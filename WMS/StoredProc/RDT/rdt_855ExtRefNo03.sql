SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_855ExtRefNo03                                   */
/* Copyright      : Maersk                                              */
/* Purpose        : FCR-10831 Return correct PQty and CQty for PPA      */
/*                  Sums Lottable01-specific records for accurate totals*/
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-03-29 1.0.0  NYE018   FCR-10831 Created                         */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_855ExtRefNo03] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @cStorer        NVARCHAR( 15),
   @cFacility      NVARCHAR( 5),
   @cRefNo         NVARCHAR( 20),
   @cOrderKey      NVARCHAR( 10),
   @cDropID        NVARCHAR( 20),
   @cLoadKey       NVARCHAR( 10),
   @cPickSlipNo    NVARCHAR( 10),
   @cID            NVARCHAR( 18),
   @cTaskDetailKey NVARCHAR( 10),
   @cSKU           NVARCHAR( 20),
   @cType          NVARCHAR( 20),
   @nCSKU          INT = 0 OUTPUT,
   @nCQTY          INT = 0 OUTPUT,
   @nPSKU          INT = 0 OUTPUT,
   @nPQTY          INT = 0 OUTPUT,
   @nVariance      INT = 0 OUTPUT,
   @nQTY_PPA       INT = 0 OUTPUT,
   @nQTY_CHK       INT = 0 OUTPUT,
   @nRowRef        INT = 0 OUTPUT,
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
      @nInputKey       INT,
      @nLottablePQty   INT,
      @nLottableCQty   INT

   -- Initialize
   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @nPQTY = 0
   SET @nCQTY = 0

   -- Get current step and inputkey from rdtMobRec
   SELECT @cLangCode = lang_code,
          @nStep = step,
          @nInputKey = InputKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE mobile = @nMobile

   IF @nFunc = 855 -- PPA by DropID
   BEGIN
      -- Step 1 - Screen 1: DropID scanned, get SKU count and total QTY
      IF @nStep = 1 AND @nInputKey = 1 -- ENTER
      BEGIN
         -- Get total PSKU count for this DropID (from PickDetail)
         SELECT @nPSKU = COUNT(DISTINCT SKU)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ShipFlag <> 'Y'

         -- Get total PQty for this DropID (from PickDetail)
         SELECT @nPQTY = SUM(Qty)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ShipFlag <> 'Y'

         -- Get checked SKU count from RDTPPA (overall records only)
         SELECT @nCSKU = COUNT(DISTINCT SKU)
         FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ISNULL(Lottable01, '') = ''

         -- Get checked CQty from RDTPPA (overall records only)
         SELECT @nCQTY = SUM(ISNULL(CQty, 0))
         FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ISNULL(Lottable01, '') = ''

         -- Handle NULL values
         SET @nPSKU = ISNULL(@nPSKU, 0)
         SET @nPQTY = ISNULL(@nPQTY, 0)
         SET @nCSKU = ISNULL(@nCSKU, 0)
         SET @nCQTY = ISNULL(@nCQTY, 0)

         -- Calculate variance
         IF @nVariance IS NOT NULL
         BEGIN
            IF @nPQTY <> @nCQTY
               SET @nVariance = 1
            ELSE
               SET @nVariance = 0
         END

      END  -- Step 1

      -- Step 3 - SKU counting screen (Enter or ESC)
      IF @nStep = 3
      BEGIN
         -- Get PQty and CQty from overall record (DropID + SKU, no Lottable01)
         SELECT TOP 1
            @nQTY_PPA = PQty,
            @nQTY_CHK = CQty,
            @nRowRef = RowRef
         FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND SKU = @cSKU
            AND ISNULL(Lottable01, '') = ''

         -- FALLBACK: If no RDTPPA record exists yet, get PQty from PickDetail
         IF @nRowRef IS NULL OR @nQTY_PPA IS NULL OR @nQTY_PPA = 0
         BEGIN
            SELECT @nQTY_PPA = SUM(Qty)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorer
               AND DropID = @cDropID
               AND SKU = @cSKU

            SET @nQTY_CHK = 0  -- No record yet, so CQty = 0
         END

         -- Get total PSKU count for this DropID
         SELECT @nPSKU = COUNT(DISTINCT SKU)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ShipFlag <> 'Y'

         -- Get total PQty for this DropID (from PickDetail)
         SELECT @nPQTY = SUM(Qty)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ShipFlag <> 'Y'

         -- Get total CSKU count from RDTPPA (overall records only)
         SELECT @nCSKU = COUNT(DISTINCT SKU)
         FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ISNULL(Lottable01, '') = ''

         -- Get total CQty from overall record
         SELECT @nCQTY = SUM(ISNULL(CQty, 0))
         FROM RDT.RDTPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
            AND ISNULL(Lottable01, '') = ''

         -- Handle NULL values
         SET @nCQTY = ISNULL(@nCQTY, 0)
         SET @nPQTY = ISNULL(@nPQTY, 0)
         SET @nQTY_CHK = ISNULL(@nQTY_CHK, 0)

         -- Calculate variance
         IF @nVariance IS NOT NULL
         BEGIN
            IF @nPQTY <> @nCQTY
               SET @nVariance = 1
            ELSE
               SET @nVariance = 0
         END

      END  -- Step 3
   END

Quit:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_855ExtRefNo03] TO nSQL
GO
