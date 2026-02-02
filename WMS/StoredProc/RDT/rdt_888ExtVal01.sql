SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_888ExtVal01                                        */
/* Copyright      : Maersk WMS                                             */
/* Customer       : PAGE Inida                                             */
/*                                                                         */
/* Date       Rev    Author     Purposes                                   */
/* 2025-10-13 1.0    Jackc      FCR-8271 Created                           */
/***************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_888ExtVal01]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR(  3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5) 
   ,@cStorerKey      NVARCHAR( 15)
   ,@cReceiptKey     NVARCHAR( 10)
   ,@cReceiptLineNo  NVARCHAR( 5)
   ,@cLOC            NVARCHAR( 10)
   ,@cID             NVARCHAR( 18)
   ,@cLottable01     NVARCHAR( 18)
   ,@cLottable02     NVARCHAR( 18)
   ,@cLottable03     NVARCHAR( 18)
   ,@dLottable04     DATETIME
   ,@dLottable05     DATETIME
   ,@cUCC            NVARCHAR( 20)
   ,@cSKU            NVARCHAR( 20)
   ,@nQTY            INT
   ,@cStatus         NVARCHAR( 10) 
   ,@cASNStatus      NVARCHAR( 10) 
   ,@cNewQty         NVARCHAR(  5)
   ,@cOption         NVARCHAR( 1)
   ,@nErrNo          INT            OUTPUT
   ,@cErrMsg         NVARCHAR( 20)  OUTPUT 
AS
BEGIN
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   IF @nFunc = 888
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
                  AND c.Code2 = CAST (@nFunc AS NVARCHAR(5))
                  AND c.UDF01 = 'UCC'
                  AND c.StorerKey = r.StorerKey
               WHERE r.ReceiptKey = @cReceiptKey
                  AND R.StorerKey = @cStorerKey
            )
            BEGIN
               SET @nErrNo = 248851 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Rcpt group not allowed
               GOTO Quit
            END
         END
      END --st1
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(@cLOC, '') = ''
            BEGIN
               SET @nErrNo = 248852
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --loc required
               GOTO Quit
            END
         END
      END --st2
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(@cID, '') = ''
            BEGIN
               SET @nErrNo = 248853
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --id required
               GOTO Quit
            END
         END
      END --st3
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_888ExtVal01 TO NSQL
GO