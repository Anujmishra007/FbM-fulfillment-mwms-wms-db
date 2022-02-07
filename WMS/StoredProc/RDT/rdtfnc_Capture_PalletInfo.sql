if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdtfnc_Capture_PalletInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdtfnc_Capture_PalletInfo]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************/
/* Store procedure: rdtfnc_Capture_PalletInfo                                          */
/* Copyright      : IDS                                                                */
/*                                                                                     */
/* Purpose: Capture pallet info                                                        */
/*                                                                                     */
/* Modifications log:                                                                  */
/*                                                                                     */
/* Date         Rev  Author     Purposes                                               */
/* 17-Jan-2018  1.0  James      WMS3782. Created                                       */
/* 07-Mar-2018  1.1  Ung        WMS-3782 Trim L W H W, from weighting machine label    */
/* 30-May-2019  1.2  YeeKung    WMS9150. Add Stackability Field   (yeekung01)          */      
/***************************************************************************************/

CREATE PROC rdt.rdtfnc_Capture_PalletInfo(
   @nMobile    int,
   @nErrNo     int  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max
)
AS

SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variable
DECLARE
   @cSQL           NVARCHAR( MAX),
   @cSQLParam      NVARCHAR( MAX),
   @cPackInfo      NVARCHAR( 4)

-- RDT.RDTMobRec variables
DECLARE
   @nFunc          INT,
   @nScn           INT,
   @nStep          INT,
   @cLangCode      NVARCHAR( 3),
   @nInputKey      INT,
   @nMenu          INT,

   @cStorerKey     NVARCHAR( 15),
   @cUserName      NVARCHAR( 18),
   @cFacility      NVARCHAR( 5),
   @cPrinter       NVARCHAR( 10),

   @cOrderKey      NVARCHAR( 10),
   @cPickSlipNo    NVARCHAR( 10),
   @nQTY           INT,

   @cDropID        NVARCHAR( 20),
   @cLabelNo       NVARCHAR( 20),
   @cCartonNo      NVARCHAR( 5),
   @cCartonType    NVARCHAR( 10),
   @cCube          NVARCHAR( 10),
   @cWeight        NVARCHAR( 10),
   @cLength        NVARCHAR( 10),
   @cWidth         NVARCHAR( 10),
   @cHeight        NVARCHAR( 10),
   @cStackability  NVARCHAR( 10),  --(yeekung01)        
   @cDefaultWeight NVARCHAR( 10),        
   @cDefaultLength NVARCHAR( 10),        
   @cDefaultWidth  NVARCHAR( 10),        
   @cDefaultHeight NVARCHAR( 10),      
   @cDefaultStack  NVARCHAR( 1),  --(yeekung01)        
   @cRefNo         NVARCHAR( 20),        
   @cPalletKey     NVARCHAR( 30),
   @nSKUCount      INT,
   @nCartonCnt     INT,
   @nTotalCarton   INT,

   @cExtendedValidateSP  NVARCHAR( 20),
   @cExtendedUpdateSP    NVARCHAR( 20),
   @cExtendedInfoSP      NVARCHAR( 20),
   @cExtendedInfo        NVARCHAR( 20),
   @cPromptAllPackInfoCreated  NVARCHAR( 1),
   @cDisableEditPackInfo NVARCHAR( 1),
   @cDisableLookupField  NVARCHAR( 10), 
   @cDefaultCursor       NVARCHAR( 1),
   @cCreateNewPallet     NVARCHAR( 1),

   @cCaptureLength   NVARCHAR( 1),
   @cCaptureWidth    NVARCHAR( 1),
   @cCaptureHeight   NVARCHAR( 1),
   @cCaptureWeight   NVARCHAR( 1),
   @cCaptureStack    NVARCHAR( 1),      
   @cCaptureInfo     NVARCHAR(10),   --(yeekung01)  

   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),  @cFieldAttr01 NVARCHAR( 1),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),  @cFieldAttr02 NVARCHAR( 1),
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),  @cFieldAttr03 NVARCHAR( 1),
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),  @cFieldAttr04 NVARCHAR( 1),
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),  @cFieldAttr05 NVARCHAR( 1),
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),  @cFieldAttr06 NVARCHAR( 1),
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),  @cFieldAttr07 NVARCHAR( 1),
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),  @cFieldAttr08 NVARCHAR( 1),
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),  @cFieldAttr09 NVARCHAR( 1),
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),  @cFieldAttr10 NVARCHAR( 1),
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),  @cFieldAttr11 NVARCHAR( 1),
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),  @cFieldAttr12 NVARCHAR( 1),
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),  @cFieldAttr13 NVARCHAR( 1),
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),  @cFieldAttr14 NVARCHAR( 1),
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),  @cFieldAttr15 NVARCHAR( 1)

-- Getting Mobile information
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

   @cDefaultLength   = V_String1,
   @cDefaultWidth    = V_String2,
   @cDefaultHeight   = V_String3,
   @cDefaultWeight   = V_String4,
   @cCreateNewPallet = V_String5,
   @cWeight          = V_String6,
   @cLength          = V_String7,
   @cWidth           = V_String8,
   @cHeight          = V_String9,
   @cCaptureLength   = V_String10,
   @cCaptureWidth    = V_String11,
   @cCaptureHeight   = V_String12,
   @cCaptureWeight   = V_String13,
   @cCaptureStack       = V_String14,      
   @cDefaultStack       = V_String15, --(yeekung01)        
   @cCaptureInfo        = V_String16, --(yeekung01)        
   @cStackability       = V_String17,  --(yeekung01)        
        
   @cExtendedValidateSP = V_String21,
   @cExtendedUpdateSP   = V_String22,
   @cExtendedInfoSP     = V_String23,
   @cExtendedInfo       = V_String24,

   @cPalletKey          = V_String41,

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

FROM rdt.rdtMobRec (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 825
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0  GOTO Step_0  -- Menu. Func = 921
   IF @nStep = 1  GOTO Step_1  -- Scn = 5110. L, W, H, W
   IF @nStep = 2  GOTO Step_2  -- Scn = 5111. PalletKey
   IF @nStep = 3  GOTO Step_3  -- Scn = 5112. PalletKey, L, W, H, W
END
RETURN -- Do nothing if incorrect step


/********************************************************************************        
Step_0. Func = 825        
********************************************************************************/        
Step_0:        
BEGIN        
   -- Set the entry point        
   SET @nScn = 5110        
   SET @nStep = 1        
        
   -- Storer configure        
   SET @cCaptureLength = rdt.RDTGetConfig( @nFunc, 'CaptureLength', @cStorerKey)        
   SET @cCaptureWidth = rdt.RDTGetConfig( @nFunc, 'CaptureWidth', @cStorerKey)        
   SET @cCaptureHeight = rdt.RDTGetConfig( @nFunc, 'CaptureHeight', @cStorerKey)        
   SET @cCaptureWeight = rdt.RDTGetConfig( @nFunc, 'CaptureWeight', @cStorerKey)        
   SET @cCreateNewPallet = rdt.RDTGetConfig( @nFunc, 'CreateNewPallet', @cStorerKey)      
   SET @cCaptureStack =  rdt.RDTGetConfig( @nFunc, 'CaptureStack', @cStorerKey)      
  
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''

   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''

   -- Prepare next screen var
   SET @cOutField01 = '' -- Length
   SET @cOutField02 = '' -- Width
   SET @cOutField03 = '' -- Height
   SET @cOutField04 = '' -- Weight

   SET @cDefaultLength = ''
   SET @cDefaultWidth = ''
   SET @cDefaultHeight = ''
   SET @cDefaultWeight = ''

   -- Enable field
   SELECT 
      @cFieldAttr01 = '', @cFieldAttr02 = '', @cFieldAttr03 = '', 
      @cFieldAttr04 = '', @cFieldAttr05 = '', @cFieldAttr06 = '', 
      @cFieldAttr07 = '', @cFieldAttr08 = '', @cFieldAttr09 = '', 
      @cFieldAttr10 = '', @cFieldAttr11 = '', @cFieldAttr12 = '', 
      @cFieldAttr13 = '', @cFieldAttr14 = '', @cFieldAttr15 = ''
      
   SELECT @cCaptureInfo= LONG      
   FROM dbo.CODELKUP WITH (NOLOCK)      
   WHERE LISTNAME='CapPalInfo'      
      AND STORERKEY=@cStorerKey      
         
   IF @@ROWCOUNT  = 0      
   BEGIN      
      SET @cFieldAttr06 = 'O'      
   END      
   ELSE       
   BEGIN      
      SET @cOutField05 = @cCaptureInfo      
      SET @cFieldAttr06 = ''      
   END       
              
   -- Disable field        
   SET @cFieldAttr01 = CASE WHEN @cCaptureLength = '1' THEN '' ELSE 'O' END        
   SET @cFieldAttr02 = CASE WHEN @cCaptureWidth  = '1' THEN '' ELSE 'O' END        
   SET @cFieldAttr03 = CASE WHEN @cCaptureHeight = '1' THEN '' ELSE 'O' END        
   SET @cFieldAttr04 = CASE WHEN @cCaptureWeight = '1' THEN '' ELSE 'O' END        
   SET @cFieldAttr06 = CASE WHEN @cCaptureStack  = '1' THEN '' ELSE 'O' END  
END
GOTO Quit


/********************************************************************************
Scn = 5110. Scan desired value
   Length      (field01, input)
   Width     (field02, input)
   Height    (field03, input)
   Weight    (field04, intput)
   (field05) (field06, input)   
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cDefaultLength 	= LTRIM( RTRIM( @cInField01))
      SET @cDefaultWidth	= LTRIM( RTRIM( @cInField02))
      SET @cDefaultHeight 	= LTRIM( RTRIM( @cInField03))
      SET @cDefaultWeight 	= LTRIM( RTRIM( @cInField04))
      SET @cDefaultStack	= LTRIM( RTRIM( @cInField06)) 

      -- Check all field
      IF @cCaptureLength = '1' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Length', @cDefaultLength) = 0
      BEGIN
         SET @nErrNo = 118801
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Length
         SET @cOutField01 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Quit
      END

      IF @cCaptureWidth = '1' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Width', @cDefaultWidth) = 0
      BEGIN
         SET @nErrNo = 118802
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Width
         SET @cOutField02 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Quit
      END

      IF @cCaptureHeight = '1' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Height', @cDefaultHeight) = 0
      BEGIN
         SET @nErrNo = 118803
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Height
         SET @cOutField03 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 3
         GOTO Quit
      END

      IF @cCaptureWeight = '1' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Weight', @cDefaultWeight) = 0
      BEGIN
         SET @nErrNo = 118804
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Weight
         SET @cOutField04 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 4
         GOTO Quit
      END

      IF @cCaptureStack = '1' AND  @cDefaultStack NOT IN ('1','0') AND @cFieldAttr06=''      
      BEGIN        
         SET @nErrNo = 118813        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Stack        
         SET @cOutField06 = ''        
         EXEC rdt.rdtSetFocusField @nMobile, 6        
         GOTO Quit        
      END
      
      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, ' +
               ' @cPalletKey, @cLength, @cWidth, @cHeight, @cWeight, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile        INT,           ' +
               '@nFunc          INT,           ' +
               '@cLangCode      NVARCHAR( 3),  ' +
               '@nStep          INT,           ' +
               '@nInputKey      INT,           ' +
               '@cStorerKey     NVARCHAR( 15), ' +
               '@cFacility      NVARCHAR( 5),  ' +
               '@cPalletKey     NVARCHAR( 30), ' +
               '@cLength        NVARCHAR( 10), ' +
               '@cWidth         NVARCHAR( 10), ' +
               '@cHeight        NVARCHAR( 10), ' +
               '@cWeight        NVARCHAR( 10), ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR( 20) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility,
               @cPalletKey, @cDefaultLength, @cDefaultWidth, @cDefaultHeight, @cDefaultWeight, @nErrNo OUTPUT, @cErrMsg OUTPUT
            IF @nErrNo <> 0
               GOTO QUIT
         END
      END

      SET @cPalletKey = ''

      -- Enable field
      SELECT @cFieldAttr01 = '', @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '',@cFieldAttr06 = ''         
        
      -- Prepare next screen var        
      SET @cOutField01 = ''   -- PalletKey        
      SET @cOutField02 = ''        
      SET @cOutField03 = ''        
      SET @cOutField04 = ''        
      SET @cOutField05 = ''       
      SET @cOutField06 = ''   

      -- Go to next screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
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
            
      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
   END
END
GOTO Quit


/********************************************************************************
Scn = 8111. PalletKey screen
   PalletKey   (field01, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cPalletKey = @cInField01

      IF ISNULL( @cPalletKey, '') = ''
      BEGIN
         SET @nErrNo = 118805
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Value needed
         SET @cOutField01 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Quit
      END

      IF NOT EXISTS ( SELECT 1 FROM dbo.Pallet WITH (NOLOCK) 
                      WHERE StorerKey = @cStorerKey
                      AND   PalletKey = @cPalletKey
                      AND   [Status] < '9')
      BEGIN
         IF @cCreateNewPallet = '0'
         BEGIN
            SET @nErrNo = 118806
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet
            SET @cOutField01 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 1
            GOTO Quit
         END
         ELSE
         BEGIN
            INSERT INTO dbo.Pallet 
               (PalletKey, StorerKey, Status)
            VALUES 
               (@cPalletKey, @cStorerKey, '0')

            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 118807
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins Pallet Err
               SET @cOutField01 = ''
               EXEC rdt.rdtSetFocusField @nMobile, 1
               GOTO Quit
            END
         END
      END

      SET @cOutField01 = @cPalletKey

      IF @cDefaultStack  = '' EXEC rdt.rdtSetFocusField @nMobile, 7        
      IF @cDefaultWeight = '' EXEC rdt.rdtSetFocusField @nMobile, 5        
      IF @cDefaultHeight = '' EXEC rdt.rdtSetFocusField @nMobile, 4        
      IF @cDefaultWidth  = '' EXEC rdt.rdtSetFocusField @nMobile, 3        
      IF @cDefaultLength = '' EXEC rdt.rdtSetFocusField @nMobile, 2        
        
      -- Check Stack configure open or not      
      IF @cCaptureInfo <> ''      
      BEGIN      
         SET @cOutField06 =  @cCaptureInfo       
         SET @cFieldAttr07 = ''      
      
         IF @cCaptureStack = '1'         
         BEGIN       
            SET @cOutField07 = @cDefaultStack        
         END       
      END
      IF @cCaptureWeight = '1' 
      BEGIN
         SET @cOutField05 = @cDefaultWeight
         ----IF @cDefaultWeight <> '' EXEC rdt.rdtSetFocusField @nMobile, 4
      END

      IF @cCaptureHeight = '1' 
      BEGIN
         SET @cOutField04 = @cDefaultHeight
         --IF @cDefaultHeight <> '' EXEC rdt.rdtSetFocusField @nMobile, 3
      END

      IF @cCaptureWidth  = '1' 
      BEGIN
         SET @cOutField03 = @cDefaultWidth
         --IF @cDefaultWidth <> '' EXEC rdt.rdtSetFocusField @nMobile, 2
      END

      IF @cCaptureLength = '1' 
      BEGIN
         SET @cOutField02 = @cDefaultLength
         --IF @cDefaultLength <> '' EXEC rdt.rdtSetFocusField @nMobile, 1
      END

      -- Disable field
      SET @cFieldAttr02 = CASE WHEN @cCaptureLength = '1' THEN '' ELSE 'O' END
      SET @cFieldAttr03 = CASE WHEN @cCaptureWidth = '1' THEN '' ELSE 'O' END
      SET @cFieldAttr04 = CASE WHEN @cCaptureHeight = '1' THEN '' ELSE 'O' END
      SET @cFieldAttr05 = CASE WHEN @cCaptureWeight = '1' THEN '' ELSE 'O' END

      -- Go to next screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare prev screen var
      SET @cOutField01 = @cDefaultLength -- Length
      SET @cOutField02 = @cDefaultWidth -- Width
      SET @cOutField03 = @cDefaultHeight -- Height
      SET @cOutField04 = @cDefaultWeight -- Weight
     	SET @cOutField05 = @cCaptureInfo -- CaptureInfo         
      SET @cOutField06 = @cDefaultStack -- Stack 

      SET @cLength = ''
      SET @cWidth = ''
      SET @cHeight = ''
      SET @cWeight = ''

      -- Enable field
      SELECT 
         @cFieldAttr01 = '', @cFieldAttr02 = '', @cFieldAttr03 = '', 
         @cFieldAttr04 = '', @cFieldAttr05 = '', @cFieldAttr06 = '', 
         @cFieldAttr07 = '', @cFieldAttr08 = '', @cFieldAttr09 = '', 
         @cFieldAttr10 = '', @cFieldAttr11 = '', @cFieldAttr12 = '', 
         @cFieldAttr13 = '', @cFieldAttr14 = '', @cFieldAttr15 = ''
      
      -- Disable field
      SET @cFieldAttr01 = CASE WHEN @cCaptureLength = '1' THEN '' ELSE 'O' END
      SET @cFieldAttr02 = CASE WHEN @cCaptureWidth = '1' THEN '' ELSE 'O' END
      SET @cFieldAttr03 = CASE WHEN @cCaptureHeight = '1' THEN '' ELSE 'O' END
      SET @cFieldAttr04 = CASE WHEN @cCaptureWeight = '1' THEN '' ELSE 'O' END
      SET @cFieldAttr06 = CASE WHEN @cCaptureStack  = '1' THEN '' ELSE 'O' END         
        
      IF @cFieldAttr06 = '' EXEC rdt.rdtSetFocusField @nMobile, 6 
      IF @cFieldAttr04 = '' EXEC rdt.rdtSetFocusField @nMobile, 4
      IF @cFieldAttr03 = '' EXEC rdt.rdtSetFocusField @nMobile, 3
      IF @cFieldAttr02 = '' EXEC rdt.rdtSetFocusField @nMobile, 2
      IF @cFieldAttr01 = '' EXEC rdt.rdtSetFocusField @nMobile, 1

      -- Go to prev screen
      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
   END
END
GOTO Quit


/********************************************************************************
Scn = 5012. Store pallet info
   PalletKey   (field01)
   Length      (field02, input)        
   Width       (field03, input)        
   Height      (field04, input)        
   Weight      (field05, input)       
   (field06)   (field07, input)       
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cLength = LTRIM( RTRIM( @cInField02))
      SET @cWidth = LTRIM( RTRIM( @cInField03))
      SET @cHeight = LTRIM( RTRIM( @cInField04))
      SET @cWeight = LTRIM( RTRIM( @cInField05))
      SET @cStackability = LTRIM( RTRIM(@cInField07))

      -- Check all field
      IF ISNULL( @cLength, '') <> '' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Length', @cLength) = 0
      BEGIN
         SET @nErrNo = 118808
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Length
         SET @cOutField02 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Quit
      END

      IF ISNULL( @cWidth, '') <> '' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Width', @cWidth) = 0
      BEGIN
         SET @nErrNo = 118809
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Width
         SET @cOutField03 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 3
         GOTO Quit
      END

      IF ISNULL( @cHeight, '') <> '' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Height', @cHeight) = 0
      BEGIN
         SET @nErrNo = 118810
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Height
         SET @cOutField04 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 4
         GOTO Quit
      END

      IF ISNULL( @cWeight, '') <> '' AND 
         rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Weight', @cWeight) = 0
      BEGIN
         SET @nErrNo = 118811
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Weight
         SET @cOutField05 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 5
         GOTO Quit
      END
      
      IF ISNULL( @cStackability, '') <> '' AND  @cStackability NOT IN ('1','0')      
      BEGIN        
         SET @nErrNo = 118811        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Weight        
         SET @cOutField07 = ''        
         EXEC rdt.rdtSetFocusField @nMobile, 7        
         GOTO Quit        
      END      
      
      UPDATE dbo.Pallet WITH (ROWLOCK) SET 
         Length = @cLength,
         Width = @cWidth,
         Height = @cHeight,
         GrossWgt = @cWeight,      
         PalletType = CASE WHEN  @cStackability = '1' THEN 'YES' ELSE 'NO' END 
      WHERE PalletKey = @cPalletKey
      AND   StorerKey = @cStorerKey
      AND   [Status] < '9'

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 118812
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd Info Err
         SET @cOutField05 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 5
         GOTO Quit
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, ' +
               ' @cPalletKey, @cLength, @cWidth, @cHeight, @cWeight, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile        INT,           ' +
               '@nFunc          INT,           ' +
               '@cLangCode      NVARCHAR( 3),  ' +
               '@nStep          INT,           ' +
               '@nInputKey      INT,           ' +
               '@cStorerKey     NVARCHAR( 15), ' +
               '@cFacility      NVARCHAR( 5),  ' +
               '@cPalletKey     NVARCHAR( 30), ' +
               '@cLength        NVARCHAR( 10), ' +
               '@cWidth         NVARCHAR( 10), ' +
               '@cHeight        NVARCHAR( 10), ' +
               '@cWeight        NVARCHAR( 10), ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR( 20) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility,
               @cPalletKey, @cDefaultLength, @cDefaultWidth, @cDefaultHeight, @cDefaultWeight, @nErrNo OUTPUT, @cErrMsg OUTPUT
            IF @nErrNo <> 0
               GOTO QUIT
         END
      END

      SET @cPalletKey = ''

      -- Enable field
      SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = '' , @cFieldAttr07 = ''       
        
      -- Prepare next screen var        
      SET @cOutField01 = ''   -- PalletKey        
      SET @cOutField02 = ''        
      SET @cOutField03 = ''        
      SET @cOutField04 = ''        
      SET @cOutField05 = ''           
      SET @cOutField06 = ''        
      SET @cOutField07 = ''    

      -- Back to PalletKey screen
      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cPalletKey = ''

      -- Enable field
      SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = ''

      -- Prepare next screen var
      SET @cOutField01 = ''   -- PalletKey
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutField04 = ''
      SET @cOutField05 = ''

      -- Go to prev screen
      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
   END
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

      StorerKey    = @cStorerKey,
      Facility     = @cFacility,
      -- UserName     = @cUserName,
      Printer      = @cPrinter,

      V_OrderKey   = @cOrderKey,
      V_PickSlipNo = @cPickSlipNo,
      V_QTY        = @nQTY,

      V_String1    = @cDefaultLength,
      V_String2    = @cDefaultWidth,
      V_String3    = @cDefaultHeight,
      V_String4    = @cDefaultWeight,
      V_String5    = @cCreateNewPallet, 
      V_String6    = @cWeight, 
      V_String7    = @cLength,
      V_String8    = @cWidth,
      V_String9    = @cHeight,

      V_String10 	= @cCaptureLength,
      V_String11 	= @cCaptureWidth,
      V_String12 	= @cCaptureHeight,
      V_String13 	= @cCaptureWeight,
      V_String14  = @cCaptureStack,   --(yeekung01)        
      V_String15  = @cDefaultStack,   --(yeekung01)      
      V_String16  = @cCaptureInfo,    --(yeekung01)      
      V_String17  = @cStackability,   --(yeekung01) 

      V_String21   = @cExtendedValidateSP, 
      V_String22   = @cExtendedUpdateSP, 
      V_String23   = @cExtendedInfoSP,
      V_String24   = @cExtendedInfo,

      V_String41   = @cPalletKey,

      I_Field01 = @cInField01,  O_Field01 = @cOutField01,  FieldAttr01  = @cFieldAttr01,
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,  FieldAttr02  = @cFieldAttr02,
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,  FieldAttr03  = @cFieldAttr03,
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,  FieldAttr04  = @cFieldAttr04,
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,  FieldAttr05  = @cFieldAttr05,
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,  FieldAttr06  = @cFieldAttr06,
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,  FieldAttr07  = @cFieldAttr07,
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,  FieldAttr08  = @cFieldAttr08,
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,  FieldAttr09  = @cFieldAttr09,
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,  FieldAttr10  = @cFieldAttr10,
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,  FieldAttr11  = @cFieldAttr11,
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,  FieldAttr12  = @cFieldAttr12,
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,  FieldAttr13  = @cFieldAttr13,
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,  FieldAttr14  = @cFieldAttr14,
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,  FieldAttr15  = @cFieldAttr15
   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_Capture_PalletInfo TO NSQL
GO