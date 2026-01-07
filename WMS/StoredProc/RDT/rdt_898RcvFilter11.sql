SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_898RcvFilter11                                  */
/* Copyright      :                                                     */
/*                                                                      */
/* Purpose: ReceiptDetail filter                                        */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2025-12-02  1.0  Dennis      FCR-9273  Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_898RcvFilter11
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
   
   IF @cUCC <> '' AND NOT EXISTS( SELECT 1 FROM RECEIPT (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND (DOCTYPE = 'R' OR RECTYPE = 'ONTO'))
      SET @cCustomSQL = @cCustomSQL + 
         ' AND UserDefine01 = ' + QUOTENAME( @cUCC, '''')

QUIT:
END -- End Procedure

GO

GRANT EXECUTE ON rdt.rdt_898RcvFilter11 TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
