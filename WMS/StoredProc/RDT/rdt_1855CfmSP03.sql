SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/
/* Store procedure: rdt_1855CfmSP03                                           */
/* Copyright      : Maersk                                                    */
/* Customer       : VIVOBAREFOOT                                              */
/*                                                                            */
/* Purpose: Confirm Pick                                                      */
/*                                                                            */
/* Called from: rdt_TM_Assist_ClusterPick                                     */
/*                                                                            */
/* Date         Rev    Author   Purposes                                      */
/* 2026-03-05   1.0.0  NLT013   FCR-10824 Created                             */
/******************************************************************************/
  
CREATE OR ALTER PROC rdt.rdt_1855CfmSP03 (
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

   DECLARE 
      @cPickDetailKey       NVARCHAR( 18),
      @cPickConfirmStatus   NVARCHAR( 1),
      @nQTY_Bal             INT,
      @nQTY_PD              INT,
      @bSuccess             INT,
      @nTranCount           INT,
      @curPD                CURSOR,
      @cSKU                 NVARCHAR( 20),
      @cLOC                 NVARCHAR( 10),
      @cDropID              NVARCHAR( 20),
      @cUserName            NVARCHAR( 18),
      @cWaveKey             NVARCHAR( 10),
      @nPickedQty           INT
   
   SELECT 
      @cUserName = UserName 
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
     
   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'
  
   -- For calculation
   SET @nQTY_Bal = @nQTY

   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1855CfmSP03 -- For rollback or commit only our own transaction

   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PD.PickDetailKey, PD.QTY, TD.DropID
      FROM dbo.TaskDetail TD WITH(NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey
      WHERE TD.TaskDetailKey = @cTaskDetailKey 
         AND TD.Storerkey = @cStorerKey
         AND TD.TaskType = 'ASTCPK'
         AND TD.Status = '3'
         AND TD.Groupkey = @cGroupKey
         AND TD.UserKey = @cUserName
         AND TD.DeviceID = @cCartID
         AND PD.Status < @cPickConfirmStatus
         AND PD.QTY > 0 
         AND PD.Status <> '4'

   OPEN @curPD

   -- Loop PickDetail
   FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD, @cDropID
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Exact match
      IF @nQTY_PD = @nQTY_Bal
      BEGIN
         -- Confirm PickDetail
         BEGIN TRY
            UPDATE dbo.PickDetail WITH (ROWLOCK)
            SET
               Status = @cPickConfirmStatus,
               DropID = @cDropID,
               EditDate = GETDATE(),
               EditWho  = @cUserName
            WHERE PickDetailKey = @cPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 260551
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update PickDetail failed

            CLOSE @curPD
            DEALLOCATE @curPD
            
            GOTO RollBackTran
         END CATCH

         SET @nQTY_Bal = 0 -- Reduce balance
      END
      -- PickDetail have less
      ELSE IF @nQTY_PD < @nQTY_Bal
      BEGIN  
         -- Confirm PickDetail
         BEGIN TRY
            UPDATE dbo.PickDetail WITH (ROWLOCK) SET  
               Status = @cPickConfirmStatus,
               DropID = @cDropID,
               EditDate = GETDATE(),
               EditWho  = @cUserName
            WHERE PickDetailKey = @cPickDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 260552
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update PickDetail failed

            CLOSE @curPD
            DEALLOCATE @curPD

            GOTO RollBackTran
         END CATCH

         SET @nQTY_Bal = @nQTY_Bal - @nQTY_PD -- Reduce balance
      END  
      -- PickDetail have more
      ELSE IF @nQTY_PD > @nQTY_Bal
      BEGIN
         -- Don't need to split
         IF @nQTY_Bal = 0
         BEGIN
            -- Short pick
            IF @cType = 'SHORT' -- Don't need to split
            BEGIN  
               -- Confirm PickDetail
               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                     Status = '4',
                     EditDate = GETDATE(),
                     EditWho  = @cUserName,
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 260553
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update PickDetail failed

                  CLOSE @curPD
                  DEALLOCATE @curPD

                  GOTO RollBackTran
               END CATCH

               SELECT @nPickedQty = SUM(Qty)
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskDetailKey
                  AND Status = @cPickConfirmStatus

               BEGIN TRY
                  UPDATE dbo.TaskDetail SET
                     SystemQty = Qty,
                     Qty = ISNULL(@nPickedQty, 0),
                     EditDate = GETDATE(),
                     EditWho  = @cUserName
                  WHERE TaskDetailKey = @cTaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 260554
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update TaskDetail failed

                  CLOSE @curPD
                  DEALLOCATE @curPD

                  GOTO RollBackTran
               END CATCH
            END  
         END  
         ELSE  
         BEGIN -- Have balance, need to split
            -- Get new PickDetailkey  
            DECLARE @cNewPickDetailKey NVARCHAR( 10)
            EXECUTE dbo.nspg_GetKey
               'PICKDETAILKEY',
               10 ,
               @cNewPickDetailKey OUTPUT,
               @bSuccess          OUTPUT,
               @nErrNo            OUTPUT,
               @cErrMsg           OUTPUT

            IF @nErrNo <> 0
            BEGIN
               CLOSE @curPD
               DEALLOCATE @curPD

               GOTO RollBackTran
            END

            IF @bSuccess <> 1
            BEGIN  
               SET @nErrNo = 260555
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Generate PickDetailKey failed

               CLOSE @curPD
               DEALLOCATE @curPD

               GOTO RollBackTran
            END  

            -- Create new a PickDetail to hold the balance
            BEGIN TRY
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
            END TRY
               BEGIN CATCH
                  SET @nErrNo = 260556
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert PickDetail failed

                  CLOSE @curPD
                  DEALLOCATE @curPD

                  GOTO RollBackTran
               END CATCH

            -- Split RefKeyLookup  
            IF EXISTS( SELECT 1 FROM RefKeyLookup WITH (NOLOCK) WHERE PickDetailKey = @cPickDetailKey)  
            BEGIN  
               -- Insert into RefKeyLookup
               BEGIN TRY
                  INSERT INTO dbo.RefKeyLookup (PickDetailkey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey)
                  SELECT @cNewPickDetailKey, PickSlipNo, OrderKey, OrderLineNumber, Loadkey
                  FROM RefKeyLookup WITH (NOLOCK)
                  WHERE PickDetailKey = @cPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 260557
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert RefKeyLookup failed

                  CLOSE @curPD
                  DEALLOCATE @curPD

                  GOTO RollBackTran  
               END CATCH
            END  

            -- Change orginal PickDetail with exact QTY (with TrafficCop)
            BEGIN TRY
               UPDATE dbo.PickDetail WITH (ROWLOCK)
               SET
                  QTY = @nQTY_Bal,
                  EditDate = GETDATE(),
                  EditWho  = @cUserName,
                  Trafficcop = NULL
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 260558
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PickDetail failed

               CLOSE @curPD
               DEALLOCATE @curPD

               GOTO RollBackTran
            END CATCH

            -- Confirm orginal PickDetail with exact QTY
            BEGIN TRY
               UPDATE dbo.PickDetail WITH (ROWLOCK) 
               SET
                  Status = @cPickConfirmStatus,
                  DropID = @cDropID,
                  EditDate = GETDATE(),
                  EditWho  = @cUserName
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 260559
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PickDetail failed

               CLOSE @curPD
               DEALLOCATE @curPD

               GOTO RollBackTran
            END CATCH

            -- Short pick
            IF @cType = 'SHORT'
            BEGIN
               -- Confirm PickDetail
               BEGIN TRY
                  UPDATE dbo.PickDetail WITH (ROWLOCK)
                  SET
                     Status = '4',
                     EditDate = GETDATE(), 
                     EditWho  = @cUserName,
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cNewPickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 260560
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PickDetail failed

                  CLOSE @curPD
                  DEALLOCATE @curPD

                  GOTO RollBackTran
               END CATCH

               SELECT @nPickedQty = SUM(Qty)
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskDetailKey
                  AND STatus = @cPickConfirmStatus

               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH(ROWLOCK)
                  SET
                     SystemQty = Qty,
                     Qty = ISNULL(@nPickedQty, 0),
                     EditDate = GETDATE(),
                     EditWho  = @cUserName
                  WHERE TaskDetailKey = @cTaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 260561
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update TaskDetail failed

                  CLOSE @curPD
                  DEALLOCATE @curPD

                  GOTO RollBackTran
               END CATCH
            END

            SET @nQTY_Bal = 0 -- Reduce balance
         END
      END
      FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD, @cDropID
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
      @cPickSlipNo   = ''

   
   
   BEGIN TRY
      UPDATE dbo.TaskDetail WITH(ROWLOCK)
      SET
         Status = '5',
         EditDate = GETDATE(),
         EditWho = @cUserName
      WHERE TaskDetailKey = @cTaskDetailKey
   END TRY
   BEGIN CATCH
      SET @nErrNo = 260562
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update TaskDetail failed
      GOTO RollBackTran
   END CATCH

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1855CfmSP03 -- Only rollback change made here  
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

GRANT EXECUTE ON RDT.rdt_1855CfmSP03 TO NSQL
GO
