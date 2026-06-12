
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

 DECLARE @cToLOC      NVARCHAR( 10)
 DECLARE @cFromID     NVARCHAR( 18)
 DECLARE @cSourceKey  NVARCHAR( 30)
 DECLARE @cFacility   NVARCHAR( 5)
 DECLARE @cStorerkey  NVARCHAR( 15)
 DECLARE @cWavekey    NVARCHAR( 10)



 --Get facility
 SELECT
    @cFacility = Facility
 FROM rdt.RDTMOBREC WITH (NOLOCK)
 WHERE Mobile = @nMobile

 -- Get task info
 SELECT
    @cStorerkey = StorerKey,
    @cToLOC = ToLOC,
    @cFromID = FromID,
    @cWavekey = WaveKey
 FROM TaskDetail WITH (NOLOCK)
 WHERE TaskDetailKey = @cTaskDetailKey

 -- TM assist NMV
 IF @nFunc = 1816
 BEGIN
    IF @nStep = 1 -- FinalLOC
    BEGIN
       IF @nInputKey = 1 -- ENTER
       BEGIN
             IF NOT EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                WHERE WaveKey = @cWavekey
                AND   StorerKey = @cStorerKey
                AND   TaskType in ('RPF','ASTTPA','ASTMV')
                AND   Status = '0'
                AND TaskDetailKey != @cTaskdetailKey)

    /*In case any Replenishment and movement tasks exisits with status 0
    That means that task is the last one in that case update status of the Picking task
    of that wave from H to 0*/
                UPDATE dbo.TaskDetail
                SET Status = '0'
                WHERE WaveKey = @cWavekey
                AND   StorerKey = @cStorerKey
                AND   TaskType in ('CPK','ASTCPK')
                AND   Status = 'H'

          GOTO Quit
       END --INPUTKEY = 1
    END --STEP = 1
 END
 GOTO Quit

Quit:

END
