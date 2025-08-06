
/**************************************************************************/
/* Store procedure: rdt_1764SwapID05                                      */
/* Copyright      : Maersk WMS                                            */
/* Customer       : BRF BRASIL FOODS SA                                   */
/*                                                                        */
/* Purpose: Swap ID base on same LOC, SKU, QTY, Lottables                 */
/*                                                                        */
/* Date        Rev      Author      Purposes                              */
/* 2025-04-08  1.0.0    Jackc       FCR-3916 Create                       */
/* 2025-08-06  1.0.1    NickT       FCR-3916 Reallocate pick task         */
/**************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1764SwapID05
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

   DECLARE @nDebugFlag     INT = 0
   DECLARE @nRowCount      INT

   DECLARE @cOtherPickDetailKey NVARCHAR(10)
   DECLARE @cOtherTaskDetailKey NVARCHAR(10)

   DECLARE @cNewSKU                 NVARCHAR( 20)
   DECLARE @cNewLOT                 NVARCHAR( 10)
   DECLARE @cNewLOC                 NVARCHAR( 10)
   DECLARE @cOtherTaskType          NVARCHAR( 10)
   DECLARE @cOtherPickMethod        NVARCHAR( 10)
   DECLARE @nNewQTY                 INT
   DECLARE @nOtherRPFRowRef         INT
   DECLARE @cOtherRPFSuggLOC        NVARCHAR( 10)
   DECLARE @nOtherRPFPendingMoveIn  INT
   DECLARE @nOtherQTYReplen         INT

   DECLARE @cRPFTaskFromLoc   NVARCHAR( 10)
   DECLARE @cRPFTaskToLoc     NVARCHAR( 10)

   DECLARE @cTaskPickDetailKey      NVARCHAR(10)
   DECLARE @cPickDetailKey          NVARCHAR(10)
   DECLARE @cStorerKey              NVARCHAR( 15)
   DECLARE @cTaskKey                NVARCHAR( 10)
   DECLARE @cTaskType               NVARCHAR( 10)
   DECLARE @cTaskSKU                NVARCHAR( 20)
   DECLARE @cTaskLOT                NVARCHAR( 10)
   DECLARE @cTaskLOC                NVARCHAR( 10)
   DECLARE @cTaskTansitLoc          NVARCHAR( 10)
   DECLARE @cTaskID                 NVARCHAR( 18)
   DECLARE @cIDStatus               NVARCHAR( 10)
   DECLARE @nTaskQTY                INT
   DECLARE @nQTY                    INT
   DECLARE @nIDQTY                  INT
   DECLARE @nCurrRPFRowRef          INT
   DECLARE @cCurrRPFSuggLOC         NVARCHAR( 10)
   DECLARE @nCurrRPFPendingMoveIn   INT
   DECLARE @nCurrQTYReplen          INT 


   DECLARE @cLottableCompare     NVARCHAR( MAX) = ''
   DECLARE @cTaskLocHandling     NVARCHAR( 10)
   DECLARE @cLocHandling         NVARCHAR( 10)
   DECLARE @cLotMatch            NVARCHAR( 1) = '0'

   DECLARE
      @cChkL01 NVARCHAR(1) = '0', @cChkL02 NVARCHAR(1) = '0', @cChkL03 NVARCHAR(1) = '0', @cChkL04 NVARCHAR(1) = '0', @cChkL05 NVARCHAR(1) = '0', 
      @cChkL06 NVARCHAR(1) = '0', @cChkL07 NVARCHAR(1) = '0', @cChkL08 NVARCHAR(1) = '0', @cChkL09 NVARCHAR(1) = '0', @cChkL10 NVARCHAR(1) = '0', 
      @cChkL11 NVARCHAR(1) = '0', @cChkL12 NVARCHAR(1) = '0', @cChkL13 NVARCHAR(1) = '0', @cChkL14 NVARCHAR(1) = '0', @cChkL15 NVARCHAR(1) = '0'

   DECLARE @curPD CURSOR
   DECLARE @tPD TABLE
   (
      PickdetailKey  NVARCHAR(10) NOT NULL, 
      TaskDetailKey  NVARCHAR(10) NOT NULL, 
      QTY            INT          NOT NULL DEFAULT 0,
      LOT            NVARCHAR(10) NOT NULL,
      ID             NVARCHAR(18) NOT NULL,
      Remark         NVARCHAR(100)  
   )

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1764SwapID05'

   SELECT @cStorerKey = StorerKey
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- Check blank
   IF @cNewID = ''
   BEGIN
      SET @nErrNo = 238151
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ID
      GOTO Quit
   END

   -- Check if ID is on HOLD
   IF EXISTS (SELECT 1 
               FROM dbo.INVENTORYHOLD WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND ID = @cNewID
                  AND Hold = '1')
   BEGIN
      SET @nErrNo = 238152
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --IDIsOnHold
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Original Task Validation'

   -- Get task info
   SELECT
      @cStorerKey = TD.StorerKey, 
      @cTaskType = TD.TaskType, 
      @cTaskSKU = TD.SKU, 
      @cTaskLOT = TD.LOT,
      @cTaskLOC = TD.FromLOC,
      @cTaskID = TD.FromID,
      @nTaskQTY = TD.SystemQTY,
      --@cTaskPickDetailKey = PickDetailKey,
      @cTaskLocHandling = LOC.LocationHandling
   FROM dbo.TaskDetail TD WITH (NOLOCK)
   INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
   WHERE TD.StorerKey = @cStorerKey
      AND TD.TaskDetailKey = @cTaskDetailKey

   SET @nRowCount = @@ROWCOUNT 

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 238153
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --BadTaskDtlKey
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Original task info', @cTaskDetailKey AS TaskKey, @cTaskID AS TaskID

   IF NOT EXISTS (SELECT 1 FROM dbo.CodeLKUP WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND ListName = 'SwapID'
                     AND Code2 = @nFunc
                     AND UDF01 = @cTaskLocHandling)
   BEGIN
      SET @nErrNo = 238154
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SwapIDDisallow
      GOTO Quit
   END

   -- Get other PickDetail info
   SET @cTaskPickDetailKey = ''

   SELECT @cTaskPickDetailKey = PickDetailKey
   FROM dbo.PickDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND SKU = @cTaskSKU
      AND ID = @cTaskID
      AND Loc = @cTaskLOC
      AND Status = '0'
      AND QTY > 0

   -- Get task ID Qty
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

   IF @nDebugFlag = 1
      SELECT 'NewID Validation'

   -- Check ID valid
   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 238155
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID
      GOTO Quit
   END

   -- Check ID multi LOC/LOT
   IF @nRowCount > 1
   BEGIN
      SET @nErrNo = 238156
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID multi rec
      GOTO Quit
   END

   -- Check LOC match
   IF @cNewLOC <> @cTaskLOC
   BEGIN
      SET @nErrNo = 238157
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC not match
      GOTO Quit
   END

   -- Check SKU match
   IF @cNewSKU <> @cTaskSKU
   BEGIN
      SET @nErrNo = 238158
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not match
      GOTO Quit
   END

   -- Check QTY match
   IF @nNewQTY <> @nTaskQTY
   BEGIN
      SET @nErrNo = 238159
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTY not match
      GOTO Quit
   END

   IF @cTaskLOT <> @cNewLot -- only check lottable values when lot not match
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Lottable values validation', @cTaskLOT AS TaskLot, @cNewLOT AS NewLot

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
         @cChkL15 = CASE WHEN Code = 'Lottable15' THEN '1' ELSE @cChkL15 END
      FROM dbo.CodeLKUP WITH (NOLOCK)
      WHERE ListName = 'SwapID'
         AND StorerKey = @cStorerKey
         AND Code2 = @nFunc
         AND UDF01 = @cTaskLocHandling

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
            SET @nErrNo = 238160
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot01NotMatch
            GOTO Quit
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
            SET @nErrNo = 238161
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot02NotMatch
            GOTO Quit
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
            SET @nErrNo = 238162
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot03NotMatch
            GOTO Quit
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
            SET @nErrNo = 238163
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot04NotMatch
            GOTO Quit
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
            SET @nErrNo = 238164
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot05NotMatch
            GOTO Quit
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
            SET @nErrNo = 238165
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot06NotMatch
            GOTO Quit
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
            SET @nErrNo = 238166
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot07NotMatch
            GOTO Quit
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
            SET @nErrNo = 238167
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot08NotMatch
            GOTO Quit
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
            SET @nErrNo = 238168
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot09NotMatch
            GOTO Quit
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
            SET @nErrNo = 238169
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot10NotMatch
            GOTO Quit
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
            SET @nErrNo = 238170
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot11NotMatch
            GOTO Quit
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
            SET @nErrNo = 238171
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot12NotMatch
            GOTO Quit
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
            SET @nErrNo = 238172
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot13NotMatch
            GOTO Quit
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
            SET @nErrNo = 238173
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot14NotMatch
            GOTO Quit
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
            SET @nErrNo = 238174
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot15NotMatch
            GOTO Quit
         END
      END-- Get check lottable setting

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
         @cChkL15 = CASE WHEN Code = 'Lottable15' THEN '1' ELSE @cChkL15 END
      FROM dbo.CodeLKUP WITH (NOLOCK)
      WHERE ListName = 'SwapID'
         AND StorerKey = @cStorerKey
         AND Code2 = @nFunc
         AND UDF01 = @cTaskLocHandling

      IF ISNULL(@cChkL01, '') = '1' 
      BEGIN
         SET @cTaskLottableValue = ''
         SET @cScannedPalletLottableValue = ''
         SELECT @cTaskLottableValue = Lottable01 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cTaskLOT
         SELECT @cScannedPalletLottableValue = Lottable01 FROM dbo.LOTAttribute WITH(NOLOCK) WHERE Lot = @cNewLOT

         IF @cTaskLottableValue <> @cScannedPalletLottableValue
         BEGIN
            SET @nErrNo = 238160
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot01NotMatch
            GOTO Quit
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
            SET @nErrNo = 238161
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot02NotMatch
            GOTO Quit
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
            SET @nErrNo = 238162
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot03NotMatch
            GOTO Quit
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
            SET @nErrNo = 238163
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot04NotMatch
            GOTO Quit
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
            SET @nErrNo = 238164
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot05NotMatch
            GOTO Quit
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
            SET @nErrNo = 238165
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot06NotMatch
            GOTO Quit
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
            SET @nErrNo = 238166
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot07NotMatch
            GOTO Quit
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
            SET @nErrNo = 238167
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot08NotMatch
            GOTO Quit
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
            SET @nErrNo = 238168
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot09NotMatch
            GOTO Quit
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
            SET @nErrNo = 238169
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot10NotMatch
            GOTO Quit
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
            SET @nErrNo = 238170
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot11NotMatch
            GOTO Quit
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
            SET @nErrNo = 238171
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot12NotMatch
            GOTO Quit
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
            SET @nErrNo = 238172
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot13NotMatch
            GOTO Quit
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
            SET @nErrNo = 238173
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot14NotMatch
            GOTO Quit
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
            SET @nErrNo = 238174
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lot15NotMatch
            GOTO Quit
         END
      END
   END -- Check lot

   IF @nDebugFlag = 1
      SELECT 'NewID Task & Pickdetail Validation'

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
      SET @nErrNo = 238175
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID picked
      GOTO Quit
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
      GOTO Quit
   END

   DECLARE 
      @cOtherTaskStatus      NVARCHAR( 10),
      @cOtherTaskUserKey     NVARCHAR( 18)

   -- Get other task info
   SET @cOtherTaskDetailKey = ''

   SELECT 
      @cOtherTaskDetailKey = TaskDetailKey,
      @cOtherTaskType = TaskType,
      @cOtherPickMethod = PickMethod,
      @cOtherTaskStatus = Status,
      @cOtherTaskUserKey = UserKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE StorerKey = @cStorerkey
      --AND TaskType IN ('RPF', 'FPK', 'VNAOUT')
      AND FromLoc = @cNewLOC
      AND FromID = @cNewID
      AND TaskDetailKey <> @cTaskDetailKey
      AND Status IN ( '0', 'Q' ) -- '0' = Open, 'Q' = Queued

   IF ISNULL(@cOtherTaskDetailKey, '') <> ''
   BEGIN
      -- Check full pallet
      IF @cOtherPickMethod <> 'FP' 
      BEGIN
         SET @nErrNo = 238177
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Swap FP only
         GOTO Quit
      END

      --Only can swap task type in RPF, FPK, VNAOUT
      IF @cOtherTaskType NOT IN ('RPF', 'FPK', 'VNAOUT')
      BEGIN
         SET @nErrNo = 238190
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Swap FP only
         GOTO Quit
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
      SET @nErrNo = 238178
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID locked
      GOTO Quit
   END

   IF @nDebugFlag = 1
      SELECT 'Get taskID and newID RPF info'

   -- Get current RFPutaway info
   SET @nCurrRPFRowRef = 0
   SET @nCurrRPFPendingMoveIn = 0
   SET @cCurrRPFSuggLOC = ''
   SELECT 
      @nCurrRPFRowRef  = RowRef, 
      @nCurrRPFPendingMoveIn = QTY, 
      @cCurrRPFSuggLOC = SuggestedLOC
   FROM RFPutaway WITH (NOLOCK) 
   WHERE TaskDetailKey = @cTaskDetailKey

   -- Get other RFPutaway info
   SET @nOtherRPFRowRef = 0
   SET @nOtherRPFPendingMoveIn = 0 
   SET @cOtherRPFSuggLOC = ''
   IF @cOtherTaskDetailKey <> ''
      SELECT 
         @nOtherRPFRowRef = RowRef, 
         @nOtherRPFPendingMoveIn = QTY, 
         @cOtherRPFSuggLOC = SuggestedLOC
      FROM RFPutaway WITH (NOLOCK) 
      WHERE TaskDetailKey = @cOtherTaskDetailKey

   IF @nDebugFlag = 1
      SELECT 'Get taskID and NewID LLI QtyReplen info'

   -- Get current LOTxLOCxID info
   SET @nCurrQTYReplen = 0
   SELECT @nCurrQTYReplen = QTYReplen
   FROM LOTxLOCxID WITH (NOLOCK)
   WHERE LOT = @cTaskLOT
      AND LOC = @cTaskLOC
      AND ID = @cTaskID

   -- Get other LOTxLOCxID info
   SET @nOtherQTYReplen = 0
   IF @cOtherTaskDetailKey <> ''
      SELECT @nOtherQTYReplen = QTYReplen
      FROM LOTxLOCxID WITH (NOLOCK)
      WHERE LOT = @cNewLOT
         AND LOC = @cNewLOC
         AND ID = @cNewID

/*--------------------------------------------------------------------------------------------------
                                                Swap ID
--------------------------------------------------------------------------------------------------*/
/*
   Scenario:
   1. Handle task data
      1.1 Handle TaskID task data
      1.2 Handle NewID task data if there is a task
   2. Handle Pickdetail data
      2.1 Unallocate taskID 
      2.2 Unallocate NewID if it is allocated
      2.3 Reallocate pickdetail but switch ID and Lot
   3. Switch QtyReplen data to make LLI correct first
   4. Re-generate rfputaway data
      4.1 refresh rfputaway for TaskID
      4.2 refresh rfputaway for NewID
*/
   IF @nDebugFlag = 1
      SELECT 'Start Swap ID logic'

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   BEGIN TRAN
   SAVE TRAN rdt_1764SwapID05

   --0. Always unlock both TaskID and NewID RF data.
   IF @nDebugFlag = 1
      SELECT 'Unlock both TaskID and NewID RF data'

   IF @nCurrRPFRowRef > 0
   BEGIN
      -- Unlock SuggestedLOC
      SET @nErrNo = 0
      EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK' 
         ,''        --@cLOC      
         ,''        --@cID       
         ,''        --@cSuggLOC 
         ,''        --@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cTaskDetailKey = @cTaskDetailKey
      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 238179
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Unlock fail
         GOTO RollBackTran
      END
   END
   
   IF @nOtherRPFRowRef > 0
   BEGIN
      -- Unlock SuggestedLOC
      SET @nErrNo = 0
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
         SET @nErrNo = 238180
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Unlock fail
         GOTO RollBackTran
      END
   END

   IF @nDebugFlag = 1
      SELECT 'Unlock both TaskID and NewID RF data done', @nCurrRPFRowRef AS CurrenRPFRowRef, @nOtherRPFRowRef AS OtherRPFRowRef

   --1. Handle task data
   IF @nDebugFlag = 1
   BEGIN
      SELECT '1. Handle task data'
      SELECT '1.1 Handle TaskID task data', @cTaskDetailKey AS TaskKey
   END

   -- 1.1 Handle TaskID task data
   -- Update current task
   UPDATE TaskDetail SET
      LOT = @cNewLOT, 
      FromID = @cNewID, 
      ToID = CASE WHEN ToID <> '' THEN @cNewID ELSE ToID END, 
      FinalID = CASE WHEN FinalID <> '' THEN @cNewID ELSE FinalID END, 
      EditDate = GETDATE(), 
      EditWho = SUSER_SNAME(), 
      TrafficCop = NULL
   WHERE TaskDetailKey = @cTaskDetailKey
   IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
   BEGIN
      SET @nErrNo = 238181
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
      GOTO RollBackTran
   END -- 1.1

   --1.2 Handle NewID task data if there is a task
   IF @cOtherTaskDetailKey <> ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT '1.2 Handle NewID task data if there is a task', @cOtherTaskDetailKey AS OtherTaskKey

      UPDATE TaskDetail SET
         LOT = @cTaskLOT, 
         FromID = @cTaskID, 
         ToID = CASE WHEN ToID <> '' THEN @cTaskID ELSE ToID END, 
         EditDate = GETDATE(), 
         EditWho = SUSER_SNAME(), 
         TrafficCop = NULL
      WHERE TaskDetailKey = @cOtherTaskDetailKey
         AND Status = '0' --'H'
      IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
      BEGIN
         SET @nErrNo = 238182
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD Task Fail
         GOTO RollBackTran
      END
   END --1.2

   --2. Handle Pickdetail data
   IF @nDebugFlag = 1
      SELECT '2. Handle Pickdetail data', @cTaskPickDetailKey AS TaskPickDetailKey, @cOtherPickDetailKey AS OtherPickDetailKey

   -- 2.1 Unallocate taskID
   IF @cTaskPickDetailKey <> ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT '2.1 Unallocate taskID'

      --Save the task pickdetail and replace lot and ID with new values
      INSERT INTO @tPD (PickDetailKey, TaskDetailKey, Qty, LOT, ID,Remark)
      SELECT
         PickDetailKey, TaskDetailKey, QTY, @cNewLot, @cNewID, 'TaskPKD'
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cTaskDetailKey
         AND Status = '0'
         AND Qty > 0

      BEGIN TRY
         UPDATE PickDetail WITH (ROWLOCK)
         SET
            QTY = 0, 
            EditDate = GETDATE(), 
            EditWho = 'rdt.' + SUSER_SNAME()
         WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cTaskDetailKey
            AND Status = '0'
            AND Qty > 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 238183
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKD Fail
         GOTO RollBackTran
      END CATCH
   END -- unallocate taskID

   --2.2 Unallocate NewID if it is allocated
   IF @cOtherPickDetailKey <> ''
   BEGIN
      IF @nDebugFlag = 1
         SELECT '2.2 Unallocate NewID'

      --Save the NewID pickdetail and replace lot and ID with task values
      INSERT INTO @tPD (PickDetailKey, TaskDetailKey, Qty, LOT, ID,Remark)
      SELECT
         PickDetailKey, TaskDetailKey, QTY, @cTaskLot, @cTaskID, 'NewID PKD'
      FROM dbo.PickDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND TaskDetailKey = @cOtherTaskDetailKey
         AND Status = '0'
         AND Qty > 0

      BEGIN TRY
         UPDATE PickDetail WITH (ROWLOCK)
         SET
            QTY = 0, 
            EditDate = GETDATE(), 
            EditWho = 'rdt.' + SUSER_SNAME()
         WHERE StorerKey = @cStorerKey
            AND TaskDetailKey = @cOtherPickDetailKey
            AND Status = '0'
            AND Qty > 0
      END TRY
      BEGIN CATCH
         SET @nErrNo = 238184
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKD Fail
         GOTO RollBackTran
      END CATCH
   END -- unallocate NewID

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Unallocation finished. Data in @tPD'
      SELECT * FROM @tPD
   END

   --2.3 Reallocate pickdetail
   IF EXISTS ( SELECT 1 FROM @tPD)
   BEGIN
      IF @nDebugFlag = 1
         SELECT '2.3 Reallocate pickdetail'

      BEGIN TRY
         MERGE INTO dbo.PickDetail AS PKD
         USING @tPD AS PD
            ON PKD.PickDetailKey = PD.PickDetailKey
         WHEN MATCHED THEN
            UPDATE SET
               QTY = PD.QTY, 
               LOT = PD.LOT, 
               ID = PD.ID, 
               EditDate = GETDATE(), 
               EditWho = 'rdt.' + SUSER_SNAME();
      END TRY
      BEGIN CATCH
         SET @nErrNo = 238185
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKD Fail
         GOTO RollBackTran
      END CATCH
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Check PickDetail'
      SELECT * FROM PickDetail WITH (NOLOCK)
      WHERE Storerkey = @cStorerKey
         AND ID IN (@cTaskID, @cNewID)
         AND LOT IN (@cTaskLOT, @cNewLOT) 
   END

   --3. Switch QtyReplen to make LLI correct
   IF @nDebugFlag = 1
      SELECT '3. Switch QtyReplen', @nCurrQTYReplen AS CurrQtyReplen, @nOtherQTYReplen AS OtherQtyReplen

   UPDATE LOTxLOCxID SET
      QTYReplen = @nCurrQTYReplen, 
      EditWho = SUSER_SNAME(), 
      EditDate = GETDATE(), 
      TrafficCop = NULL
   WHERE LOT = @cNewLOT
      AND LOC = @cTaskLOC
      AND ID = @cNewID
   IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
   BEGIN
      SET @nErrNo = 238188
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD LLI Fail
      GOTO RollBackTran
   END
 
   UPDATE LOTxLOCxID SET
      QTYReplen = @nOtherQTYReplen, 
      EditWho = SUSER_SNAME(), 
      EditDate = GETDATE(), 
      TrafficCop = NULL
   WHERE LOT = @cTaskLOT
      AND LOC = @cTaskLOC
      AND ID = @cTaskID
   IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
   BEGIN
      SET @nErrNo = 238189
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD LLI Fail
      GOTO RollBackTran
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Check LLI'
      SELECT * FROM LOTxLOCxID WITH (NOLOCK) 
      WHERE Storerkey = @cStorerKey 
         AND ID IN (@cTaskID, @cNewID)
         AND LOT IN (@cTaskLOT, @cNewLOT) 
   END


   --4 Handle RFPutaway
   IF @nDebugFlag = 1
      SELECT '4 Handle RFPutaway', @nCurrRPFRowRef AS CurrRPFRowRef, @nOtherRPFRowRef AS OtherRPFRowRef

   --4.1 re-generate rfputaway for task
   IF @nCurrRPFRowRef > 0 -- if taskID has rfputaway, then re-generate it to NewID for the task
   BEGIN
      IF @nDebugFlag = 1
         SELECT '4.1 re-generate rfputaway for current task', 
                  @cTaskDetailKey AS TaskKey, @cNewID AS NewID, @cNewLOT AS NewLot, @nCurrQTYReplen AS TaskQtyReplen, 
                  @cTaskPickDetailKey AS TaskPickDetailKey
      -- Booking
      IF @nCurrQTYReplen > 0 --Because switched QtyReplen, so if TaskQtyReplen > 0, then LLI.QtyReplen of NEWID > 0
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK' 
            ,@cTaskLOC
            ,@cNewID       
            ,@cCurrRPFSuggLOC 
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@cFromLOT = @cNewLOT
            ,@cTaskDetailKey = @cTaskDetailKey
            ,@cMoveQTYReplen = '1'
      ELSE --In the other cases, pass MoveQtyAlloc
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK' 
            ,@cTaskLOC
            ,@cNewID       
            ,@cCurrRPFSuggLOC 
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@cFromLOT = @cNewLOT
            ,@cTaskDetailKey = @cTaskDetailKey
            ,@cMoveQTYAlloc = '1'

      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 238186
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Book loc fail
         GOTO RollBackTran
      END
   END--4.1 CurrRPFRowRef <> ''

   --Regenerate rfputaway for other task
   IF @nOtherRPFRowRef > 0 -- if NewID has rfputaway, then re-generate it to TaskID for the other task
   BEGIN
      IF @nDebugFlag = 1
         SELECT '4.2 re-generate rfputaway for the other task', 
                  @cOtherTaskDetailKey AS OtherTaskKey, @cTaskID AS TaskID, @cTaskLOT AS TaskLot, @nOtherQTYReplen AS OtherQtyReplen,
                  @cOtherPickDetailKey AS OtherPickDetail
      -- Booking
      IF @nOtherQTYReplen > 0 --Because switched QtyReplen, so if OtherQtyReplen > 0, then LLI.QtyReplen of TaskID > 0
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK' 
         ,@cTaskLOC     
         ,@cTaskID       
         ,@cOtherRPFSuggLOC 
         ,@cStorerKey
         ,@nErrNo  OUTPUT
         ,@cErrMsg OUTPUT
         ,@cFromLOT = @cTaskLOT
         ,@cTaskDetailKey = @cOtherTaskDetailKey
         ,@cMoveQTYReplen = '1' 
      ELSE --In the other cases, pass MoveQtyAlloc
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'LOCK' 
            ,@cTaskLOC     
            ,@cTaskID       
            ,@cOtherRPFSuggLOC 
            ,@cStorerKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@cFromLOT = @cTaskLOT
            ,@cTaskDetailKey = @cOtherTaskDetailKey
            ,@cMoveQTYAlloc = '1' -- Just to bypass QTYReplen
      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 238187
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Book loc fail
         GOTO RollBackTran
      END
   END --4.2 otherRPFRowRef <> ''

   --- Reallocate FCP/FPK task
   DECLARE 
      @cNextPickTaskDetailKey NVARCHAR( 18),
      @cNextPickDetailKey     NVARCHAR( 18),
      @nPDQty  INT,
      @nLoopIndex INT

   DECLARE @tNextPickDetail TABLE
   (
      RowIndex INT IDENTITY(1, 1) PRIMARY KEY,
      TaskDetailKey NVARCHAR( 18) NOT NULL,
      PickDetailKey NVARCHAR( 18) NOT NULL,
      Qty INT NOT NULL
   )

   INSERT INTO @tNextPickDetail (TaskDetailKey, PickDetailKey, Qty)
   SELECT 
      PD.TaskDetailKey,
      PD.PickDetailKey,
      PD.QTY
   FROM dbo.PickDetail PD WITH(NOLOCK)
   INNER JOIN dbo.TaskDetail TD WITH(NOLOCK)
      ON PD.TaskDetailKey = TD.TaskDetailKey
   WHERE PD.StorerKey = @cStorerKey
      AND PD.ID = @cTaskID
      AND PD.LOC = @cTaskLoc
      AND PD.QTY > 0
      AND PD.Status = '0'
      AND TD.TaskType IN ('FCP', 'FPK')

   SET @nLoopIndex = -1

   WHILE 1 = 1
   BEGIN
      SELECT TOP 1 
         @cNextPickTaskDetailKey = TaskDetailKey,
         @cNextPickDetailKey = PickDetailKey,
         @nPDQty = Qty,
         @nLoopIndex = RowIndex
      FROM @tNextPickDetail
      WHERE RowIndex > @nLoopIndex
      ORDER BY RowIndex

      IF @@ROWCOUNT = 0
         BREAK

      -- Reallocate
      BEGIN TRY
         UPDATE PickDetail WITH (ROWLOCK)
         SET
            Qty = 0,
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME()
         WHERE PickDetailKey = @cNextPickDetailKey
            AND StorerKey = @cStorerKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 238191
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail failed
         GOTO RollBackTran
      END CATCH

      BEGIN TRY
         UPDATE PickDetail WITH (ROWLOCK)
         SET
            ID = @cNewID,
            LOT = @cNewLOT,
            Qty = @nPDQty,
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE PickDetailKey = @cNextPickDetailKey
            AND StorerKey = @cStorerKey
      END TRY
      BEGIN CATCH
         SET @nErrNo = 238192
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail failed
         GOTO RollBackTran
      END CATCH
   END

CommitTran:
   COMMIT TRAN rdt_1764SwapID05
   GOTO Quit

RollBackTran:
      ROLLBACK TRAN rdt_1764SwapID05
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1764SwapID05 TO NSQL
GO