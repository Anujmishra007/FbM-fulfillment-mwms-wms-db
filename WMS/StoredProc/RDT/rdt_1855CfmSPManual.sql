SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/******************************************************************************/  
/* Store procedure: rdt_1855CfmSPManual                                       */  
/* Copyright      : Maersk                                                    */  
/* Customer       : Granite Levis                                             */
/*                                                                            */  
/* Purpose: Confirm manual Pick                                               */
/*                                                                            */
/* Called from: rdt_1855CfmSP01                                               */
/*                                                                            */
/* Date         Rev    Author   Purposes                                      */
/* 2026-02-05   1.0.0  NLT013   FCR-8408 Created                              */
/* 2026-02-13   1.1.0  NLT013   FCR-11020 Wave.UserDefine09=Y is auto pick    */
/******************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_1855CfmSPManual (  
    @nMobile         INT,  
    @nFunc           INT,  
    @cLangCode       NVARCHAR( 3),  
    @nStep           INT,  
    @nInputKey       INT,  
    @cFacility       NVARCHAR( 5),  
    @cStorerKey      NVARCHAR( 15),  
    @cType           NVARCHAR( 10), -- CONFIRM/SHORT/CLOSE  
    @cCartID         NVARCHAR( 10),
    @cGroupKey       NVARCHAR( 10),
    @cTaskDetailKey  NVARCHAR( 10),  
    @nQTY            INT,
    @nErrNo          INT           OUTPUT,  
    @cErrMsg         NVARCHAR(250) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nTranCount  INT 

   DECLARE @nDebugFlag   INT = 0 
   
   DECLARE @cOrderKey      NVARCHAR( 10)  
   DECLARE @cLoadKey       NVARCHAR( 10)  
   DECLARE @cZone          NVARCHAR( 18)  
   DECLARE @cPickDetailKey NVARCHAR( 18)  
   DECLARE @cPickConfirmStatus NVARCHAR( 1)  
   DECLARE @nQTY_Bal       INT  
   DECLARE @nQTY_PD        INT  
   DECLARE @bSuccess       INT  
   DECLARE @curCfmTask     CURSOR  
   DECLARE @curPD          CURSOR
   DECLARE @cCaseID        NVARCHAR( 20)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cPickSlipNo    NVARCHAR( 10)
   DECLARE @cLOC           NVARCHAR( 10)
   DECLARE @cTaskKey       NVARCHAR( 10)
   DECLARE @cDropID        NVARCHAR( 20)
   DECLARE @cUserName      NVARCHAR( 18)
   DECLARE @cFromLoc       NVARCHAR( 10)
   DECLARE @cPickZone      NVARCHAR( 10)
   DECLARE @nRowCount      INT
   DECLARE @nPickedQty		INT
   DECLARE @cNewTaskDetailKey NVARCHAR( 10)
   DECLARE @cShortTaskDetailKey NVARCHAR( 10) --V1.1.1
   DECLARE @nSuccess       INT
   DECLARE @cReasonCode    NVARCHAR( 10)
   DECLARE @cNewPickDetailKey NVARCHAR( 10)  
   DECLARE @nTransitCount  INT
   DECLARE @nFullShortFlag INT = 1  
   DECLARE @nLoopIndex INT = -1   
   DECLARE @cOriginDropId  NVARCHAR( 20)
   DECLARE @cAutomationPickFlag  NVARCHAR( 10)
   DECLARE @cOriginalCaseID         NVARCHAR( 20)
   DECLARE @tTempTasks TABLE (
      RowIndex         INT       NOT NULL IDENTITY (1, 1),
      TaskDetaiLKey    NVARCHAR( 10) NULL,
      SKU              NVARCHAR( 20) NULL,
      CaseID           NVARCHAR( 20) NULL,
      FromLoc          NVARCHAR( 20) NULL,
      DROPID           NVARCHAR( 20) NULL,
      OrderKey         NVARCHAR( 10) NULL
      )
   SELECT 
      @cUserName        = UserName,
      @cPickZone        = V_String24
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   SELECT 
      @cSKU = SKU, 
      @cCaseID = CaseID,
      @cFromLoc = FromLoc,
      @cReasonCode = ReasonKey,
      @nTransitCount = TransitCount
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey
         
   INSERT INTO TRACEINFO (TraceName, TimeIn, Col1, Col2, Col3, Col4, Col5) VALUES ('1855', GETDATE(), @cUserName, @cSKU, @cCaseID, @cLOC, @cTaskDetailKey)
   SET @cOrderKey = ''  
   SET @cLoadKey = ''
   SET @cZone = ''  
     
   -- Get storer config  
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)  
   IF @cPickConfirmStatus = '0'  
      SET @cPickConfirmStatus = '5'  

   -- For calculation  
   SET @nQTY_Bal = @nQTY  

   -- Handling transaction  
   SET @nTranCount = @@TRANCOUNT  
   BEGIN TRAN  -- Begin our own transaction  
   SAVE TRAN rdt_1855CfmSPManual -- For rollback or commit only our own transaction  

   IF @cPickZone = 'PICK'
   BEGIN
      DELETE FROM @tTempTasks
      INSERT INTO @tTempTasks (TaskDetailKey, SKU, CaseID, FromLoc, DropID, OrderKey)
      SELECT TD.TaskDetailKey, TD.Sku, TD.Caseid, TD.FromLoc, TD.DropID, PD.OrderKey
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON ( TD.TaskDetailKey = PD.TaskDetailKey)
      WHERE TD.Storerkey = @cStorerKey
      AND   TD.TaskType = 'ASTCPK'
      AND   TD.[Status] = '3'
      AND   TD.Groupkey = @cGroupKey
      AND   TD.UserKey = @cUserName
      AND   TD.DeviceID = @cCartID
      AND   TD.Sku = @cSKU
      AND   TD.Caseid = @cCaseID
      AND   TD.FromLoc = @cFromLoc
      AND   PD.[Status] < @cPickConfirmStatus
      AND   PD.QTY > 0 
      AND   PD.Status <> '4'
      ORDER BY PD.OrderKey,PD.OrderLineNumber,PD.PICKDETAILKEY
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'TempTask List'
      SELECT * FROM @tTempTasks
   END

   SET @nLoopIndex = -1
   WHILE(1=1)
   BEGIN
      SELECT TOP 1
         @nLoopIndex = RowIndex,
         @cTaskDetailKey = TaskDetaiLKey,
         @cSKU = SKU,
         @cCaseID = CaseID,
         @cLOC = FromLoc,
         @cDropID = DropID,
         @cOrderKey = OrderKey
      FROM @tTempTasks
      WHERE RowIndex > @nLoopIndex
      ORDER BY RowIndex
      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
         BREAK

      IF ISNULL( @cOrderKey, '') = ''
      BEGIN  
         SET @nErrNo = 258151  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pick Not Found  
         GOTO RollBackTran  
      END 

      SELECT @cLoadKey = LoadKey
      FROM dbo.ORDERS WITH (NOLOCK)
      WHERE OrderKey = @cOrderKey

      SELECT @cPickSlipNo = PickheaderKey
      FROM dbo.PICKHEADER WITH (NOLOCK) 
      WHERE OrderKey = @cOrderKey 
   
      IF ISNULL( @cPickSlipNo, '') = ''
         SELECT @cPickSlipNo = PickheaderKey FROM dbo.PICKHEADER WITH (NOLOCK) WHERE LoadKey = @cLoadKey

      IF ISNULL( @cPickSlipNo, '') = ''
         SELECT @cPickSlipNo = PickheaderKey FROM dbo.PICKHEADER WITH (NOLOCK) WHERE ExternOrderKey = @cLoadKey

      IF ISNULL( @cPickSlipNo, '') = ''
      BEGIN  
         SET @nErrNo = 258152  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No Pickslip  
         GOTO RollBackTran  
      END 

      -- Get PickHeader info  
      SELECT @cZone = Zone  
      FROM dbo.PickHeader WITH (NOLOCK)  
      WHERE PickHeaderKey = @cPickSlipNo  

      -- Cross dock PickSlip  
      IF @cZone IN ('XD', 'LB', 'LP')  
         SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PD.PickDetailKey, PD.QTY 
         FROM dbo.RefKeyLookup RKL WITH (NOLOCK) 
         JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey) 
         WHERE RKL.PickSlipNo = @cPickSlipNo 
         AND   PD.LOC = @cLOC 
         AND   PD.SKU = @cSKU 
         AND   PD.CaseID = @cCaseID
         AND   PD.QTY > 0 
         AND   PD.Status <> '4'
         AND   PD.Status < @cPickConfirmStatus 
         AND   PD.TaskDetailKey = @cTaskDetailKey
         
      -- Discrete PickSlip  
      ELSE IF @cOrderKey <> ''  
      BEGIN
         IF @cPickZone = 'PICK'
            SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
            SELECT PD.PickDetailKey, PD.QTY 
            FROM dbo.PickDetail PD WITH (NOLOCK) 
            JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) 
            WHERE PD.OrderKey = @cOrderKey 
            AND   PD.LOC = @cLOC 
            AND   PD.SKU = @cSKU 
            AND   PD.CaseID = @cCaseID
            AND   PD.QTY > 0 
            AND   PD.Status <> '4' 
            AND   PD.Status < @cPickConfirmStatus 
            AND   PD.TaskDetailKey = @cTaskDetailKey
      END
         
      -- Conso PickSlip  
      ELSE IF @cLoadKey <> ''  
         SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
         SELECT PD.PickDetailKey, PD.QTY 
         FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
         JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) 
         JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) 
         WHERE LPD.LoadKey = @cLoadKey 
         AND   PD.LOC = @cLOC 
         AND   PD.SKU = @cSKU 
         AND   PD.CaseID = @cCaseID
         AND   PD.QTY > 0 
         AND   PD.Status <> '4' 
         AND   PD.Status < @cPickConfirmStatus 
         AND   PD.TaskDetailKey = @cTaskDetailKey
         
      -- Custom PickSlip  
      ELSE  
         SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
         SELECT PD.PickDetailKey, PD.QTY 
         FROM dbo.PickDetail PD WITH (NOLOCK) 
         JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) 
         WHERE PD.PickSlipNo = @cPickSlipNo 
         AND   PD.LOC = @cLOC 
         AND   PD.SKU = @cSKU 
         AND   PD.CaseID = @cCaseID
         AND   PD.QTY > 0 
         AND   PD.Status <> '4' 
         AND   PD.Status < @cPickConfirmStatus 
         AND   PD.TaskDetailKey = @cTaskDetailKey
         
      OPEN @curPD

      -- Loop PickDetail  
      FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD  
      WHILE @@FETCH_STATUS = 0  
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Loop PickDetail, Current PickDetai: ', @cPickDetailKey AS PickDetailKey, @nQty_PD AS QtyPD

         SELECT @cOriginDropId = PD.DropID,
            @cOriginalCaseID = PD.CaseID,
            @cAutomationPickFlag = ISNULL(WV.UserDefine09, '')
         FROM dbo.PickDetail PD WITH(NOLOCK)
         INNER JOIN dbo.WaveDetail WD WITH(NOLOCK) ON WD.OrderKey = PD.OrderKey
         INNER JOIN dbo.Wave WV WITH(NOLOCK) ON WD.WaveKey = WV.WaveKey
         WHERE PickDetailKey = @cPickDetailKey

         IF @cAutomationPickFlag = 'Y'
            CONTINUE

         -- Exact match  
         IF @nQTY_PD = @nQTY_Bal  
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Qty_PD = QTY_Bal' 

            SET @nFullShortFlag = 0
            -- Confirm PickDetail  
            UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
               Status = @cPickConfirmStatus, 
               DropID = @cDropID,
               EditDate = GETDATE(),  
               EditWho  = SUSER_SNAME()  
            WHERE PickDetailKey = @cPickDetailKey  
            IF @@ERROR <> 0  
            BEGIN  
               SET @nErrNo = 258153  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
               GOTO RollBackTran  
            END  
  
            SET @nQTY_Bal = 0 -- Reduce balance  
         END  
  
         -- PickDetail have less  
         ELSE IF @nQTY_PD < @nQTY_Bal  
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Qty_PD < QTY_Bal' 

            SET @nFullShortFlag = 0
            -- Confirm PickDetail  
            UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
               Status = @cPickConfirmStatus,
               DropID = @cDropID,
               EditDate = GETDATE(),  
               EditWho  = SUSER_SNAME()  
            WHERE PickDetailKey = @cPickDetailKey  
            IF @@ERROR <> 0  
            BEGIN  
               SET @nErrNo = 258154  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
               GOTO RollBackTran  
            END  
  
            SET @nQTY_Bal = @nQTY_Bal - @nQTY_PD -- Reduce balance  
         END  
  
         -- PickDetail have more  
         ELSE IF @nQTY_PD > @nQTY_Bal  
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'Qty_PD > QTY_Bal'

            -- Don't need to split  
            IF @nQTY_Bal = 0  
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Qty_PD > QTY_Bal, QTY_Bal = 0'  
               -- Short pick  
               IF @cType = 'SHORT' -- Don't need to split  
               BEGIN  
                  IF @cReasonCode <> 'SKIP' AND @nTransitCount = 0 --first time short pick
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT '1st time Short Pick'

                     IF @nFullShortFlag = 1 --Full Short Pick
                     BEGIN
                        IF @nDebugFlag = 1
                           SELECT 'Full Short Pick'

                        IF NOT EXISTS (SELECT 1 
                                    FROM dbo.TaskDetail WITH (NOLOCK) 
                                    WHERE TaskDetailKey = @cTaskDetailKey AND Status = '9' AND ReasonKey='SHORT')
                        BEGIN
                           IF @nDebugFlag = 1
                              SELECT 'Mark the PickDetail as SHORT, mark taskDetail as CLOSED'

                           UPDATE dbo.PickDetail SET
                              Status = '4',
                              EditDate = GETDATE(),
                              EditWho  = SUSER_SNAME()
                           WHERE PickDetailKey = @cPickDetailKey
                           IF @@ERROR <> 0  
                           BEGIN  
                              SET @nErrNo = 234721  
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                              GOTO RollBackTran
                           END

                           UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                              Status = '9',
                              ReasonKey = 'SHORT',
                              EditDate = GETDATE(),  
                              EditWho  = SUSER_SNAME(),
                              TrafficCop = NULL
                           WHERE TaskDetailKey = @cTaskDetailKey
                           IF @@ERROR <> 0  
                           BEGIN  
                              SET @nErrNo = 258163  
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD Task Fail  
                              GOTO RollBackTran
                           END
                        END
                     END
                     ELSE --Partial Short Pick
                     BEGIN
                        IF @nDebugFlag = 1
                              SELECT 'Partial Short Pick'
                        SET @nSuccess = 1

                        IF NOT EXISTS (
                           SELECT 1 FROM DBO.TASKDETAIL WITH (NOLOCK) 
                           WHERE SourceKey = @cTaskDetailKey
                           AND TaskType = 'ASTCPK'
                           AND TransitCount > 0
                        )
                        BEGIN
                           IF @nDebugFlag = 1
                              SELECT 'Partial Short Pick, Create new picking task'

                           --Generate new TaskDetailKey for partial short pick
                           EXECUTE dbo.nspg_getkey
                              'TASKDETAILKEY'
                              , 10
                              , @cNewTaskDetailKey OUTPUT
                              , @nSuccess          OUTPUT
                              , @nErrNo            OUTPUT
                              , @cErrMsg           OUTPUT
                           IF @nSuccess <> 1
                           BEGIN
                              SET @nErrNo = 167751
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                              GOTO Fail
                           END

                           INSERT INTO TaskDetail (
                              TaskDetailKey, TaskType, Status, UserKey, PickMethod, TransitCount, AreaKey, SourceType, FromLOC, FromID, ToLOC, ToID, CaseID, DropID,
                              StorerKey, SKU, LOT, UOM,UOMQty, QTY, ListKey, SourceKey, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop, FinalLoc,ReasonKey
                              ,DeviceID)
                           SELECT
                              @cNewTaskDetailKey, TaskType, 
                              '9', --STATUS
                              '', PickMethod, 1, AreaKey, SourceType, FROMLOC, FROMID, TOLOC, ToID, CaseID, DropID,
                              StorerKey, SKU, LOT,UOM, @nQTY_PD - @nQTY_Bal, @nQTY_PD - @nQTY_Bal, ListKey, TaskDetailKey, WaveKey, LoadKey, Priority, SourcePriority, NULL, FinalLoc,
                              'SHORT',
                              ''
                           FROM TaskDetail WITH (NOLOCK)
                           WHERE TaskDetailKey = @cTaskDetailKey

                           --V1.1.3
                           BEGIN TRY
                              UPDATE dbo.PickDetail WITH (ROWLOCK)
                              SET 
                                 TaskDetailKey = @cNewTaskDetailKey,
                                 Status = '4',
                                 EditDate = GETDATE(), 
                                 EditWho  = SUSER_SNAME(),
                                 TrafficCop = NULL
                              WHERE PickDetailKey = @cPickDetailKey
                           END TRY
                           BEGIN CATCH
                              SET @nErrNo = 258168
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                              GOTO RollBackTran
                           END CATCH
                        END
                        ELSE
                        BEGIN
                           IF @nDebugFlag = 1
                              SELECT 'Partial Short Pick, Update existing picking task'

                           --v1.1.1 start
                           SELECT TOP 1 @cShortTaskDetailKey = TaskDetailKey 
                           FROM dbo.TASKDETAIL WITH (NOLOCK) 
                           WHERE SourceKey = @cTaskDetailKey
                              AND TaskType = 'ASTCPK'
                              AND TransitCount > 0
                           ORDER BY TaskDetailKey DESC
                           --v1.1.1 end

                           UPDATE dbo.TaskDetail WITH (ROWLOCK)
                           SET
                              QTY = QTY + @nQTY_PD - @nQTY_Bal,
                              UOMQty = UOMQty + @nQTY_PD - @nQTY_Bal, -- v1.1.1
                              EditDate = GETDATE(),  
                              EditWho  = SUSER_SNAME(),
                              TrafficCop = NULL
                           WHERE TaskDetailKey = @cShortTaskDetailKey

                           --v1.1.1 start
                           -- update the pickdetail to the new task detail
                           BEGIN TRY
                              UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                                 Status = '4',
                                 TaskDetailKey = @cShortTaskDetailKey,
                                 TrafficCop = NULL
                              WHERE PickDetailKey = @cPickDetailKey
                           END TRY
                           BEGIN CATCH
                              SET @nErrNo = 234720
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                              GOTO RollBackTran
                           END CATCH
                           --V1.1.1 end
                        END
                        SET @nPickedQty = 0

                        SELECT @nPickedQty = SUM(Qty)
                        FROM dbo.PICKDETAIL WITH(NOLOCK)
                        WHERE TaskDetailKey = @cTaskDetailKey
                           AND Status = @cPickConfirmStatus

                        IF @@ROWCOUNT = 0
                        BEGIN 
                           IF @cPickZone <> 'PICK'
                           BEGIN
                              SELECT @nPickedQty = SUM(PD.Qty)
                              FROM dbo.PickDetail PD WITH (NOLOCK) 
                              INNER JOIN dbo.TaskDetail TD WITH (NOLOCK) ON ( TD.StorerKey = PD.StorerKey AND TD.FromLoc = PD.Loc AND TD.Sku = PD.Sku AND TD.RefTaskKey = PD.TaskDetailKey AND TD.CaseID = PD.CaseID )
                              INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) 
                              WHERE PD.OrderKey = @cOrderKey 
                                 AND PD.LOC = @cLOC 
                                 AND PD.SKU = @cSKU 
                                 AND PD.CaseID = @cCaseID
                                 AND PD.QTY > 0 
                                 AND PD.Status = @cPickConfirmStatus 
                                 AND TD.TaskDetailKey = @cTaskDetailKey
                           END
                        END
                        
                        UPDATE dbo.TaskDetail SET
                           SystemQty = Qty, 
                           Qty = ISNULL(@nPickedQty, 0),
                           EditDate = GETDATE(),  
                           EditWho  = SUSER_SNAME()
                        WHERE TaskDetailKey = @cTaskDetailKey
                        IF @@ERROR <> 0  
                        BEGIN  
                           SET @nErrNo = 258156  
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                           GOTO RollBackTran  
                        END
                     END
                  END

                  EXEC ispGenTransmitLog2
                     @c_TableName        = 'WSSOAlloUpd'
                     ,@c_Key1             = @cOrderKey
                     ,@c_Key2             = @cPickDetailKey
                     ,@c_Key3             = @cStorerkey
                     ,@c_TransmitBatch    = ''
                     ,@b_Success          = @bSuccess   OUTPUT
                     ,@n_err              = @nErrNo     OUTPUT
                     ,@c_errmsg           = @cErrMsg    OUTPUT

                  IF @bSuccess <> 1
                     GOTO RollBackTran
               END  
            END  --Qty_bal=0
            ELSE  
            BEGIN -- Have balance, need to split
               IF @nDebugFlag = 1
                  SELECT 'Qty_PD > QTY_Bal, QTY_Bal > 0'
                 
               SET @nFullShortFlag = 0
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
                  SET @nErrNo = 258157  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- nspg_GetKey  
                  GOTO RollBackTran  
               END  
  
               -- Create new a PickDetail to hold the balance  
               INSERT INTO dbo.PickDetail (  
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, LOT, StorerKey, SKU, AltSKU, UOM,  
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup, CartonType,  
                  ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,  
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,  
                  PickDetailKey,  
                  Status,  
                  QTY,  
                  TrafficCop,  
                  OptimizeCop,
                  Channel_ID)  
               SELECT  
                  CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,  
                  UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,  
                  CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,  
                  EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,  
                  @cNewPickDetailKey,  
                  Status,  
                  @nQTY_PD - @nQTY_Bal, -- QTY  
                  NULL, -- TrafficCop  
                  '1',  -- OptimizeCop  
                  Channel_ID
               FROM dbo.PickDetail WITH (NOLOCK)  
               WHERE PickDetailKey = @cPickDetailKey  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 258158  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS PKDtl Fail  
                  GOTO RollBackTran  
               END  
  
               -- Split RefKeyLookup  
               IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cPickDetailKey)  
               BEGIN  
                  -- Insert into  
                  INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)  
                  SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey  
                  FROM RefKeyLookup WITH (NOLOCK)  
                  WHERE PickDetailKey = @cPickDetailKey  
                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @nErrNo = 258159  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS RefKeyFail  
                     GOTO RollBackTran  
                  END  
               END  
  
               -- Change orginal PickDetail with exact QTY (with TrafficCop)  
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
                  QTY = @nQTY_Bal,  
                  EditDate = GETDATE(),  
                  EditWho  = SUSER_SNAME(),  
                  Trafficcop = NULL  
               WHERE PickDetailKey = @cPickDetailKey  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 258160  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  GOTO RollBackTran  
               END  
  
               -- Confirm orginal PickDetail with exact QTY  
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
                  Status = @cPickConfirmStatus,  
                  DropID = @cDropID,
                  EditDate = GETDATE(),  
                  EditWho  = SUSER_SNAME()  
               WHERE PickDetailKey = @cPickDetailKey  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 258161  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  GOTO RollBackTran  
               END  
            
               -- Short pick
               IF @cType = 'SHORT'
               BEGIN
                  IF @cReasonCode <> 'SKIP' AND @nTransitCount = 0 --First time short pick
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT '1st time Short Pick'

                     IF NOT EXISTS (
                        SELECT 1 FROM DBO.TASKDETAIL WITH (NOLOCK) 
                        WHERE SourceKey = @cTaskDetailKey
                        AND TaskType = 'ASTCPK'
                        AND TransitCount > 0
                     )
                     BEGIN
                        IF @nDebugFlag = 1
                           SELECT '1st time Short Pick, Create new picking task'

                        SET @nSuccess = 1

                        EXECUTE dbo.nspg_getkey
                           'TASKDETAILKEY'
                           , 10
                           , @cNewTaskDetailKey OUTPUT
                           , @nSuccess          OUTPUT
                           , @nErrNo            OUTPUT
                           , @cErrMsg           OUTPUT
                        IF @nSuccess <> 1
                        BEGIN
                           SET @nErrNo = 167751
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                           GOTO Fail
                        END

                        INSERT INTO dbo.TaskDetail (
                           TaskDetailKey, TaskType, Status, UserKey, PickMethod, TransitCount, AreaKey, SourceType, FromLOC, FromID, ToLOC, ToID, 
                           StorerKey, SKU, LOT, UOM,UOMQty, QTY, ListKey, SourceKey, WaveKey, LoadKey, Priority, SourcePriority, TrafficCop, FinalLoc,ReasonKey
                           ,DeviceID,DropID,CaseID)
                        SELECT
                           @cNewTaskDetailKey, TaskType, 
                           '9', --STATUS
                           '', PickMethod, 1, AreaKey, SourceType, FROMLOC, FROMID, TOLOC, ToID, 
                           StorerKey, SKU, LOT, UOM,@nQTY_PD - @nQTY_Bal, @nQTY_PD - @nQTY_Bal, ListKey, TaskDetailKey, WaveKey, LoadKey, Priority, SourcePriority, NULL, FinalLoc,
                           'SHORT', --REASON CODE
                           '', @cOriginDropId,''
                        FROM dbo.TaskDetail WITH (NOLOCK)
                        WHERE TaskDetailKey = @cTaskDetailKey
                     END
                     ELSE
                     BEGIN
                        IF @nDebugFlag = 1
                           SELECT '1st time Short Pick, Update existing picking task'

                        --v1.1.1 start
                        SELECT TOP 1 @cShortTaskDetailKey = TaskDetailKey 
                        FROM dbo.TASKDETAIL WITH (NOLOCK) 
                        WHERE SourceKey = @cTaskDetailKey
                           AND TaskType = 'ASTCPK'
                           AND TransitCount > 0
                           ORDER BY TaskDetailKey DESC
                        --v1.1.1 end

                        UPDATE dbo.TaskDetail WITH (ROWLOCK)
                        SET
                           QTY = QTY + @nQTY_PD - @nQTY_Bal,
                           UOMQty = UOMQty + @nQTY_PD - @nQTY_Bal, -- v1.1.1
                           EditDate = GETDATE(),  
                           EditWho  = SUSER_SNAME(),
                           TrafficCop = NULL
                        WHERE TaskDetailKey = @cShortTaskDetailKey

                        --v1.1.2 start
                        SET @cNewTaskDetailKey = @cShortTaskDetailKey
                        --V1.1.2 end
                     END
                     -- Confirm PickDetail
                     UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                        UOMQty = Qty, --V1.1.1 
                        Status = '4',
                        TaskDetailKey = @cNewTaskDetailKey,
                        EditDate = GETDATE(), 
                        EditWho  = SUSER_SNAME(),
                        TrafficCop = NULL
                     WHERE PickDetailKey = @cNewPickDetailKey
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 258162
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                        GOTO RollBackTran
                     END                    
                  END

                  SET @nPickedQty = 0

                  SELECT @nPickedQty = SUM(Qty)
                  FROM dbo.PICKDETAIL WITH(NOLOCK)
                  WHERE TaskDetailKey = @cTaskDetailKey
                     AND Status = @cPickConfirmStatus

                  IF @@ROWCOUNT = 0
                  BEGIN 
                     IF @cPickZone <> 'PICK'
                     BEGIN
                        SELECT @nPickedQty = SUM(PD.Qty)
                        FROM dbo.PickDetail PD WITH (NOLOCK) 
                        INNER JOIN dbo.TaskDetail TD WITH (NOLOCK) ON ( TD.StorerKey = PD.StorerKey AND TD.FromLoc = PD.Loc AND TD.Sku = PD.Sku AND TD.RefTaskKey = PD.TaskDetailKey AND TD.CaseID = PD.CaseID )
                        INNER JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) 
                        WHERE PD.OrderKey = @cOrderKey 
                           AND PD.LOC = @cLOC 
                           AND PD.SKU = @cSKU 
                           AND PD.CaseID = @cCaseID
                           AND PD.QTY > 0 
                           AND PD.Status = @cPickConfirmStatus 
                           AND TD.TaskDetailKey = @cTaskDetailKey
                     END
                  END

                  UPDATE dbo.TaskDetail SET
                     SystemQty = Qty,
                     Qty = ISNULL(@nPickedQty, 0),
                     EditDate = GETDATE(),  
                     EditWho  = SUSER_SNAME()
                  WHERE TaskDetailKey = @cTaskDetailKey
                  IF @@ERROR <> 0  
                  BEGIN  
                     SET @nErrNo = 258163  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                     GOTO RollBackTran  
                  END  

                  EXEC ispGenTransmitLog2
                     @c_TableName        = 'WSSOAlloUpd'
                     ,@c_Key1             = @cOrderKey
                     ,@c_Key2             = @cNewPickDetailKey
                     ,@c_Key3             = @cStorerkey
                     ,@c_TransmitBatch    = ''
                     ,@b_Success          = @bSuccess   OUTPUT
                     ,@n_err              = @nErrNo     OUTPUT
                     ,@c_errmsg           = @cErrMsg    OUTPUT

                  IF @bSuccess <> 1      
                     GOTO RollBackTran
               END
  
               SET @nQTY_Bal = 0 -- Reduce balance  
            END  
         END

         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Handled PickDetail', @cPickDetailKey
            SELECT 'Pickdetail'
            SELECT * FROM dbo.PickDetail WITH (NOLOCK) WHERE PickDetailKey IN (@cPickDetailKey, @cNewPickDetailKey)
            SELECT 'TaskDetail'
            SELECT * FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey IN (@cTaskDetailKey, @cNewTaskDetailKey)
         END 

         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD  
      END --loop pickdetail
      CLOSE @curPD
      DEALLOCATE @curPD
      
      EXEC RDT.rdt_STD_EventLog  
         @cActionType   = '3', -- Picking  
         @cUserID       = @cUserName,  
         @nMobileNo     = @nMobile,  
         @nFunctionID   = @nFunc,  
         @cFacility     = @cFacility,  
         @cStorerKey    = @cStorerKey,  
         @cLocation     = @cLOC,  
         @cSKU          = @cSKU,  
         @nQTY          = @nQTY,  
         @cTaskDetailKey= @cTaskDetailKey,
         @cRefNo1       = @cType,  
         @cPickSlipNo   = @cPickSlipNo
   END --loop temptask
   
   DECLARE @@curUpdateTask CURSOR
   SET @@curUpdateTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
   SELECT TaskDetailKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE Storerkey = @cStorerKey
   AND   TaskType = 'ASTCPK'
   AND   [Status] = '3'
   AND   FromLoc = @cLOC
   AND   Sku = @cSKU
   AND   Caseid = @cCaseID
   AND   Groupkey = @cGroupKey
   AND   DeviceID = @cCartID 

   OPEN @@curUpdateTask
   FETCH NEXT FROM @@curUpdateTask INTO @cTaskKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @nDebugFlag = 1
         SELECT 'Update TaskDetail from 3 to 5', @cTaskKey

      UPDATE dbo.TaskDetail SET 
         [Status] = '5',
         EditDate = GETDATE(),
         EditWho = @cUserName
      WHERE TaskDetailKey = @cTaskKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 258164
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD Task Fail
         GOTO RollBackTran
      END      

      FETCH NEXT FROM @@curUpdateTask INTO @cTaskKey
   END

   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Finish confirm logic'
      SELECT 'Finished'
      SELECT * FROM TaskDetail (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey OR SourceKey  = @cTaskDetailKey AND TaskType = 'ASTCPK'
      SELECT * FROM PICKDETAIL (NOLOCK) WHERE TaskDetailKey IN (
      SELECT TaskDetailKey FROM TaskDetail (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey or SourceKey  = @cTaskDetailKey and TaskType = 'ASTCPK')
   END

  
GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN rdt_1855CfmSPManual -- Only rollback change made here  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  

Fail:
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1855CfmSPManual TO NSQL
GO
