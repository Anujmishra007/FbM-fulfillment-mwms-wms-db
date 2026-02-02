SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
    
/******************************************************************************/      
/* Store procedure: isp_TPS_PostExtUpd02                                      */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2025-09-26   1.0  GCH225     FCR-8031 Update Estimate Total Carton         */ 
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_PostExtUpd02] (      
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
       , @nLastCartonNo    INT
 
SET @b_Success = 1   
     
--SELECT 'aa',* FROM @CloseCtnList    
BEGIN    
   SET @nTranCount = @@TRANCOUNT    
   BEGIN TRAN    
   SAVE TRAN isp_TPS_PostExtUpd02     

   SELECT @nLastCartonNo= MAX(CartonNo) 
   FROM PACKINFO (NOLOCK)
   WHERE PickSlipNo = @cpickslipNo

   UPDATE PACKHEADER WITH(ROWLOCK)
   SET EstimateTotalCtn = @nLastCartonNo
   WHERE PickSlipNo = @cpickslipNo

   GOTO QUIT
     
RollBackTran:    
   ROLLBACK TRAN isp_TPS_PostExtUpd02    

QUIT:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
   BEGIN
      COMMIT TRAN isp_TPS_PostExtUpd02           
   END  
END      
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_PostExtUpd02 TO NSQL
GO


