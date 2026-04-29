SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
    
/******************************************************************************/      
/* Store procedure: isp_TPS_ExtUpd12                                          */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */      
/* Date         Rev  Author     Purposes                                      */      
/* 2026-04-23   1.0  GCH225     FCR-12698 Created                             */   
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_ExtUpd12] (      
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
   @b_Success       INT = 1        OUTPUT,    
   @n_Err           INT = 0        OUTPUT,    
   @c_ErrMsg        NVARCHAR( 255) = ''  OUTPUT     
)      
AS      
      
SET NOCOUNT ON      
SET QUOTED_IDENTIFIER OFF      
SET ANSI_NULLS OFF      
SET CONCAT_NULL_YIELDS_NULL OFF      

DECLARE     
   @cSKU             NVARCHAR(20),    
   @cLblLineNumber   NVARCHAR(5),
   @nQty             FLOAT,  
   @nTranCount       INT,
   @cAltSKU          NVARCHAR(20)
   
BEGIN    
   IF EXISTS ( SELECT 1
               FROM PACKDETAIL PD (NOLOCK)
               INNER JOIN SKU S (NOLOCK)  
               ON PD.StorerKey = S.StorerKey
               AND PD.SKU = S.SKU
               WHERE PD.StorerKey = @cStorerKey
               AND PD.PickslipNo = @cPickSlipNo
               AND PD.CartonNo = @nCartonNo
               AND PD.UPC = PD.SKU
               AND (S.AltSKU = '' OR S.AltSKU IS NULL)
   )
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 1003501      
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --The AltSKU is required for the SKU with UPC same as SKU in the carton. Please update the SKU info and try again. Function: isp_TPS_ExtUpd12
      GOTO Quit
   END

   DECLARE CURSOR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT  PD.LabelNo
         , PD.LabelLine
         , PD.SKU
         , S.AltSKU
   FROM PACKDETAIL PD (NOLOCK)
   INNER JOIN SKU S (NOLOCK)  
   ON PD.StorerKey = S.StorerKey
   AND PD.SKU = S.SKU
   WHERE PD.StorerKey = @cStorerKey
   AND PD.PickslipNo = @cPickSlipNo
   AND PD.CartonNo = @nCartonNo
   AND PD.UPC = PD.SKU
   ORDER BY PD.LabelLine DESC

   OPEN CURSOR_LOOP
   FETCH NEXT FROM CURSOR_LOOP INTO @cLabelNo
                                  , @cLblLineNumber
                                  , @cSKU
                                  , @cAltSKU
   WHILE @@FETCH_STATUS = 0
   BEGIN

      UPDATE PACKDETAIL
      SET UPC = @cAltSKU
        , EditWho = @cUserName
        , EditDate = GETDATE()
        , ArchiveCop = NULL
      WHERE PickslipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND LabelNo = @cLabelNo
      AND LabelLine = @cLblLineNumber

      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 1003502      
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') --Fail to update AltSKU into UPC field in PackDetail table. Please contact system administrator. Function: isp_TPS_ExtUpd12
         GOTO Quit
      END
         
      FETCH NEXT FROM CURSOR_LOOP INTO   @cLabelNo
                                       , @cLblLineNumber
                                       , @cSKU
                                       , @cAltSKU
   END
   CLOSE CURSOR_LOOP
   DEALLOCATE CURSOR_LOOP
   
   IF EXISTS ( SELECT 1
               FROM PACKDETAIL (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND PickslipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
               GROUP BY StorerKey, PickslipNo, CartonNo, SKU, UPC, DropID, LOTTABLEVALUE
               HAVING COUNT(*) > 1
   )
   BEGIN
      ;WITH UPD_CTE AS (
         SELECT *,
               ROW_NUMBER() OVER (
                     PARTITION BY PickSlipNo, CartonNo, LabelNo, SKU, UPC, DropID, LOTTABLEVALUE
                     ORDER BY LabelLine ASC   -- keep first row
               ) AS rn,
               SUM(Qty) OVER (
                     PARTITION BY PickSlipNo, CartonNo, LabelNo, SKU, UPC, DropID, LOTTABLEVALUE
               ) AS TotalQty
         FROM PACKDETAIL (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND PickslipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
      )
      UPDATE UPD_CTE
      SET Qty = TotalQty
      , ArchiveCop = NULL
      WHERE rn = 1

      -- delete duplicates
      ;WITH DEL_CTE AS (
         SELECT ROW_NUMBER() OVER (
                     PARTITION BY PickSlipNo, CartonNo, LabelNo, SKU, UPC, DropID, LOTTABLEVALUE
                     ORDER BY LabelLine ASC
               ) AS rn
         FROM PACKDETAIL (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND PickslipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
      )
      DELETE FROM DEL_CTE
      WHERE rn <> 1
   END
Quit:
END      
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtUpd12 TO NSQL
GO