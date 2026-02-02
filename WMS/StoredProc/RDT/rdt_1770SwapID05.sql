SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****************************************************************************/
/* Store procedure: rdt_1770SwapID05                                        */
/* Copyright      : Maersk WMS                                              */
/* Customer       : BRF BRASIL FOODS SA                                     */
/*                                                                          */
/* Purpose: Swap ID base on same LOC, SKU, QTY, Lottables                   */
/*                                                                          */
/* Date        Rev    Author      Purposes                                  */
/* 2025-04-08  1.0    NLT03       FCR-3836 Create                           */
/* 2025-04-15  1.0.1  NLT03       FCR-3836 Remove useless validation        */
/* 2025-04-15  1.0.2  NLT03       FCR-3836 Handle VNAOUT RPF task           */
/* 2025-08-15  1.1.0  NLT03       UWP-39385 Allocated Qty should be swapped */
/****************************************************************************/

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

   DECLARE @cOtherTaskDetailKey NVARCHAR(10)
   DECLARE @cTaskPickDetailKey  NVARCHAR(10)
   DECLARE @cLoopTaskDetailKey  NVARCHAR(10)
   DECLARE @cTaskPickDetailQty  INT
   
   DECLARE @cNewSKU        NVARCHAR( 20)
   DECLARE @cNewLOT        NVARCHAR( 10)
   DECLARE @cNewLOC        NVARCHAR( 10)
   DECLARE @cNewTaskType    NVARCHAR( 10)
   DECLARE @cNewPickMethod NVARCHAR( 10)
   DECLARE @nNewQTY        INT

   DECLARE @cRPFTaskToLoc     NVARCHAR( 10)

   DECLARE @cLoopPickDetailKey NVARCHAR(10)
   DECLARE @cStorerKey     NVARCHAR( 15)
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
   DECLARE @nNewIDAllocatedForRPF      INT = 0
   DECLARE @nNewIDAllocatedForVNAOUT   INT = 0
   DECLARE @nNewIDAllocatedForPick     INT = 0
   DECLARE @nLoopIndex                 INT = -1

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
      SET @nErrNo = 236002
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
      @cTaskSKU = TD.SKU, 
      @cTaskLOT = TD.LOT,
      @cTaskLOC = TD.FromLOC,
      @cTaskID = TD.FromID, 
      @nTaskQTY = TD.SystemQTY,
      @cTaskPickDetailKey = PD.PickDetailKey,
      @cTaskPickDetailQty = PD.Qty,
      @cTaskLocationType = LOC.LocationHandling
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON TD.TaskDetailKey = PD.TaskDetailKey
   INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
   WHERE TD.StorerKey = @cStorerKey
      AND TD.TaskDetailKey = @cTaskDetailKey

   SET @nRowCount = @@ROWCOUNT 

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 236003
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
      RETURN
   END

   IF @cLocationType IS NOT NULL AND @cLocationType <> '' AND @cTaskLocationType <> @cLocationType
   BEGIN
      SET @nErrNo = 236004
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc Type Not Match
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
      SET @nErrNo = 236005
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID
      RETURN
   END

   SELECT @nRowCount = COUNT(1)
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Loc = @cNewLOC
      AND ID = @cNewID
      AND Status > '0'
      AND QTY > 0

   IF @nRowCount > 0
   BEGIN
      SET @nErrNo = 236006
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pick Started, cannot swap ID
      RETURN
   END

   -- Check ID multi LOC/LOT
   IF @nRowCount > 1
   BEGIN
      SET @nErrNo = 236007
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID multi rec
      RETURN
   END

   -- Check LOC match
   IF @cNewLOC <> @cTaskLOC
   BEGIN
      SET @nErrNo = 236008
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC not match
      RETURN
   END

   -- Check SKU match
   IF @cNewSKU <> @cTaskSKU
   BEGIN
      SET @nErrNo = 236009
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not match
      RETURN
   END

   -- Check QTY match
   IF @nNewQTY <> @nTaskQTY
   BEGIN
      SET @nErrNo = 236010
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


   -- Check task taken by other
   IF EXISTS( SELECT TOP 1 1
      FROM dbo.TaskDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND FromID = @cNewID
         AND Lot = @cNewLOT
         AND TaskDetailKey <> @cTaskDetailKey
         AND Status IN ('3', '5', '9') )
   BEGIN
      SET @nErrNo = 236011
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

   -- Current Pick Details
   DECLARE @tCurrentTaskDetails TABLE
   (
      RowIndex          INT IDENTITY(1,1),
      TaskDetailKey     NVARCHAR(10),
      TaskType          NVARCHAR(10),
      PickDetailKey     NVARCHAR(10),
      PickMethod        NVARCHAR(10),
      Qty               INT 
   )

   INSERT INTO @tCurrentTaskDetails (TaskDetailKey, TaskType, PickDetailKey, PickMethod, Qty)
   SELECT 
      TD.TaskDetailKey, TD.TaskType, PD.PickDetailKey, TD.PickMethod, PD.Qty
   FROM dbo.PickDetail PD WITH (NOLOCK)
   INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON TD.TaskDetailKey = PD.TaskDetailKey
   WHERE PD.StorerKey = @cStorerkey
      AND TD.FromLoc = @cTaskLOC
      AND TD.FromID = @cTaskID
      AND TD.TaskDetailKey = @cTaskDetailKey
      AND TD.Status IN ( '3' ) -- '0' = Open, 'Q' = Queued 

   -- Get other task info
   DECLARE @tOtherTaskDetails TABLE
   (
      RowIndex          INT IDENTITY(1,1),
      TaskDetailKey     NVARCHAR(10),
      TaskType          NVARCHAR(10),
      PickDetailKey     NVARCHAR(10),
      PickMethod        NVARCHAR(10),
      Qty               INT 
   )

   INSERT INTO @tOtherTaskDetails (TaskDetailKey, TaskType, PickDetailKey, PickMethod, Qty)
   SELECT 
      TD.TaskDetailKey, TD.TaskType, '', TD.PickMethod, TD.SystemQty
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   WHERE StorerKey = @cStorerkey
      AND TaskType IN ('RPF', 'RP1', 'VNAOUT')
      AND FromLoc = @cNewLOC
      AND FromID = @cNewID
      AND TaskDetailKey <> @cTaskDetailKey
      AND Status IN ( '0', 'Q' ) -- '0' = Open, 'Q' = Queued

   INSERT INTO @tOtherTaskDetails (TaskDetailKey, TaskType, PickDetailKey, PickMethod, Qty)
   SELECT 
      TD.TaskDetailKey, TD.TaskType, PD.PickDetailKey, TD.PickMethod, PD.Qty
   FROM dbo.PickDetail PD WITH (NOLOCK)
   LEFT JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey
   WHERE PD.StorerKey = @cStorerkey
      AND TD.FromLoc = @cNewLOC
      AND TD.FromID = @cNewID
      AND TD.TaskDetailKey <> @cTaskDetailKey
      AND PD.Status = '0'
      AND (TD.TaskDetailKey IS NULL OR (TD.TaskDetailKey IS NOT NULL AND TD.Status IN ( '0', 'Q' )) ) -- '0' = Open, 'Q' = Queued

   -- Search other pick tasks base on RPF task
   IF EXISTS (SELECT 1 FROM @tOtherTaskDetails WHERE TaskType IN ('RPF', 'RP1'))
   BEGIN
      INSERT INTO @tOtherTaskDetails (TaskDetailKey, TaskType, PickDetailKey, PickMethod, Qty)
      SELECT 
         TD.TaskDetailKey, TD.TaskType, PD.PickDetailKey, TD.PickMethod, PD.Qty
      FROM dbo.PickDetail PD WITH (NOLOCK)
      INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey
      INNER JOIN @tOtherTaskDetails TTD ON TD.RefTaskKey IS NOT NULL AND TTD.TaskDetailKey = TD.RefTaskKey
      WHERE PD.StorerKey = @cStorerkey
         AND PD.Status IN ( '0', 'H' )
         AND TTD.TaskType IN ('RPF', 'RP1')
   END

   SELECT @nNewIDAllocatedForRPF = COUNT(1)
   FROM @tOtherTaskDetails
   WHERE TaskType = 'RPF'

   SELECT @nNewIDAllocatedForVNAOUT = COUNT(1)
   FROM @tOtherTaskDetails
   WHERE TaskType = 'VNAOUT'

   SELECT @nNewIDAllocatedForPick = COUNT(1)
   FROM @tOtherTaskDetails
   WHERE PickDetailKey IS NOT NULL
      AND PickDetailKey <> ''

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   BEGIN TRANSACTION

   -- 1. The scanned ID is not allocated for any PickDetail
   IF NOT EXISTS (SELECT 1 FROM @tOtherTaskDetails)
   BEGIN
      -- i) Unallocated the old ID
      BEGIN TRY
         UPDATE dbo.PickDetail WITH(ROWLOCK)
         SET Qty = 0
         WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236041 
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Unallocate Failed
         GOTO RollBackTran
      END CATCH

      -- ii) Allocated Qty to scanned ID
      -- Update current task PickDetail
      -- iii) Allocated Qty to scanned ID
      -- Update current task PickDetail
      SET @nLoopIndex = -1
      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @cLoopTaskDetailKey = TaskDetailKey,
            @cLoopPickDetailKey = PickDetailKey,
            @nLoopIndex = RowIndex,
            @nQTY = Qty
         FROM @tCurrentTaskDetails
         WHERE RowIndex > @nLoopIndex
          AND ISNULL(PickDetailKey, '') <> ''
         ORDER BY RowIndex

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
            BREAK

         BEGIN TRY
            UPDATE dbo.PickDetail SET
               Qty = @nQTY,
               LOT = @cNewLOT,
               ID = @cNewID, 
               EditDate = GETDATE(), 
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cLoopPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 236042
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
            GOTO RollBackTran
         END CATCH

         BEGIN TRY
            UPDATE dbo.TaskDetail WITH(ROWLOCK)
            SET
               LOT = @cNewLOT,
               FromID = @cNewID,
               ToID = CASE WHEN ToID <> '' THEN @cNewID ELSE ToID END, 
               EditDate = GETDATE(), 
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            WHERE TaskDetailKey = @cLoopTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 236043
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
            GOTO RollBackTran
         END CATCH
      END
   END

   -- 2. Scanned ID is allocated for pick task, swap allocation
   IF ( @nNewIDAllocatedForPick > 0 )
   BEGIN
      -- i) Unallocated the old ID
      BEGIN TRY
         UPDATE dbo.PickDetail WITH(ROWLOCK)
         SET Qty = 0
         WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236013 
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Unallocate Failed
         GOTO RollBackTran
      END CATCH

      -- ii) Unallocated the scanned ID
      BEGIN TRY
         UPDATE PD WITH(ROWLOCK)
         SET Qty = 0
         FROM dbo.PickDetail PD WITH(ROWLOCK)
         INNER JOIN @tOtherTaskDetails OTD ON PD.PickDetailKey = OTD.PickDetailKey
         WHERE OTD.PickDetailKey IS NOT NULL
            AND OTD.PickDetailKey <> ''
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236014
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Unallocate Failed
         GOTO RollBackTran
      END CATCH

      -- iii) Allocated Qty to scanned ID
      -- Update current task PickDetail
      SET @nLoopIndex = -1
      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @cLoopTaskDetailKey = TaskDetailKey,
            @cLoopPickDetailKey = PickDetailKey,
            @nLoopIndex = RowIndex,
            @nQTY = Qty
         FROM @tCurrentTaskDetails
         WHERE RowIndex > @nLoopIndex
            AND ISNULL(PickDetailKey, '') <> ''
         ORDER BY RowIndex

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
            BREAK
         
         BEGIN TRY
            UPDATE dbo.PickDetail SET
               Qty = @nQTY,
               LOT = @cNewLOT,
               ID = @cNewID, 
               EditDate = GETDATE(), 
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cLoopPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 236015
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
            GOTO RollBackTran
         END CATCH

         BEGIN TRY
            UPDATE dbo.TaskDetail WITH(ROWLOCK)
            SET
               LOT = @cNewLOT,
               FromID = @cNewID,
               ToID = CASE WHEN ToID <> '' THEN @cNewID ELSE ToID END, 
               EditDate = GETDATE(), 
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            WHERE TaskDetailKey = @cLoopTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 236016
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
            GOTO RollBackTran
         END CATCH
      END

      -- iv) Allocated Qty to current ID
      -- Update other task PickDetail
      SET @nLoopIndex = -1
      WHILE 1 = 1
      BEGIN
         SELECT TOP 1
            @cLoopTaskDetailKey = TaskDetailKey,
            @cLoopPickDetailKey = PickDetailKey,
            @nLoopIndex = RowIndex,
            @nQTY = Qty
         FROM @tOtherTaskDetails
         WHERE RowIndex > @nLoopIndex
            AND ISNULL(PickDetailKey, '') <> ''
         ORDER BY RowIndex

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
            BREAK

         BEGIN TRY
            UPDATE dbo.PickDetail SET
               Qty = @nQTY,
               LOT = @cTaskLOT, 
               ID = CASE WHEN ID <> '' THEN @cTaskID ELSE ID END, 
               EditDate = GETDATE(), 
               EditWho = SUSER_SNAME()
            WHERE PickDetailKey = @cLoopPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 236017
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
            GOTO RollBackTran
         END CATCH

         BEGIN TRY
            UPDATE dbo.TaskDetail WITH(ROWLOCK)
            SET
               LOT = @cTaskLOT,
               FromID = CASE WHEN FromID <> '' THEN @cTaskID ELSE FromID END,
               ToID = CASE WHEN ToID <> '' THEN @cTaskID ELSE ToID END, 
               EditDate = GETDATE(), 
               EditWho = SUSER_SNAME(),
               TrafficCop = NULL
            WHERE TaskDetailKey = @cLoopTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 236018
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
            GOTO RollBackTran
         END CATCH
      END
   END

   -- 3. Scanned ID is allocated for a replenishment task, swap RPFPendingMoveIn
   IF @nNewIDAllocatedForRPF > 0 OR @nNewIDAllocatedForVNAOUT > 0
   BEGIN
      -- Unlock ToLoc for scanned ID
      BEGIN TRY
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
            ,'' --@cSuggFromLOC
            ,@cNewID 
            ,'' --@cSuggToLOC
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236019
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Unlock RPFPendingMoveIn Failed
         GOTO RollBackTran
      END CATCH

      IF ISNULL(@nErrNo, 0) <> 0
         GOTO RollBackTran

      BEGIN TRY
         UPDATE LOTxLOCxID SET
            QTYReplen = 0, 
            EditWho = SUSER_SNAME(), 
            EditDate = GETDATE(), 
            TrafficCop = NULL
         WHERE LOT = @cNewLOT
            AND LOC = @cNewLOC
            AND ID = @cNewID
            AND QTYReplen > 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236035
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Release QTYReplen Failed
         GOTO RollBackTran
      END CATCH

      BEGIN TRY
         UPDATE dbo.LOTxLOCxID SET
            QTYReplen = @nIDQTY, 
            EditWho = SUSER_SNAME(), 
            EditDate = GETDATE(), 
            TrafficCop = NULL
         WHERE LOT = @cTaskLOT
            AND LOC = @cNewLOC
            AND ID = @cTaskID
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236036 
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Swap QTYReplen Failed
         GOTO RollBackTran
      END CATCH

      SELECT @cOtherTaskDetailKey = TaskDetailKey
      FROM @tOtherTaskDetails
      WHERE TaskType IN ('RPF', 'RP1', 'VNAOUT')

      SELECT @cRPFTaskToLoc = ToLoc
      FROM dbo.TaskDetail WITH(NOLOCK)
      WHERE TaskDetailKey = @cOtherTaskDetailKey

      -- Loc ToLoc for scanned ID
      BEGIN TRY
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK' 
            ,@cTaskLOC
            ,@cTaskID
            ,@cRPFTaskToLoc
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@cFromLOT = @cTaskLOT
            ,@cTaskDetailKey = @cOtherTaskDetailKey
            ,@cMoveQTYAlloc = '1' -- Just to bypass QTYReplen
            ,@cMoveQTYReplen = '1'
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236037
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Unlock RPFPendingMoveIn Failed
         GOTO RollBackTran
      END CATCH

      IF ISNULL(@nErrNo, 0) <> 0
         GOTO RollBackTran

      --Update RPF/VNAOUT Task
      BEGIN TRY
         UPDATE dbo.TaskDetail WITH(ROWLOCK)
         SET
            LOT = @cTaskLOT,
            FromID = @cTaskID,
            ToID = CASE WHEN ToID <> '' THEN @cTaskID ELSE ToID END, 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(),
            TrafficCop = NULL
         WHERE TaskDetailKey = @cOtherTaskDetailKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 236044
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
         GOTO RollBackTran
      END CATCH
      
      -- Swap ID for current task If ID not swapped yet
      IF EXISTS(SELECT 1 
               FROM dbo.PickDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND TaskDetailKey = @cTaskDetailKey
                  AND ID = @cTaskID
               )
      BEGIN
         BEGIN TRY
            UPDATE dbo.PickDetail WITH(ROWLOCK)
            SET Qty = 0
            WHERE TaskDetailKey = @cTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 236038
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Unallocate Failed
            GOTO RollBackTran
         END CATCH

         SET @nLoopIndex = -1
         WHILE 1 = 1
         BEGIN
            SELECT TOP 1
               @cLoopTaskDetailKey = TaskDetailKey,
               @cLoopPickDetailKey = PickDetailKey,
               @nLoopIndex = RowIndex,
               @nQTY = Qty
            FROM @tCurrentTaskDetails
            WHERE RowIndex > @nLoopIndex
            AND ISNULL(PickDetailKey, '') <> ''
            ORDER BY RowIndex

            SELECT @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
               BREAK
            
            BEGIN TRY
               UPDATE dbo.PickDetail SET
                  Qty = @nQTY,
                  LOT = @cNewLOT,
                  ID = @cNewID, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cLoopPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 236039
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Allocate Failed
               GOTO RollBackTran
            END CATCH

            BEGIN TRY
               UPDATE dbo.TaskDetail WITH(ROWLOCK)
               SET
                  LOT = @cNewLOT,
                  FromID = @cNewID,
                  ToID = CASE WHEN ToID <> '' THEN @cNewID ELSE ToID END, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME(),
                  TrafficCop = NULL
               WHERE TaskDetailKey = @cLoopTaskDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 236040
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update TaskDetail Failed
               GOTO RollBackTran
            END CATCH
         END
      END
   END

CommitTran:
   COMMIT TRANSACTION
   GOTO Quit

RollBackTran:
      ROLLBACK TRANSACTION
Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1770SwapID05 TO NSQL
GO