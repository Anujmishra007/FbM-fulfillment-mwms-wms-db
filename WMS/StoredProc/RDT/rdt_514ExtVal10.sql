
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_514ExtVal10                                           */
/* Copyright      : Maersk                                                    */
/* Customer       : Levis UAE                                                 */
/*                                                                            */
/* Purpose: Check same SKU UCC                                                */
/*                                                                            */
/* Date        Rev    Author   Purposes                                       */
/* 2025-07-29  1.0.0  NickT    FCR-6187 Created                               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_514ExtVal10 (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR( 15),
   @cToID          NVARCHAR( 18),
   @cToLoc         NVARCHAR( 10),
   @cFromLoc       NVARCHAR( 10),
   @cFromID        NVARCHAR( 18),
   @cUCC           NVARCHAR( 20),
   @cUCC1          NVARCHAR( 20),
   @cUCC2          NVARCHAR( 20),
   @cUCC3          NVARCHAR( 20),
   @cUCC4          NVARCHAR( 20),
   @cUCC5          NVARCHAR( 20),
   @cUCC6          NVARCHAR( 20),
   @cUCC7          NVARCHAR( 20),
   @cUCC8          NVARCHAR( 20),
   @cUCC9          NVARCHAR( 20),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nRowCount                 INT,
      @cUCCLottable03            NVARCHAR( 18),
      @cToIDLottable03           NVARCHAR( 18),
      @cToLocationType           NVARCHAR( 10),
      @cToLocationPutawayZone    NVARCHAR( 10),
      @cFacility                 NVARCHAR(  5)

   SELECT @cFacility = Facility
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   DECLARE @tUCC TABLE 
   (
      UCCNo       NVARCHAR( 20) NOT NULL,
      Lottable03  NVARCHAR( 18) NOT NULL
   )

   IF @nFunc = 514 -- Move by UCC
   BEGIN
      IF @nStep = 1 -- UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @nRowCount = COUNT(DISTINCT LA.Lottable03)
            FROM rdt.rdtMoveUCCLog RMU WITH (NOLOCK)
            INNER JOIN dbo.UCC WITH(NOLOCK) ON RMU.UCCNo = UCC.UCCNo
            INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON UCC.Lot = LA.Lot
            WHERE UCC.StorerKey = @cStorerKey
               AND RMU.AddWho = SUSER_SNAME()

            IF @nRowCount > 1
            BEGIN
               SET @nErrNo = 242851
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lottable03 need to be the same
               GOTO Quit
            END
         END
      END
   
      IF @nStep = 2 -- To ID, TO LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cToID <> ''
            BEGIN
               SELECT @cToIDLottable03 = LA.Lottable03
               FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
               INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LLI.Lot = LA.Lot
               WHERE LLI.ID = @cToID
                  AND LLI.StorerKey = @cStorerKey
                  AND LLI.Qty > 0

               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount > 0
               BEGIN
                  SELECT TOP 1 @cUCCLottable03 = LA.Lottable03
                  FROM rdt.rdtMoveUCCLog RMU WITH (NOLOCK)
                  INNER JOIN dbo.UCC WITH(NOLOCK) ON RMU.UCCNo = UCC.UCCNo
                  INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON UCC.Lot = LA.Lot
                  WHERE UCC.StorerKey = @cStorerKey
                     AND RMU.AddWho = SUSER_SNAME()

                  IF ISNULL(@cUCCLottable03, '') <> ISNULL(@cToIDLottable03, '')
                  BEGIN
                     SET @nErrNo = 242902
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lottable03 need to be the same
                     GOTO Quit
                  END
               END
            END

            IF @cToLoc <> ''
            BEGIN
               SELECT TOP 1 @cUCCLottable03 = LA.Lottable03
               FROM rdt.rdtMoveUCCLog RMU WITH (NOLOCK)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON RMU.UCCNo = UCC.UCCNo
               INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON UCC.Lot = LA.Lot
               WHERE UCC.StorerKey = @cStorerKey
                  AND RMU.AddWho = SUSER_SNAME()

               IF ISNULL(@cUCCLottable03, '') = ''
               BEGIN
                  SELECT @cToLocationType = LocationType
                  FROM dbo.LOC WITH (NOLOCK)
                  WHERE LOC = @cToLOC
                     AND Facility = @cFacility

                  IF @cToLocationType <> 'CASE'
                  BEGIN
                     SET @nErrNo = 242903
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location Type must be CASE
                     GOTO Quit
                  END
               END
               ELSE 
               BEGIN
                  SELECT @cToLocationPutawayZone = PutawayZone
                  FROM dbo.LOC WITH (NOLOCK)
                  WHERE LOC = @cToLOC
                     AND Facility = @cFacility

                  SELECT @nRowCount = COUNT(1)
                  FROM dbo.CODELKUP WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND LISTNAME = 'LVSCTZONE'
                     AND ISNULL(Long, '') = @cUCCLottable03
                     AND Code = @cToLocationPutawayZone

                  IF @nRowCount = 0
                  BEGIN
                     SET @nErrNo = 242904
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location Putaway Zone is not in LVSCTZONE
                     GOTO Quit
                  END
               END
            END
         END
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_514ExtVal10 TO NSQL
GO

