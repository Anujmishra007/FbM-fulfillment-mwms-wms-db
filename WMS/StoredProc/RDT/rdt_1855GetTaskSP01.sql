SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/***********************************************************************************/
/* Store procedure: rdt_1855GetTaskSP01                                            */
/* Copyright      : Maersk                                                         */
/* Customer       : VIVOBAREFOOT                                                   */
/*                                                                                 */
/* Purpose: TM Cluster Pick Get Task SP                                            */
/*                                                                                 */
/* Called from: rdtfnc_TM_Assist_ClusterPick                                       */
/*                                                                                 */
/* Date         Rev    Author   Purposes                                           */
/* 2026-03-03   1.0.0  NickT    FCR-10824 Get Task                                 */
/***********************************************************************************/
  
CREATE OR ALTER PROC [RDT].[rdt_1855GetTaskSP01] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cGroupKey      NVARCHAR( 10),
   @cCartId        NVARCHAR( 10),
   @cType          NVARCHAR( 10),
   @cTaskDetailKey NVARCHAR( 10) OUTPUT,
   @cFromLoc       NVARCHAR( 10) OUTPUT,
   @cCartonId      NVARCHAR( 20) OUTPUT,
   @cToteID        NVARCHAR( 20) OUTPUT,
   @cSKU           NVARCHAR( 20) OUTPUT,
   @nQty           INT           OUTPUT,
   @tGetTask       VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cPickZone                 NVARCHAR( 10),
      @cUserName                 NVARCHAR( 18),
      @cMethod                   NVARCHAR( 5),
      @cNewTaskDetailKey         NVARCHAR( 10),
      @cLogicalLocation          NVARCHAR( 18),
      @cPickConfirmStatus        NVARCHAR( 1),
      @nRowCount                 INT

   -- Get storer config
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   -- Get logical LOC
   SET @cLogicalLocation = ''
   SELECT @cLogicalLocation = LogicalLocation
   FROM dbo.LOC WITH (NOLOCK)
   WHERE LOC = @cFromLoc
      AND Facility = @cFacility

   SET @cNewTaskDetailKey = ''  

   SELECT 
      @cUserName           = UserName,
      @cPickZone           = V_String24,
      @cMethod             = V_String25
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @cType = 'NEXTLOC'
   BEGIN
      SELECT TOP 1
         @cFromLoc = FromLoc,
         @cSKU = TD.Sku,
         @nQty = TD.Qty,
         @cCartonId = TD.Caseid,
         @cToteID = TD.DropID,
         @cNewTaskDetailKey = TD.TaskDetailKey
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON ( TD.FromLoc = LOC.Loc)
      INNER JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.FromLoc = PD.Loc AND TD.Sku = PD.Sku
      WHERE TD.Groupkey = @cGroupKey
         AND TD.StorerKey = @cStorerKey
         AND TD.TaskType = 'ASTCPK'
         AND TD.Status = '3'
         AND TD.UserKey = @cUserName
         AND TD.DeviceID = @cCartId
         AND LOC.Facility = @cFacility
         AND TD.DropID <> ''
         AND PD.Status < @cPickConfirmStatus
         AND PD.Status <> '4'
         AND LOC.LOC <> @cFromLoc
      ORDER BY LOC.PALogicalLoc, LOC.Loc, TD.TaskDetailKey, TD.Sku
        
      SET @nRowCount = @@ROWCOUNT
   END  
  
   IF @cType = 'NEXTCARTON'
   BEGIN  
      SET @nRowCount = 0
   END

   IF @cType = 'NEXTSKU'
   BEGIN
      SELECT TOP 1
         @cSKU = TD.Sku,
         @nQty = TD.Qty,
         @cCartonId = TD.Caseid,
         @cToteID = TD.DropID,
         @cNewTaskDetailKey = TD.TaskDetailKey
      FROM dbo.TaskDetail TD WITH (NOLOCK)
      INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON ( TD.FromLoc = LOC.Loc)
      INNER JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON ( TD.StorerKey = PD.StorerKey AND TD.FromLoc = PD.Loc AND TD.Sku = PD.Sku )
      WHERE TD.Groupkey = @cGroupKey
         AND TD.StorerKey = @cStorerKey
         AND TD.TaskType = 'ASTCPK'
         AND TD.Status = '3'
         AND TD.DropID <> ''
         AND TD.UserKey = @cUserName
         AND TD.FromLoc = @cFromLoc
         AND LOC.Facility = @cFacility
         AND PD.Status < @cPickConfirmStatus
         AND PD.Status <> '4'
      ORDER BY LOC.PALogicalLoc, LOC.Loc, TD.TaskDetailKey, TD.Sku

      SET @nRowCount = @@ROWCOUNT
   END

   IF @nRowCount = 0
   BEGIN
      SET @nErrNo = 260501
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No task is found
      GOTO Quit
   END

   IF ISNULL( @cNewTaskDetailKey, '') <> ''
      SET @cTaskDetailKey = @cNewTaskDetailKey
   Quit:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1855GetTaskSP01 to nSQL
GO 