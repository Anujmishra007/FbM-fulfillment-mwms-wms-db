SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1721UpdateId02                                  */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Called from: rdtfnc_Pallet_Move                                      */
/*                                                                      */
/* Purpose: Validate ToLoc before update. If SuggestLoc (RDTMOBREC     */
/*          V_String2) is set, scanned ToLoc must have the same         */
/*          LOC.PutawayZone as SuggestLoc AND LocationCategory = STAGE. */
/*          Otherwise, as-is update applies.                            */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2026-07-01  1.0  Dennis   FCR-12996 Created                          */
/* 2026-08-03  1.1  Dennis   FCR-12996 Loop all ChildIDs in DROPIDDETAIL*/
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1721UpdateId02] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cID            NVARCHAR( 40),
   @cToLOC         NVARCHAR( 40),
   @cLocationCategory VARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN

   DECLARE @cSuggestLoc NVARCHAR( 10)

   DECLARE @cDropID_Status NVARCHAR( 10)
   DECLARE @nTranCount     INT
   DECLARE @cFromLOC       NVARCHAR( 40)
   DECLARE @cChildID       NVARCHAR( 20)
   DECLARE @cMoveFromID    NVARCHAR( 20)
   DECLARE @curChild       CURSOR

   -- Get SuggestLoc stored by SuggestLocSP in RDTMOBREC
   SELECT @cSuggestLoc = ISNULL(V_String2, '')
   FROM RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- If SuggestLoc is set and differs from input, validate ToLoc is in the same PutawayZone
   IF ISNULL(@cSuggestLoc, '') <> '' AND @cToLOC <> @cSuggestLoc
   BEGIN
      -- Validate: ToLoc must be in same PutawayZone as SuggestLoc AND LocationCategory = STAGE
      IF NOT EXISTS (
         SELECT 1
         FROM LOC ToLoc WITH (NOLOCK)
         INNER JOIN LOC SuggestLoc WITH (NOLOCK)
            ON  SuggestLoc.Facility    = @cFacility
            AND SuggestLoc.Loc         = @cSuggestLoc
            AND ToLoc.PutawayZone      = SuggestLoc.PutawayZone
         WHERE ToLoc.Facility          = @cFacility
         AND   ToLoc.Loc               = @cToLOC
         AND   ToLoc.LocationCategory  = 'STAGE'
      )
      BEGIN
         SET @nErrNo  = 272551
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid Location
         GOTO Quit
      END
   END

   /***********************************************************************************************
                                          Update
   ***********************************************************************************************/

   SELECT @cDropID_Status = ISNULL(Code, '0')
   FROM dbo.CodeLkUp WITH (NOLOCK)
   WHERE ListName = 'SHIPSTATUS'
   AND   Short    = @cLocationCategory

   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN
   SAVE TRAN UPD_DROPID

   BEGIN TRY
      UPDATE dbo.DropID WITH (ROWLOCK)
      SET
         [Status] = CASE WHEN ISNULL(@cDropID_Status, '') = '' THEN [Status] ELSE @cDropID_Status END,
         DropLoc  = @cToLOC,
         EditWho  = 'rdt.' + sUser_sName(),
         EditDate = GETDATE()
      WHERE DropID = @cID
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272552
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Update DropID Failed
      GOTO RBACK
   END CATCH

   -- Validate at least one ChildID exists
   IF NOT EXISTS (SELECT 1 FROM dbo.DROPIDDETAIL WITH (NOLOCK) WHERE DropID = @cID)
   BEGIN
      SET @nErrNo  = 272553
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- ChildID Not Found
      GOTO RBACK
   END

   -- Loop through all ChildIDs and move each one
   SET @curChild = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT DISTINCT ChildID
      FROM dbo.DROPIDDETAIL WITH (NOLOCK)
      WHERE DropID = @cID
      ORDER BY ChildID

   OPEN @curChild
   FETCH NEXT FROM @curChild INTO @cChildID

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @cFromLOC    = NULL
      SET @cMoveFromID = @cChildID

      SELECT TOP 1 @cFromLOC = Loc
      FROM dbo.LOTxLOCxID WITH (NOLOCK)
      WHERE Id        = @cChildID
      AND   StorerKey = @cStorerKey

      IF ISNULL(@cFromLOC, '') = ''
      BEGIN
         -- Fallback: look up LOC and ID from UCC table
         SELECT TOP 1
            @cFromLOC    = LOC,
            @cMoveFromID = ID
         FROM dbo.UCC WITH (NOLOCK)
         WHERE UCCNo     = @cChildID
         AND   StorerKey = @cStorerKey
      END

      IF ISNULL(@cFromLOC, '') = ''
      BEGIN
         SET @nErrNo  = 272554
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Inventory Not Found
         CLOSE @curChild
         DEALLOCATE @curChild
         GOTO RBACK
      END

      BEGIN TRY
         EXECUTE rdt.rdt_Move
            @nMobile     = @nMobile,
            @cLangCode   = @cLangCode,
            @nErrNo      = @nErrNo  OUTPUT,
            @cErrMsg     = @cErrMsg OUTPUT,
            @cSourceType = 'rdt_1721UpdateId02',
            @cStorerKey  = @cStorerKey,
            @cFacility   = @cFacility,
            @cFromLOC    = @cFromLOC,
            @cToLOC      = @cToLOC,
            @cFromID     = @cMoveFromID,
            @cToID       = NULL,
            @nFunc       = @nFunc
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272555
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- rdt_Move Failed
         CLOSE @curChild
         DEALLOCATE @curChild
         GOTO RBACK
      END CATCH

      IF @nErrNo <> 0
      BEGIN
         CLOSE @curChild
         DEALLOCATE @curChild
         GOTO RBACK
      END

      FETCH NEXT FROM @curChild INTO @cChildID
   END

   CLOSE @curChild
   DEALLOCATE @curChild

   GOTO Quit

RBACK:
   ROLLBACK TRAN UPD_DROPID
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1721UpdateId02 TO NSQL
GO
