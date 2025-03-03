SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: [rdt_1764ExtUpdVLT]                                 */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: send replenishment to PND OUT                               */
/*                                                                      */
/* Date         Author   Purpose                                        */
/* 01/05/2024   PPA374   Created                                        */
/* 26/09/2024   PPA374   Deleting incorrect task created by system SP   */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1764ExtUpdVLT]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   ,@nAfterStep      INT = 0
   ,@cDropID         NVARCHAR( 20) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @PNDOUT NVARCHAR(20),
   @TASKTYPE NVARCHAR(20),
   @FROMPAZ NVARCHAR(20),
   @PICKMETHOD NVARCHAR(10),
   @StorerKey NVARCHAR(20),
   @Facility NVARCHAR(20)

   select top 1 @TASKTYPE = tasktype from TaskDetail WITH (NOLOCK) where TaskDetailKey = @cTaskdetailKey 
   select top 1 @FROMPAZ = putawayzone from LOC WITH (NOLOCK) where loc = (select top 1 fromloc from TaskDetail WITH (NOLOCK) where TaskDetailKey = @cTaskdetailKey)
   SET @PNDOUT = ''
   select top 1 @PICKMETHOD = pickmethod from TaskDetail WITH (NOLOCK) where TaskDetailKey = @cTaskdetailKey  
   select top 1 @StorerKey = StorerKey, @Facility = Facility from rdt.RDTMOBREC (NOLOCK) where Mobile = @nMobile

   IF @TASKTYPE = 'RPF' and exists (select 1 from CODELKUP WITH (NOLOCK) where @FROMPAZ = code and storerkey = @StorerKey and LISTNAME = 'VNAZONHUSQ') and @nStep = 0
   BEGIN
      SET @PNDOUT = (select TOP 1 CODE from CODELKUP WITH (NOLOCK) where LISTNAME = 'PNDOUTHUSQ' and storerkey = @StorerKey and short = (select LocAisle from LOC WITH (NOLOCK) where loc = (select TOP 1 FromLoc from taskdetail WITH (NOLOCK) where TaskDetailKey = @cTaskdetailKey)))
   
      update TaskDetail
     set TransitLOC = @PNDOUT, ToLoc = @PNDOUT
     where TaskDetailKey = @cTaskdetailKey

      delete from taskdetail
      where exists
      (select 1 from taskdetail TD2 (NOLOCK) where TD2.taskdetailkey = @cTaskdetailKey and taskdetail.TaskDetailKey <> TD2.TaskDetailKey 
      and taskdetail.FromLoc = TD2.FromLoc and TD2.status in ('0','3') and taskdetail.FromID = TD2.FromID and taskdetail.Storerkey = TD2.Storerkey 
      and TD2.Storerkey = @StorerKey and exists (select 1 from loc L (NOLOCK) where L.Loc = taskdetail.toloc and facility = @Facility and LocationCategory = 'PND'))
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1764ExtUpdVLT TO NSQL
GO
