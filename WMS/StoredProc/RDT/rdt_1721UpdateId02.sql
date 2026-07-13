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

   DECLARE @tPickDetail TABLE
   (
      PickDetailKey NVARCHAR(18) PRIMARY KEY
   )

   -- Get SuggestLoc stored by SuggestLocSP in RDTMOBREC
   SELECT @cSuggestLoc = ISNULL(V_String2, '')
   FROM RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- If SuggestLoc is set, validate ToLoc is in the same PutawayZone
   IF ISNULL(@cSuggestLoc, '') <> ''
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

   -- Get FromLoc via DROPIDDETAIL.ChildID -> LOTxLOCxID
   SELECT TOP 1 @cChildID = ChildID
   FROM dbo.DROPIDDETAIL WITH (NOLOCK)
   WHERE DropID = @cID
   ORDER BY ChildID

   IF ISNULL(@cChildID, '') = ''
   BEGIN
      SET @nErrNo  = 272553
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- ChildID Not Found
      GOTO RBACK
   END

   SELECT TOP 1 @cFromLOC = Loc
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
   WHERE Id        = @cChildID
   AND   StorerKey = @cStorerKey

   IF ISNULL(@cFromLOC, '') = ''
   BEGIN
      SET @nErrNo  = 272554
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- FromLoc Not Found
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
         @cFromID     = @cID,
         @cToID       = NULL,
         @nFunc       = @nFunc
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272555
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- rdt_Move Failed
      GOTO RBACK
   END CATCH

   IF @nErrNo <> 0
      GOTO RBACK

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
