SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Store procedure: rdtfnc_CartonToMBOL                                    */
/* Copyright      : LF Logistics                                           */
/*                                                                         */
/* Purpose: Scan carton to populate orders into MBOL, MBOLDetail           */
/*                                                                         */
/* Modifications log:                                                      */
/*                                                                         */
/* Date         Rev  Author   Purposes                                     */
/* 2023-03-30   1.0  Ung      WMS-22181 Created                            */
/***************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtfnc_CartonToMBOL] (
   @nMobile    INT,
   @nErrNo     INT          OUTPUT,
   @cErrMsg    NVARCHAR(20) OUTPUT
)  
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variables
DECLARE
   @cSQL           NVARCHAR(MAX),
   @cSQLParam      NVARCHAR(MAX),
   @tCaptureVar    VariableTable,
   @tExtValVar     VariableTable,
   @tExtUpdVar     VariableTable,
   @tConfirmVar    VariableTable,
   @tExtInfoVar    VariableTable, 
   @cOption        NVARCHAR( 2),
   @nTranCount     INT

-- RDT.RDTMobRec variables
DECLARE
   @nFunc          INT,
   @nScn           INT,
   @nStep          INT,
   @cLangCode      NVARCHAR( 3),
   @nInputKey      INT,
   @nMenu          INT,

   @cStorerKey     NVARCHAR( 15),
   @cFacility      NVARCHAR( 5),

   @cOrderKey           NVARCHAR( 10),
   @cPalletLOC          NVARCHAR( 10),
   @cSKU                NVARCHAR( 20),

   @cMBOLKey            NVARCHAR( 10),
   @cRefNo              NVARCHAR( 20),
   @cCartonID           NVARCHAR( 20),

   @cExtendedUpdateSP   NVARCHAR( 20),
   @cExtendedValidateSP NVARCHAR( 20),
   @cExtendedInfoSP     NVARCHAR( 20),
   @cExtendedInfo       NVARCHAR( 20),
   @cCaptureInfoSP      NVARCHAR( 20),
   @cCartonIDSP         NVARCHAR( 20),
   @cAutoGenMBOL        NVARCHAR( 1),

   @cData1              NVARCHAR( 60),
   @cData2              NVARCHAR( 60),
   @cData3              NVARCHAR( 60),
   @cData4              NVARCHAR( 60),
   @cData5              NVARCHAR( 60),

   @nTotalCarton        INT,

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

   @cOrderKey           = V_OrderKey,
   @cPalletLOC          = V_LOC, 
   @cSKU                = V_SKU, 

   @cMBOLKey            = V_String1,
   @cRefNo              = V_String2,
   @cCartonID           = V_String3,

   @cExtendedUpdateSP   = V_String21,
   @cExtendedValidateSP = V_String22,
   @cExtendedInfoSP     = V_String23,
   @cExtendedInfo       = V_String24,
   @cCaptureInfoSP      = V_String25,
   @cCartonIDSP         = V_String26,
   @cAutoGenMBOL        = V_String27,

   @cData1              = V_String41,
   @cData2              = V_String42,
   @cData3              = V_String43,
   @cData4              = V_String44,
   @cData5              = V_String45,

   @nTotalCarton        = V_Integer1,

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

FROM rdt.rdtMobRec WITH (NOLOCK)
WHERE Mobile = @nMobile

-- Screen constant
DECLARE
   @nStep_MBOL          INT,  @nScn_MBOL          INT,
   @nStep_Carton        INT,  @nScn_Carton        INT,
   @nStep_CloseMBOL     INT,  @nScn_CloseMBOL     INT,
   @nStep_CaptureData   INT,  @nScn_CaptureData   INT

SELECT
   @nStep_MBOL          = 1,  @nScn_MBOL          = 6240,
   @nStep_CaptureData   = 2,  @nScn_CaptureData   = 6241, 
   @nStep_Carton        = 3,  @nScn_Carton        = 6242,
   @nStep_CloseMBOL     = 4,  @nScn_CloseMBOL     = 6243


IF @nFunc = 1863
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0  GOTO Step_Start        -- Menu. Func = 1863
   IF @nStep = 1  GOTO Step_MBOL         -- Scn = 6240. MBOL
   IF @nStep = 2  GOTO Step_CaptureData  -- Scn = 6241. Capture data
   IF @nStep = 3  GOTO Step_Carton       -- Scn = 6242. Carton ID
   IF @nStep = 4  GOTO Step_CloseMBOL    -- Scn = 6243. Close MBOL?
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step_Start. Func = 1863
********************************************************************************/
Step_Start:
BEGIN
   SET @cAutoGenMBOL =  rdt.rdtGetConfig( @nFunc, 'AutoGenMBOL', @cStorerKey)
   --SET @cRefNoLookupColumn = rdt.rdtGetConfig( @nFunc, 'RefNoLookupColumn', @cStorerKey)

   SET @cCaptureInfoSP = rdt.RDTGetConfig( @nFunc, 'CaptureInfoSP', @cStorerKey)
   IF @cCaptureInfoSP = '0'
      SET @cCaptureInfoSP = ''
   SET @cCartonIDSP = rdt.RDTGetConfig( @nFunc, 'CartonIDSP', @cStorerKey)
   IF @cCartonIDSP = '0'
      SET @cCartonIDSP = ''
   SET @cExtendedInfoSP = rdt.rdtGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''
   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cPalletLOC = rdt.rdtGetConfig( @nFunc, 'PalletLOC', @cStorerKey)  
   IF @cPalletLOC = '0'  
      SET @cPalletLOC = ''  
      
   IF @cCartonIDSP = ''
      SET @cCartonIDSP = 'L' -- L=LabenNo

   -- Logging
   EXEC RDT.rdt_STD_EventLog
      @cActionType     = '1', -- Sign-in
      @nMobileNo       = @nMobile,
      @nFunctionID     = @nFunc,
      @cFacility       = @cFacility,
      @cStorerKey      = @cStorerKey

   -- Prepare next screen var
   SET @cOutField01 = '' -- MBOL

   -- Go to next screen
   SET @nScn = @nScn_MBOL
   SET @nStep = @nStep_MBOL
END
GOTO Quit


/************************************************************************************
Step 1. Scn = 6240. Scan MBOL
   MBOL  (field01, input)
************************************************************************************/
Step_MBOL:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cMBOLKey = @cInField01
      
      -- Check blank
      IF @cMBOLKey = ''
      BEGIN
         IF @cAutoGenMBOL = '1'
         BEGIN
            DECLARE @nSuccess INT = 1
            EXECUTE dbo.nspg_getkey
               'MBOL'
               , 10
               , @cMBOLKey    OUTPUT
               , @nSuccess    OUTPUT
               , @nErrNo      OUTPUT
               , @cErrMsg     OUTPUT
            IF @nSuccess <> 1
            BEGIN
               SET @nErrNo = 198851
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
            END
            
            -- Check pallet exist 
            -- (in case other storer already created this pallet, not thru auto generate)
            IF EXISTS( SELECT 1 FROM dbo.Pallet WITH (NOLOCK) WHERE PalletKey = @cMBOLKey)
            BEGIN
               SET @nErrNo = 198852
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet existed
               GOTO Step_MBOL_Fail
            END
            
            SET @nTranCount = @@TRANCOUNT
            BEGIN TRAN  -- Begin our own transaction
            SAVE TRAN rdtfnc_CartonToMBOL -- For rollback or commit only our own transaction
            
            -- MBOL
            INSERT INTO dbo.MBOL (MBOLKey, ExternMBOLKey, Facility, Status) 
            VALUES (@cMBOLKey, @cMBOLKey, @cFacility, '0')
            IF @@ERROR <> 0
            BEGIN
               ROLLBACK TRAN rdtfnc_CartonToMBOL -- Only rollback change made here
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN 
                  
               SET @nErrNo = 198853
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBOL Fail
               GOTO Step_MBOL_Fail
            END
/*            
            -- Pallet
            INSERT INTO dbo.Pallet (PalletKey, StorerKey, Status)
            VALUES (@cMBOLKey, @cStorerKey, '0')
            IF @@ERROR <> 0
            BEGIN
               ROLLBACK TRAN rdtfnc_CartonToMBOL -- Only rollback change made here
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN 

               SET @nErrNo = 198854
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PalletFail
               GOTO Step_MBOL_Fail
            END
*/            
            COMMIT TRAN rdtfnc_CartonToMBOL
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
               COMMIT TRAN 
         END
         ELSE
         BEGIN
            SET @nErrNo = 198855
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need MBOL
            GOTO Step_MBOL_Fail
         END
      END

      -- Scanned MBOL
      ELSE
      BEGIN
return
         
         -- Get MBOL info
         DECLARE @cChkFacility NVARCHAR( 5)
         DECLARE @cChkStatus NVARCHAR( 10)
         SELECT 
            @cChkFacility = Facility, 
            @cChkStatus = Status
         FROM dbo.MBOL WITH (NOLOCK)
         WHERE MBOLKey = @cMBOLKey
      
         -- Check MBOL valid
         IF @@ROWCOUNT = 0
         BEGIN
            SET @nErrNo = 198856
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid MBOL
            GOTO Step_MBOL_Fail
         END
         
         -- Check facility
         IF @cChkFacility <> @cFacility
         BEGIN
            SET @nErrNo = 198857
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff Facility
            GOTO Step_MBOL_Fail
         END

         -- Check facility
         IF @cChkStatus >= '5'
         BEGIN
            SET @nErrNo = 198858
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL closed
            GOTO Step_MBOL_Fail
         END
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
               ' @cMBOLKey, @cRefNo, @cOrderKey, @cPalletLOC, @cCartonID, @cSKU, @cData1, @cData2, @cData3, @cData4, @cData5, @cOption, ' +
               ' @tExtValidate, @nErrNo OUTPUT, @cErrMsg OUTPUT '

            SET @cSQLParam =
               ' @nMobile        INT,           ' +
               ' @nFunc          INT,           ' +
               ' @cLangCode      NVARCHAR( 3),  ' +
               ' @nStep          INT,           ' +
               ' @nInputKey      INT,           ' +
               ' @cFacility      NVARCHAR( 5),  ' +
               ' @cStorerKey     NVARCHAR( 15), ' +
               ' @cMBOLKey       NVARCHAR( 10), ' +
               ' @cRefNo         NVARCHAR( 20), ' +
               ' @cOrderKey      NVARCHAR( 10), ' +
               ' @cPalletLOC     NVARCHAR( 10), ' + 
               ' @cCartonID      NVARCHAR( 20), ' +
               ' @cSKU           NVARCHAR( 20), ' + 
               ' @cData1         NVARCHAR( 20), ' +
               ' @cData2         NVARCHAR( 20), ' +
               ' @cData3         NVARCHAR( 20), ' +
               ' @cData4         NVARCHAR( 20), ' +
               ' @cData5         NVARCHAR( 20), ' +
               ' @cOption        NVARCHAR( 2),  ' +
               ' @tExtValVar     VariableTable READONLY, ' +
               ' @nErrNo         INT           OUTPUT, ' +
               ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
               @cMBOLKey, @cRefNo, @cOrderKey, @cPalletLOC, @cCartonID, @cSKU, @cData1, @cData2, @cData3, @cData4, @cData5, @cOption, 
               @tExtValVar, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_MBOL_Fail
         END
      END

      -- Capture info
      IF @cCaptureInfoSP <> ''
      BEGIN
         EXEC rdt.rdt_CartonToMBOL_CaptureInfo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'DISPLAY',
            @cMBOLKey, @cRefNo, @cOrderKey, @cCartonID, @cData1, @cData2, @cData3, @cData4, @cData5, 
            @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
            @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
            @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
            @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
            @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
            @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
            @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
            @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
            @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
            @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
            @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
            @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
            @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
            @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
            @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
            @tCaptureVar,
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT
         IF @nErrNo <> 0
            GOTO Quit

         -- Go to next screen
         SET @nScn = @nScn_CaptureData
         SET @nStep = @nStep_CaptureData

         GOTO Quit
      END
      -- Get stat
      SET @nTotalCarton = 0
SELECT @nTotalCarton = ISNULL( NoofIDSCarton, 0)
FROM dbo.MBOL WITH (NOLOCK)
WHERE MbolKey = @cMBOLKey
/*      
      SELECT @nTotalCarton = COUNT(1)
      FROM dbo.PalletDetail WITH (NOLOCK)
      WHERE PalletKey = @cMBOLKey
*/      
      -- Prepare next screen var
      SET @cOutField01 = @cMBOLKey
      SET @cOutField02 = ''
      SET @cOutField15 = CAST( @nTotalCarton AS NVARCHAR( 5))

      -- Go to next screen
      SET @nScn = @nScn_Carton
      SET @nStep = @nStep_Carton
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Logging
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign Out
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerkey

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0

      -- Reset all variables
      SET @cOutField01 = ''
   END
   GOTO Quit

   Step_MBOL_Fail:
   BEGIN
      SET @cOutField01 = ''
   END

   GOTO Quit
END
GOTO Quit


/***********************************************************************************
Step 2. Scn = 6241. Capture data screen
   Data1    (field01)
   Input1   (field02, input)
   .
   .
   .
   Data5    (field09)
   Input5   (field10, input)
***********************************************************************************/
Step_CaptureData:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cData1 = CASE WHEN @cFieldAttr02 = '' THEN @cInField02 ELSE @cOutField02 END
      SET @cData2 = CASE WHEN @cFieldAttr04 = '' THEN @cInField04 ELSE @cOutField04 END
      SET @cData3 = CASE WHEN @cFieldAttr06 = '' THEN @cInField06 ELSE @cOutField06 END
      SET @cData4 = CASE WHEN @cFieldAttr08 = '' THEN @cInField08 ELSE @cOutField08 END
      SET @cData5 = CASE WHEN @cFieldAttr10 = '' THEN @cInField10 ELSE @cOutField10 END

      -- Retain value
      SET @cOutField02 = @cInField02
      SET @cOutField04 = @cInField04
      SET @cOutField06 = @cInField06
      SET @cOutField08 = @cInField08
      SET @cOutField10 = @cInField10

      EXEC rdt.rdt_CartonToMBOL_CaptureInfo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'UPDATE',
         @cMBOLKey, @cRefNo, @cOrderKey, @cCartonID, @cData1, @cData2, @cData3, @cData4, @cData5, 
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
         @tCaptureVar,
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT
      IF @nErrNo <> 0
         GOTO Quit

      -- Enable field
      SET @cFieldAttr02 = ''
      SET @cFieldAttr04 = ''
      SET @cFieldAttr06 = ''
      SET @cFieldAttr08 = ''
      SET @cFieldAttr10 = ''

      -- Get stat
      SET @nTotalCarton = 0
SELECT @nTotalCarton = ISNULL( NoofIDSCarton, 0)
FROM dbo.MBOL WITH (NOLOCK)
WHERE MbolKey = @cMBOLKey
/*
      SELECT @nTotalCarton = COUNT(1)
      FROM dbo.PalletDetail WITH (NOLOCK)
      WHERE PalletKey = @cMBOLKey
*/
      -- Prepare next screen var
      SET @cOutField01 = @cMBOLKey
      SET @cOutField02 = ''
      SET @cOutField03 = CAST( @nTotalCarton AS NVARCHAR( 5))

      -- Go to next screen
      SET @nScn = @nScn_Carton
      SET @nStep = @nStep_Carton
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Enable field
      SET @cFieldAttr02 = ''
      SET @cFieldAttr04 = ''
      SET @cFieldAttr06 = ''
      SET @cFieldAttr08 = ''
      SET @cFieldAttr10 = ''

      -- Prepare next screen var
      SET @cOutField01 = '' -- @cMBOLKey

      -- Go to next screen
      SET @nScn = @nScn_MBOL
      SET @nStep = @nStep_MBOL
   END
END
GOTO Quit


/***********************************************************************************
Step 3. Scn = 6242. Carton ID screen
   MBOLKey     (field01)
   CARTON ID   (field02, input)
   SCANNED     (field03)
***********************************************************************************/
Step_Carton:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cCartonID = @cInField02

      -- Check blank
      IF @cCartonID = ''
      BEGIN
         SET @nErrNo = 198859
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need carton ID
         GOTO Step_Carton_Fail
      END

      -- Check format  
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'CartonID', @cCartonID) = 0  
      BEGIN  
         SET @nErrNo = 198860  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet  
         GOTO Quit  
      END  
/*
      -- Check carton ID scanned
      IF EXISTS( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND CaseID = @cCartonID)
      BEGIN
         SET @nErrNo = 198861
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Carton Scanned
         GOTO Step_Carton_Fail
      END
*/
      SET @cOrderKey = ''
      SET @cSKU = ''

      -- Check carton ID (PackDetail.LabelNo)
      IF @cOrderKey = '' AND CHARINDEX( 'L', @cCartonIDSP) > 0 -- L=LabelNo
      BEGIN
         -- Get carton info
         SELECT TOP 1 
            @cOrderKey = PH.OrderKey, 
            @cSKU = SKU
         FROM dbo.PackHeader PH WITH (NOLOCK)
            JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
         WHERE PD.StorerKey = @cStorerKey
            AND PD.LabelNo = @cCartonID
     END

      -- Check carton ID (PackDetail.DropID)
      IF @cOrderKey = '' AND CHARINDEX( 'D2', @cCartonIDSP) > 0 -- D2=PackDetail.DropID
      BEGIN
         -- Get carton info
         SELECT TOP 1 
            @cOrderKey = PH.OrderKey, 
            @cSKU = SKU
         FROM dbo.PackHeader PH WITH (NOLOCK)
            JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
         WHERE PD.StorerKey = @cStorerKey
            AND PD.DropID = @cCartonID
      END

      -- Check carton ID (PickDetail.CaseID)
      IF @cOrderKey = '' AND CHARINDEX( 'C', @cCartonIDSP) > 0 -- C=CaseID
      BEGIN
         -- Get carton info
         SELECT TOP 1 
            @cOrderKey = OrderKey, 
            @cSKU = SKU
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND CaseID = @cCartonID
      END

      -- Check carton ID (PickDetail.DropID)
      IF @cOrderKey = '' AND CHARINDEX( 'D1', @cCartonIDSP) > 0 -- D1=PickDetail.DropID
      BEGIN
         -- Get carton info
         SELECT TOP 1 
            @cOrderKey = OrderKey, 
            @cSKU = SKU
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND DropID = @cCartonID
      END

      -- Check carton ID valid
      IF @cSKU = ''
      BEGIN
         SET @nErrNo = 198862
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid carton
         GOTO Step_Carton_Fail
      END

      -- Check order found
      IF @cOrderKey = ''
      BEGIN
         SET @nErrNo = 198863
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Order
         GOTO Step_Carton_Fail
      END

      -- Check order populated to other MBOL
      IF EXISTS( SELECT 1 FROM dbo.MBOLDetail WITH (NOLOCK) WHERE MBOLKey <> @cMBOLKey AND OrderKey = @cOrderKey)
      BEGIN
         SET @nErrNo = 198864
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --OrderInOthMBOL
         GOTO Step_Carton_Fail
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
               ' @cMBOLKey, @cRefNo, @cOrderKey, @cPalletLOC, @cCartonID, @cSKU, @cData1, @cData2, @cData3, @cData4, @cData5, @cOption, ' +
               ' @tExtValidate, @nErrNo OUTPUT, @cErrMsg OUTPUT '

            SET @cSQLParam =
               ' @nMobile        INT,           ' +
               ' @nFunc          INT,           ' +
               ' @cLangCode      NVARCHAR( 3),  ' +
               ' @nStep          INT,           ' +
               ' @nInputKey      INT,           ' +
               ' @cFacility      NVARCHAR( 5),  ' +
               ' @cStorerKey     NVARCHAR( 15), ' +
               ' @cMBOLKey       NVARCHAR( 10), ' +
               ' @cRefNo         NVARCHAR( 20), ' +
               ' @cOrderKey      NVARCHAR( 10), ' +
               ' @cPalletLOC     NVARCHAR( 10), ' + 
               ' @cCartonID      NVARCHAR( 20), ' +
               ' @cSKU           NVARCHAR( 20), ' + 
               ' @cData1         NVARCHAR( 20), ' +
               ' @cData2         NVARCHAR( 20), ' +
               ' @cData3         NVARCHAR( 20), ' +
               ' @cData4         NVARCHAR( 20), ' +
               ' @cData5         NVARCHAR( 20), ' +
               ' @cOption        NVARCHAR( 2),  ' +
               ' @tExtValVar     VariableTable READONLY, ' +
               ' @nErrNo         INT           OUTPUT, ' +
               ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
               @cMBOLKey, @cRefNo, @cOrderKey, @cPalletLOC, @cCartonID, @cSKU, @cData1, @cData2, @cData3, @cData4, @cData5, @cOption, 
               @tExtValVar, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_Carton_Fail
         END
      END

      -- Confirm
      EXEC rdt.rdt_CartonToMBOL_Confirm
          @nMobile      = @nMobile
         ,@nFunc        = @nFunc
         ,@cLangCode    = @cLangCode
         ,@nStep        = @nStep
         ,@nInputKey    = @nInputKey
         ,@cFacility    = @cFacility
         ,@cStorerKey   = @cStorerKey
         ,@cMBOLKey     = @cMBOLKey
         ,@cRefNo       = @cRefNo
         ,@cOrderKey    = @cOrderKey
         ,@cPalletLOC   = @cPalletLOC
         ,@cCartonID    = @cCartonID
         ,@cSKU         = @cSKU
         ,@cData1       = @cData1
         ,@cData2       = @cData2
         ,@cData3       = @cData3
         ,@cData4       = @cData4
         ,@cData5       = @cData5
         ,@tConfirmVar  = @tConfirmVar
         ,@nTotalCarton = @nTotalCarton OUTPUT
         ,@nErrNo       = @nErrNo       OUTPUT
         ,@cErrMsg      = @cErrMsg      OUTPUT
      IF @nErrNo <> 0
         GOTO Step_Carton_Fail

      -- Prepare next screen var
      SET @cOutField01 = @cMBOLKey
      SET @cOutField02 = '' -- @cCartonID
      SET @cOutField03 = CAST( @nTotalCarton AS NVARCHAR( 5))
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      IF @nTotalCarton > 0
      BEGIN
         -- Prepare next screen var
         SET @cOutField01 = @cMBOLKey
         SET @cOutField02 = ''   -- Option

         -- Go to next screen
         SET @nScn = @nScn_CloseMBOL
         SET @nStep = @nStep_CloseMBOL
      END
      ELSE
      BEGIN
         -- Prepare next screen var
         SET @cOutField01 = '' -- MBOL

         -- Go to next screen
         SET @nScn = @nScn_MBOL
         SET @nStep = @nStep_MBOL
      END
   END
   GOTO Quit

   Step_Carton_Fail:
   BEGIN
      EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @nErrNo, @cErrMsg
      SET @cOutField02 = '' -- Carton ID
   END
END
GOTO Quit


/********************************************************************************
Step 4. Scn = 6243. Close MBOL?
   MBOLKey  (field01)
   OPTION   (field02, input)
********************************************************************************/
Step_CloseMBOL:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cOption = @cInField02

      -- Check blank
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 198865
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Option
         GOTO Step_CloseMBOL_Fail
      END

      -- Check option
      IF @cOption NOT IN ( '1', '2')
      BEGIN
         SET @nErrNo = 198866
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
         GOTO Step_CloseMBOL_Fail
      END

      IF @cOption = '1' -- Yes
      BEGIN
         -- Send MBOL for validation
         UPDATE dbo.MBOL SET
            Status = '5', 
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME()
         WHERE MbolKey = @cMBOLKey

         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 198867
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD MBOL Fail
            GOTO Step_CloseMBOL_Fail
         END
      END

      -- Prepare next screen var
      SET @cOutField01 = '' -- MBOL

      -- Go to next screen
      SET @nScn = @nScn_MBOL
      SET @nStep = @nStep_MBOL
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare next screen var
      SET @cOutField01 = @cMBOLKey
      SET @cOutField02 = '' -- Carton ID
      SET @cOutField03 = CAST( @nTotalCarton AS NVARCHAR( 5))

      -- Go to next screen
      SET @nScn = @nScn_Carton
      SET @nStep = @nStep_Carton
   END
   GOTO Quit

   Step_CloseMBOL_Fail:
   BEGIN
      SET @cOption = ''
      SET @cOutField02 = ''
   END
END
GOTO Quit


/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,

      V_OrderKey = @cOrderKey, 
      V_LOC      = @cPalletLOC, 
      V_SKU      = @cSKU, 

      V_String1  = @cMBOLKey,
      V_String2  = @cRefNo,
      V_String3  = @cCartonID,

      V_String21 = @cExtendedUpdateSP,
      V_String22 = @cExtendedValidateSP,
      V_String23 = @cExtendedInfoSP,
      V_String24 = @cExtendedInfo,
      V_String25 = @cCaptureInfoSP,
      V_String26 = @cCartonIDSP,
      V_String27 = @cAutoGenMBOL, 

      V_String41 = @cData1,
      V_String42 = @cData2,
      V_String43 = @cData3,
      V_String44 = @cData4,
      V_String45 = @cData5,

      V_Integer1 = @nTotalCarton,

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
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_CartonToMBOL TO NSQL
GO