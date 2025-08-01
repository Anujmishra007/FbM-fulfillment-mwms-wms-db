SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_511ExtValid10                                   */
/* Purpose: Move By ID Extended Validate                                */
/*                                                                      */
/* Called from: rdtfnc_Move_ID                                          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-01-20  1.0  VPA235     FCR-2804 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtValid10] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 18),    
   @cFromLOC         NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @cToID            NVARCHAR( 18),
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cFacility   NVARCHAR( 5)
   DECLARE @nMaxPallet  INT
   DECLARE @nCount      INT

   SET @nErrNo = 0

   SELECT @cFacility = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 511
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS ( SELECT 1 
                        FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                        INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                        WHERE LLI.StorerKey = @cStorerKey
                           AND LLI.ID = @cFromID
                           AND LOC.Facility = @cFacility
                        GROUP BY LLI.ID
                        HAVING ISNULL( SUM( LLI.PendingMoveIn), 0) > 0)
            BEGIN
               SET @nErrNo = 235951  -- PendingPutaway
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END
            ELSE IF EXISTS ( SELECT 1 
                        FROM dbo.RFPUTAWAY RP WITH (NOLOCK)
                        INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON ( RP.SuggestedLoc = LOC.LOC)
                        WHERE RP.StorerKey = @cStorerKey
                           AND RP.FROMID = @cFromID
                           AND LOC.Facility = @cFacility
                  GROUP BY RP.FROMID)
                        
            BEGIN
               SET @nErrNo = 235952  -- LPNLOCKEDINRFPUTAWAY
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END
         END
      END
      ELSE IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- To loc have inventory only check max pallet
            IF EXISTS ( SELECT 1 
                        FROM dbo.LOTxLOCxID LLI WITH (NOLOCK) 
                        JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                        WHERE LOC.Facility = @cFacility
                        AND   LOC.Loc = @cToLOC
                        GROUP BY LOC.LOC 
                        -- Not Empty LOC
                        HAVING ISNULL(SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.PendingMoveIn), 0) <> 0)
            BEGIN
               SELECT @nMaxPallet = MaxPallet  
               FROM dbo.LOC WITH (NOLOCK)  
               WHERE Loc = @cToLOC  
               AND   Facility = @cFacility

               SELECT @nCount = COUNT(DISTINCT ID)  
               FROM dbo.RFPutaway WITH (NOLOCK)  
               WHERE SuggestedLoc = @cToLOC  

               SELECT @nCount = @nCount + COUNT(DISTINCT LLI.Id)  
               FROM dbo.LotxLocxID LLI WITH (NOLOCK)  
               INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
               WHERE LOC.Facility = @cFacility
                  AND LOC.Loc = @cToLOC  
                  AND (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.PendingMoveIn) <> 0  
                  AND LLI.Id NOT IN (  
                        SELECT DISTINCT ID  
                        FROM dbo.RFPutaway WITH (NOLOCK)  
                        WHERE SuggestedLoc = @cToLOC)

               IF @nCount >= @nMaxPallet
               BEGIN
                  SET @nErrNo = 235953  -- OVER MAX PALLET
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
            END
         END
      END
   END

QUIT:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_511ExtValid10] TO [NSQL]
GO