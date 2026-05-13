SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
      
/***********************************************************************s****/
/* Store procedure: rdt_1855ExtUpd06                                       */
/* Copyright      : MAERSK                                                 */
/* Customer       : Granite                                                */
/*                                                                         */
/* Purpose: Send picked interface to WCS                                   */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Ver.    Author  Purposes                                   */
/* 2026-03-16   1.0.0   NLT013  FCR-10824 Created                          */
/***************************************************************************/
      
CREATE OR ALTER PROCEDURE [rdt].[rdt_1855ExtUpd06]
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

   DECLARE 
      @cMethod                NVARCHAR( 10),
      @cUserName              NVARCHAR( 128),
      @cPickConfirmStatus     NVARCHAR( 1),
      @cWaveKey               NVARCHAR( 10),
      @nTranCount             INT,
      @nLoopIndex             INT,

      @cDropID                NVARCHAR(20),
      @cDropLoc               NVARCHAR(10),
      @cAdditionalLoc         NVARCHAR(30),
      @cDropIDType            NVARCHAR(10),
      @cLabelPrinted          NVARCHAR(10),
      @cLoadkey               NVARCHAR(10),
      @cStatus                NVARCHAR(10),
      @cLockTaskKey           NVARCHAR(10)
  
   SET @nErrNo = 0

   SELECT 
      @cUserName                    = UserName,
      @cMethod                      = V_String25,
      @cWaveKey                     = C_String1
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   DECLARE @tDropIDInfo TABLE
   (
      RowRef            INT IDENTITY(1,1),
      DropID            NVARCHAR(20),
      DropLoc           NVARCHAR(10),
      AdditionalLoc     NVARCHAR(30),
      DropIDType        NVARCHAR(10),
      LabelPrinted      NVARCHAR(10),
      Loadkey           NVARCHAR(10),
      Status            NVARCHAR(10)
   )

   -- Get storer config  
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)  
   IF @cPickConfirmStatus = '0'  
      SET @cPickConfirmStatus = '5'  

   IF @nFunc = 1855
   BEGIN
      IF @nStep = 7 --ToLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cMethod = '1'
            BEGIN
               BEGIN TRY
                  INSERT INTO @tDropIDInfo (DropID, DropLoc, AdditionalLoc, DropIDType, LabelPrinted, Loadkey, Status)
                  SELECT TOP 1 PD.DropID, PD.Loc, TD.ToLoc, 'SINGLES', 'N', TD.LoadKey, '5'
                  FROM dbo.PickDetail PD WITH(NOLOCK)
                  INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
                  WHERE TD.StorerKey = @cStorerKey
                     AND TD.TaskType = 'ASTCPK'
                     AND TD.UserKey = @cUserName
                     AND TD.Status = '9'
                     AND PD.Status = '5'
                     AND TD.DeviceID = @cCartId
                     AND TD.WaveKey = @cWaveKey
                     AND TD.GroupKey = @cGroupKey
                  ORDER BY TD.EditDate DESC
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 261251
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert data into @tDropIDInfo failed
                  GOTO Quit
               END CATCH
            END
            ELSE IF @cMethod = '2'
            BEGIN
               BEGIN TRY
                  INSERT INTO @tDropIDInfo (DropID, DropLoc, AdditionalLoc, DropIDType, LabelPrinted, Loadkey, Status)
                  SELECT DropID, Loc, ToLoc, DropIDType, LabelPrinted, LoadKey, Status
                  FROM
                     (SELECT PD.DropID, PD.Loc, TD.ToLoc, 'MULTIES' AS DropIDType, 'N' AS LabelPrinted, TD.LoadKey, '5' AS Status,
                        ROW_NUMBER()OVER(PARTITION BY PD.DropID ORDER BY TD.TaskDetaiLKey DESC) AS Row_No
                     FROM dbo.PickDetail PD WITH(NOLOCK)
                     INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
                     WHERE TD.StorerKey = @cStorerKey
                        AND TD.TaskType = 'ASTCPK'
                        AND TD.UserKey = @cUserName
                        AND TD.Status = '9'
                        AND PD.Status = '5'
                        AND TD.DeviceID = @cCartId
                        AND TD.WaveKey = @cWaveKey
                        AND TD.GroupKey = @cGroupKey) AS t
                  WHERE t.Row_No = 1
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 261252
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert data into @tDropIDInfo failed
                  GOTO Quit
               END CATCH
            END

            SET @nTranCount = @@TRANCOUNT
            BEGIN TRAN
            SAVE TRAN rdt_1855ExtUpd06_Step7

            BEGIN TRY
               INSERT INTO dbo.DropID(DropID, DropLoc, AdditionalLoc, DropIDType, LabelPrinted, Loadkey, Status)
               SELECT DropID, DropLoc, AdditionalLoc, DropIDType, LabelPrinted, Loadkey, Status
               FROM @tDropIDInfo AS TDI
               WHERE NOT EXISTS(SELECT 1 FROM dbo.DropID WITH(NOLOCK) WHERE DropID = TDI.DropID)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 261253
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert data into DropID failed
               GOTO Step7_RollBackTran
            END CATCH

            --Release Other tasks
            DECLARE @tTaskDetail TABLE 
            (
               RowRef INT IDENTITY(1,1),
               TaskDetailKey NVARCHAR( 10) PRIMARY KEY
            )

            BEGIN TRY
               INSERT INTO @tTaskDetail (TaskDetailKey)
               SELECT DISTINCT TD.TaskDetailKey
               FROM dbo.TaskDetail TD WITH(NOLOCK)
               INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey
               WHERE TD.StorerKey = @cStorerKey
                  AND TD.TaskType = 'ASTCPK'
                  AND TD.UserKey = @cUserName
                  AND TD.Status = '3'
                  AND PD.Status = '0'
                  AND TD.DeviceID = @cCartId
                  AND TD.WaveKey = @cWaveKey
                  AND TD.GroupKey = @cGroupKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 261254
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert data into @tTaskDetail failed
               GOTO Step7_RollBackTran
            END CATCH

            IF EXISTS(SELECT 1 FROM @tTaskDetail)
            BEGIN
               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1 
                     @cLockTaskKey = TaskDetailKey,
                     @nLoopIndex = RowRef
                  FROM @tTaskDetail
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0
                     BREAK

                  BEGIN TRY
                     UPDATE dbo.TaskDetail WITH(ROWLOCK)
                     SET
                        DropID = '',
                        StatusMsg = '',
                        DeviceID = '',
                        Status = '0',
                        UserKey = '',
                        EditWho = @cUserName,
                        EditDate = GETDATE()
                     WHERE Storerkey = @cStorerKey
                        AND TaskDetailKey = @cLockTaskKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 261255
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update TaskDetail failed
                     GOTO Step7_RollBackTran
                  END CATCH
               END
            END

            GOTO Step7_Commit

            Step7_RollBackTran:
                  ROLLBACK TRAN rdt_1855ExtUpd06_Step7
            Step7_Commit:
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN

            GOTO Quit
         END
      END
   END

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1855ExtUpd06] TO NSQL
GO