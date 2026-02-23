SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Store procedure: rdt_1812GetTask08                                   */    
/* Copyright      : maersk                                              */    
/*                                                                      */    
/* Purpose: Get next pick task for whole area until finish              */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date        Rev    Author    Purposes                                */    
/* 2025-06-11  1.0.0  Dennis    FCR-3959. Created                       */
/* 2025-12-03  1.0.1  PPA374    Added same side VNA pick logic          */
/* 2026-02-23  1.0.2  PPA374    Checking order for next task            */
/************************************************************************/    
    
CREATE OR ALTER PROC [RDT].[rdt_1812GetTask08] (    
   @nMobile          INT,    
   @nFunc            INT,    
   @cLangCode        NVARCHAR( 3),    
   @cUserName        NVARCHAR( 15),    
   @cAreaKey         NVARCHAR( 10),    
   @cListKey         NVARCHAR( 10),    
   @cDropID          NVARCHAR( 20),    
   @cNewTaskKey      NVARCHAR( 10) OUTPUT,    
   @nErrNo           INT           OUTPUT,    
   @cErrMsg          NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max    
) AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
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
   DECLARE @cLoadKey       NVARCHAR( 10)    
   DECLARE @cGroupKey      NVARCHAR( 10)    
   DECLARE @cTaskType      NVARCHAR( 10)    
   DECLARE @cPalletFinalLOC   NVARCHAR( 10)    
   DECLARE @cPalletFinalZone  NVARCHAR( 10)    
   DECLARE @cFinalPAZoneInLOC NVARCHAR( 10),
   @cTaskDetailKey      NVARCHAR(10),
   @cLastLoc            NVARCHAR(10),
   @cLastSide           NVARCHAR(10),
   @cLastAisle          NVARCHAR(10),
   @cLastCategory       NVARCHAR(20)

   SELECT @cStorerKey = StorerKey,
   @cTaskDetailKey  = V_TaskDetailKey,
   @cLastLoc = V_LOC
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cNewTaskKey = ''

   SELECT TOP 1 @cLastSide = Floor, @cLastAisle = LocAisle, @cLastCategory = LocationCategory FROM LOC WITH(NOLOCK) WHERE LOC = @cLastLoc

   SELECT TOP 1 @cNewTaskKey = TaskDetailKey
   FROM dbo.TaskDetail TD WITH (NOLOCK)    
   JOIN dbo.LOC WITH(NOLOCK) ON LOC.LOC = TD.FromLOC
   WHERE TD.ListKey <> @cListKey  
   AND TD.UserKey = @cUserName  
   AND TD.AreaKey = @cAreaKey
   AND TD.Storerkey = @cStorerKey
   AND TD.Status = '3'
   AND TaskType IN ('FCP','FCP1')
   AND OrderKey = @cOrderKey
   ORDER BY 
   IIF(LOC.LocAisle = ISNULL(@cLastAisle,'') AND ISNULL(@cLastCategory,'') = 'VNA',1,99),
   IIF(LOC.LocAisle = ISNULL(@cLastAisle,'') AND ISNULL(@cLastCategory,'') = 'VNA' AND ISNULL(@cLastSide,'') = LOC.Floor,1,99),
   LOC.LogicalLocation,
   LOC.LOC

   IF ISNULL(@cNewTaskKey,'') = ''    
   BEGIN    
      IF EXISTS( SELECT 1    
         FROM dbo.TaskDetail WITH (NOLOCK)    
         WHERE ListKey = @cListKey    
         AND UserKey = @cUserName
            AND Status = '5')    
      BEGIN    
         SET @nErrNo = 51101    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTask.ClosePL    
         GOTO Fail    
      END    
      ELSE    
      BEGIN    
         SET @nErrNo = 51102    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No more task    
         GOTO Fail    
      END 
   END  

   UPDATE TaskDetail WITH (ROWLOCK) SET    
      ListKey = @cListKey 
   WHERE TaskDetailKey = @cNewTaskKey    

   IF NOT EXISTS ( --Tasks are done
      SELECT 1 FROM dbo.TaskDetail TD WITH (NOLOCK)  
      INNER JOIN dbo.TaskDetail TD1 WITH (NOLOCK) ON TD1.OrderKey = TD.OrderKey AND TD1.TASKDETAILKEY = @cTaskDetailKey
      WHERE TD.Status <> '9'    
      AND TD.TaskType IN ('FCP','FCP1')
   )
   AND EXISTS(--Kitting Orders
      SELECT  1
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      JOIN dbo.PickDetail PD WITH (NOLOCK)
         ON TD.TaskDetailKey = PD.TaskDetailKey
      JOIN dbo.ORDERS ORD WITH (NOLOCK)
         ON PD.OrderKey = ORD.OrderKey
      JOIN dbo.CodeLKUP CL WITH (NOLOCK)
         ON ORD.type = CL.Code AND CL.LISTNAME = 'JCBKITORDT'
         AND CL.Short = 'Y'         
      WHERE TD.TaskDetailKey = @cTaskDetailKey)
   BEGIN
      SET @cErrMsg = rdt.rdtgetmessage( 239660, @cLangCode, 'DSP') -- SO IS FULLY PICKED
   END

Fail:    
    
END 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON  [RDT].[rdt_1812GetTask08] TO [NSQL]
GO
