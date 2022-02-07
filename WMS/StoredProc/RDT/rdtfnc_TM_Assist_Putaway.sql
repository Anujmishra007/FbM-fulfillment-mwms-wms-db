if exists (select * from sys.objects where object_id = object_id(N'[rdt].[rdtfnc_TM_Assist_Putaway]') and OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdtfnc_TM_Assist_Putaway]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO  
  
/************************************************************************/  
/* Store procedure: rdtfnc_TM_Assist_Putaway                            */  
/* Copyright      : LF Logistics                                        */  
/*                                                                      */  
/* Purpose: Putaway pallet to ASRS                                      */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author   Purposes                                    */  
/* 2015-03-05 1.0  Ung      Created SOS332730                           */  
/* 2019-09-12 1.1  Ung      WMS-10452 Add override LOC                  */  
/* 2019-10-03 1.2  James    WMS-10316 Clear Case ID when esc (james01)  */ 
/* 2020-08-17 1.3  YeeKung  WMS-14344 Fixed bugs (yeekung01)            */
/* 2021-10-21 1.4  Chermain WMS-17638 Add ExtUpd in st1 (cc01)          */
/************************************************************************/  
  
CREATE PROC [RDT].[rdtfnc_TM_Assist_Putaway] (  
   @nMobile    INT,  
   @nErrNo     INT  OUTPUT,  
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max  
) AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
  
-- Misc variable  
DECLARE  
   @nTranCount          INT,   
   @bSuccess            INT,   
   @cAreaKey            NVARCHAR( 10),  
   @cTTMStrategykey     NVARCHAR( 10),   
   @cNextTaskDetailKey  NVARCHAR( 10),  
   @cSQL                NVARCHAR( MAX),   
   @cSQLParam           NVARCHAR( MAX)  
  
-- RDT.RDTMobRec variable  
DECLARE  
   @nFunc               INT,  
   @nScn                INT,  
   @nStep               INT,  
   @cLangCode           NVARCHAR( 3),  
   @nInputKey           INT,  
   @nMenu               INT,  
  
   @cStorerKey          NVARCHAR( 15),  
   @cFacility           NVARCHAR( 5),  
   @cPrinter            NVARCHAR( 10),  
   @cUserName           NVARCHAR( 18),  
  
   @cFromID             NVARCHAR( 20), -- From ID  
   @cFromLOC            NVARCHAR( 10), -- From LOC  
   @cTaskDetailKey      NVARCHAR( 10),  
  
   @cTTMTaskType        NVARCHAR( 10),   
   @cSuggToLOC          NVARCHAR( 10), -- To LOC  
   @cPickAndDropLOC     NVARCHAR( 10), -- PND LOC  
  
   @cExtendedValidateSP NVARCHAR( 20),  
   @cExtendedUpdateSP   NVARCHAR( 20),  
   @cExtendedInfoSP     NVARCHAR( 20),  
   @cExtendedInfo       NVARCHAR( 20),  
   @cOverwriteToLOC     NVARCHAR( 20),   
   @cDefaultCursor      NVARCHAR( 1),
   @cFlowThruScreen     NVARCHAR( 1),
   @cGoToEndTask        NVARCHAR( 1),
  
   @nPABookingKey       INT,   
  
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
  
-- Load RDT.RDTMobRec  
SELECT  
   @nFunc            = Func,  
   @nScn             = Scn,  
   @nStep            = Step,  
   @nInputKey        = InputKey,  
   @nMenu            = Menu,  
   @cLangCode        = Lang_code,  
  
   @cStorerKey       = StorerKey,  
   @cFacility        = Facility,  
   @cUserName        = UserName,  
   @cPrinter         = Printer,  
  
   @cFromID          = V_ID,  
   @cFromLOC         = V_LOC,  
   @cTaskDetailKey   = V_TaskDetailKey,  
  
   @cAreakey            = V_String1,  
   @cTTMStrategykey     = V_String2,  
   @cTTMTaskType        = V_String3,  
   @cSuggToLOC          = V_String4,  
   @cPickAndDropLOC     = V_String5,  
  
   @cExtendedValidateSP = V_String20,  
   @cExtendedUpdateSP   = V_String21,  
   @cExtendedInfoSP     = V_String22,  
   @cExtendedInfo       = V_String23,  
   @cOverwriteToLOC     = V_String24, 
   @cDefaultCursor      = V_String25,
   @cFlowThruScreen     = V_String26,
   @cGoToEndTask        = V_String27,
  
   @nPABookingKey       = V_Integer1,  
     
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
  
FROM RDTMOBREC (NOLOCK)  
WHERE Mobile = @nMobile  
  
-- Redirect to respective screen  
IF @nFunc = 1815  
BEGIN  
   IF @nStep = 0 GOTO Step_0   -- Menu. Func = 1815  
   IF @nStep = 1 GOTO Step_1   -- Scn = 4070. From ID  
   IF @nStep = 2 GOTO Step_2   -- Scn = 4071. Sugg LOC, To LOC  
   IF @nStep = 3 GOTO Step_3   -- Scn = 4072. Message. Next task type  
END  
RETURN -- Do nothing if incorrect step  
  
  
/********************************************************************************  
Step 0. Initialize  
********************************************************************************/  
Step_0:  
BEGIN  
   -- Get task manager data  
   SET @cTaskDetailKey  = @cOutField06  
   SET @cAreaKey        = @cOutField07  
   SET @cTTMStrategyKey = @cOutField08  
  
   SET @nPABookingKey = 0  
   SET @cPickAndDropLOC = ''  
  
   -- Get task info  
   SELECT  
      @cTTMTaskType = TaskType,  
      @cStorerKey   = Storerkey,  
      @cFromID      = FromID,  
      @cFromLOC     = FromLOC,  
      @cSuggToLOC   = ToLOC  
   FROM dbo.TaskDetail WITH (NOLOCK)  
   WHERE TaskDetailKey = @cTaskDetailKey  

   SET @cDefaultCursor = rdt.rdtGetConfig( @nFunc, 'DefaultCursor', @cStorerKey)
   -- flow through step 1 (@cflowthruscreen)
   -- While scan palletid and need go back task assisted manager screen (@cGoToEndTask)
   SET @cFlowThruScreen = rdt.RDTGetConfig( @nFunc, 'FlowThruScreen', @cStorerKey) 
   SET @cGoToEndTask = rdt.RDTGetConfig( @nFunc, 'GoToEndTask', @cStorerKey) 
  
   -- Get storer configure  
   SET @cExtendedValidateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)  
   IF @cExtendedValidateSP = '0'  
      SET @cExtendedValidateSP = ''  
   SET @cOverwriteToLOC = rdt.rdtGetConfig( @nFunc, 'OverwriteToLOC', @cStorerKey)  
   IF @cOverwriteToLOC = '0'  
      SET @cOverwriteToLOC = ''  
      
   --(cc01)
   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)      
   IF @cExtendedUpdateSP = '0'      
      SET @cExtendedUpdateSP = ''  
  
   -- Suggest LOC  
   IF @cSuggToLOC = ''  
   BEGIN  
      -- Get suggest LOC  
      EXEC rdt.rdt_TM_Assist_Putaway_GetSuggestLOC @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility  
         ,@cTaskDetailKey  
         ,@cFromLOC  
         ,@cFromID  
         ,@cSuggToLOC      OUTPUT  
         ,@cPickAndDropLOC OUTPUT  
         ,@nPABookingKey   OUTPUT  
         ,@nErrNo          OUTPUT  
         ,@cErrMsg         OUTPUT  
      IF @nErrNo = -1 -- No suggested LOC  
      SET @nErrNo = 0  
   END  
  
   -- EventLog  
   EXEC RDT.rdt_STD_EventLog  
      @cActionType = '1', -- Sign-in  
      @cUserID     = @cUserName,  
      @nMobileNo   = @nMobile,  
      @nFunctionID = @nFunc,  
      @cFacility   = @cFacility,  
      @cStorerKey  = @cStorerkey  
  
   -- Prepare next screen var  
   SET @cOutField01 = @cFromID  
   SET @cOutField02 = CASE WHEN @cPickAndDropLOC = '' THEN @cSuggToLOC ELSE @cPickAndDropLOC END  
   SET @cOutField03 = '' -- FinalLOC  
  
   -- Set the entry point  
   SET @nScn  = 4070  
   SET @nStep = 1  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 1. Screen = 4070  
   ID           (Field01)  
   SUGGEST LOC  (Field02)  
   FINAL LOC    (Field03, input)  
********************************************************************************/  
Step_1:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      DECLARE @cToLOC NVARCHAR(10)  
        
      -- Screen mapping  
      SET @cToLOC = @cInField03  
  
      -- Check blank  
      IF @cToLOC = ''  
      BEGIN  
         SET @nErrNo = 51951  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC needed  
         GOTO Quit  
      END  
  
      -- Check LOC valid  
      IF NOT EXISTS( SELECT 1 FROM LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cToLOC)  
      BEGIN  
         SET @nErrNo = 51952  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LOC  
         SET @cOutField03 = '' -- FinalLOC  
         GOTO Quit  
      END  
  
      -- Check if suggested LOC match  
      IF (@cToLOC <> @cSuggToLOC AND @cPickAndDropLOC = '') OR      -- Not match suggested LOC  
         (@cToLOC <> @cPickAndDropLOC AND @cPickAndDropLOC <> '')   -- Not match PND LOC  
      BEGIN  
         IF @cOverwriteToLOC = '1'  
         BEGIN  
            SET @nErrNo = 51953  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOC Not Match  
            SET @cOutField03 = '' -- FinalLOC  
            GOTO Quit  
         END  
           
         ELSE IF @cOverwriteToLOC = '2'  
         BEGIN  
            -- Prepare next screen var  
            SET @cOutField01 = '' -- Option  
              
            -- Go to LOC not match screen  
            SET @nScn = @nScn + 1  
            SET @nStep = @nStep + 1  
              
            GOTO Quit  
         END  
      END  
  
      -- Extended validate  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,           ' +  
               '@nFunc           INT,           ' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,           ' +  
               '@nInputKey       INT,           ' +   
               '@cTaskdetailKey  NVARCHAR( 10), ' +  
               '@cToLOC       NVARCHAR( 10), ' +  
               '@nErrNo          INT OUTPUT,    ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT '  
     
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
     
            IF @nErrNo <> 0  
               GOTO Quit  
         END  
      END  
  
      -- Confirm task           
      EXEC rdt.rdt_TM_Assist_Putaway_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility  
         ,@cTaskDetailKey  
         ,@cFromLOC  
         ,@cFromID  
         ,@cSuggToLOC  
         ,@cPickAndDropLOC  
         ,@cToLOC  
         ,@nErrNo    OUTPUT  
         ,@cErrMsg   OUTPUT  
      IF @nErrNo <> 0  
         GOTO Quit  
  
      -- Get next task  
      SET @cNextTaskDetailKey = ''  
      SELECT TOP 1   
         @cNextTaskDetailKey = TaskDetailKey,  
         @cTTMTasktype = TaskType  
      FROM dbo.TaskDetail WITH (NOLOCK)  
         JOIN CodeLKUP WITH (NOLOCK) ON (ListName = 'RDTAstTask' AND Code = TaskType AND Code2 = @cFacility)  
      WHERE FromID = @cFromID  
         AND Status = '0'  
      ORDER BY TaskDetailKey  
        
      -- No task  
      IF @cNextTaskDetailKey = ''  
      BEGIN  
         -- EventLog  
         EXEC RDT.rdt_STD_EventLog  
            @cActionType = '9', -- Sign-out  
            @cUserID     = @cUserName,  
            @nMobileNo   = @nMobile,  
            @nFunctionID = @nFunc,  
            @cFacility   = @cFacility,  
            @cStorerKey  = @cStorerKey  
           
         -- Go back to assist task manager  
         SET @nFunc = 1814  
         SET @nScn = 4060  
         SET @nStep = 1  
  
         SET @cOutField01 = '' -- From ID  
         SET @cOutField02 = '' -- Case ID  
      END  
        
      -- Have next task  
      IF @cNextTaskDetailKey <> '' 
      BEGIN  
         SET @cTaskDetailKey = @cNextTaskDetailKey  
           
         -- Prepare next screen var  
         SET @cOutField01 = @cTTMTasktype  

         IF @cFlowThruScreen='1'  --(yeekung01)
         BEGIN
            IF @cGoToEndTask='1'
               SET @nInputKey=0

            GOTO STEP_3
         END
  
         -- Go to next task  
         SET @nScn  = @nScn + 2   --(yeekung01)
         SET @nStep = @nStep + 2   --(yeekung01) 
      END  
   END  
  
   IF @nInputKey = 0 -- ESC  
   BEGIN  
      -- Unlock current session suggested LOC  
      IF @nPABookingKey <> 0  
      BEGIN  
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'  
            ,'' --FromLOC  
            ,'' --FromID  
            ,'' --cSuggLOC  
            ,'' --Storer  
            ,@nErrNo  OUTPUT  
            ,@cErrMsg OUTPUT  
            ,@nPABookingKey = @nPABookingKey OUTPUT  
         IF @nErrNo <> 0    
            GOTO Quit  
           
         SET @nPABookingKey = 0  
      END  
      
      -- Extended Update  --(cc01)
      IF @cExtendedUpdateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,           ' +  
               '@nFunc           INT,           ' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,           ' +  
               '@nInputKey       INT,           ' +   
               '@cTaskdetailKey  NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@nErrNo          INT OUTPUT,    ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT '  
     
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
     
            IF @nErrNo <> 0  
               GOTO Quit  
         END  
      END  
        
      -- EventLog  
      EXEC RDT.rdt_STD_EventLog  
         @cActionType = '9', -- Sign-out  
         @cUserID     = @cUserName,  
         @nMobileNo   = @nMobile,  
         @nFunctionID = @nFunc,  
         @cFacility   = @cFacility,  
         @cStorerKey  = @cStorerKey  
  
      -- Go back to assist task manager  
      SET @nFunc = 1814  
      SET @nScn = 4060  
      SET @nStep = 1  

      IF ISNULL(@cDefaultCursor,'')<>0  --(yeekung01)
         EXEC rdt.rdtSetFocusField @nMobile, @cDefaultCursor          
      ELSE  
         EXEC rdt.rdtSetFocusField @nMobile, 2 
  
      SET @cOutField01 = ''  -- From ID  
      SET @cOutField02 = ''  -- Case ID  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 2. Scn = 4071.  
   LOC not match. Proceed?  
   1 = YES  
   2 = NO  
   OPTION (Input, Field01)  
********************************************************************************/  
Step_2:  
BEGIN  
   IF @nInputKey = 1  
   BEGIN  
      DECLARE @cOption NVARCHAR( 1)  
        
      SET @cOption = @cInField01  
  
      -- Check blank  
      IF @cOption = ''  
      BEGIN  
         SET @nErrNo = 51954  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option req  
         GOTO Quit  
      END  
        
      -- Check optin valid  
      IF @cOption NOT IN ('1', '2')  
      BEGIN  
         SET @nErrNo = 51955  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option  
         SET @cOutField01 = ''  
         GOTO Quit  
      END  
  
      IF @cOption = '1' -- YES  
      BEGIN  
         -- Confirm task           
         EXEC rdt.rdt_TM_Assist_Putaway_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility  
            ,@cTaskDetailKey  
            ,@cFromLOC  
            ,@cFromID  
            ,@cSuggToLOC  
            ,@cPickAndDropLOC  
            ,@cToLOC  
            ,@nErrNo    OUTPUT  
            ,@cErrMsg   OUTPUT  
         IF @nErrNo <> 0  
            GOTO Quit  
  
         -- Get next task  
         SET @cNextTaskDetailKey = ''  
         SELECT TOP 1   
            @cNextTaskDetailKey = TaskDetailKey,  
            @cTTMTasktype = TaskType  
         FROM dbo.TaskDetail WITH (NOLOCK)  
            JOIN CodeLKUP WITH (NOLOCK) ON (ListName = 'RDTAstTask' AND Code = TaskType AND Code2 = @cFacility)  
         WHERE FromID = @cFromID  
            AND Status = '0'  
         ORDER BY TaskDetailKey  
           
         -- No task  
         IF @cNextTaskDetailKey = ''  
         BEGIN  
            -- EventLog  
            EXEC RDT.rdt_STD_EventLog  
               @cActionType = '9', -- Sign-out  
               @cUserID     = @cUserName,  
               @nMobileNo   = @nMobile,  
               @nFunctionID = @nFunc,  
               @cFacility   = @cFacility,  
               @cStorerKey  = @cStorerKey  
              
            -- Go back to assist task manager  
            SET @nFunc = 1814  
            SET @nScn = 4060  
            SET @nStep = 1  
  
            SET @cOutField01 = '' -- From ID  
            SET @cOutField02 = '' -- Case ID  
         END  
           
         -- Have next task  
         IF @cNextTaskDetailKey <> ''  
         BEGIN  
            SET @cTaskDetailKey = @cNextTaskDetailKey  
              
            -- Prepare next screen var  
            SET @cOutField01 = @cTTMTasktype  
  
            -- Go to next task  
            SET @nScn  = @nScn + 1  
            SET @nStep = @nStep + 1  
         END  
      END  
  
      IF @cOption = '2' -- No  
      BEGIN  
         -- Prepare next screen var  
         SET @cOutField01 = @cFromID  
         SET @cOutField02 = CASE WHEN @cPickAndDropLOC = '' THEN @cSuggToLOC ELSE @cPickAndDropLOC END  
         SET @cOutField03 = ''  
  
         -- Go to Suggest LOC screen  
         SET @nScn  = @nScn - 1  
         SET @nStep = @nStep - 1  
      END  
   END  
  
   IF @nInputKey = 0 -- ESC  
   BEGIN  
      -- Prepare next screen var  
      SET @cOutField01 = @cFromID  
      SET @cOutField02 = CASE WHEN @cPickAndDropLOC = '' THEN @cSuggToLOC ELSE @cPickAndDropLOC END  
      SET @cOutField03 = ''  
  
      -- Go to Suggest LOC screen  
      SET @nScn  = @nScn - 1  
      SET @nStep = @nStep - 1  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 3. Screen 4072. Next task  
   Next task type (field01)  
********************************************************************************/  
Step_3:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      DECLARE @nToFunc INT  
      DECLARE @nToScn  INT  
      DECLARE @nToStep INT  
      SET @nToFunc = 0  
      SET @nToScn  = 0  
      SET @nToStep = 0  
  
      -- Check if function setup  
      SELECT   
         @nToFunc = Function_ID,   
         @nToStep = Step  
      FROM rdt.rdtTaskManagerConfig WITH (NOLOCK)   
      WHERE TaskType = @cTTMTaskType  
      IF @nToFunc = 0  
      BEGIN  
         SET @nErrNo = 51956  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NextTaskFncErr  
         GOTO Quit  
      END  
  
      -- Check if screen setup  
      SELECT TOP 1 @nToScn = Scn FROM RDT.RDTScn WITH (NOLOCK) WHERE Func = @nToFunc ORDER BY Scn  
      IF @nToScn = 0  
      BEGIN  
         SET @nErrNo = 51957  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NextTaskScnErr  
         GOTO Quit  
      END  
  
      -- Logging  
      EXEC RDT.rdt_STD_EventLog  
         @cActionType = '9', -- Sign Out function  
         @cUserID     = @cUserName,  
         @nMobileNo   = @nMobile,  
         @nFunctionID = @nFunc,  
         @cFacility   = @cFacility,  
         @cStorerKey  = @cStorerKey  
        
      SET @cOutField06 = @cTaskDetailKey  
      SET @cOutField07 = @cAreaKey  
      SET @cOutField08 = @cTTMStrategykey  
  
      SET @nFunc = @nToFunc  
      SET @nScn  = @nToScn  
      SET @nStep = @nToStep  
  
      IF @cTTMTaskType IN ('ASTPA')  
         GOTO Step_0  
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
         @cStorerKey  = @cStorerKey  
  
      -- Go back to assist task manager  
      SET @nFunc = 1814  
      SET @nScn = 4060  
      SET @nStep = 1  
  
      SET @cOutField01 = ''  -- From ID  
      SET @cOutField02 = ''  -- Case ID  

      IF ISNULL(@cDefaultCursor,'')<>0  --(yeekung01)
         EXEC rdt.rdtSetFocusField @nMobile, @cDefaultCursor          
      ELSE  
         EXEC rdt.rdtSetFocusField @nMobile, 2
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Quit. Update back to I/O table, ready to be pick up by JBOSS  
********************************************************************************/  
Quit:  
BEGIN  
   UPDATE RDTMOBREC WITH (ROWLOCK) SET  
      ErrMsg = @cErrMsg,  
      Func   = @nFunc,  
      Step   = @nStep,  
      Scn    = @nScn,  
  
      StorerKey = @cStorerKey,  
      Facility  = @cFacility,  
      UserName  = @cUserName,  
  
      V_ID      = @cFromID,  
      V_LOC     = @cFromLOC,  
      V_TaskDetailKey = @cTaskDetailKey,  
  
      V_String1 = @cAreakey,  
      V_String2 = @cTTMStrategykey,  
      V_String3 = @cTTMTaskType,        
      V_String4 = @cSuggToLOC,  
      V_String5 = @cPickAndDropLOC,  
  
      V_String20 = @cExtendedValidateSP,  
      V_String21 = @cExtendedUpdateSP,  
      V_String22 = @cExtendedInfoSP,  
      V_String23 = @cExtendedInfo,  
      V_String24 = @cOverwriteToLOC,  
    
      V_Integer1 = @nPABookingKey,   
   
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
  
   -- Execute TM module initialization (ung01)  
   IF (@nFunc <> 1815 AND @nStep = 0) AND -- Other module that begin with step 0  
      (@nFunc <> @nMenu)                  -- Not ESC from screen to menu  
   BEGIN  
      -- Get the stor proc to execute  
      DECLARE @cStoredProcName NVARCHAR( 1024)  
      SELECT @cStoredProcName = StoredProcName  
      FROM RDT.RDTMsg WITH (NOLOCK)  
      WHERE Message_ID = @nFunc  
  
      -- Execute the stor proc  
      SELECT @cStoredProcName = N'EXEC RDT.' + RTRIM(@cStoredProcName)  
      SELECT @cStoredProcName = RTRIM(@cStoredProcName) + ' @InMobile, @nErrNo OUTPUT,  @cErrMsg OUTPUT'  
      EXEC sp_executesql @cStoredProcName , N'@InMobile int, @nErrNo int OUTPUT,  @cErrMsg NVARCHAR(125) OUTPUT',  
         @nMobile,  
         @nErrNo OUTPUT,  
         @cErrMsg OUTPUT  
   END  
END  
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON RDT.rdtfnc_TM_Assist_Putaway TO NSQL
GO