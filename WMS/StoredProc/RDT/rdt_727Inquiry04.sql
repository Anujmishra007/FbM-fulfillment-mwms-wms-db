SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_727Inquiry04                                       */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author   Purposes                                       */
/* 2018-03-27 1.0  ChewKP   WMS-4388 Created                               */
/* 2019-09-20 1.1  YeeKung  WMS-10536 Change the parameter                 */  
/* 2023-10-03 1.2  Yeekung  WMS-23791 Extended Params (yeekung01)          */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_727Inquiry04] (
 @nMobile    INT,
 @nFunc      INT,
 @nStep      INT,
 @cLangCode  NVARCHAR( 3),
 @cStorerKey NVARCHAR( 15),
 @cOption    NVARCHAR( 1),
 @cParam1    NVARCHAR(60),
 @cParam2    NVARCHAR(60),
 @cParam3    NVARCHAR(60),
 @cParam4    NVARCHAR(60),
 @cParam5    NVARCHAR(60),
 @c_oFieled01  NVARCHAR(20) OUTPUT,
 @c_oFieled02  NVARCHAR(20) OUTPUT,
 @c_oFieled03  NVARCHAR(20) OUTPUT,
 @c_oFieled04  NVARCHAR(20) OUTPUT,
 @c_oFieled05  NVARCHAR(20) OUTPUT,
 @c_oFieled06  NVARCHAR(20) OUTPUT,
 @c_oFieled07  NVARCHAR(20) OUTPUT,
 @c_oFieled08  NVARCHAR(20) OUTPUT,
 @c_oFieled09  NVARCHAR(20) OUTPUT,
 @c_oFieled10  NVARCHAR(20) OUTPUT,
 @c_oFieled11  NVARCHAR(20) OUTPUT,
 @c_oFieled12  NVARCHAR(20) OUTPUT,
 @nNextPage    INT          OUTPUT,
 @nErrNo     INT OUTPUT,
 @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cReceiptKey NVARCHAR(10)
          ,@cSKU        NVARCHAR(20)
          ,@cUPC        NVARCHAR(20)
          ,@cCartonNo   NVARCHAR(30)

   DECLARE @nSKUCnt     INT
          ,@b_Success   INT



SET @nErrNo = 0


IF @cOption = '1'
BEGIN
   --IF @nStep = 2 OR @nStep = 3 OR @nStep = 4
   --BEGIN

      IF @nStep = 2
      BEGIN
         SET @cReceiptKey = @cParam1
         SET @cUPC        = @cParam3

         IF @cReceiptKey = ''
         BEGIN
            SET @nErrNo = 121801
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ReceiptKeyReq
            GOTO QUIT
         END

         IF NOT EXISTS ( SELECT 1 FROM dbo.Receipt WITH (NOLOCK)
                         WHERE ReceiptKey = @cReceiptKey
                         AND StorerKey = @cStorerKey   )
         BEGIN
            SET @nErrNo = 121802
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidReceiptKey
            GOTO QUIT
         END

         IF ISNULL(@cUPC,'') = ''
         BEGIN
            SET @nErrNo = 121803
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUReq
            GOTO QUIT
         END

         -- Get SKU/UPC
         SET @nSKUCnt = 0

         EXEC RDT.rdt_GETSKUCNT
             @cStorerKey  = @cStorerKey
            ,@cSKU        = @cUPC
            ,@nSKUCnt     = @nSKUCnt       OUTPUT
            ,@bSuccess    = @b_Success     OUTPUT
            ,@nErr        = @nErrNo        OUTPUT
            ,@cErrMsg     = @cErrMsg       OUTPUT

         -- Validate SKU/UPC
         IF @nSKUCnt = 0
         BEGIN
            SET @nErrNo = 121804
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidSKU
            GOTO QUIT
         END

         IF @nSKUCnt = 1
            EXEC [RDT].[rdt_GETSKU]
                @cStorerKey  = @cStorerKey
               ,@cSKU        = @cUPC          OUTPUT
               ,@bSuccess    = @b_Success     OUTPUT
               ,@nErr        = @nErrNo        OUTPUT
               ,@cErrMsg     = @cErrMsg       OUTPUT

-- Validate barcode return multiple SKU
         IF @nSKUCnt > 1
         BEGIN

            SET @nErrNo = 121805
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiBarcode
            GOTO QUIT
         END
         ELSE
            SET @cSKU = @cUPC


         IF NOT EXISTS ( SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK)
                         WHERE StorerKey = @cStorerKey
                         AND ReceiptKey = @cReceiptKey
                         AND SKU = @cSKU )
         BEGIN
            SET @nErrNo = 121806
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKUNotInASN
            GOTO QUIT
         END

         SELECT TOP 1 @cCartonNo = UserDefine05
         FROM dbo.ReceiptDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND ReceiptKey = @cReceiptKey
         AND SKU = @cSKU


         SET @c_oFieled01 = 'ASN :'  + @cReceiptKey
         SET @c_oFieled02 = 'SKU :'
         SET @c_oFieled03 = @cSKU
         SET @c_oFieled04 = ''
         SET @c_oFieled05 = ''
         SET @c_oFieled06 = 'CARTON NO:' + @cCartonNo
         SET @c_oFieled07 = ''
         SET @c_oFieled08 = ''
         SET @c_oFieled09 = ''
         SET @c_oFieled10 = ''

         SET @nNextPage = 0

      END

   --END
END
QUIT:



GO
GRANT EXECUTE ON  [RDT].[rdt_727Inquiry04] TO [NSQL]
GO
