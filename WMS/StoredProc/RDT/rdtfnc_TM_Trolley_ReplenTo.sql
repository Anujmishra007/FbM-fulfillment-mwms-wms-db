SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*******************************************************************************/    
/* Store procedure: rdtfnc_TM_Trolley_ReplenTo                                 */
/* Copyright      : Maersk                                                     */
/*                                                                             */    
/* Purpose: RDT Task Manager - Move                                            */    
/*          Called By rdtfnc_TaskManager                                       */    
/*                                                                             */    
/* Modifications log:                                                          */    
/*                                                                             */    
/* Date        Rev   Author   Purposes                                         */    
/* 2025-01-01  1.0   Cuize    FCR-9735 Created                                 */
/*******************************************************************************/    
CREATE OR ALTER PROC [RDT].[rdtfnc_TM_Trolley_ReplenTo](
   @nMobile    INT,    
   @nErrNo     INT  OUTPUT,    
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 NVARCHAR max    
) AS    
    
SET NOCOUNT ON    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS OFF    
SET CONCAT_NULL_YIELDS_NULL OFF    
    
-- Misc variable    
DECLARE    
   @b_success           INT    
    
-- Define a variable    
DECLARE    
   @nFunc               INT,    
   @nScn                INT,    
   @nStep               INT,    
   @cLangCode           NVARCHAR(3),    
   @nMenu               INT,    
   @nInputKey           NVARCHAR(3),    
   @cPrinter            NVARCHAR(10),    
   @cUserName           NVARCHAR(18),
   @cAddWho             NVARCHAR(18),

   @cStorerKey          NVARCHAR(15),    
   @cFacility           NVARCHAR(5),    

   @cToLocation         NVARCHAR(10),
   @cTaskFromLOC        NVARCHAR(10),
   @cTaskToLOC          NVARCHAR(10),
   @cTaskdetailkey      NVARCHAR(10),
   @cTTMTaskType        NVARCHAR(10),
   @cID                 NVARCHAR(18),    

   @cReasonCode         NVARCHAR(10),    
   @cSuggestedUCCno     NVARCHAR( 20),
   @cInputUCCno         NVARCHAR( 20),
   @cPosition           NVARCHAR( 20),

   @cTrolleyNo          NVARCHAR( 10),
   @nStepTrolleyID      INT,
   @nScnTrolleyID       INT,
   @nStepCartonID       INT,
   @nScnCartonID        INT,
   @nStepReasonCode     INT,
   @nScnReasonCode      INT,
   @nStepToLoc          INT,
   @nScnToLoc           INT,
   @nStepQCLoc          INT,
   @nScnQCLoc           INT,
   @nStepMessage        INT,
   @nScnMessage         INT,
   @c_outstring         NVARCHAR(255),
   @n_err               INT,
   @n_cnt               INT,
   @nRowCount           INT,



   @cSQL                NVARCHAR(1000),    
   @cSQLParam           NVARCHAR(1000),    
   @cExtendedValidateSP NVARCHAR(30),    
   @cExtendedUpdateSP   NVARCHAR(30),    


   @cExtendedInfoSP     NVARCHAR(20),    

   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),    
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),    
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),    
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),    
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),    
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),    
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),    
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),    
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),    
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),    
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),    
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),    
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),    
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),    
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),    
    
   @cFieldAttr01 NVARCHAR( 1), @cFieldAttr02 NVARCHAR( 1),    
   @cFieldAttr03 NVARCHAR( 1), @cFieldAttr04 NVARCHAR( 1),    
   @cFieldAttr05 NVARCHAR( 1), @cFieldAttr06 NVARCHAR( 1),    
   @cFieldAttr07 NVARCHAR( 1), @cFieldAttr08 NVARCHAR( 1),    
   @cFieldAttr09 NVARCHAR( 1), @cFieldAttr10 NVARCHAR( 1),    
   @cFieldAttr11 NVARCHAR( 1), @cFieldAttr12 NVARCHAR( 1),    
   @cFieldAttr13 NVARCHAR( 1), @cFieldAttr14 NVARCHAR( 1),    
   @cFieldAttr15 NVARCHAR( 1)    
    
-- Getting Mobile information    
SELECT    
   @nFunc            = Func,    
   @nScn             = Scn,    
   @nStep            = Step,    
   @nInputKey        = InputKey,    
   @cLangCode        = Lang_code,    
   @nMenu            = Menu,    
    
   @cFacility        = Facility,    
   @cStorerKey       = StorerKey,    
   @cPrinter         = Printer,
   @cUserName        = UserName,
    
   @cID              = V_ID,
   @cTaskdetailkey   = V_TaskDetailKey,
   @cSuggestedUCCno  = V_UCC,

   @cTrolleyNo       = V_String1,
   @cReasonCode      = V_String2,
   @cPosition        = V_String3,
   @cTTMTaskType      = V_String4,
   @cTaskFromLOC      = V_String5,
   @cTaskToLOC      = V_String6,



   @cExtendedInfoSP   = V_String21,
   @cExtendedValidateSP = V_String22,
   @cExtendedUpdateSP   = V_String23,
    

    

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,    
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,    
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,    
   @cInField04 = I_Field04,   @cOutField04 = O_Field04,    
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,    
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,    
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,    
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,    
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,    
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,    
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,    
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,    
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,    
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,    
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,    
    
   @cFieldAttr01  = FieldAttr01,    @cFieldAttr02   = FieldAttr02,    
   @cFieldAttr03 =  FieldAttr03,    @cFieldAttr04   = FieldAttr04,    
   @cFieldAttr05 =  FieldAttr05,    @cFieldAttr06   = FieldAttr06,    
   @cFieldAttr07 =  FieldAttr07,    @cFieldAttr08   = FieldAttr08,    
   @cFieldAttr09 =  FieldAttr09,    @cFieldAttr10   = FieldAttr10,    
   @cFieldAttr11 =  FieldAttr11,    @cFieldAttr12   = FieldAttr12,    
   @cFieldAttr13 =  FieldAttr13,    @cFieldAttr14   = FieldAttr14,    
   @cFieldAttr15 =  FieldAttr15    
    
FROM   RDTMOBREC (NOLOCK)    
WHERE  Mobile = @nMobile    
    
-- Redirect to respective screen    
IF @nFunc = 1876
BEGIN

   --step trolley ID
   SET @nStepTrolleyID     = 1
   SET @nScnTrolleyID      = 6780
   --step carton ID
   SET @nStepCartonID      = 2
   SET @nScnCartonID       = 6781
   --step reason code
   SET @nStepReasonCode    = 3
   SET @nScnReasonCode     = 6782
   --step to loc
   SET @nStepToLoc         = 4
   SET @nScnToLoc          = 6783
   --step QC loc
   SET @nStepQCLoc         = 5
   SET @nScnQCLoc          = 6784
   -- step message
   SET @nStepMessage       = 6
   SET @nScnMessage        = 6785
    
    
   IF @nStep = 0 GOTO Step_0   -- Initialize Func = 1876
   IF @nStep = 1 GOTO Step_1   -- Scn = 6780
   IF @nStep = 2 GOTO Step_2   -- Scn = 6781
   IF @nStep = 3 GOTO Step_3   -- Scn = 6782 -- REASON CODE
   IF @nStep = 4 GOTO Step_4   -- Scn = 6783 -- To Location
   IF @nStep = 5 GOTO Step_5   -- Scn = 6784 -- qc Location
   IF @nStep = 6 GOTO Step_6   -- Scn = 6785 -- Success msg
    
    
END    
    
RETURN -- Do nothing if incorrect step    
    
/********************************************************************************    
Step 0. Initialize (func = 1876)
    Screen = 6780
    GET EMPTY PALLET SCREEN    
********************************************************************************/    
Step_0:    
BEGIN

   --TASK Type ASTTPA

--       SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
--       IF @cExtendedValidateSP = '0'
--          SET @cExtendedValidateSP = ''
--       SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
--       IF @cExtendedInfoSP = '0'
--          SET @cExtendedInfoSP = ''
--       SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
--       IF @cExtendedUpdateSP = '0'
--          SET @cExtendedUpdateSP = ''

      -- prepare next screen    
      SET @cOutField01 = ''
    
      -- Go to next screen    
      SET @nScn = 6780
      SET @nStep = 1    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 1. Trolley ID
    Screen = 6780
    Trolley ID (Field01, input)
********************************************************************************/    
Step_1:    
BEGIN
    
   IF @nInputKey = 1 -- ENTER    
   BEGIN

      -- Screen mapping
      SET @cTrolleyNo = @cInField01 --TrolleyNo

      -- Check blank
      IF @cTrolleyNo = ''
      BEGIN
         SET @nErrNo = 256651
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Need TrolleyNo
         GOTO Step_1_Fail
      END

      -- Check trolley valid
      IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'CART' AND DeviceID = @cTrolleyNo)
      BEGIN
         SET @nErrNo = 256652
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- InvalidTrolley
         GOTO Step_1_Fail
      END

      -- trolley empty/loading
      IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'CART' AND DeviceID = @cTrolleyNo AND Status in ('0','3'))
      BEGIN
         SET @nErrNo = 256653
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Trolley not loaded for replenishment
         GOTO Step_1_Fail
      END

      -- trolley not closed
      IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'CART' AND DeviceID = @cTrolleyNo AND Status <> '9')
      BEGIN
         SET @nErrNo = 256654
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- trolley not closed
         GOTO Step_1_Fail
      END

      --LOCK tasks by user
      UPDATE TASK
      SET TASK.UserKey = SUSER_SNAME()
      FROM TASKDETAIL AS TASK
      JOIN rdt.rdtTrolleyLog AS T WITH (NOLOCK)
         ON T.TaskDetailKey = TASK.TaskDetailKey
      JOIN LOC WITH (NOLOCK)
         ON TASK.ToLOC = LOC.LOC
      WHERE T.TrolleyNo = @cTrolleyNo
        AND TASK.UserKey = ''
        AND TASK.[Status] <> 'H';

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 256670
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') --Lock Task Failed
         GOTO Step_1_Fail
      END

      -- Get task
      SELECT TOP 1
         @cTaskFromLOC =       TASK.FromLoc,
         @cTaskToLOC =           TASK.ToLOC,
         @cTTMTaskType =        TASK.TaskType,
         @cPosition =           T.[Position],
         @cSuggestedUCCno =     T.UCCNo,
         @cTaskdetailkey =      T.TaskDetailKey,
         @cAddWho =             T.AddWho
      FROM TASKDETAIL TASK WITH (NOLOCK)
      JOIN rdt.rdtTrolleyLog T WITH (NOLOCK) ON (T.TaskDetailKey = TASK.TaskDetailKey)
      JOIN LOC WITH (NOLOCK) ON (TASK.ToLOC = LOC.LOC)
      WHERE T.TrolleyNo = @cTrolleyNo
        AND TASK.[Status] <> 'H'
      ORDER BY LOC.PALogicalLoc, LOC.LOC


      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 256669
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No More Task
         GOTO Step_1_Fail
      END

      -- Check task uer
      IF @cAddWho <> @cUserName
      BEGIN
         SET @nErrNo = 256655
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Trolley in use
         GOTO Step_1_Fail
      END


      SET @cOutField01 = @cTrolleyNo --TrolleyNo
      SET @cOutField02 = @cTaskToLOC
      SET @cOutField03 = @cPosition
      SET @cOutField04 = @cSuggestedUCCno

      -- Go to next screen    
      SET @nScn = @nScnCartonID
      SET @nStep = @nStepCartonID
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN

      -- EventLog
      EXEC RDT.rdt_STD_EventLog
           @cActionType = '9', -- Sign-out
           @cUserID     = @cUserName,
           @nMobileNo   = @nMobile,
           @nFunctionID = @nFunc,
           @cFacility   = @cFacility,
           @cStorerKey  = @cStorerkey,
           @nStep       = @nStep

      -- Back to main menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
      SET @cOutField02 = ''
    
   END    
   GOTO Quit

   Step_1_Fail:
   SET @cTrolleyNo = ''
   SET @cOutField01 = '' --TrolleyNo

END
GOTO Quit
    
/********************************************************************************    
Step 2. screen = 6781 Carton ID
   TROLLEY     (Field01)
   Loc         (Field02)
   Position    (Field03)
   Carton      (Field04)
   Carton      (Field05, input)
********************************************************************************/
Step_2:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
    
      -- Screen mapping    
      SET @cInputUCCno = @cInField05

      -- Check blank
      IF @cInputUCCno = ''
      BEGIN
         SET @nErrNo = 256656
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Need UCCNo
         GOTO Step_2_Fail
      END
    
      -- Decode    
      IF @cInputUCCno <> @cSuggestedUCCno
      BEGIN
         SET @nErrNo = 256671
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Wrong UCC
         GOTO Step_2_Fail
      END

      SET @cOutField01 = @cTrolleyNo --TrolleyNo
      SET @cOutField02 = @cTaskToLOC
      SET @cOutField03 = @cPosition
      SET @cOutField04 = @cSuggestedUCCno
      --SET @cOutField05 = ''    
    
      -- Go to ToLoc screen    
      SET @nScn = @nScnToLoc
      SET @nStep = @nStepToLoc    
    
    
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
      SET @cOutField01 = ''
    
      -- go to previous screen    
      SET @nScn = @nScnReasonCode
      SET @nStep = @nStepReasonCode
   END    
   GOTO Quit    
    
   Step_2_Fail:    
   BEGIN
      SET @cInField05 = ''
   END    
END    
GOTO Quit


/********************************************************************************    
Step 3. screen = 6782. Reason code screen
REASON CODE (Field01, input)
********************************************************************************/
Step_3:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN

      SET @cReasonCode = @cInField01

      IF @cReasonCode = ''
      BEGIN
         SET @nErrNo = 256657
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reason Req
         GOTO Step_3_Fail
      END

      IF NOT EXISTS( SELECT TOP 1 1
         FROM CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'RDTTASKRSN'
           AND StorerKey = @cStorerKey
           AND Code = @cTTMTaskType
           AND @cReasonCode IN (UDF01, UDF02, UDF03, UDF04, UDF05))
      BEGIN
         SET @nErrNo = 256659
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Reason
         GOTO Step_3_Fail
      END


      -- Update ReasonCode
      EXEC dbo.nspRFRSN01
           @c_sendDelimiter = NULL
         ,  @c_ptcid         = 'RDT'
         ,  @c_userid        = @cUserName
         ,  @c_taskId        = 'RDT'
         ,  @c_databasename  = NULL
         ,  @c_appflag       = NULL
         ,  @c_recordType    = NULL
         ,  @c_server        = NULL
         ,  @c_ttm           = NULL
         ,  @c_taskdetailkey = @cTaskdetailkey
         ,  @c_fromloc       = @cTaskFromLOC
         ,  @c_fromid        = @cID
         ,  @c_toloc         = ''
         ,  @c_toid          = ''
         ,  @n_qty           = 0
         ,  @c_PackKey       = ''
         ,  @c_uom           = ''
         ,  @c_reasoncode    = @cReasonCode
         ,  @c_outstring     = @c_outstring    OUTPUT
         ,  @b_Success       = @b_Success      OUTPUT
         ,  @n_err           = @nErrNo         OUTPUT
         ,  @c_errmsg        = @cErrMsg        OUTPUT
         ,  @c_userposition  = '1' -- 1=at from LOC

      IF ISNULL(@cErrMsg, '') <> ''
      BEGIN
         SET @cErrMsg = @cErrMsg
         GOTO Step_3_Fail
      END

      UPDATE TASKDETAIL SET Message01 = @cTrolleyNo + @cPosition,
                            Message02 = @cUserName,
                            REASONKEY = @cReasonCode,
                            EditDate = GETDATE(),
                            EditWho = SUSER_SNAME(),
                            Status = 'H',
                            TrafficCop = NULL
      WHERE TaskDetailKey = @cTaskdetailkey
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 256660
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
         GOTO Step_3_Fail
      END

      -- Get task
      SELECT TOP 1
         @cTaskFromLOC =       TASK.FromLoc,
         @cTaskToLOC =           TASK.ToLOC,
         @cTTMTaskType =        TASK.TaskType,
         @cPosition =           T.[Position],
         @cSuggestedUCCno =     T.UCCNo,
         @cTaskdetailkey =      T.TaskDetailKey,
         @cAddWho =             T.AddWho
      FROM TASKDETAIL TASK WITH (NOLOCK)
              JOIN rdt.rdtTrolleyLog T WITH (NOLOCK) ON (T.TaskDetailKey = TASK.TaskDetailKey)
              JOIN LOC WITH (NOLOCK) ON (TASK.ToLOC = LOC.LOC)
      WHERE T.TrolleyNo = @cTrolleyNo  AND T.TaskDetailKey <> @cTaskdetailkey
        AND TASK.status <> 'H'
      ORDER BY LOC.PALogicalLoc, LOC.LOC
      SET @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0  -- No Task, Go to QC location now
      BEGIN
         SET @nScn  = @nScnQCLoc
         SET @nStep = @nStepQCLoc

         SET @cOutField01 = ''
      END
      ELSE
      BEGIN

         SET @cOutField01 = @cTrolleyNo --TrolleyNo
         SET @cOutField02 = @cTaskToLOC
         SET @cOutField03 = @cPosition
         SET @cOutField04 = @cSuggestedUCCno

         -- Go to next screen
         SET @nScn = @nScnCartonID
         SET @nStep = @nStepCartonID

      END


   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN

      SET @cOutField01 = @cTrolleyNo --TrolleyNo
      SET @cOutField02 = @cTaskToLOC
      SET @cOutField03 = @cPosition
      SET @cOutField04 = @cSuggestedUCCno

      -- Go to next screen
      SET @nScn = @nScnCartonID
      SET @nStep = @nStepCartonID
    
    
   END    
   GOTO Quit    
    
   Step_3_Fail:    
   BEGIN
      SET @cOutField01 = ''
   END
END    
GOTO Quit    
    
/********************************************************************************    
Step 4. screen = 6783. To Location screen
   TROLLEY        (Field01)
   Loc            (Field02)
   Position       (Field03)
   Carton         (Field04)
   Location:      (Field05, input)
********************************************************************************/    
Step_4:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      SET @cToLocation = @cInField05

      IF @cToLocation <> @cTaskToLOC
      BEGIN
         SET @nErrNo = 256658
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Wrong Location
         GOTO Step_4_Fail
      END

      EXEC rdt.rdt_TM_Trolley_ReplenTo_Confirm @nMobile, @nFunc, @cLangCode, @cFacility, @cStorerKey, @cUserName
         ,@cTrolleyNo
         ,@cSuggestedUCCno
         ,@cToLocation
         ,@nErrNo     OUTPUT
         ,@cErrMsg    OUTPUT
      IF @nErrNo <> 0
         GOTO Step_4_Fail


      IF EXISTS(
         SELECT 1 FROM rdt.rdtTrolleyLog T WITH (NOLOCK)
            JOIN Taskdetail TASK WITH(NOLOCK) ON (T.TaskDetailKey = TASK.TaskDetailKey)
            WHERE TrolleyNo = @cTrolleyNo
               AND T.TaskDetailKey <> @cTaskdetailkey -- NEXT TASK
               AND TASK.[Status] <> 'H' -- NOT HOLD
      )
      BEGIN  --back to carton ID screen

         -- Get task
         SELECT TOP 1
            @cTaskFromLOC =       TASK.FromLoc,
            @cTaskToLOC =           TASK.ToLOC,
            @cTTMTaskType =        TASK.TaskType,
            @cPosition =           T.[Position],
            @cSuggestedUCCno =     T.UCCNo,
            @cTaskdetailkey =      T.TaskDetailKey,
            @cAddWho =             T.AddWho
         FROM TASKDETAIL TASK WITH (NOLOCK)
                 JOIN rdt.rdtTrolleyLog T WITH (NOLOCK) ON (T.TaskDetailKey = TASK.TaskDetailKey)
                 JOIN LOC WITH (NOLOCK) ON (TASK.ToLOC = LOC.LOC)
         WHERE T.TrolleyNo = @cTrolleyNo
           AND TASK.status <> 'H'
         ORDER BY LOC.PALogicalLoc, LOC.LOC


         SET @cOutField01 = @cTrolleyNo --TrolleyNo
         SET @cOutField02 = @cTaskToLOC
         SET @cOutField03 = @cPosition
         SET @cOutField04 = @cSuggestedUCCno

         SET @nScn = @nScnCartonID
         SET @nStep = @nStepCartonID

      END
      ELSE IF EXISTS(
         SELECT 1 FROM rdt.rdtTrolleyLog T WITH (NOLOCK)
                          JOIN Taskdetail TASK WITH(NOLOCK)
                               ON (T.TaskDetailKey = TASK.TaskDetailKey)
         WHERE T.TrolleyNo = @cTrolleyNo
           AND TASK.[Status] = 'H'
      )
      BEGIN
         SET @cOutField01 = ''
         SET @nScn = @nScnQCLoc
         SET @nStep = @nStepQCLoc
      END
      ELSE
      BEGIN

         UPDATE dbo.DeviceProfile
            SET Status = 0, -- empty
            EditDate = GETDATE(),
            EditWho = SUSER_SNAME()
         WHERE DeviceType = 'CART'
           AND DeviceID = @cTrolleyNo

-- Repeated logic in rdt_TM_Trolley_ReplenTo_Confirm

--          UPDATE TD SET
--             TD.Status = '0'
--          FROM TASKDETAIL TD
--          WHERE TD.TaskType IN ('CPK', 'ASTCPK')
--            AND TD.Status = 'H'
--          AND EXISTS (SELECT 1 FROM TASKDETAIL TD1 (NOLOCK) WHERE TD1.WaveKey = TD.WaveKey AND TaskDetailKey = @cTaskDetailKey)

         SET @nScn = @nScnMessage
         SET @nStep = @nStepMessage
      END

   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    

      SET @cOutField01 = ''
    
      -- Go to Reason Code Screen    
      SET @nScn  = @nScnReasonCode
      SET @nStep = @nStepReasonCode -- Step 6
    
   END    
   GOTO Quit    
    
   Step_4_Fail:    
END    
GOTO Quit

/********************************************************************************
Step 5. screen = 2784
   Move skipped cartons to QC location
   Location:      (Field01, input)
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1-- ENTER
   BEGIN
      SET @cToLocation = @cInField01

      IF NOT EXISTS( SELECT 1 FROM LOC WITH (NOLOCK) WHERE LOC = @cToLocation)
      BEGIN
         SET @nErrNo = 256662
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LOC
         GOTO Step_5_Fail
      END

      IF NOT EXISTS(
         SELECT 1 FROM LOC WITH(NOLOCK ) WHERE LOC = @cToLocation AND LocationType = 'QC'
      )
      BEGIN
         SET @nErrNo = 256661
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- 'Only QC location type is valid
         GOTO Step_5_Fail
      END

      DECLARE @nTranCount     INT
      SET @nTranCount = @@TRANCOUNT

      BEGIN TRAN
      SAVE TRAN rdtfnc_TM_Trolley_ReplenTo;

      DECLARE @TargetTask TABLE (TaskDetailKey BIGINT);

      INSERT INTO @TargetTask (TaskDetailKey)
      SELECT DISTINCT TASK.TaskDetailKey
      FROM TASKDETAIL TASK
         JOIN rdt.rdtTrolleyLog T WITH (NOLOCK)
         ON T.TaskDetailKey = TASK.TaskDetailKey
      WHERE T.TrolleyNo = @cTrolleyNo
        AND TASK.[Status] = 'H';

      UPDATE TASK SET
         TASK.UserKey = '',
         TASK.EditWho = SUSER_SNAME(),
         TASK.EditDate = GETDATE(),
         TASK.Trafficcop = NULL
      FROM TASKDETAIL TASK
         JOIN @TargetTask TT
         ON TASK.TaskDetailKey = TT.TaskDetailKey;
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 256666
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- UpdateTaskstatus fail
         GOTO RollBackTran
      END

      DELETE T FROM rdt.rdtTrolleyLog T
         JOIN @TargetTask TT
         ON T.TaskDetailKey = TT.TaskDetailKey
      WHERE T.TrolleyNo = @cTrolleyNo;
      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 256667
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Delete trolley log fail
         GOTO RollBackTran
      END

      UPDATE dbo.DeviceProfile
         SET Status = 0, -- empty
         EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      WHERE DeviceType = 'CART'
         AND DeviceID = @cTrolleyNo

      COMMIT TRAN;
      GOTO Step_5_Success

      RollBackTran:
      ROLLBACK TRAN rdtfnc_TM_Trolley_ReplenTo

      Step_5_Success:
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN
      IF @nErrNo = 0
      BEGIN
         SET @nScn  = @nscnMessage
         SET @nStep = @nStepMessage
      END
   END

   Step_5_Fail:
END
GOTO Quit

/********************************************************************************    
Step 6. screen = 6785
     Success Message
********************************************************************************/    
Step_6:
BEGIN    
   IF @nInputKey = 1 OR @nInputKey = 0 -- ENTER / ESC
   BEGIN
      SET @nScn  = @nScnTrolleyID
      SET @nStep = @nStepTrolleyID
   END
   GOTO Quit    

END    
GOTO Quit    

    
/********************************************************************************    
Quit. Update back to I/O table, ready to be pick up by JBOSS    
********************************************************************************/    
Quit:    
BEGIN
   UPDATE RDTMOBREC WITH (ROWLOCK)
   SET
      EditDate = GETDATE(),
      ErrMsg   = @cErrMsg,

      Func     = @nFunc,
      Scn      = @nScn,
      Step     = @nStep,

      Facility  = @cFacility,
      StorerKey = @cStorerKey,
      Printer   = @cPrinter,
      UserName  = @cUserName,

      V_ID             = @cID,
      V_TaskDetailKey  = @cTaskdetailkey,
      V_UCC            = @cSuggestedUCCno,

      V_String1 = @cTrolleyNo,
      V_String2 = @cReasonCode,
      V_String3 = @cPosition,
      V_String4 = @cTTMTaskType,
      V_String5 = @cTaskFromLOC,
       V_String6 = @cTaskToLOC,

      V_String21 = @cExtendedInfoSP,
      V_String22 = @cExtendedValidateSP,
      V_String23 = @cExtendedUpdateSP,

      I_Field01 = @cInField01,  O_Field01 = @cOutField01,
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,

      -- Field Attributes
      FieldAttr01 = @cFieldAttr01,
      FieldAttr02 = @cFieldAttr02,
      FieldAttr03 = @cFieldAttr03,
      FieldAttr04 = @cFieldAttr04,
      FieldAttr05 = @cFieldAttr05,
      FieldAttr06 = @cFieldAttr06,
      FieldAttr07 = @cFieldAttr07,
      FieldAttr08 = @cFieldAttr08,
      FieldAttr09 = @cFieldAttr09,
      FieldAttr10 = @cFieldAttr10,
      FieldAttr11 = @cFieldAttr11,
      FieldAttr12 = @cFieldAttr12,
      FieldAttr13 = @cFieldAttr13,
      FieldAttr14 = @cFieldAttr14,
      FieldAttr15 = @cFieldAttr15
   WHERE
      Mobile = @nMobile;


END
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_TM_Trolley_ReplenTo TO NSQL
GO
