SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_511ExtUpd13                                     */
/* Copyright      : Maersk                                              */
/* Purpose: For Grape Galina                                            */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-02-14 1.0.0  JCH507   FCR-2597. Created                         */
/* 2025-03-07 1.0.1  CYU027   FCR-2597                                  */
/* 2025-04-17 1.0.2  CYU027   FCR-2936                                 */
/* 2025-12-08 1.0.3  JCH507   FCR-7405                                 */
/* 2026-06-12 1.0.4  NYE018   FCR-9762                                 */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtUpd13] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cFromID        NVARCHAR( 18),
   @cFromLOC       NVARCHAR( 10),
   @cToLOC         NVARCHAR( 10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @bDebugFlag           BINARY = 0
   DECLARE @cNewTaskDetailKey    NVARCHAR( 10)
   DECLARE @cKITUsrDef4          NVARCHAR( 30)
   DECLARE @nSuccess             INT
   DECLARE @cPriority            NVARCHAR( 1)
   DECLARE @cTaskFromLogiLoc     NVARCHAR( 10)
   DECLARE @cTaskToLogiLoc       NVARCHAR( 10)
   DECLARE @cKitkey              NVARCHAR( 10)
   DECLARE @cKitExternStatus     NVARCHAR( 30)

   DECLARE @cFromLocPutawayZone  NVARCHAR( 20)
   DECLARE @cToLocPutawayZone    NVARCHAR( 20)

   IF @nFunc = 511 -- Move by ID
   BEGIN
      IF @nStep = 3 -- ToLOC
      BEGIN
         IF @bDebugFlag = 1
            SELECT 'Step 3 validation'

         IF @nInputKey = 1
         BEGIN

            IF NOT EXISTS(
               SELECT 1 FROM codelkup (NOLOCK)
               WHERE Listname ='CCHAINPD'
                 AND Storerkey = @cStorerkey
                 AND code = @cToLOC
            )
            BEGIN --Normal movement
               GOTO Quit
            END

            SELECT TOP 1
               @cKitExternStatus = KIT.externStatus,
               @cKitkey = KIT.KITKey,
               @cKITUsrDef4 = ISNULL(KIT.USRDEF4, '')
            FROM KIT WITH (NOLOCK)
            JOIN KITDETAIL WITH (NOLOCK) 
               ON KIT.KITKey = KITDETAIL.KITKey
            WHERE KIT.Facility = @cFacility
               AND   KIT.StorerKey = @cStorerKey
               AND   KIT.[Status] <> '9'
               AND   KITDETAIL.Id = @cFromID
               AND   KITDETAIL.[Type] = 'F'

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 233351
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID not allocated to Kit
               GOTO Quit
            END

            IF @cKITUsrDef4 = ''
            BEGIN
               SET @nErrNo = 233352
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No production line  
               GOTO Quit
            END

            IF @cKitExternStatus = '7'
            BEGIN
               SET @nErrNo = 233356
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- KIT on hold  
               GOTO Quit
            END

            IF @bDebugFlag = 1
               SELECT @cKITUsrDef4 AS FinalToLoc, @cFromID AS FromID, @cToLOC AS ToLOC

            --Task from loc is the location pallet move to
            --Task to loc is the final production line
            SELECT @cTaskFromLogiLoc = ISNULL(LogicalLocation,'') FROM LOC WITH (NOLOCK) 
            WHERE Facility = @cFacility 
               AND LOC = @cToLOC

            SELECT @cTaskToLogiLoc = ISNULL(LogicalLocation,'') FROM LOC WITH (NOLOCK) 
            WHERE Facility = @cFacility 
               AND LOC = @cKITUsrDef4

            IF @@ROWCOUNT < 1
            BEGIN
               SET @nErrNo = 233354
               SET @cErrMsg = REPLACE(rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'),'{}',@cKITUsrDef4 )-- KIT {} does not have valid production line location
               GOTO Quit
            END
            
            -- Get new TaskDetailKeys      
            SET @nSuccess = 1
            EXECUTE dbo.nspg_getkey      
               'TASKDETAILKEY'      
               , 10      
               , @cNewTaskDetailKey OUTPUT      
               , @nSuccess          OUTPUT      
               , @nErrNo            OUTPUT      
               , @cErrMsg           OUTPUT      
            IF @nSuccess <> 1      
            BEGIN      
               SET @nErrNo = 233355      
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey      
               GOTO Quit      
            END

            SET @cPriority = '9'
            -- Insert final task
            BEGIN TRY
               INSERT INTO TaskDetail (
                  TaskDetailKey, TaskType, Status, UserKey, FromLOC, LogicalFromLoc, FromID, ToLOC, LogicalToLoc, ToID, 
                  QTY, CaseID, AreaKey, UOMQty, PickMethod, StorerKey, SKU, LOT, ListKey, SourceType, SourceKey, WaveKey, 
                  Priority, TrafficCop)
               VALUES (
                  @cNewTaskDetailKey, 'ASTMV', '0', '', @cToLOC, @cTaskFromLogiLoc, @cFromID, @cKITUsrDef4, @cTaskToLogiLoc, @cFromID, 
                  0, '', '', 0, 'FP', @cStorerKey, '', '',  '', 'rdt_511ExtUpd13',  @cKitkey, '', 
                  @cPriority, NULL)
            END TRY
            BEGIN CATCH
               SET @nErrNo = 233353
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
               GOTO Quit
            END CATCH

            UPDATE KD SET
               KD.Loc = @cToLOC
            FROM KIT WITH (NOLOCK)
                    JOIN KITDETAIL KD WITH (NOLOCK)
                         ON KIT.KITKey = KD.KITKey
            WHERE KIT.Facility = @cFacility
               AND KIT.StorerKey = @cStorerKey
               AND KIT.[Status] <> '9'
               AND KD.Id = @cFromID
               AND KD.[Type] = 'F'
               AND KIT.KITKey = @cKitkey
            
            -- FCR-9762 Start
            SELECT @cFromLocPutawayZone = PutawayZone FROM LOC (NOLOCK) WHERE LOC = @cFromLOC AND Facility = @cFacility
            SELECT @cToLocPutawayZone = PutawayZone FROM LOC (NOLOCK) WHERE LOC = @cToLOC AND Facility = @cFacility

            IF EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE ListName = 'KITPAZONES' AND Storerkey = @cStorerKey 
                        AND Code = '511-FROMLOC' AND Short = @cFromLocPutawayZone)
               AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE ListName = 'KITPAZONES' AND Storerkey = @cStorerKey 
                        AND Code = '511-TOLOC' AND Short = @cToLocPutawayZone)
            BEGIN
               SELECT TOP 1 @cKitkey = K.KITKey
               FROM KIT K (NOLOCK)
               JOIN KITDETAIL KD (NOLOCK) ON K.KITKey = KD.KITKey
               WHERE KD.Id = @cFromID
                 AND KD.Type = 'F'
                 AND K.Status <> '9'
                 AND K.Facility = @cFacility

               IF @@ROWCOUNT > 0
               BEGIN
                  BEGIN TRY
                     -- Update KITDETAIL Location
                     UPDATE KITDETAIL
                     SET Loc = @cToLOC
                     WHERE KITKey = @cKitkey 
                        AND Id = @cFromID 
                        AND Type = 'F'

                     -- Update KIT.USRDEF6 if empty
                     UPDATE KIT
                     SET USRDEF6 = GETDATE()
                     WHERE KITKey = @cKitkey 
                        AND ISNULL(USRDEF6, '') = ''
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 233357
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ToLocUpdFail
                     GOTO Quit
                  END CATCH
               END
            END
            -- FCR-9762 End

         END
      END
   END

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_511ExtUpd13 TO NSQL
GO
