
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_523ExtValidSP23                                 */
/*                                                                      */
/* Customer: DAIMLER TRUCK AG                                           */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author    Purposes                                   */
/* 2026-05-22 1.0  NickT     FCR-12892. Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_523ExtValidSP23] (
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
   
   DECLARE
      @cLOT                      NVARCHAR( 10),
      @cLottable02               NVARCHAR( 18),
      @cSuggestedLOCPutawayZone  NVARCHAR( 10) = 'AEOMX_DAM',
      @cFinalLOCPutawayZone      NVARCHAR( 10) = '',
      @cFinalLocCategory         NVARCHAR( 10) = ''

   SELECT @cLOT          = V_LOT
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SELECT TOP 1 @cLottable02 = Lottable02
   FROM dbo.LOTATTRIBUTE WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Sku = @cSKU
      AND Lot = @cLOT

   SELECT @cSuggestedLOCPutawayZone = PutawayZone
   FROM dbo.LOC WITH(NOLOCK)
   WHERE LOC = @cSuggestedLOC
      AND Facility = @cFacility

   SELECT @cFinalLOCPutawayZone = PutawayZone
   FROM dbo.LOC WITH(NOLOCK)
   WHERE LOC = @cFinalLOC
      AND Facility = @cFacility

   SET @cLottable02 = UPPER(ISNULL(@cLottable02, ''))

   IF @nFunc = 523
   BEGIN
      IF @nInputKey = 1 
      BEGIN
         IF @nStep = 4 -- ToLoc
         BEGIN
            IF @cSuggestedLOC <> @cFinalLOC
            BEGIN
               IF @cLottable02 = 'DAM'
               BEGIN
                  IF @cFinalLOCPutawayZone <> @cSuggestedLOCPutawayZone
                  BEGIN
                     SET @nErrNo = 267351
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Wrong Putaway Zone
                     GOTO Quit
                  END
               END
               ELSE IF @cLottable02 = 'GOO'
               BEGIN
                  DECLARE @cBUSR2 NVARCHAR(30)
                  SELECT @cBUSR2 = BUSR2
                  FROM dbo.SKU WITH(NOLOCK)
                  WHERE SKU.StorerKey = @cStorerKey
                     AND SKU.SKU = @cSKU

                  DECLARE @cSectionKey NVARCHAR(30)

                  SELECT 
                     @cSectionKey = SectionKey,
                     @cFinalLocCategory = LocationCategory
                  FROM dbo.LOC WITH(NOLOCK)
                  WHERE LOC.Facility = @cFacility
                     AND LOC.Loc = @cFinalLOC

                  IF ISNULL(@cSectionKey, '') <> ISNULL(@cBUSR2, '')
                  BEGIN
                     SET @nErrNo = 267352
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Product Division mismatch
                     GOTO Quit
                  END

                  IF @cFinalLocCategory <> 'AEOMX_MEZ'
                  BEGIN
                     SET @nErrNo = 267353
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Putaway Zone shoud be AEOMX_MEZ
                     GOTO Quit
                  END
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

GRANT EXECUTE ON rdt.rdt_523ExtValidSP23 TO NSQL
GO