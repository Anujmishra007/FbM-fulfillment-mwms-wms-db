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
/* 2025-09-16   NLT013   1.3.0   UWP-41254 No need fire trigger if short   */
/* 2025-09-15   NLT013   1.3.0   FCR-7730 Print ZPL                        */
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
   DECLARE @nInputKey               INT
   DECLARE @cSKU                    NVARCHAR( 20)
   DECLARE @nRowCount               INT
   DECLARE @cWSCTOTALLOCLOG         NVARCHAR(10)
   DECLARE @cWaveKey                NVARCHAR( 10)
   DECLARE @cCaseID                 NVARCHAR( 20)
   DECLARE @bSuccess                INT
   DECLARE @nLoopIndex              INT
   DECLARE @cOption                 NVARCHAR( 2)
   DECLARE @cListKey                NVARCHAR( 10)

   DECLARE @tCases TABLE
   (
      ID    INT IDENTITY(1,1),
      CaseID NVARCHAR(20),
      SKU    NVARCHAR(20)
   )

   DECLARE @tPickDetail TABLE
   (
      PickDetailKey  NVARCHAR(18) PRIMARY KEY
   )

   SET @nTranCount = @@TRANCOUNT

   SELECT @cFacilily = Facility,
      @cStorerKey  = StorerKey,
      @nInputKey = InputKey
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   -- TM Replen From
   IF @nFunc = 1764
   BEGIN
      IF @nTranCount = 0
         BEGIN TRAN
      ELSE
         SAVE TRAN rdt_1764ExtUpd21


      IF @nStep = 5 OR @nStep = 6 -- CONT NEXT TASK or ToLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nStep = 5  -- Continue next task, get originak TaskDetailKey from rdtmobrec
            BEGIN
               SELECT @cTaskDetailKey = V_TaskDetailKey
               FROM RDT.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile
            END

            -- 1. Update PickDetail as 3
            -- 2. Print ZPL label
            IF @nStep = 6
            BEGIN
               -- Update PickDetail as 3
               DECLARE 
                  @cToID               NVARCHAR(18),
                  @cLocationType       NVARCHAR(10),
                  @cLocationCategory   NVARCHAR(10)

               SELECT 
                  @cToID = TD.ToID,
                  @cLocationType = LOC.LocationType,
                  @cLocationCategory = LOC.LocationCategory,
                  @cListKey = TD.ListKey
               FROM dbo.TaskDetail TD WITH(NOLOCK)
               INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FinalLoc = LOC.Loc
               WHERE TD.TaskDetailKey = @cTaskDetailKey

               IF @cLocationType = 'PND'
               BEGIN
                  DELETE FROM @tPickDetail

                  INSERT INTO @tPickDetail( PickDetailKey )
                  SELECT DISTINCT PD.PickDetailKey
                  FROM dbo.PickDetail PD WITH (NOLOCK)
                  INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey AND PD.SKU = TD.SKU
                  INNER JOIN dbo.SKUInfo SI WITH(NOLOCK) ON TD.SKU = SI.SKU 
                  WHERE PD.StorerKey = @cStorerKey
                     AND TD.ListKey = @cListKey
                     AND PD.Status = '0'
                     AND TD.Status = '9'
                     AND TD.TaskType = 'RPF'
                     AND ISNULL(SI.ExtendedField06, '') = 'SORTABLE' 
                     AND ISNULL(SI.ExtendedField07, '') = 'CONVEYABLE'

                  IF @@ROWCOUNT > 0
                  BEGIN
                     BEGIN TRY
                        UPDATE PD
                        SET Status = '3'
                        FROM dbo.PickDetail PD WITH (ROWLOCK) 
                        INNER JOIN @tPickDetail TPD ON PD.PickDetailKey = TPD.PickDetailKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 233653
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update PickDetail Failed
                        GOTO RollbackTran
                     END CATCH
                  END

                  -- Print ZPL
                  DECLARE @cRefTaskKey       NVARCHAR(10) = ''
                  DELETE FROM @tCases

                  INSERT INTO @tCases(CaseID, SKU)
                  SELECT DISTINCT CaseID, SKU
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE ListKey = @cListKey
                     AND Status = '9'
                     AND TaskType = 'RPF'
                     AND Qty > 0

                  SET @nLoopIndex = -1
                  WHILE 1 = 1
                  BEGIN
                     SELECT TOP 1
                        @cCaseID = CASEID,
                        @cSKU = SKU,
                        @nLoopIndex = id
                     FROM @tCases
                     WHERE id > @nLoopIndex
                     ORDER BY id

                     IF @@ROWCOUNT = 0
                        BREAK

                     IF EXISTS(SELECT 1
                              FROM dbo.SkuInfo WITH (NOLOCK)
                              WHERE StorerKey = @cStorerKey
                                 AND SKU = @cSKU
                                 AND ISNULL(ExtendedField06, '') = 'SORTABLE'
                                 AND ISNULL(ExtendedField07, '') = 'CONVEYABLE')
                     BEGIN
                        DECLARE @nCaseCount INT = 0
                        SELECT @nCaseCount = COUNT(DISTINCT CASEID) FROM DBO.PICKDETAIL PD WITH(NOLOCK) WHERE PD.StorerKey= @cStorerKey AND PD.DropID = @cCaseID

                        IF @nCaseCount = 1
                        BEGIN
                           IF EXISTS(
                              SELECT 1 FROM dbo.PickDetail PD WITH(NOLOCK)
                              INNER JOIN dbo.ORDERS ORM WITH(NOLOCK) ON ORM.OrderKey = PD.OrderKey AND ORM.StorerKey = PD.StorerKey
                              WHERE PD.StorerKey = @cStorerKey
                                 AND PD.DropID = @cCaseID
                                 AND PD.UOM = '2'
                                 AND NOT EXISTS (SELECT 1 FROM dbo.WorkOrderDetail WOD WITH(NOLOCK) WHERE WOD.ExternWorkOrderKey = PD.OrderKey)
                                 AND NOT EXISTS(SELECT 1 FROM dbo.CODELKUP CL WITH(NOLOCK) WHERE ORM.ShipperKey = CL.short AND CL.LISTNAME = 'WSCourier' AND CL.Code = 'ECL-1')
                           )
                           AND EXISTS (SELECT 1 FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cCaseID AND StorerKey = @cStorerKey)
                           BEGIN
                              DECLARE @cACTCaseID NVARCHAR(20)
                              SELECT @cACTCaseID = CASEID FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cCaseID
                              -- Login user's printer must = 'PANDA', then goes to ZPL print
                              BEGIN TRY
                                 EXEC rdt.rdt_LevisPrintCartonLabel
                                    @nMobile       = @nMobile
                                    ,@nFunc        = @nFunc
                                    ,@cLangCode    = @cLangCode
                                    ,@cStorerKey   = @cStorerKey
                                    ,@nStep        = @nStep
                                    ,@nInputKey    = @nInputKey
                                    ,@cDropID      = @cACTCaseID
                                    ,@cPrintType   = 'ZPL'
                                    ,@nErrNo       = @nErrNo      OUTPUT
                                    ,@cErrMsg      = @cErrMsg     OUTPUT
                                    ,@cSourceName  = 'rdt_1764ExtUpd21'
                              END TRY
                              BEGIN CATCH
                                 SET @nErrNo = 233654
                                 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Print ZPL Failed
                                 GOTO RollbackTran
                              END CATCH

                              IF @nErrNo <> 0
                              BEGIN
                                 GOTO RollBackTran
                              END
                           END
                        END
                     END
                  END
               END
            END

            -- Get task info
            DECLARE @nQty INT
            SELECT
               @cSKU = SKU,
               @cWaveKey = WaveKey,
               @cCaseID = CaseID,
               @cTaskStatus = Status,
               @nQty = Qty
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND TaskdetailKey = @cTaskDetailKey
               AND TaskType = 'RPF'
               
            IF @cTaskStatus IN ( '5', '9' ) AND @nQty > 0 -- RPF task is completed
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
                        GOTO RollBackTran
                     END CATCH

                     IF @bSuccess <> 1
                     BEGIN
                        GOTO RollBackTran
                     END
                  END
               END
            END
         END
      END

      IF @nStep = 9 -- REASON CODE
      BEGIN
         IF @nInputKey = 1
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
         END
      END
   END

   GOTO Quit

RollBackTran:
   IF @nTranCount = 0
      ROLLBACK TRANSACTION
   ELSE
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
