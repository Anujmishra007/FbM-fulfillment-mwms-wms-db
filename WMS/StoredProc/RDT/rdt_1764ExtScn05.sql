
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtScn05                                       */
/* Copyright      : Maersk                                                 */
/* Customer       : AEOMX MEXWMS                                           */
/*                                                                         */
/*                                                                         */
/* Date       Rev      Author   Purposes                                   */
/* 2027-08-03 1.0.0    NickT    FCR-14963 Created                          */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764ExtScn05] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nScn             INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT,
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT,
   @cUDF30  NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nCurrentFunc           INT,
      @cLoopTaskDetailKey     NVARCHAR( 10),
      @cTaskdetailKey         NVARCHAR( 10),
      @nRowCount              INT,
      @nLoopIndex             INT,
      @nTranCount             INT,
      @cUserName              NVARCHAR( 18),
      @cGroupKey              NVARCHAR( 10)
  
   SET @nTranCount = @@TRANCOUNT
  
   DECLARE @tTaskDetail TABLE  
   (  
      RowRef            INT IDENTITY(1,1),
      TaskDetailKey     NVARCHAR(10)
   )  
  
   SELECT
      @cUserName = UserName,
      @cTaskdetailKey = V_TaskDetailKey,
      @nCurrentFunc = Func
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nCurrentFunc = 1764 -- TM Replen
   BEGIN
      -- Back to Task management step 1
      IF @nFunc = 1756 AND @nAfterScn = 2100 AND @nAfterStep = 1
      BEGIN
         SELECT @cGroupKey = GroupKey
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskdetailKey
         SET @cGroupKey = ISNULL(@cGroupKey, '')

         DELETE @tTaskDetail
         IF @cGroupKey <> ''
         BEGIN
            INSERT INTO @tTaskDetail (TaskDetailKey)
            SELECT TaskDetailKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND TaskType IN ('RPF', 'RP1')
               AND Status = '0'
               AND UserKey = @cUserName
               AND GroupKey IS NOT NULL
               AND GroupKey = @cGroupKey
         END

         BEGIN TRAN
         SAVE TRAN rdt_1764ExtScn05

         SET @nLoopIndex = -1
         WHILE 1 = 1
         BEGIN
            SELECT TOP 1  
               @cLoopTaskDetailKey = TaskDetailKey,
               @nLoopIndex = RowRef
            FROM @tTaskDetail
            WHERE RowRef > @nLoopIndex  
            ORDER BY RowRef  

            SET @nRowCount = @@ROWCOUNT  

            IF @nRowCount = 0  
               BREAK  
               
            BEGIN TRY  
               UPDATE dbo.TaskDetail WITH (ROWLOCK)
               SET UserKey = '',
                  EditDate = GETDATE(),
                  EditWho = @cUserName,
                  TrafficCop = NULL
               WHERE TaskDetailKey = @cLoopTaskDetailKey
            END TRY  
            BEGIN CATCH  
               SET @nErrNo = 276251
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Fail to release TaskDetail
               GOTO RollbackTran  
            END CATCH  
         END -- end while  

         COMMIT TRAN rdt_1764ExtScn05
      END
   END
   GOTO Quit

RollBackTran:  
   IF @nTranCount > 0 AND XACT_STATE() <> -1
      ROLLBACK TRAN rdt_1764ExtScn05  
   ELSE  
    ROLLBACK TRAN  
   GOTO Quit  
  
   Fail:  
     
   Quit:  
   WHILE @@TRANCOUNT > @nTranCount  
      COMMIT TRAN  

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1764ExtScn05 TO NSQL 
GO  
