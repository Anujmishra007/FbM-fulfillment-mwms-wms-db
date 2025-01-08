
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/******************************************************************************/  
/* Store procedure: rdt_1867Confirm01                                         */  
/* Copyright      : Maersk                                                    */  
/*                                                                            */  
/* Purpose: Confirm Pick                                                      */
/*                         For HuSQ                                           */
/* Called from: rdt_TM_Assist_ClusterPick_ConfirmPickV2                       */
/*                                                                            */
/* Date         Rev   Author    Purposes                                      */
/* 2024-10-10   1.0   JHU151    FCR-777 Created                               */
/* 2024-12-27   1.1.0 Dennis    FCR-1872 Remove Lot                           */ 
/******************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_1867Confirm01 (  
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
    @cSerialNo       NVARCHAR( 30),
    @nSerialQTY      INT,
    @nBulkSNO        INT,
    @nBulkSNOQTY     INT,
    @nErrNo          INT           OUTPUT,  
    @cErrMsg         NVARCHAR(250) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cSQL        NVARCHAR( MAX)  
   DECLARE @cSQLParam   NVARCHAR( MAX)  
   DECLARE @nTranCount  INT  
   DECLARE @nTaskQty    INT =0 


   DECLARE @cOrderKey      NVARCHAR( 10)  
   DECLARE @cLoadKey       NVARCHAR( 10)  
   DECLARE @cZone          NVARCHAR( 18)  
   DECLARE @cPickDetailKey NVARCHAR( 18)  
   DECLARE @cPickConfirmStatus NVARCHAR( 1)  
   DECLARE @nQTY_Bal       INT  
   DECLARE @nQTY_PD        INT 
   DECLARE @nTotalPkdSN    INT 
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
   DECLARE @cNewPickDetailKey    NVARCHAR( 10)
   DECLARE @cNewTaskDetailKey    NVARCHAR( 10)
   DECLARE @cUserDefine10        NVARCHAR( 10)
   DECLARE @cMethod        NVARCHAR( 1)

   SELECT 
      @cUserName = UserName 
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   SELECT 
      @cSKU = SKU, 
      @cCaseID = CaseID,
      @cFromLoc = FromLoc
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey
         
   INSERT INTO TRACEINFO (TraceName, TimeIn, Col1, Col2, Col3, Col4, Col5) VALUES ('1867', GETDATE(), @cUserName, @cSKU, @cCaseID, @cLOC, @cTaskDetailKey)
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

   IF @cSerialNo <> ''
   BEGIN
      /**
     NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PickSerialNo')
      CREATE TABLE dbo.PickSerialNo
      (
         PickSerialNoKey      BIGINT        NOT NULL IDENTITY( 1, 1), 
         PickDetailKey        NVARCHAR(18)  NOT NULL,
         StorerKey            NVARCHAR(15)  NOT NULL, 
         SKU                  NVARCHAR(20)  NOT NULL, 
         SerialNo             NVARCHAR(30)  NOT NULL, 
         QTY                  INT           NOT NULL, 
         -- ID                   NVARCHAR(18) NOT NULL, 
         AddWho               NVARCHAR(128) NOT NULL CONSTRAINT DF_PickSerialNo_AddWho   DEFAULT (SUSER_SNAME()), 
         AddDate              DATETIME      NOT NULL CONSTRAINT DF_PickSerialNo_AddDate  DEFAULT (GETDATE()), 
         EditWho              NVARCHAR(128) NOT NULL CONSTRAINT DF_PickSerialNo_EditWho  DEFAULT (SUSER_SNAME()), 
         EditDate             DATETIME      NOT NULL CONSTRAINT DF_PickSerialNo_EditDate DEFAULT (GETDATE()), 
         TrafficCop           NVARCHAR( 1)  NULL, 
         ArchiveCop           NVARCHAR( 1)  NULL, 
         CONSTRAINT PK_PickSerialNo PRIMARY KEY CLUSTERED (PickSerialNoKey)
      )
      **/
      BEGIN TRAN  -- Begin our own transaction  
      SAVE TRAN ConfirmPick -- For rollback or commit only our own transaction 
 
      SELECT TOP 1 
         @cTaskDetailKey = TD.TaskDetailKey, 
         @cSKU = TD.Sku, 
         @cCaseID = TD.Caseid, 
         @cLOC = TD.FromLoc, 
         @cDropID = TD.DropID, 
         @cOrderKey = PD.OrderKey,
         @cPickDetailKey = PD.PickDetailkey,
         @nQTY_PD = PD.Qty
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
      AND   TD.TaskDetailKey = @cTaskDetailKey
      ORDER BY 1

      -- Check pick task
      IF @cPickDetailKey = ''
      BEGIN
         SET @nErrNo = 227251
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No pick task
         GOTO RollBackTran
      END

      -- Split PickDetail
      IF @nQTY_PD > @nSerialQTY
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
            SET @nErrNo = 227251
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
            Channel_ID )      --(cc01)
         SELECT
            CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot, StorerKey, SKU, AltSku, UOM,
            UOMQTY, QTYMoved, DropID, LOC, ID, PackKey, UpdateSource, CartonGroup,
            CartonType, ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod, WaveKey,
            EffectiveDate, ArchiveCop, ShipFlag, PickSlipNo, TaskDetailKey, TaskManagerReasonKey, Notes,
            @cNewPickDetailKey,
            Status,
            @nQTY_PD - @nSerialQTY, -- QTY
            NULL, -- TrafficCop
            '1',   -- OptimizeCop
            Channel_ID --(cc01)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE PickDetailKey = @cPickDetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 227253
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
               SET @nErrNo = 227254
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS RefKeyFail
               GOTO RollBackTran
            END
         END

         -- Change orginal PickDetail with exact QTY (with TrafficCop)
         UPDATE dbo.PickDetail WITH (ROWLOCK) SET
            QTY = @nSerialQTY,
            EditDate = GETDATE(),
            EditWho  = SUSER_SNAME(),
            Trafficcop = NULL
         WHERE PickDetailKey = @cPickDetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 204808
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
            GOTO RollBackTran
         END
      END


      -- Confirm PickDetail
      UPDATE dbo.PickDetail WITH (ROWLOCK) SET
         Status = @cPickConfirmStatus,
         DropID = @cDropID,
         EditDate = GETDATE(),
         EditWho  = SUSER_SNAME()
      WHERE PickDetailKey = @cPickDetailKey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 227255
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
         GOTO RollBackTran
      END
      
      -- Insert PickSerialNo
      INSERT INTO PickSerialNo (PickDetailKey, StorerKey, SKU, SerialNo, QTY)
      VALUES (@cPickDetailKey, @cStorerKey, @cSKU, @cSerialNo, @nSerialQTY)
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 227256
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- INS RDSNo Fail
         GOTO RollBackTran
      END
      
      IF EXISTS(SELECT 1 FROM dbo.SerialNo WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
         AND SKU = @cSKU
         AND SerialNo = @cSerialNo)
      BEGIN
         -- Posting to serial no
         UPDATE dbo.SerialNo SET
            Status = '5', 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME(), 
            TrafficCop = NULL
         WHERE StorerKey = @cStorerKey
            AND SKU = @cSKU
            AND SerialNo = @cSerialNo
         IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
         BEGIN
            SET @nErrNo = 227257
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD SNO Fail
            GOTO RollBackTran
         END
      END

      IF NOT EXISTS(SELECT 1 FROM PickDetail WITH(NOLOCK)
                     WHERE TaskdetailKey = @cTaskDetailKey
                     AND status < '5')
      BEGIN
         UPDATE dbo.TaskDetail SET 
               [Status] = '5',
               EditDate = GETDATE(),
               EditWho = @cUserName
         WHERE TaskDetailKey = @cTaskDetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 227270
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD Task Fail
            GOTO RollBackTran
         END
      END
   END
   ELSE-- non serial no
   BEGIN
      
      BEGIN TRAN  -- Begin our own transaction  
      SAVE TRAN ConfirmPick -- For rollback or commit only our own transaction  
      
      SET @curCfmTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
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
      AND   TD.TaskDetailKey = @cTaskDetailKey
      ORDER BY 1
      OPEN @curCfmTask
      FETCH NEXT FROM @curCfmTask INTO @cTaskDetailKey, @cSKU, @cCaseID, @cLOC, @cDropID, @cOrderKey
      WHILE @@FETCH_STATUS = 0  
      BEGIN
         IF ISNULL( @cOrderKey, '') = ''
         BEGIN  
            SET @nErrNo = 227258  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pick Not Found  
            GOTO RollBackTran  
         END 

         SELECT @cLoadKey = LoadKey,
                @cUserDefine10 = UserDefine10
         FROM dbo.ORDERS WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey

         SELECT @cPickSlipNo = PickheaderKey
         FROM dbo.PICKHEADER WITH (NOLOCK) 
         WHERE OrderKey = @cOrderKey 

         IF EXISTS (
                  SELECT  1  
                  FROM CodeLKUP WITH(NOLOCK) 
                  WHERE LISTNAME = 'HUSQPKTYPE' 
                  AND Code2 = '' 
                  AND StorerKey = @cStorerKey
                  AND short = @cUserDefine10)
         Begin
            SET @cMethod = '3'
         END

         IF ISNULL( @cLoadKey, '') = ''
         BEGIN  
            SET @nErrNo = 227259  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No LoadKey  
            GOTO RollBackTran  
         END 

         IF ISNULL( @cPickSlipNo, '') = ''
            SELECT @cPickSlipNo = PickheaderKey FROM dbo.PICKHEADER WITH (NOLOCK) WHERE LoadKey = @cLoadKey

         IF ISNULL( @cPickSlipNo, '') = ''
            SELECT @cPickSlipNo = PickheaderKey FROM dbo.PICKHEADER WITH (NOLOCK) WHERE ExternOrderKey = @cLoadKey

         IF ISNULL( @cPickSlipNo, '') = ''
         BEGIN  
            SET @nErrNo = 227260  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No Pickslip  
            GOTO RollBackTran  
         END 

         /**
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
         **/

         SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
         SELECT PD.PickDetailKey, PD.QTY 
         FROM dbo.PickDetail PD WITH (NOLOCK) 
         JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) 
         WHERE PD.LOC = @cLOC 
         AND   PD.SKU = @cSKU 
         AND   PD.CaseID = @cCaseID
         AND   PD.QTY > 0 
         AND   PD.Status <> '4' 
         AND   PD.Status < @cPickConfirmStatus 
         AND   PD.TaskDetailKey = @cTaskDetailKey
         ORDER BY CASE WHEN PD.QTY - @nQTY_Bal >=0 THEN 0 ELSE 1 END, ABS(PD.QTY - @nQTY_Bal)

         OPEN @curPD

         -- Loop PickDetail  
         FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD  
         WHILE @@FETCH_STATUS = 0  
         BEGIN

            -- Exact match  
            IF @nQTY_PD = @nQTY_Bal  
            BEGIN  
               -- Confirm PickDetail  
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
                  Status = @cPickConfirmStatus, 
                  DropID = @cDropID,
                  EditDate = GETDATE(),  
                  EditWho  = SUSER_SNAME()  
               WHERE PickDetailKey = @cPickDetailKey  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 227261  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  GOTO RollBackTran  
               END  
   
               SET @nQTY_Bal = 0 -- Reduce balance  
            END  
   
            -- PickDetail have less  
            ELSE IF @nQTY_PD < @nQTY_Bal  
            BEGIN  
               -- Confirm PickDetail  
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
                  Status = @cPickConfirmStatus,
                  DropID = @cDropID,
                  EditDate = GETDATE(),  
                  EditWho  = SUSER_SNAME()  
               WHERE PickDetailKey = @cPickDetailKey  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 227262  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  GOTO RollBackTran  
               END  
   
               SET @nQTY_Bal = @nQTY_Bal - @nQTY_PD -- Reduce balance  
               SET @nTaskQty = @nTaskQty + @nQTY_PD
            END  
   
            -- PickDetail have more  
            ELSE IF @nQTY_PD > @nQTY_Bal  
            BEGIN  
               -- Don't need to split  
               IF @nQTY_Bal = 0  
               BEGIN  
                  -- -- Short pick  
                  -- IF @cType = 'SHORT' -- Don't need to split  
                  -- BEGIN  
                  --    -- Confirm PickDetail  
                  --    UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
                  --       Status = '4',  
                  --       EditDate = GETDATE(),  
                  --       EditWho  = SUSER_SNAME(),  
                  --       TrafficCop = NULL  
                  --    WHERE PickDetailKey = @cPickDetailKey  
                  --    IF @@ERROR <> 0  
                  --    BEGIN  
                  --       SET @nErrNo = 171955  
                  --       SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  --       GOTO RollBackTran  
                  --    END  
                     
                  --    UPDATE dbo.TaskDetail SET
                  --       SystemQty = Qty, 
                  --       Qty = @nQTY_Bal,  
                  --       EditDate = GETDATE(),  
                  --       EditWho  = SUSER_SNAME()
                  --    WHERE TaskDetailKey = @cTaskDetailKey
                  --    IF @@ERROR <> 0  
                  --    BEGIN  
                  --       SET @nErrNo = 227263  
                  --       SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  --       GOTO RollBackTran  
                  --    End

                  --    -- mutiple pickdetail in same taskdetailkey
                  --    IF EXISTS(SELECT 1 FROM PickDetail PD WITH(NOLOCK)
                  --                WHERE storerkey = @cStorerkey
                  --                AND TaskDetailKey = @cTaskDetailKey
                  --                AND status <> '4')
                  --    BEGIN                        
                  --       EXECUTE dbo.nspg_getkey
                  --       'TaskDetailKey'
                  --       , 10
                  --       , @cNewTaskDetailKey OUTPUT
                  --       , @bSuccess OUTPUT
                  --       , @nErrNo     --OUTPUT Commented by NLT013, it overrides the old error no, if the error was not 0, but no error happens while executing this SP, error no will be updated as 0
                  --       , @cErrMsg OUTPUT

                  --       IF NOT @bSuccess = 1
                  --       BEGIN
                  --          SET @nErrNo = 227271
                  --          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKeyFailed(rdt_1867Confirm01)
                  --          GOTO RollBackTran 
                  --       END

                  --       INSERT INTO dbo.TaskDetail
                  --       (TaskDetailKey,TaskType,Storerkey,Sku,Lot,UOM,UOMQty,QTY,FromLoc,LogicalFromLoc,FromID,ToLoc,LogicalToLoc
                  --       ,ToID,Caseid,PickMethod,Status,StatusMsg,Priority,SourcePriority,Holdkey,UserKey,UserPosition,UserKeyOverRide
                  --       ,StartTime,EndTime,SourceType,SourceKey,PickDetailKey,OrderKey,OrderLineNumber,ListKey,WaveKey,ReasonKey
                  --       ,Message01,Message02,Message03,RefTaskKey,LoadKey,AreaKey,DropID, SystemQty,Groupkey,TrafficCop)
                  --       SELECT  TOP 1
                  --       @cNewTaskDetailKey,TaskType,Storerkey,Sku,Lot,UOM,UOMQty,QTY-@nQTY_Bal,FromLoc,LogicalFromLoc,FromID,ToLoc,LogicalToLoc
                  --       ,ToID,Caseid,PickMethod,Status,StatusMsg,Priority,SourcePriority,Holdkey,UserKey,UserPosition,UserKeyOverRide
                  --       ,StartTime,EndTime,SourceType,SourceKey,PickDetailKey,OrderKey,OrderLineNumber,ListKey,WaveKey,ReasonKey
                  --       ,Message01,Message02,Message03,RefTaskKey,LoadKey,AreaKey,DropID, SystemQty,GroupKey,'9'
                  --       FROM dbo.TaskDetail WITH (NOLOCK)
                  --       WHERE Taskdetailkey = @cTaskDetailKey
                  --       AND Storerkey = @cStorerkey
                        
                  --       IF @@ERROR <> 0
                  --       BEGIN
                  --          SET @nErrNo = 227272
                  --          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsTaskFailed
                  --          GOTO RollBackTran 
                  --       END

                  --       UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
                  --          EditDate = GETDATE(),  
                  --          EditWho  = SUSER_SNAME(),  
                  --          taskdetailkey = @cNewTaskDetailKey
                  --       WHERE PickDetailKey = @cPickDetailKey

                  --       IF @@ERROR <> 0  
                  --       BEGIN  
                  --          SET @nErrNo = 171955  
                  --          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  --          GOTO RollBackTran  
                  --       END
                        
                  --       UPDATE dbo.TaskDetail SET                           
                  --          RefTaskKey = @cNewTaskDetailKey,
                  --          EditDate = GETDATE(),  
                  --          EditWho  = SUSER_SNAME()
                  --       WHERE TaskDetailKey = @cTaskDetailKey
                  --       IF @@ERROR <> 0  
                  --       BEGIN  
                  --          SET @nErrNo = 227263  
                  --          SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                  --          GOTO RollBackTran  
                  --       End
                  --    END
                  -- END  
                  print 1
               END  
               ELSE  
               BEGIN -- Have balance, need to split                                         
                  
                  EXECUTE dbo.nspg_GetKey  
                     'PICKDETAILKEY',  
                     10 ,  
                     @cNewPickDetailKey OUTPUT,  
                     @bSuccess          OUTPUT,  
                     @nErrNo            OUTPUT,  
                     @cErrMsg           OUTPUT  
                  IF @bSuccess <> 1  
                  BEGIN  
                     SET @nErrNo = 227264  
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
                     SET @nErrNo = 227265  
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
                        SET @nErrNo = 227266  
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
                     SET @nErrNo = 171959  
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
                     SET @nErrNo = 227267  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                     GOTO RollBackTran  
                  END  

                  EXECUTE dbo.nspg_getkey
                     'TaskDetailKey'
                     , 10
                     , @cNewTaskDetailKey OUTPUT
                     , @bSuccess OUTPUT
                     , @nErrNo     --OUTPUT Commented by NLT013, it overrides the old error no, if the error was not 0, but no error happens while executing this SP, error no will be updated as 0
                     , @cErrMsg OUTPUT

                  IF NOT @bSuccess = 1
                  BEGIN
                     SET @nErrNo = 227271
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKeyFailed(rdt_1867Confirm01)
                     GOTO RollBackTran 
                  END

                  INSERT INTO dbo.TaskDetail
                  (TaskDetailKey,TaskType,Storerkey,Sku,Lot,UOM,UOMQty,QTY,FromLoc,LogicalFromLoc,FromID,ToLoc,LogicalToLoc
                  ,ToID,Caseid,PickMethod,Status,StatusMsg,Priority,SourcePriority,Holdkey,UserKey,UserPosition,UserKeyOverRide
                  ,StartTime,EndTime,SourceType,SourceKey,PickDetailKey,OrderKey,OrderLineNumber,ListKey,WaveKey,ReasonKey
                  ,Message01,Message02,Message03,RefTaskKey,LoadKey,AreaKey,DropID, SystemQty,Groupkey,DeviceID)
                  SELECT  TOP 1
                  @cNewTaskDetailKey,TaskType,Storerkey,Sku,Lot,UOM,UOMQty,Qty - @nTaskQty - @nQTY_Bal,FromLoc,LogicalFromLoc,FromID,ToLoc,LogicalToLoc
                  ,ToID,Caseid,PickMethod,Status,StatusMsg,Priority,SourcePriority,Holdkey,UserKey,UserPosition,UserKeyOverRide
                  ,StartTime,EndTime,SourceType,SourceKey,PickDetailKey,OrderKey,OrderLineNumber,ListKey,WaveKey,ReasonKey
                  ,Message01,Message02,Message03,RefTaskKey,LoadKey,AreaKey,DropID, Qty - @nTaskQty - @nQTY_Bal,GroupKey,DeviceID
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE Taskdetailkey = @cTaskDetailKey
                  AND Storerkey = @cStorerkey
                  
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 227272
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsTaskFailed
                     GOTO RollBackTran 
                  END
                  
                  -- Short pick
                  IF @cType = 'SHORT'
                  BEGIN                                       
                     -- Confirm PickDetail
                     UPDATE dbo.PickDetail WITH (ROWLOCK) SET 
                        Status = '4',
                        EditDate = GETDATE(), 
                        EditWho  = SUSER_SNAME(),
                        TrafficCop = NULL,
                        TaskDetailKey = @cNewTaskDetailKey
                     WHERE PickDetailKey = @cNewPickDetailKey
                     OR (TaskDetailKey = @cTaskDetailKey AND Status <> '5' AND PickDetailKey <> @cPickDetailKey)
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 227268
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                        GOTO RollBackTran
                     END

                     UPDATE dbo.TaskDetail SET
                        SystemQty = @nQTY_Bal+@nTaskQty, 
                        Qty = @nQTY_Bal+@nTaskQty,  
                        EditDate = GETDATE(),  
                        EditWho  = SUSER_SNAME(),
                        RefTaskKey = @cNewTaskDetailKey
                     WHERE TaskDetailKey = @cTaskDetailKey
                     IF @@ERROR <> 0  
                     BEGIN  
                        SET @nErrNo = 227269  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                        GOTO RollBackTran  
                     END  
                  END
                  ELSE
                  Begin
                     UPDATE dbo.TaskDetail SET
                        SystemQty = Qty, 
                        Qty = @nQTY_Bal,  
                        EditDate = GETDATE(),  
                        EditWho  = SUSER_SNAME()
                     WHERE TaskDetailKey = @cTaskDetailKey
                     IF @@ERROR <> 0  
                     BEGIN  
                        SET @nErrNo = 227263  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail  
                        GOTO RollBackTran  
                     End
                     
                     -- Confirm PickDetail
                     UPDATE dbo.PickDetail WITH (ROWLOCK) SET 
                        EditDate = GETDATE(), 
                        EditWho  = SUSER_SNAME(),
                        TrafficCop = NULL,
                        TaskDetailKey = @cNewTaskDetailKey
                     WHERE PickDetailKey = @cNewPickDetailKey
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 227268
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                        GOTO RollBackTran
                     END
                  END

                  SET @nQTY_Bal = 0 -- Reduce balance  
               END  
            END  

            FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD  
         END  
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

         FETCH NEXT FROM @curCfmTask INTO @cTaskDetailKey, @cSKU, @cCaseID, @cLOC, @cDropID, @cOrderKey
      END
      
      /**
      DECLARE @curUpdTask CURSOR
      SET @curUpdTask = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
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
      AND   TaskdetailKey = @cTaskDetailKey

      OPEN @curUpdTask
      FETCH NEXT FROM @curUpdTask INTO @cTaskKey
      WHILE @@FETCH_STATUS = 0
      BEGIN
         UPDATE dbo.TaskDetail SET 
            [Status] = '5',
            EditDate = GETDATE(),
            EditWho = @cUserName
         WHERE TaskDetailKey = @cTaskKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 227270
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD Task Fail
            GOTO RollBackTran
         END      

         FETCH NEXT FROM @curUpdTask INTO @cTaskKey
      END
      **/       

      UPDATE dbo.TaskDetail SET 
         [Status] = '5',
         EditDate = GETDATE(),
         EditWho = @cUserName
      WHERE TaskDetailKey = @cTaskDetailKey
      AND NOT EXISTS(SELECT 1 FROM Pickdetail PD WITH(NOLOCK)
                        WHERE Taskdetail.taskdetailkey = PD.taskdetailkey
                         AND PD.status = '0')
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 227270
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD Task Fail
         GOTO RollBackTran
      END  


   END-- non serial no

   --COMMIT TRAN ConfirmPick  
  
 
   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN ConfirmPick -- Only rollback change made here  
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

GRANT EXECUTE ON RDT.rdt_1867Confirm01 TO NSQL
GO
