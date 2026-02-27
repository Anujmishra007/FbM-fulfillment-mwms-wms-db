SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_PalletReceive_CheckDetail                             */
/* Copyright      : Maersk WMS                                                */
/*                                                                            */
/* Purpose: For rdt_PalletReceive check receiptdetail                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2025-06-18 1.0  Cuize      FCR-4200 Created                               */
/******************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_PalletReceive_CheckDetail (
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

   DECLARE @cCheckDetailSP  NVARCHAR( 20)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)


   -- Get storer config
   SET @cCheckDetailSP = rdt.RDTGetConfig( @nFunc, 'CheckDetailSP', @cStorerKey)
   IF @cCheckDetailSP = '0'
      SET @cCheckDetailSP = ''

   /***********************************************************************************************
                                              Custom Check DetailSP
   ***********************************************************************************************/
   -- Check confirm SP blank
   IF @cCheckDetailSP <> ''
   BEGIN
      -- Confirm SP
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cCheckDetailSP)
         + ' @nFunc, @nMobile, @cLangCode, @nScn, @nInputKey, @cFacility,'
         + ' @cReceiptKey,'
         + ' @cID,'
         + ' @cRefNo,'
         + ' @cStorerKey       OUTPUT,'
         + ' @cActReceiptKey   OUTPUT,'
         + ' @nErrNo           OUTPUT,'
         + ' @cErrMsg          OUTPUT'
      SET @cSQLParam =
           ' @nFunc            INT,'
         + ' @nMobile          INT,'
         + ' @cLangCode        NVARCHAR(  3),'
         + ' @nScn             INT,'
         + ' @nInputKey        INT,'
         + ' @cFacility        NVARCHAR(  5),'
         + ' @cReceiptKey      NVARCHAR( 10),'
         + ' @cID              NVARCHAR( 18),'
         + ' @cRefNo           NVARCHAR( 20),'
         + ' @cStorerKey       NVARCHAR( 15) OUTPUT,'
         + ' @cActReceiptKey   NVARCHAR( 10) OUTPUT,'
         + ' @nErrNo           INT           OUTPUT,'
         + ' @cErrMsg          NVARCHAR( 1024) OUTPUT'

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
           @nFunc, @nMobile, @cLangCode, @nScn, @nInputKey, @cFacility,
           @cReceiptKey,
           @cID,
           @cRefNo,
           @cStorerKey       OUTPUT,
           @cActReceiptKey   OUTPUT,
           @nErrNo           OUTPUT,
           @cErrMsg          OUTPUT

      GOTO Quit
   END

   DECLARE  @nTotalLine   INT

   -- Check barcode format
   IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'ID', @cID) = 0
   BEGIN
      SET @nErrNo = 52963
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
      GOTO Quit
   END

      -- Get ID info
   SELECT @nTotalLine = COUNT(1)
   FROM rdt.rdtPalletReceiveLog PRL WITH (NOLOCK)
      JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (PRL.ReceiptKey = RD.ReceiptKey)
   WHERE PRL.Mobile = @nMobile
      AND RD.ToID = @cID

   -- Check ID in ASN
   IF @nTotalLine = 0
   BEGIN
      SET @nErrNo = 52964
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID not in ASN
      GOTO Quit
   END

   -- Check ID received in ASN
   IF EXISTS (SELECT 1
      FROM rdt.rdtPalletReceiveLog PRL WITH (NOLOCK)
         JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (PRL.ReceiptKey = RD.ReceiptKey)
      WHERE PRL.Mobile = @nMobile
         AND RD.ToID = @cID
         AND RD.BeforeReceivedQty > 0)
   BEGIN
      SET @nErrNo = 52965
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID received
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

   -- RefNo
   IF @cRefNo <> ''
   BEGIN
      -- Check ID in multi ASN
      IF EXISTS( SELECT 1
         FROM rdt.rdtPalletReceiveLog PRL WITH (NOLOCK)
                JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (PRL.ReceiptKey = RD.ReceiptKey)
         WHERE PRL.Mobile = @nMobile
          AND RD.ToID = @cID
         HAVING COUNT( DISTINCT PRL.ReceiptKey) > 1)
      BEGIN
         SET @nErrNo = 52967
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID in MultiASN
         GOTO Quit
      END

      -- Set session storer, receipt
      SELECT TOP 1
         @cStorerKey = RD.StorerKey,
         @cActReceiptKey = RD.ReceiptKey
      FROM rdt.rdtPalletReceiveLog PRL WITH (NOLOCK)
              JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON (PRL.ReceiptKey = RD.ReceiptKey)
      WHERE PRL.Mobile = @nMobile
        AND RD.ToID = @cID
   END

Quit: 

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_PalletReceive_CheckDetail TO NSQL
GO
