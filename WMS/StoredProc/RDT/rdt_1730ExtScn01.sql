
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************************/
/* Store procedure: rdt_1730ExtScn01                                                            */
/* Copyright      : Maersk                                                                      */
/* Customer       : Granite Levis                                                               */
/*                                                                                              */
/*                                                                                              */
/* Date       Rev    Author   Purposes                                                          */
/* 2026-02-05 1.0    NLT013   FCR-10345 Create                                                  */
/************************************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1730ExtScn01] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nScn             INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT,
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT,
   @cUDF30  NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cFromID             NVARCHAR( 18),
      @cFromLoc            NVARCHAR( 10),
      @cQCKey              NVARCHAR( 10),
      @cQCLine             NVARCHAR( 5),
      @cSKU                NVARCHAR( 20),
      @cSKUDescr           NVARCHAR( 60),
      @cReason             NVARCHAR( 10),
      @cToLoc              NVARCHAR( 10),
      @cFromLot            NVARCHAR( 10),
      @cPackKey            NVARCHAR( 10),
      @cPUOM               NVARCHAR( 1),
      @cPUOM_Desc          NVARCHAR( 5),
      @cMUOM_Desc          NVARCHAR( 5),
      @cMatchSuggestLoc    NVARCHAR( 5),
      @cFinalizeFlag       NVARCHAR( 5),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @nPUOM_Div           INT,
      @nACT_QTY            INT,
      @nIQCQty             INT,
      @nPIQC_QTY           INT,
      @nMIQC_QTY           INT,
      @nPACT_QTY           INT,
      @nMACT_QTY           INT,
      @nSKULotCount        INT,
      @nCurrentStep        INT,
      @nCurrentScn         INT,
      @nTranCount          INT,
      @nTotalQty           INT,

      @cErrMsg1    NVARCHAR( 20), @cErrMsg2    NVARCHAR( 20),
      @cErrMsg3    NVARCHAR( 20), @cErrMsg4    NVARCHAR( 20),
      @cErrMsg5    NVARCHAR( 20), @cErrMsg6    NVARCHAR( 20),
      @cErrMsg7    NVARCHAR( 20), @cErrMsg8    NVARCHAR( 20),
      @cErrMsg9    NVARCHAR( 20), @cErrMsg10   NVARCHAR( 20),
      @cErrMsg11   NVARCHAR( 20), @cErrMsg12   NVARCHAR( 20),
      @cErrMsg13   NVARCHAR( 20), @cErrMsg14   NVARCHAR( 20),
      @cErrMsg15   NVARCHAR( 20),

      @cSQL             NVARCHAR(MAX),
      @cSQLParam        NVARCHAR(MAX)

   -- Initialize UDF outputs
   SET @cUDF01 = ''
   SET @cUDF02 = ''
   SET @cUDF03 = ''
   SET @cUDF04 = ''

   -- Only process for FN 1730
   IF @nFunc <> 1730
      GOTO Quit

   -- Get QCKey from session
   SELECT 
      @cQCKey = V_String1,
      @cFromLoc = V_Loc,
      @cFromID = V_ID,
      @cMatchSuggestLoc = V_String10,
      @nCurrentStep = Step,
      @nCurrentScn = Scn
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Get default reason from config
   SET @cReason = ISNULL(rdt.rdtGetConfig(@nFunc, 'DEFAULTREASON', @cStorerKey), '')
   IF @cReason = '0'
      SET @cReason = ''

   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''

   -- Get preferred UOM
   SELECT @cPUOM = ISNULL(DefaultUOM, '6')
   FROM RDT.rdtMobRec M WITH (NOLOCK)
   INNER JOIN RDT.rdtUser U WITH (NOLOCK) ON (M.UserName = U.UserName)
   WHERE M.Mobile = @nMobile

   /********************************************************************************
   Step 3: FROM ID Screen (Scn 1732)
   - Check if FromID has only 1 SKU/LOT
   - If single SKU/LOT: Skip screens 4, 5, 6, 7 and go directly to Step 9 (ToLOC)
   - If multiple SKU/LOT: Let user proceed to Screen 4 to select SKU
   ********************************************************************************/
   IF @nCurrentStep = 3
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- Get FromID from input
         SELECT @cFromID = Value FROM @tExtScnData WHERE Variable = '@cFromID'

         -- Count distinct SKU/LOT combinations for this FromID
         SELECT @nSKULotCount = COUNT(DISTINCT CONCAT(SKU, '|', FromLot))
         FROM dbo.InventoryQCDetail WITH (NOLOCK)
         WHERE QC_Key = @cQCKey
           AND FromLoc = @cFromLoc
           AND FromID = @cFromID
           AND FinalizeFlag = 'N'

         -- Get the single SKU and QCLine details
         SELECT TOP 1
            @cQCLine   = QCLineNo,
            @cSKU      = SKU,
            @nACT_QTY  = OriginalQty,
            @cFromLot  = FromLot,
            @cPackKey  = PackKey,
            @cToLoc    = ISNULL(ToLoc, '')
         FROM dbo.InventoryQCDetail WITH (NOLOCK)
         WHERE QC_Key = @cQCKey
            AND FromLoc = @cFromLoc
            AND FromID = @cFromID
            AND FinalizeFlag = 'N'
         ORDER BY QCLineNo

         -- If single SKU/LOT, skip to ToLOC screen (Step 9)
         IF @nSKULotCount = 1
         BEGIN
            -- Get SKU info for display
            SELECT
               @cSKUDescr = S.Descr,
               @cMUOM_Desc = Pack.PackUOM3,
               @cPUOM_Desc =
                  CASE @cPUOM
                     WHEN '2' THEN Pack.PackUOM1 -- Case
                     WHEN '3' THEN Pack.PackUOM2 -- Inner pack
                     WHEN '6' THEN Pack.PackUOM3 -- Master unit
                     WHEN '1' THEN Pack.PackUOM4 -- Pallet
                     WHEN '4' THEN Pack.PackUOM8 -- Other unit 1
                     WHEN '5' THEN Pack.PackUOM9 -- Other unit 2
                  END,
               @nPUOM_Div = CAST(ISNULL(
                  CASE @cPUOM
                     WHEN '2' THEN Pack.CaseCNT
                     WHEN '3' THEN Pack.InnerPack
                     WHEN '6' THEN Pack.QTY
                     WHEN '1' THEN Pack.Pallet
                     WHEN '4' THEN Pack.OtherUnit1
                     WHEN '5' THEN Pack.OtherUnit2
                  END, 1) AS INT)
            FROM dbo.SKU S WITH (NOLOCK)
            INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
            WHERE StorerKey = @cStorerKey
              AND SKU = @cSKU

            -- Convert to preferred UOM QTY
            IF @cPUOM = '6' OR @nPUOM_Div = 0 OR @nPUOM_Div IS NULL
            BEGIN
               SET @nPUOM_Div = 1
               SET @cPUOM_Desc = ''
               SET @nPIQC_QTY = 0
               SET @nMIQC_QTY = @nACT_QTY
               SET @nPACT_QTY = 0
               SET @nMACT_QTY = @nACT_QTY
            END
            ELSE
            BEGIN
               SET @nPIQC_QTY = @nACT_QTY / @nPUOM_Div
               SET @nMIQC_QTY = @nACT_QTY % @nPUOM_Div
               SET @nPACT_QTY = @nACT_QTY / @nPUOM_Div
               SET @nMACT_QTY = @nACT_QTY % @nPUOM_Div
            END

            -- Prepare output fields for ToLOC screen (Screen 1738, Step 9)
            SET @cOutField01 = @cSKU
            SET @cOutField02 = SUBSTRING(@cSKUDescr, 1, 20)    -- SKU descr 1
            SET @cOutField03 = SUBSTRING(@cSKUDescr, 21, 40)   -- SKU descr 2
            SET @cOutField04 = CAST(@nPUOM_Div AS NVARCHAR(5))
            SET @cOutField05 = @cPUOM_Desc
            SET @cOutField06 = @cMUOM_Desc
            SET @cOutField07 = CASE WHEN @nPIQC_QTY = 0 THEN '' ELSE CAST(@nPIQC_QTY AS NVARCHAR(5)) END
            SET @cOutField08 = CAST(@nMIQC_QTY AS NVARCHAR(7))
            SET @cOutField09 = CASE WHEN @nPACT_QTY = 0 THEN '' ELSE CAST(@nPACT_QTY AS NVARCHAR(5)) END
            SET @cOutField10 = CAST(@nMACT_QTY AS NVARCHAR(7))
            SET @cOutField11 = @cReason          -- Default Reason from config
            SET @cOutField12 = @cFromID          -- ToID = FromID (no pallet change)
            SET @cOutField13 = @cToLoc           -- ToLoc from IQCDetail
            SET @cOutField14 = ''
         END
         ELSE
         BEGIN
            SELECT
               @nTotalQty  = SUM(OriginalQty)
            FROM dbo.InventoryQCDetail WITH (NOLOCK)
            WHERE QC_Key = @cQCKey
              AND FromLoc = @cFromLoc
              AND FromID = @cFromID
              AND FinalizeFlag = 'N'

            SET @cOutField01 = 'SKU/LOT Qty:' + CAST(@nSKULotCount AS NVARCHAR(5))
            SET @cOutField02 = 'Total Qty:'  + CAST(@nTotalQty AS NVARCHAR(5))
            SET @cOutField03 = ''
            SET @cOutField04 = ''
            SET @cOutField05 = ''
            SET @cOutField06 = ''
            SET @cOutField07 = ''
            SET @cOutField08 = ''
            SET @cOutField09 = ''
            SET @cOutField10 = ''
            SET @cOutField11 = @cReason          -- Default Reason from config
            SET @cOutField12 = @cFromID          -- ToID = FromID (no pallet change)
            SET @cOutField13 = @cToLoc           -- ToLoc from IQCDetail
            SET @cOutField14 = ''
         END

         -- Set UDF values for parent SP to use
         SET @cUDF01 = CAST(@nACT_QTY AS NVARCHAR(10))   -- ActQTY
         SET @cUDF02 = @cQCLine                          -- QCLine
         SET @cUDF03 = @cReason                          -- Reason
         SET @cUDF04 = @cFromID                          -- ToID = FromID
         SET @cUDF05 = @cSKU                             -- SKU

         -- Skip to ToLOC screen (Step 9, Scn 1738)
         SET @nAfterScn = 1738
         SET @nAfterStep = 99
      END
   END
   ELSE IF @nCurrentStep = 99
   BEGIN
      IF @nCurrentScn = 1738
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE 
               @cAcToLoc NVARCHAR( 10),
               @cChkFacility  NVARCHAR( 5),
               @cToFacility   NVARCHAR( 5)

            SET @cAcToLoc = ISNULL(@cInField14, '')
            SET @cToLoc = ISNULL(@cOutField13, '')

            -- Validate blank
            IF @cAcToLoc = '' OR @cAcToLoc IS NULL
            BEGIN
               SET @nErrNo = 258701
               SET @cErrMsg = rdt.rdtgetmessage( 64070, @cLangCode, 'DSP') -- ToLoc is needed
               GOTO Scn_1738_Fail
            END

            IF @cAcToLoc <> @cToLoc AND @cMatchSuggestLoc = 0
            BEGIN
               SET @nErrNo = 0
               SET @cErrMsg1 = 'WRONG LOC.'
               SET @cErrMsg2 = 'PLS HOLD THE SKU.'
               EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2
               IF @nErrNo = 1
               BEGIN
                  SET @cErrMsg1 = ''
                  SET @cErrMsg2 = ''
               END

               -- Prep next screen var
               SET @cOutField01 = @cFromLOC
               SET @cOutField02 = @cFromID
               SET @cOutField03 = ''
            
               -- Go to next screen
               SET @nAfterScn = 1733
               SET @nAfterStep = 4
               GOTO Quit
            END

            SET @cChkFacility = ''
            -- Get LOC info
            SELECT 
               @cChkFacility = Facility, 
               @cAcToLoc = LOC 
            FROM dbo.LOC WITH (NOLOCK)
            WHERE LOC = @cAcToLoc

            -- Validate LOC
            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 258702
               SET @cErrMsg = rdt.rdtgetmessage( 64071, @cLangCode, 'DSP') -- Invalid ToLoc
               GOTO Scn_1738_Fail
            END
            
            SELECT @cToFacility = To_facility
            FROM dbo.InventoryQC WITH (NOLOCK)
            WHERE QC_Key = @cQCKey

            IF ISNULL(RTRIM(@cToFacility), '') = ''
               SET @cToFacility = ''

            -- Validate LOC's facility
            IF ISNULL(@cChkFacility, '') <> @cToFacility
            BEGIN
               SET @nErrNo = 258703
               SET @cErrMsg = rdt.rdtgetmessage( 64072, @cLangCode, 'DSP') -- Different Facility
               GOTO Scn_1738_Fail
            END

            IF @cAcToLoc <> @cToLoc AND ISNULL(@cToLoc , '') <> ''   -- dispaly ToLoc is blank
            BEGIn
            -- Prep next screen var
               -- Option - IQC to different location   Proceed?
               SET @cOutField01 = ''
         
               -- Go to Next screen
               SET @nAfterScn  = @nScn + 1
               SET @nAfterStep = 10
               GOTO Quit
            END
            ELSE
            BEGIN
               SET @cOutField01 = ''

               SET @cFinalizeFlag = 0
               IF EXISTS( SELECT 1 FROM dbo.StorerConfig WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ConfigKey = 'FinalizeIQC' AND sValue = '1' )
               BEGIN
                  SET @cFinalizeFlag = '1'
               END   
               ELSE
               BEGIN
                  SET @cFinalizeFlag = '0'
               END

               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
                        ' @cQCKey, @cQCLine, @cToLoc, @cToID, @cReason, @nActQty, @cFinalizeFlag, ' +
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile      INT,           ' +
                        '@nFunc        INT,           ' +
                        '@cLangCode    NVARCHAR( 3),  ' +
                        '@nStep        INT,           ' +
                        '@nInputKey    INT,           ' +
                        '@cFacility    NVARCHAR( 5),  ' +
                        '@cStorerKey   NVARCHAR( 15), ' +
                        '@cQCKey       NVARCHAR( 10), ' +
                        '@cQCLine      NVARCHAR( 5), ' +
                        '@cToLoc       NVARCHAR( 10), ' +
                        '@cToID        NVARCHAR( 18), ' +
                        '@cReason      NVARCHAR( 20), ' +
                        '@nActQty      INT, ' +
                        '@cFinalizeFlag NVARCHAR( 1), ' +
                        '@nErrNo             INT            OUTPUT, ' +
                        '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
                        @cQCKey, @cQCLine, @cAcToLoc, @cFromID, @cReason, @nACT_QTY, @cFinalizeFlag, 
                        @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrno<>0
                     BEGIN
                        GOTO Scn_1738_Fail
                     END
                  END
               END

               -- Go to Next screen   -- skip confirm update screen
               SET @nAfterScn  = 1740
               SET @nAfterStep = 11
               GOTO Quit
            END

            Scn_1738_Fail:
               -- Count distinct SKU/LOT combinations for this FromID
               SELECT @nSKULotCount = COUNT(DISTINCT CONCAT(SKU, '|', FromLot))
               FROM dbo.InventoryQCDetail WITH (NOLOCK)
               WHERE QC_Key = @cQCKey
               AND FromLoc = @cFromLoc
               AND FromID = @cFromID
               AND FinalizeFlag = 'N'

               -- Get the single SKU and QCLine details
               SELECT TOP 1
                  @cQCLine   = QCLineNo,
                  @cSKU      = SKU,
                  @nACT_QTY  = OriginalQty,
                  @cFromLot  = FromLot,
                  @cPackKey  = PackKey,
                  @cToLoc    = ISNULL(ToLoc, '')
               FROM dbo.InventoryQCDetail WITH (NOLOCK)
               WHERE QC_Key = @cQCKey
                  AND FromLoc = @cFromLoc
                  AND FromID = @cFromID
                  AND FinalizeFlag = 'N'
               ORDER BY QCLineNo

               -- If single SKU/LOT, skip to ToLOC screen (Step 9)
               IF @nSKULotCount = 1
               BEGIN
                  -- Get SKU info for display
                  SELECT
                     @cSKUDescr = S.Descr,
                     @cMUOM_Desc = Pack.PackUOM3,
                     @cPUOM_Desc =
                        CASE @cPUOM
                           WHEN '2' THEN Pack.PackUOM1 -- Case
                           WHEN '3' THEN Pack.PackUOM2 -- Inner pack
                           WHEN '6' THEN Pack.PackUOM3 -- Master unit
                           WHEN '1' THEN Pack.PackUOM4 -- Pallet
                           WHEN '4' THEN Pack.PackUOM8 -- Other unit 1
                           WHEN '5' THEN Pack.PackUOM9 -- Other unit 2
                        END,
                     @nPUOM_Div = CAST(ISNULL(
                        CASE @cPUOM
                           WHEN '2' THEN Pack.CaseCNT
                           WHEN '3' THEN Pack.InnerPack
                           WHEN '6' THEN Pack.QTY
                           WHEN '1' THEN Pack.Pallet
                           WHEN '4' THEN Pack.OtherUnit1
                           WHEN '5' THEN Pack.OtherUnit2
                        END, 1) AS INT)
                  FROM dbo.SKU S WITH (NOLOCK)
                  INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                  WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU

                  -- Convert to preferred UOM QTY
                  IF @cPUOM = '6' OR @nPUOM_Div = 0 OR @nPUOM_Div IS NULL
                  BEGIN
                     SET @nPUOM_Div = 1
                     SET @cPUOM_Desc = ''
                     SET @nPIQC_QTY = 0
                     SET @nMIQC_QTY = @nACT_QTY
                     SET @nPACT_QTY = 0
                     SET @nMACT_QTY = @nACT_QTY
                  END
                  ELSE
                  BEGIN
                     SET @nPIQC_QTY = @nACT_QTY / @nPUOM_Div
                     SET @nMIQC_QTY = @nACT_QTY % @nPUOM_Div
                     SET @nPACT_QTY = @nACT_QTY / @nPUOM_Div
                     SET @nMACT_QTY = @nACT_QTY % @nPUOM_Div
                  END

                  -- Prepare output fields for ToLOC screen (Screen 1738, Step 9)
                  SET @cOutField01 = @cSKU
                  SET @cOutField02 = SUBSTRING(@cSKUDescr, 1, 20)    -- SKU descr 1
                  SET @cOutField03 = SUBSTRING(@cSKUDescr, 21, 40)   -- SKU descr 2
                  SET @cOutField04 = CAST(@nPUOM_Div AS NVARCHAR(5))
                  SET @cOutField05 = @cPUOM_Desc
                  SET @cOutField06 = @cMUOM_Desc
                  SET @cOutField07 = CASE WHEN @nPIQC_QTY = 0 THEN '' ELSE CAST(@nPIQC_QTY AS NVARCHAR(5)) END
                  SET @cOutField08 = CAST(@nMIQC_QTY AS NVARCHAR(7))
                  SET @cOutField09 = CASE WHEN @nPACT_QTY = 0 THEN '' ELSE CAST(@nPACT_QTY AS NVARCHAR(5)) END
                  SET @cOutField10 = CAST(@nMACT_QTY AS NVARCHAR(7))
                  SET @cOutField11 = @cReason          -- Default Reason from config
                  SET @cOutField12 = @cFromID          -- ToID = FromID (no pallet change)
                  SET @cOutField13 = @cToLoc           -- ToLoc from IQCDetail
                  SET @cOutField14 = ''
               END
               ELSE
               BEGIN
                  SELECT
                     @nTotalQty  = SUM(OriginalQty)
                  FROM dbo.InventoryQCDetail WITH (NOLOCK)
                  WHERE QC_Key = @cQCKey
                  AND FromLoc = @cFromLoc
                  AND FromID = @cFromID
                  AND FinalizeFlag = 'N'

                  SET @cOutField01 = 'SKU/LOT Qty:' + CAST(@nSKULotCount AS NVARCHAR(5))
                  SET @cOutField02 = 'Total Qty:'  + CAST(@nTotalQty AS NVARCHAR(5))
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ''
                  SET @cOutField06 = ''
                  SET @cOutField07 = ''
                  SET @cOutField08 = ''
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = @cReason          -- Default Reason from config
                  SET @cOutField12 = @cFromID          -- ToID = FromID (no pallet change)
                  SET @cOutField13 = @cToLoc           -- ToLoc from IQCDetail
                  SET @cOutField14 = ''
               END

               -- Set UDF values for parent SP to use
               SET @cUDF01 = CAST(@nACT_QTY AS NVARCHAR(10))   -- ActQTY
               SET @cUDF02 = @cQCLine                          -- QCLine
               SET @cUDF03 = @cReason                          -- Reason
               SET @cUDF04 = @cFromID                          -- ToID = FromID
               SET @cUDF05 = @cSKU                             -- SKU

               -- Skip to ToLOC screen (Step 9, Scn 1738)
               SET @nAfterScn = 1738
               SET @nAfterStep = 99
         END
         ELSE IF @nInputKey = 0
         BEGIN
            -- Prep next screen var
            SET @cOutField01 = @cFromLOC
            SET @cOutField02 = ''
            
            SET @nAfterScn = 1732
            SET @nAfterStep = 3
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

GRANT EXECUTE ON rdt.rdt_1730ExtScn01 TO NSQL 
GO  
