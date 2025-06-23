SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_1770SwapID05                                      */
/* Copyright      : Maersk WMS                                            */
/* Customer       : BRF BRASIL FOODS SA                                   */
/*                                                                        */
/* Purpose: Swap ID base on same LOC, SKU, QTY, Lottables                 */
/*                                                                        */
/* Date        Rev    Author      Purposes                                */
/* 2025-04-08  1.0    NLT03       FCR-3836 Create                         */
/* 2025-04-15  1.0.1  NLT03       FCR-3836 Remove useless validation      */
/* 2025-04-15  1.0.2  NLT03       FCR-3836 Handle VNAOUT RPF task         */
/**************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1770SwapID05
   @nMobile           INT,
   @nFunc             INT,
   @cLangCode         NVARCHAR( 3),
   @cTaskDetailKey    NVARCHAR( 10),
   @cNewID            NVARCHAR( 18),
   @cNewTaskDetailKey NVARCHAR( 10) OUTPUT,
   @nErrNo            INT           OUTPUT,
   @cErrMsg           NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount      INT

   DECLARE @cOtherPickDetailKey NVARCHAR(10)
   DECLARE @cOtherTaskDetailKey NVARCHAR(10)
   DECLARE @cTaskPickDetailKey  NVARCHAR(10)
   
   DECLARE @cNewSKU        NVARCHAR( 20)
   DECLARE @cNewLOT        NVARCHAR( 10)
   DECLARE @cNewLOC        NVARCHAR( 10)
   DECLARE @cNewTaskType    NVARCHAR( 10)
   DECLARE @cNewPickMethod NVARCHAR( 10)
   DECLARE @nNewQTY        INT

   DECLARE @cRPFTaskFromLoc   NVARCHAR( 10)
   DECLARE @cRPFTaskToLoc     NVARCHAR( 10)

   DECLARE @cPickDetailKey NVARCHAR(10)
   DECLARE @cStorerKey     NVARCHAR( 15)
   DECLARE @cTaskKey       NVARCHAR( 10)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cTaskSKU       NVARCHAR( 20)
   DECLARE @cTaskLOT       NVARCHAR( 10)
   DECLARE @cTaskLOC       NVARCHAR( 10)
   DECLARE @cTaskID        NVARCHAR( 18)
   DECLARE @cIDStatus      NVARCHAR( 10)
   DECLARE @nTaskQTY       INT
   DECLARE @nQTY           INT
   DECLARE @nIDQTY         INT
   DECLARE @cLottableCompare     NVARCHAR( MAX) = ''
   DECLARE @cTaskLocationType    NVARCHAR( 10)
   DECLARE @cLocationType        NVARCHAR( 10)
   DECLARE @cLotMatch            NVARCHAR( 1) = '0'

   DECLARE
      @cChkL01 NVARCHAR(1) = '0', @cChkL02 NVARCHAR(1) = '0', @cChkL03 NVARCHAR(1) = '0', @cChkL04 NVARCHAR(1) = '0', @cChkL05 NVARCHAR(1) = '0', 
      @cChkL06 NVARCHAR(1) = '0', @cChkL07 NVARCHAR(1) = '0', @cChkL08 NVARCHAR(1) = '0', @cChkL09 NVARCHAR(1) = '0', @cChkL10 NVARCHAR(1) = '0', 
      @cChkL11 NVARCHAR(1) = '0', @cChkL12 NVARCHAR(1) = '0', @cChkL13 NVARCHAR(1) = '0', @cChkL14 NVARCHAR(1) = '0', @cChkL15 NVARCHAR(1) = '0'

   -- Check blank
   IF @cNewID = ''
   BEGIN
      SET @nErrNo = 236001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ID
      RETURN
   END

   -- Check if ID is on HOLD
   SELECT 
      @cIDStatus = Status
   FROM dbo.ID WITH(NOLOCK)
   WHERE ID = @cNewID

   IF @cIDStatus = 'HOLD'
   BEGIN
      SET @nErrNo = 236041
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IDIsOnHold
      RETURN
   END

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Get check lottable setting
   SELECT
      @cChkL01 = CASE WHEN Code = 'Lottable01' THEN '1' ELSE @cChkL01 END,
      @cChkL02 = CASE WHEN Code = 'Lottable02' THEN '1' ELSE @cChkL02 END,
      @cChkL03 = CASE WHEN Code = 'Lottable03' THEN '1' ELSE @cChkL03 END,
      @cChkL04 = CASE WHEN Code = 'Lottable04' THEN '1' ELSE @cChkL04 END,
      @cChkL05 = CASE WHEN Code = 'Lottable05' THEN '1' ELSE @cChkL05 END,
      @cChkL06 = CASE WHEN Code = 'Lottable06' THEN '1' ELSE @cChkL06 END,
      @cChkL07 = CASE WHEN Code = 'Lottable07' THEN '1' ELSE @cChkL07 END,
      @cChkL08 = CASE WHEN Code = 'Lottable08' THEN '1' ELSE @cChkL08 END,
      @cChkL09 = CASE WHEN Code = 'Lottable09' THEN '1' ELSE @cChkL09 END,
      @cChkL10 = CASE WHEN Code = 'Lottable10' THEN '1' ELSE @cChkL10 END,
      @cChkL11 = CASE WHEN Code = 'Lottable11' THEN '1' ELSE @cChkL11 END,
      @cChkL12 = CASE WHEN Code = 'Lottable12' THEN '1' ELSE @cChkL12 END,
      @cChkL13 = CASE WHEN Code = 'Lottable13' THEN '1' ELSE @cChkL13 END,
      @cChkL14 = CASE WHEN Code = 'Lottable14' THEN '1' ELSE @cChkL14 END,
      @cChkL15 = CASE WHEN Code = 'Lottable15' THEN '1' ELSE @cChkL15 END,
      @cLocationType = UDF01
   FROM dbo.CodeLKUP WITH (NOLOCK)
   WHERE ListName = 'SwapID'
      AND StorerKey = @cStorerKey
      AND Code2 = @nFunc

   -- Get task info
   SELECT
      @cStorerKey = TD.StorerKey, 
      @cTaskType = TD.TaskType, 
      @cTaskSKU = TD.SKU, 
      @cTaskLOT = TD.LOT,
      @cTaskLOC = TD.FromLOC,
      @cTaskID = TD.FromID, 
      @nTaskQTY = TD.SystemQTY,
      @cTaskPickDetailKey = PickDetailKey,
      @cTaskLocationType = LOC.LocationHandling
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
   WHERE TD.StorerKey = @cStorerKey
      AND TD.TaskDetailKey = @cTaskDetailKey

   SET @nRowCount = @@ROWCOUNT 

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 236002
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
      RETURN
   END

   IF @cLocationType IS NOT NULL AND @cLocationType <> '' AND @cTaskLocationType <> @cLocationType
   BEGIN
      SET @nErrNo = 236019
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Racking Type Not Match
      RETURN
   END

   -- Get old ID Qty
   SELECT
      @nIDQTY = QTY - QTYPicked
   FROM dbo.LOTxLOCxID WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND ID = @cTaskID
      AND QTY - QTYPicked > 0

   -- Get new ID info
   SELECT
      @cNewSKU = LLI.SKU,
      @nNewQTY = LLI.QTY - LLI.QTYPicked,
      @cNewLOT = LLI.LOT,
      @cNewLOC = LLI.LOC
   FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
   INNER JOIN dbo.LOC WITH (NOLOCK) ON LOC.LOC = LLI.LOC
   WHERE LLI.StorerKey = @cStorerKey
      AND LLI.ID = @cNewID
      AND LLI.QTY - LLI.QTYPicked > 0

   SET @nRowCount = @@ROWCOUNT 

   -- Check ID valid
   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 236003
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID
      RETURN
   END

   -- Check ID multi LOC/LOT
   IF @nRowCount > 1
   BEGIN
      SET @nErrNo = 236004
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID multi rec
      RETURN
   END

   -- Check LOC match
   IF @cNewLOC <> @cTaskLOC
   BEGIN
      SET @nErrNo = 236005
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC not match
      RETURN
   END

   -- Check SKU match
   IF @cNewSKU <> @cTaskSKU
   BEGIN
      SET @nErrNo = 236006
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not match
      RETURN
   END

   -- Check QTY match
   IF @nNewQTY <> @nTaskQTY
   BEGIN
      SET @nErrNo = 236007
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY not match
      RETURN
   END

   DECLARE @cTaskLottableValue                  NVARCHAR( 30) = ''
   DECLARE @dtTaskLottableValue                 DATETIME = ''
   DECLARE @cScannedPalletLottableValue         NVARCHAR( 30) = ''
   DECLARE @dtScannedPalletTaskLottableValue    DATETIME = ''

   IF ISNULL(@cChkL01, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable01 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable01 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236020
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot01NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL02, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable02 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable02 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236021
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot02NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL03, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable03 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable03 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236022
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot03NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL04, '') = '1' 
   BEGIN
      SET @dtTaskLottableValue = '1990-01-01'
      SET @dtScannedPalletTaskLottableValue = '1990-01-01'
      SELECT @dtTaskLottableValue = Lottable04 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @dtScannedPalletTaskLottableValue = Lottable04 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF ISNULL(@dtTaskLottableValue, '1990-01-01') <> ISNULL(@dtScannedPalletTaskLottableValue, '1990-01-01')
      BEGIN
         SET @nErrNo = 236023
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot04NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL05, '') = '1' 
   BEGIN
      SET @dtTaskLottableValue = '1990-01-01'
      SET @dtScannedPalletTaskLottableValue = '1990-01-01'
      SELECT @dtTaskLottableValue = Lottable05 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @dtScannedPalletTaskLottableValue = Lottable05 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF ISNULL(@dtTaskLottableValue, '1990-01-01') <> ISNULL(@dtScannedPalletTaskLottableValue, '1990-01-01')
      BEGIN
         SET @nErrNo = 236024
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot05NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL06, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable06 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable06 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236025
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot06NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL07, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable07 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable07 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236026
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot07NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL08, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable08 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable08 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236027
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot08NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL09, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable09 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable09 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236028
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot09NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL10, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable10 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable10 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236029
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot10NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL11, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable11 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable11 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236030
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot11NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL12, '') = '1' 
   BEGIN
      SET @cTaskLottableValue = ''
      SET @cScannedPalletLottableValue = ''
      SELECT @cTaskLottableValue = Lottable12 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @cScannedPalletLottableValue = Lottable12 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF @cTaskLottableValue <> @cScannedPalletLottableValue
      BEGIN
         SET @nErrNo = 236031
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot12NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL13, '') = '1' 
   BEGIN
      SET @dtTaskLottableValue = '1990-01-01'
      SET @dtScannedPalletTaskLottableValue = '1990-01-01'
      SELECT @dtTaskLottableValue = Lottable13 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @dtScannedPalletTaskLottableValue = Lottable13 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF ISNULL(@dtTaskLottableValue, '1990-01-01') <> ISNULL(@dtScannedPalletTaskLottableValue, '1990-01-01')
      BEGIN
         SET @nErrNo = 236032
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot13NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL14, '') = '1' 
   BEGIN
      SET @dtTaskLottableValue = '1990-01-01'
      SET @dtScannedPalletTaskLottableValue = '1990-01-01'
      SELECT @dtTaskLottableValue = Lottable14 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @dtScannedPalletTaskLottableValue = Lottable14 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF ISNULL(@dtTaskLottableValue, '1990-01-01') <> ISNULL(@dtScannedPalletTaskLottableValue, '1990-01-01')
      BEGIN
         SET @nErrNo = 236033
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot14NotMatch
         RETURN
      END
   END

   IF ISNULL(@cChkL15, '') = '1' 
   BEGIN
      SET @dtTaskLottableValue = '1990-01-01'
      SET @dtScannedPalletTaskLottableValue = '1990-01-01'
      SELECT @dtTaskLottableValue = Lottable15 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
      SELECT @dtScannedPalletTaskLottableValue = Lottable15 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

      IF ISNULL(@dtTaskLottableValue, '1990-01-01') <> ISNULL(@dtScannedPalletTaskLottableValue, '1990-01-01')
      BEGIN
         SET @nErrNo = 236034
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot15NotMatch
         RETURN
      END
   END

   -- Check ID picked
   IF EXISTS( SELECT TOP 1 1
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND SKU = @cNewSKU
         AND ID = @cNewID
         AND Lot = @cNewLOT
         AND Status <> '0'
         AND QTY > 0)
   BEGIN
      SET @nErrNo = 236009
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID picked
      RETURN
   END

   -- Check task taken by other
   IF EXISTS( SELECT TOP 1 1
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND FromID = @cNewID
         AND Lot = @cNewLOT
         AND TaskDetailKey <> @cTaskDetailKey
         AND Status IN ('3', '5', '9') )
   BEGIN
      SET @nErrNo = 236010
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID task taken
      RETURN
   END

/*--------------------------------------------------------------------------------------------------

                                                Swap ID

--------------------------------------------------------------------------------------------------*/
/*
   Scenario:
   1. ID is not alloc           swap
   2. ID on other PickDetail    swap
   3. ID is allocated for a replenishment task    swap
*/
   DECLARE 
      @cOtherTaskStatus      NVARCHAR( 10),
      @cOtherTaskUserKey     NVARCHAR( 18),
      @cOtherTaskMessage03   NVARCHAR( 30)

   -- Get other task info
   SET @cOtherTaskDetailKey = ''

   SELECT 
      @cOtherTaskDetailKey = TaskDetailKey,
      @cNewTaskType = TaskType,
      @cNewPickMethod = PickMethod,
      @cOtherTaskStatus = Status,
      @cOtherTaskUserKey = UserKey,
      @cOtherTaskMessage03 = Message03
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerkey
      AND TaskType IN ('RPF', 'FPK', 'VNAOUT')
      AND FromLoc = @cNewLOC
      AND FromID = @cNewID
      AND TaskDetailKey <> @cTaskDetailKey
      AND Status IN ( '0', 'Q' ) -- '0' = Open, 'Q' = Queued

   IF ISNULL(@cOtherTaskDetailKey, '') <> ''
   BEGIN
      -- Check full pallet
      IF @cNewPickMethod <> 'FP' 
      BEGIN
         SET @nErrNo = 236037
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Swap FP only
         RETURN
      END
   END

   -- Get other PickDetail info
   SET @cOtherPickDetailKey = ''

   SELECT @cOtherPickDetailKey = PickDetailKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cNewSKU
      AND ID = @cNewID
      AND Loc = @cNewLOC
      AND Status = '0'
      AND QTY > 0

   -- Check pallet allocated but not yet release task
   IF @cOtherTaskDetailKey = '' AND ISNULL(@cOtherPickDetailKey, '') <> ''
   BEGIN
      SET @nErrNo = 236038
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID locked
      RETURN
   END

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN
   SAVE TRAN rdt_1770SwapID05

   -- 1. Scanned ID is allocated for a replenishment task, release the pallet first
   IF @cOtherTaskDetailKey <> '' AND ISNULL(@cOtherPickDetailKey, '') = '' AND ( @cNewTaskType IN ( 'RPF', 'VNAOUT') )
   BEGIN
      SELECT 
         @cRPFTaskFromLoc = FromLOC,
         @cRPFTaskToLoc = ToLoc
      FROM dbo.TaskDetail WITH(NOLOCK)
      WHERE TaskDetailKey = @cOtherTaskDetailKey
         AND StorerKey = @cStorerKey

      -- Unlock the inventory for the RPF task
      EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK' 
         ,''        --@cLOC      
         ,''        --@cID       
         ,''        --@cSuggLOC 
         ,''        --@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cTaskDetailKey = @cOtherTaskDetailKey
      IF @nErrNo <> 0
      BEGIN
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UnlockRPFFail
         GOTO RollBackTran
      END

      UPDATE LOTxLOCxID SET
         QTYReplen = 0, 
         EditWho = SUSER_SNAME(), 
         EditDate = GETDATE(), 
         TrafficCop = NULL
      WHERE LOT = @cNewLOT
         AND LOC = @cNewLOC
         AND ID = @cNewID
      IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
      BEGIN
         SET @nErrNo = 236042
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD LLI Fail
         GOTO RollBackTran
      END

      UPDATE TaskDetail 
      SET
         UserKey  = '',
         Status   = '0',
         EditDate = GETDATE(), 
         EditWho = SUSER_SNAME(), 
         TrafficCop = NULL
      WHERE TaskDetailKey = @cOtherTaskDetailKey

      IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
      BEGIN
         SET @nErrNo = 236036
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDRPFTaskFail
         GOTO RollBackTran
      END
   END
   
   -- 2. ID is not alloc, 
   --    or ID is allocaed for a replenishment task, but the ID is released in previous section
   IF (@cOtherTaskDetailKey = '' AND @cOtherPickDetailKey = '')
      OR (@cOtherTaskDetailKey <> '' AND ISNULL(@cOtherPickDetailKey, '') = '' AND (@cNewTaskType IN ('RPF', 'VNAOUT') ))
   BEGIN
      -- i. ID is not allocated
      -- Loop PickDetail
      DECLARE @curPD CURSOR
      SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PickDetailKey, QTY
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey
            AND Status = '0'
            AND QTY > 0
      OPEN @curPD
      FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Update current task PickDetail
         UPDATE PickDetail SET
            LOT = @cNewLOT, 
            ID = @cNewID, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME()
         WHERE PickDetailKey = @cPickDetailKey
         IF @@ERROR <> 0
            GOTO RollBackTran

         SET @nNewQTY = @nNewQTY - @nQTY
         SET @nTaskQTY = @nTaskQTY - @nQTY
         
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY
      END

      -- Check balance
      IF @nTaskQTY <> 0 OR @nNewQTY <> 0
      BEGIN
         SET @nErrNo = 236011
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --TaskOffsetErr
         GOTO RollBackTran
      END

      -- Update current task
      UPDATE TaskDetail SET
         LOT = @cNewLOT, 
         FromID = @cNewID, 
         ToID = CASE WHEN ToID <> '' THEN @cNewID ELSE ToID END, 
         EditDate = GETDATE(), 
         EditWho = SUSER_SNAME(), 
         TrafficCop = NULL
      WHERE TaskDetailKey = @cTaskDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 236012
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
         GOTO RollBackTran
      END

      -- ii. ID is allocated for a replenishment task, but the ID is released in previous section
      -- ID was allocated for a replenishment task, it was released, and allocated for the Picking task,
      -- need allocate the old ID to the replenishment task
      IF @cOtherTaskDetailKey <> '' AND ISNULL(@cOtherPickDetailKey, '') = '' AND ( @cNewTaskType IN ( 'RPF', 'VNAOUT' )  )
      BEGIN
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK' 
            ,@cRPFTaskFromLoc
            ,@cTaskID
            ,@cRPFTaskToLoc 
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@cFromLOT = @cTaskLOT
            ,@cTaskDetailKey = @cOtherTaskDetailKey
            ,@cMoveQTYAlloc = '1' -- Just to bypass QTYReplen

         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
            GOTO RollBackTran
         END

         UPDATE TaskDetail SET
            Status = @cOtherTaskStatus,
            UserKey = @cOtherTaskUserKey,
            LOT = @cTaskLOT, 
            FromID = @cTaskID, 
            ToID = CASE WHEN ToID <> '' THEN @cTaskID ELSE ToID END, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE TaskDetailKey = @cOtherTaskDetailKey
            AND Status IN ( '0', 'Q' ) -- '0' = Open, 'Q' = Queued

         IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
         BEGIN
            SET @nErrNo = 236039
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskFail
            GOTO RollBackTran
         END

         UPDATE LOTxLOCxID SET
            QTYReplen = @nIDQTY, 
            EditWho = SUSER_SNAME(), 
            EditDate = GETDATE(), 
            TrafficCop = NULL
         WHERE LOT = @cTaskLOT
            AND LOC = @cNewLOC
            AND ID = @cTaskID

         IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
         BEGIN
            SET @nErrNo = 236043
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD LLI Fail
            GOTO RollBackTran
         END
      END

      GOTO CommitTran
   END

   -- 3. ID on other TaskDetail and PickDetail
   IF @cOtherTaskDetailKey <> '' AND @cOtherPickDetailKey <> ''
   BEGIN
      IF @cNewTaskType = @cTaskType 
      BEGIN
         -- Loop PickDetail
         SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PickDetailKey, TaskDetailKey, QTY
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE TaskDetailKey IN (@cOtherTaskDetailKey, @cTaskDetailKey)
               AND Status = '0'
               AND QTY > 0
         OPEN @curPD
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cTaskKey, @nQTY
         WHILE @@FETCH_STATUS = 0
         BEGIN
            IF @cTaskKey = @cOtherTaskDetailKey
            BEGIN
               -- Update other task PickDetail
               UPDATE PickDetail SET
                  LOT = @cTaskLOT, 
                  ID = @cTaskID, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME(), 
                  TrafficCop = NULL
               WHERE PickDetailKey = @cPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 236013
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
                  GOTO RollBackTran
               END
               SET @nNewQTY = @nNewQTY - @nQTY
            END
            ELSE
            BEGIN
               -- Update current task PickDetail
               UPDATE PickDetail SET
                  LOT = @cNewLOT, 
                  ID = @cNewID, 
                  EditDate = GETDATE(), 
                  EditWho = 'rdt.' + SUSER_SNAME(), 
                  TrafficCop = NULL
               WHERE PickDetailKey = @cPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 236014
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
                  GOTO RollBackTran
               END
               SET @nTaskQTY = @nTaskQTY - @nQTY
            END
            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @cTaskKey, @nQTY
         END
         
         -- Check balance
         IF @nTaskQTY <> 0 OR @nNewQTY <> 0
         BEGIN
            SET @nErrNo = 236015
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --TaskOffsetErr
            GOTO RollBackTran
         END
         
         -- Update other task
         UPDATE TaskDetail SET
            LOT = @cTaskLOT, 
            FromID = @cTaskID, 
            ToID = CASE WHEN ToID <> '' THEN @cTaskID ELSE ToID END, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE TaskDetailKey = @cOtherTaskDetailKey
            AND Status IN ( '0', 'Q' ) -- '0' = Open, 'Q' = Queued
         IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
         BEGIN
            SET @nErrNo = 236016
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
            GOTO RollBackTran
         END

         -- Update current task
         UPDATE TaskDetail SET
            LOT = @cNewLOT, 
            FromID = @cNewID, 
            ToID = CASE WHEN ToID <> '' THEN @cNewID ELSE ToID END, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE TaskDetailKey = @cTaskDetailKey
         IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
         BEGIN
            SET @nErrNo = 236017
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
            GOTO RollBackTran
         END
      END
      GOTO CommitTran
   END

   -- Check not swap
   SET @nErrNo = 236018
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NothingSwapped
   GOTO RollBackTran

CommitTran:
   COMMIT TRAN rdt_1770SwapID05
   GOTO Quit

RollBackTran:
      ROLLBACK TRAN rdt_1770SwapID05
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1770SwapID05 TO NSQL
GO