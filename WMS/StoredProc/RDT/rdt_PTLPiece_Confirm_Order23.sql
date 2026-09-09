SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_PTLPiece_Confirm_Order23                              */
/* Copyright      : Maersk                                                    */
/* Purpose        : PTW/PTL Sorting Confirmation for AEOMX with:              */
/*                  - Full UCC sort (skip SKU scan)                           */
/*                  - Unit-level SKU sorting with qty transfer                */
/*                  - SortTote capture (tote-to-slot relationship)            */
/*                  - Slot completion and inventory move                       */
/*                  - Double-depth movement for non-ECOM                      */
/*                  - PTL light activation                                    */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 2026-07-06 1.0  Cuize    FCR-13139 Created                                 */
/* 2026-08-20 1.1  Cuize    UWP-64610 Fix Full UCC detection in Screen 6920   */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_PTLPiece_Confirm_Order23] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cLight       NVARCHAR( 1),
   @cStation     NVARCHAR( 10),
   @cMethod      NVARCHAR( 1),
   @cSKU         NVARCHAR( 20),
   @cIPAddress   NVARCHAR( 40) OUTPUT,
   @cPosition    NVARCHAR( 10) OUTPUT,
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR(250) OUTPUT,
   @cResult01    NVARCHAR( 20) OUTPUT,
   @cResult02    NVARCHAR( 20) OUTPUT,
   @cResult03    NVARCHAR( 20) OUTPUT,
   @cResult04    NVARCHAR( 20) OUTPUT,
   @cResult05    NVARCHAR( 20) OUTPUT,
   @cResult06    NVARCHAR( 20) OUTPUT,
   @cResult07    NVARCHAR( 20) OUTPUT,
   @cResult08    NVARCHAR( 20) OUTPUT,
   @cResult09    NVARCHAR( 20) OUTPUT,
   @cResult10    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Variables
   DECLARE @cUserName         NVARCHAR(18)
   DECLARE @cDropID           NVARCHAR(20)
   DECLARE @cVirtualCartonID  NVARCHAR(20)
   DECLARE @cSortToteID       NVARCHAR(20)
   DECLARE @cSlotLOC          NVARCHAR(10)
   DECLARE @cFinalToLOC       NVARCHAR(10)  -- Final destination (front or back)
   DECLARE @cBackLOC          NVARCHAR(10)  -- Back location for double-depth
   DECLARE @bUseBackLOC       BIT           -- Flag: move to back location
   DECLARE @cUserColor        NVARCHAR(20)
   DECLARE @nVirtualCartonCount INT
   DECLARE @bIsFullUCC        BIT
   DECLARE @nUCCQty           INT
   DECLARE @nPDQty            INT
   DECLARE @cPickDetailKey    NVARCHAR(10)
   DECLARE @cOrderKey         NVARCHAR(10)
   DECLARE @nQty              INT
   DECLARE @nRemainingQty     INT
   DECLARE @bSuccess          INT
   DECLARE @nTranCount        INT
   DECLARE @cMoveRefKey       NVARCHAR(10)
   DECLARE @cFromLOC          NVARCHAR(10)
   DECLARE @cFromID           NVARCHAR(18)
   DECLARE @cLOT              NVARCHAR(10)
   DECLARE @cPackKey          NVARCHAR(10)
   DECLARE @cPackUOM3         NVARCHAR(10)

   -- Initialize transaction - unified for all branches (Full UCC and Unit-Level)
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN rdt_PTLPiece_Confirm_Order23

   -- Get user info and current screen from MobRec
   DECLARE @nCurrentScn INT
   SELECT @cUserName = UserName,
          @nCurrentScn = Scn
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get user's assigned color and DropID from rdtPTLPieceLog
   -- FCR-13139: ORDER BY EditDate DESC to get the most recently updated record
   -- This ensures we get the current DropID, not an old one from previous operations
   SELECT TOP 1
      @cUserColor = UserDefine01,
      @cDropID = DropID
   FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
   WHERE Station = @cStation
     AND AddWho = @cUserName
     AND UserDefine02 = 'INPROGRESS'
   ORDER BY EditDate DESC

   -- ========================================================================
   -- SCREEN 6920 (3b): Full UCC SortTote Scan - called from ExtScnSP
   -- ========================================================================
   IF @nCurrentScn = 6920
   BEGIN
      -- UWP-64610: Full UCC detection - must check ALL conditions:
      --   1. DropID exists in UCC.UCCNo
      --   2. Only 1 distinct VirtualCartonID (CaseID) under this DropID
      --   3. PickDetail total Qty = UCC total Qty (no partial processing)
      SET @bIsFullUCC = 0
      IF EXISTS (SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cDropID)
      BEGIN
         SELECT @nUCCQty = ISNULL(SUM(Qty), 0)
         FROM dbo.UCC WITH (NOLOCK)
         WHERE UCCNo = @cDropID
         AND StorerKey = @cStorerKey

         SELECT @nVirtualCartonCount = COUNT(DISTINCT ISNULL(NULLIF(CaseID, ''), @cDropID)),
                @nPDQty = ISNULL(SUM(Qty), 0)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND DropID = @cDropID
           AND Qty > 0

         -- Full UCC: only 1 CaseID AND no partial processing
         IF @nVirtualCartonCount <= 1 AND @nPDQty = @nUCCQty
            SET @bIsFullUCC = 1
      END

      IF @bIsFullUCC = 1
      BEGIN
         -- ========================================================================
         -- FULL UCC: Get virtual carton and jump to Full UCC section
         -- ========================================================================
         SELECT TOP 1 @cVirtualCartonID = CaseID
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND DropID = @cDropID

         -- Get slot info
         SELECT TOP 1
            @cPosition = L.Position,
            @cIPAddress = DP.IPAddress,
            @cSortToteID = L.CartonID,
            @cSlotLOC = DP.LOC
         FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
         JOIN dbo.DeviceProfile DP WITH (NOLOCK)
            ON DP.DeviceID = L.Station
            AND DP.DevicePosition = L.Position
            AND DP.StorerKey = @cStorerKey
         WHERE L.Station = @cStation
           AND L.SourceKey = @cVirtualCartonID
           AND L.UserDefine02 = 'INPROGRESS'
           AND L.AddWho = @cUserName

         GOTO FullUCCSort
      END
      ELSE
      BEGIN
         -- ========================================================================
         -- UNIT-LEVEL: Get SKU info from V_SKU and jump to AfterToteAssign
         -- ========================================================================
         SET @cSKU = (SELECT V_SKU FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile)

         -- Find PickDetail for this SKU
         SELECT TOP 1
            @cPickDetailKey = PD.PickDetailKey,
            @cVirtualCartonID = PD.CaseID,
            @cOrderKey = PD.OrderKey,
            @nQty = PD.Qty,
            @cFromLOC = PD.LOC,
            @cFromID = PD.ID,
            @cLOT = PD.LOT
         FROM dbo.PickDetail PD WITH (NOLOCK)
         JOIN rdt.rdtPTLPieceLog L WITH (NOLOCK)
            ON PD.CaseID = L.SourceKey
            AND L.Station = @cStation
            AND L.UserDefine02 = 'INPROGRESS'
            AND L.AddWho = @cUserName
         WHERE PD.StorerKey = @cStorerKey
           AND PD.DropID = @cDropID
           AND PD.SKU = @cSKU
           AND PD.Qty > 0
         ORDER BY PD.OrderKey

         IF @cPickDetailKey IS NULL
         BEGIN
            SET @nErrNo = 272801
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            GOTO Quit
         END

         -- Get slot info
         SELECT TOP 1
            @cPosition = L.Position,
            @cIPAddress = DP.IPAddress,
            @cSortToteID = L.CartonID,
            @cSlotLOC = DP.LOC
         FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
         JOIN dbo.DeviceProfile DP WITH (NOLOCK)
            ON DP.DeviceID = L.Station
            AND DP.DevicePosition = L.Position
            AND DP.StorerKey = @cStorerKey
         WHERE L.Station = @cStation
           AND L.SourceKey = @cVirtualCartonID
           AND L.UserDefine02 = 'INPROGRESS'
           AND L.AddWho = @cUserName

         -- Get SKU pack info
         SELECT @cPackKey = SKU.PackKey,
                @cPackUOM3 = Pack.PackUOM3
         FROM dbo.SKU WITH (NOLOCK)
         JOIN dbo.Pack WITH (NOLOCK) ON SKU.PackKey = Pack.PackKey
         WHERE SKU.StorerKey = @cStorerKey
           AND SKU.SKU = @cSKU

         SET @bIsFullUCC = 0
         GOTO AfterToteAssign
      END
   END

   -- ========================================================================
   -- SCREEN 6922 (3a): Unit-Level SKU Scan - called from ExtScnSP
   -- ========================================================================
   IF @nCurrentScn = 6922
   BEGIN
      -- Find PickDetail for this SKU in current user's DropID
      SELECT TOP 1
         @cPickDetailKey = PD.PickDetailKey,
         @cVirtualCartonID = PD.CaseID,
         @cOrderKey = PD.OrderKey,
         @nQty = PD.Qty,
         @cFromLOC = PD.LOC,
         @cFromID = PD.ID,
         @cLOT = PD.LOT
      FROM dbo.PickDetail PD WITH (NOLOCK)
      JOIN rdt.rdtPTLPieceLog L WITH (NOLOCK)
         ON PD.CaseID = L.SourceKey
         AND L.Station = @cStation
         AND L.UserDefine02 = 'INPROGRESS'
         AND L.AddWho = @cUserName
      WHERE PD.StorerKey = @cStorerKey
        AND PD.DropID = @cDropID
        AND PD.SKU = @cSKU
        AND PD.Qty > 0
      ORDER BY PD.OrderKey

      IF @cPickDetailKey IS NULL
      BEGIN
         SET @nErrNo = 272802
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END

      -- Get slot info for this user's record
      SELECT TOP 1
         @cPosition = L.Position,
         @cIPAddress = DP.IPAddress,
         @cSortToteID = L.CartonID,
         @cSlotLOC = DP.LOC
      FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
      JOIN dbo.DeviceProfile DP WITH (NOLOCK)
         ON DP.DeviceID = L.Station
         AND DP.DevicePosition = L.Position
         AND DP.StorerKey = @cStorerKey
      WHERE L.Station = @cStation
        AND L.SourceKey = @cVirtualCartonID
        AND L.UserDefine02 = 'INPROGRESS'
        AND L.AddWho = @cUserName

      -- Get SKU pack info for inventory move
      SELECT @cPackKey = SKU.PackKey,
             @cPackUOM3 = Pack.PackUOM3
      FROM dbo.SKU WITH (NOLOCK)
      JOIN dbo.Pack WITH (NOLOCK) ON SKU.PackKey = Pack.PackKey
      WHERE SKU.StorerKey = @cStorerKey
        AND SKU.SKU = @cSKU

      GOTO AfterToteAssign
   END

   /***********************************************************************************************
                                      DETERMINE SORT TYPE
   ***********************************************************************************************/
   -- UWP-64610: Check Full UCC vs Unit Level sorting
   -- Full UCC conditions:
   --   1. @PickDropID exists in UCC.UCCNo
   --   2. Only 1 distinct VirtualCartonID (CaseID) under this DropID
   --   3. PickDetail total Qty = UCC total Qty (no partial processing)
   -- Unit Level: Multiple VirtualCartonIDs OR partial UCC already processed
   SET @bIsFullUCC = 0
   IF EXISTS (SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cDropID)
   BEGIN
      -- Get UCC total qty
      IF @nUCCQty IS NULL
      BEGIN
         SELECT @nUCCQty = ISNULL(SUM(Qty), 0)
         FROM dbo.UCC WITH (NOLOCK)
         WHERE UCCNo = @cDropID
      END

      -- Count distinct VirtualCartonIDs and total PickDetail qty
      SELECT @nVirtualCartonCount = COUNT(DISTINCT ISNULL(NULLIF(CaseID, ''), @cDropID)),
             @nPDQty = ISNULL(SUM(Qty), 0)
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND DropID = @cDropID
        AND Qty > 0

      -- Full UCC: Only 1 VirtualCartonID AND no partial processing
      IF @nVirtualCartonCount <= 1 AND @nPDQty = @nUCCQty
         SET @bIsFullUCC = 1
   END

   /***********************************************************************************************
                                      FULL UCC SORT (Skip SKU Scan)
   ***********************************************************************************************/
FullUCCSort:
   IF @bIsFullUCC = 1
   BEGIN
      -- FCR-13139: Full UCC - VirtualCarton = CaseID (NOT DropID)
      -- Get CaseID from PickDetail if not already set
      IF @cVirtualCartonID IS NULL OR @cVirtualCartonID = ''
      BEGIN
         SELECT TOP 1 @cVirtualCartonID = ISNULL(NULLIF(CaseID, ''), @cDropID)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND DropID = @cDropID
           AND Qty > 0
      END

      -- Get UCC location/ID info
      SELECT TOP 1
         @cFromLOC = U.LOC,
         @cFromID = U.ID
      FROM dbo.UCC U WITH (NOLOCK)
      WHERE U.StorerKey = @cStorerKey
        AND U.UCCNo = @cDropID

      -- Get UCC total qty (for allocated move)
      SELECT @nUCCQty = ISNULL(SUM(Qty), 0)
      FROM dbo.UCC WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND UCCNo = @cDropID
        AND Status IN ('1', '3')  -- Received or Allocated

      -- Get assigned slot for this user (SourceKey = CaseID)
      SELECT TOP 1
         @cPosition = Position,
         @cIPAddress = IPAddress,
         @cSortToteID = CartonID
      FROM rdt.rdtPTLPieceLog WITH (NOLOCK)
      WHERE Station = @cStation
        AND SourceKey = @cVirtualCartonID
        AND UserDefine02 = 'INPROGRESS'
        AND AddWho = @cUserName

      -- Get slot location
      SELECT TOP 1 @cSlotLOC = LOC
      FROM dbo.DeviceProfile WITH (NOLOCK)
      WHERE DeviceID = @cStation
        AND DevicePosition = @cPosition
        AND StorerKey = @cStorerKey

      -- ========================================================================
      -- CHECK: SortTote must be captured first
      -- If no SortTote, quit and let ExtScnSP (Step 2) handle Screen 3b
      -- ========================================================================
      IF @cSortToteID IS NULL OR @cSortToteID = ''
      BEGIN
         GOTO Quit
      END

      -- ========================================================================
      -- FCR-13139: Full UCC Double-depth logic (REVISED)
      -- Always move to FRONT first during scan, same as Unit-Level.
      -- This ensures all UCCs with same CaseID go to same location.
      -- Move to BACK happens at slot completion (nspPTL_ProcessSlotCompletion).
      -- ========================================================================
      SET @cFinalToLOC = @cSlotLOC  -- Always front location during scan
      SET @bUseBackLOC = 0

      -- Get back location config for later use at slot completion
      IF @cStation NOT LIKE '%ECOM%'
      BEGIN
         SELECT TOP 1 @cBackLOC = Short
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'AEO_PTWSTG'
           AND Code = @cSlotLOC
           AND StorerKey = @cStorerKey
      END

      -- ========================================================================
      -- FULL UCC: Move entire UCC using rdt.rdt_Move (reference: rdt_Move_UCC_Confirm)
      -- Default: SingleSKU, MoveQTYAllocated
      -- FCR-13139: No outer transaction - rdt_Move manages its own transaction
      -- ========================================================================
      -- Move entire UCC to final destination (front or back) with SortTote as ToID
      EXEC RDT.rdt_Move
         @nMobile     = @nMobile,
         @cLangCode   = @cLangCode,
         @nErrNo      = @nErrNo OUTPUT,
         @cErrMsg     = @cErrMsg OUTPUT,
         @cSourceType = 'rdt_PTLPiece_Confirm_Order23',
         @cStorerKey  = @cStorerKey,
         @cFacility   = @cFacility,
         @cFromLOC    = @cFromLOC,
         @cToLOC      = @cFinalToLOC,  -- Final destination (front or back)
         @cFromID     = @cFromID,
         @cToID       = @cSortToteID,
         @cSKU        = NULL,          -- Move entire UCC (all SKUs)
         @cUCC        = @cDropID,      -- UCC number
         @nFunc       = @nFunc,
         @nQTYAlloc   = @nUCCQty,      -- MoveQTYAllocated = 1
         @nQTYPick    = 0,
         @cDropID     = @cDropID

      IF @nErrNo <> 0
         GOTO Quit

      -- Update PickDetail.DropID to SortToteID for all relevant entries
      BEGIN TRY
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET DropID = @cSortToteID,
             EditDate = GETDATE(),
             EditWho = SUSER_SNAME()
         WHERE StorerKey = @cStorerKey
           AND DropID = @cDropID
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272817
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UPD DropID Fail (Full UCC)
         GOTO RollBackTran
      END CATCH

      -- ========================================================================
      -- FCR-13139: Full UCC - Update DeviceProfile based on final location
      -- Back: IDLE (slot released), Front: BUSY (slot occupied)
      -- ========================================================================
      IF @bUseBackLOC = 1
      BEGIN
         BEGIN TRY
            UPDATE dbo.DeviceProfile WITH (ROWLOCK)
            SET Status = 'IDLE',
                EditDate = GETDATE(),
                EditWho = SUSER_SNAME()
            WHERE DeviceID = @cStation
              AND DevicePosition = @cPosition
              AND StorerKey = @cStorerKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 272818
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UPD DevProf Fail (Full UCC)
            GOTO RollBackTran
         END CATCH

         SET @cResult03 = 'Listo para packing'
      END
      ELSE
      BEGIN
         SET @cResult03 = 'Listo para packing'
      END

      -- FCR-13139: Full UCC done - use unified Slot Completion logic
      -- Same rule for Full UCC and Unit-Level:
      -- COMPLETE when ALL PickDetails for this CaseID are sorted to SortTote
      SET @cResult10 = 'ND'
      GOTO SlotCompletion
   END

   /***********************************************************************************************
                                      UNIT-LEVEL SORT (SKU by SKU)
   ***********************************************************************************************/
   -- ========================================================================
   -- FIND: Match SKU to this user's INPROGRESS slot
   -- Each user has their own rdtPTLPieceLog record
   -- ========================================================================
   SELECT TOP 1
      @cPickDetailKey = PD.PickDetailKey,
      @cVirtualCartonID = PD.CaseID,
      @cOrderKey = PD.OrderKey,
      @nQty = PD.Qty,
      @cFromLOC = PD.LOC,
      @cFromID = PD.ID,
      @cLOT = PD.LOT,
      @cPosition = L.Position,
      @cSortToteID = L.CartonID
   FROM dbo.PickDetail PD WITH (NOLOCK)
   JOIN rdt.rdtPTLPieceLog L WITH (NOLOCK)
      ON PD.CaseID = L.SourceKey
      AND L.Station = @cStation
      AND L.UserDefine02 = 'INPROGRESS'
      AND L.AddWho = @cUserName
   WHERE PD.StorerKey = @cStorerKey
     AND PD.DropID = @cDropID
     AND PD.SKU = @cSKU
     AND PD.Qty > 0
     AND PD.status = '3'
   ORDER BY PD.OrderKey

   IF @cPickDetailKey IS NULL
   BEGIN
      SET @nErrNo = 272804
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- No slot for SKU
      GOTO Quit
   END

   -- ========================================================================
   -- CHECK: SortTote must be captured first
   -- If no SortTote, quit and let ExtScnSP (Step 3) handle Screen 3b
   -- ========================================================================
   IF @cSortToteID IS NULL OR @cSortToteID = ''
   BEGIN
      GOTO Quit
   END

   -- Get SKU pack info for inventory move
   SELECT @cPackKey = SKU.PackKey,
          @cPackUOM3 = Pack.PackUOM3
   FROM dbo.SKU WITH (NOLOCK)
   JOIN dbo.Pack WITH (NOLOCK) ON SKU.PackKey = Pack.PackKey
   WHERE SKU.StorerKey = @cStorerKey
     AND SKU.SKU = @cSKU

   -- Get remaining slot info (IPAddress, SlotLOC) for this user
   SELECT TOP 1
      @cIPAddress = DP.IPAddress,
      @cSlotLOC = DP.LOC
   FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
   JOIN dbo.DeviceProfile DP WITH (NOLOCK)
      ON DP.DeviceID = L.Station
      AND DP.DevicePosition = L.Position
      AND DP.StorerKey = @cStorerKey
   WHERE L.Station = @cStation
     AND L.SourceKey = @cVirtualCartonID
     AND L.UserDefine02 = 'INPROGRESS'
     AND L.AddWho = @cUserName

   -- ========================================================================
   -- AfterToteAssign: Entry point from ExtScnSP after SortTote assignment
   -- When Step=99, we jump here directly after getting slot info
   -- ========================================================================
AfterToteAssign:

   -- ========================================================================
   -- FCR-13139: Double-depth logic (REVISED)
   -- Always move to FRONT first during scan. Move to BACK at slot completion.
   -- ========================================================================
   SET @cFinalToLOC = @cSlotLOC  -- Always front location during scan
   SET @bUseBackLOC = 0

   -- Get back location config for later use at slot completion
   IF @cStation NOT LIKE '%ECOM%'
   BEGIN
      SELECT TOP 1 @cBackLOC = Short
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE ListName = 'AEO_PTWSTG'
        AND Code = @cSlotLOC
        AND StorerKey = @cStorerKey
   END

   -- ========================================================================
   -- PICKDETAIL QTY TRANSFER using rdt_Move_PickDetail + nspItrnAddMove
   -- Transaction already started at SP entry point
   -- ========================================================================

   -- Variables for rdt_Move_PickDetail
   DECLARE @nLLI_QTY INT
   DECLARE @nLLI_Alloc INT
   DECLARE @nLLI_Pick INT = 0
   DECLARE @nPD_Alloc INT = 0
   DECLARE @nPD_Pick INT = 0

   -- Get LotxLocxID qty info
   SELECT @nLLI_QTY = Qty, @nLLI_Alloc = QtyAllocated
   FROM dbo.LotxLocxID WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
     AND SKU = @cSKU
     AND LOC = @cFromLOC
     AND ID = @cFromID
     AND LOT = @cLOT

   -- Block same-location move to prevent qty discrepancy
   IF (@cFromLOC = @cFinalToLOC) AND (@cFromID = @cSortToteID)
   BEGIN
      SET @nErrNo = 272827
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Same LOC ID
      GOTO RollBackTran
   END

   IF EXISTS (SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceID = @cStation AND LOC = @cFromLOC AND StorerKey = @cStorerKey)
   BEGIN
      SET @nErrNo = 272820
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Can not move from PTLSlot
      GOTO RollBackTran
   END

   -- Step 1: rdt_Move_PickDetail - Split PickDetail and stamp MoveRefKey
   EXEC rdt.rdt_Move_PickDetail
      @nMobile       = @nMobile,
      @nFunc         = @nFunc,
      @cLangCode     = @cLangCode,
      @cStorerKey    = @cStorerKey,
      @cFacility     = @cFacility,
      @cMoveQTYAlloc = '1',
      @cMoveQTYPick  = '0',
      @cLOT          = @cLOT,
      @cLOC          = @cFromLOC,
      @cID           = @cFromID,
      @cToLOC        = @cFinalToLOC,
      @cToID         = @cSortToteID,
      @cSKU          = @cSKU,
      @cUCC          = NULL,
      @nBal_Avail    = 0,
      @nBal_Alloc    = 1,    -- Move 1 qty
      @nBal_Pick     = 0,
      @nLLI_QTY      = @nLLI_QTY,
      @nLLI_Alloc    = @nLLI_Alloc,
      @nLLI_Pick     = @nLLI_Pick,
      @nPD_Alloc     = @nPD_Alloc OUTPUT,
      @nPD_Pick      = @nPD_Pick OUTPUT,
      @cMoveRefKey   = @cMoveRefKey OUTPUT,
      @nErrNo        = @nErrNo OUTPUT,
      @cErrMsg       = @cErrMsg OUTPUT,
      @cTaskDetailKey = '',
      @cOrderKey     = @cOrderKey,
      @cDropID       = @cDropID
      --@cCaseID       = @cVirtualCartonID

   IF @nErrNo <> 0
   BEGIN
      SET @nErrNo = 272805
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Move_PickDetail Fail
      GOTO RollBackTran
   END

   -- Step 2: Update PickDetail.DropID for the moved record (use PickDetailKey, not MoveRefKey)
   BEGIN TRY
      UPDATE dbo.PickDetail WITH (ROWLOCK)
      SET DropID = @cSortToteID,
          EditDate = GETDATE(),
          EditWho = SUSER_SNAME()
      WHERE PickDetailKey = @cPickDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272806
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
      GOTO RollBackTran
   END CATCH

   -- Step 3: Move LOTxLOCxID inventory to final destination (front or back)
   BEGIN TRY
      EXEC dbo.nspItrnAddMove
         @n_ItrnSysId     = NULL,
         @c_StorerKey     = @cStorerKey,
         @c_Sku           = @cSKU,
         @c_Lot           = @cLOT,
         @c_FromLoc       = @cFromLOC,
         @c_FromID        = @cFromID,
         @c_ToLoc         = @cFinalToLOC,  -- Final destination (front or back)
         @c_ToID          = @cSortToteID,
         @c_Status        = '',
         @c_lottable01    = '',
         @c_lottable02    = '',
         @c_lottable03    = '',
         @d_lottable04    = '',
         @d_lottable05    = '',
         @n_casecnt       = 0,
         @n_innerpack     = 0,
         @n_qty           = 1,
         @n_pallet        = 0,
         @f_cube          = 0,
         @f_grosswgt      = 0,
         @f_netwgt        = 0,
         @f_otherunit1    = 0,
         @f_otherunit2    = 0,
         @c_SourceKey     = '',
         @c_SourceType    = 'rdt_PTLPiece_Confirm_Order23',
         @c_PackKey       = @cPackKey,
         @c_UOM           = @cPackUOM3,
         @b_UOMCalc       = 1,
         @d_EffectiveDate = '',
         @c_itrnkey       = '',
         @b_Success       = @bSuccess OUTPUT,
         @n_err           = @nErrNo OUTPUT,
         @c_errmsg        = @cErrMsg OUTPUT,
         @c_MoveRefKey    = @cMoveRefKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272813
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Inv Move Fail
      GOTO RollBackTran
   END CATCH

   IF @nErrNo <> 0
   BEGIN
      GOTO RollBackTran
   END

   -- ========================================================================
   -- PICKDETAIL MERGE: Consolidate records in same SortTote
   -- Match criteria: same CaseID, OrderKey, OrderLineNumber, SKU, LOT, UOM, DropID
   -- FCR-13139: Added LOT and UOM to prevent merging different lots or UOM types
   -- ========================================================================
   DECLARE @cExistingPDKey NVARCHAR(10)
   DECLARE @cCurrentPDQty INT
   SET @cExistingPDKey = NULL

   -- Find existing record in SortTote with same CaseID/OrderKey/OrderLineNumber/SKU/LOT/UOM
   SELECT TOP 1 @cExistingPDKey = E.PickDetailKey,
                @cCurrentPDQty = C.qty
   FROM dbo.PickDetail C WITH (NOLOCK)
   JOIN dbo.PickDetail E WITH (NOLOCK)
      ON E.StorerKey = C.StorerKey
     AND E.CaseID = C.CaseID
     AND E.OrderKey = C.OrderKey
     AND E.OrderLineNumber = C.OrderLineNumber
     AND E.SKU = C.SKU
     AND E.LOT = C.LOT
     AND E.UOM = C.UOM
     AND E.DropID = C.DropID
     AND E.PickDetailKey <> C.PickDetailKey
     AND E.Qty > 0
   WHERE C.PickDetailKey = @cPickDetailKey
     AND C.status = '3'
     AND E.status = '3'

   IF ISNULL (@cCurrentPDQty,0) > 1
   BEGIN
      SET @nErrNo = 272821
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
      GOTO RollBackTran
   END

   --Merge pickdetail with same SKU LOT DROPID
   IF @cExistingPDKey IS NOT NULL
   BEGIN
      -- Merge: increment existing record qty
      BEGIN TRY
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET Qty = Qty + 1,
             TrafficCop = NULL,
             EditDate = GETDATE(),
             EditWho = SUSER_SNAME()
         WHERE PickDetailKey = @cExistingPDKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272807
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Merge Qty Fail
         GOTO RollBackTran
      END CATCH

      -- Delete RefKeyLookup for current record
      BEGIN TRY
         DELETE FROM dbo.RefKeyLookup WHERE PickDetailKey = @cPickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272822
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Del RefKey Fail
         GOTO RollBackTran
      END CATCH

      -- Delete current record (merged into existing)
      -- First set Qty=0 with TrafficCop=NULL to avoid trigger QtyAllocated adjustment
      BEGIN TRY
         UPDATE dbo.PickDetail WITH (ROWLOCK)
         SET Qty = 0, TrafficCop = NULL
         WHERE PickDetailKey = @cPickDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272823
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Upd PD Qty Fail
         GOTO RollBackTran
      END CATCH

      -- Then delete the record
      BEGIN TRY
         DELETE FROM dbo.PickDetail
         WHERE PickDetailKey = @cPickDetailKey AND QTY = 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272808
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Merge Del Fail
         GOTO RollBackTran
      END CATCH
   END

   -- Delete source Qty=0 records if any
   BEGIN TRY
      DELETE FROM dbo.RefKeyLookup
      WHERE PickDetailKey IN (
         SELECT PickDetailKey FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND CaseID = @cVirtualCartonID
           AND SKU = @cSKU
           AND DropID = @cDropID
           AND Qty = 0
      )
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272824
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Del RefKey0 Fail
      GOTO RollBackTran
   END CATCH

   BEGIN TRY
      DELETE FROM dbo.PickDetail
      WHERE StorerKey = @cStorerKey
        AND CaseID = @cVirtualCartonID
        AND SKU = @cSKU
        AND DropID = @cDropID
        AND Qty = 0
        AND TrafficCop IS NULL
   END TRY
   BEGIN CATCH
      SET @nErrNo = 272825
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Del PD Qty0 Fail
      GOTO RollBackTran
   END CATCH

   -- Transaction will be committed at Quit label

   -- Calculate remaining qty for PTL display
   SELECT @nRemainingQty = SUM(Qty)
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
     AND DropID = @cDropID
     AND CaseID = @cVirtualCartonID
     AND SKU = @cSKU

   -- FCR-13139: PTL light is triggered in MatrixSP14, not here

   /***********************************************************************************************
                                      SLOT COMPLETION CHECK
   ***********************************************************************************************/
SlotCompletion:

   -- ========================================================================
   -- SLOT COMPLETION: Check if ALL inventory for this VirtualCarton is sorted
   -- FCR: "contains all inventory required according to the virtual carton"
   -- Inventory is already moved during each SKU scan, no need to move again
   -- Note: ISNULL handles NULL DropID (unsorted items) - they should block completion
   -- ========================================================================
   IF NOT EXISTS (
      SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND CaseID = @cVirtualCartonID
        AND ISNULL(DropID, '') <> @cSortToteID
        AND Qty > 0
   )
   BEGIN
      -- Mark ALL users' records as COMPLETE for this slot
      BEGIN TRY
         UPDATE rdt.rdtPTLPieceLog WITH (ROWLOCK)
         SET UserDefine02 = 'COMPLETE',
             UserDefine01 = '',
             EditDate = GETDATE(),
             EditWho = SUSER_SNAME()
         WHERE Station = @cStation
           AND SourceKey = @cVirtualCartonID
      END TRY
      BEGIN CATCH
         SET @nErrNo = 272814
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         GOTO RollBackTran
      END CATCH

      -- ========================================================================
      -- FCR-13139: Double-depth movement at SLOT COMPLETION
      -- non-ECOM: Check if back (STG PTW) is empty, if so move inventory to back
      -- ========================================================================
      IF @cStation NOT LIKE '%ECOM%' AND @cBackLOC IS NOT NULL AND @cBackLOC <> ''
      BEGIN
         -- Check if STG PTW (back location) is empty
         IF NOT EXISTS (
            SELECT 1 FROM dbo.LotxLocxID WITH (NOLOCK)
            WHERE LOC = @cBackLOC
              AND Qty > 0
         )
         BEGIN
            -- STG PTW is empty: Move inventory from front to back using rdt_Move
            SET @bUseBackLOC = 1

            -- Get total QtyAllocated in front location for this SortTote
            DECLARE @nFrontQtyAllocUnit INT = 0
            SELECT @nFrontQtyAllocUnit = ISNULL(SUM(QtyAllocated), 0)
            FROM dbo.LotxLocxID WITH (NOLOCK)
            WHERE LOC = @cSlotLOC
              AND ID = @cSortToteID

            EXEC RDT.rdt_Move
               @nMobile     = @nMobile,
               @cLangCode   = @cLangCode,
               @nErrNo      = @nErrNo OUTPUT,
               @cErrMsg     = @cErrMsg OUTPUT,
               @cSourceType = 'rdt_PTLPiece_Confirm_Order23',
               @cStorerKey  = @cStorerKey,
               @cFacility   = @cFacility,
               @cFromLOC    = @cSlotLOC,      -- Front location
               @cToLOC      = @cBackLOC,      -- Back location (STG PTW)
               @cFromID     = @cSortToteID,
               @cToID       = @cSortToteID,   -- Same tote ID
               @cSKU        = NULL,           -- Move all SKUs
               @cUCC        = NULL,
               @nFunc       = @nFunc,
               @nQTYAlloc   = @nFrontQtyAllocUnit,
               @nQTYPick    = 0,
               @cDropID     = @cSortToteID

            IF @nErrNo <> 0
            BEGIN
               -- Double-depth move failed, but slot complete is still valid
               SET @nErrNo = 0
               SET @cErrMsg = ''
               SET @bUseBackLOC = 0
            END
            ELSE
            BEGIN
               -- Release front slot to IDLE
               BEGIN TRY
                  UPDATE dbo.DeviceProfile WITH (ROWLOCK)
                  SET Status = 'IDLE',
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
                  WHERE DeviceID = @cStation
                    AND DevicePosition = @cPosition
                    AND StorerKey = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 272819
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UPD DevProf Fail (Double-depth)
                  GOTO RollBackTran
               END CATCH

               SET @cResult03 = 'Listo para packing'
            END
         END
         ELSE
         BEGIN
            -- STG PTW occupied: Stay in front, status BUSY
            SET @bUseBackLOC = 0
            SET @cResult03 = 'Listo para packing'
         END
      END
      ELSE IF @cStation NOT LIKE '%ECOM%' AND (@cBackLOC IS NULL OR @cBackLOC = '')
      BEGIN
         -- No STG PTW configured
         SET @cResult03 = 'Listo para packing. STG PTW no existe'
      END
      ELSE
      BEGIN
         -- ECOM: Status stays BUSY, no double-depth
         SET @cResult03 = 'Listo para packing'
      END

      -- FCR-13139: Packer light is triggered in MatrixSP14, not here
   END

   -- ========================================================================
   -- CHECK: Does current DropID have more unsorted PickDetails?
   -- FCR-13139: Check by DropID, not by INPROGRESS slot count
   -- A DropID is complete when all its PickDetails have been moved to SortTote
   -- (DropID changed from original to SortToteID)
   -- ========================================================================
   -- FCR-13139: Result10 codes for ExtScn04:
   --   ND = DropID complete, return to DropID scan screen
   --   SC = Slot complete (all VCs for this slot done)
   --   PC = Partial complete (DropID has more VCs without slot assignment)
   --   (empty) = Continue scanning SKUs for this DropID

   -- Check if current DropID still has unsorted PickDetails
   IF NOT EXISTS (
      SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
        AND DropID = @cDropID
        AND Qty > 0
   )
   BEGIN
      -- DropID complete - all PickDetails have been moved to SortTote
      SET @cResult10 = 'ND'

      -- FCR-13139: If slot complete also happened, use SC instead
      IF @cResult03 = 'Listo para packing' OR @cResult03 LIKE 'Listo para packing%'
      BEGIN
         SET @cResult10 = 'SC'
      END
   END
   ELSE
   BEGIN
      -- DropID still has unsorted items, check if they have slot assignment
      -- PC = DropID has VCs without slot (need to assign slot first)
      IF EXISTS (
         SELECT 1 FROM dbo.PickDetail PD WITH (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
           AND PD.DropID = @cDropID
           AND PD.Qty > 0
           AND NOT EXISTS (
               SELECT 1 FROM rdt.rdtPTLPieceLog L WITH (NOLOCK)
               WHERE L.Station = @cStation
                 AND L.SourceKey = PD.CaseID
                 AND L.UserDefine02 = 'INPROGRESS'
                 AND L.AddWho = @cUserName
           )
      )
      BEGIN
         SET @cResult10 = 'PC'
      END
      -- ELSE: Continue scanning SKUs (Result10 stays empty or unchanged)
   END

   -- Draw matrix (and light up)

   DrawMatrix:
   DECLARE @cDisplay NVARCHAR(5)
   EXEC rdt.rdt_PTLPiece_Matrix @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
      ,@cLight
      ,@cStation
      ,@cMethod
      ,@cSKU
      ,@cIPAddress
      ,@cPosition
      ,@cDisplay
      ,@nErrNo     OUTPUT
      ,@cErrMsg    OUTPUT
      ,@cResult01  OUTPUT
      ,@cResult02  OUTPUT
      ,@cResult03  OUTPUT
      ,@cResult04  OUTPUT
      ,@cResult05  OUTPUT
      ,@cResult06  OUTPUT
      ,@cResult07  OUTPUT
      ,@cResult08  OUTPUT
      ,@cResult09  OUTPUT
      ,@cResult10  OUTPUT

   -- ========================================================================
   -- FCR-13139: Cleanup DROPIDDETAIL when DropID sorting is complete
   -- Reuse DropID for next wave (independent of slot completion)
   -- Config: ReuseDropID = '1' to enable
   -- ========================================================================
   DECLARE @cReuseDropID NVARCHAR(1)
   SET @cReuseDropID = rdt.RDTGetConfig(@nFunc, 'ReuseDropID', @cStorerKey)

   IF @cReuseDropID = '1'
   BEGIN
      -- Only cleanup if NO PickDetails remain with this DropID (all moved to SortTote)
      -- PTL sorting changes DropID from original to SortToteID, so check if any remain
      IF NOT EXISTS (
         SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)
         WHERE DropID = @cDropID
           AND Qty > 0
      )
      BEGIN
         DECLARE @cParentDropID NVARCHAR(20)

         -- Get parent DropID from DROPIDDETAIL (ChildID = scanned DropID)
         SELECT @cParentDropID = DropID
         FROM dbo.DROPIDDETAIL WITH (NOLOCK)
         WHERE ChildID = @cDropID

         -- Delete child from DROPIDDETAIL
         IF @cParentDropID IS NOT NULL
         BEGIN
            BEGIN TRY
               DELETE FROM dbo.DROPIDDETAIL WITH (ROWLOCK)
               WHERE ChildID = @cDropID

               -- If no more children, delete parent DROPID
               IF NOT EXISTS (SELECT 1 FROM dbo.DROPIDDETAIL WITH (NOLOCK) WHERE DropID = @cParentDropID)
                  DELETE FROM dbo.DROPID WITH (ROWLOCK) WHERE DropID = @cParentDropID
            END TRY
            BEGIN CATCH
               -- ReuseDropID cleanup failed - not critical, log but don't fail transaction
               SET @nErrNo = 0
               SET @cErrMsg = ''
            END CATCH
         END
      END
   END

   GOTO Quit

RollBackTran:
   -- FCR-13139: Use @@TRANCOUNT check instead of direct named rollback
   IF @@TRANCOUNT > @nTranCount
      ROLLBACK TRAN rdt_PTLPiece_Confirm_Order23

Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

   IF @nErrNo = 272827
   BEGIN
      -- Debug: Log same-location move details after rollback (ignore failures)
      BEGIN TRY
         INSERT INTO dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Step3, Step4, Step5, Col1, Col2, Col3)
         VALUES ('rdt_PTLPiece_Confirm_Order23', GETDATE(), @cPickDetailKey, @cSKU, @cLOT, @cFromID, @cDropID, @cFromLOC, @cFinalToLOC, @cSortToteID)
      END TRY
      BEGIN CATCH
         -- Ignore TraceInfo insert failures
      END CATCH
   END

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_PTLPiece_Confirm_Order23 TO NSQL
GO
