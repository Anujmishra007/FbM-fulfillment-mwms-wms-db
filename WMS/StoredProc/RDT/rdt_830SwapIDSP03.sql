
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_830SwapIDSP03                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 13-05-2025  1.0  Ung         FCR-4215 base rdt_830SwapIDSP02         */
/*                              Swap SKU only without consider lottable */
/* 05-04-2026  1.1 ASP123      FCR-11252 Check On-Hold status before SWAP */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_830SwapIDSP03
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nAfterStep    INT,
   @nInputKey     INT,
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cPickSlipNo   NVARCHAR( 10),
   @cPickZone     NVARCHAR( 10),
   @cSuggLOC      NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cDropID       NVARCHAR( 20),
   @cSKU          NVARCHAR( 20),
   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @nTaskQTY      INT,
   @nQTY          INT,
   @cToLOC        NVARCHAR( 10),
   @cOption       NVARCHAR( 1),
   @cSuggID       NVARCHAR( 20),
   @cID           NVARCHAR( 20),
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSQLCommon        NVARCHAR( MAX)
   DECLARE @cSQLCommonParam   NVARCHAR( MAX)
   DECLARE @cSQLCustom        NVARCHAR( MAX)
   DECLARE @cSQLCustomParam   NVARCHAR( MAX)
   DECLARE @nRowCount         INT

   /*
      Orbiter location:
      1 LOC 1 SKU, but multiple IDs and LOTs
   
      Scenarios:
      1. Actual ID is suggested ID, no swap
      2. Actual ID is in the pick slip, no swap
      3. Actual ID is free and/or alloc (by another pick slip), swap
         4.1 Unalloc suggest ID
         4.2 Alloc actual ID
   */
      
   -- 1. Actual ID is suggested ID, no swap
   IF @cID = @cSuggID
      GOTO Quit

/*--------------------------------------------------------------------------------------------------
                                            Build common SQL
--------------------------------------------------------------------------------------------------*/
   DECLARE @cOrderKey NVARCHAR( 10) = ''
   DECLARE @cLoadKey  NVARCHAR( 10) = ''
   DECLARE @cZone     NVARCHAR( 18) = ''

   -- Get PickHeader info
   SELECT TOP 1
      @cOrderKey = OrderKey,
      @cLoadKey = ExternOrderKey,
      @cZone = Zone
   FROM dbo.PickHeader WITH (NOLOCK)
   WHERE PickHeaderKey = @cPickSlipNo

   -- Cross dock PickSlip
   IF @cZone IN ('XD', 'LB', 'LP')
      SET @cSQLCommon = 
         ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK) ' + 
            ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) ' + 
         ' WHERE RKL.PickSlipNo = @cPickSlipNo ' 

   -- Discrete PickSlip
   ELSE IF @cOrderKey <> ''
      SET @cSQLCommon = 
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' + 
            ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' + 
         ' WHERE PD.OrderKey = @cOrderKey '

   -- Conso PickSlip
   ELSE IF @cLoadKey <> ''
      SET @cSQLCommon = 
         ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' + 
            ' JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' + 
            ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' + 
         ' WHERE LPD.LoadKey = @cLoadKey '

   -- Custom PickSlip
   ELSE
      SET @cSQLCommon = 
         ' FROM dbo.PickDetail PD WITH (NOLOCK) ' + 
            ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' + 
         ' WHERE PD.PickSlipNo = @cPickSlipNo '

   SET @cSQLCommon +=
      ' AND PD.LOC = @cLOC ' + 
      ' AND PD.ID  = @cID ' + 
      ' AND PD.QTY > 0 ' + 
      ' AND PD.Status <> ''4'' ' + 
      ' AND PD.Status < @cPickConfirmStatus '

   SET @cSQLCommonParam = 
      ' @cPickSlipNo          NVARCHAR( 10) ' + 
      ',@cOrderKey            NVARCHAR( 10) ' + 
      ',@cLoadKey             NVARCHAR( 10) ' + 
      ',@cLOC                 NVARCHAR( 10) ' + 
      ',@cID                  NVARCHAR( 18) ' + 
      ',@cPickConfirmStatus   NVARCHAR( 1)  '

/*--------------------------------------------------------------------------------------------------
   2. Actual ID is in the pick slip, no swap
--------------------------------------------------------------------------------------------------*/
   -- Get storer config
   DECLARE @cPickConfirmStatus NVARCHAR( 1)
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   SET @nRowCount = 0
   SET @cSQLCustom = 'SELECT TOP 1 @nRowCount = 1 ' + @cSQLCommon
   SET @cSQLCustomParam = @cSQLCommonParam + 
      ',@nRowCount   INT OUTPUT '      
   exec sp_executeSQL @cSQLCustom, @cSQLCustomParam
      ,@cPickSlipNo        = @cPickSlipNo
      ,@cOrderKey          = @cOrderKey
      ,@cLoadKey           = @cLoadKey
      ,@cLOC               = @cLOC
      ,@cID                = @cID
      ,@cPickConfirmStatus = @cPickConfirmStatus
      ,@nRowCount          = @nRowCount OUTPUT
   IF @nRowCount = 1
      GOTO Quit
   
/*--------------------------------------------------------------------------------------------------
   Get task in suggest ID
--------------------------------------------------------------------------------------------------*/
   IF OBJECT_ID( 'tempdb..#tTaskPD') IS NOT NULL DROP TABLE #tTaskPD
   CREATE TABLE #tTaskPD 
   (
      PickDetailKey NVARCHAR( 10) NOT NULL,
      SKU           NVARCHAR( 20) NOT NULL,
      LOT           NVARCHAR( 10) NOT NULL,
      QTY           INT           NOT NULL
      PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   IF OBJECT_ID( 'tempdb..#tActPD') IS NOT NULL DROP TABLE #tActPD
   CREATE TABLE #tActPD
   (
      RowRef        INT           NOT NULL IDENTITY(1, 1), 
      PickDetailKey NVARCHAR( 10) NOT NULL, -- If free QTY, PickDetailKey is blank
      SKU           NVARCHAR( 20) NOT NULL,
      LOT           NVARCHAR( 10) NOT NULL,
      QTY           INT           NOT NULL
      -- PRIMARY KEY CLUSTERED (PickDetailKey)
   )

   -- Get task in suggested ID
   SET @cSQLCustom = 
      'INSERT INTO #tTaskPD (PickDetailKey, SKU, LOT, QTY) ' + 
      'SELECT PD.PickDetailKey, SKU, LOT, QTY ' + 
      @cSQLCommon
   SET @cSQLCustomParam = @cSQLCommonParam
   EXEC sp_executeSQL @cSQLCustom, @cSQLCustomParam
      ,@cPickSlipNo        = @cPickSlipNo
      ,@cOrderKey          = @cOrderKey
      ,@cLoadKey           = @cLoadKey
      ,@cLOC               = @cLOC
      ,@cID                = @cSuggID
      ,@cPickConfirmStatus = @cPickConfirmStatus

   -- Get task in actual ID
   SET @cSQLCustom = 
      'INSERT INTO #tActPD (PickDetailKey, SKU, LOT, QTY) ' + 
      'SELECT PickDetailKey, SKU, LOT, QTY ' + 
      'FROM dbo.PickDetail WITH (NOLOCK) ' + 
      'WHERE LOC = @cLOC ' + 
         ' AND ID = @cID ' 
   SET @cSQLCustomParam = 
      ' @cLOC NVARCHAR( 10), ' + 
      ' @cID  NVARCHAR( 18)  '
   EXEC sp_executeSQL @cSQLCustom, @cSQLCustomParam
      ,@cLOC               = @cLOC
      ,@cID                = @cID

   -- Get free QTY in actual ID
   SET @cSQLCustom = 
      'INSERT INTO #tActPD (PickDetailKey, SKU, LOT, QTY) ' + 
      'SELECT '''', SKU, LOT, QTY-QTYAllocated-QTYPicked ' + 
      'FROM dbo.LOTxLOCxID WITH (NOLOCK) ' + 
      'WHERE LOC = @cLOC ' + 
         ' AND ID = @cID ' + 
         ' AND QTY-QTYAllocated-QTYPicked > 0 ' 
   SET @cSQLCustomParam = 
      ' @cLOC NVARCHAR( 10), ' + 
      ' @cID  NVARCHAR( 18)  '
   EXEC sp_executeSQL @cSQLCustom, @cSQLCustomParam
      ,@cLOC               = @cLOC
      ,@cID                = @cID

   -- Check actual ID valid
   IF NOT EXISTS( SELECT 1 FROM #tActPD)
   BEGIN
      SET @nErrNo = 238401      
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ID
      GOTO quit
   END

   -- Check actual ID had same task (SKU, LOT)
   IF NOT EXISTS( SELECT TOP 1 1 
      FROM #tTaskPD T
         JOIN #tActPD A ON (T.SKU = A.SKU))
   BEGIN
      SET @nErrNo = 238402      
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff SKU
      GOTO quit
   END

   -- Check ON HOLD swap ID logic
   IF EXISTS( SELECT 1
      FROM dbo.INVENTORYHOLD WITH (NOLOCK)
      WHERE ID = @cSuggID and HOLD = 1)
   BEGIN
      SET @nErrNo = 238417
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID on HOLD, cannot SWAP
      GOTO Quit
   END

   -- Get first task (by SKU, LOT)
   DECLARE @cSuggSKU NVARCHAR( 20)   
   SELECT TOP 1 
      @cSuggSKU = T.SKU
   FROM #tTaskPD T
      JOIN #tActPD A ON (T.SKU = A.SKU)
   ORDER BY T.SKU
   
   /*
      Inventory:
         P1 = 30 alloc (order A)
         P2 = 10 free
              10 alloc (order B)
   
      Suggest P1, swap P2

      Inventory:
         P2 = 20 alloc (order A)
         P1 = 10 alloc (order A)
              10 alloc (order B)
              10 free

      Loop P1, line by line
         Loop P2, line by line
            Calc QTY to take (take the smaller QTY, of P1 or P2)
            If P1 QTY < P2 QTY
               Split P2 line
               If P2 is free, alloc P2, unalloc P1
               If P2 is alloc, exchange with P1

            If P1 QTY = P2 QTY
               If P2 is free, alloc P2, unalloc P1
               If P2 is alloc, exchange with P1

            If P1 QTY > P2 QTY
               Split P1 line
               If P2 is free, alloc P2, unalloc P1
               If P2 is alloc, exchange with P1

   */
   
   DECLARE @cSuggPickDetailKey NVARCHAR( 10)
   DECLARE @cSuggLOT NVARCHAR( 10)
   DECLARE @nSuggQTY INT
   
   DECLARE @cActPickDetailKey NVARCHAR( 10)
   DECLARE @cActLOT NVARCHAR( 10)
   DECLARE @nActQTY INT
   DECLARE @nRowRef INT
   
   DECLARE @cNewPickDetailKey NVARCHAR( 10)
   DECLARE @bSuccess INT
   
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_830SwapIDSP03
   
   -- Suggest (P1)
   DECLARE @curSuggPD CURSOR
   SET @curSuggPD = CURSOR LOCAL FAST_FORWARD FOR -- READ_ONLY 
      SELECT PickDetailKey, LOT, QTY 
      FROM #tTaskPD 
      WHERE SKU = @cSuggSKU
      ORDER BY PickDetailKey
   OPEN @curSuggPD
   FETCH NEXT FROM @curSuggPD INTO @cSuggPickDetailKey, @cSuggLOT, @nSuggQTY
   WHILE @@FETCH_STATUS = 0
   BEGIN   
      -- Get Actual (P2, include free QTY and alloc QTY)
      SELECT TOP 1 
         @nRowRef = RowRef, 
         @cActPickDetailKey = PickDetailKey, 
         @cActLOT = LOT, 
         @nActQTY = QTY
      FROM #tActPD 
      WHERE SKU = @cSuggSKU
         AND QTY > 0
      ORDER BY PickDetailKey -- Free comes first
         
      IF @@ROWCOUNT > 0
      BEGIN
         -- Calc QTY to take
         IF @nSuggQTY <= @nActQTY
            SET @nQTY = @nSuggQTY
         ELSE
            SET @nQTY = @nActQTY

         -- Split P2 line
         IF @nSuggQTY < @nActQTY
         BEGIN
            -- Alloc
            IF @cActPickDetailKey <> '' 
            BEGIN
               -- Get new PickDetailkey
               EXECUTE dbo.nspg_GetKey
                  'PICKDETAILKEY',
                  10 ,
                  @cNewPickDetailKey OUTPUT,
                  @bSuccess          OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT
               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 238403
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_GetKey
                  GOTO RollBackTran
               END

               -- Create new a PickDetail to hold the balance
               INSERT INTO dbo.PickDetail (
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey, Channel_ID, 
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
                  PickDetailKey,
                  Status, 
                  QTY, 
                  TrafficCop, 
                  OptimizeCop)
               SELECT
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType, 
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey, Channel_ID, 
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
                  @cNewPickDetailKey,
                  Status, 
                  @nActQTY - @nQTY, -- QTY
                  NULL, -- TrafficCop
                  '1'   -- OptimizeCop
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE PickDetailKey = @cActPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 238404
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PKDtl Fail
                  GOTO RollBackTran
               END

               -- Add balance to temp also
               INSERT INTO #tActPD (PickDetailKey, SKU, LOT, QTY) VALUES (@cNewPickDetailKey, @cSuggSKU, @cActLOT, @nActQTY - @nQTY)

               -- Split RefKeyLookup
               IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cActPickDetailKey)
               BEGIN
                  -- Insert into
                  INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
                  SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
                  FROM RefKeyLookup WITH (NOLOCK) 
                  WHERE PickDetailKey = @cActPickDetailKey
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 238405
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RefKeyFail
                     GOTO RollBackTran
                  END
               END
               
               -- Change the original line (using TrafficCop)
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                  QTY = @nQTY,
                  TrafficCop = NULL, 
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME()
               WHERE PickDetailKey = @cActPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 238406
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END
            END
            
            -- Reduce original
            UPDATE #tActPD SET
               QTY = @nQTY
            WHERE RowRef = @nRowRef
               
            -- Insert balance
            INSERT INTO #tActPD (PickDetailKey, SKU, LOT, QTY)
            VALUES (IIF( @cActPickDetailKey = '', '', @cNewPickDetailKey) , @cSuggSKU, @cActLOT, @nActQTY - @nQTY)
         END
           
         -- Split P1 line
         ELSE IF @nSuggQTY > @nActQTY
         BEGIN
            -- Get new PickDetailkey
            EXECUTE dbo.nspg_GetKey
               'PICKDETAILKEY',
               10 ,
               @cNewPickDetailKey OUTPUT,
               @bSuccess          OUTPUT,
               @nErrNo            OUTPUT,
               @cErrMsg           OUTPUT
            IF @bSuccess <> 1
            BEGIN
               SET @nErrNo = 238407
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_GetKey
               GOTO RollBackTran
            END

            -- Create new a PickDetail to hold the balance
            INSERT INTO dbo.PickDetail (
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,
               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey, Channel_ID, 
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               PickDetailKey,
               Status, 
               QTY, 
               TrafficCop, 
               OptimizeCop)
            SELECT
               CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
               UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType, 
               ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey, Channel_ID, 
               EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
               @cNewPickDetailKey,
               Status, 
               @nSuggQTY - @nQTY, -- QTY
               NULL, -- TrafficCop
               '1'   -- OptimizeCop
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE PickDetailKey = @cSuggPickDetailKey
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 238408
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PKDtl Fail
               GOTO RollBackTran
            END

            -- Split RefKeyLookup
            IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cSuggPickDetailKey)
            BEGIN
               -- Insert into
               INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
               SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
               FROM RefKeyLookup WITH (NOLOCK) 
               WHERE PickDetailKey = @cSuggPickDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 238409
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RefKeyFail
                  GOTO RollBackTran
               END
            END
            
            -- Change the original line (using TrafficCop)
            UPDATE dbo.PickDetail WITH (ROWLOCK) SET
               QTY = @nQTY,
               TrafficCop = NULL, 
               EditDate = GETDATE(),
               EditWho  = SUSER_SNAME()
            WHERE PickDetailKey = @cSuggPickDetailKey
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 238410
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
               GOTO RollBackTran
            END
            
            -- Reduce original
            UPDATE #tTaskPD SET
               QTY = @nQTY
            WHERE PickDetailKey = @cSuggPickDetailKey
            
            -- Insert balance
            INSERT INTO #tTaskPD (PickDetailKey, SKU, LOT, QTY) 
            VALUES (@cNewPickDetailKey, @cSuggSKU, @cSuggLOT, @nSuggQTY - @nQTY)
         END
                     
         -- Exchange P1, P2
         BEGIN
            -- If P2 is free, alloc P2, unalloc P1
            IF @cActPickDetailKey = ''
            BEGIN
               -- Suggest (unalloc P1)
               UPDATE dbo.PickDetail SET
                  QTY = 0, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cSuggPickDetailKey
               IF @@ERROR <> 0 OR @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 238411
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END
               
               -- Suggest (alloc P2)
               UPDATE dbo.PickDetail SET
                  ID = @cID, 
                  LOT = @cActLOT, 
                  QTY = @nQTY, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cSuggPickDetailKey
               IF @@ERROR <> 0 OR @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 238412
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END
            END
            
            -- If P2 is alloc, exchange with P1
            ELSE
            BEGIN
               -- Suggest (unalloc P1)
               UPDATE dbo.PickDetail SET
                  QTY = 0, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cSuggPickDetailKey
               IF @@ERROR <> 0 OR @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 238413
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END
               
               -- Actual (unalloc P2)
               UPDATE dbo.PickDetail SET
                  QTY = 0, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cActPickDetailKey
               IF @@ERROR <> 0 OR @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 238414
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END
               
               -- Suggest (alloc P2)
               UPDATE dbo.PickDetail SET
                  ID = @cID, 
                  LOT = @cActLOT, 
                  QTY = @nQTY, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cSuggPickDetailKey
               IF @@ERROR <> 0 OR @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 238415
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END
               
               -- Actual (alloc P1)
               UPDATE dbo.PickDetail SET
                  ID = @cSuggID, 
                  LOT = @cSuggLOT, 
                  QTY = @nQTY, 
                  EditDate = GETDATE(), 
                  EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @cActPickDetailKey
               IF @@ERROR <> 0 OR @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 238416
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                  GOTO RollBackTran
               END
            END
               
            -- Actual (reduce QTY)
            UPDATE #tActPD SET
               QTY = 0
            WHERE RowRef = @nRowRef
         END
      END

      FETCH NEXT FROM @curSuggPD INTO @cSuggPickDetailKey, @cSuggLOT, @nSuggQTY
   END
   
   COMMIT TRAN rdt_830SwapIDSP03
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_830SwapIDSP03
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

GRANT EXECUTE ON rdt.rdt_830SwapIDSP03 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
