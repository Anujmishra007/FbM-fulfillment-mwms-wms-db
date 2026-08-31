
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
      @cFinalLocCategory         NVARCHAR( 10) = '',
      @cFinalLocCommingleSKU     NVARCHAR( 1) = '',
      @cFinalLocNoMixLottable02  NVARCHAR( 1) = '',
      @cFinalLocSectionKey       NVARCHAR(30)

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

   SELECT @cFinalLOCPutawayZone = PutawayZone,
      @cFinalLocCommingleSKU = CommingleSKU,
      @cFinalLocNoMixLottable02 = NoMixLottable02,
      @cFinalLocCategory = LocationCategory,
      @cFinalLocSectionKey = SectionKey
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

                  IF ISNULL(@cFinalLocSectionKey, '') <> ISNULL(@cBUSR2, '')
                  BEGIN
                     SET @nErrNo = 267352
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Product Division mismatch
                     GOTO Quit
                  END

                  IF @cFinalLocCategory <> 'AEOMX_MEZ'
                  BEGIN
                     SET @nErrNo = 267353
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Location Category should be AEOMX_MEZ
                     GOTO Quit
                  END
               END

               IF @cFinalLocCommingleSKU IN ( '0', 'N' )
               BEGIN
                  IF EXISTS(SELECT 1 FROM dbo.LOTxLOCxID WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND Sku <> @cSKU
                              AND Loc = @cFinalLOC
                              AND (Qty - QtyPicked - QtyPickInProcess > 0 OR PendingMoveIN + QtyExpected > 0)
                           )
                  BEGIN
                     SET @nErrNo = 267354
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  No Mix SKU allowed in the location
                     GOTO Quit
                  END
               END

               IF @cFinalLocNoMixLottable02 IN ( '1', 'Y' )
               BEGIN
                  IF EXISTS(SELECT 1 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                           INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LA.Lot = LLI.Lot AND LA.Sku = LLI.Sku AND LA.StorerKey = LLI.StorerKey
                           WHERE LLI.StorerKey = @cStorerKey
                              AND LLI.Loc = @cFinalLOC
                              AND LA.Lottable02 <> @cLottable02
                              AND (LLI.Qty - LLI.QtyPicked - LLI.QtyPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QtyExpected > 0)
                           )
                  BEGIN
                     SET @nErrNo = 267355
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  No Mix Lottable02 allowed in the location
                     GOTO Quit
                  END
               END

               IF EXISTS(SELECT 1 FROM dbo.LOTxLOCxID WITH(NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND Loc = @cFinalLOC
                           AND (Qty - QtyPicked - QtyPickInProcess > 0 OR PendingMoveIN + QtyExpected > 0)
                        )
               BEGIN
                  DECLARE 
                     @nAvailableCube   FLOAT,
                     @fSKUCube         FLOAT

                  SELECT @nAvailableCube = IIF(ISNULL(LOC.CubicCapacity, 0) = 0, 999999, LOC.CubicCapacity)
                                          - ISNULL(SUM(CASE
                                                         WHEN (LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess > 0 OR LLI.PendingMoveIN + LLI.QTYExpected > 0)
                                                            THEN ISNULL(Pack.CubeUOM3, 0) * ISNULL((LLI.Qty - LLI.QtyPicked - LLI.QTYPickInProcess + LLI.PendingMoveIN + LLI.QTYExpected), 0)
                                                         ELSE 0
                                                      END), 0)
                  FROM dbo.LOC WITH(NOLOCK)
                  LEFT JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK) ON LLI.Loc = LOC.Loc AND LLI.StorerKey = @cStorerKey
                  LEFT JOIN dbo.SKU WITH(NOLOCK) ON SKU.SKU = LLI.SKU AND SKU.StorerKey = LLI.StorerKey
                  LEFT JOIN dbo.Pack WITH(NOLOCK) ON Pack.PackKey = SKU.PackKey
                  WHERE LOC.Facility = @cFacility
                     AND LOC.Loc = @cFinalLOC
                  GROUP BY LOC.CubicCapacity

                  SET @nAvailableCube = IIF(ISNULL(@nAvailableCube, 0) < 0, 0, @nAvailableCube)

                  SELECT @fSKUCube = ISNULL(Pack.CubeUOM3, 0) * @nQTY
                  FROM dbo.SKU WITH(NOLOCK)
                  INNER JOIN dbo.Pack WITH(NOLOCK)
                     ON Pack.PackKey = SKU.PackKey
                  WHERE SKU.StorerKey = @cStorerKey
                     AND SKU.SKU = @cSKU

                  IF @fSKUCube > @nAvailableCube
                  BEGIN
                     SET @nErrNo = 267356
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --   No enough available space in the location
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