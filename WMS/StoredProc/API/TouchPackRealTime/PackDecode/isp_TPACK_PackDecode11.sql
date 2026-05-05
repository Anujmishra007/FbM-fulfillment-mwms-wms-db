SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PackDecode11                                       */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : MODT UPC;EPC Decode                                          */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-04-20   1.0  GCH225     FCR-11777 Created                                */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_PackDecode11] (
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
   , @cInputValue2      NVARCHAR(MAX)     = ''  OUTPUT
   , @cInputValue3      NVARCHAR(128)     = ''  OUTPUT
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
   
   DECLARE @cUPC  NVARCHAR(100)
         , @cEPC  NVARCHAR(100)

   SET @b_Success = 0  

   SET @cUPC = @cInputValue1

   IF  CHARINDEX(';', @cInputValue1) > 0
   BEGIN
      SET @cUPC = LEFT(@cInputValue1, CHARINDEX(';', @cInputValue1) - 1)
      SET @cEPC = RIGHT(@cInputValue1, LEN(@cInputValue1) - CHARINDEX(';', @cInputValue1))
   END

   SELECT @cSKU = ISNULL(RTRIM(SKU), '')
   FROM UPC (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND UPC = @cUPC

   IF @@ROWCOUNT = 0 OR @cSKU = ''
   BEGIN
      SET @n_ErrNo = 15701
	   SET @c_ErrMsg = '(' + @cUPC + ')' + API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Current UPC is not found in UPC table.
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1
               FROM SKU (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND BUSR5 = 'Y'
   )
   BEGIN
      IF @cEPC = ''
      BEGIN
         SET @n_ErrNo = 15702
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Current SKU requires EPC value, but no EPC value is provided.
         GOTO QUIT
      END
      ELSE
      BEGIN
         IF LEN(@cEPC) <> 24
         BEGIN
            SET @n_ErrNo = 15703
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --The length of EPC value is not correct. Expected length is 24.
             GOTO QUIT
         END
      END
   END
   ELSE
   BEGIN
      IF @cEPC <> ''
      BEGIN
         SET @n_ErrNo = 15704
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Current SKU does not require EPC scan, but got EPC value.
         GOTO QUIT
      END
   END
   
   SET @cInputValue2 = '["' + @cEPC + '"]'
   SET @cInputValue3 = ''
   SET @b_Success = 1

QUIT:
END
