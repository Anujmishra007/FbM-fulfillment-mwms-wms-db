SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_830DecodeSP08                                         */
/* Copyright      : Maersk                                                    */
/* Customer       : South Africa BAT                                          */
/*                                                                            */
/* Purpose: Decode SKU                                                        */
/*                                                                            */
/* Date        Author    Ver.    Purposes                                     */
/* 2025-11-10  Jackc     1.0     FCR-8676 Created                             */
/******************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_830DecodeSP08] ( 
  @nMobile      INT,               
  @nFunc        INT,               
  @cLangCode    NVARCHAR( 3),      
  @nStep        INT,               
  @nInputKey    INT,               
  @cStorerKey   NVARCHAR( 15),        
  @cFacility    NVARCHAR( 20),   
  @cLOC         NVARCHAR( 10),   
  @cDropid      NVARCHAR( 20),
  @cpickslipno  NVARCHAR( 20), 
  @cBarcode     NVARCHAR( 2000),
  @cFieldName   NVARCHAR( 10),     
  @cUPC         NVARCHAR( 20)  OUTPUT,
  @cSKU         NVARCHAR( 20)  OUTPUT,
  @nQTY         INT            OUTPUT,
  @cLottable01  NVARCHAR( 18)  OUTPUT,
  @cLottable02  NVARCHAR( 18)  OUTPUT,
  @cLottable03  NVARCHAR( 18)  OUTPUT,
  @dLottable04  DATETIME       OUTPUT,
  @dLottable05  DATETIME       OUTPUT,
  @cLottable06  NVARCHAR( 30)  OUTPUT,
  @cLottable07  NVARCHAR( 30)  OUTPUT,
  @cLottable08  NVARCHAR( 30)  OUTPUT,
  @cLottable09  NVARCHAR( 30)  OUTPUT,
  @cLottable10  NVARCHAR( 30)  OUTPUT,
  @cLottable11  NVARCHAR( 30)  OUTPUT,
  @cLottable12  NVARCHAR( 30)  OUTPUT,
  @dLottable13  DATETIME       OUTPUT,
  @dLottable14  DATETIME       OUTPUT,
  @dLottable15  DATETIME       OUTPUT,
  @cUserDefine01 NVARCHAR(30)  OUTPUT,
  @nErrNo       INT            OUTPUT,
  @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cBarcode = REPLACE(LTRIM(RTRIM(@cBarcode)), ' ', '')
    
   IF @nFunc = 830
   BEGIN
      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cBarcode <> ''
            BEGIN
               IF LEN(@cBarcode) = 17 --label 2
               BEGIN
                  SELECT @cUPC = 
                  CASE 
                     WHEN CHARINDEX('(21)', @cBarcode) > 0 AND CHARINDEX('(241)', @cBarcode) > CHARINDEX('(21)', @cBarcode) THEN
                           SUBSTRING(
                              @cBarcode,
                              CHARINDEX('(21)', @cBarcode) + 4,
                              CHARINDEX('(241)', @cBarcode) - CHARINDEX('(21)', @cBarcode) - 4
                           )
                     ELSE NULL
                  END

                  GOTO Quit
               END --label 2
               ELSE IF LEN(@cBarcode) = 67 --label 5
               BEGIN
                  SELECT  @cUPC = SUBSTRING(@cBarcode, 51, 8)
                  GOTO Quit
               END --label 5
            END
         END
      END --st3
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_830DecodeSP08] TO NSQL
GO
