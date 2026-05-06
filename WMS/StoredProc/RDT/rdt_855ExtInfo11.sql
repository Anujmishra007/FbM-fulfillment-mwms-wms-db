SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt.rdt_855ExtInfo11                                */
/* Copyright      : Maersk                                              */
/* Purpose        : FCR-10831 Display Lottable01 on PPA SKU screen      */
/*                  for Lottable01 (lot/batch) level counting           */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2026-03-16 1.0.0  NYE018   FCR-10831 Created                         */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_855ExtInfo11
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nAfterStep     INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @tExtInfo       VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cDropID             NVARCHAR(20),
      @cSKU                NVARCHAR(20),
      @cLottable01         NVARCHAR(18),
      @cCurrentLot         NVARCHAR(18),
      @nScn                INT

   -- Initialize output parameters
   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cExtendedInfo = ''

   -- Variable mapping from @tExtInfo
   SELECT @cDropID = Value FROM @tExtInfo WHERE Variable = '@cDropID'
   SELECT @cSKU = Value FROM @tExtInfo WHERE Variable = '@cSKU'

   -- Get current screen
   SELECT @nScn = Scn FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nFunc = 855 -- PPA by DropID
   BEGIN
      -- Step 3 after scanning SKU - display Lottable01 in extended info
      IF @nStep = 3 
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Validate inputs
            IF ISNULL(@cDropID, '') = '' OR ISNULL(@cSKU, '') = ''
               GOTO Quit

            -- PRIORITY 1: Get first Lottable01 NOT yet in RDTPPA (never counted)
            SELECT TOP 1 @cLottable01 = LA.Lottable01
            FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
               ON LLI.StorerKey = LA.StorerKey
               AND LLI.SKU = LA.SKU
               AND LLI.Lot = LA.Lot
            WHERE LLI.StorerKey = @cStorerKey
               AND LLI.ID = @cDropID
               AND LLI.SKU = @cSKU
               AND ISNULL(LA.Lottable01, '') <> ''
               AND NOT EXISTS (
                  SELECT 1 FROM RDT.RDTPPA PPA WITH (NOLOCK)
                  WHERE PPA.StorerKey = @cStorerKey
                     AND PPA.DropID = @cDropID
                     AND PPA.SKU = @cSKU
                     AND PPA.Lottable01 = LA.Lottable01
               )
            ORDER BY LA.Lottable01

            -- PRIORITY 2: If all lots have records, get lots where CQty < PQty (partially audited)
            IF ISNULL(@cLottable01, '') = ''
            BEGIN
               SELECT TOP 1 @cLottable01 = PPA.Lottable01
               FROM RDT.RDTPPA PPA WITH (NOLOCK)
               WHERE PPA.StorerKey = @cStorerKey
                  AND PPA.DropID = @cDropID
                  AND PPA.SKU = @cSKU
                  AND ISNULL(PPA.Lottable01, '') <> ''
                  AND ISNULL(PPA.CQty, 0) < ISNULL(PPA.PQty, 0)
               ORDER BY PPA.Lottable01
            END

            -- Set extended info to display Lottable01
            IF ISNULL(@cLottable01, '') <> ''
            BEGIN
               SET @cExtendedInfo = 'LOT01:' + LTRIM(RTRIM(SUBSTRING(@cLottable01, 1, 15)))
            END

            GOTO Quit
         END
      END

      -- Step 4 ESC or Step 99 (returning from extended screens) - redisplay Lottable01 on screen 3
      IF (@nStep = 4 AND @nInputKey = 0) OR (@nStep = 99 AND @nScn = 816)
      BEGIN
         -- Validate inputs
         IF ISNULL(@cDropID, '') = '' OR ISNULL(@cSKU, '') = ''
            GOTO Quit

         -- Get current displayed Lottable01 from O_Field15 (keep showing the same one)
         SELECT @cCurrentLot = O_Field15
         FROM RDT.RDTMobRec WITH (NOLOCK)
         WHERE Mobile = @nMobile

         -- If we have a current lot, keep showing it
         IF @cCurrentLot LIKE 'LOT01:%'
         BEGIN
            SET @cExtendedInfo = @cCurrentLot
            GOTO Quit
         END

         -- Otherwise get first available Lottable01
         SELECT TOP 1 @cLottable01 = LA.Lottable01
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
         INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK)
            ON LLI.StorerKey = LA.StorerKey
            AND LLI.SKU = LA.SKU
            AND LLI.Lot = LA.Lot
         WHERE LLI.StorerKey = @cStorerKey
            AND LLI.ID = @cDropID
            AND LLI.SKU = @cSKU
            AND ISNULL(LA.Lottable01, '') <> ''
         ORDER BY LA.Lottable01

         -- Set extended info to display Lottable01
         IF ISNULL(@cLottable01, '') <> ''
         BEGIN
            SET @cExtendedInfo = 'LOT01:' + LTRIM(RTRIM(SUBSTRING(@cLottable01, 1, 15)))
         END

         GOTO Quit
      END
   END

Quit:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_855ExtInfo11] TO nSQL
GO
