SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_513SuggestLOC23                                       */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 14-12-2023  1.0  yeekung  WMS-24427 Created                                */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_513SuggestLOC23] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR(  5),
   @cFromLOC        NVARCHAR( 10),
   @cFromID         NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cToID           NVARCHAR( 18),
   @cToLOC          NVARCHAR( 10),
   @cType           NVARCHAR( 10),
   @nPABookingKey   INT           OUTPUT,
   @cOutField01     NVARCHAR( 20) OUTPUT,
   @cOutField02     NVARCHAR( 20) OUTPUT,
   @cOutField03     NVARCHAR( 20) OUTPUT,
   @cOutField04     NVARCHAR( 20) OUTPUT,
   @cOutField05     NVARCHAR( 20) OUTPUT,
   @cOutField06     NVARCHAR( 20) OUTPUT,
   @cOutField07     NVARCHAR( 20) OUTPUT,
   @cOutField08     NVARCHAR( 20) OUTPUT,
   @cOutField09     NVARCHAR( 20) OUTPUT,
   @cOutField10     NVARCHAR( 20) OUTPUT,
   @cOutField11     NVARCHAR( 20) OUTPUT,
   @cOutField12     NVARCHAR( 20) OUTPUT,
   @cOutField13     NVARCHAR( 20) OUTPUT,
   @cOutField14     NVARCHAR( 20) OUTPUT,
   @cOutField15     NVARCHAR( 20) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @cType = 'LOCK'
   BEGIN
      DECLARE  @cSuggToLoc  NVARCHAR(20)
      DECLARE  @nQTYTOLOC INT
      DECLARE  @nSKUCnt   INT

      SET @cOutField01  = ''
      SET @cOutField02  = ''
      SET @cOutField03  = ''
      SET @cOutField04  = ''
      SET @cOutField05  = ''
      SET @cOutField06  = ''
      SET @cOutField07  = ''
      SET @cOutField08  = ''
      SET @cOutField09  = ''
      SET @cOutField10  = ''
      SET @cOutField11  = ''
      SET @cOutField12  = ''
      SET @cOutField13  = ''
      SET @cOutField14  = ''
      SET @cOutField15  = ''



     

      IF (  SELECT COUNT(1)
            FROM dbo.LotxLocxID LLI WITH (NOLOCK)
            JOIN  dbo.Loc Loc WITH (NOLOCK) ON Loc.Loc = LLI.Loc
            WHERE LLI.SKU = @cSKU
            AND LOC.LocationType    = 'PICK'
            AND LOC.Facility = @cFacility
            and lli.StorerKey = @cStorerKey
            AND Loc.Loc <> @cFromLoc
            HAVING SUM( LLI.QTY-LLI.QtyAllocated-LLI.QTYPicked) >0
            ) >= 1
      BEGIN
         
         SELECT TOP 1 @cSuggToLoc = Loc.Loc
         FROM dbo.LotxLocxID LLI WITH (NOLOCK)
         JOIN  dbo.Loc Loc WITH (NOLOCK) ON Loc.Loc = LLI.Loc
         JOIN  dbo.LOTattribute LOT WITH (NOLOCK) ON LOT.LOT = LLI.LOT
         WHERE LLI.SKU = @cSKU
         AND LOC.LocationType    = 'PICK'
         AND LOC.Facility = @cFacility
         and lli.StorerKey = @cStorerKey
         AND Loc.Loc <> @cFromLoc
         GROUP BY LOC.LOC,lot.lottable04 
         HAVING SUM( LLI.QTY-LLI.QtyAllocated-LLI.QTYPicked) >0
         ORDER BY LOC.LOC,lot.lottable04 
      END

      IF @cSuggToLoc = ''
      BEGIN
         SET @cOutField01 = 'No Suggest Loc'
         SET @cOutField02 = ''
      END
      ELSE
      BEGIN
         SET @cOutField01 = @cSuggToLoc
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_513SuggestLOC23] TO [NSQL]
GO
