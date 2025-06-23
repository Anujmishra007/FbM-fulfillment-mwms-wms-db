SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1770ExtUpd04                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: For VLT                                                     */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2024-10-12   Dennis    1.0   FCR-775 Created                         */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1770ExtUpd04]
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nQTY            INT
   ,@cToLOC          NVARCHAR( 10)
   ,@cDropID         NVARCHAR( 20)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   -- Get storer
   DECLARE @cUserID NVARCHAR(18),
   @cOrderKey NVARCHAR(10),
   @cStorerKey NVARCHAR(15),
   @cFacility  NVARCHAR(5),
   @cLoadKey NVARCHAR(20),
   @cPickSlipNo NVARCHAR(20),
   @cHUSQGRPPICK NVARCHAR(1),
   @cGroupKey NVARCHAR(10),
   @cFinalLOC NVARCHAR(20),
   @cWaveKey NVARCHAR(10),
   @cROrderKey NVARCHAR(10)

   SELECT @cFacility = Facility,@cUserID = USERNAME, @cStorerKey = StorerKey,@cHUSQGRPPICK = V_STRING44 FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE  Mobile = @nMobile       
   SELECT @cWaveKey = WaveKey,@cOrderKey = OrderKey,@cLoadKey = LOADKEY,@cGroupKey = GroupKey,@cFinalLOC = FinalLOC FROM TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey

   -- TM Pallet Pick
   IF @nFunc = 1770
   BEGIN
      IF @nStep = 4
      BEGIN
         IF @nInputKey = 1 
         BEGIN
            IF @cHUSQGRPPICK = '1'
            BEGIN
               -- INSERT DROP ID 
               IF EXISTS (SELECT 1 FROM LOC WITH(NOLOCK) WHERE Facility = @cFacility AND LOC = @cFinalLOC AND LocationType = 'STAGEOB')
               BEGIN
                  SELECT TOP 1 @cPickSlipNo = PickHeaderKey FROM PICKHEADER (NOLOCK) WHERE orderkey = @cOrderKey AND StorerKey = @cStorerKey
                  IF NOT EXISTS(SELECT 1 FROM dbo.DropID WITH(NOLOCK) WHERE DropID = @cDropID)
                     INSERT INTO Dropid(Dropid,Droploc,AdditionalLoc,DropIDType,LabelPrinted,ManifestPrinted,Status,TrafficCop,ArchiveCop,Loadkey,PickSlipNo)
                     VALUES(@cDropID,'','',0,'N',0,5,null,null,@cLoadKey,@cPickSlipNo)
               END
               -- RELEASE TASK
               IF NOT EXISTS (SELECT 1 FROM dbo.PickDetail WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND OrderKey = @cOrderKey
               AND LOC <> (SELECT ISNULL(OtherReference,'') FROM dbo.MBOL M WITH(NOLOCK) INNER JOIN dbo.ORDERS O ON O.StorerKey = @cStorerKey AND O.MBOLKey = M.MBOLKey WHERE O.OrderKey = @cOrderKey ))
               BEGIN
                  SELECT TOP 1 @cROrderKey = O.OrderKey 
                  FROM dbo.ORDERS O WITH(NOLOCK) 
                  INNER JOIN dbo.TASKDETAIL TD WITH(NOLOCK) ON TD.StorerKey = @cStorerKey AND O.OrderKey = TD.OrderKey
                  WHERE TaskType IN ('FPK','ASTCPK') AND TD.STATUS = 'S' AND TD.WaveKey = @cWaveKey AND O.StorerKey = @cStorerKey
                  ORDER BY O.DeliveryDate,TaskDetailKey
                  UPDATE dbo.TaskDetail WITH(ROWLOCK) SET Message01 = 'Staged' WHERE OrderKey = @cOrderKey AND ISNULL(Message01,'') = '' AND TASKTYPE IN ('FPK','ASTCPK','FPK1')
                  UPDATE dbo.TaskDetail WITH(ROWLOCK) SET STATUS = '0' WHERE OrderKey = @cROrderKey AND TaskType IN ('FPK','ASTCPK') AND STATUS = 'S' AND StorerKey = @cStorerKey
               END
            END
         END
      END
      IF @nStep = 5
      BEGIN
         IF @nInputKey = 0
         BEGIN
            IF @cHUSQGRPPICK = '1'
            BEGIN
               --Unassign task
               UPDATE dbo.TASKDETAIL WITH(ROWLOCK) SET
                  USERKEY = ''
               WHERE UserKey = @cUserID AND Status = '0' AND TaskType IN( 'FPK', 'FPK1' )
            END
         END
      END
   END

Quit:

END
GO
GRANT EXECUTE ON  [RDT].[rdt_1770ExtUpd04] TO [NSQL]
GO
