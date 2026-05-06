
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1814ExtUpd01                                  */
/*                                                                      */
/* Purpose: Schneider BE                                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-04-07 1.0  Jackc      FCR-10346 - Created                       */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1814ExtUpd01 (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR(15),
   @cFacility        NVARCHAR( 5), 
   @cTaskdetailKey   NVARCHAR(10),
   @cTTMTaskType     NVARCHAR(10),
   @cFromLOC         NVARCHAR(10),
   @cFromID          NVARCHAR(18), 
   @cCaseID          NVARCHAR(20), 
   @nToFunc          INT, 
   @nToScn           INT, 
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @nDebugFlag INT = 0

   DECLARE
      @nRowCount        INT, 
      @cOrderKey        NVARCHAR(10),
      @cMbolKey         NVARCHAR(10),
      @cPlaceOfLoading  NVARCHAR(30)   


   SET @nErrNo = 0

   IF @nFunc = 1814
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @cTTMTaskType = 'ASTLO'
         BEGIN
            SELECT TOP 1 @cOrderKey = OrderKey
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND ID = @cFromID

            SELECT TOP 1
               @cMbolKey = MB.MbolKey,
               @cPlaceOfLoading = placeofloading
            FROM dbo.MBOL MB WITH (NOLOCK)
            JOIN dbo.MBOLDETAIL MBD WITH (NOLOCK)
               ON MB.MbolKey = MBD.MbolKey
            WHERE OrderKey = @cOrderKey
               AND Status <> '9'

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
            BEGIN
               SET @nErrNo = 263301
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Mbol not found
               GOTO Quit
            END

            IF ISNULL(@cPlaceOfLoading, '') = ''
            BEGIN
               SET @nErrNo = 263302
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Door Provided
               GOTO Quit
            END

            IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cPlaceOfLoading)
            BEGIN
               SET @nErrNo = 263303
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Door
               GOTO Quit
            END

            BEGIN TRY
               UPDATE dbo.TaskDetail WITH (ROWLOCK)
               SET
                  ToLoc = @cPlaceOfLoading,
                  FinalLOC = @cPlaceOfLoading
               WHERE TaskDetailKey = @cTaskDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 263304
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd taskdetail fail
               GOTO Quit
            END CATCH

            GOTO Quit 
         END -- ASTLO
      END --st1
   END -- 1814

   GOTO Quit

   QUIT:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1814ExtUpd01 TO NSQL
GO
