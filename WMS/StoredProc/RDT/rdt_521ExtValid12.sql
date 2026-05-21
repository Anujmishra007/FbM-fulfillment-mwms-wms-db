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

            SELECT @cToLocPutawayZone = PutawayZone
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
