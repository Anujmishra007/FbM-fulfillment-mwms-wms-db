
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: [rdt_511ExtUpdVLT]                                  */
/* Copyright: Maersk                                                    */
/*                                                                      */
/*                                                                      */
/* Date       VER    Author   Purpose                                   */
/* 15/07/24   1.0    PPA374   Clearing outstanding pending moves        */
/* 21/10/24   1.1    PPA374   UWP-25931                                 */
/* 23/10/24   1.2    Dennis   FCR-775 Task Detail Check                 */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtUpdVLT] (
@nMobile    INT,
@nFunc      INT,
@cLangCode  NVARCHAR( 3),
@nStep      INT,
@nInputKey  INT,
@cFacility  NVARCHAR( 5),
@cStorerKey NVARCHAR( 15),
@cFromID    NVARCHAR( 18),
@cFromLOC   NVARCHAR( 10),
@cToLOC     NVARCHAR( 10),
@nErrNo     INT           OUTPUT,
@cErrMsg    NVARCHAR( 20) OUTPUT
) AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

DECLARE
   @Orderkey NVARCHAR(15),
   @Wavekey NVARCHAR(15),
   @NextOrderKey NVARCHAR(15)

SET @Orderkey = ''
SET @Wavekey = ''
SET @NextOrderKey = ''

   IF @nStep = 3 -- To Loc
   -- Clearing outstanding pending moves, as since ID is moved, it is not required anymore.
   BEGIN
      UPDATE dbo.LOTxLOCxID WITH(ROWLOCK)
      SET PendingMoveIN = 0
      WHERE id = @cFromID AND PendingMoveIN > 0 AND StorerKey = @cStorerKey AND ID <> ''

      IF EXISTS (SELECT 1 FROM dbo.loc L (NOLOCK) WHERE loc = @cToLOC
      AND EXISTS (SELECT 1 FROM dbo.CODELKUP (NOLOCK) WHERE LISTNAME = 'OUTZONHUSQ' AND Storerkey = @cStorerKey AND L.LocationType = Code))
      BEGIN
         SELECT TOP 1 @Orderkey = orderkey FROM dbo.PICKDETAIL (NOLOCK) WHERE id = @cFromID AND Storerkey = @cStorerKey
         SELECT TOP 1 @Wavekey = wavekey FROM dbo.TaskDetail (NOLOCK) WHERE OrderKey = @Orderkey AND Storerkey = @cStorerKey AND TaskType in ('FPK','ASTCPK','FPK1')
         SELECT TOP 1 @NextOrderKey = TD.OrderKey 
            FROM dbo.TaskDetail TD WITH(NOLOCK) 
            JOIN dbo.Orders O WITH(NOLOCK) 
            ON O.OrderKey = TD.OrderKey
            WHERE TD.Status = 'S'
               AND TD.OrderKey <> @Orderkey AND WaveKey = @Wavekey AND TD.Storerkey = @cStorerKey AND TaskType in ('FPK','ASTCPK','FPK1') 
            ORDER BY CASE WHEN ISNULL(O.OrderGroup,'') = '' THEN 'YYY' WHEN ISNUMERIC(ISNULL(O.OrderGroup,'')) = 0 THEN 'YY'+ISNULL(O.OrderGroup,'') 
            ELSE ISNULL(O.OrderGroup,'') END, TaskDetailKey

         IF (SELECT isnull(sum(openqty),0)-isnull(sum(QtyPicked),0) FROM orderdetail (NOLOCK)
         WHERE orderkey = @Orderkey AND StorerKey = @cStorerKey AND Facility = @cFacility) <= 0
         AND not EXISTS (SELECT 1 FROM dbo.PICKDETAIL (NOLOCK) WHERE OrderKey = @Orderkey AND Status < '5' AND Storerkey = @cStorerKey)
         AND NOT EXISTS (SELECT 1 FROM dbo.PICKDETAIL PD (NOLOCK) WHERE OrderKey = @Orderkey AND Storerkey = @cStorerKey
         AND NOT EXISTS (SELECT 1 FROM dbo.LOC L WITH(NOLOCK) WHERE L.Loc = PD.Loc 
            AND NOT EXISTS (SELECT 1 FROM dbo.CODELKUP (NOLOCK) WHERE LISTNAME = 'OUTZONHUSQ' AND Storerkey = @cStorerKey AND L.LocationType <> Code)))
         AND NOT EXISTS (select 1 from dbo.TaskDetail TD WITH (NOLOCK) where WaveKey = @Wavekey and status not in ('H','S','9'))
         BEGIN 
            UPDATE dbo.TaskDetail WITH(ROWLOCK)
            SET Status = '0'
            WHERE OrderKey = @NextOrderKey AND status = 'S'
         END
      END
      
      IF rdt.rdtGetConfig(@nFunc,'HUSQGRPPICK',@cStorerKey) = '1'
      BEGIN
         DECLARE 
            @cLoadKey NVARCHAR(20),
            @cDropID  NVARCHAR(20),
            @cPickSlipNo NVARCHAR(20)

         SELECT TOP 1 @Orderkey = orderkey, @cDropID = Dropid FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE id = @cFromID AND Storerkey = @cStorerKey
         SELECT TOP 1 @cPickSlipNo = PickHeaderKey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE OrderKey = @Orderkey
         SELECT TOP 1 @cLoadKey = Loadkey FROM dbo.TaskDetail WITH(NOLOCK) where OrderKey = @OrderKey

         --From Vas LOC to marshalling lane
         IF EXISTS (SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE FACILITY = @cFacility AND LOC = @cFromLOC AND LocationType = 'VAS')
         AND EXISTS (SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE FACILITY = @cFacility AND LOC = @cToLOC AND LocationType = 'STAGEOB')
         BEGIN
            IF NOT EXISTS(SELECT 1 FROM dbo.DropID WITH(NOLOCK) WHERE DropID = @cDropID)
            BEGIN
               INSERT INTO dbo.Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,TrafficCop,ArchiveCop,Loadkey,PickSlipNo)
               VALUES(@cDropID,'','',0,'N',0,5,null,null,@cLoadKey,@cPickSlipNo)
            END
         END
      END
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_511ExtUpdVLT] TO [NSQL]
GO
