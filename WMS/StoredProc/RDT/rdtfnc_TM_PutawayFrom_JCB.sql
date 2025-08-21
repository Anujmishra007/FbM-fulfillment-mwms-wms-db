SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*******************************************************************************/
/* Store procedure: rdtfnc_TM_PutawayFrom_JCB                                  */
/* Copyright      : Maersk                                                     */
/*                                                                             */
/* Purpose: RDT Task Manager - Move                                            */
/*                                                                             */
/* Modifications log:                                                          */
/*                                                                             */
/* Date        Rev    Author   Purposes                                        */
/* 2025-04-21  1.0.0  NLT013   FCR-3954. Created                               */
/* 2025-06-27  1.0.1  Dennis   FCR-3954. Update Dispatch strategy              */
/* 2025-07-16  1.0.2  Jackc    FCR-3954. Fix overwriteToLoc is cleared issue.  */  
/* 2025-07-23  1.0.3  Dennis   FCR-3954. Fix Recalculation issue.              */
/* 2025-08-21  0.0.0  Jackc    !!!Cutover. User V0 repo for work!!!            */  
/*******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdtfnc_TM_PutawayFrom_JCB](
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variable
DECLARE
   @b_success           INT, 
   @c_outstring         NVARCHAR(255), 
   @cSQL                NVARCHAR(1000),
   @cSQLParam           NVARCHAR(1000), 
   @cFromLoc            NVARCHAR(10)

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
   @cStorerKey          NVARCHAR(15),
   @cFacility           NVARCHAR(5),

   @cTaskdetailKey      NVARCHAR(10),
   @cAreaKey            NVARCHAR(10),

   @cSuggFromLoc        NVARCHAR(10),
   @cSuggToLoc          NVARCHAR(10),
   @cTaskToLoc          NVARCHAR(10),
   @cSuggFinalLoc       NVARCHAR(10),
   @cSuggID             NVARCHAR(18),
   @cSKU                NVARCHAR(20),
   @nQTY                INT,
   @nFromStep           INT,
   @nFromScn            INT,
   @cExtendedUpdateSP   NVARCHAR( 20),
   @cSwapTask           NVARCHAR( 1), 
   @cOverwriteToLOC     NVARCHAR( 20), 
   @cDefaultFromLOC     NVARCHAR( 20), 
   @cToLoc              NVARCHAR( 20),
   @cExtendedInfo       NVARCHAR( 20),
   @cExtendedInfoSP     NVARCHAR( 20),
   @cExtendedValidateSP NVARCHAR( 20),
   @tExtInfo            VariableTable, 
   @cReloadToLoc        NVARCHAR( 1),
   @cExtendedScreenSP   NVARCHAR( 20),
   @cExtScnSP           NVARCHAR( 20),
   @cEquipmentProfileKey               NVARCHAR(10),
   @cNewEquipmentProfileKey            NVARCHAR(10),
   @nTranCount          INT,

   @cNewIDAreaKey       NVARCHAR( 10),
   @cNewIDPutawayZone   NVARCHAR( 10),
   @fNewIDGrossWeight   FLOAT,
   @fMaximumWeight      FLOAT,
   @nRowCount           INT,
   @nLoopIndex          INT,
   @cReasonCode         NVARCHAR(10),
   @cLOCHoldKey         NVARCHAR(10),
   @cLocAisle           NVARCHAR(10),

   @cOldIDAreaKey       NVARCHAR( 10),
   @cOldIDPutawayZone   NVARCHAR( 10),
   @cTaskDetailMsg01    NVARCHAR(20), --Location PutawayZone
   @cTaskDetailMsg02    NVARCHAR(20), --Location Group
   @cTaskDetailMsg03    NVARCHAR(20), --Location Category
   @cNewTaskDetailKey   NVARCHAR( 10),
   @cCheckDigitLOC      NVARCHAR( 20),
   @cLocCategory              NVARCHAR( 10),
   @cMsg01                    NVARCHAR(20),
   @cMsg02                    NVARCHAR(20),
   @cMsg03                    NVARCHAR(20),
   @cMsg04                    NVARCHAR(20),
   @cMsg05                    NVARCHAR(20),
   @cMsg06                    NVARCHAR(20),
   @cMsg07                    NVARCHAR(20),
   @cMsg08                    NVARCHAR(20),
   @cMsg09                    NVARCHAR(20),
   @cMsg10                    NVARCHAR(20),

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

   DECLARE @tCandidateLoc TABLE
   (
      RowIndex INT IDENTITY(1,1) PRIMARY KEY,
      Loc NVARCHAR(20) NOT NULL,
      Qty INT NOT NULL
   )
   DECLARE @tAisleInUsed TABLE
   (
      RowIndex                 INT IDENTITY(1,1),
      LocAisle                 NVARCHAR(10),
      Userkey                  NVARCHAR(30)
   )

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

   @cTaskdetailKey   = V_TaskDetailKey,
   @cSuggFromLoc     = V_LOC,
   @cSuggID          = V_ID,
   @cSKU             = V_SKU,
   @nQTY             = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_QTY, 5), 0) = 1 THEN LEFT( V_QTY, 5) ELSE 0 END,

   @nFromStep        = V_FromStep,
   @nFromScn         = V_FromScn,
   
   @cSuggToloc          = V_String1,
   @cExtendedValidateSP = V_String2,
   @cExtendedInfoSP     = V_String3,
   @cExtendedUpdateSP   = V_String4,
   @cSwapTask           = V_String5, 
   @cOverwriteToLOC     = V_String6, 
   @cDefaultFromLOC     = V_String7, 
   @cToLoc              = V_String8,
   @cExtScnSP           = V_String10,
   @cEquipmentProfileKey= V_String11,

   @cAreakey            = V_String32,

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
IF @nFunc = 1871
BEGIN
   IF @nStep = 0 GOTO Step_0   -- Initialize
   IF @nStep = 1 GOTO Step_1   -- Scn = 6590. MHE
   IF @nStep = 2 GOTO Step_2   -- Scn = 6591. Area Key
   IF @nStep = 3 GOTO Step_3   -- Scn = 6592. ID
   IF @nStep = 4 GOTO Step_4   -- Scn = 6593. ToLOC
   IF @nStep = 5 GOTO Step_5   -- Scn = 6594. Sucess Msg
   IF @nStep = 6 GOTO Step_6   -- Scn = 6595. Reason Code
END      
RETURN -- Do nothing if incorrect step      


/********************************************************************************
Step 0. Called from Task Manager Main Screen (func = 1796)

********************************************************************************/
Step_0:
BEGIN
   -- Get task manager data
   SET @cTaskdetailKey  = @cOutField06
   SET @cAreaKey        = @cOutField07
   
   -- Get storer config
   SET @cSwapTask = rdt.rdtGetConfig( @nFunc, 'SwapTask', @cStorerKey)
   SET @cDefaultFromLOC = rdt.rdtGetConfig( @nFunc, 'DefaultFromLOC', @cStorerKey)
   IF @cDefaultFromLOC = '0'
      SET @cDefaultFromLOC = ''
   SET @cOverwriteToLOC = rdt.rdtGetConfig( @nFunc, 'OverwriteToLOC', @cStorerKey)
   IF @cOverwriteToLOC = '0'
      SET @cOverwriteToLOC = ''
   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''

   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'  
      SET @cExtendedValidateSP = ''

   SET @cExtendedInfoSP = rdt.rdtGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''

   SET @cExtScnSP = rdt.RDTGetConfig( @nFunc, 'ExtScnSP', @cStorerKey)
   IF @cExtScnSP = '0'
      SET @cExtScnSP = ''

   -- Default FromLOC
   SET @cFromLOC = ''
   IF @cDefaultFromLOC <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cDefaultFromLOC AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cDefaultFromLOC) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,           ' +
            '@nFunc           INT,           ' +
            '@cLangCode       NVARCHAR( 3),  ' +
            '@nStep           INT,           ' +  
            '@cTaskdetailKey  NVARCHAR( 10), ' +
            '@nErrNo          INT OUTPUT,    ' +
            '@cErrMsg         NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo = 0
            SET @cFromLOC = @cSuggFromLoc
         ELSE 
            SET @nErrNo = 0
      END
   END

   SELECT @cEquipmentProfileKey = EquipmentProfileKey
   FROM dbo.TaskManagerUser WITH (NOLOCK) 
   WHERE UserKey = @cUserName

   -- Enable all fields
   SET @cFieldAttr01 = ''
   SET @cFieldAttr02 = ''
   SET @cFieldAttr03 = ''
   SET @cFieldAttr04 = ''
   SET @cFieldAttr05 = ''
   SET @cFieldAttr06 = ''
   SET @cFieldAttr07 = ''
   SET @cFieldAttr08 = ''
   SET @cFieldAttr09 = ''
   SET @cFieldAttr10 = ''
   SET @cFieldAttr11 = ''
   SET @cFieldAttr12 = ''
   SET @cFieldAttr13 = ''
   SET @cFieldAttr14 = ''
   SET @cFieldAttr15 = ''

   -- Prepare next screen
   SET @cOutField01 = @cSuggFromLoc
   SET @cOutField02 = @cFromLOC

   -- Sign-in
   EXEC RDT.rdt_STD_EventLog
      @cActionType     = '1', -- Sign in function
      @cUserID         = @cUserName,
      @nMobileNo       = @nMobile,
      @nFunctionID     = @nFunc,
      @cFacility       = @cFacility,
      @cStorerKey      = @cStorerKey,
      @cLocation       = @cSuggFromLoc,
      @cToLocation    =  @cSuggToLoc,
      @cID             = @cSuggID,
      @cRefNo2         = @cAreaKey,
      @cRefNo3         = '',
      @cRefNo4         = '',
      @cRefNo5         = '',
      @cTaskdetailKey  = @cTaskdetailKey

   SET @cOutField01 = @cEquipmentProfileKey
   SET @cOutField02 = ''
   SET @cOutField15 = ''

   -- Set the entry point
   SET @nScn  = 6590
   SET @nStep = 1

   GOTO Quit
END
GOTO Quit


/******************************************
Step 1. Screen = 6590. MHE
Current MHE:            (Field01)
Provide New MHE:        (Field02 Input)
******************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 --Enter
   BEGIN
      SET @cNewEquipmentProfileKey = @cInField02

      IF @cEquipmentProfileKey = '' AND @cNewEquipmentProfileKey = ''
      BEGIN
         SET @nErrNo = 237101
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- MHE Needed
         GOTO Step_1_Fail
      END

      IF @cEquipmentProfileKey <> '' AND NOT EXISTS(SELECT 1 FROM dbo.EquipmentProfile WITH(NOLOCK) WHERE EquipmentProfileKey = @cEquipmentProfileKey)
      BEGIN
         SET @nErrNo = 237102
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid MHE
         GOTO Step_1_Fail
      END

      IF @cNewEquipmentProfileKey <> '' AND @cNewEquipmentProfileKey <> @cEquipmentProfileKey
      BEGIN
         IF NOT EXISTS(SELECT 1 FROM dbo.EquipmentProfile WITH(NOLOCK) WHERE EquipmentProfileKey = @cNewEquipmentProfileKey)
         BEGIN
            SET @nErrNo = 237103
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid New MHE
            GOTO Step_1_Fail
         END
      END

       -- Extended validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        '              +
               '@nFunc           INT,        '              +
               '@cLangCode       NVARCHAR( 3),   '          +
               '@nStep           INT,        '              +
               '@nScn            INT,        '              +
               '@cAreaKey        NVARCHAR( 10),  '          +
               '@cID             NVARCHAR( 18),  '          +
               '@cToLoc          NVARCHAR( 10),  '          +
               '@cEquipmentProfileKey NVARCHAR( 10),  '     +
               '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
               '@cTaskdetailKey  NVARCHAR( 10),  '          +
               '@cReasonCode     NVARCHAR(10) '             +
               '@nErrNo          INT OUTPUT, '              +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cSuggID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      IF @cNewEquipmentProfileKey <> '' AND @cNewEquipmentProfileKey <> @cEquipmentProfileKey
      BEGIN
         SET @cEquipmentProfileKey = @cNewEquipmentProfileKey

         UPDATE dbo.TaskManagerUser WITH (ROWLOCK)
         SET EquipmentProfileKey = @cNewEquipmentProfileKey,
            EditDate = GETDATE(),
            EditWho = @cUserName
         WHERE UserKey = @cUserName
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        '              +
               '@nFunc           INT,        '              +
               '@cLangCode       NVARCHAR( 3),   '          +
               '@nStep           INT,        '              +
               '@nScn            INT,        '              +
               '@cEquipmentProfileKey NVARCHAR( 10),  '     +
               '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
               '@cTaskdetailKey  NVARCHAR( 10),  '          +
               '@nErrNo          INT OUTPUT, '              +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      SET @cOutField01 = ''
      SET @cOutField02 = ''
      SET @cOutField15 = ''
      
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END
   ELSE IF @nInputKey = 0
   BEGIN
      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign-out
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep
         
      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = '' -- Option
   END

   GOTO Quit

   Step_1_Fail:
      GOTO Quit
END
GOTO Quit


/******************************************
Step 2. Screen = 6591. Area
Area:          (Field01 input)
******************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 --Enter
   BEGIN
      SET @cAreakey = @cInField01

      IF @cAreaKey = ''
      BEGIN
         SET @nErrNo = 237104
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Area Key Needed
         GOTO Step_2_Fail
      END
      ELSE
      BEGIN
         -- Check if Area exists
         IF NOT EXISTS ( SELECT 1
            FROM dbo.AreaDetail WITH (NOLOCK)
            WHERE AreaKey = @cAreaKey)
         BEGIN
            SET @nErrNo = 237105
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Area Key
            GOTO Step_2_Fail
         END
   
         -- Check if Area same as RDT User setup
         IF NOT EXISTS ( SELECT 1
            FROM dbo.TaskManagerUserDetail WITH (NOLOCK)
            WHERE AreaKey = @cAreaKey
            AND   UserKey = @cUsername)
         BEGIN
            SET @nErrNo = 237106
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not User Area Key
            GOTO Step_2_Fail
         END    
   
         -- Check if RDT User has permission on this area
         IF NOT EXISTS ( SELECT 1
            FROM dbo.TaskManagerUserDetail WITH (NOLOCK)
            WHERE AreaKey = @cAreaKey
               AND UserKey = @cUsername
               AND Permission = '1')
         BEGIN    
            SET @nErrNo = 237107
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Permission
            GOTO Step_2_Fail
         END
      END

       -- Extended validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        '              +
               '@nFunc           INT,        '              +
               '@cLangCode       NVARCHAR( 3),   '          +
               '@nStep           INT,        '              +
               '@nScn            INT,        '              +
               '@cAreaKey        NVARCHAR( 10),  '          +
               '@cID             NVARCHAR( 18),  '          +
               '@cToLoc          NVARCHAR( 10),  '          +
               '@cEquipmentProfileKey NVARCHAR( 10),  '     +
               '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
               '@cTaskdetailKey  NVARCHAR( 10),  '          +
               '@cReasonCode     NVARCHAR(10) '             +
               '@nErrNo          INT OUTPUT, '              +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cSuggID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_2_Fail
         END
      END

      -- Get pending task, if no pending task is found, find a new task
      -- If a task is found, update the task to be assigned to current user, go to ID screen
      -- If no task is found, prompt an error message "No Task Found"
      SELECT @fMaximumWeight = MaximumWeight 
      FROM dbo.EquipmentProfile EP WITH(NOLOCK) 
      WHERE EquipmentProfileKey = @cEquipmentProfileKey

      SET @cTaskdetailKey = ''
      SET @cSuggFromLoc = ''
      SET @cSuggID = ''
      SET @cSuggToLoc = ''
      SET @cSKU = ''

      DELETE FROM @tAisleInUsed
      INSERT INTO @tAisleInUsed
      (
         LocAisle, UserKey
      )
      SELECT DISTINCT v.LocAisle, Td.UserKey
      FROM TaskDetail TD WITH (NOLOCK)
      LEFT JOIN LOC FromLoc WITH (NOLOCK)
         ON TD.FromLOC = FromLoc.Loc
         AND FromLoc.LocationCategory = 'VNA'
         AND FromLOC.Facility = @cFacility
      LEFT JOIN LOC ToLoc WITH (NOLOCK)
         ON TD.ToLOC = ToLoc.Loc
         AND ToLoc.LocationCategory = 'VNA'
         AND ToLoc.Facility = @cFacility
      CROSS APPLY (
         SELECT FromLoc.LocAisle WHERE ISNULL(FromLoc.LocAisle,'') <> ''
         UNION ALL
         SELECT ToLoc.LocAisle WHERE ISNULL(ToLoc.LocAisle,'') <> ''
      ) v(LocAisle)
      WHERE TD.UserKey <> @cUsername
      AND TD.Status = '3'
      AND (FromLoc.Loc IS NOT NULL OR ToLoc.Loc IS NOT NULL)

      SELECT TOP 1 @cTaskdetailKey = TD.TaskDetailKey,
         @cSuggFromLoc = TD.FromLoc,
         @cSuggID = TD.FromID,
         @cSuggToLoc = TD.ToLoc,
         @cSKU = LLI.SKU
      FROM dbo.TaskDetail TD WITH(NOLOCK) 
      INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc
      INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc
      INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON LOC.PutawayZone = AD.PutawayZone
      INNER JOIN dbo.PALLET PL WITH(NOLOCK) ON TD.StorerKey = PL.StorerKey AND TD.FromID = PL.PalletKey
      INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON TD.StorerKey = LLI.StorerKey AND TD.FromID = LLI.ID
      LEFT JOIN dbo.RECEIPTDETAIL RTD WITH(NOLOCK) ON RTD.StorerKey = TD.StorerKey AND RTD.ToId = TD.FromID
      LEFT JOIN dbo.RECEIPT RT WITH(NOLOCK) ON RTD.StorerKey = RT.StorerKey AND RT.ReceiptKey = RTD.ReceiptKey
      WHERE TD.StorerKey = @cStorerKey
         AND TD.TaskType IN ('PAF', 'PA1')
         AND TD.Status IN ('0', '3' )
         AND TD.UserKey IN ('', @cUserName)
         AND TD.UserKeyOverRide IN (@cUserName, '')
         AND AD.AreaKey = @cAreakey
         AND LOC1.Status = 'OK'
         AND PL.GrossWgt <= @fMaximumWeight
         AND LLI.Qty - LLI.QtyPicked > 0
         AND NOT EXISTS(SELECT 1 
                        FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                        WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                           AND PAE.PutawayZone = LOC1.PutawayZone
                     )
         AND (NOT EXISTS(SELECT 1 
                        FROM @tAisleInUsed AIU
                        WHERE AIU.LocAisle = LOC1.LocAisle
                     ) OR LOC1.LocationCategory <> 'VNA')
      ORDER BY IIF (TD.Status = '3' AND TD.UserKey = @cUserName, 1, 2), IIF(TD.UserKeyOverRide = @cUserName, 1, 2), RT.FinalizeDate, TD.Priority, LOC.LocAisle, LOC.LogicalLocation, LOC.Loc, TD.TaskDetailKey

      IF ISNULL(@cTaskdetailKey, '') = ''
      BEGIN
         SET @nErrNo = 237108
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No Task Found
         GOTO Step_2_Fail
      END

      SET @nTranCount = @@TRANCOUNT

      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_1871Step2 -- For rollback or commit only our own transaction
      SET @nErrNo = 0

      BEGIN TRY
         UPDATE rdt.RDTUser WITH(ROWLOCK)
         SET AreaKey = @cAreaKey
         WHERE UserName = @cUserName

         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET Status = '3',
            ReasonKey = '',
            UserKey = @cUserName,
            EditDate = GETDATE(),
            EditWho = @cUserName
         WHERE TaskDetailKey = @cTaskdetailKey

         --Remove records from TaskManagerSkipTasks
         DELETE FROM dbo.TaskManagerSkipTasks
         WHERE USERID = @cUserName
            AND TaskType IN ('PAF', 'PA1')

         -- Extended update
         IF @cExtendedUpdateSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedUpdateSP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
               SET @cSQLParam =
                  '@nMobile         INT,        '              +
                  '@nFunc           INT,        '              +
                  '@cLangCode       NVARCHAR( 3),   '          +
                  '@nStep           INT,        '              +
                  '@nScn            INT,        '              +
                  '@cEquipmentProfileKey NVARCHAR( 10),  '     +
                  '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
                  '@cTaskdetailKey  NVARCHAR( 10),  '          +
                  '@nErrNo          INT OUTPUT, '              +
                  '@cErrMsg         NVARCHAR( 20) OUTPUT'
      
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep,@nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey,  @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT
      
               IF @nErrNo <> 0
               BEGIN
                  ;THROW @nErrNo, @cErrMsg, 1
               END
            END
         END
      END TRY
      BEGIN CATCH
         IF @nErrNo = 0
         BEGIN
            SET @nErrNo = 237109
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update Task Failed
         END
         ELSE
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Get the error message from the error number

         ROLLBACK TRAN rdt_1871Step2 -- Only rollback change made here
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN

         GOTO Step_2_Fail
      END CATCH

      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN

	  IF @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')
      BEGIN
	     UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET Status = '0',
            ReasonKey = '',
            UserKey = '',
            EditDate = GETDATE(),
            EditWho = 'RDTPA'
         WHERE TaskDetailKey = @cTaskdetailKey

	     SET @cSuggID = ''
	  END

      SET @cOutField01 = @cSuggFromLoc --Suggested FromLoc
      SET @cOutField02 = @cSuggID  --Suggested FromID
      SET @cOutField03 = ''               --ID to be scanned
      SET @cOutField15 = ''               --Extended info
      
      SET @nScn =  @nScn + 1               --ID Screen
      SET @nStep = @nStep + 1              --Step 3
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare next screen var
      SET @cOutField01 = @cEquipmentProfileKey
      SET @cOutField02 = '' -- New MHE
      SET @cOutField15 = '' -- Extended Info

      --Remove records from TaskManagerSkipTasks
      DELETE FROM dbo.TaskManagerSkipTasks
      WHERE USERID = @cUserName
         AND TaskType IN ('PAF', 'PA1')

      -- go to previous screen
      SET @nScn = @nScn - 1      -- MHE Screen
      SET @nStep = @nStep - 1    -- Step 1
   END

   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cAreakey = ''

      SET @cOutField01 = ''
      SET @cOutField02 = '' -- New MHE
      SET @cOutField15 = '' -- Extended Info
   END
END
GOTO Quit

/********************************************************************************
Step 3. screen = 6592 ID Screen
   FROM LOC (Field01)
   SUGG ID  (Field02)
   ID       (Field03, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      DECLARE @cFromID NVARCHAR(18)

      -- Screen mapping
      SET @cFromID = @cInField03

      -- Check blank
      IF @cFromID = ''
      BEGIN
         SET @nErrNo = 237110
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID is Needed
         GOTO Step_3_Fail
      END

      SELECT @fNewIDGrossWeight = PL.GrossWgt
      FROM dbo.LOTXLOCXID LLI WITH(NOLOCK)
      INNER JOIN dbo.PALLET PL WITH(NOLOCK)
         ON LLI.ID = PL.PalletKey
      WHERE LLI.ID = @cFromID
         AND LLI.StorerKey = @cStorerKey
      
      SELECT @nRowCount = @@ROWCOUNT

      IF @nRowCount = 0
      BEGIN
         SET @nErrNo = 237111
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- ID Does Not Exist
         GOTO Step_3_Fail
      END

      -- Check FromID match
      IF @cFromID <> @cSuggID AND @cSwapTask <> '1'
      BEGIN
         SET @nErrNo = 237112
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID Does Not Match
         GOTO Step_3_Fail
      END

      IF @cFromID <> @cSuggID AND @cSwapTask = '1'
      BEGIN
         --New ID should be in same area, ID suitable for the MHE, 
         --MHE is not excluded from the putaway zone (Message01 in the TaskDetail table)
         SELECT @cNewIDAreaKey = AD.AreaKey
         FROM dbo.TaskDetail TD WITH(NOLOCK)
         INNER JOIN dbo.LOC LOC WITH(NOLOCK)
            ON TD.FromLoc = LOC.Loc
         INNER JOIN dbo.AreaDetail AD WITH(NOLOCK)
            ON LOC.PutawayZone = AD.PutawayZone
         WHERE TD.FromID = @cFromID
            AND TD.TaskType IN ('PAF', 'PA1')
            AND (TD.Status = '0' OR (TD.Status = '3' AND TD.UserKey = @cUserName))
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND Loc.Facility = @cFacility
            AND TD.StorerKey = @cStorerKey

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 237113
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- InvalidID
            GOTO Step_3_Fail
         END

         SELECT @cOldIDAreaKey = AD.AreaKey
         FROM dbo.TaskDetail TD WITH(NOLOCK)
         INNER JOIN dbo.LOC LOC WITH(NOLOCK)
            ON TD.FromLoc = LOC.Loc
         INNER JOIN dbo.AreaDetail AD WITH(NOLOCK)
            ON LOC.PutawayZone = AD.PutawayZone
         WHERE TD.TaskType IN ('PAF', 'PA1')
            AND (TD.Status = '3' OR (TD.Status = '0' AND @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')))
            AND (TD.UserKey = @cUserName OR (TD.UserKey = '' AND @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')))
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND Loc.Facility = @cFacility
            AND TD.TaskDetailKey = @cTaskdetailKey
            AND TD.StorerKey = @cStorerKey

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 237114
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- No Task is Found
            GOTO Step_3_Fail
         END

         IF @cNewIDAreaKey <> @cOldIDAreaKey
         BEGIN
            SET @nErrNo = 237115
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Different Area Key
            GOTO Step_3_Fail
         END

         SELECT @fMaximumWeight = MaximumWeight
         FROM dbo.EquipmentProfile WITH(NOLOCK)
         WHERE EquipmentProfileKey = @cEquipmentProfileKey

         IF @fMaximumWeight < @fNewIDGrossWeight
         BEGIN
            SET @nErrNo = 237116
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Scanned Pallet is Over Weight
            GOTO Step_3_Fail
         END

         SELECT @cNewIDPutawayZone = AD.PutawayZone
         FROM dbo.TaskDetail TD WITH(NOLOCK)
         INNER JOIN dbo.LOC LOC WITH(NOLOCK)
            ON TD.ToLoc = LOC.Loc
         INNER JOIN dbo.AreaDetail AD WITH(NOLOCK)
            ON LOC.PutawayZone = AD.PutawayZone
         WHERE TD.FromID = @cFromID
            AND TD.TaskType IN ('PAF', 'PA1')
            AND ((TD.Status = '0' AND TD.UserKey = '') OR (TD.Status = '3' AND TD.UserKey = @cUserName))
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND Loc.Facility = @cFacility
            AND TD.StorerKey = @cStorerKey

         IF EXISTS(SELECT 1 
                  FROM dbo.PAZoneEquipmentExcludeDetail WITH(NOLOCK)
                  WHERE EquipmentProfileKey = @cEquipmentProfileKey
                     AND PutawayZone = @cNewIDPutawayZone
               )
         BEGIN
            SET @nErrNo = 237117
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Putaway Zone Is Excluded
            GOTO Step_3_Fail
         END
      END

       -- Extended validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        '              +
               '@nFunc           INT,        '              +
               '@cLangCode       NVARCHAR( 3),   '          +
               '@nStep           INT,        '              +
               '@nScn            INT,        '              +
               '@cAreaKey        NVARCHAR( 10),  '          +
               '@cID             NVARCHAR( 18),  '          +
               '@cToLoc          NVARCHAR( 10),  '          +
               '@cEquipmentProfileKey NVARCHAR( 10),  '     +
               '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
               '@cTaskdetailKey  NVARCHAR( 10),  '          +
               '@cReasonCode     NVARCHAR(10) '             +
               '@nErrNo          INT OUTPUT, '              +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cFromID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_3_Fail
         END
      END

      -- Check FromID match
      IF @cFromID <> @cSuggID AND @cSwapTask = '1'
      BEGIN-- Swap task
         EXEC rdt.rdt_TM_PutawayFrom_SwapTask_JCB @nMobile, @nFunc, @cLangCode, @cUserName
            ,@cTaskDetailKey
            ,@cFromID
            ,@cNewTaskDetailKey OUTPUT
            ,@nErrNo            OUTPUT
            ,@cErrMsg           OUTPUT
         IF @nErrNo <> 0
         BEGIN
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
            GOTO Step_3_Fail
         END
      
         -- Reload task
         SET @cTaskDetailKey = @cNewTaskDetailKey

         SELECT 
            @cStorerKey   = Storerkey,
            @cSuggFromLoc = FromLOC, 
            @cSuggID      = FromID,
            @cSuggToLoc   = ToLOC
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskdetailKey

         --Remove it from TaskManagerSkipTasks
         DELETE FROM dbo.TaskManagerSkipTasks
         WHERE USERID = @cUserName
            AND TaskType IN ('PAF', 'PA1')
            AND TaskDetailKey = @cTaskdetailKey
      END

      SELECT @cToLoc = TD.ToLoc,
         @cSKU = LLI.SKU,
         @cTaskDetailMsg01 = TD.Message01,  -- PutawayZone
         @cTaskDetailMsg02 = TD.Message02,  -- LocationGroup
         @cTaskDetailMsg03 = TD.Message03,  -- LocationCategory
         @cLocCategory = LOC.LocationCategory
      FROM dbo.TaskDetail TD WITH(NOLOCK)
      INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.ToLoc = LOC.Loc
      INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON LLI.StorerKey = TD.StorerKey AND LLI.ID = TD.FromID
      WHERE TD.StorerKey = @cStorerKey
         AND LOC.Facility = @CFacility
         AND TD.TaskDetailKey = @cTaskdetailKey
         AND LLI.Qty - LLI.QtyPicked > 0

      SET @cOutField04 = ''
      SET @cOutField05 = ''
      SET @cOutField06 = ''
      SET @cOutField07 = ''
      SET @cOutField08 = ''

      -- If ToLoc exists in the CODELKUP where LISTNAME = 'JCBBKTOLOC', need find top 5 proper locations, display them
      -- Search location criterias: 1. Same Facility, 2, Same Putaway Zone, Location Group, Location Category, 3. Same SKU
      IF EXISTS(SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK)
               WHERE LISTNAME = 'JCBBKTOLOC'
                  AND StorerKey = @cStorerKey
                  AND Short = @cLocCategory)
      BEGIN
         DELETE FROM @tCandidateLoc

         INSERT INTO @tCandidateLoc (Loc, Qty)
         SELECT TOP 5 LOC.Loc, SUM(LLI.Qty - LLI.QtyPicked) AS TotalQty
         FROM dbo.LOC WITH(NOLOCK)
         INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK)
            ON LLI.Loc = LOC.Loc
         WHERE Facility = @cFacility
            AND LLI.StorerKey = @cStorerKey
            AND LLI.Sku = @cSKU
            AND LOC.Loc <> @cToLoc
            AND LOC.Status = 'OK'
            AND LOC.PutawayZone = @cTaskDetailMsg01
            AND LOC.LocationGroup = @cTaskDetailMsg02
            AND LOC.LocationCategory = @cTaskDetailMsg03
            AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
            AND NOT EXISTS(SELECT 1 
                        FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                        WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                           AND PAE.PutawayZone = LOC.PutawayZone
                     )
         GROUP BY LOC.Loc
         ORDER BY SUM(LLI.Qty - LLI.QtyPicked) DESC, LOC.Loc

         DECLARE 
            @cSuggestToLoc       NVARCHAR(10),
            @nRowIndex           INT = 0

         SET @nLoopIndex = -1
         WHILE 1 = 1
         BEGIN
            SELECT TOP 1
               @cSuggestToLoc = Loc,
               @nLoopIndex = RowIndex
            FROM @tCandidateLoc
            WHERE RowIndex > @nLoopIndex
            ORDER BY RowIndex

            SELECT @nRowCount = @@ROWCOUNT

            IF @nRowCount = 0
               BREAK

            SET @nRowIndex = @nRowIndex + 1

            SET @cOutField04 = IIF(@nRowIndex = 1 , @cSuggestToLoc, @cOutField04)
            SET @cOutField05 = IIF(@nRowIndex = 2 , @cSuggestToLoc, @cOutField05)
            SET @cOutField06 = IIF(@nRowIndex = 3 , @cSuggestToLoc, @cOutField06)
            SET @cOutField07 = IIF(@nRowIndex = 4 , @cSuggestToLoc, @cOutField07)
            SET @cOutField08 = IIF(@nRowIndex = 5 , @cSuggestToLoc, @cOutField08)
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        ' +
               '@nFunc           INT,        ' +
               '@cLangCode       NVARCHAR( 3),   ' +
               '@nStep           INT,        ' +
               '@nScn            INT,        ' +
               '@cEquipmentProfileKey NVARCHAR( 10),' +
               '@cNewEquipmentProfileKey NVARCHAR( 10),' +
               '@cTaskdetailKey  NVARCHAR( 10),  ' +
               '@nErrNo          INT OUTPUT, ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_3_Fail
         END
      END

      -- Extended info
      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cExtendedInfo = ''
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @tExtInfo, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        ' +
               '@nFunc           INT,        ' +
               '@cLangCode       NVARCHAR( 3),   ' +
               '@nStep           INT,        ' +
               '@nInputKey       INT,        ' + 
               '@cTaskdetailKey  NVARCHAR( 10),  ' +
               '@tExtInfo        VariableTable READONLY, ' +
               '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' + 
               '@nErrNo          INT OUTPUT, ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @tExtInfo, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @cExtendedInfo <> ''
               SET @cOutField15 = @cExtendedInfo
         END
      END

      --NLT013
      SET @cReloadToLoc = rdt.rdtGetConfig( @nFunc, 'ReloadToLoc', @cStorerKey)
      IF @cReloadToLoc = '0'
         SET @cReloadToLoc = ''
      IF @cReloadToLoc = '1'
      BEGIN
         SELECT
            @cSuggToLoc = ToLOC
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskdetailKey
      END
      
      -- Prepare next screen var
      SET @cOutField01 = @cSuggID
      SET @cOutField02 = @cSuggToLoc
      SET @cOutField03 = '' -- ToLOC

      -- Go to next screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- IF current taks is not finished, go to Reason Code screen
      IF EXISTS(SELECT 1 
                  FROM dbo.TaskDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND TaskDetailKey = @cTaskDetailKey
                     AND Status = '3'
                     AND UserKey = @cUserName)
      BEGIN
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutfield04 = ''
         SET @cOutField05 = ''
         SET @cOutField09 = ''

         -- Go to Reason Code Screen
         SET @nFromScn  = @nScn
         SET @nFromStep = @nStep
         SET @nScn  = 6595
         SET @nStep = @nStep + 3
         GOTO Quit
      END
      ELSE
      BEGIN
         -- Prepare next screen var
         SET @cOutField01 = ''--@cSuggFromLoc
         SET @cOutField02 = '' 

         -- go to previous screen
         SET @nScn = @nScn - 1      --Area Screen
         SET @nStep = @nStep - 1    --Step 2
      END
   END

   GOTO Quit

   Step_3_Fail:
   BEGIN
   	  IF @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')
      BEGIN
	     UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET Status = '0',
            ReasonKey = '',
            UserKey = '',
            EditDate = GETDATE(),
            EditWho = 'RDTPA'
         WHERE TaskDetailKey = @cTaskdetailKey

	     SET @cSuggID = ''
	  END

      SET @cOutField01 = @cSuggFromLoc --Suggested FromLoc
      SET @cOutField02 = @cSuggID  --Suggested FromID
      SET @cOutField03 = ''            --ID to be scanned
      SET @cOutField15 = ''            --Extended info
   END
END
GOTO Quit


/********************************************************************************
   Step 4. Screen = 6593. ToLoc
   ID:            (Field01)
   To LOC:        (Field02, Field03 input)
   SUGGESTED LOC: (Field04, Field05, Field06, Field07, Field08)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cToLOC = @cInField03 -- ToLOC

      -- Check blank
      IF @cToLoc = ''
      BEGIN
         SET @nErrNo = 237118
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLoc is Needed
         GOTO Step_4_Fail
      END

      -- Exception happens, go to Reason Code screen
      IF @cToLoc = '99' 
      BEGIN
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutfield04 = ''
         SET @cOutField05 = ''
         SET @cOutField09 = ''

         -- Go to Reason Code Screen
         SET @nFromScn  = @nScn
         SET @nFromStep = @nStep
         SET @nScn  = 6595
         SET @nStep = @nStep + 2
         GOTO Quit
      END

      SET @cCheckDigitLOC = @cToLOC
      EXEC rdt.rdt_LOCLookUp_CheckDigit @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,
         @cCheckDigitLOC    OUTPUT,
         @nErrNo      OUTPUT,
         @cErrMsg     OUTPUT
      IF @nErrNo <> 0
         GOTO Step_4_Fail
      SET @cToLoc = @cCheckDigitLOC

      SELECT
         @cSKU = LLI.SKU,
         @cTaskDetailMsg01 = TD.Message01,  -- PutawayZone
         @cTaskDetailMsg02 = TD.Message02,  -- LocationGroup
         @cTaskDetailMsg03 = TD.Message03,  -- LocationCategory
         @cLocCategory = LOC.LocationCategory,
         @cSuggFinalLoc = TD.FinalLoc
      FROM dbo.TaskDetail TD WITH(NOLOCK)
      INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.ToLoc = LOC.Loc
      INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON LLI.StorerKey = TD.StorerKey AND LLI.ID = TD.FromID
      WHERE TD.StorerKey = @cStorerKey
         AND LOC.Facility = @CFacility
         AND LLI.Qty - LLI.QtyPicked > 0
         AND TD.Status = '3'
         AND TD.UserKey = @cUserName
         AND TD.TaskType IN ('PAF', 'PA1')
         AND TD.TaskDetailKey = @cTaskdetailKey

      -- It is able to overwrite ToLoc if Location exists in 'JCBBKTOLOC'
      IF NOT EXISTS(SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK)
                  WHERE LISTNAME = 'JCBBKTOLOC'
                     AND StorerKey = @cStorerKey
                     AND Short = @cLocCategory)
      BEGIN
         --V1.0.2 start
         -- If category not set, then not allow to overwrite toLoc no matter whether OverwriteToLoc is set.
         -- Do not change @cOverwriteToLOC value, it will impact the following tasks.
         --SET @cOverwriteToLOC = '' --Disallow to overwrite ToLoc
         IF @cToLoc <> @cSuggToLoc
         BEGIN
            SET @nErrNo = 237130
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot overwrit in this category
            GOTO Step_4_Fail
         END
         --V1.0.2 end
      END

      IF @cToLoc <> @cSuggToLoc
      BEGIN
         -- Not allow overwrite
         IF @cOverwriteToLOC = ''
         BEGIN
            SET @nErrNo = 237119
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Loc Does Not Match
            GOTO Step_4_Fail
         END
         
         -- Override suggest LOC should not allow, if suggest LOC is transit LOC (TaskDetail.TransitLOC)
         IF EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) 
                     WHERE TaskDetailKey = @cTaskdetailKey 
                     AND TransitLOC = @cToLOC)
         BEGIN
            SET @nErrNo = 237120
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLoc is Transit Loc
            GOTO Step_4_Fail
         END

         -- Check if Overwrote Location is valid
         IF @cOverwriteToLOC = '1'
         BEGIN
            IF EXISTS(SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK)
                     WHERE LISTNAME = 'JCBBKTOLOC'
                        AND StorerKey = @cStorerKey
                        AND Short = @cLocCategory)
            BEGIN
               SELECT @nRowCount = COUNT(1)
                  FROM dbo.LOC WITH(NOLOCK)
               LEFT JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK)
                  ON LLI.Loc = LOC.Loc AND LLI.Sku = @cSKU AND LLI.StorerKey = @cStorerKey
               WHERE Facility = @cFacility
                  AND (LLI.Qty - LLI.QtyPicked > 0 OR LLI.Qty IS NULL)
                  AND LOC.Loc = @cToLoc
                  AND LOC.Status = 'OK'
                  AND LOC.PutawayZone = @cTaskDetailMsg01
                  AND LOC.LocationGroup = @cTaskDetailMsg02
                  AND LOC.LocationCategory = @cTaskDetailMsg03
                  AND NOT EXISTS(SELECT 1 
                              FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                              WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                                 AND PAE.PutawayZone = LOC.PutawayZone
                           )

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 237127
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid ToLoc
                  GOTO Step_4_Fail
               END
            END
         END
         ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cOverwriteToLOC AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cOverwriteToLOC) +
               ' @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cSuggToLoc, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile        INT,           ' +
               '@nFunc          INT,           ' +
               '@cLangCode      NVARCHAR( 3),  ' +
               '@cTaskdetailKey NVARCHAR( 10), ' +
               '@cSuggToLoc     NVARCHAR( 10), ' +
               '@cToLOC         NVARCHAR( 10), ' +
               '@nErrNo         INT OUTPUT,    ' +
               '@cErrMsg        NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cSuggToLoc, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_4_Fail
         END
      END

       -- Extended validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        '              +
               '@nFunc           INT,        '              +
               '@cLangCode       NVARCHAR( 3),   '          +
               '@nStep           INT,        '              +
               '@nScn            INT,        '              +
               '@cAreaKey        NVARCHAR( 10),  '          +
               '@cID             NVARCHAR( 18),  '          +
               '@cToLoc          NVARCHAR( 10),  '          +
               '@cEquipmentProfileKey NVARCHAR( 10),  '     +
               '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
               '@cTaskdetailKey  NVARCHAR( 10),  '          +
               '@cReasonCode     NVARCHAR(10) '             +
               '@nErrNo          INT OUTPUT, '              +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cSuggID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_4_Fail
         END
      END

      SELECT @cLocCategory = LocationCategory
      FROM dbo.Loc WITH(NOLOCK)
      WHERE Facility = @cFacility
         AND Loc = @cToLoc

      -- Handling transaction
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_TM_PutawayFrom -- For rollback or commit only our own transaction

      BEGIN TRY
         UPDATE dbo.TaskDetail WITH(ROWLOCK) 
         SET
            ToLoc = IIF(@cToLoc <> @cSuggToLoc, @cToLoc, ToLoc),
            TransitLOC = IIF(@cLocCategory IN ('PND', 'PNDIN','PND_IN'), @cToLoc, TransitLoc)
         WHERE StorerKey = @cStorerKey
            AND TaskType IN ('PAF', 'PA1')
            AND UserKey = @cUserName
            AND Status = '3'
            AND TaskDetailKey = @cTaskDetailKey

         -- Confirm task
         EXEC rdt.rdt_TM_PutawayFrom_Confirm_JCB @nMobile, @nFunc, @cLangCode, @cUserName
            ,@cTaskDetailKey
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT

         IF @nErrNo <> 0
         BEGIN
            ;THROW @nErrNo, @cErrMsg, 1
         END

         IF @cToLoc <> @cSuggToLoc
         BEGIN
            EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK' 
               ,''       --@cLOC      
               ,@cSuggID   --@cID       
               ,@cSuggToLoc --@cFinalLOC 
               ,''       --@cStorerKey
               ,@nErrNo  OUTPUT
               ,@cErrMsg OUTPUT
            IF @nErrNo <> 0
            BEGIN
               ;THROW @nErrNo, @cErrMsg, 1
            END
         END
         -- If PA1 task was created, need update Message01, Message02, Message03 in TaskDetail table
         DECLARE @cPA1TaskDetailKey NVARCHAR(10) = ''

         SELECT @cPA1TaskDetailKey  = TaskDetailKey FROM dbo.TaskDetail WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND TaskDetailKey <> @cTaskDetailKey
                        AND TaskType = 'PA1'
                        AND Status = '0'
                        AND FromID = @cSuggID
                        AND FromLoc = @cSuggToLoc
                        AND ToLoc = @cSuggFinalLoc
         
         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount > 0 AND ISNULL(@cPA1TaskDetailKey, '') <> ''
         BEGIN
            -- Check if RFPutaway record exists
            -- If not, create a new one
            IF NOT EXISTS (SELECT 1 FROM dbo.RFPutaway WITH(NOLOCK)
                           WHERE StorerKey = @cStorerKey
                              AND ID = @cSuggID
                              AND FromLoc = @cSuggToLoc
                              AND SuggestedLOC = @cSuggFinalLoc
                              AND SKU = @cSKU)
            BEGIN
               EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
                  ,@cSuggToLoc
                  ,@cSuggID
                  ,@cSuggFinalLoc
                  ,@cStorerKey
                  ,@nErrNo  OUTPUT
                  ,@cErrMsg OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  ;THROW @nErrNo, @cErrMsg, 1
               END
            END

            -- Update PA1 TaskDetail, Message01, Message02, Message03
            -- Message01 = PutawayZone, Message02 = LocationGroup, Message03 = LocationCategory
            UPDATE TD
            SET 
               Message01 = Loc.PutawayZone,  -- PutawayZone
               Message02 = LOC.LocationGroup,  -- LocationGroup
               Message03 = LOC.LocationCategory   -- LocationCategory
            FROM dbo.TaskDetail TD WITH(ROWLOCK)
            INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.ToLoc = LOC.Loc
            WHERE StorerKey = @cStorerKey
               AND TaskDetailKey = @cPA1TaskDetailKey
               AND LOC.Facility = @cFacility
         END

         -- Extended update
         IF @cExtendedUpdateSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedUpdateSP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
               SET @cSQLParam =
                  '@nMobile         INT,        ' +
                  '@nFunc           INT,        ' +
                  '@cLangCode       NVARCHAR( 3),   ' +
                  '@nStep           INT,        ' +
                  '@nScn            INT,        ' +
                  '@cEquipmentProfileKey NVARCHAR( 10),' +
                  '@cNewEquipmentProfileKey NVARCHAR( 10),' +
                  '@cTaskdetailKey  NVARCHAR( 10),  ' +
                  '@nErrNo          INT OUTPUT, ' +
                  '@cErrMsg         NVARCHAR( 20) OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT
      
               IF @nErrNo <> 0
               BEGIN
                  ;THROW @nErrNo, @cErrMsg, 1
               END
            END
         END

         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN
      END TRY
      BEGIN CATCH
         IF @nErrNo = 0
         BEGIN
            SET @nErrNo = 237122
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Confirm Putaway Failed
         END
         ELSE
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Get the error message from the error number

         ROLLBACK TRAN rdt_TM_PutawayFrom -- Only rollback change made here
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN

         GOTO Step_4_Fail
      END CATCH
            
      -- Logging
      EXEC RDT.rdt_STD_EventLog
         @cActionType   = '4', -- Move
         @cUserID       = @cUserName,
         @nMobileNo     = @nMobile,
         @nFunctionID   = @nFunc,
         @cFacility     = @cFacility,
         @cStorerKey    = @cStorerKey,
         @cLocation     = @cSuggFromLoc,
         @cToLocation   = @cToLOC,
         @cID           = @cSuggID

      -- Go to message screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      IF @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')
      BEGIN
	     UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET Status = '0',
            ReasonKey = '',
            UserKey = '',
            EditDate = GETDATE(),
            EditWho = 'RDTPA'
         WHERE TaskDetailKey = @cTaskdetailKey

	     SET @cSuggID = ''
	  END

      -- Go to previous screen
      SET @cOutField01 = @cSuggFromLoc --Suggested FromLoc
      SET @cOutField02 = @cSuggID  --Suggested FromID
      SET @cOutField03 = ''            --ID to be scanned
      SET @cOutField15 = ''            --Extended info
      
      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1
   END
   GOTO Quit

   Step_4_Fail:
   BEGIN
      SET @cOutField01 = @cSuggID      --Suggested FromID
      SET @cOutField02 = @cSuggToLoc   --Suggested ToLoc
      SET @cOutField03 = ''            --ID to be scanned
      SET @cOutField15 = ''            --Extended info
   END
END
GOTO Quit


/********************************************************************************
Step 5. screen = 6594. Message screen
   SUCCESSFUL PUTAWAY
   ENTER = Next Task
   ESC   = Exit TM
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      DECLARE 
         @cNextTaskDetailKey        NVARCHAR(10)

      SET @cNextTaskDetailKey = ''
      SET @cLocAisle = ''

      -- Get Next Task
      SELECT @cLocCategory = LocationCategory,
         @cLocAisle = LocAisle
      FROM dbo.Loc WITH(NOLOCK)
      WHERE Facility = @cFacility
         AND Loc = @cSuggFromLoc

      SELECT @fMaximumWeight = MaximumWeight 
      FROM dbo.EquipmentProfile EP WITH(NOLOCK) 
      WHERE EquipmentProfileKey = @cEquipmentProfileKey

      -- If last task is from PND location, then next task should be from PND location
      -- Sequence: 1. same aisle but opposite side to be given 2. Next aisle in the same AreaKey
      IF @cLocCategory IN  ('PNDIN', 'PND', 'PND_IN')
      BEGIN
         SELECT TOP 1 
            @cNextTaskDetailKey = TD.TaskDetailKey,
            @cSuggFromLoc = TD.FromLoc,
            @cSuggID = TD.FromID,
            @cSKU = TD.SKU
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC.Loc
         INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON LOC.PutawayZone = AD.PutawayZone
         INNER JOIN dbo.PALLET PL WITH(NOLOCK) ON TD.StorerKey = PL.StorerKey AND TD.FromID = PL.PalletKey
         WHERE TD.StorerKey = @cStorerKey
            AND LOC.Facility = @cFacility
            AND LOC.LocationCategory IN  ('PND_IN', 'PND', 'PNDIN')
            AND TD.TaskType IN ('PAF', 'PA1')
            AND ((TD.Status = '0' AND TD.UserKey = '') OR (TD.Status = '3' AND TD.UserKey = @cUserName))
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND AD.AreaKey = @cAreaKey
            AND PL.GrossWgt <= @fMaximumWeight
            AND NOT EXISTS(SELECT 1 
                           FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                           WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                              AND PAE.PutawayZone = LOC1.PutawayZone)
            AND NOT EXISTS(SELECT 1 
                           FROM dbo.TaskManagerSkipTasks TST WITH(NOLOCK)
                           WHERE TST.TaskDetailKey = TD.TaskDetailKey
                              AND TST.TaskType = TD.TaskType)
         ORDER BY IIF(LOC.LocAisle = @cLocAisle, 1, 2), LOC.LocAisle, IIF(TD.UserKeyOverRide = @cUserName, 1, 2), LOC.LogicalLocation, LOC.Loc
      END

      -- If no task was found from PND location, then next task should be from the same area
      IF ISNULL(@cNextTaskDetailKey, '') = ''
      BEGIN
         -- Get pending task, if no pending task is found, find a new task
         -- If a task is found, update the task to be assigned to current user, go to ID screen
         -- If no task is found, prompt an error message "No More Found", go back to Area screen
         SELECT TOP 1 @cNextTaskDetailKey = TD.TaskDetailKey,
            @cSuggFromLoc = TD.FromLoc,
            @cSuggID = TD.FromID,
            @cSKU = TD.SKU
         FROM dbo.TaskDetail TD WITH(NOLOCK) 
         INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc
         INNER JOIN dbo.LOC LOC1 WITH(NOLOCK) ON TD.ToLoc = LOC1.Loc
         INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON LOC.PutawayZone = AD.PutawayZone
         INNER JOIN dbo.PALLET PL WITH(NOLOCK) ON TD.StorerKey = PL.StorerKey AND TD.FromID = PL.PalletKey
         LEFT JOIN dbo.RECEIPTDETAIL RTD WITH(NOLOCK) ON RTD.StorerKey = TD.StorerKey AND RTD.ToId = TD.FromID
         LEFT JOIN dbo.RECEIPT RT WITH(NOLOCK) ON RTD.StorerKey = RT.StorerKey AND RT.ReceiptKey = RTD.ReceiptKey
         WHERE TD.StorerKey = @cStorerKey
            AND TD.TaskType IN ('PAF', 'PA1')
            AND TD.Status IN ('0', '3' )
            AND TD.UserKey IN ('', @cUserName)
            AND TD.UserKeyOverRide IN (@cUserName, '')
            AND AD.AreaKey = @cAreakey
            AND PL.GrossWgt <= @fMaximumWeight
            AND NOT EXISTS(SELECT 1 
                           FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                           WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                              AND PAE.PutawayZone = LOC1.PutawayZone)
            AND NOT EXISTS(SELECT 1 
                           FROM dbo.TaskManagerSkipTasks TST WITH(NOLOCK)
                           WHERE TST.TaskDetailKey = TD.TaskDetailKey
                              AND TST.TaskType = TD.TaskType)
         ORDER BY IIF (TD.Status = '3' AND TD.UserKey = @cUserName, 1, 2), IIF(TD.UserKeyOverRide = @cUserName, 1, 2), RT.FinalizeDate, TD.Priority, LOC.LocAisle, LOC.LogicalLocation, LOC.Loc, TD.TaskDetailKey
      END

      SET @cTaskDetailKey = @cNextTaskDetailKey

      IF ISNULL(@cTaskDetailKey, '') <> ''
      BEGIN
         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET Status = '3',
            UserKey = @cUserName,
            EditDate = GETDATE(),
            EditWho = @cUserName
         WHERE TaskDetailKey = @cTaskdetailKey
            AND StorerKey = @cStorerKey

         SELECT 
            @cStorerKey   = Storerkey,
            @cSuggFromLoc = FromLOC, 
            @cSuggID      = FromID,
            @cSuggToLoc   = ToLOC
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskdetailKey
            AND StorerKey = @cStorerKey
      END

      -- No task
      IF ISNULL(@cNextTaskDetailKey, '') = ''
      BEGIN
         -- Go back to Area Screen
         SET @cErrMsg = 'No More Task'
         SET @cOutField01 = @cAreaKey  -- Area
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutField04 = ''
         SET @cOutField05 = ''
         SET @cOutField06 = ''
         SET @cOutField07 = ''
         SET @cOutField08 = ''

         SET @nScn = @nScn - 3            --Area Screen
         SET @nStep = @nStep - 3          --Step 2
         GOTO QUIT
      END
      ELSE 
      BEGIN
	     IF @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')
         BEGIN
	        UPDATE dbo.TaskDetail WITH (ROWLOCK)
            SET Status = '0',
               ReasonKey = '',
               UserKey = '',
               EditDate = GETDATE(),
               EditWho = 'RDTPA'
            WHERE TaskDetailKey = @cTaskdetailKey

	        SET @cSuggID = ''
	     END

         SET @cOutField01 = @cSuggFromLoc --Suggested FromLoc
         SET @cOutField02 = @cSuggID  --Suggested FromID
         SET @cOutField03 = ''               --ID to be scanned
         SET @cOutField15 = ''               --Extended info
         
         SET @nScn =  @nScn - 2               --ID Screen
         SET @nStep = @nStep - 2              --Step 3
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Go back to Area Screen
      SET @cOutField01 = @cAreaKey  -- Area
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutField04 = ''
      SET @cOutField05 = ''
      SET @cOutField06 = ''
      SET @cOutField07 = ''
      SET @cOutField08 = ''

      SET @nScn = @nScn - 3            --Area Screen
      SET @nStep = @nStep - 3          --Step 2
   END

   GOTO Quit

   Step_5_Fail:
END
GOTO Quit


/********************************************************************************
Step 6. screen = 6595
     REASON CODE  (Field01, input)
********************************************************************************/
Step_6:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cReasonCode = @cInField01
      
      -- Check blank reason
      IF @cReasonCode = ''
      BEGIN
        SET @nErrNo = 237123
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reason Code is Needed
        GOTO Step_6_Fail
      END

      -- Extended validation
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        '              +
               '@nFunc           INT,        '              +
               '@cLangCode       NVARCHAR( 3),   '          +
               '@nStep           INT,        '              +
               '@nScn            INT,        '              +
               '@cAreaKey        NVARCHAR( 10),  '          +
               '@cID             NVARCHAR( 18),  '          +
               '@cToLoc          NVARCHAR( 10),  '          +
               '@cEquipmentProfileKey NVARCHAR( 10),  '     +
               '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
               '@cTaskdetailKey  NVARCHAR( 10),  '          +
               '@cReasonCode     NVARCHAR(10) '             +
               '@nErrNo          INT OUTPUT, '              +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'
   
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cFromID, @cToLoc, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @cReasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT
   
            IF @nErrNo <> 0
               GOTO Step_6_Fail
         END
      END

      DECLARE @cNewToLocIsFound NVARCHAR(1) = '0'

      -- Handling transaction
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdt_TM_PutawayFrom_RSN -- For rollback or commit only our own transaction

      BEGIN TRY
         -- Update ReasonCode
         EXEC dbo.nspRFRSN01
            @c_sendDelimiter = NULL
            ,@c_ptcid         = 'RDT'
            ,@c_userid        = @cUserName
            ,@c_taskId        = 'RDT'
            ,@c_databasename  = NULL
            ,@c_appflag       = NULL
            ,@c_recordType    = NULL
            ,@c_server        = NULL
            ,@c_ttm           = NULL
            ,@c_TaskDetailKey = @cTaskdetailKey
            ,@c_fromloc       = @cSuggFromLOC
            ,@c_fromid        = @cSuggID
            ,@c_toloc         = @cSuggToloc
            ,@c_toid          = @cSuggID
            ,@n_qty           = @nQTY
            ,@c_PackKey       = ''
            ,@c_uom           = ''
            ,@c_reasoncode    = @cReasonCode
            ,@c_outstring     = @c_outstring    OUTPUT
            ,@b_Success       = @b_Success      OUTPUT
            ,@n_err           = @nErrNo         OUTPUT
            ,@c_errmsg        = @cErrMsg        OUTPUT
            ,@c_userposition  = '2' -- 1=at from LOC, 2=at to LOC
         IF @b_Success = 0 OR @nErrNo <> 0
            GOTO Step_6_Fail

         -- Get task reason info
         DECLARE @cContinueProcess         NVARCHAR(10)
         DECLARE @cRemoveTaskFromUserQueue NVARCHAR(10)
         DECLARE @cTaskStatus              NVARCHAR(10)
         SELECT 
            @cContinueProcess = ContinueProcessing,
            @cRemoveTaskFromUserQueue = RemoveTaskFromUserQueue, 
            @cTaskStatus = TaskStatus,
            @cLOCHoldKey = LOCHoldKey,
            @cTaskToLoc = ToLoc
         FROM dbo.TaskManagerReason WITH (NOLOCK)
         WHERE TaskManagerReasonKey = @cReasonCode

         -- Get task info
         DECLARE @cTaskType NVARCHAR(10)
         SELECT @cTaskType = TaskType FROM TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey

         -- Update TaskDetail.Status
         IF @cTaskStatus <> ''
         BEGIN
            -- Skip task
            IF @cTaskStatus = '0'
            BEGIN
               -- Release current task
               UPDATE dbo.TaskDetail SET
                  UserKey = ''
                  ,ReasonKey = ''
                  ,Status = '0'
                  ,EditDate = GETDATE()
                  ,EditWho  = SUSER_SNAME()
                  ,TrafficCop = NULL
               WHERE StorerKey = @cStorerKey
                  AND TaskDetailKey = @cTaskDetailKey

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 237125
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdSkipTskFail
                  GOTO Step_6_Fail
               END
            END
            
            -- Cancel task
            IF @cTaskStatus IN ('9', 'X')
            BEGIN
               UPDATE dbo.TaskDetail WITH (ROWLOCK) SET
                  Status = @cTaskStatus
                  ,EditDate = GETDATE()
                  ,EditWho  = SUSER_SNAME()
                  ,TrafficCop = NULL
               WHERE TaskDetailKey = @cTaskDetailKey
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 237126
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdSkipTskFail
                  GOTO Step_6_Fail
               END

               -- Unlock SuggestedLOC
               IF @cSuggID <> ''
               BEGIN
                  EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                     ,'' --@cSuggFromLOC
                     ,@cSuggID 
                     ,'' --@cSuggToLoc
                     ,@cStorerKey
                     ,@nErrNo  OUTPUT
                     ,@cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Step_6_Fail
               END

               IF @cReasonCode = 'DMG STOCK'
               BEGIN
                  -- Execute move process
                  EXECUTE rdt.rdt_Move
                     @nMobile     = @nMobile,
                     @cLangCode   = @cLangCode, 
                     @nErrNo      = @nErrNo  OUTPUT,
                     @cErrMsg     = @cErrMsg OUTPUT, -- screen limitation, 20 char max
                     @cSourceType = 'rdt_TM_PutawayFrom_ReasonCode', 
                     @cStorerKey  = @cStorerKey,
                     @cFacility   = @cFacility, 
                     @cFromLOC    = @cSuggFromLOC, 
                     @cToLOC      = @cTaskToLoc, 
                     @cFromID     = @cSuggID, 
                     @cToID       = NULL,  -- NULL means not changing ID
                     @nFunc       = @nFunc
                  IF @nErrNo <> 0
                     GOTO Step_6_Fail
               END
            END
         END

         IF @cTaskStatus = '3'
         BEGIN
            IF @cContinueProcess <> '1'
            BEGIN 
               -- If exception happens in Step 4, need recalculate ToLoc
               IF @cToLOC = '99'
               BEGIN
                  -- Recalculate ToLoc
                  DECLARE 
                     @cToLocAreaKey          NVARCHAR(10),
                     @cToLocPutawayZone      NVARCHAR(10),
                     @nToLocLevel            INT,
					 @cToLocFloor            NVARCHAR(10)

                  IF @cSuggToLoc <> '' AND @cLOCHoldKey <> ''
                  BEGIN
                     -- Find a new ToLoc 
                     SELECT
                        @cLocCategory = LOC.LocationCategory,
                        @cLocAisle = LOC.LocAisle,
                        @cTaskDetailMsg01 = TD.Message01,  -- PutawayZone
                        @cTaskDetailMsg02 = TD.Message02,  -- LocationGroup
                        @cTaskDetailMsg03 = TD.Message03   -- LocationCategory
                     FROM dbo.TaskDetail TD WITH(NOLOCK)
                     INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.ToLoc = LOC.Loc
                     WHERE TD.StorerKey = @cStorerKey
                        AND LOC.Facility = @CFacility
                        AND TD.TaskDetailKey = @cTaskdetailKey

                     DECLARE @cNewToLoc NVARCHAR(10) = ''

                     -- a) If ToLoc is in the list of JCBBKTOLOC, search candidate location
                     IF EXISTS(SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK)
                              WHERE LISTNAME = 'JCBBKTOLOC'
                                 AND StorerKey = @cStorerKey
                                 AND Short = @cLocCategory)
                     BEGIN
                        SELECT TOP 1 @cNewToLoc = LOC.Loc
                           FROM dbo.LOC WITH(NOLOCK)
                        INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK)
                           ON LLI.Loc = LOC.Loc
                        WHERE Facility = @cFacility
                           AND LLI.StorerKey = @cStorerKey
                           AND LLI.Sku = @cSKU
                           AND LLI.Qty - LLI.QtyPicked > 0
                           AND LOC.Status = 'OK'
                           --AND LOC.LocAisle = @cLocAisle
                           AND LOC.PutawayZone = @cTaskDetailMsg01
                           AND LOC.LocationGroup = @cTaskDetailMsg02
                           AND LOC.LocationCategory = @cTaskDetailMsg03
                           AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
                           AND NOT EXISTS(SELECT 1 
                                       FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                                       WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                                          AND PAE.PutawayZone = LOC.PutawayZone
                                    )
                     END
                     -- b) If ToLoc is a PND location, search candidate location
                     ELSE IF @cLocCategory IN ('PND', 'PNDIN', 'PND_IN')
                     BEGIN
                        SELECT TOP 1 @cNewToLoc = LOC.Loc
                        FROM dbo.LOC WITH(NOLOCK)
                        WHERE LOC.Facility = @cFacility
                           AND LOC.Status = 'OK'
                           AND LOC.LocationCategory = @cLocCategory
                           AND LOC.LocAisle = @cLocAisle
                           AND LOC.Loc <> @cSuggToLoc
                           AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
                     END
                     -- c) If ToLoc is neither in the list of JCBBKTOLOC nor a PND location, search candidate location
                     -- Get a ToLoc, same Area, PutawayZone, Level ,Aisle
                     -- Beams must be empty
                     ELSE 
                     BEGIN
                        SELECT 
                           @cToLocAreaKey = AD.AreaKey,
                           @cToLocPutawayZone = LOC.PutawayZone,
                           @nToLocLevel = LOC.LocLevel,
                           @cToLocFloor = LOC.Floor
                        FROM dbo.LOC WITH(NOLOCK)
                        INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON LOC.PutawayZone = AD.PutawayZone
                        WHERE LOC.Facility = @cFacility
                           AND LOC.Loc = @cSuggToLoc

                        DECLARE @tEmptyLocBeam TABLE
                        (
                           RowIndex       INT IDENTITY(1,1) PRIMARY KEY,
                           LocationRoom   NVARCHAR(10)
                        )

                        INSERT INTO @tEmptyLocBeam (LocationRoom)
                        SELECT DISTINCT LocationRoom
                        FROM
                           (SELECT LocationRoom, SUM(LLI.QTY - LLI.QtyPicked) AS QTY
                           FROM dbo.LOC WITH(NOLOCK)
                           INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON LOC.PutawayZone = AD.PutawayZone
                           LEFT JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK) ON LOC.Loc = LLI.Loc
                           WHERE LOC.Facility = @cFacility
                              AND AD.AreaKey = @cToLocAreaKey
                              AND LOC.PutawayZone = @cToLocPutawayZone
                              AND LOC.LocLevel = @nToLocLevel
                              AND LOC.Floor = @cToLocFloor
                              AND LOC.Status = 'OK'
                              AND LOC.LocationRoom IS NOT NULL
                              AND LOC.LocationRoom <> ''
                           GROUP BY LOC.LocationRoom) AS T1
                        WHERE ISNULL(T1.QTY, 0) = 0
                        ORDER BY LocationRoom

                        SELECT TOP 1 @cNewToLoc = LOC.Loc
                        FROM dbo.LOC WITH(NOLOCK)
                        INNER JOIN dbo.AreaDetail AD WITH(NOLOCK) ON LOC.PutawayZone = AD.PutawayZone
                        LEFT JOIN dbo.PALLET P ON P.StorerKey = @cStorerKey AND P.PalletKey = @cSuggID
                        LEFT JOIN @tEmptyLocBeam EB ON LOC.LocationRoom = EB.LocationRoom
                        WHERE Facility = @cFacility
                           AND LOC.Loc <> @cSuggToLoc
                           AND AD.AreaKey = @cToLocAreaKey
                           AND Loc.PutawayZone = @cToLocPutawayZone
                           AND LOC.LocLevel <= @nToLocLevel
                           AND (LOC.Floor = @cToLocFloor OR LOC.LocationCategory <> 'VNA')
                           AND (LOC.LocAisle = @cLocAisle OR LOC.LocationCategory <> 'VNA')
                           AND LOC.Status = 'OK'
                           AND (EB.LocationRoom IS NOT NULL OR LOC.LocationCategory = 'VNA' OR ISNULL(P.PalletType,'') NOT LIKE 'D%')
                           AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
                           AND NOT EXISTS(SELECT 1 FROM dbo.LOTxLOCxID LLI (NOLOCK) 
                           WHERE LLI.Loc = LOC.Loc AND QTY-QtyPicked+PendingMoveIN > 0 
                           GROUP BY LLI.Loc HAVING COUNT(DISTINCT LLI.Id) >= LOC.MaxPallet)
                     END

                     -- i). If a location is found, go to ToLoc screen 
                     -- ii). If no location is found, prompt a new dialog to ask him to put the Pallet to QA location, find a new task
                     IF ISNULL(@cNewToLoc, '') <> ''
                     BEGIN
                        SET @cSuggToLoc = @cNewToLoc
                        SET @cNewToLocIsFound = '1'

                        UPDATE dbo.TaskDetail WITH(ROWLOCK) SET
                           ToLoc = @cSuggToLoc
                           ,ReasonKey = ''
                           ,EditDate = GETDATE()
                           ,EditWho  = SUSER_SNAME()
                           ,TrafficCop = NULL
                        WHERE TaskDetailKey = @cTaskDetailKey

                        IF @cSuggID <> ''
                        BEGIN
                           EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                              ,'' --@cSuggFromLOC
                              ,@cSuggID 
                              ,'' --@cSuggToLoc
                              ,@cStorerKey
                              ,@nErrNo  OUTPUT
                              ,@cErrMsg OUTPUT

                           IF @nErrNo <> 0
                              GOTO Step_6_Fail

                           EXEC rdt.rdt_Putaway_PendingMoveIn @cUserName, 'LOCK'
                              ,@cSuggFromLOC
                              ,@cSuggID
                              ,@cSuggToLoc
                              ,@cStorerKey
                              ,@nErrNo  OUTPUT
                              ,@cErrMsg OUTPUT
                           IF @nErrNo <> 0
                              GOTO Step_6_Fail
                        END
                     END
                     ELSE
                     BEGIN -- No location found, prompt a new dialog to ask him to put the Pallet to QA location
                        SET @cNewToLocIsFound = '0'

                        SET @cMsg01 = 'No suitable location'
                        SET @cMsg02 = 'is found, move it '
                        SET @cMsg03 = 'to QA location '
                        EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                           @nErrNo = @nErrNo,
                           @cErrMsg = @cErrMsg,
                           @cLine01 = @cMsg01,
                           @cLine02 = @cMsg02,
                           @cLine03 = @cMsg03,
                           @cLine04 = @cMsg04,
                           @cLine05 = @cMsg05,
                           @cLine06 = @cMsg06,
                           @cLine07 = @cMsg07,
                           @cLine08 = @cMsg08,
                           @cLine09 = @cMsg09,
                           @nDisplayMsg = 0

                        --Rollback the status, UserKey, ReasonKey if no ToLoc is found
                        UPDATE dbo.TaskDetail WITH(ROWLOCK) SET
                           Status = '9',
                           EditDate = GETDATE(),
                           EditWho  = SUSER_SNAME(),
                           TrafficCop = NULL
                        WHERE TaskDetailKey = @cTaskDetailKey

                        EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
                           ,'' --@cSuggFromLOC
                           ,@cSuggID 
                           ,'' --@cSuggToLoc
                           ,@cStorerKey
                           ,@nErrNo  OUTPUT
                           ,@cErrMsg OUTPUT
                     END
                  END
               END
            END
         END

         -- Extended update
         IF @cExtendedUpdateSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedUpdateSP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
               SET @cSQLParam =
                  '@nMobile         INT,        ' +
                  '@nFunc           INT,        ' +
                  '@cLangCode       NVARCHAR( 3),   ' +
                  '@nStep           INT,        ' +
                  '@nScn            INT,        ' +
                  '@cEquipmentProfileKey NVARCHAR( 10),' +
                  '@cNewEquipmentProfileKey NVARCHAR( 10),' +
                  '@cTaskdetailKey  NVARCHAR( 10),  ' +
                  '@nErrNo          INT OUTPUT, ' +
                  '@cErrMsg         NVARCHAR( 20) OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT
      
               IF @nErrNo <> 0
               BEGIN
                  GOTO Step_6_Fail
               END
            END
         END

         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN
      END TRY
      BEGIN CATCH
         ROLLBACK TRAN rdt_TM_PutawayFrom_RSN -- Only rollback change made here
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN

         SET @nErrNo = 237128
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update Reason Failed
      END CATCH

      IF @cTaskStatus = '3'
      BEGIN
         -- Continue process current task 
         IF @cContinueProcess = '1'
         BEGIN
            -- Back to ID screen
            IF @nFromStep = 3
            BEGIN
		       IF @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')
               BEGIN
	              UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET Status = '0',
                  ReasonKey = '',
                  UserKey = '',
                  EditDate = GETDATE(),
                  EditWho = 'RDTPA'
               WHERE TaskDetailKey = @cTaskdetailKey

	          SET @cSuggID = ''
	       END

               SET @cOutField01 = @cSuggFromLoc --Suggested FromLoc
               SET @cOutField02 = @cSuggID      --Suggested FromID
               SET @cOutField03 = ''               --ID to be scanned
               SET @cOutField15 = ''               --Extended info
            END

            -- Back to ToLOC screen
            IF @nFromStep = 4
            BEGIN
               SET @cOutField01 = @cSuggID
               SET @cOutField02 = @cSuggToLoc
               SET @cOutField03 = '' -- ToLOC
            END

            SET @nScn = @nFromScn
            SET @nStep = @nFromStep
         END
         ELSE
         BEGIN
            IF @cToLOC = '99'
            BEGIN
               -- If a new location is found, go to ToLoc screen
               IF @cNewToLocIsFound = '1'
               BEGIN
                  -- Go to ToLOC screen
                  SET @cOutField01 = @cSuggID
                  SET @cOutField02 = @cSuggToLoc
                  SET @cOutField03 = '' -- ToLOC

                  SET @cOutField04 = ''
                  SET @cOutField05 = ''
                  SET @cOutField06 = ''
                  SET @cOutField07 = ''
                  SET @cOutField08 = ''

                  -- If ToLoc is in the list of JCBBKTOLOC, search candidate locations
                  IF EXISTS(SELECT 1 FROM dbo.CODELKUP WITH(NOLOCK)
                           WHERE LISTNAME = 'JCBBKTOLOC'
                              AND StorerKey = @cStorerKey
                              AND Short = @cLocCategory)
                  BEGIN
                     DELETE FROM @tCandidateLoc

                     INSERT INTO @tCandidateLoc (Loc, Qty)
                     SELECT TOP 5 LOC.Loc, SUM(LLI.Qty - LLI.QtyPicked) AS TotalQty
                     FROM dbo.LOC WITH(NOLOCK)
                     INNER JOIN dbo.LOTXLOCXID LLI WITH(NOLOCK)
                        ON LLI.Loc = LOC.Loc
                     WHERE Facility = @cFacility
                        AND LLI.StorerKey = @cStorerKey
                        AND LLI.Sku = @cSKU
                        AND LOC.Loc <> @cSuggToLoc
                        AND LOC.Status = 'OK'
                        AND LOC.PutawayZone = @cTaskDetailMsg01
                        AND LOC.LocationGroup = @cTaskDetailMsg02
                        AND LOC.LocationCategory = @cTaskDetailMsg03
                        AND LOC.LocAisle = @cLocAisle
                        AND ISNULL(LOC.LocationFlag,'') IN ('','NONE')
                        AND NOT EXISTS(SELECT 1 
                                    FROM dbo.PAZoneEquipmentExcludeDetail PAE WITH(NOLOCK)
                                    WHERE PAE.EquipmentProfileKey = @cEquipmentProfileKey
                                       AND PAE.PutawayZone = LOC.PutawayZone
                                 )
                     GROUP BY LOC.Loc
                     ORDER BY SUM(LLI.Qty - LLI.QtyPicked) DESC, LOC.Loc

                     DECLARE 
                        @cSuggestToLocTemp       NVARCHAR(10),
                        @nRowIndexTemp           INT = 0

                     SET @nLoopIndex = -1
                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1
                           @cSuggestToLocTemp = Loc,
                           @nLoopIndex = RowIndex
                        FROM @tCandidateLoc
                        WHERE RowIndex > @nLoopIndex
                        ORDER BY RowIndex

                        SELECT @nRowCount = @@ROWCOUNT

                        IF @nRowCount = 0
                           BREAK

                        SET @nRowIndexTemp = @nRowIndexTemp + 1

                        SET @cOutField04 = IIF(@nRowIndexTemp = 1 , @cSuggestToLocTemp, @cOutField04)
                        SET @cOutField05 = IIF(@nRowIndexTemp = 2 , @cSuggestToLocTemp, @cOutField05)
                        SET @cOutField06 = IIF(@nRowIndexTemp = 3 , @cSuggestToLocTemp, @cOutField06)
                        SET @cOutField07 = IIF(@nRowIndexTemp = 4 , @cSuggestToLocTemp, @cOutField07)
                        SET @cOutField08 = IIF(@nRowIndexTemp = 5 , @cSuggestToLocTemp, @cOutField08)
                     END
                  END

                  SET @nScn = 6593
                  SET @nStep = 4
               END
               ELSE -- If no new location is found, go to Message screen, step 5
               BEGIN
                  -- Go to get a new task in Step 5
                  SET @nScn = 6594
                  SET @nStep = 5
               END
            END
            ELSE
            BEGIN -- Go to Area screen
               SET @cOutField01 = ''
               SET @cAreaKey = ''
               SET @nScn = 6591
               SET @nStep = 2
            END
         END
      END
      ELSE
      BEGIN
         -- Go to get a new task in Step 5
         SET @nScn = 6594
         SET @nStep = 5

         --GOTO GET_NEW_TASK -- Go to get a new task in Step 5
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Go to ID screen
      IF @nFromStep = 3
      BEGIN
	     IF @cAreaKey IN (SELECT Code FROM CODELKUP WITH(NOLOCK) WHERE Short = 1 AND Storerkey = @cStorerKey AND LISTNAME = 'JCBPAAREAR')
         BEGIN
	        UPDATE dbo.TaskDetail WITH (ROWLOCK)
            SET Status = '0',
               ReasonKey = '',
               UserKey = '',
               EditDate = GETDATE(),
               EditWho = 'RDTPA'
            WHERE TaskDetailKey = @cTaskdetailKey

	        SET @cSuggID = ''
	     END

         SET @cOutField01 = @cSuggFromLoc --Suggested FromLoc
         SET @cOutField02 = @cSuggID  --Suggested FromID
         SET @cOutField03 = ''               --ID to be scanned
         SET @cOutField15 = ''               --Extended info
      END
      
      -- Go to ToLOC screen
      IF @nFromStep = 4
      BEGIN
         SET @cOutField01 = @cSuggID
         SET @cOutField02 = @cSuggToLoc
         SET @cOutField03 = '' -- ToLOC
      END
      
      -- Back to prev screen
      SET @nScn = @nFromScn
      SET @nStep = @nFromStep
   END

   GOTO Quit

   Step_6_Fail:
   BEGIN
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         ROLLBACK TRAN
      -- Reset this screen var
      SET @cReasonCode = ''
      SET @cOutField01 = ''
      SELECT
         @cSuggToLoc = ToLOC
      FROM dbo.TaskDetail TD WITH(NOLOCK)
      WHERE TD.StorerKey = @cStorerKey
         AND TD.TaskDetailKey = @cTaskdetailKey
   END
END
GOTO Quit



/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE RDTMOBREC WITH (ROWLOCK) SET
      EditDate      = GETDATE(), 
      ErrMsg        = @cErrMsg,
      Func          = @nFunc,
      Step          = @nStep,
      Scn           = @nScn,

      StorerKey     = @cStorerKey,
      Facility      = @cFacility,
      Printer       = @cPrinter,
      -- UserName      = @cUserName,

      V_TaskDetailKey = @cTaskdetailKey,
      V_LOC         = @cSuggFromloc,
      V_ID          = @cSuggID,
      V_SKU         = @cSKU,
      V_QTY         = @nQTY,

      V_FromStep    = @nFromStep,
      V_FromScn     = @nFromScn,
   
      V_String1      = @cSuggToloc,
      V_String2      = @cExtendedValidateSP,
      V_String3      = @cExtendedInfoSP,
      V_String4      = @cExtendedUpdateSP,
      V_String5      = @cSwapTask,
      V_String6      = @cOverwriteToLOC, 
      V_String7      = @cDefaultFromLOC, 
      V_String8      = @cToLoc,
      V_String10     = @cExtScnSP,
      V_String11     = @cEquipmentProfileKey,
      
      V_String32     = @cAreakey,

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

      FieldAttr01  = @cFieldAttr01,   FieldAttr02  = @cFieldAttr02,
      FieldAttr03  = @cFieldAttr03,   FieldAttr04  = @cFieldAttr04,
      FieldAttr05  = @cFieldAttr05,   FieldAttr06  = @cFieldAttr06,
      FieldAttr07  = @cFieldAttr07,   FieldAttr08  = @cFieldAttr08,
      FieldAttr09  = @cFieldAttr09,   FieldAttr10  = @cFieldAttr10,
      FieldAttr11  = @cFieldAttr11,   FieldAttr12  = @cFieldAttr12,
      FieldAttr13  = @cFieldAttr13,   FieldAttr14  = @cFieldAttr14,
      FieldAttr15  = @cFieldAttr15

   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_TM_PutawayFrom_JCB TO NSQL
GO