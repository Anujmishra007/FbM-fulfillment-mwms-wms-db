SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP06                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2024-12-13   1.0  yeekung   TPS-949 Created                               */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP06] (
	@json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1        OUTPUT,
   @n_Err      INT = 0        OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
BEGIN
	DECLARE
		@cStorerKey		NVARCHAR ( 15),
      @cFacility		NVARCHAR ( 5),
      @nFunc			INT,
      @cBarcode		NVARCHAR( 60),
      @cUserName		NVARCHAR( 30),
      @cLangCode		NVARCHAR( 3),
      @cSKU				NVARCHAR( 30),
		@cPickSlipNo	NVARCHAR( 30),
		@nQTY				INT,
		@cOrderKey		NVARCHAR( 20),
		@cLoadkey		NVARCHAR( 20),
		@cZone			NVARCHAR( 20),
		@nPickQTY		INT,
		@nPackQTY		INT,
      @cSerialNo     NVARCHAR( 20)

	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode, @cPickSlipNo = PickSlipNo
   FROM OPENJSON(@json)
   WITH (
      StorerKey   NVARCHAR ( 15),
      Facility    NVARCHAR ( 5),
      Func        INT,
      Barcode     NVARCHAR( 60),
		PickSlipNo  NVARCHAR( 20),
      UserName    NVARCHAR( 30),
      LangCode    NVARCHAR( 3)
   )

   SET @b_Success = 1

   DECLARE @curValid CURSOR
   DECLARE @cQRCodeValid NVARCHAR(60)

   SET @curValid = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT  Long
   FROM Codelkup  
   WHERE Listname =  'QRTPS'
      AND Storerkey = @cStorerkey


   OPEN @curValid  
   FETCH NEXT FROM @curValid INTO @cQRCodeValid
   WHILE @@FETCH_STATUS <> -1  
   BEGIN  
      IF @cBarcode LIKE @cQRCodeValid
      BEGIN     
         SET @b_Success = 0    
         SET @n_Err = 1001501    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'1000701 Err Scan QRCode : isp_TPS_ExtValidP06'  
         GOTO QUIT  
      END  

      FETCH NEXT FROM @curValid INTO @cQRCodeValid
   END
   CLOSE @curValid
   DEALLOCATE @curValid

   IF EXISTS ( SELECT 1
               FROM PackserialNo (nolock)
               WHERe Pickslipno = @cPickslipno
                  AND Storerkey = @cStorerkey
                  AND Barcode = @cBarcode)
   BEGIN
      SET @b_Success = 0    
      SET @n_Err = 1001502    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP')--'1000702 Duplicate QRCode : isp_TPS_ExtValidP06'  
      GOTO QUIT  
   END

   SET @b_Success = 1
   SET @jResult = (SELECT '' AS SKU
   FOR JSON PATH,INCLUDE_NULL_VALUES ) 

   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'
QUIT:
END


GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_ExtValidP06 TO NSQL
GO