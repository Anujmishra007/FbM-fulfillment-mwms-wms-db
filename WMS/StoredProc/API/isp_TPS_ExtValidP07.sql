SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP07                                        */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */
/* 2024-12-13   1.0  yeekung   TPS-744 Created                               */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP07] (
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

 DECLARE    @n_Foundpos INT,      
         @n_LastFoundpos INT      
    
   SET @n_Foundpos = 0      
   SET @n_LastFoundpos = 0    
     
   WHILE 1=1      
   BEGIN      
      SELECT @n_Foundpos = CHARINDEX('/', @cBarcode, @n_Foundpos + 1)      
            
      IF @n_Foundpos > 0       
         SET @n_LastFoundpos = @n_Foundpos      
      ELSE      
         BREAK              
   END       
         
   IF @n_LastFoundpos > 0      
      SELECT @jResult = SUBSTRING(@cBarcode, @n_LastFoundpos + 1, LEN(@cBarcode) - @n_LastFoundpos)      
   ELSE      
      SELECT @jResult = @cBarcode     
  

   IF EXISTS (SELECT 1 FROM SerialNo WITH (NOLOCK)
         WHERE SerialNo = @jResult      
         AND storerKey = @cStorerKey )
   BEGIN
      SET @n_Err = 1001651
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_Err, @cLangCode, 'DSP') -- 1001651 Duplicate SerialNO. Function : isp_TPS_DecodeSP09

      SET @jResult = (SELECT '' AS SKU
      FOR JSON PATH,INCLUDE_NULL_VALUES )    
      SET @b_Success = 0
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
GRANT EXECUTE ON api.isp_TPS_ExtValidP07 TO NSQL
GO