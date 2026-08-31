/*****************************************************************************/
/* Store procedure: rdt_1836ExtUpd08                                         */
/* Copyright      : Maersk                                                   */
/* Client         : ONBR                                                     */
/*                                                                           */
/* Modifications log:                                                        */
/*                                                                           */
/* Date         Author    Ver.    Purposes                                   */
/* 2026-06-16   DennisW   1.0.0   FCR-12981 Release FCP task on hold         */
/*****************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1836ExtUpd08]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cTaskdetailKey  NVARCHAR( 10),
   @cFinalLOC       NVARCHAR( 10),
   @nErrNo          INT             OUTPUT,
   @cErrMsg         NVARCHAR( 20)   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cUserName         NVARCHAR( 128)
   DECLARE @cLot              NVARCHAR( 10)
   DECLARE @cGroupKey         NVARCHAR( 10)
   DECLARE @nTranCount        INT

   SELECT
      @cStorerKey = Storerkey,
      @cUserName  = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @nTranCount = @@TRANCOUNT

   IF @nFunc = 1836
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @nInputKey = 1
         BEGIN
            -- Get Lot from current ASTRPT task
            -- Derive FinalLoc from RPF task via ASTRPT.SourceKey → RPF.TaskDetailKey
            SELECT
               @cLot      = T1.Lot,
               @cFinalLOC = T2.FinalLoc
            FROM dbo.TaskDetail T1 WITH (NOLOCK)
            JOIN dbo.TaskDetail T2 WITH (NOLOCK)
               ON  T2.TaskDetailKey = T1.SourceKey
               AND T2.TaskType      = 'RPF'
               AND T2.StorerKey     = T1.StorerKey
            WHERE T1.TaskDetailKey = @cTaskdetailKey
              AND T1.TaskType      = 'ASTRPT'
              AND T1.StorerKey     = @cStorerKey

            -- Release FCP tasks on hold matching RPF.FinalLoc and Lot
            BEGIN TRAN
            SAVE TRAN rdt_1836ExtUpd08

            BEGIN TRY
               UPDATE dbo.TaskDetail WITH (ROWLOCK)
               SET Status   = '0',
                   UserKey  = '',
                   EditWho  = @cUserName,
                   EditDate = GETDATE()
               WHERE StorerKey = @cStorerKey
                  AND TaskType = 'FCP'
                  AND FromLoc  = @cFinalLOC
                  AND Lot      = @cLot
                  AND Status   = 'H'

               -- Check if all TaskDetails with the same GroupKey are now Status = '0'
               SELECT TOP 1 @cGroupKey = GroupKey
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND TaskType = 'FCP'
                  AND FromLoc  = @cFinalLOC
                  AND Lot      = @cLot

               IF ISNULL( @cGroupKey, '') <> ''
               AND NOT EXISTS (
                  SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND TaskType  = 'FCP'
                     AND GroupKey  = @cGroupKey
                     AND Status   <> '0'
               )
               BEGIN
                  -- TODO: Call SP to trigger release of tasks to LOCUS WCS system
                  SELECT 1
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 270001
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')-- 270001 Update TaskDetail failed
               GOTO RollBackTran
            END CATCH

            COMMIT TRAN rdt_1836ExtUpd08
         END -- enter
      END -- st1
   END -- 1836

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1836ExtUpd08
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1836ExtUpd08 TO NSQL
GO
