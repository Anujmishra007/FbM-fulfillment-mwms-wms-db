
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_825ExtScn02                                     */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2025-09-16 1.0  Dennis     FCR-8079. Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC  [RDT].[rdt_825ExtScn02] (
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
   @nAction          INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
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
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
         @cSku                NVARCHAR(30)

   DECLARE 
         @nTotalWeight        FLOAT,
         @nEmptyPalletWgt     FLOAT,
         @nMobStep           INT,  
         @nMobScn            INT 

-- Misc variable
DECLARE
   @cSQL           NVARCHAR( MAX),
   @cSQLParam      NVARCHAR( MAX),
   @cPackInfo      NVARCHAR( 4)

-- RDT.RDTMobRec variables
DECLARE
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
   @cExtScnSP      NVARCHAR( 20),
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
   @cCaptureInfo     NVARCHAR(10)


   SELECT 
      @nMobStep = Step,
      @nMobScn  = Scn,
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
      @cExtScnSP           = V_string25,

      @cPalletKey          = V_String41
   FROM rdt.rdtMobRec (NOLOCK)
   WHERE Mobile = @nMobile
   
   IF @nFunc = 825
   BEGIN
      IF @nMobStep = 2
      BEGIN         
         IF @nInputKey = 1
         BEGIN
            SET @nAfterStep = 99
            GOTO QUIT
         END
      END
      IF @nMobStep = 99 AND @nMobScn = 5112
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
            
            UPDATE dbo.Pallet WITH (ROWLOCK) SET 
               Length = CASE WHEN ISNULL(@cLength,'') = '' THEN Length ELSE @cLength END,
               Width = CASE WHEN ISNULL(@cWidth,'') = '' THEN Width ELSE @cWidth END,
               Height = CASE WHEN ISNULL(@cHeight,'') = '' THEN Height ELSE @cHeight END,
               GrossWgt = CASE WHEN ISNULL(@cWeight,'') = '' THEN GrossWgt ELSE @cWeight END,
               PalletType = CASE WHEN  @cStackability = '1' THEN 'YES' ELSE PalletType END 
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
            SET @nAfterScn = 5111
            SET @nAfterStep = 2
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
            SET @nAfterScn = 5111
            SET @nAfterStep = 2
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
GRANT EXECUTE ON rdt.rdt_825ExtScn02 TO NSQL
GO
 
