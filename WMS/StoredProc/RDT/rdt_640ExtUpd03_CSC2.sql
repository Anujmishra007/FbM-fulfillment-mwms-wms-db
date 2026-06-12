
/*****************************************************************************************/
/* Store procedure: rdt_640ExtUpd03_CSC2                                                 */
/*                                                                                       */
/* Purpose:  Update PICKDETAIL DropID = CaseID in Dynamic PickFace for UOM 6 or 7        */
/*                                                                                       */
/* Date         Author   Purposes                                                        */
/* 27/03/2026   Huhu Li   Create                                                         */
/* 07/04/2026   AGA399    Pickdetail Update for Skipped Task SIZE and SHORT              */
/*                                                                                       */
/*****************************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_640ExtUpd03_CSC2]
 @nMobile        INT,
 @nFunc          INT,
 @cLangCode      NVARCHAR( 3),
 @nStep          INT,
 @nInputKey      INT,
 @cFacility      NVARCHAR( 5),
 @cStorerKey     NVARCHAR( 15),
 @cGroupKey      NVARCHAR( 10),
 @cTaskDetailKey NVARCHAR( 10),
 @cCartId        NVARCHAR( 10),
 @cFromLoc       NVARCHAR( 10),
 @cCartonId      NVARCHAR( 20),
 @cSKU           NVARCHAR( 20),
 @nQty           INT,
 @cOption        NVARCHAR( 1),
 @tExtUpdate     VariableTable READONLY,
 @nErrNo         INT           OUTPUT,
 @cErrMsg        NVARCHAR( 20) OUTPUT
AS
BEGIN
 SET NOCOUNT ON
 SET QUOTED_IDENTIFIER OFF
 SET ANSI_NULLS OFF
 SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE @nTranCount        INT
 DECLARE @cUserName         NVARCHAR( 18)
 DECLARE @cChkTaskDetailKey NVARCHAR( 10)
 DECLARE @cPalletId         NVARCHAR( 18)
 DECLARE @cWaveKey          NVARCHAR( 10)
 DECLARE @cCaseId           NVARCHAR( 20)
 DECLARE @cOrderKey         NVARCHAR( 12)
 DECLARE @n                 INT = 1
 DECLARE @cTaskKey          NVARCHAR( 10)
 DECLARE @cPickDetailKey    NVARCHAR( 18)
 DECLARE @cNewPickDetailKey NVARCHAR( 10)
 DECLARE @bSuccess          INT


 SELECT
    @cUserName = UserName
 FROM RDT.RDTMOBREC WITH (NOLOCK)
 WHERE Mobile = @nMobile

 -- Handling transaction
 SET @nTranCount = @@TRANCOUNT
 BEGIN TRAN  -- Begin our own transaction
 SAVE TRAN rdt_640ExtUpd03_CSC2 -- For rollback or commit only our own transaction

 IF @nStep = 10 AND @nFunc='640' AND @nInputKey = 1 -- ENTER
 BEGIN
    IF EXISTS ( SELECT 1 FROM dbo.TaskDetail TD WITH (NOLOCK)
    WHERE TD.Storerkey=@cStorerKey and TD.TaskDetailKey=@cTaskDetailKey
    AND TD.ReasonKey IN ('SIZE','SHORT0'))
    BEGIN
        SELECT TOP 1 @cPickDetailKey=PickDetailKey
        FROM pickdetail WITH (NOLOCK)
        WHERE storerkey=@cStorerKey AND taskdetailkey=@cTaskDetailKey --find PickDetailKey

             -- Update PickDetail
             UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                Status = '4',
                EditDate = GETDATE(),
                EditWho  = SUSER_SNAME(),
                TrafficCop = NULL
             WHERE PickDetailKey = @cPickDetailKey  AND Status = '0'
             IF @@ERROR <> 0
             BEGIN
                SET @nErrNo = 149005
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                GOTO RollBackTran
             END
    END
 END

 IF @nStep = 8 AND @nFunc='640'
 BEGIN
    IF isnull(@cTaskDetailKey,'')<>''
    BEGIN
 SELECT TOP 1
    @cGroupKey = Groupkey,
    @cCartID = DeviceID
 FROM dbo.TaskDetail WITH (NOLOCK)
 WHERE TaskDetailKey = @cTaskDetailKey
 ORDER BY 1
 DECLARE @cur CURSOR
 SET @cur = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
 SELECT TaskdetailKey
 FROM dbo.TASKDETAIL WITH (NOLOCK)
 WHERE Groupkey = @cGroupKey
 AND   DeviceID = @cCartID
 AND   [Status] >= '5'
 OPEN @cur
 FETCH NEXT FROM @cur INTO @cTaskKey
 WHILE @@FETCH_STATUS = 0
 BEGIN
  IF EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
        WHERE Storerkey = @cStorerKey
        --AND   WaveKey = @cWaveKey
   AND TaskDetailKey=@cTaskKey
    AND   TaskType in('CPK'))   --Only update when picked completed for taskdetail
  Begin
   IF EXISTS ( SELECT 1 FROM pickdetail PD WITH (NOLOCK)
    WHERE PD.storerkey=@cStorerKey and PD.taskdetailkey=@cTaskKey
    AND PD.DropID<>PD.CaseID AND PD.UOM in ('6','7') and PD.Status>'4')
   BEGIN
    SELECT top 1 @cOrderKey=OrderKey,@cCaseId=CaseID FROM pickdetail WITH (NOLOCK)
    WHERE storerkey=@cStorerKey and taskdetailkey=@cTaskKey  --find orderkey and caseid

    SET @nErrNo = 0
    UPDATE dbo.pickdetail SET
    DropID=@cCaseId,
    EditWho = @cUserName,
    EditDate = GETDATE()
    where storerkey=@cStorerKey and taskdetailkey=@cTaskKey
    and OrderKey=@cOrderKey
    and UOM  in ('6','7') and Status>'4'

    IF @@ERROR <> 0
    BEGIN
     SET @nErrNo = 3538995
     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Upd pickdetail Err
     GOTO RollBackTran
    END

    IF @nErrNo = 0
    BEGIN
     IF NOT EXISTS ( SELECT 1 FROM PACKDETAIL PAD WITH (NOLOCK)
      INNER JOIN PackHeader PH WITH(nolock) on PAD.PickSlipNo=PH.PickSlipNo
      INNER JOIN PICKDETAIL PID WITH(nolock) on PAD.LabelNo=PID.CaseID and PH.OrderKey=PID.OrderKey
      WHERE PAD.STORERKEY=@cStorerKey AND LabelNo=@cCaseId AND PAD.dropid<>@cCaseId and PID.Status<'4' and PID.OrderKey=@cOrderKey)
     BEGIN
      UPDATE PD set
      dropid=@cCaseId,
      EditWho = @cUserName,
      EditDate = GETDATE()
      from PACKDETAIL PD with(nolock)
      INNER JOIN PackHeader PH With(nolock) on PD.PickSlipNo=PH.PickSlipNo
      WHERE  PD.STORERKEY=@cStorerKey AND PD.LabelNo=@cCaseId AND PD.dropid<>PD.LabelNo AND PH.OrderKey=@cOrderKey

      IF @@ERROR <> 0
      BEGIN
       SET @nErrNo = 3538996
       SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Upd PACKDETAIL Err
       GOTO RollBackTran
      END
     END
    END
   END
  END
  FETCH NEXT FROM @cur INTO @cTaskKey
 END
Close @cur
Deallocate @cur
    END
 END

 COMMIT TRAN

 GOTO Commit_Tran

 RollBackTran:
    ROLLBACK TRAN rdt_640ExtUpd03_CSC2 -- Only rollback change made here
 Commit_Tran:
    WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
       COMMIT TRAN
 Quit:

END
SET QUOTED_IDENTIFIER OFF
