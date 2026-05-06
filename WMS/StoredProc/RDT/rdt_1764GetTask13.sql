SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: rdt_1764GetTask13                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Get next replenish task                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev    Author    Purposes                                */
/* 2025-06-11  1.0.0  Dennis    FCR-3959                                */
/* 2025-12-03  1.0.1  PPA374    Added same side VNA pick logic          */ 
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1764GetTask13] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @cUserName        NVARCHAR( 15),
   @cAreaKey         NVARCHAR( 10),
   @cListKey         NVARCHAR( 10),
   @cDropID          NVARCHAR( 20),
   @cNewTaskKey      NVARCHAR( 10)  OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT  -- screen limitation, 20 char max
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bDebugFlag     BINARY = 0

   DECLARE @bSuccess       INT
   DECLARE @bSkipTheTask   INT
   DECLARE @cFinalLOC      NVARCHAR( 10)
   DECLARE @cFinalID       NVARCHAR( 18)
   DECLARE @cFinalPAZone   NVARCHAR( 10)
   DECLARE @cFinalAisle    NVARCHAR( 10)

   DECLARE @cFacility      NVARCHAR( 5)
   DECLARE @cToLOC         NVARCHAR( 10)
   DECLARE @cToLOCAisle    NVARCHAR( 10)
   DECLARE @cToLOCCat      NVARCHAR( 10)
   DECLARE @cToPAZone      NVARCHAR( 10)

   DECLARE @cFromLOC       NVARCHAR( 10)
   DECLARE @cFromID        NVARCHAR( 18)
   DECLARE @cStorerKey     NVARCHAR( 10)
   DECLARE @cSKU           NVARCHAR( 20)
   DECLARE @cLOT           NVARCHAR( 10)
   DECLARE @nQTY           INT
   DECLARE @cToID          NVARCHAR( 18)
   DECLARE @cWaveKey       NVARCHAR( 10)
   DECLARE @cPalletFinalLOC NVARCHAR( 10)
   DECLARE @cOrderGroup    NVARCHAR( 20)
   DECLARE @cTaskType      NVARCHAR( 10)
   DECLARE @cPickMethod    NVARCHAR( 10)

   DECLARE    @cTaskDetailKey      NVARCHAR(10),
   @cLastLoc            NVARCHAR(10),
   @cLastSide           NVARCHAR(10),
   @cLastAisle          NVARCHAR(10),
   @b_Success           INT,
   @c_appflag           NVARCHAR(10),
   @c_fromloc           NVARCHAR(10),
   @c_outstring         NVARCHAR(4000),
   @cLastCategory       NVARCHAR(20),
   @cLastToLoc          NVARCHAR(20),
   @cCloseCont          NVARCHAR(20)

   SET @cNewTaskKey = ''

   SELECT @cStorerKey = StorerKey,
   @cLastLoc = V_LOC,
   @cTaskDetailKey = V_TaskDetailKey,
   @cLastToLoc = O_Field01,
   @cCloseCont = V_String70
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SELECT TOP 1 @cLastSide = Floor, @cLastAisle = LocAisle, @cLastCategory = LocationCategory FROM LOC WITH(NOLOCK) WHERE LOC = @cLastLoc

   SELECT TOP 1 @cToLOC = ToLoc FROM TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey AND Storerkey = @cStorerKey

   IF @cLastLoc = 'INTRANSIT' OR (@cCloseCont = '9' AND @cLastToLoc = 'INTRANSIT')
   BEGIN
      SELECT TOP 1 @cNewTaskKey = TaskDetailKey
      FROM dbo.TaskDetail TD WITH (NOLOCK)    
      JOIN dbo.LOC WITH(NOLOCK) ON LOC.LOC = TD.FromLOC
	  WHERE TD.TaskDetailKey <> @cTaskDetailKey
	  AND (TD.UserKey = @cUserName OR UserKeyOverRide = @cUserName)
      AND TD.AreaKey = @cAreaKey
	  AND TD.FromLoc = 'INTRANSIT'
	  AND TD.ToLoc = @cToLOC
	  AND TD.Status IN ('0','3')
	  ORDER BY 
      IIF(TD.FromLoc = 'INTRANSIT',1,99),
	  IIF(TD.ToLoc = @cToLOC,1,99),
	  TD.Message01 DESC,
	  TD.Message02 DESC,
      LOC.LogicalLocation,
      LOC.LOC
   END

   ELSE
   BEGIN
      SELECT TOP 1 @cNewTaskKey = TaskDetailKey
      FROM dbo.TaskDetail TD WITH (NOLOCK)    
      JOIN dbo.LOC WITH(NOLOCK) ON LOC.LOC = TD.FromLOC
      WHERE TD.ListKey <> @cListKey  
      AND TD.UserKey = @cUserName  
      AND TD.AreaKey = @cAreaKey
      AND TD.Status = '3'
      AND TD.TaskType IN ('RPF','RP1')
      AND TD.Storerkey = @cStorerKey
      ORDER BY 
      IIF(TD.TaskType = 'RPF',1,99),
      IIF(LOC.LocAisle = ISNULL(@cLastAisle,'') AND ISNULL(@cLastCategory,'') = 'VNA',1,99),
      IIF(LOC.LocAisle = ISNULL(@cLastAisle,'') AND ISNULL(@cLastCategory,'') = 'VNA' AND ISNULL(@cLastSide,'') = LOC.Floor,1,99),
      LOC.LogicalLocation,
      LOC.LOC
   END

   IF @cNewTaskKey = ''
   BEGIN
      IF EXISTS( SELECT 1
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE ListKey = @cListKey
         AND UserKey = @cUserName
            AND Status = '5')
      BEGIN
         IF @cAreaKey = 'MOTHERSONS' AND @cLastLoc <> 'INTRANSIT'
         BEGIN
            SELECT @b_success = 0
            SELECT @c_appflag = 'TRP'
            EXECUTE nspTTMEvaluateRPFFCPTasks_JCB
            @c_senddelimiter=''
            , @c_userid=@cUserName
            , @c_Strategykey=''
            , @c_ttmStrategykey=''
            , @c_ttmpickcode='REPLEN'
            , @c_ttmoverride=''
            , @c_AreaKey01=@cAreaKey
            , @c_AreaKey02=''
            , @c_AreaKey03=''
            , @c_AreaKey04=''
            , @c_AreaKey05=''
            , @c_LastLOC=''--Will fetch in JCB Get task sp
            , @c_outstring=@c_outstring OUTPUT
            , @b_Success=@b_success OUTPUT
            , @n_err=@nErrNo OUTPUT
            , @c_errmsg=@cErrMsg OUTPUT
            , @c_ptcid='' 
            , @c_fromloc=@c_fromloc OUTPUT 
            , @c_taskDetailkey=@cNewTaskKey OUTPUT 
         END

         IF @cNewTaskKey = ''
         BEGIN
            SET @nErrNo = 230301
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL
            GOTO Fail
         END
      END
      ELSE
      BEGIN
         SET @nErrNo = 230302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task
         GOTO Fail
      END
   END

   UPDATE TaskDetail WITH (ROWLOCK) SET    
      ListKey = @cListKey 
   WHERE TaskDetailKey = @cNewTaskKey   

Fail:

IF @bDebugFlag = 1
   SELECT 'Quit', @nErrNo, @cErrMsg

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1764GetTask13] TO [NSQL]
GO
