SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_898RcvFilter07                                  */
/* Copyright      : Maersk                                         */
/*                                                                      */
/* Purpose: ReceiptDetail filter                                        */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2024-10-14  1.0  CYU027       FCR-759 Created.                      */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_898RcvFilter07]
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


   DECLARE @cStorerKey    NVARCHAR( 15)
   DECLARE @cExternKey    NVARCHAR( 20)
   DECLARE @cUserDefine07 NVARCHAR( 20)

   -- Get session info
   SELECT
      @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get UCC info
   SET @cExternKey = ''
   SELECT TOP 1
      @cExternKey    = ExternKey
     ,@cUserDefine07 = Userdefined07
   FROM dbo.UCC WITH (NOLOCK)
   WHERE UCCNo = @cUCC
     AND StorerKey = @cStorerKey
     AND SKU = @cSKU
     AND Status = '0'
   ORDER BY UCC_RowRef

   -- Build custom SQL
   IF @cUCC <> ''
      SET @cCustomSQL = @cCustomSQL +
                        ' AND RTRIM( ExternReceiptKey) = ''' + RTRIM( @cExternKey) + '''' +
                        ' AND RTRIM( ExternLineNo) = ''' + RTRIM( @cUserDefine07) + ''''
QUIT:
END -- End Procedure

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_898RcvFilter07 TO NSQL
GO

