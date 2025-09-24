SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_898ExtVal11                                     */
/* Copyright      : Maersk                                              */
/* Customer: For PAGE                                                   */
/*                                                                      */
/* Date        Author   Ver.     Purposes                               */
/* 2025-09-19  1.0      JackC    FCR-7818 Created                       a*/
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_898ExtVal11]
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@nStep       INT
   ,@nInputKey   INT
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cLOC        NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@cUCC        NVARCHAR( 20)
   ,@cSKU        NVARCHAR( 20)
   ,@nQTY        INT
   ,@cParam1     NVARCHAR( 20) OUTPUT
   ,@cParam2     NVARCHAR( 20) OUTPUT
   ,@cParam3     NVARCHAR( 20) OUTPUT
   ,@cParam4     NVARCHAR( 20) OUTPUT
   ,@cParam5     NVARCHAR( 20) OUTPUT
   ,@cOption     NVARCHAR( 1)
   ,@nErrNo      INT       OUTPUT
   ,@cErrMsg     NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cStorerKey  NVARCHAR( 15)

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile 
 
   IF @nFunc = 898
   BEGIN
      IF @nStep = 1  -- ASN
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF NOT EXISTS (
               SELECT 1 FROM dbo.Receipt r WITH (NOLOCK)
               INNER JOIN dbo.CodeLkUp c WITH (NOLOCK)
               ON c.LISTNAME = 'RECEIPTGRP'
                  AND c.Code = r.ReceiptGroup
                  AND c.UDF01 = CAST (@nFunc AS NVARCHAR(5))
                  AND c.UDF02 = 'UCC'
                  AND c.StorerKey = r.StorerKey
               WHERE r.ReceiptKey = @cReceiptKey
                  AND R.StorerKey = @cStorerKey
            )
            BEGIN
               SET @nErrNo = 247101 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Rcpt group not allowed
               GOTO Quit
            END
         END
      END --st1
   END --898

Quit:

END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_898ExtVal11 TO NSQL
GO


