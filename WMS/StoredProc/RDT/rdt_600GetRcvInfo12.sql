
/******************************************************************************/
/* Store procedure: rdt_600GetRcvInfo12                                       */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date        Author   Ver.  Purposes                                        */
/* 2025-09-11  Dennis   1.0   UWP-36518 Created                               */
/******************************************************************************/
      
CREATE OR ALTER PROC [RDT].[rdt_600GetRcvInfo12] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cID          NVARCHAR( 18)  OUTPUT,
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
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT
               @cLottable01 = '' ,
               @cLottable02 = '' ,
               @cLottable03 = '' ,
               @dLottable04 = '',
               @dLottable05 = '' ,
               @cLottable06 = '' ,
               @cLottable07 = '' ,
               @cLottable08 = '' ,
               @cLottable09 = '' ,
               @cLottable10 = '' ,
               @cLottable11 = '' ,
               @cLottable12 = '' ,
               @dLottable13 = '' ,
               @dLottable14 = '' ,
               @dLottable15 = ''
         END
      END
   END
END

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600GetRcvInfo12 TO NSQL
GO
