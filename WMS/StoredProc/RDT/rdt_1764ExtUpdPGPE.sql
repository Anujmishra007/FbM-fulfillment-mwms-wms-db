SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1764ExtUpdPGPE                                  */
/* Copyright      : Maersk                                              */
/* Customer       : PGPE                                                */
/*                                                                      */
/* Purpose: Active the hold pick task once the repl task is done        */
/*                                                                      */
/* Date         Author   Ver.  Purposes                                 */
/* 2024-05-07   NLT013   1.0   UWP-19082 UWP-18889 Create Initial Ver  */
/* 2026-06-15   FRO014   1.1   RITM9021237/UWP-62595 Remove SKU filter  */
/*                             RP1 task does not include SKU value      */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpdPGPE]
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @cTaskDetailKey NVARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT,
   @nAfterStep     INT = 0,
   @cDropID        NVARCHAR( 20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount        INT
   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cToLOC            NVARCHAR( 10)
   DECLARE @cReplPickListName NVARCHAR( 10)

   SET @nTranCount = @@TRANCOUNT

   IF @nFunc = 1764
   BEGIN
      IF @nStep = 6 -- ToLOC
      BEGIN
         SELECT
            @cStorerKey = StorerKey,
            @cToLOC     = ToLoc
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey
            AND TaskType IN ('RPF', 'RP1')

         SET @cReplPickListName = rdt.RDTGetConfig(@nFunc, 'TM_RPLRELPICK', @cStorerKey)
         IF ISNULL(@cReplPickListName, '') = ''
            SET @cReplPickListName = '0'

         BEGIN TRAN
         SAVE TRAN rdt_1764ExtUpdPGPE

         BEGIN TRY
            UPDATE dbo.TaskDetail WITH (ROWLOCK)
            SET Status   = '0',
                EditWho  = SUSER_SNAME(),
                EditDate = GETDATE()
            FROM dbo.TaskDetail td
            INNER JOIN dbo.CODELKUP lu WITH (NOLOCK)
               ON  td.StorerKey = lu.StorerKey
               AND td.TaskType  = ISNULL(lu.Code2, '')
            WHERE td.StorerKey = @cStorerKey
               AND lu.LISTNAME = @cReplPickListName
               AND td.Status   = 'H'
               AND td.FromLoc  = @cToLOC
         END TRY
         BEGIN CATCH
            SET @nErrNo  = 275068
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- UpdPKTaskFail
            GOTO RollBackTran
         END CATCH

         COMMIT TRAN rdt_1764ExtUpdPGPE
      END
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764ExtUpdPGPE
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1764ExtUpdPGPE] TO [NSQL]
GO
