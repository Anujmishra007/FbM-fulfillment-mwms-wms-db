if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdtfnc_JobCapture]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdtfnc_JobCapture]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Store procedure: rdtfnc_JobCapture                                   */  
/* Copyright      : LFLogistics                                         */  
/*                                                                      */  
/* Purpose: Serial no capture by ext orderkey + sku                     */  
/*                                                                      */  
/* Date        Rev  Author     Purposes                                 */  
/* 30-08-2018  1.0  Ung        WMS-6051 Created                         */  
/* 13-02-2019  1.1  James      WMS-7795 Add capture reference (james01) */  
/* 11-04-2019  1.2  James      WMS-8603 Enable capture reference field  */ 
/*                             repeatly until press esc (james02)       */
/* 02-07-2019  1.3  James      WMS-9493 Add display jobtype (james03)   */
/* 25-05-2021  1.4  Chermaine  WMS-17049 Add codelkup to validate       */
/*                             column in scn6 (cc01)                    */
/* 10-09-2020  1.5  YeeKung    WMS-15084 Change username and loc length */  
/*                             (yeekung01)                              */  
/* 27-07-2021 1.7  YeeKung   JSM-11627 go through step 1 to ref screen  */
/*                           (yeekung02)                                */  
/************************************************************************/  
  
CREATE PROC [RDT].[rdtfnc_JobCapture] (  
   @nMobile    INT,  
   @nErrNo     INT  OUTPUT,  
   @cErrMsg    NVARCHAR(1024) OUTPUT  
)  
AS  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
-- Misc var  
DECLARE  
   @nRowRef     INT,  
   @cSQL        NVARCHAR( MAX),   
   @cSQLParam   NVARCHAR( MAX)  
  
-- RDT.RDTMobRec variable  
DECLARE  
   @nFunc       INT,  
   @nScn        INT,  
   @nStep       INT,  
   @cLangCode   NVARCHAR( 3),  
   @cUserName   NVARCHAR( 10),  
   @nInputKey   INT,  
   @nMenu       INT,  
                  
   @cStorerKey  NVARCHAR( 15),  
   @cFacility   NVARCHAR( 5),  
                  
   @cUserID     NVARCHAR( 30),  --(yeekung01)  
   @cJobType    NVARCHAR( 20),   
   @cLOC        NVARCHAR( 30),   --(yeekung01)                   
   @cQTY        NVARCHAR( 5),  
   @cCaptureLOC NVARCHAR( 1),                     
   @cCaptureQTY NVARCHAR( 1),  
   @cStart      NVARCHAR( 10),  
   @cEnd        NVARCHAR( 10),  
   @cDuration   NVARCHAR( 5),  
   @cCaptureRF          NVARCHAR( 60),  
   @cRef01              NVARCHAR( 60),  
   @cRef02              NVARCHAR( 60),  
   @cRef03              NVARCHAR( 60),  
   @cRef04              NVARCHAR( 60),  
   @cRef05              NVARCHAR( 60),  
   @cUDF01              NVARCHAR( 60),  
   @cUDF02              NVARCHAR( 60),  
   @cUDF03              NVARCHAR( 60),  
   @cUDF04              NVARCHAR( 60),  
   @cUDF05              NVARCHAR( 60),  
   @cExtendedValidateSP NVARCHAR( 20),  
   @cColVlidate         NVARCHAR( 10), --(cc01)  
   @tVar                VariableTable,  
  
   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),    @cFieldAttr01 NVARCHAR( 1),  
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),    @cFieldAttr02 NVARCHAR( 1),  
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),    @cFieldAttr03 NVARCHAR( 1),  
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),    @cFieldAttr04 NVARCHAR( 1),  
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),    @cFieldAttr05 NVARCHAR( 1),  
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),    @cFieldAttr06 NVARCHAR( 1),  
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),    @cFieldAttr07 NVARCHAR( 1),  
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),    @cFieldAttr08 NVARCHAR( 1),  
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),    @cFieldAttr09 NVARCHAR( 1),  
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),    @cFieldAttr10 NVARCHAR( 1),  
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),    @cFieldAttr11 NVARCHAR( 1),  
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),    @cFieldAttr12 NVARCHAR( 1),  
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),    @cFieldAttr13 NVARCHAR( 1),  
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),    @cFieldAttr14 NVARCHAR( 1),  
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),    @cFieldAttr15 NVARCHAR( 1)  
  
-- Load RDT.RDTMobRec  
SELECT  
   @nFunc       = Func,  
   @nScn        = Scn,  
   @nStep       = Step,  
   @nInputKey   = InputKey,  
   @nMenu       = Menu,  
   @cLangCode   = Lang_code,  
   @cUserName   = UserName,  
                  
   @cStorerKey  = StorerKey,  
   @cFacility   = Facility,  
  
   @cUserID     = V_String1,  
   @cJobType    = V_String2,      
   @cLOC        = V_String3,                         
   @cQTY        = V_String4,  
   @cCaptureLOC = V_String5,                         
   @cCaptureQTY = V_String6,  
   @cStart      = V_String7,  
   @cEnd        = V_String8,  
   @cDuration   = V_String9,   
   @cExtendedValidateSP = V_String10,   
   @cCaptureRF  = V_String11,   

   @cUDF01 =  V_String12,
   @cUDF02 =  V_String13,
   @cUDF03 =  V_String14,
   @cUDF04 =  V_String15,
   @cUDF05 =  V_String16,
   @cColVlidate =  V_String17, --(cc01)

   @cRef01 =  V_String41,  
   @cRef02 =  V_String42,  
   @cRef03 =  V_String43,  
   @cRef04 =  V_String44,  
   @cRef05 =  V_String45,  

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,  @cFieldAttr01 = FieldAttr01,  
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,  @cFieldAttr02 = FieldAttr02,  
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,  @cFieldAttr03 = FieldAttr03,  
   @cInField04 = I_Field04,   @cOutField04 = O_Field04,  @cFieldAttr04 = FieldAttr04,  
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,  @cFieldAttr05 = FieldAttr05,  
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,  @cFieldAttr06 = FieldAttr06,  
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,  @cFieldAttr07 = FieldAttr07,  
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,  @cFieldAttr08 = FieldAttr08,   
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,  @cFieldAttr09 = FieldAttr09,  
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,  @cFieldAttr10 = FieldAttr10,  
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,  @cFieldAttr11 = FieldAttr11,  
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,  @cFieldAttr12 = FieldAttr12,  
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,  @cFieldAttr13 = FieldAttr13,  
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,  @cFieldAttr14 = FieldAttr14,  
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,  @cFieldAttr15 = FieldAttr15  
     
FROM rdt.RDTMOBREC (NOLOCK)  
WHERE Mobile = @nMobile  
  
IF @nFunc = 705 -- Job capture  
BEGIN  
   -- Redirect to respective screen  
   IF @nStep = 0 GOTO Step_0   -- Func = 705  
   IF @nStep = 1 GOTO Step_1   -- 5220 UserID  
   IF @nStep = 2 GOTO Step_2   -- 5221 JobType  
   IF @nStep = 3 GOTO Step_3   -- 5222 LOC  
   IF @nStep = 4 GOTO Step_4   -- 5223 QTY  
   IF @nStep = 5 GOTO Step_5   -- 5224 Confirm job end?  
   IF @nStep = 6 GOTO Step_6   -- 5225 Ref  
END  
  
RETURN -- Do nothing if incorrect step  
  
  
/********************************************************************************  
Step 0. func = 705. Menu  
********************************************************************************/  
Step_0:  
BEGIN  
   SET @cExtendedValidateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)  
   IF @cExtendedValidateSP = '0'  
      SET @cExtendedValidateSP = ''  
  
   SET @cFieldAttr02 = ''
   SET @cFieldAttr04 = ''
   SET @cFieldAttr06 = ''
   SET @cFieldAttr08 = ''
   SET @cFieldAttr10 = ''

   SET @cUserID = ''

   -- Set the entry point  
   SET @nScn = 5220  
   SET @nStep = 1  
  
   -- Prepare next screen var  
   SET @cOutField01 = '' -- User ID  
  
   -- EventLog  
   EXEC RDT.rdt_STD_EventLog  
      @cActionType = '1', -- Sign-in  
      @cUserID     = @cUserName,  
      @nMobileNo   = @nMobile,  
      @nFunctionID = @nFunc,  
      @cFacility   = @cFacility,  
      @cStorerKey  = @cStorerkey  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 1. Screen = 5220  
   User ID  (Field01, input)  
********************************************************************************/  
Step_1:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cUserID = @cInField01  
  
      -- Check blank  
      IF @cUserID = ''  
      BEGIN  
         SET @nErrNo = 128501  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need UserID  
         GOTO Quit  
      END  

      -- Clear variable here, user might not go back to menu screen 
      -- before start using with another user id
      SET @cJobType = ''
      SET @cLOC = ''
      SET @cQTY = ''
      SET @cRef01 = ''
      SET @cRef02 = ''
      SET @cRef03 = ''
      SET @cRef04 = ''
      SET @cRef05 = ''
      SET @cFieldAttr02 = ''
      SET @cFieldAttr04 = ''
      SET @cFieldAttr06 = ''
      SET @cFieldAttr08 = ''
      SET @cFieldAttr10 = ''

      -- Get user info  
      DECLARE @cStatus NVARCHAR(10)  
      SELECT @cStatus = Short  
      FROM CodeLKUP WITH (NOLOCK)  
      WHERE ListName = 'JOBCapUser'  
         AND Code = @cUserID  
         AND StorerKey = @cStorerKey  
         AND Code2 = @cFacility  
  
      -- Check order valid  
      IF @@ROWCOUNT = 0  
      BEGIN  
         SET @nErrNo = 128502  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid UserID  
         SET @cOutField01 = ''  
         GOTO Quit  
      END  
  
      -- Check status  
      IF @cStatus = '9'  
      BEGIN  
         SET @nErrNo = 128503  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inactive user  
         EXEC rdt.rdtSetFocusField @nMobile, 1 -- Order  
         SET @cOutField01 = ''  
         GOTO Quit  
      END  
  
      -- Get job info  
      SELECT   
         @nRowRef = RowRef,   
         @cJobType = TaskCode,   
         @cLOC = Location,  
         @cQTY = QTY,   
         @cStatus = Status  
      FROM rdt.rdtWATLog WITH (NOLOCK)  
      WHERE Module = 'JOBCAPTURE'  
         AND UserName = @cUserID  
         AND StorerKey = @cStorerKey  
         AND Facility = @cFacility  
         AND Status = '0'  
  
      -- Job start  
      IF @@ROWCOUNT = 0  
      BEGIN  
         -- Prep next screen var  
         SET @cOutField01 = @cUserID  
         SET @cOutField02 = '' -- JobType  
  
         SET @nScn = @nScn + 1  
         SET @nStep = @nStep + 1  
      END  
      ELSE  
      BEGIN  
         -- Get job info  
         DECLARE @cShort NVARCHAR(10)  
         SELECT   
            @cCaptureQTY = UDF02,   
            @cCaptureRF = UDF03,  
            @cShort = ISNULL( Short, '')  
         FROM CodeLKUP WITH (NOLOCK)  
         WHERE ListName = 'JOBCapType'  
            AND Code = @cJobType  
            AND StorerKey = @cStorerKey  
            AND Code2 = @cFacility  
  
         IF @cCaptureQTY = '1'  
         BEGIN  
            -- Prep next screen var  
            SET @cOutField01 = @cUserID  
            SET @cOutField02 = @cJobType  
            SET @cOutField03 = @cLOC  
            SET @cOutField04 = '' -- QTY  
  
            SET @nScn = @nScn + 3  
            SET @nStep = @nStep + 3  

            GOTO Quit
         END  
         ELSE IF @cCaptureRF = '1'
         BEGIN
            -- If already scanned some ucc then ask need end job or not
            --IF EXISTS ( SELECT 1 FROM rdt.RDTSTDEVENTLOG WITH (NOLOCK)
            --            WHERE RefNo1 = CAST( @nRowRef AS NVARCHAR( 10))
            --            AND   RefNo2 = @cJobType
            --            AND   Status < '9'
            --            AND   StorerKey = @cStorerKey
            --            AND   Facility = @cFacility
            --            AND   FunctionId = @nFunc
            --            AND   UCC <> '')
            IF EXISTS ( SELECT 1
                        FROM rdt.rdtWATLog WITH (NOLOCK)
                        WHERE Module = 'JOBCAPTURE'
                        AND   UserName = @cUserID
                        AND   StorerKey = @cStorerKey
                        AND   Facility = @cFacility
                        AND   TaskCode = @cJobType
                        AND   Status = '0'
                        AND   (udf01 <>''
                        OR     udf02<>''
                        OR     udf03<>''
                        OR     udf04<>''
                        OR     udf05<>''))--(yeekung02)
            BEGIN
               -- Confirm job end  
               IF CHARINDEX( 'C', @cShort) > 0  
               BEGIN  
                  -- Prep next screen var  
                  SET @cOutField01 = '' -- Option  
                  SET @cOutField02 = @cJobType
  
                  SET @nScn = @nScn + 4  
                  SET @nStep = @nStep + 4  
               END  
               ELSE  
               BEGIN  
                  -- Confirm  
                  EXEC rdt.rdt_JobCapture_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 'END',   
                     @cUserID   = @cUserID,   
                     @cJobType  = @cJobType,   
                     @cQTY      = @cQTY,   
                     @cLOC      = @cLOC,   
                     @cStart    = @cStart    OUTPUT,   
                     @cEnd      = @cEnd      OUTPUT,   
                     @cDuration = @cDuration OUTPUT,   
                     @nErrNo    = @nErrNo    OUTPUT,   
                     @cErrMsg   = @cErrMsg   OUTPUT  
                  IF @nErrNo <> 0  
                     GOTO Quit  
  
                  -- Prep next screen var  
                  SET @cOutField01 = '' --  UserID  
                  SET @cOutField02 = @cStart  
                  SET @cOutField03 = @cEnd  
                  SET @cOutField04 = @cDuration 
                  SET @cOutField05 = @cJobType 
               END  

               GOTO Quit
            END
            
            -- Nothing scanned b4 then straight go to scan ucc
            SELECT  
               @cUDF01 = UDF01,   
               @cUDF02 = UDF02,   
               @cUDF03 = UDF03,   
               @cUDF04 = UDF04,   
               @cUDF05 = UDF05,
               @cColVlidate = short  --(cc01)  
            FROM dbo.CodeLKUP WITH (NOLOCK)  
            WHERE ListName = 'JOBCapCol'  
            AND   Code = @cJobType  
            AND   StorerKey = @cStorerKey  
            AND   Code2 = @cFacility  
  
            IF ISNULL( @cUDF01, '') = '' AND   
               ISNULL( @cUDF02, '') = '' AND  
               ISNULL( @cUDF03, '') = '' AND  
               ISNULL( @cUDF04, '') = '' AND  
               ISNULL( @cUDF05, '') = ''   
            BEGIN  
               SET @nErrNo = 128510  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Setup Column  
               SET @cOutField02 = ''  
               GOTO Quit  
            END  
  
            -- Prepare next screen var  
            SET @cOutField01 = @cUDF01  
            SET @cOutField02 = ''  
            SET @cOutField03 = @cUDF02  
            SET @cOutField04 = ''  
            SET @cOutField05 = @cUDF03  
            SET @cOutField06 = ''  
            SET @cOutField07 = @cUDF04  
            SET @cOutField08 = ''  
            SET @cOutField09 = @cUDF05  
            SET @cOutField10 = ''  
  
            -- Enable / disable field  
            SET @cFieldAttr02 = CASE WHEN ISNULL( @cUDF01, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr04 = CASE WHEN ISNULL( @cUDF02, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr06 = CASE WHEN ISNULL( @cUDF03, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr08 = CASE WHEN ISNULL( @cUDF04, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr10 = CASE WHEN ISNULL( @cUDF05, '') = '' THEN 'O' ELSE '' END  
  
            SET @nScn = @nScn + 5  
            SET @nStep = @nStep + 5  
  
            GOTO Quit  
         END       
         ELSE  
         BEGIN  
            -- Confirm job end  
            IF CHARINDEX( 'C', @cShort) > 0  
            BEGIN  
               -- Prep next screen var  
               SET @cOutField01 = '' -- Option  
               SET @cOutField02 = @cJobType
  
               SET @nScn = @nScn + 4  
               SET @nStep = @nStep + 4  
            END  
            ELSE  
            BEGIN  
               -- Confirm  
               EXEC rdt.rdt_JobCapture_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 'END',   
                  @cUserID   = @cUserID,   
                  @cJobType  = @cJobType,   
                  @cQTY      = @cQTY,   
                  @cLOC      = @cLOC,   
                  @cStart    = @cStart    OUTPUT,   
                  @cEnd      = @cEnd      OUTPUT,   
                  @cDuration = @cDuration OUTPUT,   
                  @nErrNo    = @nErrNo    OUTPUT,   
                  @cErrMsg   = @cErrMsg   OUTPUT  
               IF @nErrNo <> 0  
                  GOTO Quit  
  
               -- Prep next screen var  
               SET @cOutField01 = '' --  UserID  
               SET @cOutField02 = @cStart  
               SET @cOutField03 = @cEnd  
               SET @cOutField04 = @cDuration  
               SET @cOutField05 = @cJobType  
            END  
         END  
      END  
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
       @cStorerKey  = @cStorerkey  
  
      -- Back to menu  
      SET @nFunc = @nMenu  
      SET @nScn  = @nMenu  
      SET @nStep = 0  
      SET @cOutField01 = '' -- Clean up for menu option  
   END  
   GOTO Quit  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 2. Screen = 5221  
   USER ID  (Field01)  
   JOB TYPE (Field02, input)  
********************************************************************************/  
Step_2:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cJobType = @cInField02  
  
      -- Check blank  
      IF @cJobType = ''  
      BEGIN  
         SET @nErrNo = 128504  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need JobType  
         SET @cOutField02 = ''  
         GOTO Quit  
      END  
  
      -- Get job info  
      SELECT   
         @cCaptureLOC = UDF01,  
         @cCaptureQTY = UDF02,  
         @cCaptureRF = UDF03  
      FROM CodeLKUP WITH (NOLOCK)  
      WHERE ListName = 'JOBCapType'  
         AND Code = @cJobType  
         AND StorerKey = @cStorerKey  
         AND Code2 = @cFacility  
  
      -- Check SKU valid  
      IF @@ROWCOUNT = 0  
      BEGIN  
         SET @nErrNo = 128505  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidJobType  
         SET @cOutField02 = ''  
         GOTO Quit  
      END  
  
      -- Extended validate  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            INSERT INTO @tVar (Variable, Value) VALUES   
               ('@cUserID',      @cUserID),   
               ('@cJobType',     @cJobType),   
               ('@cQTY',         @cQTY),   
               ('@cLOC',         @cLOC),   
               ('@cStart',       @cStart),  
               ('@cEnd',         @cEnd),  
               ('@cDuration',    @cDuration),  
               ('@cRef01',       @cRef01),  
               ('@cRef02',       @cRef02),  
               ('@cRef03',       @cRef03),  
               ('@cRef04',       @cRef04),  
               ('@cRef05',       @cRef05)  
  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @tVar, @nErrNo OUTPUT, @cErrMsg OUTPUT'   
            SET @cSQLParam =  
               '@nMobile         INT,           ' +  
               '@nFunc           INT,           ' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,           ' +  
               '@nInputKey       INT,           ' +   
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cFacility       NVARCHAR( 5),  ' +  
               '@tVar            VariableTable READONLY, ' +   
               '@nErrNo          INT           OUTPUT,   ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT    '  
     
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @tVar, @nErrNo OUTPUT, @cErrMsg OUTPUT  
     
            IF @nErrNo <> 0  
            BEGIN  
               SET @cOutField02 = ''  
               GOTO Quit  
            END  
         END  
      END  

      IF @cCaptureLOC = '1'  
      BEGIN  
         -- Prepare next screen var  
         SET @cOutField01 = @cUserID  
         SET @cOutField02 = @cJobType  
         SET @cOutField03 = '' -- LOC  
  
         SET @nScn = @nScn + 1  
         SET @nStep = @nStep + 1  
  
         GOTO Quit  
      END  

      -- Confirm  
      EXEC rdt.rdt_JobCapture_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 'START',   
         @cUserID   = @cUserID,   
         @cJobType  = @cJobType,   
         @cStart    = @cStart    OUTPUT,   
         @cEnd      = @cEnd      OUTPUT,   
         @cDuration = @cDuration OUTPUT,   
         @nErrNo    = @nErrNo    OUTPUT,   
         @cErrMsg   = @cErrMsg   OUTPUT,  
         @cRef01    = @cRef01,  
         @cRef02    = @cRef02,  
         @cRef03    = @cRef03,  
         @cRef04    = @cRef04,  
         @cRef05    = @cRef05  
  
      IF @nErrNo <> 0  
         GOTO Quit 

      -- Prepare next screen var  
      SET @cOutField01 = '' -- UserID  
      SET @cOutField02 = @cStart  
      SET @cOutField03 = @cEnd  
      SET @cOutField04 = @cDuration  
      SET @cOutField05 = @cJobType  
  
      SET @nScn = @nScn - 1  
      SET @nStep = @nStep - 1  
   END  
  
   IF @nInputKey = 0 -- ESC  
   BEGIN  
      -- Prepare next screen var  
      SET @cOutField01 = '' -- UserID  
      SET @cOutField02 = @cStart  
      SET @cOutField03 = '' -- End  
      SET @cOutField04 = '' -- Duration  
  
      SET @nScn = @nScn - 1                  
      SET @nStep = @nStep - 1                  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 3. Screen = 5222. LOC  
   USER ID  (Field01)  
   JOB TYPE (Field02)  
   LOC      (Field03, input)  
********************************************************************************/  
Step_3:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cLOC = @cInField03  
  
      -- Check blank  
      IF @cLOC = ''  
      BEGIN  
         SET @nErrNo = 128506  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need LOC  
         SET @cOutField03 = ''  
         GOTO Quit  
      END  
  
      -- Check LOC valid  
      IF NOT EXISTS( SELECT TOP 1 1  
         FROM CodeLKUP WITH (NOLOCK)  
         WHERE ListName = 'JOBCapLOC'  
            AND Code = @cLOC  
            AND StorerKey = @cStorerKey  
            AND Code2 = @cFacility)  
      BEGIN  
         SET @nErrNo = 128507  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LOC  
         SET @cOutField03 = ''  
         GOTO Quit  
      END  

      -- Confirm
      EXEC rdt.rdt_JobCapture_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 'START', 
         @cUserID   = @cUserID, 
         @cJobType  = @cJobType, 
         @cLOC      = @cLOC, 
         @cStart    = @cStart    OUTPUT, 
         @cEnd      = @cEnd      OUTPUT, 
         @cDuration = @cDuration OUTPUT, 
         @nErrNo    = @nErrNo    OUTPUT, 
         @cErrMsg   = @cErrMsg   OUTPUT

      IF @nErrNo <> 0
         GOTO Quit

      -- Prepare next screen var  
      SET @cOutField01 = '' -- UserID  
      SET @cOutField02 = @cStart  
      SET @cOutField03 = @cEnd  
      SET @cOutField04 = @cDuration  
      SET @cOutField05 = @cJobType
  
      SET @nScn = @nScn - 2  
      SET @nStep = @nStep - 2  
   END  
  
   IF @nInputKey = 0 -- ESC  
   BEGIN  
      -- Prepare next screen var  
      SET @cOutField01 = @cUserID  
      SET @cOutField02 = '' -- JobType  
  
      SET @nScn  = @nScn - 1  
      SET @nStep = @nStep - 1  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 4. Screen = 5223. QTY  
   USER ID  (Field01)  
   JOB TYPE (Field02)  
   LOC      (Field03)  
   QTY      (Field04, input)  
********************************************************************************/  
Step_4:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cQTY = @cInField04  
  
      -- Check blank  
      IF @cQTY = ''  
      BEGIN  
         SET @nErrNo = 128508  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need QTY  
         GOTO Quit  
      END  
  
      -- Check QTY valid  
      IF rdt.rdtIsValidQty( @cQTY, 1) = 0  
      BEGIN  
         SET @nErrNo = 128509  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY  
         GOTO Quit  
      END  
  
      -- Confirm  
      EXEC rdt.rdt_JobCapture_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 'END',   
         @cUserID   = @cUserID,   
         @cJobType  = @cJobType,   
         @cQTY      = @cQTY,   
         @cLOC      = @cLOC,   
         @cStart    = @cStart    OUTPUT,   
         @cEnd      = @cEnd      OUTPUT,   
         @cDuration = @cDuration OUTPUT,   
         @nErrNo    = @nErrNo    OUTPUT,   
         @cErrMsg   = @cErrMsg   OUTPUT  
      IF @nErrNo <> 0  
         GOTO Quit  
  
      -- Prepare next screen var  
      SET @cOutField01 = '' -- UserID  
      SET @cOutField02 = @cStart  
      SET @cOutField03 = @cEnd  
      SET @cOutField04 = @cDuration  
      SET @cOutField05 = @cJobType  
  
      SET @nScn = @nScn - 3  
      SET @nStep = @nStep - 3  
   END  
  
   IF @nInputKey = 0 -- ESC  
   BEGIN  
      -- Prepare next screen var  
      SET @cOutField01 = '' -- User ID  
      SET @cOutField02 = @cStart  
      SET @cOutField03 = '' -- End  
      SET @cOutField04 = '' -- Duration  
        
      -- Go back SKU screen  
      SET @nScn  = @nScn - 3  
      SET @nStep = @nStep - 3  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 5. Screen = 5224  
   CONFIRM JOB END?  
   OPTION (Field01, input)  
********************************************************************************/  
Step_5:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      DECLARE @cOption NVARCHAR(1)  
  
      -- Screen mapping  
      SET @cOption = @cInField01  
  
      -- Check blank  
      IF @cOption = ''  
      BEGIN  
         SET @nErrNo = 128504  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need option  
         GOTO Quit  
      END  
  
      -- Check option valid  
      IF @cOption NOT IN ('1', '9')  
      BEGIN  
         SET @nErrNo = 128505  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid option  
         SET @cOutField01 = ''  
         GOTO Quit  
      END  
  
      IF @cOption = '1' -- YES  
      BEGIN  
         -- Confirm  
         EXEC rdt.rdt_JobCapture_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 'END',   
            @cUserID   = @cUserID,   
            @cJobType  = @cJobType,   
            @cQTY      = @cQTY,   
            @cLOC      = @cLOC,   
            @cStart    = @cStart    OUTPUT,   
            @cEnd      = @cEnd      OUTPUT,   
            @cDuration = @cDuration OUTPUT,   
            @nErrNo    = @nErrNo    OUTPUT,   
            @cErrMsg   = @cErrMsg   OUTPUT  
         IF @nErrNo <> 0  
            GOTO Quit  
  
         -- Prepare next screen var  
         SET @cOutField01 = '' -- UserID  
         SET @cOutField02 = @cStart  
         SET @cOutField03 = @cEnd  
         SET @cOutField04 = @cDuration  
         SET @cOutField05 = @cJobType
  
         SET @nScn = @nScn - 4  
         SET @nStep = @nStep - 4  
  
         GOTO Quit  
      END 
      
      IF @cOption = '9'
      BEGIN
         SELECT   
            @cCaptureRF = UDF03
         FROM CodeLKUP WITH (NOLOCK)  
         WHERE ListName = 'JOBCapType'  
            AND Code = @cJobType  
            AND StorerKey = @cStorerKey  
            AND Code2 = @cFacility  

         IF ISNULL( @cCaptureRF, '') = '1'  
         BEGIN  
            SELECT  
               @cUDF01 = UDF01,   
               @cUDF02 = UDF02,   
               @cUDF03 = UDF03,   
               @cUDF04 = UDF04,   
               @cUDF05 = UDF05,
               @cColVlidate = short  --(cc01)    
            FROM dbo.CodeLKUP WITH (NOLOCK)  
            WHERE ListName = 'JOBCapCol'  
            AND   Code = @cJobType  
            AND   StorerKey = @cStorerKey  
            AND   Code2 = @cFacility  
  
            IF ISNULL( @cUDF01, '') = '' AND   
               ISNULL( @cUDF02, '') = '' AND  
               ISNULL( @cUDF03, '') = '' AND  
               ISNULL( @cUDF04, '') = '' AND  
               ISNULL( @cUDF05, '') = ''   
            BEGIN  
               SET @nErrNo = 128510  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Setup Column  
               SET @cOutField02 = ''  
               GOTO Quit  
            END  
  
            -- Prepare next screen var  
            SET @cOutField01 = @cUDF01  
            SET @cOutField02 = ''  
            SET @cOutField03 = @cUDF02  
            SET @cOutField04 = ''  
            SET @cOutField05 = @cUDF03  
            SET @cOutField06 = ''  
            SET @cOutField07 = @cUDF04  
            SET @cOutField08 = ''  
            SET @cOutField09 = @cUDF05  
            SET @cOutField10 = ''  
  
            -- Enable / disable field  
            SET @cFieldAttr02 = CASE WHEN ISNULL( @cUDF01, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr04 = CASE WHEN ISNULL( @cUDF02, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr06 = CASE WHEN ISNULL( @cUDF03, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr08 = CASE WHEN ISNULL( @cUDF04, '') = '' THEN 'O' ELSE '' END  
            SET @cFieldAttr10 = CASE WHEN ISNULL( @cUDF05, '') = '' THEN 'O' ELSE '' END  
  
            SET @nScn = @nScn + 1  
            SET @nStep = @nStep + 1  
  
            GOTO Quit  
         END       
      END 
   END  
  
   -- Prepare next screen var  
   SET @cOutField01 = '' -- User ID  
   SET @cOutField02 = @cStart  
   SET @cOutField03 = '' -- End  
   SET @cOutField04 = '' -- Duration  
  
   SET @nScn = @nScn - 4                  
   SET @nStep = @nStep - 4                  
  
END  
GOTO Quit  
  
/********************************************************************************  
Step 6. Screen = 5225. Ref  
   Reference field  (Field01, input)  
********************************************************************************/  
Step_6:  
BEGIN  
   IF @nInputKey = 1 -- ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cRef01 = @cInField02  
      SET @cRef02 = @cInField04  
      SET @cRef03 = @cInField06  
      SET @cRef04 = @cInField08  
      SET @cRef05 = @cInField10  
  
      -- Check blank  
      IF ISNULL( @cRef01, '') = '' AND   
         ISNULL( @cRef02, '') = '' AND  
         ISNULL( @cRef03, '') = '' AND  
         ISNULL( @cRef04, '') = '' AND  
         ISNULL( @cRef05, '') = ''   
      BEGIN  
         SET @nErrNo = 128511  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Value Required  
         SET @cOutField02 = ''  
         GOTO Quit  
      END  
      
      --(cc01)
      IF @cColVlidate = 'V' -- need validate on JobCapCol, UDF01-05 = codelkup.code
      BEGIN
      	DECLARE @cCode       NVARCHAR( 10)  
         DECLARE @cCheck      NVARCHAR( 20)  
         DECLARE @cColumn     NVARCHAR( 20)  
         DECLARE @cData       NVARCHAR( 60)
         DECLARE @curData     CURSOR 
         DECLARE @nCursorPos  INT 
   
      	SET @curData = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT Code, Short, Long  
            FROM dbo.CodeLKUP WITH (NOLOCK)  
            WHERE ListName = 'JOBCapColC'  
               AND Storerkey = @cStorerKey  
               AND Code2 = @nFunc  
            ORDER BY Code  
         OPEN @curData  
         FETCH NEXT FROM @curData INTO @cCode, @cCheck, @cColumn  
         WHILE @@FETCH_STATUS = 0  
         BEGIN  
            -- Check require field  
            IF @cCheck <> ''  
            BEGIN  
               -- Get data  
               IF @cCode = @cUDF01 SELECT @cData = @cRef01, @nCursorPos = 2  ELSE  
               IF @cCode = @cUDF02 SELECT @cData = @cRef02, @nCursorPos = 4  ELSE  
               IF @cCode = @cUDF03 SELECT @cData = @cRef03, @nCursorPos = 6  ELSE  
               IF @cCode = @cUDF04 SELECT @cData = @cRef04, @nCursorPos = 8  ELSE  
               IF @cCode = @cUDF05 SELECT @cData = @cRef05, @nCursorPos = 10   
              
               -- Check blank  
               IF CHARINDEX( 'R', @cCheck) > 0 AND @cData = ''  
               BEGIN  
                  SET @nErrNo = 128512  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need data  
                  EXEC rdt.rdtSetFocusField @nMobile, @nCursorPos  
                  GOTO Step_6_Fail  
               END  
  
               -- Check format  
               IF CHARINDEX( 'F', @cCheck) > 0   
               BEGIN  
                  IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Data' + @cCode, @cData) = 0  
                  BEGIN  
                     SET @nErrNo = 155902  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid format  
                     EXEC rdt.rdtSetFocusField @nMobile, @nCursorPos  
                     GOTO Step_6_Fail  
                  END  
               END  
            END  
           
            -- Build update column TSQL  
            IF ISNULL( @cColumn, '') <> ''  
               SET @cSQL = @cSQL + @cColumn + ' = @cData' + @cCode + ', '  
           
            FETCH NEXT FROM @curData INTO @cCode, @cCheck, @cColumn  
         END  
      END
  
      -- Extended validate  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            INSERT INTO @tVar (Variable, Value) VALUES   
               ('@cUserID',      @cUserID),   
               ('@cJobType',     @cJobType),   
               ('@cQTY',         @cQTY),   
               ('@cLOC',         @cLOC),   
               ('@cStart',       @cStart),  
               ('@cEnd',         @cEnd),  
               ('@cDuration',    @cDuration),  
               ('@cRef01',       @cRef01),  
               ('@cRef02',       @cRef02),  
               ('@cRef03',       @cRef03),  
               ('@cRef04',       @cRef04),  
               ('@cRef05',       @cRef05)  
  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @tVar, @nErrNo OUTPUT, @cErrMsg OUTPUT'   
            SET @cSQLParam =  
               '@nMobile         INT,           ' +  
               '@nFunc           INT,           ' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,           ' +  
               '@nInputKey       INT,           ' +   
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cFacility       NVARCHAR( 5),  ' +  
               '@tVar            VariableTable READONLY, ' +   
               '@nErrNo          INT           OUTPUT,   ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT    '  
     
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @tVar, @nErrNo OUTPUT, @cErrMsg OUTPUT  
     
            IF @nErrNo <> 0  
            BEGIN  
               SET @cOutField02 = ''  
               GOTO Quit  
            END  
         END  
      END  
  
      -- Confirm  
      EXEC rdt.rdt_JobCapture_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 'UDF',   
         @cUserID   = @cUserID,   
         @cJobType  = @cJobType,   
         @cLOC      = @cLOC,   
         @cStart    = @cStart    OUTPUT,   
         @cEnd      = @cEnd      OUTPUT,   
         @cDuration = @cDuration OUTPUT,   
         @nErrNo    = @nErrNo    OUTPUT,   
         @cErrMsg   = @cErrMsg   OUTPUT,  
         @cRef01    = @cRef01,  
         @cRef02    = @cRef02,  
         @cRef03    = @cRef03,  
         @cRef04    = @cRef04,  
         @cRef05    = @cRef05  
  
      IF @nErrNo <> 0  
         GOTO Quit  
  
      -- Prepare next screen var
      SET @cOutField01 = @cUDF01
      SET @cOutField02 = ''
      SET @cOutField03 = @cUDF02
      SET @cOutField04 = ''
      SET @cOutField05 = @cUDF03
      SET @cOutField06 = ''
      SET @cOutField07 = @cUDF04
      SET @cOutField08 = ''
      SET @cOutField09 = @cUDF05
      SET @cOutField10 = ''

      -- Enable / disable field
      SET @cFieldAttr02 = CASE WHEN ISNULL( @cUDF01, '') = '' THEN 'O' ELSE '' END
      SET @cFieldAttr04 = CASE WHEN ISNULL( @cUDF02, '') = '' THEN 'O' ELSE '' END
      SET @cFieldAttr06 = CASE WHEN ISNULL( @cUDF03, '') = '' THEN 'O' ELSE '' END
      SET @cFieldAttr08 = CASE WHEN ISNULL( @cUDF04, '') = '' THEN 'O' ELSE '' END
      SET @cFieldAttr10 = CASE WHEN ISNULL( @cUDF05, '') = '' THEN 'O' ELSE '' END

      IF @cFieldAttr10 <> 'O' EXEC rdt.rdtSetFocusField @nMobile, 10
      IF @cFieldAttr08 <> 'O' EXEC rdt.rdtSetFocusField @nMobile, 8
      IF @cFieldAttr06 <> 'O' EXEC rdt.rdtSetFocusField @nMobile, 6
      IF @cFieldAttr04 <> 'O' EXEC rdt.rdtSetFocusField @nMobile, 4
      IF @cFieldAttr02 <> 'O' EXEC rdt.rdtSetFocusField @nMobile, 2
   END  
  
   IF @nInputKey = 0 -- ESC  
   BEGIN  
      -- Prepare next screen var
      SET @cOutField01 = ''

      SET @nScn = @nScn - 5
      SET @nStep = @nStep - 5
   END  
   GOTO Quit
   
   Step_6_Fail:
      SET @cOutField02 = @cRef01
      SET @cOutField04 = @cRef02
      SET @cOutField06 = @cRef03
      SET @cOutField08 = @cRef04
      SET @cOutField10 = @cRef05
   
END  
GOTO Quit  
  
  
/********************************************************************************  
Quit. Update back to I/O table, ready to be pick up by JBOSS  
********************************************************************************/  
Quit:  
BEGIN  
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET  
      EditDate = GETDATE(),  
      ErrMsg = @cErrMsg,  
      Func   = @nFunc,  
      Step   = @nStep,  
      Scn    = @nScn,  
  
      StorerKey = @cStorerKey,  
      Facility  = @cFacility,  
  
      V_String1 = @cUserID,  
      V_String2 = @cJobType,   
      V_String3 = @cLOC,                         
      V_String4 = @cQTY,  
      V_String5 = @cCaptureLOC,                         
      V_String6 = @cCaptureQTY,  
      V_String7 = @cStart,  
      V_String8 = @cEnd,  
      V_String9 = @cDuration,  
      V_String10 = @cExtendedValidateSP,   
      V_String11 = @cCaptureRF,   

      V_String12 = @cUDF01,
      V_String13 = @cUDF02,
      V_String14 = @cUDF03,
      V_String15 = @cUDF04,
      V_String16 = @cUDF05,
      V_String17 = @cColVlidate,

      V_String41 = @cRef01,  
      V_String42 = @cRef02,  
      V_String43 = @cRef03,  
      V_String44 = @cRef04,  
      V_String45 = @cRef05,  
  
      I_Field01 = @cInField01,  O_Field01 = @cOutField01,   FieldAttr01  = @cFieldAttr01,  
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,   FieldAttr02  = @cFieldAttr02,  
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,   FieldAttr03  = @cFieldAttr03,  
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,   FieldAttr04  = @cFieldAttr04,  
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,   FieldAttr05  = @cFieldAttr05,  
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,   FieldAttr06  = @cFieldAttr06,  
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,   FieldAttr07  = @cFieldAttr07,  
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,   FieldAttr08  = @cFieldAttr08,  
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,   FieldAttr09  = @cFieldAttr09,   
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,   FieldAttr10  = @cFieldAttr10,   
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,   FieldAttr11  = @cFieldAttr11,   
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,   FieldAttr12  = @cFieldAttr12,   
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,   FieldAttr13  = @cFieldAttr13,   
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,   FieldAttr14  = @cFieldAttr14,   
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,   FieldAttr15  = @cFieldAttr15  
        
   WHERE Mobile = @nMobile  
END  
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_JobCapture TO NSQL
GO