IF EXISTS (SELECT name FROM sysobjects WHERE name = 'rdt_898RcvFilter03' AND type = 'P')
   DROP PROC rdt.rdt_898RcvFilter03
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_898RcvFilter03                                  */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: ReceiptDetail filter                                        */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2020-09-05  1.0  Chermaine   WMS-14444 Created                       */  
/************************************************************************/

CREATE PROCEDURE rdt.rdt_898RcvFilter03
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cToLOC      NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME 
   ,@cSKU        NVARCHAR( 20)
   ,@cUCC        NVARCHAR( 20)
   ,@nQTY        INT
   ,@cCustomSQL  NVARCHAR( MAX) OUTPUT
   ,@nErrNo      INT            OUTPUT
   ,@cErrMsg     NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   IF @cUCC <> ''
      SET @cCustomSQL = @cCustomSQL + 
         ' AND (QTYExpected - BeforeReceivedQTY >= ' + CAST( @nQTY AS NVARCHAR(5)) + 
         '  OR  QTYExpected = 0) '

QUIT:
END -- End Procedure

GO

GRANT EXECUTE ON rdt.rdt_898RcvFilter03 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
