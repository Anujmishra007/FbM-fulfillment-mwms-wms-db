SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 

/******************************************************************************/ 
/* Copyright: Maersk                                                          */ 
/* Purpose: For Levis                                                         */ 
/*                                                                            */ 
/* Modifications log:                                                         */ 
/*                                                                            */ 
/* Date       Rev    Author     Purposes                                      */ 
/* 2025-04-18 1.0.0  Dennis     FCR-4159 Created                              */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtfnc_Floor_Check] (
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
   @cOption     NVARCHAR( 1),
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
   @cMBOLKey      NVARCHAR(10),
   @cConsigneeKey NVARCHAR(15),
   @nDropIDCount  INT,
   @cDropID       NVARCHAR(20),
   @cStatus       NVARCHAR(10),
   @cTruckID      NVARCHAR( 20),
   @cPallet       NVARCHAR( 18),
   @cFromLoc      NVARCHAR( 10),
   @cStatusMessage NVARCHAR( 100),

   @cSealNo1      NVARCHAR(10),
   @cSealNo2      NVARCHAR(10),
   @cSealNo3      NVARCHAR(10),
   @cSealNo4      NVARCHAR(10),
   @cSealNo5      NVARCHAR(10),
   @cSealNo6      NVARCHAR(10),
   @nTotal         INT,
   @nScanned       INT,
   @cExtScnSP     NVARCHAR(20),
   @nAction             INT,
   @nAfterScn           INT,
   @nAfterStep          INT,
   @tExtScnData			VariableTable,

   @cLottable01   NVARCHAR( 18),
   @cLottable02   NVARCHAR( 18),
   @cLottable03   NVARCHAR( 18),
   @dLottable04   DATETIME,
   @dLottable05   DATETIME,
   @cLottable06   NVARCHAR( 30),
   @cLottable07   NVARCHAR( 30),
   @cLottable08   NVARCHAR( 30),
   @cLottable09   NVARCHAR( 30),
   @cLottable10   NVARCHAR( 30),
   @cLottable11   NVARCHAR( 30),
   @cLottable12   NVARCHAR( 30),
   @dLottable13   DATETIME,
   @dLottable14   DATETIME,
   @dLottable15   DATETIME,
   @c_ContainerKey       NVARCHAR(10),

   @cMsg01        NVARCHAR(20),
   @cMsg02        NVARCHAR(20),
   @cMsg03        NVARCHAR(20),
   @cMsg04        NVARCHAR(20),
   @cMsg05        NVARCHAR(20),
   @cMsg06        NVARCHAR(20),
   @cMsg07        NVARCHAR(20),
   @cMsg08        NVARCHAR(20),
   @cMsg09        NVARCHAR(20),
   @cMsg10        NVARCHAR(20),

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

   @cUDF01  NVARCHAR( 250), @cUDF02 NVARCHAR( 250), @cUDF03 NVARCHAR( 250),
   @cUDF04  NVARCHAR( 250), @cUDF05 NVARCHAR( 250), @cUDF06 NVARCHAR( 250),
   @cUDF07  NVARCHAR( 250), @cUDF08 NVARCHAR( 250), @cUDF09 NVARCHAR( 250),
   @cUDF10  NVARCHAR( 250), @cUDF11 NVARCHAR( 250), @cUDF12 NVARCHAR( 250),
   @cUDF13  NVARCHAR( 250), @cUDF14 NVARCHAR( 250), @cUDF15 NVARCHAR( 250),
   @cUDF16  NVARCHAR( 250), @cUDF17 NVARCHAR( 250), @cUDF18 NVARCHAR( 250),
   @cUDF19  NVARCHAR( 250), @cUDF20 NVARCHAR( 250), @cUDF21 NVARCHAR( 250),
   @cUDF22  NVARCHAR( 250), @cUDF23 NVARCHAR( 250), @cUDF24 NVARCHAR( 250),
   @cUDF25  NVARCHAR( 250), @cUDF26 NVARCHAR( 250), @cUDF27 NVARCHAR( 250),
   @cUDF28  NVARCHAR( 250), @cUDF29 NVARCHAR( 250), @cUDF30 NVARCHAR( 250)
   
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
 --@cOrderKey   = V_OrderKey,
   
   @cMBOLKey      = V_String1,
   @cTruckID      = V_String2,     
   @cSealNo1      = V_String4,
   @cSealNo2      = V_String5,
   @cSealNo3      = V_String6,
   @c_ContainerKey = V_String7,

   @nTotal        = V_Integer1,
   @nScanned      = V_Integer2,

   @cExtScnSP     = V_String8,
   @cFromLoc      = V_String9,

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

-- Screen constant  
DECLARE  
   @nStep_FROMLOC          INT,  @nScn_FROMLOC           INT,  
   @nStep_PalletID         INT,  @nScn_PalletID          INT,  
   @nStep_Option           INT,  @nScn_Option            INT,  
   @nStep_ScanPalletID     INT,  @nScn_ScanPalletID      INT,  
   @nStep_SealNo1st        INT,  @nScn_SealNo1st         INT,  
   @nStep_SealNo2nd        INT,  @nScn_SealNo2nd         INT,  
   @nStep_Success          INT,  @nScn_Success           INT  
  
SELECT  
   @nStep_FROMLOC          = 1,   @nScn_FROMLOC          = 6580,  
   @nStep_PalletID         = 2,   @nScn_PalletID         = 6581
  


IF @nFunc = 927 -- Floor Check
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Truck Loading
   IF @nStep = 1 GOTO Step_1   -- Scn = 6580. Fromloc
   IF @nStep = 2 GOTO Step_2   -- Scn = 6581. Pallet ID

END

RETURN -- Do nothing if incorrect step

/********************************************************************************
Step 0. func = 927. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Get prefer UOM
   SET @cPUOM = ''
   SELECT @cPUOM = IsNULL( DefaultUOM, '6') -- If not defined, default as EA
   FROM RDT.rdtMobRec M WITH (NOLOCK)
   INNER JOIN RDT.rdtUser U WITH (NOLOCK) ON (M.UserName = U.UserName)
   WHERE M.Mobile = @nMobile

   -- EventLog - Sign In Function
   EXEC RDT.rdt_STD_EventLog
   @cActionType = '1', -- Sign in function
   @cUserID     = @cUserName,
   @nMobileNo   = @nMobile,
   @nFunctionID = @nFunc,
   @cFacility   = @cFacility,
   @cStorerKey  = @cStorerkey,
   @nStep       = @nStep


   -- Init screen
   SET @cOutField01 = '' 
   
   SET @cFromLoc = ''

   -- Set the entry point
   SET @nScn = @nScn_FROMLOC
   SET @nStep = @nStep_FROMLOC
   
END
GOTO Quit


/********************************************************************************
Step 1. Scn = 6580. 
   Fromloc (Input , Field01)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      SET @cFromLoc = ISNULL(RTRIM(@cInField01),'')
      
      IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK)
      WHERE LocationCategory =  'STAGE' AND PutawayZone='OBSTG' AND Loc = @cFromLoc)
      BEGIN
         SET @nErrNo = 237301
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid FROM LOC
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END
      
      -- Prepare Next Screen Variable
      SET @cOutField01 = @cFromLoc
       
      -- GOTO Next Screen
      SET @nScn = @nScn_PalletID
      SET @nStep = @nStep_PalletID

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
        @cStorerKey  = @cStorerkey,
        @nStep       = @nStep
        
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
   END
   

END 
GOTO QUIT

/********************************************************************************
Step 2. Scn = 6581. 
   Pallet ID (field02, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      SET @cPallet = ISNULL(RTRIM(@cInField02),'')
      -- Validate blank
      IF @cPallet = ''
      BEGIN
         SET @nErrNo = 237302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet ID
         GOTO Step_2_Fail
      END

      IF EXISTS (SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK) WHERE 
      ID = @cPallet AND Status = '9' AND StorerKey = @cStorerKey
      AND LOC = @cFromLoc)
      BEGIN
         SET @cStatusMessage = 'SHIPPED'
         SET @nErrNo = 237303
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet shipped
         SET @cMsg01 = 'Pallet ID:' + @cPallet
         SET @cMsg02 = 'Shipped '
         GOTO STEP_2_SUCCESS
      END
      
      ELSE IF EXISTS (SELECT 1 FROM dbo.PALLETDETAIL WITH (NOLOCK) WHERE 
      PalletKey = @cPallet AND StorerKey = @cStorerKey
      AND LOC = @cFromLoc)
      BEGIN
         SET @cStatusMessage = 'GOOD'
         SET @cMsg01 = 'Pallet ID:' + @cPallet
         SET @cMsg02 = 'Floor Checked '
         SET @cMsg03 = @cFromLoc
         GOTO STEP_2_SUCCESS
      END

      ELSE IF EXISTS (SELECT 1 FROM dbo.PALLETDETAIL WITH (NOLOCK) WHERE 
      PalletKey = @cPallet AND StorerKey = @cStorerKey
      AND LOC <> @cFromLoc)
      BEGIN
         SET @cStatusMessage = 'Wrong Loc'
         SET @cMsg01 = 'Pallet ID:' + @cPallet
         SET @cMsg02 = 'In Different Loc '
         SET @cMsg03 =  @cFromLoc
         GOTO STEP_2_SUCCESS
      END
      ELSE
      BEGIN
         SET @nErrNo = 237302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet ID
         GOTO Step_2_Fail
      END

   STEP_2_SUCCESS:
      INSERT INTO [RDT].[RDTDataCapture]
         (STORERKEY,FACILITY,V_ID,V_STRING1,V_Loc,V_String2,V_STRING3)
      VALUES
         (@cStorerKey, @cFacility, @cPallet,@nFunc, @cFromLoc, CONVERT(VARCHAR(19), GETDATE(), 120), @cStatusMessage)

      EXEC rdt.rdtInsertMsgQueue 
      @nMobile = @nMobile,
      @nErrNo  = @nErrNo,
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

      -- Prepare Next Screen Variable
      SET @cOutField02 = ''  
   END  -- Inputkey = 1

   IF @nInputKey = 0 
   BEGIN
        -- Prepare Previous Screen Variable
       SET @cOutField01 = ''
          
       -- GOTO Previous Screen
       SET @nScn = @nScn_FROMLOC
       SET @nStep = @nStep_FROMLOC
   END
   GOTO Quit

   STEP_2_FAIL:
   BEGIN
      SET @cOutField02 = ''
      SET @cPallet = ''
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
      InputKey  =   @nInputKey,

      V_UOM = @cPUOM,
  
      V_String1 = @cMBOLKey,
      V_String2 = @cTruckID,
      V_String4 = @cSealNo1,
      V_String5 = @cSealNo2,
      V_String6 = @cSealNo3,
      V_String7 = @c_ContainerKey,
      V_String8 = @cExtScnSP,
      V_String9 = @cFromLoc,
      V_Integer1 = @nTotal,
      V_Integer2 = @nScanned,
      
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

GRANT EXECUTE ON [RDT].[rdtfnc_Floor_Check] to nSQL
GO
