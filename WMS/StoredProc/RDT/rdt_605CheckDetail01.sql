SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_605CheckDetail01                             */
/* Copyright      : Maersk WMS                                                */
/*                                                                            */
/* Purpose: For rdt_PalletReceive check receiptdetail                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2025-06-18 1.0  Cuize      FCR-4200 Created                               */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_605CheckDetail01 (
   @nFunc            INT,
   @nMobile          INT,
   @cLangCode        NVARCHAR(  3),
   @nScn             INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR(  5),
   @cReceiptKey      NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cRefNo           NVARCHAR( 20),
   @cStorerKey       NVARCHAR( 15) OUTPUT,
   @cActReceiptKey   NVARCHAR( 10) OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 1024) OUTPUT
) AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @nTotalLine   INT

   -- Check barcode format
   IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'ID', @cID) = 0
   BEGIN
      SET @nErrNo = 52963
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
      GOTO Quit
   END

   IF NOT EXISTS(
      SELECT 1 FROM dbo.UCC (NOLOCK )
      WHERE Storerkey = @cStorerKey
        AND ID = @cID
   )
   BEGIN
      SET @nErrNo = 239351
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID does not exist in ASN
      GOTO quit
   END

   IF EXISTS(
      SELECT 1 FROM dbo.UCC (NOLOCK )
      WHERE Storerkey = @cStorerKey
        AND ID = @cID
        AND status <> '0'
   )
   BEGIN
      SET @nErrNo = 239352
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID has UCC that are not in New (0) Status
      GOTO quit
   END

   -- Get ID info
   SELECT @nTotalLine = COUNT(1)
   FROM rdt.rdtPalletReceiveLog PRL WITH (NOLOCK)
      JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (PRL.ReceiptKey = RD.ReceiptKey)
      JOIN dbo.UCC U WITH (NOLOCK) ON (U.externkey = RD.externReceiptKey)
   WHERE PRL.Mobile = @nMobile
      AND U.ID = @cID

   -- Check ID in ASN
   IF @nTotalLine = 0
   BEGIN
      SET @nErrNo = 239353
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID in another PO
      GOTO Quit
   END

   -- Check ID received
   IF EXISTS( SELECT 1
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
      INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC)
   WHERE [ID] = @cID
      AND QTY > 0
      AND LOC.Facility = @cFacility)
   BEGIN
      SET @nErrNo = 52966
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID in used
      GOTO Quit
   END

   -- ReceiptKey
   IF @cReceiptKey <> ''
      SET @cActReceiptKey = @cReceiptKey

Quit: 

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_605CheckDetail01 TO NSQL
GO
