SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1770ExtVal03                                    */
/* Purpose: FOR VLT                                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2024-10-23   Dennis    1.0   FCR-775 Created                         */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1770ExtVal03
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

   -- TM Pallet Pick
   IF @nFunc = 1770
   BEGIN
      IF @nStep = 4 -- ToLOC, DropID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Get storer
            DECLARE @cStorerKey NVARCHAR(15),
            @cSuggToLOC         NVARCHAR(10),
            @cFacility          NVARCHAR(5),
            @cOrderKey          NVARCHAR(10),
            @cTaskType          NVARCHAR(10)

            SELECT @cFacility = Facility FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE  Mobile = @nMobile       
            SELECT @cStorerKey = StorerKey, @cSuggToLOC = TOLOC,@cTaskType = TaskType FROM TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey

            IF rdt.rdtGetConfig(@nFunc,'HUSQGRPPICK',@cStorerKey) = '1'
            BEGIN
               IF @cSuggToLOC <> @cToLOC
               BEGIN
                  IF EXISTS ( SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE LOC= @cSuggToLOC AND LocationType = N'STAGEOB' AND Facility = @cFacility)
                  BEGIN
                     SET @nErrNo = 226101
                     SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') -- 226101Cannot Override Marshalling Location
                     GOTO Quit
                  END
                  ELSE IF EXISTS ( SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE LOC= @cSuggToLOC AND LocationType = N'VAS' AND Facility = @cFacility)
                  AND NOT EXISTS( SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE LOC= @cToLOC AND LocationType = N'VAS' AND Facility = @cFacility)
                  BEGIN
                     SET @nErrNo = 226102
                     SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') -- 226102Cannot Override Not a VAS Location
                     GOTO Quit
                  END
                  ELSE IF NOT EXISTS ( SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE LOC= @cSuggToLOC AND LocationType = N'VAS' AND Facility = @cFacility)
                  AND NOT EXISTS( SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE LOC= @cSuggToLOC AND LocationType = N'STAGEOB' AND Facility = @cFacility)
                  BEGIN
                     SET @nErrNo = 90763
                     SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP') --ToLOC Diff   
                     GOTO Quit
                  END
               END
               IF @cTaskType = 'FPK'
               BEGIN
                  IF CHARINDEX(' ',@cDropID)>0 OR LEN(@cDropID) <> 18 OR CONVERT(NVARCHAR(30),substring(@cDropID,1,3)) <> '050'
                  BEGIN
                     SET @nErrNo = 226103
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 226103Invalid Drop ID
                     GOTO Quit
                  END
                  --1.Exists in pickdetail
                  --2.Exists in Packdetail
                  --3.Exists in Dropid
                  ELSE IF (EXISTS (SELECT 1 FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cDropID))
                  OR EXISTS(select 1 FROM dbo.PackDetail (NOLOCK) where STORERKEY = @cStorerKey AND Dropid = @cDropID)
                  OR EXISTS(SELECT dropid FROM dbo.dropid (NOLOCK) WHERE Dropid = @cDropID)
                  BEGIN
                     SET @nErrNo = 217933
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropIDIsUsed
                     GOTO Quit
                  END
                  --1.Pickdetail not done & from loc is not PICK OR CASE loc
                  --2.Pickdetail not done & id <> ''
                  ELSE IF EXISTS (SELECT 1 FROM dbo.PICKDETAIL PD (NOLOCK) 
                  JOIN dbo.LOC LOC WITH (NOLOCK) ON LOC.LOC = PD.LOC 
                  WHERE PD.STORERKEY = @cStorerKey AND PD.STATUS <> '9' AND PD.dropid = @cDropID 
                  AND (LOC.LocationType NOT IN ('PICK','CASE') AND LOC.Facility = @cFacility
                  OR (SELECT TOP 1 ID FROM dbo.pickdetail (NOLOCK) WHERE STORERKEY = @cStorerKey AND STATUS <> '9' AND Dropid = @cDropID)<>''))
                  BEGIN
                     SET @nErrNo = 217934
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropIDUsedforPAL
                     GOTO Quit
                  END
               END
            END
         END
      END
   END
   GOTO Quit

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1770ExtVal03 TO NSQL
GO
