SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
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
 
   SET @nErrNo = 0
   SET @cErrMsg = ''
 
   DECLARE @nTranCount        INT
   DECLARE @cUserName         NVARCHAR( 18)
   DECLARE @cCaseId           NVARCHAR( 20)
   DECLARE @cOrderKey         NVARCHAR( 12)
   DECLARE @cTaskKey          NVARCHAR( 10)
   DECLARE @cPickDetailKey    NVARCHAR( 18)
 
   SELECT @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
 
   -- Handling transaction
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_640ExtUpd03_CSC2 -- For rollback or commit only our own transaction
 
   IF @nStep = 10
   BEGIN
      IF @nFunc = 640
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF EXISTS ( SELECT 1
                        FROM dbo.TaskDetail TD WITH (NOLOCK)
                        WHERE TD.Storerkey = @cStorerKey
                        AND   TD.TaskDetailKey = @cTaskDetailKey
                        AND   TD.ReasonKey IN ('SIZE', 'SHORT0'))
            BEGIN
               SELECT TOP 1 @cPickDetailKey = PickDetailKey
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
               AND   TaskDetailKey = @cTaskDetailKey --find PickDetailKey
 
               BEGIN TRY
                  -- Update PickDetail
                  UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                     [Status] = '4',
                     EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME(),
                     TrafficCop = NULL
                  WHERE PickDetailKey = @cPickDetailKey  
                  AND   [Status] = '0'
               END TRY
               
               BEGIN CATCH
                  SET @nErrNo = 270751
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                  GOTO RollBackTran
               END CATCH
            END
         END
      END
   END
 
   IF @nStep = 8
   BEGIN
      IF @nFunc = 640
         BEGIN
            IF ISNULL(@cTaskDetailKey, '') <> ''
            BEGIN
               SELECT TOP 1
                  @cGroupKey = GroupKey,
                  @cCartId = DeviceID
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskDetailKey
               ORDER BY 1
 
               DECLARE @cur CURSOR
               SET @cur = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
               SELECT TaskDetailKey
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE GroupKey = @cGroupKey
               AND   DeviceID = @cCartId
               AND   [Status] >= '5'
               
               OPEN @cur
               FETCH NEXT FROM @cur INTO @cTaskKey
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     IF EXISTS ( SELECT 1
                                 FROM dbo.TaskDetail WITH (NOLOCK)
                                 WHERE StorerKey = @cStorerKey
                                 AND   TaskDetailKey = @cTaskKey
                                 AND   TaskType = 'CPK')   --Only update when picked completed for taskdetail
                     BEGIN
                        IF EXISTS ( SELECT 1
                                    FROM dbo.PickDetail PD WITH (NOLOCK)
                                    WHERE PD.StorerKey = @cStorerKey
                                    AND   PD.TaskDetailKey = @cTaskKey
                                    AND   PD.DropID <> PD.CaseID
                                    AND   PD.UOM IN ('6', '7')
                                    AND   PD.[Status] > '4')
                        BEGIN
                           SELECT TOP 1
                              @cOrderKey = OrderKey,
                              @cCaseId = CaseID
                           FROM dbo.PickDetail WITH (NOLOCK)
                           WHERE StorerKey = @cStorerKey
                           AND   TaskDetailKey = @cTaskKey  --find orderkey and caseid
                           
                           BEGIN TRY
                              UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                                 DropID = @cCaseId,
                                 EditWho = @cUserName,
                                 EditDate = GETDATE()
                              WHERE StorerKey = @cStorerKey
                              AND   TaskDetailKey = @cTaskKey
                              AND   OrderKey = @cOrderKey
                              AND   UOM IN ('6', '7')
                              AND   [Status] > '4'
                           END TRY
 
                           BEGIN CATCH
                              SET @nErrNo = 270752
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Upd pickdetail Err
                              GOTO RollBackTran
                           END CATCH
 
                           IF @nErrNo = 0
                           BEGIN
                              IF NOT EXISTS ( SELECT 1
                                             FROM dbo.PackDetail PAD WITH (NOLOCK)
                                             INNER JOIN dbo.PackHeader PH WITH (NOLOCK) ON PAD.PickSlipNo = PH.PickSlipNo
                                             INNER JOIN dbo.PickDetail PID WITH (NOLOCK) ON PAD.LabelNo = PID.CaseID AND PH.OrderKey = PID.OrderKey
                                             WHERE PAD.StorerKey = @cStorerKey
                                             AND   PAD.LabelNo = @cCaseId
                                             AND   PAD.DropID <> @cCaseId
                                             AND   PID.[Status] < '4'
                                             AND   PID.OrderKey = @cOrderKey)
                              BEGIN TRY
                                 UPDATE PD WITH (ROWLOCK)
                                 SET
                                    DropID = @cCaseId,
                                    EditWho = @cUserName,
                                    EditDate = GETDATE()
                                 FROM dbo.PackDetail PD WITH (ROWLOCK)
                                 INNER JOIN dbo.PackHeader PH WITH (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
                                 WHERE PD.StorerKey = @cStorerKey
                                 AND   PD.LabelNo = @cCaseId
                                 AND   PD.DropID <> PD.LabelNo
                                 AND   PH.OrderKey = @cOrderKey
                              END TRY
 
                              BEGIN CATCH
                                 SET @nErrNo = 270753
                                 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Upd PACKDETAIL Err
                                 GOTO RollBackTran
                              END CATCH
                           END
                        END
                     END
                  END
                  FETCH NEXT FROM @cur INTO @cTaskKey
               END
 
               CLOSE @cur
               DEALLOCATE @cur
 
            END
         END
      END
   END
 
   COMMIT TRAN
   GOTO Quit
 
RollBackTran:
   IF XACT_STATE() = -1
       ROLLBACK TRAN
    ELSE
       ROLLBACK TRAN rdt_640ExtUpd03_CSC2 -- Only rollback change made here
Commit_Tran:
   WHILE @@TRANCOUNT > @nTranCount AND XACT_STATE() = 1 -- Commit until the level we started
      COMMIT TRAN
Quit:
-- Safe cursor cleanup for error paths
   IF CURSOR_STATUS('variable', '@cur') = 1
   BEGIN
      CLOSE @cur
      DEALLOCATE @cur
   END
   ELSE IF CURSOR_STATUS('variable', '@cur') = -1
      DEALLOCATE @cur
END
GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON [RDT].[rdt_640ExtUpd03_CSC2] TO NSQL
GO
 