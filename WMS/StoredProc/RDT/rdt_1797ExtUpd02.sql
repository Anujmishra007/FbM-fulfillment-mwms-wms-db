SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1797ExtUpd02                                    */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-04-30   NLT03     1.0   FCR-11750 Created                       */
/************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1797ExtUpd02]
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey        NVARCHAR( 15)
   DECLARE @cSuggToloc        NVARCHAR(10)
   DECLARE @cFromLOC          NVARCHAR(10)
   DECLARE @cFromID           NVARCHAR(18)
   DECLARE @cSKU              NVARCHAR(20)
   DECLARE @cLOT              NVARCHAR( 10)
   DECLARE @cUserName         NVARCHAR( 18)
   DECLARE @nQTY              INT
   DECLARE @nInputKey         INT

   SELECT 
      @cStorerKey       = Storerkey,
      @cUserName        = UserName,
      @cSuggToloc       = V_String1,
      @nInputKey        = InputKey,
      @cTaskdetailKey   = V_TaskDetailKey
   FROM rdt.RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile
   
   -- TM Putaway From
   IF @nFunc = 1797
   BEGIN
      IF @nStep = 5 -- Reason Code
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- If the task is SKIPped, the ToLoc is updated as empty string, RFPutaway data is removed as well.
            -- So need update the ToLoc with suggested location, and book the pending move in again.
            IF ISNULL(@cSuggToloc, '') <> ''
            BEGIN
               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH(ROWLOCK)
                  SET 
                     ToLoc = @cSuggToloc,
                     TrafficCop = NULL
                  WHERE TaskDetailKey = @cTaskDetailKey
                     AND ToLoc <> @cSuggToloc
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 265451
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update TaskDetail Failed
                  GOTO Quit
               END CATCH
            END

            SELECT 
               @cFromLOC = FromLoc,
               @cFromID = FromID,
               @cSKU = SKU,
               @nQTY = Qty,
               @cLOT = LOT
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey

            BEGIN TRY
               EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
                  ,@cFromLOC
                  ,@cFromID
                  ,@cSuggToloc
                  ,@cStorerKey
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT
                  ,@cSKU          = @cSKU
                  ,@nPutawayQTY   = @nQTY
                  ,@cFromLOT      = @cLOT

                  IF @nErrNo <> 0
                  BEGIN
                     GOTO Quit
                  END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 265452
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Book Putaway PendingMoveIn Failed
               GOTO Quit
            END CATCH

            
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

GRANT EXECUTE ON rdt.rdt_1797ExtUpd02 TO NSQL
GO
