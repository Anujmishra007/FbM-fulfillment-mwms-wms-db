
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_727Inquiry22                                       */
/* Copyright      : LF Logistics                                           */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date       Rev  Author     Purposes                                     */
/* 2023-10-02 1.0  yeekung    WMS-23791 Created                            */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_727Inquiry22] (
 	@nMobile      INT,  
   @nFunc        INT,  
   @nStep        INT,  
   @cLangCode    NVARCHAR(3),  
   @cStorerKey   NVARCHAR(15),  
   @cOption      NVARCHAR(1),  
   @cParam1      NVARCHAR(60),  
   @cParam2      NVARCHAR(60),  
   @cParam3      NVARCHAR(60),  
   @cParam4      NVARCHAR(60),  
   @cParam5      NVARCHAR(60),  
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
   @nErrNo       INT          OUTPUT,  
   @cErrMsg      NVARCHAR(20) OUTPUT  
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0

   DECLARE @cUPC NVARCHAR(20)
   DECLARE @cID NVARCHAR(20)
   DECLARE @cComponentSKU NVARCHAR(20)
   DECLARE @cFacility   NVARCHAR(20)


   IF @nFunc = 727 -- General inquiry
   BEGIN
      IF @nStep = 2
      BEGIN
         SELECT @cFacility = facility
         FROM RDT.RDTMOBREC (NOLOCK)
         WHERE Mobile = @nMobile

         IF ISNULL(@cParam1,'') =''
         BEGIN
            SET @nErrNo = 206951
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedBoxBarcode
            EXEC rdt.rdtSetFocusField @nMobile, 2 -- SKU
            GOTO QUIT
         END

         IF ISNULL(@cParam2,'') =''
         BEGIN
            SET @nErrNo = 206952
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NeedSSCCSKU
            EXEC rdt.rdtSetFocusField @nMobile, 4 -- SKU
            GOTO QUIT
         END

         SET @cUPC = @cParam1

         EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, '1', @cStorerKey, @cFacility, @cParam1,
            @cUPC     = @cUPC     OUTPUT,
            @cType   = 'UPC'


         SELECT @c_oFieled01 = UDF01,
                @c_oFieled02 = @cUPC,
                @c_oFieled04 = UDF02,
                @c_oFieled05 = @cParam2
         FROM dbo.CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'RDTINQUIRY'
            AND StorerKey = @cStorerKey
            AND code = @cOption

         IF EXISTS ( SELECT 1
                     FROM BillOfMaterial (NOLOCK) 
                     WHERE Storerkey = @cStorerKey
                        AND SKU = @cUPC
                        AND ComponentSku = @cParam2)
         BEGIN
            SET @c_oFieled07 = 'OK'
         END
         ELSE
         BEGIN
            SET @c_oFieled07 = 'Not match BOM'
         END
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_727Inquiry22 TO NSQL
GO
