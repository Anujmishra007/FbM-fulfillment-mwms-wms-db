
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************************/
/* Store procedure: rdt_1764ExtScn01                                                            */
/* Copyright      : Maersk                                                                      */
/* Customer       : Granite Levis                                                               */
/*                                                                                              */
/*                                                                                              */
/* Date       Rev    Author   Purposes                                                          */
/* 2025-03-11 1.0    NLT013   UWP-31321 Create                                                  */
/* 2025-05-21 1.1    NLT013   UWP-34785 Add new Exit Screen                                     */
/* 2025-07-11 1.2.0  NLT013   UWP-37578 Option issue                                            */
/* 2025-10-10 1.3.0  NickT    FCR-7928 Reallocate for short task                                */
/* 2025-10-10 1.3.1  NickT    FCR-7928 Do not clear ListKey                                     */
/* 2025-11-08 1.4.0  NLT013   UWP-43838 Skip InProgress/Completed Task                          */
/* 2025-11-14 1.5.0  NLT013   UWP-43847 Fix issue: PickDetail status is not updated             */ 
/* 2025-01-29 1.6.0  NLT013   UWP-47931 Fix issue: QCmd is not proceed in some scenarios        */
/* 2025-04-10 1.7.0  NLT013   FCR-12136 Support Pick Mode                                       */
/************************************************************************************************/

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
      @nStep_FromLOC          INT         = 2,
      @nScn_FromLOC           INT         = 2681,
      @nStep_SKU              INT         = 4,
      @nScn_SKU               INT         = 2683,
      @nStep_NextTask         INT         = 5,
      @nScn_NextTask          INT         = 2684,
      @nStep_ToLOC            INT         = 6,
      @nScn_ToLOC             INT         = 2685,
      @nStep_Exit             INT         = 7,
      @nScn_Exit              INT         = 2686,
      @nStep_ShortPick        INT         = 8,
      @nScn_ShortPick         INT         = 2687,
      @nStep_99               INT         = 99,
      @nScn_NewExit           INT         = 6527,
      @nStep_Reason           INT         = 9,  

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
      @cOption                NVARCHAR(10),
      @cDefaultSkipReason     NVARCHAR(20),
      @cTaskDetailMessage02   NVARCHAR(20),
      @cCaseID                NVARCHAR(20),
      @cSKU                   NVARCHAR(20),
      @nQTY                   INT,
      @nLoopIndex             INT,
      @cFromLoc               NVARCHAR(10),
      @cFromID                NVARCHAR(18),
      @cWaveKey               NVARCHAR(10),
      @cReasonKey             NVARCHAR(10),
      @nTranCount             INT,
      @cUCCNo                 NVARCHAR(20),
      @cPickDetailKey         NVARCHAR(18),
      @cPickModeFlag          NVARCHAR(1),
      @cAlertMessage          NVARCHAR(255),
      @bSuccess               INT,
      @cSupportPickMode       NVARCHAR(5),

      @cMessage01              NVARCHAR(125),
      @cMessage02              NVARCHAR(125),
      @cMessage03              NVARCHAR(125),
      @cMessage04              NVARCHAR(125),
      @cMessage05              NVARCHAR(125)

   SET @cUDF01  = ''
   SET @cUDF13 = ''

      DECLARE @tPickDetail TABLE
      (
         RowIndex INT IDENTITY(1,1),
         PickDetailKey NVARCHAR(18)
      )

      DECLARE @tTaskDetail TABLE
      (
         RowIndex INT IDENTITY(1,1),
         TaskDetailKey NVARCHAR(10) PRIMARY KEY
      )
 
   SELECT 
      @nCurrentStep        = Step,
      @nCurrentScn         = Scn,
      @cUserName           = UserName,
      @cDropID             = V_String3,
      @cListKey            = V_String7,
      @cUCCNo              = I_Field08,
      @cPickModeFlag       = C_String1
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT @nTranCount = @@TRANCOUNT

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
            @cPendingTaskDetailKey   = TD.TaskDetailKey,
            @cDropID          = TD.DropID,
            @cAreaKey         = TD.AreaKey,
            @cFromLoc         = TD.FromLoc
         FROM dbo.TaskDetail TD WITH(NOLOCK)
         INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON TD.StorerKey = PD.StorerKey AND TD.TaskDetailKey = PD.TaskDetailKey AND PD.Status <> '4'
         WHERE TD.StorerKey = @cStorerKey
            AND TD.Status = '5'
            AND TD.UserKey = @cUserName
            AND TD.DropID <> ''
            AND TD.TaskType = 'RPF'
            AND TD.PickMethod = 'PP'
            AND TD.Message03 NOT IN ('MoveInProgress', 'MoveCompleted')

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

            INSERT INTO @tTaskDetail ( TaskDetailKey )
            SELECT DISTINCT TaskDetailKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND (ListKey = @cListKey OR TaskDetailKey = @cPendingTaskDetailKey)

            BEGIN TRAN
            SAVE TRAN rdt_1764ExtScn01

            BEGIN TRY
               --Mark Pending task as PENDING
               UPDATE TD
               SET Message01 = 'PENDING' 
               FROM dbo.TaskDetail TD WITH (ROWLOCK)
               INNER JOIN @tTaskDetail TTD ON TD.TaskDetailKey = TTD.TaskDetailKey
               WHERE TD.StorerKey = @cStorerKey
                  
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

         ELSE
         BEGIN
            SET @cSupportPickMode = rdt.rdtGetConfig( @nFunc, 'SupportPickMode', @cStorerKey)

            IF @cSupportPickMode = '1'
            BEGIN
                SELECT @cTaskDetailKey = Value FROM @tExtScnData WHERE Variable = '@cTaskDetailKey'

               SELECT TOP 1
                  @cFromLoc         = TD.FromLoc,
                  @cPickMethod      = PickMethod,
                  @cSuggFromLOC     = FromLoc
               FROM dbo.TaskDetail TD WITH(NOLOCK)
               WHERE TD.StorerKey = @cStorerKey
                  AND TaskDetailKey = @cTaskDetailKey
               
               SELECT @cPickModeFlag = IIF(LocationGroup = 'PICKMOD', '1', '0')
               FROM dbo.LOC WITH(NOLOCK)
               WHERE Facility = @cFacility
                  AND Loc = @cFromLoc

               IF @cPickModeFlag = '1'
               BEGIN
                  DECLARE @cNewDropID NVARCHAR( 10)
                  EXECUTE dbo.nspg_GetKey
                     'NewDropID',
                     8 ,
                     @cNewDropID       OUTPUT,
                     @bSuccess         OUTPUT,
                     @nErrNo           OUTPUT,
                     @cErrMsg          OUTPUT

                  IF @bSuccess <> 1
                  BEGIN
                     SET @nErrNo = 234864
                     SET @cErrMsg = rdt.rdtgetmessage( 66029, @cLangCode, 'DSP') --  Generate DropID Failed
                     GOTO Quit
                  END

                  IF @nErrNo <> 0
                     GOTO Quit

                  SET @cUDF11 = 'PM' + @cNewDropID

                  SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) 
                  FROM dbo.LOC WITH (NOLOCK) 
                  WHERE Facility = @cFacility 
                     AND LOC = @cFromLoc

                  IF ISNULL( @cLocDescr, '') = ''
                     SET @cLocDescr = @cSuggFromLOC

                  -- Prepare next screen variable
                  SET @cOutField01 = @cPickMethod
                  SET @cOutField02 = @cNewDropID
                  SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
                  SET @cOutField04 = '' -- FromLOC
                  SET @cOutField10 = '' -- ExtendedInfo

                  SET @nAfterScn = @nScn_FromLOC
                  SET @nAfterStep = @nStep_FromLOC
               END
            END
         END
      END
      ELSE IF @nCurrentStep = @nStep_FromLOC -- FromLoc
      BEGIN
         IF @nInputKey = 0
         BEGIN
            IF @cPickModeFlag = '1'
            BEGIN
               SELECT 
                  @cTaskDetailKey = V_TaskDetailKey
               FROM RDT.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile

               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH(ROWLOCK)
                  SET ReasonKey = 'EXIT',
                     Status = '0',
                     EditDate = GetDate(),
                     EditWho = @cUserName,
                     TrafficCop = NULL
                  WHERE TaskDetailKey = @cTaskDetailKey
                     AND StorerKey = @cStorerKey
                     AND Status = '3'
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 234865
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update Task Failed
               END CATCH

               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutfield04 = ''
               SET @cOutField05 = ''
               SET @cOutField09 = ''

               SET @cUDF13 = 'BackToTaskManagement'
               GOTO Quit
            END
         END
      END
      ELSE IF @nCurrentStep = @nStep_SKU -- SKU/UCC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT 
               @cTaskDetailKey = V_TaskDetailKey
            FROM RDT.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile

            IF @cUCCNo = '99'
            BEGIN
               SET @nAfterStep = @nStep_ShortPick
               SET @nAfterScn = @nScn_ShortPick
               GOTO Quit
            END

            BEGIN TRAN
            SAVE TRAN rdt_1764ExtScn01

            IF @cPickModeFlag = '1' 
               AND EXISTS(SELECT 1 FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cUCCNo)
            BEGIN
               SELECT @nQTY = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nQTY'
               SELECT @nQTY_RPL = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nQTY_RPL'

               IF @nQTY = @nQTY_RPL
               BEGIN
                  EXEC rdt.rdt_TM_Replen_Confirm @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey,
                     @cTaskDetailKey,
                     @cDropID,
                     @nQTY,
                     '',
                     @cListKey,
                     @nErrNo             OUTPUT,
                     @cErrMsg            OUTPUT

                  IF @nErrNo <> 0
                     GOTO RollBack_rdt_1764ExtScn01

                  IF EXISTS (SELECT 1 FROM dbo.TaskDetail WITH(NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey AND Status = '5')
                  BEGIN
                     SET @cToLoc = rdt.rdtGetConfig( @nFunc, 'PickModeDefaultToLoc', @cStorerkey)

                     IF NOT EXISTS(SELECT 1 FROM dbo.LOC WITH(NOLOCK) WHERE Loc = @cToLoc)
                        SET @cToLoc = 'WCS'

                     EXEC rdt.rdt_TM_Replen_ClosePallet @nMobile, @nFunc, @cLangCode,
                        @cUserName,
                        @cListKey,
                        @nErrNo  OUTPUT,
                        @cErrMsg OUTPUT,
                        @cToLOC
                        
                     IF @nErrNo <> 0
                     BEGIN
                        GOTO RollBack_rdt_1764ExtScn01
                     END

                     SET @nAfterStep = 99
                     SET @nAfterScn = @nScn_NewExit
                     SET @cOutField02 = '1'

                     SET @cOutField03 = 'UCC Moved'
                     SET @cOutField04 = ''

                     GOTO COMMIT_1764ExtScn01
                  END
                  ELSE
                  BEGIN
                     SET @nErrNo = 234866
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update Task Failed
                     GOTO RollBack_rdt_1764ExtScn01
                  END
               END
            END
            
            -- If no enough qty for full UCC, mark the task as BADUCC
            IF @cUCCNo <> '' AND 
               NOT EXISTS(
                  SELECT 1 
                  FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
                  INNER JOIN dbo.UCC WITH(NOLOCK)
                     ON LLI.StorerKey = UCC.StorerKey
                        AND LLI.Loc = UCC.Loc
                        AND LLI.ID = UCC.ID
                        AND LLI.LOT = UCC.LOT
                        AND LLI.SKU = UCC.SKU
                  INNER JOIN dbo.TaskDetail TD WITH(NOLOCK)
                     ON TD.StorerKey = UCC.StorerKey
                        AND TD.CaseID = UCC.UCCNo
                        AND TD.SKU = UCC.SKU
                        AND TD.LOT = UCC.LOT
                  WHERE UCC.StorerKey = @cStorerKey
                     AND UCC.UCCNo = @cUCCNo
                     AND LLI.Qty - LLI.QtyPicked >= TD.Qty 
                     AND TD.TaskDetailKey = @cTaskDetailKey
                  )
            BEGIN
               INSERT INTO @tPickDetail (PickDetailKey)
               SELECT PickDetailKey
               FROM dbo.PickDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskDetailKey

               SET @nLoopIndex = -1

               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1 
                     @nLoopIndex = RowIndex,
                     @cPickDetailKey = PickDetailKey
                  FROM @tPickDetail
                  WHERE RowIndex > @nLoopIndex
                  ORDER BY RowIndex

                  IF @@ROWCOUNT = 0
                     BREAK

                  BEGIN TRY
                     UPDATE dbo.PickDetail WITH (ROWLOCK)
                     SET
                        Status =  '4',
                        QtyMoved = Qty,
                        Qty = 0,
                        EditWho  = SUSER_SNAME(), 
                        EditDate = GETDATE(),
                        Trafficcop = NULL
                     WHERE PickDetailKey = @cPickDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 234859
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PKDtl Fail
                     GOTO RollBack_rdt_1764ExtScn01
                  END CATCH

                  BEGIN TRY
                     UPDATE dbo.TaskDetail WITH(ROWLOCK)
                     SET ReasonKey = 'BADUCC',
                        Status = '9',
                        Qty = 0,
                        EditWho  = SUSER_SNAME(), 
                        EditDate = GETDATE(),
                        TrafficCop = NULL
                     WHERE TaskDetailKey = @cTaskDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 234860
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update TaskDetail Failed
                     GOTO RollBack_rdt_1764ExtScn01
                  END CATCH
               END

               SET @nErrNo = 0
               SET @cErrMsg = ''

               EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                  @nErrNo = @nErrNo,
                  @cErrMsg = @cErrMsg,
                  @cLine01 = 'BAD UCC',
                  @cLine02 = 'Will reallocate.',
                  @nDisplayMsg = 0

               SET @nCurrentStep = @nStep_ShortPick
               SET @nCurrentScn = @nScn_ShortPick
               GOTO REALLOCATION
            END

            BEGIN TRY
               UPDATE TaskDetail WITH (ROWLOCK)
               SET 
                  ReasonKey = '',
                  Message01 = '',
                  --Message02 = '',
                  Message03 = '',
                  EditDate = GETDATE(),
                  EditWho  = SUSER_SNAME(),
                  TrafficCop = NULL
               WHERE StorerKey = @cStorerKey
                  AND TaskDetailKey = @cTaskDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 234862
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update TaskDetail Failed
               GOTO RollBack_rdt_1764ExtScn01
            END CATCH

            COMMIT_1764ExtScn01:
            COMMIT TRAN rdt_1764ExtScn01 -- Only commit change made here
         END
      END
      ELSE IF @nCurrentStep = @nStep_ShortPick -- Short Pick
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cOption = @cInField01

            IF @cOption = '1'
            BEGIN
               SELECT 
                  @cTaskDetailKey = V_TaskDetailKey
               FROM RDT.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile

               REALLOCATION:
               SELECT 
                  @cTaskDetailMessage02 = Message02,
                  @cCaseID = CaseID,
                  @cSKU = SKU,
                  @nQTY = QTY,
                  @cFromLoc = FromLOC,
                  @cFromID = FromID,
                  @cWaveKey = WaveKey,
                  @cReasonKey = ReasonKey
               FROM dbo.TaskDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND TaskDetailKey = @cTaskDetailKey

               DECLARE 
                  @cRealloNumberofRetry      NVARCHAR(5),
                  @cMaxRealloNumberofRetry   NVARCHAR(5)

               SET @cRealloNumberofRetry = rdt.RDTGetConfig( @nFunc, 'RealloNumberofRetry', @cStorerKey)
               IF @cRealloNumberofRetry = '0'
                  SET @cRealloNumberofRetry = '99'
               
               SET @cMaxRealloNumberofRetry = 'SKIP' + @cRealloNumberofRetry

               IF @cTaskDetailMessage02 = @cMaxRealloNumberofRetry
                  GOTO Quit

               SET @cDefaultSkipReason = rdt.rdtGetConfig( @nFunc, 'DefaultSkipReason', @cStorerKey)

               SET @cDefaultSkipReason = IIF (@cReasonKey = 'BADUCC', @cReasonKey, @cDefaultSkipReason)

               BEGIN TRAN
               SAVE TRAN rdt_1764ExtScn01

               -- Update TaskDetail status to 9 - Short Picked
               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET 
                     ReasonKey = IIF( ReasonKey = 'BADUCC', ReasonKey, @cDefaultSkipReason),
                     Status = '9',
                     Qty = 0,
                     EditDate = GETDATE(),
                     EditWho  = SUSER_SNAME(),
                     TrafficCop = NULL
                  WHERE StorerKey = @cStorerKey
                     AND TaskDetailKey = @cTaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 234861
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update Task Failed
                  GOTO RollBack_rdt_1764ExtScn01
               END CATCH

               BEGIN TRY
                  INSERT INTO @tPickDetail (PickDetailKey)
                  SELECT PickDetailKey
                  FROM dbo.PickDetail WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND TaskDetailKey = @cTaskDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 234855
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Insert Into @tPickDetail Failed
                  GOTO RollBack_rdt_1764ExtScn01
               END CATCH

               -- Update PickDetail QtyMoved, Status and Qty
               BEGIN TRY
                  UPDATE PD
                  SET PD.QtyMoved = Qty,
                     PD.Status = '4',
                     PD.Qty = 0,
                     PD.EditDate = GETDATE(),
                     PD.EditWho = SUSER_SNAME()
                  FROM dbo.PickDetail PD WITH (ROWLOCK)
                  INNER JOIN @tPickDetail TPD ON PD.PickDetailKey = TPD.PickDetailKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 234856
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update PickDetail Failed
                  GOTO RollBack_rdt_1764ExtScn01
               END CATCH

               DECLARE 
                  @cAlertMessage       NVARCHAR(255),
                  @bSuccess            INT

               SELECT @cUCCNo = UCCNo
               FROM dbo.TaskDetail TD WITH(NOLOCK)
               INNER JOIN dbo.UCC WITH(NOLOCK) ON TD.StorerKey = UCC.StorerKey AND TD.CaseID = UCC.UCCNo
               WHERE TD.StorerKey = @cStorerKey
                  AND TD.TaskDetailKey = @cTaskDetailKey

               IF ISNULL(@cUCCNo, '') <> ''
               BEGIN
                  -- Hold the UCC
                  BEGIN TRY
                     EXEC nspInventoryHoldWrapper
                        @c_lot = ''
                        ,@c_Loc = ''
                        ,@c_ID = ''
                        ,@c_StorerKey = @cStorerKey
                        ,@c_SKU = ''
                        ,@c_Lottable01 = ''
                        ,@c_Lottable02 = ''
                        ,@c_Lottable03 = ''
                        ,@dt_Lottable04 = NULL
                        ,@dt_Lottable05 = NULL
                        ,@c_Lottable06 = ''
                        ,@c_Lottable07 = ''
                        ,@c_Lottable08 = ''
                        ,@c_Lottable09 = ''
                        ,@c_Lottable10 = ''
                        ,@c_Lottable11 = ''
                        ,@c_Lottable12 = ''
                        ,@dt_Lottable13  = NULL
                        ,@dt_Lottable14  = NULL
                        ,@dt_Lottable15  = NULL
                        ,@c_Status = 'HOLD'
                        ,@c_Hold = 1
                        ,@b_success = @bSuccess OUTPUT
                        ,@n_Err = @nErrNo OUTPUT
                        ,@c_Errmsg = @cErrMsg OUTPUT
                        ,@c_Remark = ''
                        ,@c_UCCNo = @cUCCNo

                     IF @nErrNo <> 0
                        GOTO RollBack_rdt_1764ExtScn01

                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 234863
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Hold UCC Failed
                     GOTO RollBack_rdt_1764ExtScn01
                  END CATCH
               END

               SET @cAlertMessage = 'Short Picked by ' + ISNULL(@cUserName, '')
                                    + ' TaskDetailKey: ' + ISNULL(@cTaskDetailKey, '')
                                    + ' TaskType: RPF'
                                    + ' CaseID: ' + ISNULL(@cCaseID, '')
                                    + ' Reason: ' + ISNULL(@cDefaultSkipReason, '')
               
               -- Log Alert
               BEGIN TRY
                  EXEC nspLogAlert
                     @c_modulename           = 'TMCC'
                     , @c_AlertMessage       = @cAlertMessage
                     , @n_Severity           = '5'
                     , @b_success            = @bSuccess       OUTPUT
                     , @n_err                = @nErrNo         OUTPUT
                     , @c_errmsg             = @cErrMsg        OUTPUT
                     , @c_Activity	         = 'FN1764'
                     , @c_Storerkey	         = @cStorerKey
                     , @c_SKU	               = @cSKU
                     , @c_UOM	               = ''
                     , @c_UOMQty	            = ''
                     , @c_Qty	               = @nQty
                     , @c_Lot	               = ''
                     , @c_Loc	               = @cFromLoc
                     , @c_ID	               = @cFromID
                     , @c_TaskDetailKey	   = @cTaskDetailKey
                     , @c_UCCNo	            = ''
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 234857
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Log Alert Failed
                  GOTO RollBack_rdt_1764ExtScn01
               END CATCH

               IF @nErrNo <> 0
                  GOTO RollBack_rdt_1764ExtScn01

               DECLARE 
                  @cAPP_DB_Name              NVARCHAR(20),
                  @cDataStream               VARCHAR(10),
                  @nThreadPerAcct            INT,
                  @nThreadPerStream          INT,
                  @nMilisecondDelay          INT,
                  @cIP                       NVARCHAR(20),
                  @cPORT                     NVARCHAR(5),
                  @cIniFilePath              NVARCHAR(200),
                  @cCmdType                  NVARCHAR(10),
                  @cTaskType                 NVARCHAR(1),
                  @c_TransmitlogKey          NVARCHAR(10),
                  @cExecStatements           NVARCHAR(MAX),
                  @cExecArguments            NVARCHAR(MAX)

               SELECT 
                  @cAPP_DB_Name         = APP_DB_Name,
                  @cDataStream          = DataStream,
                  @nThreadPerAcct       = ThreadPerAcct,
                  @nThreadPerStream     = ThreadPerStream,
                  @nMilisecondDelay     = MilisecondDelay,
                  @cIP                  = IP,
                  @cPORT                = PORT,
                  @cIniFilePath         = IniFilePath,
                  @cCmdType             = CmdType,
                  @cTaskType            = TaskType,
                  @cExecStatements      = StoredProcName
               FROM dbo.QCmd_TransmitlogConfig WITH (NOLOCK)
               WHERE TableName = 'ShortPickHoldUCC'
                  AND App_Name = 'WMS'
                  AND  StorerKey =  @cStorerKey

               SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                                    + ' @c_Wavekey = ''' + @cWaveKey + ''''
                                    + ', @c_SKU = ''' + @cSKU + ''''
                                    + ', @c_UCCNo = ''' + @cCaseID + ''''
                                    + ', @c_TaskDetailKey = ''' + @cTaskDetailKey + ''''

               -- Submit task to QCommander
               BEGIN TRY
                  EXEC isp_QCmd_SubmitTaskToQCommander
                       @cTaskType           = 'O'                  -- -- D=By Datastream, T=Transmitlog, O=Others
                     , @cStorerKey          = @cStorerKey
                     , @cDataStream         = @cDataStream
                     , @cCmdType            = @cCmdType 
                     , @cCommand            = @cExecStatements
                     , @cTransmitlogKey     = @cTaskDetailKey 
                     , @nThreadPerAcct      = @nThreadPerAcct 
                     , @nThreadPerStream    = @nThreadPerStream 
                     , @nMilisecondDelay    = @nMilisecondDelay  
	                  , @nSeq                = 1
                     , @cIP                 = @cIP
                     , @cPORT               = @cPORT
                     , @cIniFilePath        = @cIniFilePath
                     , @cAPPDBName          = @cAPP_DB_Name
                     , @bSuccess            = @bSuccess     OUTPUT 
                     , @nErr                = @nErrNo       OUTPUT 
                     , @cErrMsg             = @cErrMsg      OUTPUT
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 234857
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Submit QCommanderTask Failed
                  GOTO RollBack_rdt_1764ExtScn01
               END CATCH

               IF @nErrNo <> 0
                  GOTO RollBack_rdt_1764ExtScn01

               COMMIT TRAN rdt_1764ExtScn01 -- Only commit change made here

               SET @nAfterScn = @nScn_NextTask
               SET @nAfterStep = @nStep_NextTask
               SET @cUDF01 = @cDefaultSkipReason
            END
         END
      END
      ELSE IF @nCurrentStep = @nStep_Reason -- ReasonCOde
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Reset QTY to 0 if SKIP/SHORT Task
            SET @cUDF01 = '0'
         END
      END
      ELSE IF @nCurrentStep = @nStep_ToLOC -- ToLoc
      BEGIN
         IF @nInputKey = 0 -- ESC
         BEGIN
            -- Press ESC on Timeout Screen, go to Pallet Close Screen
            IF EXISTS(SELECT 1 
                     FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND ListKey = @cListKey
                        AND Message03 IN ('MoveInProgress', 'MoveCompleted')
                        AND Status IN ( '5', '9' )
                        AND TaskType = 'RPF')
            BEGIN
               SET @cOutField02 = '' --Option

               SET @nAfterScn = @nScn_NewExit
               SET @nAfterStep = @nStep_99

               SET @cOutField03 = 'Pallet is closed and'
               SET @cOutField04 = 'moved'
               GOTO Quit
            END

            IF EXISTS(SELECT 1 FROM 
                     dbo.TaskDetail WITH (NOLOCK) 
                     WHERE StorerKey = @cStorerKey
                        AND ListKey = @cListKey
                        AND Message01 = 'PENDING'
                        AND Status = '5'
                        AND TaskType = 'RPF'
                        AND PickMethod = 'PP')
            BEGIN
               SET @nErrNo = 234854
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID is not closed yet
               GOTO Quit

               -- SET @cMessage01 = 'Pending DropID is not closed yet.'
               -- SET @cMessage02 = 'Back to main menu.'
               
               -- EXEC rdt.rdtInsertMsgQueue 
               --    @nMobile = @nMobile,
               --    @nErrNo = @nErrNo,
               --    @cErrMsg = @cErrMsg,
               --    @cLine01 = @cMessage01,
               --    @cLine02 = @cMessage02,
               --    @cLine03 = '',
               --    @cLine04 = '',
               --    @cLine05 = '',
               --    @cLine06 = '',
               --    @cLine07 = '',
               --    @cLine08 = '',
               --    @cLine09 = '',
               --    @nDisplayMsg = 0

               -- SET @cMessage01 = ''
               -- SET @cMessage02 = ''

               -- SET @cOutField01 = ''
               -- SET @cOutField02 = ''
               -- SET @cOutField03 = ''

               -- SET @nAfterScn = 2100
               -- SET @nAfterStep = 1
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
               DECLARE 
                  @nOption  INT

               -- Check blank option
               IF @cInField02 = ''
               BEGIN
                  SET @nErrNo = 234852
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OptionNeeded
                  GOTO Fail
               END

               -- Screen mapping
               SET @nOption = ISNULL(TRY_CAST(@cInField02 AS INT), 0)

               -- Check option is valid
               IF @nOption NOT IN (1, 9)
               BEGIN
                  SET @nErrNo = 234853
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidOption
                  GOTO Fail
               END

               IF @nOption = 1
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

         IF @cPickModeFlag = '1'
         BEGIN
            SET @cOutField03 = 'UCC Moved'
            SET @cOutField04 = ''
         END
         ELSE
         BEGIN
            SET @cOutField03 = 'Pallet is closed and'
            SET @cOutField04 = 'moved'
         END
      END 
   END

   GOTO Quit
RollBack_rdt_1764ExtScn01:
   IF @nTranCount = 0
   BEGIN
      ROLLBACK TRANSACTION
   END
   ELSE
   BEGIN
      IF XACT_STATE() <> -1
      BEGIN
         ROLLBACK TRANSACTION rdt_1764ExtScn01
      END
   END

   IF @cPickModeFlag = '1' AND @nCurrentStep = @nStep_SKU
   BEGIN
      DECLARE @nRowRef INT

      SELECT TOP 1 @nRowRef = RowRef FROM rdt.rdtRPFLog WITH (NOLOCK) 
      WHERE TaskDetailKey = @cTaskDetailKey 
         AND UCCNo = @cUCCNo
      
      IF @@ROWCOUNT > 0
         DELETE FROM rdt.rdtRPFLog WITH(ROWLOCK) WHERE RowRef = @nRowRef
   END
   GOTO Fail
Fail:
   SET @nAfterScn = @nCurrentScn 
   SET @nAfterStep = @nCurrentStep

Quit:
   UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
   SET C_String1 = @cPickModeFlag
   WHERE Mobile = @nMobile

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1764ExtScn01 TO NSQL 
GO  
