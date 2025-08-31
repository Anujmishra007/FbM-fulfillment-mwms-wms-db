SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtUpd21                                       */
/* Purpose: Rollback FinalLoc and TransitLoc once quit the task            */
/* Customer: Grainte Levis                                                 */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Author   Ver.    Purposes                                  */
/* 2025-02-21   NLT013   1.0.0   UWP-30476 Create Intial Version           */
/* 2025-02-25   JCH507   1.0.1   UWP-30476 Clear Final loc when status = H */
/* 2025-03-22   NLT013   1.1.0   UWP-31321 Clear ListKey while cancel task */
/* 2025-08-26   NLT013   1.2.0   FCR-7417 Add TransmitLog                  */
/* 2025-08-31   NLT013   1.2.1   FCR-7417 Get Task from RDTMOBREC          */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpd21]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   ,@nAfterStep      INT = 0
   ,@cDropID         NVARCHAR( 20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount  INT

   DECLARE @cStorerKey              NVARCHAR( 15)
   DECLARE @cToLOC                  NVARCHAR( 10)
   DECLARE @cFinalLOC               NVARCHAR(10)
   DECLARE @cTaskStatus             NVARCHAR(10)
   DECLARE @cToLOCCat               NVARCHAR( 10)
   DECLARE @cFacilily               NVARCHAR( 5)
   DECLARE @cInputKey               NVARCHAR(3)
   DECLARE @cSKU                    NVARCHAR( 20)
   DECLARE @nRowCount               INT
   DECLARE @cWSCTOTALLOCLOG         NVARCHAR(10)
   DECLARE @cWaveKey                NVARCHAR( 10)
   DECLARE @cCaseID                 NVARCHAR( 20)
   DECLARE @bSuccess                INT
   DECLARE @cOption                 NVARCHAR( 2)

   SET @nTranCount = @@TRANCOUNT

   SELECT @cFacilily = Facility,
      @cStorerKey  = StorerKey,
      @cInputKey = InputKey
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nStep = 5 OR @nStep = 6 -- CONT NEXT TASK or ToLoc
      BEGIN
         IF @cInputKey = '1'
         BEGIN
            IF @nStep = 5  -- Continue next task, get originak TaskDetailKey from rdtmobrec
            BEGIN
               SELECT @cTaskDetailKey = V_TaskDetailKey
               FROM RDT.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile
            END

            -- Get task info
            SELECT
               @cSKU = SKU,
               @cWaveKey = WaveKey,
               @cCaseID = CaseID,
               @cTaskStatus = Status
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND TaskdetailKey = @cTaskDetailKey
               AND TaskType = 'RPF'
               
            IF @cTaskStatus IN ( '5', '9' ) -- RPF task is completed
            BEGIN
               SELECT @nRowCount = COUNT(*)
               FROM dbo.SkuInfo WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SKU = @cSKU
                  AND ISNULL(ExtendedField06, '') = 'SORTABLE'
                  AND ISNULL(ExtendedField07, '') = 'CONVEYABLE'

               SET @cWSCTOTALLOCLOG = rdt.RDTGetConfig( @nFunc, 'WSCTOTALLOCLOG', @cStorerKey)

               IF @nRowCount > 0 AND @cWSCTOTALLOCLOG = '1'
               BEGIN
                  SELECT @nRowCount = COUNT(*)
                  FROM dbo.Transmitlog2 WITH (NOLOCK)
                  WHERE TableName = 'WSCTOTALLOCLOG' 
                     AND Key1 = @cWaveKey
                     AND Key2 = @cCaseID
                     AND Key3 = @cStorerKey

                  IF @nRowCount = 0 -- No record exist, then generate TransmitLog
                  BEGIN
                     BEGIN TRY
                        EXEC ispGenTransmitLog2
                           @c_TableName        = 'WSCTOTALLOCLOG'
                           ,@c_Key1             = @cWaveKey
                           ,@c_Key2             = @cCaseID
                           ,@c_Key3             = @cStorerKey
                           ,@c_TransmitBatch    = ''
                           ,@b_Success          = @bSuccess   OUTPUT
                           ,@n_err              = @nErrNo     OUTPUT
                           ,@c_errmsg           = @cErrMsg    OUTPUT
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 233652
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Generate TransmitLog Failed
                        GOTO Fail
                     END CATCH

                     IF @bSuccess <> 1
                     BEGIN
                        GOTO Fail
                     END
                  END
               END
            END
         END
      END

      IF @nStep = 9 -- REASON CODE
      BEGIN
         IF @cInputKey = '1'
         BEGIN
            -- Get task info
            SELECT
               @cToLoc        = ToLoc,
               @cFinalLOC     = FinalLoc,
               @cTaskStatus   = Status
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskdetailKey = @cTaskDetailKey
               AND TaskType = 'RPF'
               AND StorerKey = @cStorerKey

            IF @cToLoc <> '' AND @cFinalLOC <> '' AND @cFinalLOC <> @cToLoc
            BEGIN
               SELECT @cToLOCCat = LocationCategory
               FROM dbo.LOC WITH(NOLOCK)
               WHERE Facility = @cFacilily
                  AND Loc = @cToLoc
            END

            BEGIN TRAN
            SAVE TRAN rdt_1764ExtUpd21

            BEGIN TRY
               IF @cToLOCCat IN ('PND', 'PND_IN', 'PND_OUT') AND @cTaskStatus IN ('0', 'X','H') AND @cFinalLOC <> '' 
               BEGIN
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET ToLoc = @cFinalLOC,
                     FinalLoc = '',
                     EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME(),
                     TransitLoc = '',
                     ListKey = '',
                     Priority = IIF( @cTaskStatus = 'X', 1, Priority),
                     TransitCount = 0,
                     TrafficCop = NULL
                  WHERE TaskDetailKey = @cTaskdetailKey
                     AND StorerKey = @cStorerKey
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 233651
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPKTaskFail
               GOTO RollBackTran
            END CATCH

            COMMIT TRAN rdt_1764ExtUpd21 -- Only commit change made here
         END
      END
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764ExtUpd21 -- Only rollback change made here
Fail:
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1764ExtUpd21 TO NSQL
GO
