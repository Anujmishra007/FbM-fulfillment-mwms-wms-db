

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/***************************************************************************/
/* Store procedure: rdt_UCCReceive_CreateNextTask                                        */
/* Copyright      : Maersk                                                 */
/*                                                                         */
/* Purpose: Extended Upd for USLevis                                       */
/*                                                                         */
/* Date        Rev    Author      Purposes                                 */
/* 2025-09-29  1.0    JACKC       UWP-29593                                */
/***************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_UCCReceive_CreateNextTask
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@cStorerKey  NVARCHAR( 15)
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cLOC        NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@nErrNo      INT             OUTPUT
   ,@cErrMsg     NVARCHAR( 20)   OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cGenPATaskSP        NVARCHAR( 20),
      @cNewTaskDetailKey   NVARCHAR( 10),
      @cTaskType           NVARCHAR( 10),
      @cTaskStatus         NVARCHAR( 10),
      @cAreaKey            NVARCHAR( 10),
      @nSuccess            INT

   DECLARE
      @cSQL              NVARCHAR(1000),
      @cSQLParam         NVARCHAR(1000)
   
   /***********************************************************************************************
                                             Customize Create Task 
   ***********************************************************************************************/   
   SET @cGenPATaskSP = rdt.RDTGetConfig( @nFunc, 'GenPATaskSP', @cStorerKey)            
   IF @cGenPATaskSP = '0'            
      SET @cGenPATaskSP = ''   
      
   IF @cGenPATaskSP <> ''    
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGenPATaskSP AND type = 'P')            
      BEGIN            
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cGenPATaskSP) +            
            ' @nMobile, @nFunc, @cLangCode, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cToID, @nErrNo  OUTPUT, @cErrMsg OUTPUT '            
         SET @cSQLParam =      
            '@nMobile        INT,                 ' +
            '@nFunc          INT,                 ' +
            '@cLangCode      NVARCHAR( 3),        ' +
            '@cStorerKey     NVARCHAR( 15),       ' +
            '@cReceiptKey    NVARCHAR( 10),       ' +
            '@cPOKey         NVARCHAR( 10),       ' +
            '@cLOC           NVARCHAR( 10),       ' +
            '@cToID          NVARCHAR( 18),       ' +
            '@nErrNo         INT          OUTPUT, ' +
            '@cErrMsg        NVARCHAR( 20) OUTPUT '    

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,            
            @nMobile, @nFunc, @cLangCode, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cToID, @nErrNo  OUTPUT, @cErrMsg OUTPUT      
            
         GOTO Quit             
      END  
   END

   /***********************************************************************************************
                                             Standard Create Task 
   ***********************************************************************************************/
   SELECT
      @cTaskType = Short,
      @cTaskStatus = UDF01
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE LISTNAME = 'PATASKTYPE'
      AND StorerKey = @cStorerKey
      AND Code = 'RECEIPT'

   IF @@ROWCOUNT = 0
   BEGIN
      SET @nErrNo = 248101
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Code missing
      GOTO Quit
   END

   IF ISNULL(@cTaskType, '') = '' OR ISNULL(@cTaskStatus, '') = ''
   BEGIN
      SET @nErrNo = 248102
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid code
      GOTO Quit
   END

   SELECT TOP 1
      @cAreaKey = areakey 
   FROM dbo.LOC WITH (NOLOCK)
   JOIN dbo.AreaDetail AD WITH (NOLOCK)
   ON LOC.PutawayZone = AD.PutawayZone
   WHERE LOC = @cLOC

   -- Get new TaskDetailKeys
   SET @nSuccess = 1
   EXECUTE dbo.nspg_getkey
      'TASKDETAILKEY'
      , 10
      , @cNewTaskDetailKey OUTPUT
      , @nSuccess          OUTPUT
      , @nErrNo            OUTPUT
      , @cErrMsg           OUTPUT
   IF @nSuccess <> 1
   BEGIN
      SET @nErrNo = 248103
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
      GOTO Quit
   END

   -- Insert final task
   BEGIN TRY
      INSERT INTO TaskDetail (
         TaskDetailKey, TaskType, Status, UserKey, FromLOC, FromID, ToLOC, ToID, QTY, CaseID, AreaKey, UOMQty,
         PickMethod, StorerKey, SKU, LOT, ListKey, TransitCount, SourceType, SourceKey, WaveKey, Priority, SourcePriority, TrafficCop)
      VALUES (
         @cNewTaskDetailKey, @cTaskType, @cTaskStatus, '', @cLOC, @cToID, '', '', 0, '', ISNULL(@cAreaKey, ''), 0,
         'FP', @cStorerKey, '', '', '', 0, 'rdt_UCCReceive_CreateNextTask', '', '', '5', '9', NULL)
   END TRY
   BEGIN CATCH
      SET @nErrNo = 248104
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS fail
      GOTO Quit
   END CATCH

   QUIT:
END -- End Procedure

GO

GRANT EXECUTE ON rdt.rdt_UCCReceive_CreateNextTask TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

