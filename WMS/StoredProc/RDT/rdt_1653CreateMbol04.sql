SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1653CreateMbol04                                */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdt_TrackNo_SortToLane_CreateMbol                       */
/*                                                                      */
/* Purpose: Create PalletDetail record                                  */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2024-07-05  1.0  CYU027   FCR 539. Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1653CreateMbol04] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cTrackNo       NVARCHAR( 40), -- From Scanned
   @cOrderKey      NVARCHAR( 20),
   @cPalletKey     NVARCHAR( 20),
   @cMBOLKey       NVARCHAR( 10) OUTPUT,
   @cLane          NVARCHAR( 20), -- Location
   @cLabelNo       NVARCHAR( 20), -- From CartonTrack
   @tCreateMBOLVar VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSKU                    NVARCHAR( 20)
   DECLARE @nQtyPicked              INT
   DECLARE @cFromLoc                NVARCHAR( 20)
   DECLARE @cPDID                   NVARCHAR( 20)
   DECLARE @cPDLabelNo              NVARCHAR( 20)
   DECLARE @cPalletLineNumber          NVARCHAR( 5)
   DECLARE @nPDQty                  INT
   DECLARE @cSuggestLoc             NVARCHAR( 1)
   DECLARE @cOverrideLoc            NVARCHAR( 1)
   DECLARE @curDel                  CURSOR


   SELECT
      @cSuggestLoc            = V_String29,
      @cOverrideLoc           = V_String30,
      @cFacility              = Facility
   FROM rdt.RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile


   -- New Pallet
   IF NOT EXISTS( SELECT 1 FROM PALLET WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND Status = '0')
   BEGIN
      IF EXISTS ( SELECT 1 FROM PALLET WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND Status = '9')
      BEGIN
         SET @curDel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
            SELECT PalletLineNumber
            FROM dbo.PalletDetail WITH (NOLOCK)
            WHERE PalletKey = @cPalletKey
         OPEN @curDel
         FETCH NEXT FROM @curDel INTO @cPalletLineNumber
         WHILE @@FETCH_STATUS = 0
         BEGIN
            UPDATE PALLETDETAIL SET ArchiveCop = '9'
            WHERE PalletKey = @cPalletKey
              AND PalletLineNumber = @cPalletLineNumber

            DELETE FROM PALLETDETAIL
            WHERE PalletKey = @cPalletKey
              AND PalletLineNumber = @cPalletLineNumber

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 219105
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltDtl Err
               GOTO Quit
            END

            FETCH NEXT FROM @curDel INTO @cPalletLineNumber
         END

         UPDATE PALLET SET ArchiveCop = '9' WHERE PalletKey = @cPalletKey

         DELETE FROM PALLET WHERE PalletKey = @cPalletKey

         IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 219106
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltHdr Err
               GOTO Quit
            END
      END

      INSERT INTO dbo.Pallet (PalletKey, StorerKey, Status)
      VALUES (@cPalletKey, @cStorerKey, '0')
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 219103
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PalletFail
         GOTO Quit
      END
   END

   -- PalletDetail
   IF NOT EXISTS( SELECT 1 FROM PalletDetail WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND (CaseID = @cLabelNo or CaseID = @cTrackNo))
   BEGIN
      SELECT TOP 1   @cSKU = SKU,
                     @nPDQty = Qty,
                     @cPDLabelNo = LabelNo
      FROM dbo.PackDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   (LabelNo = @cTrackNo OR LabelNo = @cLabelNo)
      ORDER BY 1

      INSERT INTO dbo.PalletDetail
         (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, QTY, Status, OrderKey, TrackingNo, UserDefine01)
      VALUES
         (@cPalletKey, '0', @cPDLabelNo, @cStorerKey, @cSKU, @cLane, @nPDQty, '0', @cOrderKey, @cTrackNo, @cMBOLKey)

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 219104
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PLDtl Err
         GOTO Quit
      END

      SELECT TOP 1
         @cFromLoc   = PD.Loc,
         @nQtyPicked = PD.Qty,
         @cPDID      = PD.ID
      FROM PICKDETAIL PD WITH (NOLOCK)
              INNER JOIN LOTxLOCxID LLI WITH (NOLOCK)
                         ON (LLI.Loc = PD.Loc AND LLI.LOT = PD.LOT AND LLI.Id=PD.ID)
      WHERE ISNULL(PD.CaseID , '') <> '' AND
         (PD.CaseID = @cTrackNo OR PD.CASEID =@cLabelNo)

      --    Create LOTxLOCxID record
      EXECUTE rdt.rdt_Move
              @nMobile     = @nMobile,
              @cLangCode   = @cLangCode,
              @nErrNo      = @nErrNo  OUTPUT,
              @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
              @cSourceType = 'rdt_1653CreateMbol04',
              @cStorerKey  = @cStorerKey,
              @cFacility   = @cFacility,
              @cFromLOC    = @cFromLoc,
              @cFromID     = @cPDID,
              @cToLOC      = @cLane,
              @cToID       = @cPalletKey,
              @cSKU        = @cSKU,
              @nQTY        = @nPDQty,
              @nQTYPick    = @nPDQty,
              @nFunc       = @nFunc

   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1653CreateMbol04 TO NSQL
GO
