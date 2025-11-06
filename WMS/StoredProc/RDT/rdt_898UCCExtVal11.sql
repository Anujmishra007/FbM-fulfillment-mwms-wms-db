SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_898UCCExtVal11                                     */
/* Copyright      :                                                        */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Date        Rev   Author   Purposes                                     */
/* 2025-10-27  1.0   Dennis   FCR-8601. Created                            */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898UCCExtVal11]
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cLOC        NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@cUCC        NVARCHAR( 20)
   ,@nErrNo      INT           OUTPUT
   ,@cErrMsg     NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 898 -- UCC receiving
   BEGIN
      IF NOT EXISTS(
         SELECT 1 FROM dbo.RECEIPTDETAIL RD (NOLOCK)
         JOIN dbo.RECEIPT R (NOLOCK) ON RD.ReceiptKey = R.ReceiptKey AND R.StorerKey = RD.StorerKey
         JOIN dbo.UCC UCC (NOLOCK) ON RD.StorerKey = UCC.StorerKey AND RD.UserDefine01 = UCC.UCCNO
         JOIN dbo.PO WITH (NOLOCK) ON RD.StorerKey = PO.StorerKey AND RD.POKEY = PO.POKEY
         WHERE RD.ReceiptKey = @cReceiptKey
         AND R.DOCTYPE = 'A'
         AND UCC.UCCNo = @cUCC
         AND PO.STATUS = '0'
      )
      BEGIN
         SET @nErrNo = 225308 
         SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') -- UCC from PO closed/ Unavailable
         GOTO Quit
      END
   END

   GOTO Quit

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_898UCCExtVal11] TO [NSQL]
GO
