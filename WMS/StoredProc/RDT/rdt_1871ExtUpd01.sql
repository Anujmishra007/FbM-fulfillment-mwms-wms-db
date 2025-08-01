SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1871ExtUpd01                                    */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-05-20   Dennis    1.0   FCR-3954 Created                        */
/************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1871ExtUpd01]
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT
   ,@nScn            INT
   ,@cEquipmentProfileKey NVARCHAR( 10)
   ,@cNewEquipmentProfileKey NVARCHAR( 10)
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE @PAPath               NVARCHAR(10)
   DECLARE @ToLOC                NVARCHAR(20)
   DECLARE @FinalLOC             NVARCHAR(20)
   DECLARE @TMFromPutaway        NVARCHAR(10)
   DECLARE @cNewTaskDetailKey    NVARCHAR(10)
   DECLARE @nSuccess             INT
   DECLARE @cStorerkey           NVARCHAR(10)
   DECLARE @cFacility            NVARCHAR(5)
   DECLARE @cListKey             NVARCHAR(10)
   DECLARE @cSourceType          NVARCHAR( 30),
   @cAreaKey                     NVARCHAR(10),
   @cSuggToLoc          NVARCHAR(10),
   @cSuggFinalLoc       NVARCHAR(10),
   @cSuggID             NVARCHAR(18)

   SELECT @cStorerkey = storerkey,
      @cFacility = Facility,
      @cAreaKey = V_String32
   FROM RDT.RDTMobrec (NOLOCK)
   WHERE Mobile = @nMobile

   
   IF @nFunc = 1871
   BEGIN
      IF @nStep = 4 -- To loc
      BEGIN
         -- Get task info
         SELECT 
            @cListKey      = ListKey, 
            @cSourceType   = 'rdt_TM_PutawayFrom_CreateTask',
            @cSuggToLoc = ToLoc,
            @cSuggFinalLoc = FinalLoc,
            @cSuggID = FromID,
            @cAreaKey = AD.AreaKey
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         LEFT JOIN dbo.LOC LOC WITH (NOLOCK)
            ON LOC.LOC = ToLoc
         LEFT JOIN dbo.AREADETAIL AD WITH (NOLOCK)
            ON AD.PutawayZone = LOC.PutawayZone
         WHERE TaskDetailKey = @cTaskdetailKey

         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET AreaKey = @cAreaKey
         WHERE  StorerKey = @cStorerKey
            AND TaskDetailKey <> @cTaskDetailKey
            AND TaskType = 'PA1'
            AND Status = '0'
            AND FromID = @cSuggID
            AND FromLoc = @cSuggToLoc
            AND ToLoc = @cSuggFinalLoc
            AND SourceType = @cSourceType
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

GRANT EXECUTE ON rdt.rdt_1871ExtUpd01 TO NSQL
GO
