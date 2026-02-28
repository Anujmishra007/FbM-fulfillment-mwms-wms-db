
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_523ExtValidSP20                                 */
/*                                                                      */
/* Customer: DAIMLER TRUCK AG                                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author    Purposes                                   */
/* 2026-01-29 1.0  Jackc     FCR-9756. Created                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523ExtValidSP20] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR( 5),
   @cFromLOC        NVARCHAR( 10),
   @cFromID         NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQty            INT,
   @cSuggestedLOC   NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @cOption         NVARCHAR( 1),
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cLocType          NVARCHAR(10)
   DECLARE @cLot              NVARCHAR(10)
   DECLARE @cChkToLocLoseID   NVARCHAR( 1)
   DECLARE @nTotalPreAlloQty  INT = 0
   DECLARE @nMovedQty         INT = 0
   DECLARE @nPreAlloQty       INT = 0

   IF @nFunc = 523
   BEGIN
      IF @nInputKey = 1 
      BEGIN
         IF @nStep = 1
         BEGIN
            IF @cFromID = ''
            BEGIN
               SET @nErrNo = 257151
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID required
               GOTO Quit
            END

            SELECT @cLocType = LocationType
            FROM dbo.LotXLocxID LLI WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK)
               ON LLI.Loc = LOC.Loc
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cFromID
               AND Qty > 0

            IF NOT EXISTS (SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)
                           WHERE LISTNAME = 'PAALLZON'
                              AND StorerKey = @cStorerKey
                              AND Code = @cLocType)
            BEGIN
               SET @nErrNo = 257152
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Not allow to putaway
               GOTO Quit
            END
         END --st1

         IF @nStep = 4
         BEGIN
            SET @cChkToLocLoseID = rdt.rdtGetConfig( @nFunc, 'ChkToLocLoseID', @cStorerkey)
            
            IF @cChkToLocLoseID = '1' AND @cFinalLOC <> ''
            BEGIN
               IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE Loc = @cFinalLOC AND LoseID = 1 )
               BEGIN
                  SET @nErrNo = 257153
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
            END
         END
      END -- Enter
   END --523

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_523ExtValidSP20 TO NSQL
GO