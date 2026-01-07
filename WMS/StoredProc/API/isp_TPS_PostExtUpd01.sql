SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
    
/******************************************************************************/      
/* Store procedure: isp_TPS_PostExtUpd01                                      */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2025-09-02   1.0  GCH225     FCR-7712 handle post extended update          */ 
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_PostExtUpd01] (      
   @cStorerKey      NVARCHAR( 15),    
   @cFacility       NVARCHAR( 5),      
   @nFunc           INT,          
   @cUserName       Nvarchar( 128),    
   @cLangCode       NVARCHAR( 3),     
   @cScanNo         NVARCHAR( 50),    
   @cpickslipNo     NVARCHAR( 30),    
   @cDropID         NVARCHAR( 50),    
   @cOrderKey       NVARCHAR( 10),    
   @cLoadKey        NVARCHAR( 10),    
   @cZone           NVARCHAR( 18),    
   @EcomSingle      NVARCHAR( 1),     
   @nCartonNo       INT,          
   @cCartonType     NVARCHAR( 10),     
   @cType           NVARCHAR( 30),     
   @fCartonWeight   FLOAT,         
   @fCartonCube     FLOAT,         
   @cWorkstation    NVARCHAR( 30),     
   @cLabelNo        NVARCHAR( 20), 
   @cCloseCartonJson   NVARCHAR (MAX),   
   @pickSkuDetailJson   NVARCHAR( MAX),
   @b_Success       INT = 1               OUTPUT,    
   @n_Err           INT = 0               OUTPUT,    
   @c_ErrMsg        NVARCHAR( 255) = ''   OUTPUT     
)      
AS      
      
SET NOCOUNT ON      
SET QUOTED_IDENTIFIER OFF      
SET ANSI_NULLS OFF      
SET CONCAT_NULL_YIELDS_NULL OFF      
    
DECLARE  @nTranCount       INT
       , @cCurOrderkey     NVARCHAR(20)
       , @CUR_PSN          CURSOR
       , @nPSN_Qty         INT
       , @nPDQty           INT
       , @cPSN_LabelNo     NVARCHAR(20)
       , @cPSN_SKU         NVARCHAR(20)
       , @cPickDetailKey   NVARCHAR(10)
       , @cPackSerialNoKey BIGINT
 
DECLARE @tPickDetailKeyTable TABLE (
    PickDetailKey  NVARCHAR(18) PRIMARY KEY
  , Qty            INT
)
SET @b_Success = 1   
     
--SELECT 'aa',* FROM @CloseCtnList    
BEGIN    
   SET @nTranCount = @@TRANCOUNT    
   BEGIN TRAN    
   SAVE TRAN isp_TPS_PostExtUpd01     
   
   SELECT @cCurOrderkey = Orderkey  
   FROM PICKHEADER (NOLOCK)  
   WHERE Pickheaderkey = @cpickslipNo  
  
   IF ISNULL( @cCurOrderkey,'') <> ''  
      SET @cOrderkey = @cCurOrderkey  

   SET @cOrderKey = ISNULL(@cOrderKey,'')
   SET @cLoadKey = ISNULL(@cLoadKey,'')

   IF @cOrderKey = '' AND @cLoadKey = ''     
   BEGIN
      SET @b_Success = 0;
      SET @n_Err = 1003301        
      SET @c_ErrMsg = API.TouchPadGetMessage(@n_Err ,@cLangCode ,'DSP') -- 'OrderKey or LoadKey Not found, failed to proceed. Function : isp_TPS_PostExtUpd01'        
      GOTO RollBackTran       
   END   

   --UPDATE PSN
   --SET PickDetailKey = PD.PickDetailKey
   --  , EditWho = @cUserName
   --  , EditDate = GETDATE()
   --  , TrafficCop = NULL
   --FROM PACKSERIALNO PSN WITH (ROWLOCK)
   --INNER JOIN PICKDETAIL PD (NOLOCK)
   --ON PD.StorerKey = PSN.StorerKey
   --AND PD.CaseID = PSN.LabelNo
   --AND PD.SKU = PSN.SKU
   --AND PD.OrderKey = @cOrderKey
   --WHERE PSN.StorerKey = @cStorerKey
   --AND PSN.PickSlipNo = @cpickslipNo

   SET @CUR_PSN = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PackSerialNoKey, LabelNo, SKU, Qty
   FROM PACKSERIALNO (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND PickSlipNo = @cpickslipNo

   OPEN @CUR_PSN
   FETCH NEXT FROM @CUR_PSN INTO @cPackSerialNoKey, @cPSN_LabelNo, @cPSN_SKU, @nPSN_Qty
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @cPickDetailKey = ''
      SET @nPDQty = 0
      DELETE FROM @tPickDetailKeyTable

      IF @nPSN_Qty > 1
      BEGIN
         --why skip, is because system cannot determine which pickdetailkey can use to update the packserialno table.
         GOTO NEXTITEM
      END

      IF @cOrderKey <> ''
      BEGIN
         INSERT INTO @tPickDetailKeyTable (PickDetailKey, Qty)
         SELECT PickDetailKey, Qty
         FROM PICKDETAIL (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND OrderKey = @cOrderKey
         AND CaseID = @cPSN_LabelNo
         AND SKU = @cPSN_SKU
      END
      ELSE
      BEGIN
         INSERT INTO @tPickDetailKeyTable (PickDetailKey, Qty)
         SELECT PickDetailKey, Qty
         FROM PICKDETAIL PD (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
         AND EXISTS( SELECT 1 
                     FROM LOADPLANDETAIL LPD (NOLOCK)
                     WHERE LPD.LoadKey = @cLoadKey
                     AND LPD.OrderKey = PD.OrderKey
         )
         AND PD.CaseID = @cPSN_LabelNo
         AND PD.SKU = @cPSN_SKU
      END

      IF NOT EXISTS (SELECT 1 FROM @tPickDetailKeyTable)
      BEGIN
         --why skip, is because system cannot determine which pickdetailkey can use to update the packserialno table.
         GOTO NEXTITEM
      END

      WHILE EXISTS (SELECT 1 FROM @tPickDetailKeyTable)
      BEGIN
         SELECT TOP 1 @cPickDetailKey = PickDetailKey 
                     ,@nPDQty = Qty
         FROM @tPickDetailKeyTable

         IF ( SELECT COUNT(1)
              FROM PACKSERIALNO (NOLOCK)
              WHERE StorerKey = @cStorerKey
              AND PickSlipNo = @cpickslipNo
              AND LabelNo = @cPSN_LabelNo
              AND SKU = @cPSN_SKU
              AND PickDetailKey = @cPickDetailKey
         ) <> @nPDQty
         BEGIN
            BREAK
         END
         
         DELETE FROM @tPickDetailKeyTable WHERE PickDetailKey = @cPickDetailKey

         IF NOT EXISTS (SELECT 1 FROM @tPickDetailKeyTable)
         BEGIN
            --why skip, is because system cannot determine which pickdetailkey can use to update the packserialno table.
            GOTO NEXTITEM
         END
      END

      UPDATE PACKSERIALNO WITH (ROWLOCK)
      SET  PickDetailKey = @cPickDetailKey
         , EditWho = @cUserName
         , EditDate = GETDATE()
         , TrafficCop = NULL
      WHERE PackSerialNoKey = @cPackSerialNoKey

      IF @@ERROR <> 0  
      BEGIN           
         SET @b_Success = 0    
         SET @n_Err = 1003303    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'Fail to update into PACKSERIALNO. Function : isp_TPS_PostExtUpd01'   
         GOTO RollBackTran  
      END

NEXTITEM:
      FETCH NEXT FROM @CUR_PSN INTO @cPackSerialNoKey, @cPSN_LabelNo, @cPSN_SKU, @nPSN_Qty
   END

   CLOSE @CUR_PSN;
   DEALLOCATE @CUR_PSN;

   GOTO QUIT
     
 RollBackTran:    
      ROLLBACK TRAN isp_TPS_PostExtUpd01    

QUIT:  
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      BEGIN
         COMMIT TRAN isp_TPS_PostExtUpd01           
      END
    
END      
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_PostExtUpd01 TO NSQL
GO


