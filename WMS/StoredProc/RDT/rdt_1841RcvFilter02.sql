SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1841RcvFilter02                                 */
/* Copyright      : Maersk WMS                                          */
/* Customer: COLUMBIA SPORTSWEAR CO                                     */
/*                                                                      */
/* Purpose: ReceiptDetail filter                                        */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2025-12-01  1.0  NickT       FCR-9027 Created                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1841RcvFilter02
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cToLOC      NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cSKU        NVARCHAR( 20)
   ,@cUCC        NVARCHAR( 20)
   ,@nQTY        INT
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@dLottable05 DATETIME
   ,@cLottable06 NVARCHAR( 30)
   ,@cLottable07 NVARCHAR( 30)
   ,@cLottable08 NVARCHAR( 30)
   ,@cLottable09 NVARCHAR( 30)
   ,@cLottable10 NVARCHAR( 30)
   ,@cLottable11 NVARCHAR( 30)
   ,@cLottable12 NVARCHAR( 30)
   ,@dLottable13 DATETIME
   ,@dLottable14 DATETIME
   ,@dLottable15 DATETIME
   ,@cCustomSQL  NVARCHAR( MAX) OUTPUT
   ,@nErrNo      INT            OUTPUT
   ,@cErrMsg     NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @cCustomSQL = @cCustomSQL + 
      '     AND UserDefine01 = ' + QUOTENAME( @cUCC, '''')

QUIT:
END -- End Procedure
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_1841RcvFilter02 TO NSQL
GO

