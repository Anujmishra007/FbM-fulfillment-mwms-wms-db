SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_511ExtValid09                                            */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: For Grape Galina                                                     */
/*                                                                               */
/* Date        Rev      Author     Purposes                                      */
/* 2025-02-14  1.0.0    JCH507     FCR-2597. Created                             */
/* 2025-03-07  1.0.1    CYU027     FCR-2597                                      */
/* 2025-03-26  1.0.2    JCH507     FCR-2597  FBR V2.5 update                     */
/*********************************************************************************/

CREATE OR ALTER PROC rdt.rdt_511ExtValid09 (
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

   DECLARE @bDebugFlag     BINARY = 0
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @cFacility      NVARCHAR( 5)
   DECLARE @cKITUsrDef4    NVARCHAR( 30)
   DECLARE @nMaxPallet     INT
   DECLARE @nCount         INT
   
   SELECT
      @cFacility = Facility, 
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 511 -- Move by ID
   BEGIN
--       IF @nStep = 1 -- From Id
--       BEGIN
--          IF @nInputKey = 1 -- ENTER
--          BEGIN
--             SELECT TOP 1
--                @cKITUsrDef4 = ISNULL(KIT.USRDEF4, '')
--             FROM KIT WITH (NOLOCK)
--             JOIN KITDETAIL WITH (NOLOCK)
--                ON KIT.KITKey = KITDETAIL.KITKey
--             WHERE KIT.Facility = @cFacility
--                AND   KIT.StorerKey = @cStorerKey
--                AND   KIT.[Status] <> '9'
--                AND   KITDETAIL.Id = @cFromID
--                AND   KITDETAIL.[Type] = 'F'
--
--             IF @@ROWCOUNT = 0
--             BEGIN
--                SET @nErrNo = 233301
--                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID not associated
--                GOTO Quit
--             END
--
--             IF @cKITUsrDef4 = ''
--             BEGIN
--                SET @nErrNo = 233302
--                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No production line
--                GOTO Quit
--             END
--
--             --Check FinalLoc is valid
--             IF NOT EXISTS (SELECT 1 FROM LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cKITUsrDef4)
--             BEGIN
--                SET @nErrNo = 233303
--                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- production line not exists
--                GOTO Quit
--             END
--
--          END --inputkey=1
--       END --step=1
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF EXISTS(
               SELECT 1 FROM codelkup (NOLOCK)
               WHERE Listname ='CCHAINPD'
               AND Storerkey = @cStorerkey
               AND code = @cToLOC
            )
            BEGIN -- KIT
               --V1.0.2 start
               IF EXISTS (SELECT 1 FROM dbo.TaskDetail (NOLOCK) 
                           WHERE FromID = @cFromID
                              AND Status IN ('0','3')
                              AND Storerkey = @cStorerKey
                        )
               BEGIN
                  SET @nErrNo = 233305
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Open Task exists
                  GOTO Quit
               END

               IF (  SELECT DISTINCT COUNT(KIT.kitkey) 
                     FROM KIT WITH (NOLOCK)
                     INNER JOIN KITDETAIL KD (nolock)
                        ON KIT.kitkey = KD.KITKey
                     WHERE KIT.Facility = @cFacility
                        AND KIT.StorerKey = @cStorerKey
                        AND KIT.Status <> '9'
                        AND ID = @cFromID
                        AND KD.[Type] = 'F' ) > 1
               BEGIN
                  SET @nErrNo = 233306
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Multiple KitKey
                  GOTO Quit
               END
               --v1.0.2 end
               
               GOTO Quit
            END -- Kit
            ELSE
            BEGIN -- Normal
               -- To loc have inventory only check max pallet
               IF EXISTS ( SELECT 1
                           FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                                 JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                           WHERE LOC.Facility = @cFacility
                           AND   LOC.Loc = @cToLOC
                           GROUP BY LOC.LOC
                           -- Not Empty LOC
                           HAVING ISNULL(SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.PendingMoveIn), 0) > 0)
               BEGIN
                  SELECT @nMaxPallet = MaxPallet
                  FROM dbo.LOC WITH (NOLOCK)
                  WHERE Loc = @cToLOC
                     AND Facility = @cFacility

                  SELECT @nCount = COUNT(DISTINCT ID)
                  FROM dbo.RFPutaway WITH (NOLOCK)
                  WHERE SuggestedLoc = @cToLOC

                  SELECT @nCount = @nCount + COUNT(DISTINCT LLI.Id)
                  FROM dbo.LotxLocxID LLI WITH (NOLOCK)
                        JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
                  WHERE LOC.Facility = @cFacility
                  AND   LOC.Loc = @cToLOC
                  AND  (LLI.Qty - LLI.QtyPicked) > 0
                  AND   LLI.Id NOT IN (
                     SELECT DISTINCT ID
                     FROM dbo.RFPutaway WITH (NOLOCK)
                     WHERE SuggestedLoc = @cToLOC)

                  IF @nCount >= @nMaxPallet
                  BEGIN
                     SET @nErrNo = 233304  -- OVER MAX PALLET
                     GOTO Quit
                  END
               END
            END -- normal movement
         END --Inputkey = 1
      END --step3
      Quit:
   END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_511ExtValid09 TO NSQL
GO
