IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[RDT].[rdt_GetTransitLoc06]') AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 )
   DROP PROCEDURE [RDT].[rdt_GetTransitLoc06]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_GetTransitLoc06                                 */
/* Copyright      : Maersk WMS                                          */
/*                                                                      */
/* Purpose: Get transit LOC                                             */
/*                                                                      */
/* Called from:                                                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 17-14-2024  1.0  NLT013    USP-17667 - Allow move CASE to MoveTo Loc */
/*                                                                      */
/************************************************************************/

CREATE PROC [RDT].[rdt_GetTransitLoc06] (
   @cUserName   NVARCHAR( 10),
   @cStorerKey  NVARCHAR( 15),
   @cSKU        NVARCHAR( 20),
   @nQTY        INT,
   @cFromLOC    NVARCHAR(10),
   @cFromID     NVARCHAR(18),
   @cToLOC      NVARCHAR(10),
   @nLockLOC    INT = 0,    -- Lock MoveTo transit LOC. 1=Yes, 0=No
   @cTransitLOC NVARCHAR(10)  OUTPUT,
   @nErrNo      INT           OUTPUT,
   @cErrMsg     NVARCHAR(20)  OUTPUT,
   @nFunc       INT = 0
) AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_success            INT
   DECLARE @cGITLOC              NVARCHAR( 10)
   DECLARE @cFacility            NVARCHAR( 5)

   DECLARE @cFromLOCAisle        NVARCHAR( 10)
   DECLARE @cFromLOCCat          NVARCHAR( 10)
   DECLARE @cFromLOCInCASEPICK        INT
   DECLARE @cFromPAZone          NVARCHAR( 10)
   DECLARE @cFromPAOutLOC        NVARCHAR( 10)
   DECLARE @cFromTransitLOC      NVARCHAR( 10)

   DECLARE @cToLOCAisle          NVARCHAR( 10)
   DECLARE @cToLOCCat            NVARCHAR( 10)
   DECLARE @cToLOCInCASEPICK          INT
   DECLARE @cToPAZone            NVARCHAR( 10)
   DECLARE @cToPAInLOC           NVARCHAR( 10)
   DECLARE @cToTransitLOC        NVARCHAR( 10)
   DECLARE @cSkipPnDLocation   NVARCHAR( 30)
   DECLARE @cLangCode            NVARCHAR( 3)


   -- Init var
   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cFromTransitLOC = ''
   SET @cToTransitLOC = ''
   SET @cTransitLOC = ''
   SET @cFromLOCInCASEPICK = 0

   -- Get session info
   SELECT
      @cLangCode = Lang_Code
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE UserName = SUSER_SNAME()

   IF @cLangCode IS NULL OR TRIM(@cLangCode) = ''
      SET @cLangCode = 'ENG'

   -- Get FromLOC info
   SELECT
      @cFacility = Facility,
      @cFromPAZone = PutawayZone,
      @cFromLOCAisle  = LocAisle,
      @cFromLOCCat = LocationCategory
   FROM LOC WITH (NOLOCK)
   WHERE LOC = @cFromLOC

   IF @cFromLOCAisle IS NULL OR TRIM(@cFromLOCAisle) = ''
   BEGIN
      SET @nErrNo = 214102
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --214102^NoAisle
      GOTO Fail
   END

   IF @cFromLOCCat IS NULL OR TRIM(@cFromLOCCat) = ''
   BEGIN
      SET @nErrNo = 214103
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --214103^NoCategory
      GOTO Fail
   END

   SET @cSkipPnDLocation = rdt.RDTGetConfig( @nFunc, 'SkipPnDLocation', @cStorerKey)

   IF @cSkipPnDLocation IS NULL OR TRIM(@cSkipPnDLocation) = ''
      SET @cSkipPnDLocation = '0'

   IF @cSkipPnDLocation = '0' OR @cSkipPnDLocation = 'PnD' OR NOT EXISTS(SELECT 1 FROM CODELKUP where LISTNAME = 'LOCCATEGRY' AND Code = @cSkipPnDLocation)
       RETURN

   IF @nLockLOC = 1 --Yes
   BEGIN
      SELECT TOP 1
            @cFromTransitLOC = LOC.LOC
      FROM LOC WITH (NOLOCK)
      WHERE Facility = @cFacility
         AND LOCAisle = @cFromLOCAisle
         AND LocationCategory = @cSkipPnDLocation
         AND  NOT EXISTS( SELECT 1
                           FROM LOC L2 WITH (NOLOCK)
                           JOIN LOTxLOCxID LLI WITH (NOLOCK) ON (LLI.LOC = L2.LOC
                                 AND (LLI.LOC = L2.LOC AND (LLI.QTY > 0 OR LLI.PendingMoveIN > 0)))
                           WHERE LOC.LOC = L2.LOC
                           AND   L2.Facility = @cFacility
                           AND   L2.LOCAisle = @cFromLOCAisle
                           AND LocationCategory = @cSkipPnDLocation
                           GROUP BY L2.LOC, L2.MaxPallet
                           HAVING COUNT(DISTINCT LLI.ID) >= L2.MaxPallet )
      ORDER BY LOC.LogicalLocation, LOC.LOC

      IF @cFromTransitLOC = ''
      BEGIN
         SET @nErrNo = 214105
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --214105^NoMoveToLoc
         GOTO Fail
      END
   END
   ELSE  -- Find any MoveTo location. Don't need to be empty
   BEGIN
      -- Get a MoveTo LOC
      SELECT TOP 1
         @cFromTransitLOC = LOC.LOC
      FROM LOC WITH (NOLOCK)
      LEFT OUTER JOIN LOTxLOCxID LLI WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
      WHERE Facility = @cFacility
         AND LOCAisle = @cFromLOCAisle
         AND LocationCategory = @cSkipPnDLocation
      GROUP BY LOC.LogicalLocation, LOC.LOC
      ORDER BY LOC.LogicalLocation, LOC.LOC

      IF @cFromTransitLOC = ''
      BEGIN
         SET @nErrNo = 214106
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --214106^NoMoveToLoc
         GOTO Fail
      END
   END

   SET @cTransitLOC = @cFromTransitLOC

   IF @nLockLOC = 1
   BEGIN
      EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
         ,@cFromLOC
         ,@cFromID
         ,@cTransitLOC
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cSKU        = @cSKU
         ,@nPutawayQTY = @nQTY
         ,@nFunc       = @nFunc

      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 214107
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --214107^LockLocFail
         GOTO Fail
      END
   END
   
Fail:

END
GO
GRANT EXECUTE ON [RDT].[rdt_GetTransitLoc06] TO nSQL
GO