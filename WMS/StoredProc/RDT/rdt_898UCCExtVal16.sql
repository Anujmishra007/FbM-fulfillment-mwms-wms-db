SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Store procedure: rdt_898UCCExtVal16                                     */
/* Copyright      : Maersk                                                 */
/* Customer       : For PAGE                                               */
/*                                                                         */
/* Purpose: UCC extended validation for FCR-15183                          */
/*                                                                         */
/* Date        Rev   Author   Purposes                                     */
/* 2026-09-17  1.0   NickT    FCR-15183 Created - Single SKU/Batch check  */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_898UCCExtVal16]
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

   IF @nFunc = 898
   BEGIN

      DECLARE
         @cStorerKey       NVARCHAR( 15)
        ,@nSKUCount        INT = 0
        ,@nLottable01Count INT = 0

      SELECT @cStorerKey = StorerKey
      FROM rdt.RDTMOBREC WITH (NOLOCK) 
      WHERE Mobile = @nMobile 

      IF LEFT(@cToID, 2) <> 'DM'
      BEGIN
         SELECT
            @nSKUCount        = COUNT(DISTINCT SKU),
            @nLottable01Count = COUNT(DISTINCT Lottable01)
         FROM dbo.ReceiptDetail WITH (NOLOCK)
         WHERE ReceiptKey = @cReceiptKey
            AND StorerKey = @cStorerKey
            AND UserDefine01 IS NOT NULL
            AND UserDefine01 = @cUCC

         SET @nSKUCount        = ISNULL(@nSKUCount, 0)
         SET @nLottable01Count = ISNULL(@nLottable01Count, 0)

         IF @nSKUCount > 1 OR @nLottable01Count > 1
         BEGIN
            SET @nErrNo = 281801
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ONLY SINGLE SKU + BATCH UCC allowed
            GOTO Quit
         END
      END

   END -- 898

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_898UCCExtVal16] TO [NSQL]
GO
