
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* Store procedure: rdt_1816ExtUpdCSCUK                                     */
/* Copyright      : Maersk                                                  */
/*                                                                          */
/* Purpose: Un hold picking tasks when execute last replenishment tasks     */
/*                                                                          */
/* Modifications log:                                                       */
/*                                                                          */
/* Date         Author    Ver.   Purposes                                   */
/* 2026-03-11   AGA399    1.0.0  Created                                    */
/****************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1816ExtUpdCSCUK]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@cFinalLOC       NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cToLOC     NVARCHAR( 10)
   DECLARE @cFromID    NVARCHAR( 18)
   DECLARE @cSourceKey NVARCHAR( 30)
   DECLARE @cFacility  NVARCHAR( 5)
   DECLARE @cStorerKey NVARCHAR( 15)
   DECLARE @cWaveKey   NVARCHAR( 10)

   -- Get facility
   SELECT @cFacility = Facility
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get task info
   SELECT
      @cStorerKey = StorerKey,
      @cToLOC     = ToLOC,
      @cFromID    = FromID,
      @cWaveKey   = WaveKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   IF @nFunc = 1816
   BEGIN
      IF @nStep = 1 -- FinalLOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- If no RPF/ASTTPA/ASTMV tasks with status 0 remain for this wave,
            -- this is the last replen task — unhold the picking tasks (H -> 0)
            IF NOT EXISTS (
               SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE WaveKey       = @cWaveKey
               AND   StorerKey     = @cStorerKey
               AND   TaskType      IN ('RPF', 'ASTTPA', 'ASTMV')
               AND   Status        = '0'
               AND   TaskDetailKey != @cTaskdetailKey
               AND   SourceType    <> 'rdt_1837ExtScn02'
            )
            BEGIN
               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET    Status = '0'
                  WHERE  WaveKey   = @cWaveKey
                  AND    StorerKey = @cStorerKey
                  AND    TaskType  IN ('CPK', 'ASTCPK')
                  AND    Status    = 'H'
               END TRY
               BEGIN CATCH
                  SET @nErrNo = ERROR_NUMBER()
                  SET @cErrMsg = SUBSTRING(ERROR_MESSAGE(), 1, 20)
                  GOTO Quit
               END CATCH
            END

            GOTO Quit
         END -- ENTER
      END -- STEP = 1
   END -- FUNC = 1816

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1816ExtUpdCSCUK] TO nSQL
GO
