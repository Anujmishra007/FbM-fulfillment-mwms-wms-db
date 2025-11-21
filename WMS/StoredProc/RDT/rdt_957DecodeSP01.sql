SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_957DecodeSP01                                         */
/* Copyright      : Maersk                                                    */
/* Customer       : BAT SA                                                    */
/*                                                                            */
/* Purpose: Decode SKU                                                        */
/*                                                                            */
/* Date        Author    Ver.    Purposes                                     */
/* 2025-11-06  JackC     1.0     FCR-8676 Created                             */
/******************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_957DecodeSP01] ( 
   @nMobile      INT,               
   @nFunc        INT,               
   @cLangCode    NVARCHAR( 3),      
   @nStep        INT,               
   @nInputKey    INT,
   @cFacility    NVARCHAR( 20),                
   @cStorerKey   NVARCHAR( 15),
   @cBarcode     NVARCHAR(MAX),
   @cPickSlipNo  NVARCHAR( 10),
   @cPickZone    NVARCHAR( 10),
   @cDropID      NVARCHAR( 20),
   @cLOC         NVARCHAR( 10),       
   @cUPC         NVARCHAR( 30)  OUTPUT,
   @nQTY         INT            OUTPUT,
   @cUCCNo       NVARCHAR( 20)  OUTPUT,
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
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cBarcode = REPLACE(LTRIM(RTRIM(@cBarcode)), ' ', '')
    
   IF @nFunc = 957
   BEGIN
      IF @nStep = 3 -- dropid
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cBarcode <> ''  -- UCC  Decode
            BEGIN
               IF LEN(@cBarcode) = 40 OR LEN(@cBarcode) = 44 --label2
               BEGIN
                  SELECT 
                  @cUCCNo = 
                  CASE 
                     WHEN CHARINDEX('(240)', @cBarcode) > 0 THEN
                           SUBSTRING(
                              @cBarcode,
                              CHARINDEX('(240)', @cBarcode) + 5,
                              LEN(@cBarcode)
                           )
                     ELSE NULL
                  END
                  GOTO Quit
               END--label2 
               ELSE IF LEN(@cBarcode) = 34 --label4
               BEGIN
                  SELECT @cUCCNo = RIGHT(@cBarcode, 20)
                  GOTO Quit
               END
               ELSE IF LEN(@cBarcode) = 67 --label5
               BEGIN
                  SELECT @cUCCNo = SUBSTRING(@cBarcode, 19, 19)
                  GOTO Quit
               END

               
            END      
         END -- enter
      END --st3
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_957DecodeSP01] TO NSQL
GO
