
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****************************************************************************/
/* Store procedure: rdt_1764ExtScn01                                        */
/* Copyright      : Maersk                                                  */
/* Customer       : Granite Levis                                           */
/*                                                                          */
/*                                                                          */
/* Date       Rev    Author   Purposes                                      */
/* 2025-03-11 1.0    NLT013   UWP-31321 Create                              */
/* 2025-05-21 1.1    NLT013   UWP-34785 Add new Exit Screen                 */
/****************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1764ExtScn01] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nScn             INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT,
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT,
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT,
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT,
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT,
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT,
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT,
   @cUDF30  NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nCurrentStep           INT,
      @nCurrentScn            INT,
      @cTaskDetailKey         NVARCHAR(10) = '',
      @cPendingTaskDetailKey    NVARCHAR(10) = '',
      @nStep_ToLOC            INT         = 6,  
      @nScn_ToLOC             INT         = 2685,
      @nStep_Exit             INT         = 7,  
      @nScn_Exit              INT         = 2686,
      @nStep_99               INT         = 99,  
      @nScn_NewExit           INT         = 6527,

      @cTTMTaskType           NVARCHAR(10),
      @cSuggID                NVARCHAR(18),
      @cSuggToLOC             NVARCHAR(10),
      @cSuggSKU               NVARCHAR(20),
      @cSKUDesc               NVARCHAR(60),
      @cSuggLOT               NVARCHAR(10),
      @cSuggFromLOC           NVARCHAR(10),
      @nQTY_RPL               INT,
      @nSystemQTY             NVARCHAR(10),
      @cPickMethod            NVARCHAR(10),
      @nTransit               INT,
      @cDropID                NVARCHAR(20),
      @cListKey               NVARCHAR(10),
      @cUserName              NVARCHAR(18),
      @cReasonCode            NVARCHAR(10),
      @cStatus                NVARCHAR(10),
      @cDefaultToLOC          NVARCHAR(10),
      @cDefaultSuggToLOC      NVARCHAR(10),
      @cLocShowDescr          NVARCHAR(1),  
      @cLocDescr              NVARCHAR(20),
      @cToLOC                 NVARCHAR(10),
      @cFinalLOC              NVARCHAR(10),
      @cTaskStatus            NVARCHAR(10),
      @cToLOCCat              NVARCHAR(10),
      @nRowCount              INT,
      @cTaskUserKey           NVARCHAR(18),
      @cAreaKey               NVARCHAR(10),

      @cMessage01              NVARCHAR(125),
      @cMessage02              NVARCHAR(125),
      @cMessage03              NVARCHAR(125),
      @cMessage04              NVARCHAR(125),
      @cMessage05              NVARCHAR(125)
 
   SELECT 
      @nCurrentStep        = Step,
      @nCurrentScn         = Scn,
      @cUserName           = UserName,
      @cListKey            = V_String7
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1764 -- TM Replen
   BEGIN
      IF @nCurrentStep = 0 -- Beginning
      BEGIN
         SET @cDefaultToLOC = rdt.rdtGetConfig( @nFunc, 'DefaultToLOC', @cStorerKey)
         IF @cDefaultToLOC = '0'
            SET @cDefaultToLOC = ''

         SET @cDefaultSuggToLOC = rdt.RDTGetConfig( @nFunc, 'DefaultSuggToLOC', @cStorerKey)
         IF @cDefaultSuggToLOC = '0'
            SET @cDefaultSuggToLOC = ''

         SET @cLocShowDescr = rdt.RDTGetConfig( @nFunc, 'LocShowDescr', @cStorerkey)
         
         SELECT TOP 1 
            @cPendingTaskDetailKey   = TaskDetailKey,
            @cDropID          = DropID,
            @cAreaKey         = AreaKey
         FROM dbo.TaskDetail WITH(NOLOCK) 
         WHERE StorerKey = @cStorerKey
            AND Status = '5'
            AND UserKey = @cUserName
            AND DropID <> ''
            AND TaskType = 'RPF'
            AND PickMethod = 'PP'

         SET @cMessage01 = 'Pending DropID is found, need close it.'
         SET @cMessage02 = 'Area Key: ' + @cAreaKey
         SET @cMessage03 = 'Drop ID: ' +@cDropID

         --Unfinished Task is found
         IF (ISNULL(@cPendingTaskDetailKey, '') <> '' AND @cDropID <> '')
         BEGIN
            EXEC rdt.rdtInsertMsgQueue 
               @nMobile = @nMobile,
               @nErrNo = @nErrNo,
               @cErrMsg = @cErrMsg,
               @cLine01 = @cMessage01,
               @cLine02 = @cMessage02,
               @cLine03 = @cMessage03,
               @cLine04 = '',
               @cLine05 = '',
               @cLine06 = '',
               @cLine07 = '',
               @cLine08 = '',
               @cLine09 = '',
               @nDisplayMsg = 0

            SET @cMessage01 = ''
            SET @cMessage02 = ''
            SET @cMessage03 = ''

            SELECT
               @cTTMTaskType     = TaskType,
               @cSuggID          = FromID,
               @cSuggLOT         = LOT,
               @cSuggFromLOC     = FromLOC,
               @cSuggToLOC       = ToLOC,
               @cSuggSKU         = SKU,
               @nQTY_RPL         = QTY,
               @nSystemQTY       = SystemQTY,
               @cPickMethod      = PickMethod,
               @nTransit         = TransitCount,
               @cListKey         = ListKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND TaskDetailKey = @cPendingTaskDetailKey

            --Release new task which is assigned this time 
            SELECT 
               @cTaskDetailKey = V_TaskDetailKey
            FROM RDT.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile
            
            -- Get task info
            SELECT
               @cToLoc        = ToLoc,
               @cFinalLOC     = FinalLoc,
               @cTaskStatus   = Status
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskdetailKey = @cTaskDetailKey
               AND TaskType = 'RPF'
               AND StorerKey = @cStorerKey

            IF @cToLoc <> '' AND @cFinalLOC <> '' AND @cFinalLOC <> @cToLoc
            BEGIN
               SELECT @cToLOCCat = LocationCategory
               FROM dbo.LOC WITH(NOLOCK)
               WHERE Facility = @cFacility
                  AND Loc = @cToLoc
            END

            BEGIN TRAN
            SAVE TRAN rdt_1764ExtScn01

            BEGIN TRY
               --Mark Pending task as PENDING
               UPDATE dbo.TaskDetail WITH (ROWLOCK)
               SET Message01 = 'PENDING' 
               WHERE StorerKey = @cStorerKey
                  AND (ListKey = @cListKey OR TaskDetailKey = @cPendingTaskDetailKey)
                  
               --Rollback ToLoc, FinalLoc, TransitLoc of new assigned tasks
               IF @cToLOCCat IN ('PND', 'PND_IN', 'PND_OUT') AND @cTaskStatus IN ('3','X','H') AND @cFinalLOC <> '' AND @cFinalLOC <> @cToLoc
               BEGIN
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET   ToLoc = @cFinalLOC,
                        ToID = '',
                        Listkey = '',
                        FinalLoc = '',
                        EditDate = GETDATE(),
                        EditWho  = SUSER_SNAME(),
                        TransitLoc = '',
                        TrafficCop = NULL
                  WHERE TaskDetailKey = @cTaskdetailKey
                     AND StorerKey = @cStorerKey
               END

               --Unassign new assigned tasks
               UPDATE dbo.TaskDetail WITH (ROWLOCK)
               SET Status = '0',
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME()
               WHERE TaskDetailKey = @cTaskdetailKey
                  AND StorerKey = @cStorerKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 234851
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPKTaskFail
               GOTO RollBack_rdt_1764ExtScn01
            END CATCH

            COMMIT TRAN rdt_1764ExtScn01 -- Only commit change made here

            SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
            IF ISNULL( @cLocDescr, '') = ''
               SET @cLocDescr = @cSuggFromLOC

            SET @cOutField01 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END

            SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) 
            FROM dbo.LOC WITH (NOLOCK) 
            WHERE Facility = @cFacility 
            AND   (( @cDefaultSuggToLOC <> '' AND LOC = @cDefaultSuggToLOC) OR ( LOC = @cSuggToLOC))
            
            IF ISNULL( @cLocDescr, '') = ''
               SET @cLocDescr = CASE WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC ELSE @cSuggToLOC END

            SET @cOutField02 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr 
                                 WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                 ELSE @cSuggToLOC END

            SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC 
                              WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                              ELSE '' END

            SET @cOutField10 = @cDropID

            SET @nAfterScn = @nScn_ToLOC
            SET @nAfterStep = @nStep_ToLOC

            SET @cUDF01 = @cTTMTaskType
            SET @cUDF02 = @cSuggID
            SET @cUDF03 = @cSuggLOT
            SET @cUDF04 = @cSuggFromLOC
            SET @cUDF05 = @cSuggToLOC
            SET @cUDF06 = @cSuggSKU

            SET @cUDF07 = CAST(@nQTY_RPL AS NVARCHAR(10))
            SET @cUDF08 = CAST(@nSystemQTY AS NVARCHAR(10))
            SET @cUDF09 = @cPickMethod
            SET @cUDF10 = CAST(@nTransit AS NVARCHAR(10))
            SET @cUDF11 = @cDropID
            SET @cUDF12 = @cListKey
            SET @cUDF13 = @cPendingTaskDetailKey
         END
      END
      ELSE IF @nCurrentStep = @nStep_ToLOC -- ToLoc
      BEGIN
         IF @nInputKey = 0 -- ESC
         BEGIN
            IF EXISTS(SELECT 1 FROM 
                     dbo.TaskDetail WITH (NOLOCK) 
                     WHERE StorerKey = @cStorerKey
                        AND ListKey = @cListKey
                        AND Message01 = 'PENDING'
                        AND Status = '5'
                        AND TaskType = 'RPF'
                        AND PickMethod = 'PP')
            BEGIN
               SET @cMessage01 = 'Pending DropID is not closed yet.'
               SET @cMessage02 = 'Back to main menu.'
               
               EXEC rdt.rdtInsertMsgQueue 
                  @nMobile = @nMobile,
                  @nErrNo = @nErrNo,
                  @cErrMsg = @cErrMsg,
                  @cLine01 = @cMessage01,
                  @cLine02 = @cMessage02,
                  @cLine03 = '',
                  @cLine04 = '',
                  @cLine05 = '',
                  @cLine06 = '',
                  @cLine07 = '',
                  @cLine08 = '',
                  @cLine09 = '',
                  @nDisplayMsg = 0

               SET @cMessage01 = ''
               SET @cMessage02 = ''

               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''

               SET @nAfterScn = 2100
               SET @nAfterStep = 1
            END
         END
      END
      ELSE IF @nCurrentStep = @nStep_99 -- New Exit
      BEGIN
         /********************************************************************************
         Step 99. screen = 6527. Message screen
            Pallet is Close
            1   = Next Task
            9   = Exit TM
            LAST LOC (Field01)
            EXTINFO  (Field10)
         ********************************************************************************/
         IF @nCurrentScn = @nScn_NewExit
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               DECLARE @cOption  NVARCHAR(1)

               -- Screen mapping
               SET @cOption = @cInField02

               -- Check blank option
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 234852
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OptionNeeded
                  GOTO Fail
               END
               -- Check option is valid
               IF @cOption NOT IN ('1', '9')
               BEGIN
                  SET @nErrNo = 234853
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidOption
                  GOTO Fail
               END

               IF @cOption = '1'
               BEGIN
                  SET @cUDF01 = '1'
               END
               ELSE 
                  SET @cUDF01 = '0'
            END

            IF @nInputKey = 0 -- ESC
               SET @cUDF01 = '0'
         END
      END

      -- If next step is EXIT, jump to new Exit screen
      IF @nStep = @nStep_Exit 
      BEGIN
         SET @cOutField02 = '' --Option

         SET @nAfterScn = @nScn_NewExit
         SET @nAfterStep = @nStep_99
      END 
   END

   GOTO Quit
RollBack_rdt_1764ExtScn01:
   ROLLBACK TRAN rdt_1764ExtScn01
   GOTO Fail
Fail:
   SET @nAfterScn = @nCurrentScn 
   SET @nAfterStep = @nCurrentStep

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1764ExtScn01 TO NSQL 
GO  
