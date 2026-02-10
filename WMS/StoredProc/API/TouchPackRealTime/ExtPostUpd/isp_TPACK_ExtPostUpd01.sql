SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtPostUpd01                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Post Update to PackSerialNo table.                  */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-28   1.0  GCH225     Cloned from isp_TPS_PostExtUpd01 (FCR-7712)      */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtPostUpd01] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  

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
   SET @b_Success    = 0  
   SET @n_ErrNo      = 0  
   SET @c_ErrMsg     = ''

   DECLARE CUR_PSN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PackSerialNoKey, LabelNo, SKU, Qty
   FROM PACKSERIALNO (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND PickSlipNo = @cpickslipNo

   OPEN CUR_PSN
   FETCH NEXT FROM CUR_PSN INTO @cPackSerialNoKey, @cPSN_LabelNo, @cPSN_SKU, @nPSN_Qty
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

      IF @bIsDiscrete = 1
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
         , EditWho = @c_UserID
         , EditDate = GETDATE()
         , TrafficCop = NULL
      WHERE PackSerialNoKey = @cPackSerialNoKey

      IF @@ERROR <> 0  
      BEGIN           
         SET @b_Success = 3    
         SET @n_ErrNo = 13201    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to update into PACKSERIALNO.'   
         GOTO EXIT_SP  
      END

NEXTITEM:
      FETCH NEXT FROM CUR_PSN INTO @cPackSerialNoKey, @cPSN_LabelNo, @cPSN_SKU, @nPSN_Qty
   END
   CLOSE CUR_PSN;
   DEALLOCATE CUR_PSN;

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END

