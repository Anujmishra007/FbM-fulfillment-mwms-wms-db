SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Store procedure: rdt_1764ExtUpd30                                       */
/* Copyright      : Maersk WMS                                             */
/*                                                                         */
/* Purpose: After replenishment ToLOC is confirmed (Step 6), release all   */
/*          suspended FCP pick tasks that were waiting on this replen task.*/
/*          Identifies tasks via TaskDetail.RefTaskKey = replen key,       */
/*          TaskType = 'FCP', Status = 'S', and sets Status = '0' (Open).  */
/*                                                                         */
/* Modifications log:                                                      */
/* Date         Author    Ver.    Purposes                                 */
/* 2026-08-13   NYE018    1.0.0   FCR-14962 Created                        */
/***************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpd30]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount  INT
   DECLARE @cStorerKey  NVARCHAR( 15)
   DECLARE @cUserName   NVARCHAR( 18)
   DECLARE @nInputKey   INT

   SET @nTranCount = @@TRANCOUNT

   SELECT
       @cStorerKey = StorerKey
      ,@cUserName  = UserName
      ,@nInputKey  = InputKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   BEGIN TRAN
   SAVE TRAN rdt_1764ExtUpd30

   -- Only act on Step 6 (ToLOC) with ENTER
   IF @nStep = 6
   BEGIN 
        IF @nInputKey = 1
        BEGIN
            -- Release suspended FCP pick tasks that were waiting on this replen
            BEGIN TRY
                UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                    Status   = '0'
                    ,EditDate = GETDATE()
                    ,EditWho  = @cUserName
                WHERE RefTaskKey = @cTaskdetailKey
                AND TaskType         = 'FCP'
                AND Status           = 'S'
            END TRY
            BEGIN CATCH
                SET @nErrNo = 277951
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ReleaseFCPFail
                GOTO RollBackTran
            END CATCH
        END -- IF @nInputKey = 1
   END -- IF @nStep = 6

   COMMIT TRAN rdt_1764ExtUpd30
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1764ExtUpd30

Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1764ExtUpd30 TO NSQL
GO
