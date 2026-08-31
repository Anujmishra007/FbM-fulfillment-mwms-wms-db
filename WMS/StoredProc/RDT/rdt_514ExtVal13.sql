SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_514ExtVal13                                       */
/* Purpose: Validate Putaway Zone for GOO inventory during UCC Move       */
/* Copyright      : Maersk                                                */
/* Customer       : AEOMX (American Eagle Mexico)                         */
/*                                                                        */
/* Modifications log:                                                     */
/*                                                                        */
/* Date       Rev    Author     Purposes                                  */
/* 2026-05-26 1.0.0  JackC     FCR-12938 Created                         */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_514ExtVal13] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR(3),
   @nStep          INT,
   @nInputKey      INT,
   @cStorerKey     NVARCHAR(15),
   @cToID          NVARCHAR(18),
   @cToLoc         NVARCHAR(10),
   @cFromLoc       NVARCHAR(10),
   @cFromID        NVARCHAR(18),
   @cUCC           NVARCHAR(20),
   @cUCC1          NVARCHAR(20),
   @cUCC2          NVARCHAR(20),
   @cUCC3          NVARCHAR(20),
   @cUCC4          NVARCHAR(20),
   @cUCC5          NVARCHAR(20),
   @cUCC6          NVARCHAR(20),
   @cUCC7          NVARCHAR(20),
   @cUCC8          NVARCHAR(20),
   @cUCC9          NVARCHAR(20),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR(20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0

   DECLARE @nDebugFlag  INT = 0

   DECLARE
      @nTotalUCC       INT,
      @nGOOCount       INT,
      @nPAZoneCount    INT,
      @nNullPAZone     INT,
      @cSKUPAZone      NVARCHAR(10),
      @cLocPAZone      NVARCHAR(10)

   DECLARE @tUCC TABLE (UCCNo NVARCHAR(20))

   IF @nFunc = 514
   BEGIN
      IF @nStep = 2 -- ToLOC screen
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Collect all UCCs from parameters
            --IF ISNULL(@cUCC, '') <> '' INSERT INTO @tUCC VALUES (@cUCC)
            IF ISNULL(@cUCC1, '') <> '' INSERT INTO @tUCC VALUES (@cUCC1)
            IF ISNULL(@cUCC2, '') <> '' INSERT INTO @tUCC VALUES (@cUCC2)
            IF ISNULL(@cUCC3, '') <> '' INSERT INTO @tUCC VALUES (@cUCC3)
            IF ISNULL(@cUCC4, '') <> '' INSERT INTO @tUCC VALUES (@cUCC4)
            IF ISNULL(@cUCC5, '') <> '' INSERT INTO @tUCC VALUES (@cUCC5)
            IF ISNULL(@cUCC6, '') <> '' INSERT INTO @tUCC VALUES (@cUCC6)
            IF ISNULL(@cUCC7, '') <> '' INSERT INTO @tUCC VALUES (@cUCC7)
            IF ISNULL(@cUCC8, '') <> '' INSERT INTO @tUCC VALUES (@cUCC8)
            IF ISNULL(@cUCC9, '') <> '' INSERT INTO @tUCC VALUES (@cUCC9)

            -- Collect UCCs from rdtMoveUCCLog (for multi-page UCC scans)
            INSERT INTO @tUCC (UCCNo)
            SELECT UCCNo
            FROM rdt.rdtMoveUCCLog WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND AddWho = SUSER_SNAME()
               AND UCCNo NOT IN (SELECT UCCNo FROM @tUCC)

            IF @nDebugFlag = 1
            BEGIN
               SELECT '@tUCC'
               SELECT T.UCCNo, LA.Lottable02, S.PutawayZone
               FROM @tUCC T
               INNER JOIN dbo.UCC U WITH (NOLOCK) ON T.UCCNo = U.UCCNo AND U.StorerKey = @cStorerKey
               INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) 
                  ON LA.StorerKey = U.StorerKey
                  AND LA.SKU = U.SKU
                  AND LA.Lot = U.Lot
               INNER JOIN dbo.SKU S WITH (NOLOCK) ON S.StorerKey = U.StorerKey AND S.SKU = U.SKU       
            END

            SELECT @nTotalUCC = COUNT(*) FROM @tUCC

            IF @nTotalUCC = 0
               GOTO Quit

            -- Count UCCs with Lottable02 = 'GOO'
            SELECT @nGOOCount = COUNT(DISTINCT U.UCCNo)
            FROM @tUCC T
            INNER JOIN dbo.UCC U WITH (NOLOCK) ON T.UCCNo = U.UCCNo AND U.StorerKey = @cStorerKey
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON LA.StorerKey = U.StorerKey
               AND LA.SKU = U.SKU
               AND LA.Lot = U.Lot
            WHERE LA.Lottable02 = 'GOO'

            -- If not all UCCs have Lottable02 = 'GOO', skip validation
            IF @nGOOCount <> @nTotalUCC
               GOTO Quit

            -- All UCCs have Lottable02 = 'GOO', proceed with PutawayZone validation

            -- Check if any SKU has NULL/empty PutawayZone
            SELECT @nNullPAZone = COUNT(DISTINCT U.UCCNo)
            FROM @tUCC T
            INNER JOIN dbo.UCC U WITH (NOLOCK) ON T.UCCNo = U.UCCNo AND U.StorerKey = @cStorerKey
            INNER JOIN dbo.SKU S WITH (NOLOCK) ON S.StorerKey = U.StorerKey AND S.SKU = U.SKU
            WHERE ISNULL(S.PutawayZone, '') = ''

            IF @nNullPAZone > 0
            BEGIN
               SET @nErrNo = 268051
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- SKU PA zone not set
               GOTO Quit
            END

            -- Check if multiple distinct PutawayZones exist
            SELECT @nPAZoneCount = COUNT(DISTINCT S.PutawayZone)
            FROM @tUCC T
            INNER JOIN dbo.UCC U WITH (NOLOCK) ON T.UCCNo = U.UCCNo AND U.StorerKey = @cStorerKey
            INNER JOIN dbo.SKU S WITH (NOLOCK) ON S.StorerKey = U.StorerKey AND S.SKU = U.SKU

            IF @nPAZoneCount > 1
            BEGIN
               SET @nErrNo = 268052
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- MIX SKU PA zone
               GOTO Quit
            END

            -- Get the single SKU PutawayZone
            SELECT TOP 1 @cSKUPAZone = S.PutawayZone
            FROM @tUCC T
            INNER JOIN dbo.UCC U WITH (NOLOCK) ON T.UCCNo = U.UCCNo AND U.StorerKey = @cStorerKey
            INNER JOIN dbo.SKU S WITH (NOLOCK) ON S.StorerKey = U.StorerKey AND S.SKU = U.SKU

            -- Get destination location's PutawayZone
            SET @cLocPAZone = ''
            SELECT @cLocPAZone = ISNULL(PutawayZone, '')
            FROM dbo.LOC WITH (NOLOCK)
            WHERE Loc = @cToLoc

            -- Compare PutawayZones
            IF @cSKUPAZone <> @cLocPAZone
            BEGIN
               SET @nErrNo = 268053
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- PA zone mismatch
               GOTO Quit
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
GRANT EXEC ON RDT.rdt_514ExtVal13 TO NSQL
GO
