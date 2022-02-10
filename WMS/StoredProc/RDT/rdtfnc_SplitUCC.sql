IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'rdt.rdtfnc_SplitUCC') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdtfnc_SplitUCC
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/******************************************************************************/   
/* Copyright: IDS                                                             */   
/* Purpose: SOS#306388 A&F Project                                            */   
/*                                                                            */   
/* Modifications log:                                                         */   
/*                                                                            */   
/* Date       Rev  Author     Purposes                                        */   
/* 2014-04-15 1.0  ChewKP     Created                                         */  
/******************************************************************************/  
  
CREATE PROC [RDT].[rdtfnc_SplitUCC] (  
   @nMobile    int,  
   @nErrNo     int  OUTPUT,  
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 NVARCHAR max  
)  
AS  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
-- Misc variable  
DECLARE   
   @nCount      INT,  
   @nRowCount   INT  
  
-- RDT.RDTMobRec variable  
DECLARE   
   @nFunc      INT,  
   @nScn       INT,  
   @nStep      INT,  
   @cLangCode  NVARCHAR( 3),  
   @nInputKey  INT,  
   @nMenu      INT,  
  
   @cStorerKey NVARCHAR( 15),  
   @cFacility  NVARCHAR( 5),   
   @cPrinter   NVARCHAR( 20),   
   @cUserName  NVARCHAR( 18),  
     
   @nError        INT,  
   @b_success     INT,  
   @n_err         INT,       
   @c_errmsg      NVARCHAR( 250),   
   @cPUOM         NVARCHAR( 10),      
   @bSuccess      INT,  
     
   @cFromUCC      NVARCHAR(20),  
   @cToUCC        NVARCHAR(20),  
   @cSKU          NVARCHAR(20),  
   @cExtendedUpdateSP    NVARCHAR(20),  
   @cExtendedValidateSP  NVARCHAR(20),  
   @cSuggestedSKU        NVARCHAR(20),   
   @cOptions             NVARCHAR(1),   
   @cQty                 NVARCHAR(5),   
   @nSKUCnt              INT,  
   @cSQL                 NVARCHAR(1000),   
   @cSQLParam            NVARCHAR(1000),   
        
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
   @nFunc      = Func,  
   @nScn       = Scn,  
   @nStep      = Step,  
   @nInputKey  = InputKey,  
   @nMenu      = Menu,  
   @cLangCode  = Lang_code,  
  
   @cStorerKey = StorerKey,  
   @cFacility  = Facility,  
   @cPrinter   = Printer,   
   @cUserName  = UserName,  
     
   @cPUOM       = V_UOM,  
   @cFromUCC    = V_UCC,  
   @cSKU        = V_SKU,  
     
   @cToUCC     = V_String1,  
   @cSuggestedSKU = V_String2,  
   @cExtendedUpdateSP    = V_String3,  
   @cExtendedValidateSP  = V_String4,  
   
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
   @cFieldAttr03 =  FieldAttr03,    @cFieldAttr04  = FieldAttr04,  
   @cFieldAttr05 =  FieldAttr05,    @cFieldAttr06   = FieldAttr06,  
   @cFieldAttr07 =  FieldAttr07,    @cFieldAttr08   = FieldAttr08,  
   @cFieldAttr09 =  FieldAttr09,    @cFieldAttr10   = FieldAttr10,  
   @cFieldAttr11 =  FieldAttr11,    @cFieldAttr12   = FieldAttr12,  
   @cFieldAttr13 =  FieldAttr13,    @cFieldAttr14   = FieldAttr14,  
   @cFieldAttr15 =  FieldAttr15  
  
FROM RDTMOBREC (NOLOCK)  
WHERE Mobile = @nMobile  
  
Declare @n_debug INT  
  
SET @n_debug = 0  
  

IF @nFunc = 535  -- Split UCC  
BEGIN  
   -- Redirect to respective screen  
   IF @nStep = 0 GOTO Step_0   -- Split UCC  
   IF @nStep = 1 GOTO Step_1   -- Scn = 3820. From UCC  
   IF @nStep = 2 GOTO Step_2   -- Scn = 3820. To UCC , Options  
   IF @nStep = 3 GOTO Step_3   -- Scn = 3820. SKU, Qty  
   
     
END  
  
--IF @nStep = 3  
--BEGIN  
-- SET @cErrMsg = 'STEP 3'  
-- GOTO QUIT  
--END  
  
RETURN -- Do nothing if incorrect step  
  
/********************************************************************************  
Step 0. func = 815. Menu  
********************************************************************************/  
Step_0:  
BEGIN  
   -- Get prefer UOM  
 SET @cPUOM = ''  
   SELECT @cPUOM = IsNULL( DefaultUOM, '6') -- If not defined, default as EA  
   FROM RDT.rdtMobRec M WITH (NOLOCK)  
      INNER JOIN RDT.rdtUser U WITH (NOLOCK) ON (M.UserName = U.UserName)  
   WHERE M.Mobile = @nMobile  
     
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)  
   IF @cExtendedValidateSP = '0'  
      SET @cExtendedValidateSP = ''  
   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)  
   IF @cExtendedUpdateSP = '0'  
      SET @cExtendedUpdateSP = ''  
        
  
   -- Initiate var  
 -- EventLog - Sign In Function  
   EXEC RDT.rdt_STD_EventLog  
     @cActionType = '1', -- Sign in function  
     @cUserID     = @cUserName,  
     @nMobileNo   = @nMobile,  
     @nFunctionID = @nFunc,  
     @cFacility   = @cFacility,  
     @cStorerKey  = @cStorerkey  
       
     
   -- Init screen  
   SET @cOutField01 = ''   
   SET @cOutField02 = ''  
     
   SET @cFromUCC    = ''    
   SET @cToUCC      = ''    
   SET @cSKU        = ''  
   
   -- Set the entry point  
   SET @nScn = 3820  
   SET @nStep = 1  
   
   EXEC rdt.rdtSetFocusField @nMobile, 1  
   
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 1. Scn = 3820.   
   FromUCC  (Input , Field01)  
********************************************************************************/  
Step_1:  
BEGIN  
   IF @nInputKey = 1 --ENTER  
   BEGIN  
      SET @cFromUCC  = ISNULL(RTRIM(@cInField01),'')  
    
    
      IF @cFromUCC = ''   
      BEGIN  
         SET @nErrNo = 87251  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FromUCC Req  
         GOTO Step_1_Fail  
      END   
      
      IF NOT EXISTS ( SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cFromUCC AND Status = '1' )   
      BEGIN  
         SET @nErrNo = 87252  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidUCC  
         GOTO Step_1_Fail  
      END         
        
      -- Prepare Next Screen Variable  
      SET @cOutField01 = RTRIM(@cFromUCC)   
      SET @cOutField02 = ''  
      SET @cOutField03 = ''  
  
      -- GOTO Next Screen  
      SET @nScn = @nScn + 1  
      SET @nStep = @nStep + 1  
       
   END  -- Inputkey = 1  
  
   IF @nInputKey = 0   
   BEGIN  
      -- EventLog - Sign In Function  
       EXEC RDT.rdt_STD_EventLog  
        @cActionType = '9', -- Sign in function  
        @cUserID     = @cUserName,  
        @nMobileNo   = @nMobile,  
        @nFunctionID = @nFunc,  
        @cFacility   = @cFacility,  
        @cStorerKey  = @cStorerkey  
          
      --go to main menu  
      SET @nFunc = @nMenu  
      SET @nScn  = @nMenu  
      SET @nStep = 0  
      SET @cOutField01 = ''  
          
   END  
   GOTO Quit  
  
   STEP_1_FAIL:  
   BEGIN  
      SET @cOutField01 = ''  
      SET @cOutField02 = ''  
      --EXEC rdt.rdtSetFocusField @nMobile, 1  
   END  
     
  
END   
GOTO QUIT  
  
/********************************************************************************  
Step 2. Scn = 3821.   
   FromUCC       (field01)  
   ToUCC         (field02, input)  
   Options       (field03, input)  
     
     
********************************************************************************/  
Step_2:  
BEGIN  
   IF @nInputKey = 1 --ENTER  
   BEGIN  
      
      SET @cToUCC = ISNULL(RTRIM(@cInField02),'')  
      SET @cOptions = ISNULL(RTRIM(@cInField03),'')  
    
      IF @cToUCC = ''   
      BEGIN  
      SET @nErrNo = 87253  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToUCC Req  
         SET @cToUCC = ''  
         GOTO Step_2_Fail  
      END   
      
      IF NOT EXISTS ( SELECT 1 FROM dbo.UCC WITH (NOLOCK) WHERE UCCNo = @cToUCC )   
      BEGIN  
         SET @nErrNo = 87254  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCCExists  
         SET @cToUCC = ''  
         GOTO Step_2_Fail  
      END   
      
      IF @cOptions = ''  
      BEGIN  
         SET @nErrNo = 87255  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Option Req'  
         GOTO Step_2_Fail  
      END  
        
      IF @cOptions NOT IN ('1','9')  
      BEGIN  
         SET @nErrNo = 87256  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InvalidOption'  
         GOTO Step_2_Fail  
      END  
      
      IF @cOptions = '1'  
      BEGIN  
         
         UPDATE dbo.UCC WITH (ROWLOCK)  
         SET UCCNo = @cToUCC  
         WHERE UCCNo = @cFromUCC   
         AND Status = '1'  
         
         IF @@ERROR <> 0   
         BEGIN  
            SET @nErrNo = 87257  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UpdUCCFail'  
            GOTO Step_2_Fail  
         END  
         
         EXEC RDT.rdt_STD_EventLog  
            @cActionType = '3',   
            @cUserID     = @cUserName,  
            @nMobileNo   = @nMobile,  
            @nFunctionID = @nFunc,  
            @cFacility   = @cFacility,  
            @cStorerKey  = @cStorerkey,  
            @cRefNo1     = @cFromUCC,  
            @cRefNo2     = @cToUCC  
           
         -- Prepare Next Screen Variable  
         SET @cOutField01 = ''  
         SET @cOutField02 = ''  
         SET @cOutField03 = ''  
         SET @cOutField04 = ''  
       
         -- GOTO Previous Screen  
         SET @nScn = @nScn - 1  
         SET @nStep = @nStep - 1  
          
         GOTO QUIT  
      END  
      ELSE IF @cOptions = '9'  
      BEGIN  
         SET @cSuggestedSKU = ''  
         
         SELECT @cSuggestedSKU = SKU   
         FROM dbo.UCC WITH (NOLOCK)  
         WHERE UCCNo = @cFromUCC  
         
         
         SET @cOutField01 = @cFromUCC  
         SET @cOutField02 = @cToUCC  
         SET @cOutField03 = @cSuggestedSKU  
         SET @cOutField04 = ''  
         SET @cOutField05 = ''  
         
         -- GOTO Next Screen  
         SET @nScn = @nScn + 1  
         SET @nStep = @nStep+ 1  
          
         GOTO QUIT  
      END  
       
   END  -- Inputkey = 1  
  
  
   IF @nInputKey = 0   
   BEGIN  
      SET @cOutField01 = ''  
      SET @cOutField02 = ''    
      SET @cOutField03 = ''  
      SET @cOutField04 = ''  
  
      -- GOTO Previous Screen  
      SET @nScn = @nScn - 1  
      SET @nStep = @nStep - 1  
          
   END  
   GOTO Quit  
  
   STEP_2_FAIL:  
   BEGIN    
      -- Prepare Next Screen Variable  
      SET @cOutField01 = @cFromUCC   
      SET @cOutField02 = @cToUCC   
      SET @cOutField03 = ''      
   END  
     
  
END   
GOTO QUIT  
  
  
/********************************************************************************  
Step 3. Scn = 3822.   
     
   FROM UCC (field01)  
   TO UCC   (field02)  
   SKU      (field03)  
   SKU      (field04, Input)  
   Qty      (field05, Input)  
     
     
********************************************************************************/  
Step_3:  
BEGIN  
   IF @nInputKey = 1  
   BEGIN  
      SET @cSKU = ISNULL(RTRIM(@cInField04),'')  
      SET @cQty = ISNULL(RTRIM(@cInField05),'')  
        
      IF @cSKU = ''  
      BEGIN  
         SET @nErrNo = 87258  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'SKU Req'  
         SET @cSKU = ''  
         GOTO Step_3_Fail  
      END  
        
      EXEC rdt.rdt_GETSKUCNT  
       @cStorerkey  = @cStorerKey         
      ,@cSKU        = @cSKU  
      ,@nSKUCnt     = @nSKUCnt       OUTPUT  
      ,@bSuccess    = @b_Success     OUTPUT  
      ,@nErr        = @nErrNo        OUTPUT  
      ,@cErrMsg     = @cErrMsg       OUTPUT  
  
      -- Check SKU/UPC  
      IF @nSKUCnt = 0  
      BEGIN  
         SET @nErrNo = 87259  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid SKU  
         SET @cSKU = ''  
         GOTO Step_3_Fail  
      END  
        
      EXEC dbo.nspg_GETSKU  
            @cStorerKey OUTPUT   
         ,  @cSKU       OUTPUT  
         ,  @b_Success  OUTPUT  
         ,  @nErrNo     OUTPUT  
         ,  @cErrMsg    OUTPUT  
  
    IF @b_success = 0  
    BEGIN  
         SET @nErrNo = 87260  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo , @cLangCode, 'DSP') --'Invalid SKU'  
         SET @cSKU = ''  
         GOTO Step_3_Fail  
      END  
        
      IF @cQty = ''  
      BEGIN  
         SET @nErrNo = 87262  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo , @cLangCode, 'DSP') --'Qty Req'  
         GOTO Step_3_Fail  
      END  
        
      IF RDT.rdtIsValidQTY( @cQty, 0) = 0  
      BEGIN  
         SET @nErrNo = 87263  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo , @cLangCode, 'DSP') --'InvalidQty'  
         GOTO Step_3_Fail  
      END  
        
      IF EXISTS ( SELECT 1 FROM dbo.UCC WITH (NOLOCK)   
                  WHERE UCCNo = @cFromUCC  
                  AND Qty < CAST(@cQty AS INTEGER ) )  
      BEGIN  
         SET @nErrNo = 87264  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo , @cLangCode, 'DSP') --'InvalidQty'  
         GOTO Step_3_Fail  
      END                    

      -- Extended validate  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFromUCC, @cToUCC, @cSKU, @cQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile    INT,           ' +  
               '@nFunc      INT,           ' +  
               '@cLangCode  NVARCHAR( 3),  ' +  
               '@nStep      INT,           ' +   
               '@cStorerKey NVARCHAR( 15), ' +   
               '@cFromUCC   NVARCHAR( 20), ' +   
               '@cToUCc     NVARCHAR( 20), ' +  
               '@cSKU       NVARCHAR( 20), ' +  
               '@cQty       NVARCHAR( 5),  ' +  
               '@nErrNo     INT OUTPUT,    ' +  
               '@cErrMsg    NVARCHAR( 20) OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFromUCC, @cToUCC, @cSKU, @cQty, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
               GOTO Quit  
         END  
      END  
        
      -- Extended update  
      IF @cExtendedUpdateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFromUCC, @cToUCC, @cSKU, @cQty, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile    INT,           ' +  
               '@nFunc      INT,           ' +  
               '@cLangCode  NVARCHAR( 3),  ' +  
               '@nStep      INT,           ' +   
               '@cStorerKey NVARCHAR( 15), ' +   
               '@cFromUCC   NVARCHAR( 20), ' +   
               '@cToUCc     NVARCHAR( 20), ' +  
               '@cSKU       NVARCHAR( 20), ' +  
               '@cQty       NVARCHAR( 5),  ' +  
               '@nErrNo     INT OUTPUT,    ' +  
               '@cErrMsg    NVARCHAR( 20) OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFromUCC, @cToUCC, @cSKU, @cQty, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
               GOTO Quit  
         END  
      END  
        
        
   END  -- Inputkey = 1  
     
   IF @nInputKey = 0   
   BEGIN  
          -- Prepare Previous Screen Variable  
      SET @cOutField01 = @cFromUCC  
      SET @cOutField02 = ''  
      SET @cOutField03 = ''  
      SET @cOutField04 = ''  
        
       -- GOTO Previous Screen  
      SET @nScn = @nScn - 1  
      SET @nStep = @nStep - 1  
       
   END  
   GOTO Quit  
   
   STEP_3_FAIL:  
   BEGIN  
        
      -- Prepare Next Screen Variable  
      SET @cOutField01 = @cFromUCC  
      SET @cOutField02 = @cToUCC  
      SET @cOutField03 = @cSuggestedSKU  
      SET @cOutField04 = @cSKU  
      SET @cOutField05 = ''  
    
   END  
  
END   
GOTO QUIT  
  
  
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
      Printer   = @cPrinter,   
      UserName  = @cUserName,  
      InputKey  = @nInputKey,  
    
  
      V_UOM = @cPUOM,  
      V_UCC = @cFromUCC,  
      V_SKU = @cSKU,  
  
        
      V_String1 = @cToUCC,  
      V_String2 = @cSuggestedSKU,           
        
      V_String3 = @cExtendedUpdateSP,    
      V_String4 = @cExtendedValidateSP,  
              
              
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

GRANT EXECUTE ON rdt.rdtfnc_SplitUCC TO NSQL
GO
  
  
  
  
  