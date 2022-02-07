IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdtfnc_PTLPiece]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC rdt.rdtfnc_PTLPiece
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdtfnc_PTLPiece                                           */
/* Copyright: LF Logistics                                                    */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2016-04-25 1.0  Ung        SOS368861 Created                               */
/* 2018-02-05 1.1  James      WMS3893-Add DefaultDeviceID (james01)           */
/* 2018-10-24 1.2  James      WMS6781-Add display who locked station (james02)*/
/* 2019-05-21 1.3  YeeKung    WMS-8762  Add RDT Event Log (yeekung01)         */
/* 2019-10-10 1.4  Chermaine  WMS-10753-Remove EventLog actiontype=3 which    */
/*                            exists in rdt.rdt_PTLPiece_Confirm (cc01)       */
/* 2020-01-16 1.5  James      WMS-11427 Add default method by config (james03)*/
/*                            Add extvalid @ step 1                           */
/* 2021-02-22 1.6  YeeKung    WMS-16066 Add Close carton(yeekung01)           */
/******************************************************************************/

CREATE PROC rdt.rdtfnc_PTLPiece (
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
   @i             INT, 
   @nCount        INT,
   @bSuccess      INT,
   @nTranCount    INT,
   @cSQL          NVARCHAR( MAX),
   @cSQLParam     NVARCHAR( MAX),
   @cIPAddress    NVARCHAR( 40), 
   @cPosition     NVARCHAR( 10), 
   @cOption       NVARCHAR( 1), 
      
   @cResult01  NVARCHAR( 20),
   @cResult02  NVARCHAR( 20),
   @cResult03  NVARCHAR( 20),
   @cResult04  NVARCHAR( 20),
   @cResult05  NVARCHAR( 20),
   @cResult06  NVARCHAR( 20),
   @cResult07  NVARCHAR( 20),
   @cResult08  NVARCHAR( 20),
   @cResult09  NVARCHAR( 20),
   @cResult10  NVARCHAR( 20)

-- RDT.RDTMobRec variable
DECLARE
   @nFunc         INT,
   @nScn          INT,
   @nStep         INT,
   @cLangCode     NVARCHAR( 3),
   @nInputKey     INT,
   @nMenu         INT,

   @cStorerKey    NVARCHAR( 15),
   @cFacility     NVARCHAR( 5),
   @cPrinter      NVARCHAR( 20),
   @cUserName     NVARCHAR( 18),
   @cDeviceID     NVARCHAR( 20),

   @cSKU          NVARCHAR(20),

   @cStation      NVARCHAR(10),
   @cMethod       NVARCHAR(1),
   @cLastPos      NVARCHAR(5),

   @cExtendedValidateSP    NVARCHAR( 20),
   @cExtendedUpdateSP      NVARCHAR( 20),
   @cExtendedInfoSP        NVARCHAR( 20),
   @cDecodeSP         NVARCHAR( 20),
   @cLight                 NVARCHAR( 1),
   @cExtendedInfo          NVARCHAR( 20),
   @cDefaultDeviceID       NVARCHAR( 20), -- (james01)
   @cUserWhoLockedStation  NVARCHAR( 20), -- (james02)
   @cDefaultMethod         NVARCHAR( 1),  -- (james03)
   @tExtValid              VARIABLETABLE,  -- (james03)
   @cCartonID              NVARCHAR(20),
   @cLOC                   NVARCHAR(20),

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
   @cFieldAttr15 NVARCHAR( 1),

   @cErrMsg1    NVARCHAR( 20), @cErrMsg2    NVARCHAR( 20),
   @cErrMsg3    NVARCHAR( 20), @cErrMsg4    NVARCHAR( 20),
   @cErrMsg5    NVARCHAR( 20), @cErrMsg6    NVARCHAR( 20),
   @cErrMsg7    NVARCHAR( 20), @cErrMsg8    NVARCHAR( 20),
   @cErrMsg9    NVARCHAR( 20), @cErrMsg10   NVARCHAR( 20),
   @cErrMsg11   NVARCHAR( 20), @cErrMsg12   NVARCHAR( 20),
   @cErrMsg13   NVARCHAR( 20), @cErrMsg14    NVARCHAR( 20),
   @cErrMsg15   NVARCHAR( 20) 

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
   @cDeviceID  = DeviceID,

   @cSKU        = V_SKU,

   @cStation         = V_String1,
   @cMethod          = V_String2,
   @cLastPos         = V_String3,
   @cIPAddress       = V_String4,
   @cPosition        = V_String5,

   @cExtendedValidateSP = V_String20,
   @cExtendedUpdateSP   = V_String21,
   @cExtendedInfoSP     = V_String22,
   @cDecodeSP           = V_String23,
   @cLight              = V_String24,
   @cExtendedInfo       = V_String25,
   @cCartonID           = V_String26,

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

FROM rdt.rdtMobRec (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 803  -- PTL piece
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- PTL Cart
   IF @nStep = 1 GOTO Step_1   -- Scn = 4590. Station, Method
   IF @nStep = 2 GOTO Step_2   -- Scn = 4591. Dynamic assign
   IF @nStep = 3 GOTO Step_3   -- Scn = 4592. SKU
   IF @nStep = 4 GOTO Step_4   -- Scn = 4593. Unassign cart?
   IF @nStep = 5 GOTO Step_5  -- Scn = 4594 Close Carton
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 803. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Get storer config
   SET @cDecodeSP = rdt.rdtGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
   IF @cDecodeSP = '0'
      SET @cDecodeSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''



   -- (james01)
   SET @cDefaultDeviceID = rdt.RDTGetConfig( @nFunc, 'DefaultDeviceID', @cStorerKey)

   -- (james03)
   SET @cDefaultMethod = rdt.RDTGetConfig( @nFunc, 'DefaultMethod', @cStorerKey)

   -- Get storer config
   DECLARE @cBypassTCPSocket NVARCHAR(1)
   SET @cBypassTCPSocket = ''
   EXECUTE nspGetRight
      NULL,
      @cStorerKey,
      NULL,
      'BypassTCPSocketClient',
      @bSuccess         OUTPUT,
      @cBypassTCPSocket OUTPUT,
      @nErrNo           OUTPUT,
      @cErrMsg          OUTPUT

   -- Light
   IF @cDeviceID <> '' AND @cBypassTCPSocket <> '1'
      SET @cLight = '1' -- Use light
   ELSE
      SET @cLight = '0' -- Not use

   -- EventLog
   EXEC RDT.rdt_STD_EventLog
     @cActionType = '1', -- Sign-in
     @cUserID     = @cUserName,
     @nMobileNo   = @nMobile,
     @nFunctionID = @nFunc,
     @cFacility   = @cFacility,
     @cStorerKey  = @cStorerkey

   -- Init var
   SET @cLastPos = ''

   -- Init screen
   SET @cOutField01 = CASE WHEN @cDefaultDeviceID = '1' AND @cDeviceID <> '' THEN 
                      @cDeviceID ELSE '' END -- Station  (james01)
   SET @cOutField02 = CASE WHEN @cDefaultMethod <> '' THEN @cDefaultMethod ELSE '' END -- Method  (james03)

   -- Set the entry point
   SET @nScn = 4590
   SET @nStep = 1

   EXEC rdt.rdtSetFocusField @nMobile, 1
END
GOTO Quit


/********************************************************************************
Step 1. Scn = 4590.
   Station  (Field01, input)
   Method   (Field02, input)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      -- Screen mapping
      SET @cStation = @cInField01
      SET @cMethod = @cInField02

      -- Validate blank
      IF @cStation = ''
      BEGIN
         SET @nErrNo = 99501
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need station
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Quit
      END

      -- Check station valid
      IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'STATION' AND DeviceID <> '' AND DeviceID = @cStation)
      BEGIN
         SET @nErrNo = 99502
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidStation
         EXEC rdt.rdtSetFocusField @nMobile, 1
         SET @cOutField01 = ''
         GOTO Quit
      END

      -- (james02)
      SET @cUserWhoLockedStation = ''

      -- Check station in use                  
      SELECT @cUserWhoLockedStation = UserName 
      FROM rdt.rdtMobRec WITH (NOLOCK) 
      WHERE Mobile <> @nMobile
      AND   Func = @nFunc 
      AND   @cStation = V_String1

      IF ISNULL( @cUserWhoLockedStation, '') <> ''
      BEGIN
         SET @nErrNo = 99503
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --StationInUse
         EXEC rdt.rdtSetFocusField @nMobile, 1
         SET @cOutField01 = ''

         IF rdt.RDTGetConfig( @nFunc, 'ShowStationInUseWithUserName', @cStorerKey) = '1'
         BEGIN
            SET @cErrMsg1 = SUBSTRING( @cErrMsg, 7, 14)
            SET @cErrMsg2 = SUBSTRING( rdt.rdtgetmessage( 99512, @cLangCode, 'DSP'), 7, 14) --Locked By
            SET @cErrMsg3 = @cUserWhoLockedStation
            SET @nErrNo = 0
            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
            IF @nErrNo = 1
            BEGIN
               SET @cErrMsg1 = ''
               SET @cErrMsg2 = ''
               SET @cErrMsg3 = ''
            END   
         END

         GOTO Quit
      END
      SET @cOutField01 = @cStation
                  
      -- Check blank
      IF @cMethod = ''
      BEGIN
         SET @nErrNo = 99504
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need method
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Quit
      END

      -- Get method info
      DECLARE @cMethodSP SYSNAME
      SET @cMethodSP = ''
      SELECT @cMethodSP = ISNULL( UDF01, '')
      FROM CodeLKUP WITH (NOLOCK)
      WHERE ListName = 'PTLPiece'
         AND Code = @cMethod
         AND StorerKey = @cStorerKey

      -- Check method
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 99505
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid method
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Quit
      END

      -- Check method SP
      IF NOT EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cMethodSP AND type = 'P')
      BEGIN
         SET @nErrNo = 99506
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SetupMethodSP
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Quit
      END
      SET @cOutField02 = @cMethod

      --james03
      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLastPos, @cOption, ' +
               ' @tExtValid, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' + 
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cStation     NVARCHAR( 10), ' +
               '@cMethod      NVARCHAR( 1),  ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLastPos     NVARCHAR( 10), ' +
               '@cOption      NVARCHAR( 1),  ' +
               '@tExtValid    VariableTable READONLY, ' +
               '@nErrNo       INT            OUTPUT,  ' +
               '@cErrMsg      NVARCHAR( 20)  OUTPUT   '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLastPos, @cOption,
               @tExtValid, @nErrNo OUTPUT, @cErrMsg OUTPUT
            
            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- Dynamic assign
      EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
         @cStation, @cMethod, 'POPULATE-IN',
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
         @nScn        OUTPUT,
         @nErrNo      OUTPUT,
         @cErrMsg     OUTPUT
      IF @nErrNo <> 0
         GOTO Quit

      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0
   BEGIN
      -- EventLog
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign-out
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerkey

      -- Back to main menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
      SET @cOutField02 = ''
   END
END
GOTO QUIT


/********************************************************************************
Step 2. Scn = 4591. Dynamic assign
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      -- Dynamic assign
      EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
         @cStation, @cMethod, 'CHECK',
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
         @nScn        OUTPUT,
         @nErrNo      OUTPUT,
         @cErrMsg     OUTPUT
      IF @nErrNo <> 0
         GOTO Quit

      SET @cLastPos = ''

      -- Prepare next screen var
      SET @cOutField01 = '' --Result01
      SET @cOutField02 = '' 
      SET @cOutField03 = '' 
      SET @cOutField04 = '' 
      SET @cOutField05 = '' 
      SET @cOutField06 = '' 
      SET @cOutField07 = '' 
      SET @cOutField08 = '' 
      SET @cOutField09 = '' 
      SET @cOutField10 = '' --Result10
      SET @cOutField11 = '' --@cSKU
      SET @cOutField12 = '' --@cLastPos

      -- Go to matrix, SKU screen
      SET @nScn = 4592
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0
   BEGIN
      -- Dynamic assign  
      EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
         @cStation, @cMethod, 'POPULATE-OUT',  
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  
         @nScn        OUTPUT,  
         @nErrNo      OUTPUT,  
         @cErrMsg     OUTPUT  
      IF @nErrNo <> 0  
         GOTO Quit  

      -- Get method info
      DECLARE @cShort NVARCHAR(10)
      SET @cShort = ''
      SELECT @cShort = Short
      FROM CodeLKUP WITH (NOLOCK) 
      WHERE ListName = 'PTLPiece' 
         AND Code = @cMethod 
         AND StorerKey = @cStorerKey
      
      -- Unassign station
      IF CHARINDEX( 'U', @cShort) > 0 -- U=Unassign
      BEGIN
         -- Prep next screen var
         SET @cOutfield01 = '' -- Option
         
         -- Go to unassign station screen
         SET @nScn = 4591 + 2
         SET @nStep = @nStep + 2
      END
      ELSE
      BEGIN
         -- Prep next screen var
         SET @cOutfield01 = @cStation
         SET @cOutfield02 = @cMethod
   
         EXEC rdt.rdtSetFocusField @nMobile, 1 -- Station1
   
         -- Go to cart screen
         SET @nScn = 4591 - 1
         SET @nStep = @nStep - 1
      END
   END
END
GOTO QUIT


/********************************************************************************
Step 3. Scn = 4592. Matrix, SKU screen
   Result01 (Field01)
   Result02 (Field02)
   Result03 (Field03)
   Result04 (Field04)
   Result05 (Field05)
   Result06 (Field06)
   Result07 (Field07)
   Result08 (Field08)
   Result09 (Field09)
   Result10 (Field10)
   SKU      (Field11, input)
   LAST     (Field12)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      DECLARE @cBarcode NVARCHAR( 60)
      DECLARE @cUPC     NVARCHAR( 30)

      -- Screen mapping
      SET @cBarcode = @cInField11 -- SKU
      SET @cUPC = LEFT( @cInField11, 30)
      SET @cOption = @cInField13

      IF @cOption='9'
      BEGIN
         SET @cOutField01=''
         SET @cOutField02=''

         SET @nStep=@nStep+2
         SET @nScn=@nScn+2
         GOTO Quit
      END

      -- Check blank
		IF @cBarcode = ''
      BEGIN
         SET @nErrNo = 99507
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need SKU
         GOTO Step_3_Fail
      END
   
      -- Decode
      IF @cDecodeSP <> ''
      BEGIN
         -- Standard decode
         IF @cDecodeSP = '1'
         BEGIN
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode, 
               @cUPC    = @cUPC     OUTPUT, 
               @nErrNo  = @nErrNo   OUTPUT, 
               @cErrMsg = @cErrMsg  OUTPUT
         END
         
         -- Customize decode
         ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cBarcode, ' +
               ' @cUPC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               ' @nMobile      INT,           ' +
               ' @nFunc        INT,           ' +
               ' @cLangCode    NVARCHAR( 3),  ' +
               ' @nStep        INT,           ' +
               ' @nInputKey    INT,           ' +
               ' @cFacility    NVARCHAR( 5),  ' +
               ' @cStorerKey   NVARCHAR( 15), ' +
               ' @cStation     NVARCHAR( 10), ' +
               ' @cMethod      NVARCHAR( 10), ' +
               ' @cBarcode     NVARCHAR( 60), ' +
               ' @cUPC         NVARCHAR( 30)  OUTPUT, ' +
               ' @nErrNo       INT            OUTPUT, ' +
               ' @cErrMsg      NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cBarcode, 
               @cUPC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_3_Fail
         END
      END

      -- Get SKU count
      DECLARE @nSKUCnt INT
      SET @nSKUCnt = 0
      EXEC RDT.rdt_GetSKUCNT
          @cStorerKey  = @cStorerKey
         ,@cSKU        = @cUPC
         ,@nSKUCnt     = @nSKUCnt   OUTPUT
         ,@bSuccess    = @bSuccess  OUTPUT
         ,@nErr        = @nErrNo    OUTPUT
         ,@cErrMsg     = @cErrMsg   OUTPUT

      -- Check SKU valid
      IF @nSKUCnt = 0
      BEGIN
         SET @nErrNo = 99508
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
         GOTO Step_3_Fail
      END

      IF @nSKUCnt = 1
         EXEC rdt.rdt_GetSKU
             @cStorerKey  = @cStorerKey
            ,@cSKU        = @cUPC      OUTPUT
            ,@bSuccess    = @bSuccess  OUTPUT
            ,@nErr        = @nErrNo    OUTPUT
            ,@cErrMsg     = @cErrMsg   OUTPUT

      -- Check barcode return multi SKU
      IF @nSKUCnt > 1
      BEGIN
         SET @nErrNo = 99509
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod
         GOTO Step_3_Fail
      END
      SET @cSKU = @cUPC

      -- Confirm task
      EXEC rdt.rdt_PTLPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
         ,@cLight
         ,@cStation
         ,@cMethod
         ,@cSKU
         ,@cIPAddress OUTPUT
         ,@cPosition  OUTPUT
         ,@nErrNo     OUTPUT
         ,@cErrMsg    OUTPUT
         ,@cResult01  OUTPUT
         ,@cResult02  OUTPUT
         ,@cResult03  OUTPUT
         ,@cResult04  OUTPUT
         ,@cResult05  OUTPUT
         ,@cResult06  OUTPUT
         ,@cResult07  OUTPUT
         ,@cResult08  OUTPUT
         ,@cResult09  OUTPUT
         ,@cResult10  OUTPUT
      IF @nErrNo <> 0
         GOTO Step_3_Fail

      -- Prepare next screen var
      SET @cOutField01 = @cResult01
      SET @cOutField02 = @cResult02
      SET @cOutField03 = @cResult03
      SET @cOutField04 = @cResult04
      SET @cOutField05 = @cResult05
      SET @cOutField06 = @cResult06
      SET @cOutField07 = @cResult07
      SET @cOutField08 = @cResult08
      SET @cOutField09 = @cResult09
      SET @cOutField10 = @cResult10
      SET @cOutField11 = '' -- SKU
      SET @cOutField12 = @cLastPos
      
      /*-- EventLog - Sign In Function -- (yeekung01)     
      EXEC RDT.rdt_STD_EventLog    
         @cActionType = '3', -- Sign in function    
         @nMobileNo   = @nMobile,    
         @nFunctionID = @nFunc,    
         @cFacility   = @cFacility,    
         @cStorerKey  = @cStorerKey,  
         @cSKU        = @cSKU,        
         @nStep       = @nStep */ --(cc01)      
        
      -- Save last position
      SET @cLastPos = ''
      SELECT @cLastPos = LEFT( LogicalName, 5)
      FROM DeviceProfile WITH (NOLOCK)
      WHERE DeviceType = 'STATION'
         AND DeviceID = @cStation
         AND DeviceID <> ''
         AND IPAddress = @cIPAddress
         AND DevicePosition = @cPosition

      -- Remain in current screen
      -- SET @nScn = @nScn + 1
      -- SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0
   BEGIN
      -- Extended validate
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLastPos, @cOption, ' +
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' + 
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cStation     NVARCHAR( 10), ' +
               '@cMethod      NVARCHAR( 1),  ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLastPos     NVARCHAR( 10), ' +
               '@cOption      NVARCHAR( 1),  ' +
               '@nErrNo       INT            OUTPUT, ' +
               '@cErrMsg      NVARCHAR( 20)  OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLastPos, @cOption,
               @nErrNo OUTPUT, @cErrMsg OUTPUT
            
            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- Dynamic assign  
      EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
         @cStation, @cMethod, 'POPULATE-IN',  
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  
         @nScn        OUTPUT,  
         @nErrNo      OUTPUT,  
         @cErrMsg     OUTPUT  
      IF @nErrNo <> 0  
         GOTO Quit  
  
      SET @nStep = @nStep - 1  
   END
   GOTO Quit

   Step_3_Fail:
   BEGIN
      -- Blank the matrix 
      SET @cOutField01 = ''
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutField04 = ''
      SET @cOutField05 = ''
      SET @cOutField06 = ''
      SET @cOutField07 = ''
      SET @cOutField08 = ''
      SET @cOutField09 = ''
      SET @cOutField10 = ''
      SET @cOutField11 = '' -- SKU
/*
      -- Off all lights
      IF @cLight = '1'
      BEGIN
         -- Clear light
         EXEC PTL.isp_PTL_TerminateModule
             @cStorerKey
            ,@nFunc
            ,@cStation
            ,'STATION'
            ,@bSuccess    OUTPUT
            ,@nErrNo      --OUTPUT -- Prevent PTL overwrite RDT error
            ,@cErrMsg     --OUTPUT -- Prevent PTL overwrite RDT error
         IF @nErrNo <> 0
            GOTO Quit
      END
*/
   END
END
GOTO QUIT


/********************************************************************************
Step 4. Scn = 4593. Unassign cart screen
   Unassign cart?
   1 = YES
   9 = NO
   Option   (field01, input)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cOption = @cInField01

      -- Check blank
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 99510
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Option
         GOTO Quit
      END

      -- Check valid option
      IF @cOption <> '1' AND @cOption <> '9'
      BEGIN
         SET @nErrNo = 99511
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
         GOTO Quit
      END

      --james03
      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLastPos, @cOption, ' +
               ' @tExtValid, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile      INT,           ' +
               '@nFunc        INT,           ' +
               '@cLangCode    NVARCHAR( 3),  ' +
               '@nStep        INT,           ' +
               '@nInputKey    INT,           ' +
               '@cFacility    NVARCHAR( 5),  ' + 
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cStation     NVARCHAR( 10), ' +
               '@cMethod      NVARCHAR( 1),  ' +
               '@cSKU         NVARCHAR( 20), ' +
               '@cLastPos     NVARCHAR( 10), ' +
               '@cOption      NVARCHAR( 1),  ' +
               '@tExtValid    VariableTable READONLY, ' +
               '@nErrNo       INT            OUTPUT,  ' +
               '@cErrMsg      NVARCHAR( 20)  OUTPUT   '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLastPos, @cOption,
               @tExtValid, @nErrNo OUTPUT, @cErrMsg OUTPUT
            
            IF @nErrNo <> 0
               GOTO Quit
         END
      END
      
      IF @cOption = '1' -- Yes
      BEGIN
         -- Dynamic assign
         EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
            @cStation, @cMethod, 'POPULATE-OUT',
            @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
            @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
            @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
            @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
            @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
            @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
            @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
            @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
            @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
            @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
            @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
            @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
            @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
            @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
            @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
            @nScn        OUTPUT,
            @nErrNo      OUTPUT,
            @cErrMsg     OUTPUT
         IF @nErrNo <> 0
            GOTO Quit

         -- Close station
         EXEC rdt.rdt_PTLPiece_Unassign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey
            ,@cStation
            ,@cMethod
            ,@nErrNo     OUTPUT
            ,@cErrMsg    OUTPUT
         IF @nErrNo <> 0
            GOTO Quit

         -- Prep next screen var
         SET @cOutField01 = @cStation
         SET @cOutField02 = @cMethod
   
         EXEC rdt.rdtSetFocusField @nMobile, 1 -- Station
   
         -- Go to station screen
         SET @nScn = @nScn - 3
         SET @nStep = @nStep - 3
         
         GOTO Quit
      END
      
      IF @cOption = '9' -- No
      BEGIN
         -- Prepare next screen var
         SET @cOutField01 = @cStation
         SET @cOutField02 = @cMethod
   
         -- Go to station screen
         SET @nScn = @nScn - 3
         SET @nStep = @nStep - 3
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Dynamic assign
      EXEC rdt.rdt_PTLPiece_Assign @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
         @cStation, @cMethod, 'POPULATE-IN',
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
         @nScn        OUTPUT,
         @nErrNo      OUTPUT,
         @cErrMsg     OUTPUT
      IF @nErrNo <> 0
         GOTO Quit
   
      -- Go to assign screen
      SET @nStep = @nStep - 2
   END
END
GOTO QUIT


/********************************************************************************
Step 5. Scn = 4594 Carton ID screen
   Carton ID
   (field01, input)
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      SET @cLOC=@cInField01
      SET @cCartonID=@cInField02

      -- Validate blank
      IF @cLOC = ''
      BEGIN
         SET @nErrNo = 99513
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need station
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Quit
      END

      SET @cOutField01 = @cLOC

      -- Validate blank
      IF @cCartonID = ''
      BEGIN
         SET @nErrNo = 99514
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need station
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Quit
      END

      -- Close station
      EXEC rdt.rdt_PTLPiece_CloseCarton @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,@cStation,@cPosition,@cLOC
         ,@cCartonID
         ,@nErrNo     OUTPUT
         ,@cErrMsg    OUTPUT
      IF @nErrNo <> 0
         GOTO Quit

      SET @cLastPos = ''

      -- Prepare next screen var
      SET @cOutField01 = '' --Result01
      SET @cOutField02 = '' 
      SET @cOutField03 = '' 
      SET @cOutField04 = '' 
      SET @cOutField05 = '' 
      SET @cOutField06 = '' 
      SET @cOutField07 = '' 
      SET @cOutField08 = '' 
      SET @cOutField09 = '' 
      SET @cOutField10 = '' --Result10
      SET @cOutField11 = '' --@cSKU
      SET @cOutField12 = '' --@cLastPos

      -- Go to matrix, SKU screen
      SET @nScn = 4592
      SET @nStep=@nStep-2
   END

   IF @nInputKey = 0
   BEGIN
      -- Prepare next screen var
      SET @cOutField01 = '' --Result01
      SET @cOutField02 = '' 
      SET @cOutField03 = '' 
      SET @cOutField04 = '' 
      SET @cOutField05 = '' 
      SET @cOutField06 = '' 
      SET @cOutField07 = '' 
      SET @cOutField08 = '' 
      SET @cOutField09 = '' 
      SET @cOutField10 = '' --Result10
      SET @cOutField11 = '' --@cSKU
      SET @cOutField12 = '' --@cLastPos

      -- Go to matrix, SKU screen
      SET @nScn = 4592
      SET @nStep=@nStep-2
   END
END
GOTO QUIT


/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:

BEGIN
   UPDATE RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(), 
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,

      StorerKey = @cStorerKey,
      Facility  = @cFacility,
      Printer   = @cPrinter,
      -- UserName  = @cUserName,
      InputKey  = @nInputKey,

      V_SKU      = @cSKU,

      V_String1  = @cStation,
      V_String2  = @cMethod,
      V_String3  = @cLastPos,
      V_String4  = @cIPAddress,
      V_String5  = @cPosition,
   
      V_String20 = @cExtendedValidateSP,
      V_String21 = @cExtendedUpdateSP,
      V_String22 = @cExtendedInfoSP,
      V_String23 = @cDecodeSP,
      V_String24 = @cLight,
      V_String25 = @cExtendedInfo,
      V_String26 = @cCartonID,

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

GRANT EXECUTE ON [RDT].[rdtfnc_PTLPiece] to nSQL
GO