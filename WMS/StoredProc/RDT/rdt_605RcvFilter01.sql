SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: rdt_605RcvFilter01                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Link UCC and ReceiptDetail by externreceiptkey = externkey  */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2025-06-18 1.0  Cuize      FCR-4200 Created                          */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_605RcvFilter01
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
   
   -- Get Receipt info
   DECLARE @cStorerKey NVARCHAR(15)
   DECLARE @cExternKey NVARCHAR( 20)
   
   SET @cExternKey = ''

   -- Get session info
   SELECT
      @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE UserName = SUSER_SNAME()

   -- Get UCC info
   SELECT 
       @cExternKey    = ExternKey
   FROM dbo.UCC WITH (NOLOCK) 
   WHERE UCCNo = @cUCC 
      AND StorerKey = @cStorerKey 
      AND SKU = @cSKU 

   -- Build custom SQL
   IF @cExternKey <> ''
   BEGIN
      SET @cCustomSQL = @cCustomSQL + 
      ' AND RTRIM( ExternReceiptKey) = ' + QUOTENAME( RTRIM( @cExternKey), '''')
   END
QUIT:
END -- End Procedure

GO

GRANT EXECUTE ON rdt.rdt_605RcvFilter01 TO NSQL
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
