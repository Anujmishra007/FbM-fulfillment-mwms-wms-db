SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode10                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Check the Pack Decode Config                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-14   1.0  GCH225     Cloned from isp_TPS_DecodeSP10 (FCR-7558)        */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode10] (
	  @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cInputValue1      NVARCHAR(128)     = ''
   , @c_UserID          NVARCHAR(256)     = ''
   , @cLangCode         NVARCHAR(3)       = ''
   , @cSKU              NVARCHAR(20)      = ''  OUTPUT
   , @nQty              INT                     OUTPUT
   , @b_Success         INT               = 0   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
   
   DECLARE @nQPos          INT
         , @nBangPos       INT
         , @cFirstValue    NVARCHAR(100)
         , @cSecondValue   NVARCHAR(100)

   SET @b_Success       = 0  
   SET @nQPos = CHARINDEX('?', @cInputValue1);
   SET @nBangPos = CHARINDEX('!', @cInputValue1);

   IF @nQPos = 0 OR @nBangPos = 0 OR @nQPos > @nBangPos
   BEGIN
      SET @n_ErrNo = 12851
	   SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Invalid format: must contain "?" before "!".' 
      GOTO QUIT
   END

   --SerialNo
   SET @cFirstValue = SUBSTRING(@cInputValue1, @nQPos + 1, @nBangPos - @nQPos - 1)
   
   --UPC
   SET @cSecondValue = SUBSTRING(@cInputValue1, @nBangPos + 1, LEN(@cInputValue1) - @nBangPos)

   IF NOT EXISTS (SELECT 1
                  FROM UPC (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND UPC = @cSecondValue
   )
   BEGIN
      SET @n_ErrNo = 12852
	   SET @c_ErrMsg = '(' + @cSecondValue + ')' + API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Current UPC is not found in UPC table.
      GOTO QUIT
   END

   IF(SELECT COUNT(1) 
      FROM UPC (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND UPC = @cSecondValue
   ) > 1
   BEGIN
      SET @n_ErrNo = 12853
	   SET @c_ErrMsg = '(' + @cSecondValue + ')' + API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Current UPC contains more than 1 SKUs. Failed to proceed decode and get the right SKU.' 
      GOTO QUIT
   END

   SELECT @cSKU = RTRIM(SKU)
   FROM UPC (NOLOCK) 
   WHERE StorerKey = @cStorerKey
   AND UPC = @cSecondValue
   
   SET @b_Success = 1

QUIT:
END



