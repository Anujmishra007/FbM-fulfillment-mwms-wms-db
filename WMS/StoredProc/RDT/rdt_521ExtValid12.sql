SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtValid12                                   */
/* Copyright      : Maersk                                              */
/* Customer       : AMERICAN EAGLE                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 2026-05-19   1.0  NickT    FCR-12181 Create                          */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_521ExtValid12] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cUCCNo          NVARCHAR( 20),
   @cSuggestedLOC   NVARCHAR( 10),
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cSuggestedLocPutawayZone           NVARCHAR(10),
      @cToLocPutawayZone                  NVARCHAR(10),
      @cFacility                          NVARCHAR(5),
      @cSKUPutawayZone                    NVARCHAR(10),
      @cLottable02                        NVARCHAR( 18),
      @cSKU                               NVARCHAR(20),
      @cFinalLocCommingleSKU              NVARCHAR( 1) = '',
      @cFinalLocNoMixLottable02           NVARCHAR( 1) = '',
      @cLOT                               NVARCHAR(10)

   SET @nErrNo = 0
   SET @cErrMsg = ''

   SELECT @cFacility = Facility 
   FROM rdt.rdtMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nStep = 2 -- ToLOC
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @cSuggestedLOC <> @cToLOC
         BEGIN
            SELECT TOP 1 
               @cSKU = SKU,
               @cLOT = Lot
            FROM dbo.UCC WITH(NOLOCK)
            WHERE UCCNo = @cUCCNo
               AND StorerKey = @cStorerKey

            SELECT TOP 1 
               @cLottable02 = Lottable02
            FROM dbo.LOTATTRIBUTE WITH(NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Sku = @cSKU
               AND Lot = @cLOT

            SELECT @cToLocPutawayZone = PutawayZone,
               @cFinalLocCommingleSKU = CommingleSKU,
               @cFinalLocNoMixLottable02 = NoMixLottable02
            FROM dbo.LOC WITH (NOLOCK) 
            WHERE LOC = @cToLOC 
               AND Facility = @cFacility
               
            IF @cLottable02 = 'DAM'
            BEGIN
               SELECT @cSuggestedLocPutawayZone = PutawayZone
               FROM dbo.LOC WITH (NOLOCK) 
               WHERE LOC = @cSuggestedLOC 
                  AND Facility = @cFacility

               IF ISNULL(@cToLocPutawayZone, '') <> ISNULL(@cSuggestedLocPutawayZone, '')
               BEGIN
                  SET @nErrNo = 267201
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Wrong Putaway Zone
                  GOTO QUIT
               END
            END
            ELSE IF @cLottable02 = 'GOO'
            BEGIN
               SELECT @cSKUPutawayZone = PutawayZone
               FROM dbo.SKU WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU

               IF ISNULL(@cToLocPutawayZone, '') <> ISNULL(@cSKUPutawayZone, '')
               BEGIN
                  SET @nErrNo = 267202
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Wrong Putaway Zone
                  GOTO QUIT
               END
            END

            IF @cFinalLocCommingleSKU IN( '0', 'N' )
            BEGIN
               IF EXISTS(SELECT 1 FROM dbo.LOTxLOCxID WITH(NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND Sku <> @cSKU
                           AND Loc = @cToLOC
                           AND (Qty - QtyPicked - QtyPickInProcess > 0 OR PendingMoveIN + QtyExpected > 0)
                        )
               BEGIN
                  SET @nErrNo = 267203
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  No Mix SKU allowed in the location
                  GOTO Quit
               END
            END

            IF @cFinalLocNoMixLottable02 IN ('1', 'Y')
            BEGIN
               IF EXISTS(SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                        INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LA.Lot = LLI.Lot AND LA.Sku = LLI.Sku AND LA.StorerKey = LLI.StorerKey
                        WHERE LLI.StorerKey = @cStorerKey
                           AND LLI.Loc = @cToLOC
                           AND LA.Lottable02 <> @cLottable02
                           AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0)
                        )
               BEGIN
                  SET @nErrNo = 267204
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  No Mix Lottable02 allowed in the location
                  GOTO Quit
               END
            END

            IF EXISTS(SELECT 1 FROM dbo.LOTxLOCxID WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND Loc = @cToLOC
                        AND (Qty - QtyPicked - QtyPickInProcess > 0 OR PendingMoveIN + QtyExpected > 0)
                     )
            BEGIN
               DECLARE 
                     @nAvailableSpace   INT,
                     @nExistingCartons   INT,
                     @nPendingCartons    INT

               SELECT @nExistingCartons = COUNT(DISTINCT UCC.UCCNo)
               FROM dbo.UCC WITH(NOLOCK)
               INNER JOIN LOTxLOCxID LLI WITH(NOLOCK) ON UCC.Loc = LLI.Loc AND UCC.StorerKey = LLI.StorerKey AND UCC.SKU = LLI.Sku AND UCC.Lot = LLI.Lot
               WHERE UCC.StorerKey = @cStorerKey
                  AND UCC.Loc = @cToLOC
                  AND Status IN ('1', '3', '4')

               SELECT @nPendingCartons = COUNT(DISTINCT UCC2.UCCNo)
               FROM dbo.RFPutaway RFP WITH(NOLOCK)
               INNER JOIN dbo.UCC UCC2 WITH(NOLOCK) ON RFP.FromLOC = UCC2.Loc AND RFP.StorerKey = UCC2.StorerKey AND RFP.CaseID = UCC2.ID
               WHERE RFP.StorerKey = @cStorerKey
                  AND RFP.SuggestedLOC = @cToLOC

               SELECT @nAvailableSpace = IIF(ISNULL(LOC.MaxCarton, 0) = 0, 999999, LOC.MaxCarton) - ISNULL(@nExistingCartons, 0) - ISNULL(@nPendingCartons, 0)
               FROM dbo.LOC WITH(NOLOCK)
               WHERE Facility = @cFacility
                  AND Loc = @cToLOC

               IF @nAvailableSpace < 1
               BEGIN
                  SET @nErrNo = 267205
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  No enough available space in the location
                  GOTO Quit
               END
            END
         END
      END
   END

QUIT:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_521ExtValid12] TO [NSQL]
GO
