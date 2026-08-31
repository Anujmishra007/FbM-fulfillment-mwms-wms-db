
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_803ExtScn04                                       */
/* Copyright      : Maersk                                                */
/* Customer       : AEOMX                                                 */
/* Purpose        : PTW/PTL Extended Screen for:                          */
/*                  - Screen 6920 (3b): SortTote scan                     */
/*                  - Screen 6921 (3c): Confirm LOC                       */
/*                                                                        */
/* Date       Rev    Author   Purposes                                    */
/* 2026-07-14 1.0    Cuize    FCR-13139 Created                           */
/* 2026-08-14 1.1    Cuize    UWP-63852 Fix: Light up slot on first SKU   */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_803ExtScn04] (
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
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nCurrentScn      INT,
      @nCurrentStep     INT,
      @cStation         NVARCHAR(10),
      @cMethod          NVARCHAR(1),
      @cUserName        NVARCHAR(18),
      @cPosition        NVARCHAR(10),
      @cSortToteID      NVARCHAR(20),
      @cSlotLOC         NVARCHAR(10),
      @cSKU             NVARCHAR(20),
      @cDestLOC         NVARCHAR(10),
      @nMenu            INT,
      @cIPAddress       NVARCHAR(40),
      @cLight           NVARCHAR(1),
      @cResult01        NVARCHAR(20),
      @cResult02        NVARCHAR(20),
      @cResult03        NVARCHAR(20),
      @cResult04        NVARCHAR(20),
      @cResult05        NVARCHAR(20),
      @cResult06        NVARCHAR(20),
      @cResult07        NVARCHAR(20),
      @cResult08        NVARCHAR(20),
      @cResult09        NVARCHAR(20),
      @cResult10        NVARCHAR(20),
      -- FCR-13139: Store Result values in C_String for ConfirmLOC screen passthrough
      @cSaveResult01    NVARCHAR(20),
      @cSaveResult02    NVARCHAR(20),
      @cSaveResult03    NVARCHAR(20),
      @cSaveResult04    NVARCHAR(20),
      @cSaveNODROPID    NVARCHAR(10)   -- Save NODROPID flag for 3c->6924 flow

   -- Get current session info (same as rdtfnc_PTLPiece)
   -- FCR-13139: Also read C_String2/3/4/6 for ConfirmLOC screen passthrough
   SELECT
      @nCurrentScn  = Scn,
      @nCurrentStep = Step,
      @cStation     = V_String1,
      @cMethod      = V_String2,
      @cIPAddress   = V_String4,
      @cPosition    = V_String5,
      @cLight       = V_String24,
      @cSKU         = V_SKU,
      @cUserName    = UserName,
      @nMenu        = Menu,
      @cSaveResult01 = C_String2,
      @cSaveResult02 = C_String3,
      @cSaveResult03 = C_String4,
      @cSaveResult04 = C_String6,
      @cSaveNODROPID = C_String5
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 803
   BEGIN
      -- ========================================================================
      -- Step 2: After DropID scan, check if Full UCC -> skip to Screen 3b
      -- Full UCC = single VirtualCarton in DropID + DropID is a UCC
      -- ========================================================================
      IF @nCurrentStep = 2 AND @nInputKey = 1
      BEGIN
         DECLARE @cUserDropID_Step2 NVARCHAR(20)
         DECLARE @nVCCount INT
         DECLARE @bIsFullUCC BIT = 0

         -- Get user's DropID from rdtPTLPieceLog
         SELECT TOP 1 @cUserDropID_Step2 = DropID
         FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
         WHERE Station = @cStation
           AND AddWho = @cUserName
           AND UserDefine02 = 'INPROGRESS'
         ORDER BY AddDate DESC

         IF @cUserDropID_Step2 IS NOT NULL AND @cUserDropID_Step2 <> ''
         BEGIN
            -- UWP-64610: Full UCC detection
            -- Full UCC conditions:
            --   1. DropID exists in UCC.UCCNo
            --   2. Only 1 distinct VirtualCartonID (CaseID) under this DropID
            --   3. PickDetail total Qty = UCC total Qty (no partial processing)
            -- When Full UCC, CaseID in PickDetail is empty/NULL, VirtualCarton = UCCNo = DropID
            IF EXISTS (SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUserDropID_Step2 AND StorerKey = @cStorerKey)
            BEGIN
               DECLARE @nVCCount_Step2 INT = 0
               DECLARE @nUCCQty_Step2 INT = 0
               DECLARE @nPDQty_Step2 INT = 0

               SELECT @nUCCQty_Step2 = ISNULL(SUM(Qty), 0)
               FROM dbo.UCC WITH (NOLOCK)
               WHERE UCCNo = @cUserDropID_Step2
                 AND StorerKey = @cStorerKey

               SELECT @nVCCount_Step2 = COUNT(DISTINCT ISNULL(NULLIF(CaseID, ''), @cUserDropID_Step2)),
                      @nPDQty_Step2 = ISNULL(SUM(Qty), 0)
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND DropID = @cUserDropID_Step2
                 AND Qty > 0

               -- Full UCC: Only 1 CaseID AND no partial processing
               IF @nVCCount_Step2 <= 1 AND @nPDQty_Step2 = @nUCCQty_Step2
                  SET @bIsFullUCC = 1
            END

            -- If Full UCC, jump to Screen 6920 (3b) to scan SortTote
            IF @bIsFullUCC = 1
            BEGIN
               DECLARE @cFullUCC_Position NVARCHAR(10)
               DECLARE @cFullUCC_SlotLOC NVARCHAR(10)
               DECLARE @cFullUCC_CartonID NVARCHAR(20)
               DECLARE @cFullUCC_CaseID NVARCHAR(20)

               -- Get CaseID for this DropID
               SELECT TOP 1 @cFullUCC_CaseID = ISNULL(NULLIF(CaseID, ''), @cUserDropID_Step2)
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND DropID = @cUserDropID_Step2
                 AND Qty > 0

               -- Get slot info by SourceKey = CaseID
               SELECT TOP 1
                  @cFullUCC_Position = L.Position,
                  @cFullUCC_SlotLOC = DP.LOC,
                  @cFullUCC_CartonID = L.CartonID
               FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
               JOIN dbo.DeviceProfile DP WITH (NOLOCK)
                  ON DP.DeviceID = L.Station
                  AND DP.DevicePosition = L.Position
                  AND DP.StorerKey = @cStorerKey
               WHERE L.Station = @cStation
                 AND L.AddWho = @cUserName
                 AND L.UserDefine02 = 'INPROGRESS'
                 AND L.SourceKey = @cFullUCC_CaseID

               -- If no SortTote yet, go to Screen 6920 (3b) to scan Tote
               IF @cFullUCC_CartonID IS NULL OR @cFullUCC_CartonID = ''
               BEGIN
                  SET @cOutField01 = ''                 -- TOTE ID input
                  SET @cOutField02 = @cFullUCC_SlotLOC  -- LOC display

                  SET @nAfterScn = 6920
                  SET @nAfterStep = 99
                  GOTO Quit
               END
               ELSE
               BEGIN
                  -- SortTote already assigned - call ConfirmSP directly to process Full UCC
                  -- No need to scan Tote again, use existing @cFullUCC_CartonID
                  -- Update MobRec so ConfirmSP knows we're in Screen 6920 context
                  UPDATE rdt.rdtMobRec
                  SET V_DropID = @cUserDropID_Step2,
                      Scn = 6920
                  WHERE Mobile = @nMobile

                  EXEC rdt.rdt_PTLPiece_Confirm_Order23
                     @nMobile,
                     @nFunc,
                     @cLangCode,
                     99,            -- Step 99 triggers FullUCCSort
                     1,             -- InputKey = ENTER
                     @cFacility,
                     @cStorerKey,
                     @cLight,
                     @cStation,
                     @cMethod,
                     '',            -- SKU (not needed for Full UCC)
                     @cIPAddress OUTPUT,
                     @cFullUCC_Position OUTPUT,
                     @nErrNo OUTPUT,
                     @cErrMsg OUTPUT,
                     @cResult01 OUTPUT,
                     @cResult02 OUTPUT,
                     @cResult03 OUTPUT,
                     @cResult04 OUTPUT,
                     @cResult05 OUTPUT,
                     @cResult06 OUTPUT,
                     @cResult07 OUTPUT,
                     @cResult08 OUTPUT,
                     @cResult09 OUTPUT,
                     @cResult10 OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit

                  -- FCR-13139: Check if ConfirmLOC is required (same as Unit-Level)
                  DECLARE @cConfirmLOC_FullUCC NVARCHAR(10)
                  SET @cConfirmLOC_FullUCC = rdt.RDTGetConfig(@nFunc, 'ConfirmLOC', @cStorerKey)

                  IF @cConfirmLOC_FullUCC = '1'
                  BEGIN
                     -- Get destination LOC for confirmation
                     DECLARE @cDestLOC_FullUCC NVARCHAR(10)
                     SELECT TOP 1 @cDestLOC_FullUCC = DP.LOC
                     FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
                     JOIN dbo.DeviceProfile DP WITH (NOLOCK)
                        ON DP.DeviceID = L.Station
                        AND DP.DevicePosition = L.Position
                        AND DP.StorerKey = @cStorerKey
                     WHERE L.Station = @cStation
                       AND L.Position = @cFullUCC_Position
                       AND L.AddWho = @cUserName
                       AND L.UserDefine02 IN ('INPROGRESS', 'COMPLETE')
                     ORDER BY L.EditDate DESC

                     -- Prepare Screen 6921 (3c) - Confirm LOC
                     SET @cOutField01 = @cDestLOC_FullUCC  -- Destination LOC display
                     SET @cOutField02 = ''                 -- Confirm LOC input

                     -- Store MatrixSP14 results for use after LOC confirmation
                     SET @cSaveResult01 = @cResult01
                     SET @cSaveResult02 = @cResult02
                     SET @cSaveResult03 = @cResult03
                     SET @cSaveResult04 = @cResult04
                     SET @cSaveNODROPID = @cResult10

                     SET @nAfterScn = 6921
                     SET @nAfterStep = 99
                     GOTO Quit
                  END

                  -- No ConfirmLOC - Return to Step 2 for next DropID
                  -- FCR-13139: Show completion message based on Result10 (same as ConfirmLOC flow)
                  IF @cResult10 IN ('SC', 'ND', 'PC')
                  BEGIN
                     SET @nErrNo = CASE @cResult10
                        WHEN 'SC' THEN 274511  -- Listo para packing (Slot Complete)
                        WHEN 'ND' THEN 274508  -- DropID/UCC sorting complete
                        WHEN 'PC' THEN 274514  -- Partial complete, continue scan
                        ELSE 274508
                     END
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
                  END
                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  -- FCR-13139: Show LOC and TOTE on DropID screen (d03, d04)
                  SET @cOutField03 = @cResult01  -- LOC:xxx
                  SET @cOutField04 = @cResult02  -- TOTE:xxx
                  SET @cOutField11 = ''
                  SET @cSaveResult01 = ''
                  SET @cSaveResult02 = ''
                  SET @cSaveResult03 = ''
                  SET @cSaveResult04 = ''
                  SET @nAfterScn = 6924
                  SET @nAfterStep = 2
                  GOTO Quit
               END
            END
            ELSE
            BEGIN
               -- ========================================================================
               -- UNIT-LEVEL SORT: Jump to Screen 6922 (3a) for SKU scan
               -- ========================================================================
               SET @cOutField01 = ''  -- Result01
               SET @cOutField02 = ''  -- Result02
               SET @cOutField03 = ''  -- Result03
               SET @cOutField11 = ''  -- SKU input

               SET @nAfterScn = 6922
               SET @nAfterStep = 99
               GOTO Quit
            END
         END
         ELSE
         BEGIN
            -- No DropID found - error, return to DropID scan
            SET @nErrNo = 274507
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField11 = ''
            SET @cSaveResult01 = ''
            SET @cSaveResult02 = ''
            SET @cSaveResult03 = ''
            SET @cSaveResult04 = ''
            SET @nAfterScn = 6924
            SET @nAfterStep = 2
            GOTO Quit
         END
      END

      -- ========================================================================
      -- Screen 6920 (3b): SortTote Scan
      -- Field01: TOTE ID (input)
      -- Field02: LOC - Physical SLOT (output)
      -- ========================================================================
      IF @nCurrentStep = 99 AND @nCurrentScn = 6920
      BEGIN
         -- ESC - Go back to SKU scan screen (6922)
         IF @nInputKey = 0
         BEGIN
            -- Reset screen fields
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField11 = ''

            SET @nAfterScn = 6922
            SET @nAfterStep = 99
            GOTO Quit
         END

         -- ENTER - Validate and save SortTote
         IF @nInputKey = 1
         BEGIN
            SET @cSortToteID = @cInField01

            -- FCR-13139: Check if this is Full UCC (DropID exists in UCC table)
            DECLARE @cUserDropID_6920 NVARCHAR(20)
            DECLARE @bIsFullUCC_6920 BIT = 0

            -- FCR-13139: ORDER BY EditDate DESC to get the most recently updated record
            SELECT TOP 1 @cUserDropID_6920 = DropID
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
            WHERE Station = @cStation
              AND AddWho = @cUserName
              AND UserDefine02 = 'INPROGRESS'
            ORDER BY EditDate DESC

            IF EXISTS (SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cUserDropID_6920 AND StorerKey = @cStorerKey)
               DECLARE @nVCCount_6920 INT = 0
               DECLARE @nUCCQty_6920 INT = 0
               DECLARE @nPDQty_6920 INT = 0

               SELECT @nUCCQty_6920 = ISNULL(SUM(Qty), 0)
               FROM dbo.UCC WITH (NOLOCK)
               WHERE UCCNo = @cUserDropID_6920

               SELECT @nVCCount_6920 = COUNT(DISTINCT ISNULL(NULLIF(CaseID, ''), @cUserDropID_6920)),
                      @nPDQty_6920 = ISNULL(SUM(Qty), 0)
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND DropID = @cUserDropID_6920
                 AND Qty > 0

               -- Full UCC: Only 1 CaseID AND no partial processing
               IF @nVCCount_6920 <= 1 AND @nPDQty_6920 = @nUCCQty_6920
                  SET @bIsFullUCC_6920 = 1
            END

            -- Get current slot position from rdtPTLPieceLog
            -- SourceKey = CaseID for BOTH Full UCC and Unit-Level
            DECLARE @cCaseID_6920 NVARCHAR(20)
            SELECT TOP 1 @cCaseID_6920 = ISNULL(NULLIF(CaseID, ''), @cUserDropID_6920)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
              AND DropID = @cUserDropID_6920
              AND Qty > 0

            IF @bIsFullUCC_6920 = 1
            BEGIN
               -- Full UCC: SourceKey = CaseID, match by DropID to find the right slot
               SELECT TOP 1
                  @cPosition = L.Position,
                  @cSlotLOC = DP.LOC
               FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
               JOIN dbo.DeviceProfile DP WITH (NOLOCK)
                  ON DP.DeviceID = L.Station
                  AND DP.DevicePosition = L.Position
                  AND DP.StorerKey = @cStorerKey
               WHERE L.Station = @cStation
                 AND L.AddWho = @cUserName
                 AND L.UserDefine02 = 'INPROGRESS'
                 AND L.SourceKey = @cCaseID_6920
                 AND L.DropID = @cUserDropID_6920
                 AND (L.CartonID IS NULL OR L.CartonID = '')
            END
            ELSE
            BEGIN
               -- Unit-Level: SourceKey = CaseID, may have multiple records, match by SKU
               SELECT TOP 1
                  @cPosition = L.Position,
                  @cSlotLOC = DP.LOC
               FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
               JOIN dbo.DeviceProfile DP WITH (NOLOCK)
                  ON DP.DeviceID = L.Station
                  AND DP.DevicePosition = L.Position
                  AND DP.StorerKey = @cStorerKey
               JOIN dbo.PickDetail PD WITH (NOLOCK)
                  ON PD.CaseID = L.SourceKey
                  AND PD.StorerKey = @cStorerKey
                  AND PD.DropID = L.DropID
                  AND PD.SKU = @cSKU
                  AND PD.Qty > 0
               WHERE L.Station = @cStation
                 AND L.AddWho = @cUserName
                 AND L.UserDefine02 = 'INPROGRESS'
                 AND (L.CartonID IS NULL OR L.CartonID = '')
               ORDER BY PD.OrderKey
            END

            -- Validate SortTote not blank
            IF @cSortToteID = ''
            BEGIN
               SET @nErrNo = 274501
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            -- FCR-13139: Check SortTote not in use
            -- If ToteID exists in PickDetail.DropID, tote is still in progress
            IF EXISTS (
               SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND DropID = @cSortToteID
            )
            BEGIN
               SET @nErrNo = 274503  -- Tote en uso / Tote in progress
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            -- Check SortTote not already used by another INPROGRESS slot
            -- COMPLETE slots can reuse the tote after packing
            IF EXISTS (
               SELECT 1 FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
               WHERE Station = @cStation
                 AND CartonID = @cSortToteID
                 AND Position <> @cPosition
                 AND UserDefine02 = 'INPROGRESS'
            )
            BEGIN
               SET @nErrNo = 274502
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            -- ========================================================================
            -- Transaction: Update SortTote + Call ConfirmSP (rollback all if fail)
            -- ========================================================================
            DECLARE @nTranCount INT
            SET @nTranCount = @@TRANCOUNT

            BEGIN TRY
               BEGIN TRAN

               -- Update ALL users' rdtPTLPieceLog records with SortTote
               -- Multi-user: SortTote is shared across all users of the same slot
               UPDATE rdt.rdtPTLPieceLog WITH (ROWLOCK)
               SET CartonID = @cSortToteID,
                   EditDate = GETDATE(),
                   EditWho = SUSER_SNAME()
               WHERE Station = @cStation
                 AND Position = @cPosition
                 AND UserDefine02 = 'INPROGRESS'

               -- Call ConfirmSP with Step=99 to process inventory
               EXEC rdt.rdt_PTLPiece_Confirm_Order23
                  @nMobile,
                  @nFunc,
                  @cLangCode,
                  99,            -- Step 99 triggers AfterToteAssign label
                  @nInputKey,
                  @cFacility,
                  @cStorerKey,
                  @cLight,
                  @cStation,
                  @cMethod,
                  @cSKU,
                  @cIPAddress OUTPUT,
                  @cPosition OUTPUT,
                  @nErrNo OUTPUT,
                  @cErrMsg OUTPUT,
                  @cResult01 OUTPUT,
                  @cResult02 OUTPUT,
                  @cResult03 OUTPUT,
                  @cResult04 OUTPUT,
                  @cResult05 OUTPUT,
                  @cResult06 OUTPUT,
                  @cResult07 OUTPUT,
                  @cResult08 OUTPUT,
                  @cResult09 OUTPUT,
                  @cResult10 OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  -- FCR-13139: Check @@TRANCOUNT before rollback
                  -- ConfirmOrder23 may have already rolled back the transaction
                  IF @@TRANCOUNT > @nTranCount
                     ROLLBACK TRAN
                  GOTO Quit
               END

               COMMIT TRAN
            END TRY
            BEGIN CATCH
               IF @@TRANCOUNT > @nTranCount ROLLBACK TRAN
               SET @nErrNo = 274516  -- Update SortTote failed
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END CATCH

            -- FCR-13139: Check if ConfirmLOC is required
            -- Config: ConfirmLOC = '1' to enable LOC confirmation screen
            DECLARE @cConfirmLOCInput NVARCHAR(10)
            SET @cConfirmLOCInput = rdt.RDTGetConfig(@nFunc, 'ConfirmLOC', @cStorerKey)

            IF @cConfirmLOCInput = '1'
            BEGIN
               -- Get destination LOC for confirmation
               DECLARE @cDestLOC_6920 NVARCHAR(10)
               SELECT TOP 1 @cDestLOC_6920 = DP.LOC
               FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
               JOIN dbo.DeviceProfile DP WITH (NOLOCK)
                  ON DP.DeviceID = L.Station
                  AND DP.DevicePosition = L.Position
                  AND DP.StorerKey = @cStorerKey
               WHERE L.Station = @cStation
                 AND L.Position = @cPosition
                 AND L.UserDefine02 IN ('INPROGRESS', 'COMPLETE')

               -- Prepare Screen 6921 (3c) - Confirm LOC
               SET @cOutField01 = @cDestLOC_6920  -- Destination LOC display
               SET @cOutField02 = ''              -- Confirm LOC input

               -- Store MatrixSP14 results for use after LOC confirmation (saved to MobRec at Quit)
               SET @cSaveResult01 = @cResult01
               SET @cSaveResult02 = @cResult02
               SET @cSaveResult03 = @cResult03
               SET @cSaveResult04 = @cResult04
               -- Save NODROPID flag to return to 6924 after 3c confirmation
               SET @cSaveNODROPID = @cResult10

               SET @nAfterScn = 6921
               SET @nAfterStep = 99
               GOTO Quit
            END

            -- FCR-13139: Check if need to return to DropID screen (SC/ND/PC)
            -- SC = Slot Complete, ND = DropID Complete, PC = Partial Complete
            IF @cResult10 IN ('SC', 'ND', 'PC')
            BEGIN
               SET @nErrNo = CASE @cResult10
                  WHEN 'SC' THEN 274511  -- Listo para packing
                  WHEN 'ND' THEN 274508  -- DropID/UCC sorting complete
                  WHEN 'PC' THEN 274514  -- Partial complete, continue scan
                  ELSE 274508
               END
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               -- FCR-13139: Show LOC and TOTE on DropID screen (d03, d04)
               SET @cOutField03 = @cResult01  -- LOC:xxx
               SET @cOutField04 = @cResult02  -- TOTE:xxx
               SET @cOutField11 = ''
               SET @cSaveResult01 = ''
               SET @cSaveResult02 = ''
               SET @cSaveResult03 = ''
               SET @cSaveResult04 = ''
               SET @cSaveNODROPID = ''
               SET @nAfterScn = 6924
               SET @nAfterStep = 2
               GOTO Quit
            END

            -- Prepare next screen var
            SET @cOutField01 = @cResult01
            SET @cOutField02 = @cResult02
            SET @cOutField03 = @cResult03
            SET @cOutField04 = @cResult04
            SET @cOutField11 = ''  -- Clear SKU input

            -- Return to SKU scan screen (6922)
            SET @nAfterScn = 6922
            SET @nAfterStep = 99
            GOTO Quit
         END
      END

      -- ========================================================================
      -- Screen 6922 (3a): SKU Scan (simplified from rdtfnc_PTLPiece Step 3)
      -- Field01-03: Result display (d01-d03)
      -- Field11: SKU/UPC input (i11)
      -- No Option 9 Close, No @nErrNo = -2, No lastPos
      -- ========================================================================
      IF @nCurrentStep = 99 AND @nCurrentScn = 6922
      BEGIN
         -- ESC - Go back to previous screen
         IF @nInputKey = 0
         BEGIN
            -- Reset screen fields
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''
            SET @cOutField11 = ''
            SET @cSaveResult01 = ''
            SET @cSaveResult02 = ''
            SET @cSaveResult03 = ''
            SET @cSaveResult04 = ''

            -- Return to DropID scan screen
            SET @nAfterScn = 6924
            SET @nAfterStep = 2
            GOTO Quit
         END

         -- ENTER - Process SKU scan
         IF @nInputKey = 1
         BEGIN
            DECLARE @cBarcode NVARCHAR(60)
            DECLARE @cUPC NVARCHAR(30)
            DECLARE @cDecodeSP NVARCHAR(30)
            DECLARE @nSKUCnt INT
            DECLARE @bSuccess INT
            DECLARE @cSQL NVARCHAR(MAX)
            DECLARE @cSQLParam NVARCHAR(MAX)

            SET @cBarcode = LTRIM(RTRIM(@cInField11))

            -- Check blank
            IF @cBarcode = ''
            BEGIN
               SET @nErrNo = 99507
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Need SKU
               GOTO Quit
            END

            -- Get DecodeSP config
            SET @cDecodeSP = rdt.rdtGetConfig(@nFunc, 'DecodeSP', @cStorerKey)

            -- Decode
            SET @cUPC = @cBarcode
            IF @cDecodeSP <> '' AND @cDecodeSP <> '0'
            BEGIN
               -- Standard decode
               IF @cDecodeSP = '1'
               BEGIN
                  EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                     @cUPC    = @cUPC     OUTPUT,
                     @nErrNo  = @nErrNo   OUTPUT,
                     @cErrMsg = @cErrMsg  OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit
               END
               -- Custom decode
               ELSE IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM(@cDecodeSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cBarcode, ' +
                     ' @cUPC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                  SET @cSQLParam =
                     ' @nMobile      INT,           ' +
                     ' @nFunc        INT,           ' +
                     ' @cLangCode    NVARCHAR( 3),  ' +
                     ' @nStep        INT,           ' +
                     ' @nInputKey    INT,           ' +
                     ' @cFacility    NVARCHAR( 5),  ' +
                     ' @cStorerKey   NVARCHAR( 15), ' +
                     ' @cStation     NVARCHAR( 10), ' +
                     ' @cMethod      NVARCHAR( 10), ' +
                     ' @cBarcode     NVARCHAR( 60), ' +
                     ' @cUPC         NVARCHAR( 30)  OUTPUT, ' +
                     ' @nErrNo       INT            OUTPUT, ' +
                     ' @cErrMsg      NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cBarcode,
                     @cUPC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit
               END
            END

            -- Get SKU count
            SET @nSKUCnt = 0
            EXEC RDT.rdt_GetSKUCNT
                @cStorerKey  = @cStorerKey
               ,@cSKU        = @cUPC
               ,@nSKUCnt     = @nSKUCnt   OUTPUT
               ,@bSuccess    = @bSuccess  OUTPUT
               ,@nErr        = @nErrNo    OUTPUT
               ,@cErrMsg     = @cErrMsg   OUTPUT

            -- Check SKU valid
            IF @nSKUCnt = 0
            BEGIN
               SET @nErrNo = 99508
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid SKU
               GOTO Quit
            END

            -- Get full SKU if only one match
            IF @nSKUCnt = 1
               EXEC rdt.rdt_GetSKU
                   @cStorerKey  = @cStorerKey
                  ,@cSKU        = @cUPC      OUTPUT
                  ,@bSuccess    = @bSuccess  OUTPUT
                  ,@nErr        = @nErrNo    OUTPUT
                  ,@cErrMsg     = @cErrMsg   OUTPUT

            -- Multi-SKU not supported in this simplified screen
            IF @nSKUCnt > 1
            BEGIN
               SET @nErrNo = 99509
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Multi SKU
               GOTO Quit
            END

            SET @cSKU = @cUPC

            -- ========================================================================
            -- Check if slot needs SortTote before processing
            -- ========================================================================
            DECLARE @cCurrentCartonID NVARCHAR(20)
            DECLARE @cCurrentPosition NVARCHAR(10)
            DECLARE @cCurrentSlotLOC NVARCHAR(10)
            DECLARE @cVirtualCartonID NVARCHAR(20)
            DECLARE @cUserDropID NVARCHAR(20)

            -- Get user's DropID
            -- FCR-13139: ORDER BY EditDate DESC to get the most recently updated record
            SELECT TOP 1 @cUserDropID = DropID
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
            WHERE Station = @cStation
              AND AddWho = @cUserName
              AND UserDefine02 = 'INPROGRESS'
            ORDER BY EditDate DESC

            -- Find slot for the scanned SKU
            SELECT TOP 1
               @cVirtualCartonID = PD.CaseID,
               @cCurrentPosition = L.Position,
               @cCurrentCartonID = L.CartonID
            FROM dbo.PickDetail PD WITH (NOLOCK)
            JOIN rdt.rdtPTLPieceLog L WITH (NOLOCK)
               ON PD.CaseID = L.SourceKey
               AND L.Station = @cStation
               AND L.UserDefine02 = 'INPROGRESS'
               AND L.AddWho = @cUserName
            WHERE PD.StorerKey = @cStorerKey
              AND PD.DropID = @cUserDropID
              AND PD.SKU = @cSKU
              AND PD.Qty > 0
            ORDER BY PD.OrderKey

            -- If slot has no SortTote, go to Screen 6920 (3b) first
            IF @cVirtualCartonID IS NOT NULL AND (@cCurrentCartonID IS NULL OR @cCurrentCartonID = '')
            BEGIN
               -- Get slot LOC and IP for display and light-up
               DECLARE @cCurrentIPAddress NVARCHAR(40)
               SELECT TOP 1 @cCurrentSlotLOC = DP.LOC,
                            @cCurrentIPAddress = DP.IPAddress
               FROM dbo.DeviceProfile DP WITH (NOLOCK)
               WHERE DP.DeviceID = @cStation
                 AND DP.DevicePosition = @cCurrentPosition
                 AND DP.StorerKey = @cStorerKey

               DECLARE @cLightControl NVARCHAR(10)
               SET @cLightControl = rdt.RDTGetConfig(@nFunc, 'LightControl', @cStorerKey)
               -- ========================================================================
               -- FCR-13139 FIX: Light up the destination slot BEFORE going to Screen 6920
               -- This ensures the light turns on when SKU is scanned (first SKU flow)
               -- Call MatrixSP14 directly to reuse all light-up logic (color, qty, model)
               -- ========================================================================
               IF @cLightControl = '1'
               BEGIN
                  DECLARE @cDisplay_6922 NVARCHAR(5)
                  DECLARE @cResult01_6922 NVARCHAR(20)
                  DECLARE @cResult02_6922 NVARCHAR(20)
                  DECLARE @cResult03_6922 NVARCHAR(20)
                  DECLARE @cResult04_6922 NVARCHAR(20)
                  DECLARE @cResult05_6922 NVARCHAR(20)
                  DECLARE @cResult06_6922 NVARCHAR(20)
                  DECLARE @cResult07_6922 NVARCHAR(20)
                  DECLARE @cResult08_6922 NVARCHAR(20)
                  DECLARE @cResult09_6922 NVARCHAR(20)
                  DECLARE @cResult10_6922 NVARCHAR(20)

                  EXEC rdt.rdt_803MatrixSP14
                     @nMobile,
                     @nFunc,
                     @cLangCode,
                     @nCurrentStep,
                     @nInputKey,
                     @cFacility,
                     @cStorerKey,
                     @cLight,
                     @cStation,
                     @cMethod,
                     @cSKU,
                     @cCurrentIPAddress,
                     @cCurrentPosition,
                     @cDisplay_6922,
                     @nErrNo OUTPUT,
                     @cErrMsg OUTPUT,
                     @cResult01_6922 OUTPUT,
                     @cResult02_6922 OUTPUT,
                     @cResult03_6922 OUTPUT,
                     @cResult04_6922 OUTPUT,
                     @cResult05_6922 OUTPUT,
                     @cResult06_6922 OUTPUT,
                     @cResult07_6922 OUTPUT,
                     @cResult08_6922 OUTPUT,
                     @cResult09_6922 OUTPUT,
                     @cResult10_6922 OUTPUT

                  -- Reset error if light-up fails (non-critical)
                  IF @nErrNo <> 0
                  BEGIN
                     SET @nErrNo = 0
                     SET @cErrMsg = ''
                  END
               END

               -- Prepare Screen 6920 (3b)
               SET @cOutField01 = ''                -- TOTE ID input
               SET @cOutField02 = @cCurrentSlotLOC  -- LOC display

               SET @nAfterScn = 6920
               SET @nAfterStep = 99
               GOTO Quit
            END

            -- Call ConfirmSP with Step=99 to process inventory
            EXEC rdt.rdt_PTLPiece_Confirm_Order23
               @nMobile,
               @nFunc,
               @cLangCode,
               99,            -- Step 99 triggers AfterToteAssign label
               @nInputKey,
               @cFacility,
               @cStorerKey,
               @cLight,
               @cStation,
               @cMethod,
               @cSKU,
               @cIPAddress OUTPUT,
               @cPosition OUTPUT,
               @nErrNo OUTPUT,
               @cErrMsg OUTPUT,
               @cResult01 OUTPUT,
               @cResult02 OUTPUT,
               @cResult03 OUTPUT,
               @cResult04 OUTPUT,
               @cResult05 OUTPUT,
               @cResult06 OUTPUT,
               @cResult07 OUTPUT,
               @cResult08 OUTPUT,
               @cResult09 OUTPUT,
               @cResult10 OUTPUT

            IF @nErrNo <> 0
               GOTO Quit

            -- FCR-13139: Check if ConfirmLOC is required
            -- Config: ConfirmLOC = '1' to enable LOC confirmation screen
            DECLARE @cConfirmLOCInput_6922 NVARCHAR(10)
            SET @cConfirmLOCInput_6922 = rdt.RDTGetConfig(@nFunc, 'ConfirmLOC', @cStorerKey)

            IF @cConfirmLOCInput_6922 = '1'
            BEGIN
               -- Get destination LOC for confirmation (use Position from earlier query)
               -- FCR-13139: Include COMPLETE status for last SKU scenario
               DECLARE @cDestLOC_6922 NVARCHAR(10)
               SELECT TOP 1 @cDestLOC_6922 = DP.LOC
               FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
               JOIN dbo.DeviceProfile DP WITH (NOLOCK)
                  ON DP.DeviceID = L.Station
                  AND DP.DevicePosition = L.Position
                  AND DP.StorerKey = @cStorerKey
               WHERE L.Station = @cStation
                 AND L.Position = @cPosition
                 AND L.AddWho = @cUserName
                 AND L.UserDefine02 IN ('INPROGRESS', 'COMPLETE')
               ORDER BY L.EditDate DESC

               -- Prepare Screen 6921 (3c) - Confirm LOC
               SET @cOutField01 = @cDestLOC_6922  -- Destination LOC display
               SET @cOutField02 = ''              -- Confirm LOC input

               -- Store MatrixSP14 results for use after LOC confirmation (saved to MobRec at Quit)
               SET @cSaveResult01 = @cResult01
               SET @cSaveResult02 = @cResult02
               SET @cSaveResult03 = @cResult03
               SET @cSaveResult04 = @cResult04
               -- Save NODROPID flag to return to 6924 after 3c confirmation
               SET @cSaveNODROPID = @cResult10

               SET @nAfterScn = 6921
               SET @nAfterStep = 99
               GOTO Quit
            END

            -- FCR-13139: Check if need to return to DropID screen (SC/ND/PC)
            IF @cResult10 IN ('SC', 'ND', 'PC')
            BEGIN
               SET @nErrNo = CASE @cResult10
                  WHEN 'SC' THEN 274511
                  WHEN 'ND' THEN 274508
                  WHEN 'PC' THEN 274514
                  ELSE 274508
               END
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               -- FCR-13139: Show LOC and TOTE on DropID screen (d03, d04)
               SET @cOutField03 = @cResult01  -- LOC:xxx
               SET @cOutField04 = @cResult02  -- TOTE:xxx
               SET @cOutField11 = ''
               SET @cSaveResult01 = ''
               SET @cSaveResult02 = ''
               SET @cSaveResult03 = ''
               SET @cSaveResult04 = ''
               SET @cSaveNODROPID = ''
               SET @nAfterScn = 6924
               SET @nAfterStep = 2
               GOTO Quit
            END

            -- Prepare next screen var
            SET @cOutField01 = @cResult01
            SET @cOutField02 = @cResult02
            SET @cOutField03 = @cResult03
            SET @cOutField04 = @cResult04
            SET @cOutField11 = ''  -- Clear SKU input

            -- Remain in current screen
            SET @nAfterScn = 6922
            SET @nAfterStep = 99
            GOTO Quit
         END
      END

      -- ========================================================================
      -- Screen 6921 (3c): Confirm LOC
      -- Field01: Destination LOC (output)
      -- Field02: Confirm LOC (input)
      -- NOTE: ESC not allowed, user must scan matching LOC to confirm
      -- ========================================================================
      IF @nCurrentStep = 99 AND @nCurrentScn = 6921
      BEGIN
         -- ESC - Not allowed, must confirm LOC
         IF @nInputKey = 0
         BEGIN
            SET @nErrNo = 274504
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO Quit
         END

         -- ENTER - Validate confirm LOC
         IF @nInputKey = 1
         BEGIN
            DECLARE @cConfirmLOCInputVal NVARCHAR(10)
            SET @cConfirmLOCInputVal = @cInField02

            -- Validate confirm LOC not blank
            IF ISNULL(@cConfirmLOCInputVal, '') = ''
            BEGIN
               SET @nErrNo = 274504
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END

            -- FCR-13139: CheckDigit validation for LOC confirmation
            -- Config: LOCCheckDigitSP = '1' to enable
            DECLARE @cLOCCheckDigitSP_6921 NVARCHAR(20)
            SET @cLOCCheckDigitSP_6921 = rdt.RDTGetConfig(@nFunc, 'LOCCheckDigitSP', @cStorerKey)

            IF @cLOCCheckDigitSP_6921 = '1'
            BEGIN
               EXEC rdt.rdt_LOCLookUp_CheckDigit @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility,
                  @cConfirmLOCInputVal OUTPUT,
                  @nErrNo OUTPUT,
                  @cErrMsg OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  SET @cOutField02 = ''
                  GOTO Quit
               END
            END

            -- Validate confirm LOC matches destination LOC (displayed in OutField01)
            IF @cConfirmLOCInputVal <> @cOutField01
            BEGIN
               SET @nErrNo = 274505
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               SET @cOutField02 = ''
               GOTO Quit
            END

            -- FCR-13139: Check if need to return to DropID screen (SC/ND/PC) after ConfirmLOC
            IF @cSaveNODROPID IN ('SC', 'ND', 'PC')
            BEGIN
               SET @nErrNo = CASE @cSaveNODROPID
                  WHEN 'SC' THEN 274513  -- Listo para packing (ConfirmLOC path)
                  WHEN 'ND' THEN 274510  -- DropID/UCC complete (ConfirmLOC path)
                  WHEN 'PC' THEN 274515  -- Partial complete (ConfirmLOC path)
                  ELSE 274510
               END
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               -- FCR-13139: Show LOC and TOTE on DropID screen (d03, d04)
               -- Use saved values from before entering ConfirmLOC screen
               SET @cOutField03 = @cSaveResult01  -- LOC:xxx
               SET @cOutField04 = @cSaveResult02  -- TOTE:xxx
               SET @cOutField11 = ''
               SET @cSaveResult01 = ''
               SET @cSaveResult02 = ''
               SET @cSaveResult03 = ''
               SET @cSaveResult04 = ''
               SET @cSaveNODROPID = ''
               SET @nAfterScn = 6924
               SET @nAfterStep = 2
               GOTO Quit
            END

            -- Confirmation successful - return to SKU scan screen (6922)
            -- Use saved Result values from C_String (read from MobRec at start)
            SET @cOutField01 = @cSaveResult01
            SET @cOutField02 = @cSaveResult02
            SET @cOutField03 = @cSaveResult03
            SET @cOutField04 = @cSaveResult04
            SET @cOutField11 = ''  -- Clear SKU input
            SET @cSaveNODROPID = ''  -- Clear flag

            SET @nAfterScn = 6922
            SET @nAfterStep = 99
            GOTO Quit
         END
      END
   END

Quit:

   -- Update MobRec with SKU, screen info and output fields
   -- FCR-13139: Also save C_String2/3/4/5/6 for ConfirmLOC screen passthrough and NODROPID flag
   UPDATE rdt.rdtMobRec WITH (ROWLOCK)
   SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      V_SKU = @cSKU,
       Scn =  @nAfterScn,
       Step = @nAfterStep,
       O_Field01 = @cOutField01,
       O_Field02 = @cOutField02,
       O_Field03 = @cOutField03,
       O_Field04 = @cOutField04,
       O_Field05 = @cOutField05,
       O_Field06 = @cOutField06,
       O_Field07 = @cOutField07,
       O_Field08 = @cOutField08,
       O_Field09 = @cOutField09,
       O_Field10 = @cOutField10,
       O_Field11 = @cOutField11,
       O_Field12 = @cOutField12,
       O_Field13 = @cOutField13,
       O_Field14 = @cOutField14,
       O_Field15 = @cOutField15,
       C_String2 = @cSaveResult01,
       C_String3 = @cSaveResult02,
       C_String4 = @cSaveResult03,
       C_String5 = @cSaveNODROPID,
       C_String6 = @cSaveResult04
   WHERE Mobile = @nMobile

   IF @nCurrentStep <> 1
      SET @cUDF01 = 'NO UPD RDTMOBREC'

END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_803ExtScn04 TO NSQL
GO
