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
/* 2026-06-18 2.0.0  Dennis     FCR-13604 New 6-screen carton check flow      */
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

   @cFromID            NVARCHAR(20),
   @cCartonID          NVARCHAR(20),
   @cActualPalletKey   NVARCHAR(20),
   @cStatusCode        NVARCHAR(20),
   @cUCC01        NVARCHAR(20),
   @cUCC02        NVARCHAR(20),
   @cUCC03        NVARCHAR(20),
   @cUCC04        NVARCHAR(20),
   @cUCC05        NVARCHAR(20),
   @cDisplayUCC   NVARCHAR(10),
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

DECLARE @tUCC TABLE (RowNum INT, UCC NVARCHAR(20))

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
   @cFromID       = V_String3,
   @cSealNo1      = V_String4,
   @cSealNo2      = V_String5,
   @cSealNo3      = V_String6,
   @c_ContainerKey = V_String7,

   @nTotal        = V_Integer1,
   @nScanned      = V_Integer2,

   @cExtScnSP     = V_String8,
   @cFromLoc      = V_String9,
   @cCartonID     = V_String10,
   @cDisplayUCC   = V_String11,

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
   @nStep_FROMLOC    INT,  @nScn_FROMLOC    INT,
   @nStep_FromID     INT,  @nScn_FromID     INT,
   @nStep_CartonID   INT,  @nScn_CartonID   INT,
   @nStep_UCCList    INT,  @nScn_UCCList    INT,
   @nStep_Msg      INT,  @nScn_Msg      INT,
   @nStep_CartonMsg  INT,  @nScn_CartonMsg  INT

SELECT
   @nStep_FROMLOC   = 1,  @nScn_FROMLOC   = 6580,
   @nStep_FromID    = 2,  @nScn_FromID    = 6581,
   @nStep_CartonID  = 3,  @nScn_CartonID  = 6582,
   @nStep_UCCList   = 4,  @nScn_UCCList   = 6583,
   @nStep_Msg     = 5,  @nScn_Msg     = 6584,
   @nStep_CartonMsg = 6,  @nScn_CartonMsg = 6585
  


IF @nFunc = 927 -- Floor Check
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Init
   IF @nStep = 1 GOTO Step_1   -- Scn = 6580. FROM LOC
   IF @nStep = 2 GOTO Step_2   -- Scn = 6581. FROM ID
   IF @nStep = 3 GOTO Step_3   -- Scn = 6582. CARTON ID
   IF @nStep = 4 GOTO Step_4   -- Scn = 6583. UCC List
   IF @nStep = 5 GOTO Step_5   -- Scn = 6584. Msg
   IF @nStep = 6 GOTO Step_6   -- Scn = 6585. Carton Msg

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

   -- Load storer config
   SET @cDisplayUCC = rdt.RDTGetConfig(@nFunc, 'DISPLAYUCC', @cStorerKey)

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
      SET @nScn  = @nScn_FromID
      SET @nStep = @nStep_FromID

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
Step 2. Scn = 6581. FROM ID
   FROM LOC  (field01, display)
   FROM ID   (field02, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cFromID = ISNULL(RTRIM(@cInField02), '')

      IF @cFromID = ''
      BEGIN
         SET @nErrNo  = 237302
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid Pallet ID
         GOTO Step_2_Fail
      END

      IF EXISTS (SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK)
         WHERE ID = @cFromID AND Status = '9'
         AND StorerKey = @cStorerKey AND LOC = @cFromLoc)
      BEGIN
         -- SHIPPED: insert record + show message, stay on Step 2
         SET @cStatusMessage = 'SHIPPED'
         SET @nErrNo  = 237303
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Pallet shipped
         SET @cMsg01  = 'Pallet ID:' + @cFromID
         SET @cMsg02  = 'Shipped'

         INSERT INTO RDT.RDTDataCapture
            (STORERKEY, FACILITY, V_ID, V_STRING1, V_Loc, V_String2, V_STRING3)
         VALUES
            (@cStorerKey, @cFacility, @cFromID, TRY_CAST(@nFunc AS NVARCHAR(10)) + 'P',
             @cFromLoc, CONVERT(VARCHAR(19), GETDATE(), 120), @cStatusMessage)

         EXEC rdt.rdtInsertMsgQueue
            @nMobile     = @nMobile,
            @nErrNo      = @nErrNo,
            @cErrMsg     = @cErrMsg,
            @cLine01     = @cMsg01,
            @cLine02     = @cMsg02,
            @cLine03     = @cMsg03,
            @cLine04     = @cMsg04,
            @cLine05     = @cMsg05,
            @cLine06     = @cMsg06,
            @cLine07     = @cMsg07,
            @cLine08     = @cMsg08,
            @cLine09     = @cMsg09,
            @nDisplayMsg = 0

         SET @cFromID     = ''
         SET @cOutField02 = ''
         GOTO Quit
      END

      ELSE IF EXISTS (SELECT 1 FROM dbo.PALLETDETAIL WITH (NOLOCK)
         WHERE PalletKey = @cFromID AND StorerKey = @cStorerKey)
      BEGIN
         -- GOOD or WRONG LOC: proceed to Step 3 (carton-level check)
         SET @cCartonID   = ''
         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = @cFromID

         SET @nScn  = @nScn_CartonID
         SET @nStep = @nStep_CartonID
         GOTO Quit
      END
      ELSE
      BEGIN
         SET @nErrNo  = 237302
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid Pallet ID
         GOTO Step_2_Fail
      END
   END -- InputKey = 1

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cFromID     = ''
      SET @cOutField01 = ''

      SET @nScn  = @nScn_FROMLOC
      SET @nStep = @nStep_FROMLOC
   END
   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cOutField02 = ''
   END

END
GOTO Quit

/********************************************************************************
Step 3. Scn = 6582. CARTON ID
   FROM LOC  (field01, display)
   FROM ID   (field02, display)
   CARTON ID (field03, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      SET @cCartonID = ISNULL(RTRIM(@cInField03), '')

      IF @cCartonID = '99'
      BEGIN
         -- Pallet-level floor check using FROM ID (@cFromID)
         SET @cStatusMessage = ''

         IF EXISTS (SELECT 1 FROM dbo.PALLETDETAIL WITH (NOLOCK)
            WHERE PalletKey = @cFromID AND StorerKey = @cStorerKey
            AND LOC = @cFromLoc)
         BEGIN
            SET @cStatusMessage = 'GOOD'
         END
         ELSE IF EXISTS (SELECT 1 FROM dbo.PALLETDETAIL WITH (NOLOCK)
            WHERE PalletKey = @cFromID AND StorerKey = @cStorerKey
            AND LOC <> @cFromLoc)
         BEGIN
            SET @cStatusMessage = 'WRONG LOC'
         END

         INSERT INTO RDT.RDTDataCapture
            (STORERKEY, FACILITY, V_ID, V_STRING1, V_Loc, V_String2, V_STRING3)
         VALUES
            (@cStorerKey, @cFacility, @cFromID, TRY_CAST(@nFunc AS NVARCHAR(10)) + 'P',
             @cFromLoc, CONVERT(VARCHAR(19), GETDATE(), 120), @cStatusMessage)

         -- Prepare next screen var
         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = @cFromID
         SET @cOutField03 = @cStatusMessage

         SET @nScn  = @nScn_Msg
         SET @nStep = @nStep_Msg
         GOTO Quit
      END

      -- Validate CARTON ID against PALLETDETAIL.CaseID
      IF NOT EXISTS (SELECT 1 FROM dbo.PALLETDETAIL WITH (NOLOCK)
         WHERE CaseID    = @cCartonID
         AND   StorerKey = @cStorerKey
         AND   LOC       = @cFromLoc)
      BEGIN
         SET @nErrNo  = 237304
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid Carton ID
         GOTO Step_3_Fail
      END

      -- Check DISPLAYUCC storer config
      IF @cDisplayUCC = '1'
      BEGIN
         -- Fetch all UCCs via PICKDETAIL → UCC table (page 1)
         DELETE FROM @tUCC
         INSERT INTO @tUCC (RowNum, UCC)
         SELECT ROW_NUMBER() OVER (ORDER BY PD.PickDetailKey), U.UCCNo
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         JOIN dbo.UCC U WITH (NOLOCK)
            ON  U.SKU       = PD.SKU
            AND U.Lot       = PD.Lot
            AND U.WaveKey   = PD.WaveKey
            AND U.StorerKey = PD.StorerKey
         WHERE PD.StorerKey = @cStorerKey
         AND   PD.CaseID    = @cCartonID
         AND   PD.Status   <> '4'

         SELECT @nTotal = COUNT(1) FROM @tUCC

         IF @nTotal > 0
         BEGIN
            SET @nScanned = 1

            SELECT @cUCC01 = ISNULL(MAX(CASE WHEN RowNum = 1 THEN UCC END), '') FROM @tUCC
            SELECT @cUCC02 = ISNULL(MAX(CASE WHEN RowNum = 2 THEN UCC END), '') FROM @tUCC
            SELECT @cUCC03 = ISNULL(MAX(CASE WHEN RowNum = 3 THEN UCC END), '') FROM @tUCC
            SELECT @cUCC04 = ISNULL(MAX(CASE WHEN RowNum = 4 THEN UCC END), '') FROM @tUCC
            SELECT @cUCC05 = ISNULL(MAX(CASE WHEN RowNum = 5 THEN UCC END), '') FROM @tUCC

            -- XX = current page, YY = total pages (CEILING(@nTotal/5))
            SET @cOutField01 = @cFromLoc
            SET @cOutField02 = @cFromID
            SET @cOutField03 = @cCartonID
            SET @cOutField04 = @cUCC01
            SET @cOutField05 = @cUCC02
            SET @cOutField06 = @cUCC03
            SET @cOutField07 = @cUCC04
            SET @cOutField08 = @cUCC05
            SET @cOutField09 = RIGHT('00' + TRY_CAST(@nScanned AS NVARCHAR(2)), 2)
                             + '/' + RIGHT('00' + TRY_CAST((@nTotal + 4) / 5 AS NVARCHAR(2)), 2)

            SET @nScn  = @nScn_UCCList
            SET @nStep = @nStep_UCCList
            GOTO Quit
         END
      END

      -- DISPLAYUCC = 0, or no UCCs found: run status checks then go to Screen 6
      SET @cActualPalletKey = ''

      IF EXISTS (
         SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   CaseID    = @cCartonID
         AND   Status    = '9'
      )
      BEGIN
         SET @cStatusMessage = 'CARTON SHIPPED'
         SET @cStatusCode    = 'SHIPPED'
      END
      ELSE IF EXISTS (
         SELECT 1 FROM dbo.PACKINFO WITH (NOLOCK)
         WHERE REFNO      = @cCartonID
         AND   CartonType <> '9999'
      )
      BEGIN
         SET @cStatusMessage = 'LOOSE PICK: NO UCCs'
         SET @cStatusCode    = 'NO UCCs'
      END
      ELSE IF EXISTS (
         SELECT 1 FROM dbo.PACKINFO WITH (NOLOCK)
         WHERE REFNO  = @cCartonID
         AND   STATUS <> 'PACKED'
      )
      BEGIN
         SET @cStatusMessage = 'CARTON NOT PACKED'
         SET @cStatusCode    = 'CARTON NOT PACKED'
      END
      ELSE
      BEGIN
         SELECT @cStatusMessage   = CASE
                  WHEN PalletKey <> ISNULL(@cFromID, '') THEN 'CARTON DIFF PALLET:'
                  ELSE 'FLOOR CHECKED'
               END,
               @cStatusCode      = CASE
                  WHEN PalletKey <> ISNULL(@cFromID, '') THEN 'WRONG PALLET'
                  ELSE 'GOOD'
               END,
               @cActualPalletKey = CASE
                  WHEN PalletKey <> ISNULL(@cFromID, '') THEN PalletKey
                  ELSE ''
               END
         FROM dbo.PALLETDETAIL WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   CaseID    = @cCartonID
      END

      INSERT INTO RDT.RDTDataCapture
         (STORERKEY, FACILITY, V_ID, V_STRING1, V_Loc, V_String4, V_String2, V_STRING3)
      VALUES
         (@cStorerKey, @cFacility, @cFromID, TRY_CAST(@nFunc AS NVARCHAR(10)) + 'C',
          @cFromLoc, @cCartonID, CONVERT(NVARCHAR(19), GETDATE(), 120), @cStatusCode)

      SET @cOutField01 = @cFromLoc
      SET @cOutField02 = @cFromID
      SET @cOutField03 = @cCartonID
      SET @cOutField04 = @cStatusMessage
      SET @cOutField05 = ISNULL(@cActualPalletKey, '')

      SET @nScn  = @nScn_CartonMsg
      SET @nStep = @nStep_CartonMsg
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cCartonID   = ''
      SET @cOutField03 = ''

      SET @nScn  = @nScn_FromID
      SET @nStep = @nStep_FromID
   END
   GOTO Quit

   Step_3_Fail:
   BEGIN
      SET @cOutField03 = ''
   END

END
GOTO Quit

/********************************************************************************
Step 4. Scn = 6583. UCC List
   FROM LOC  (field01, display)
   FROM ID   (field02, display)
   CARTON ID (field03, display)
   UCC 1-5   (field04-08, display)
   XX/YY     (field09, display)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Advance to next page
      SET @nScanned = ISNULL(@nScanned, 1) + 1

      IF @nScanned > (ISNULL(@nTotal, 0) + 4) / 5
      BEGIN
         SET @cActualPalletKey = ''

         -- Priority 1: SHIPPED
         IF EXISTS (
            SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND   CaseID    = @cCartonID
            AND   Status    = '9'
         )
         BEGIN
            SET @cStatusMessage = 'CARTON SHIPPED'
            SET @cStatusCode    = 'SHIPPED'
         END
         -- Priority 2: Loose pick (CartonType <> '9999')
         ELSE IF EXISTS (
            SELECT 1 FROM dbo.PACKINFO WITH (NOLOCK)
            WHERE REFNO      = @cCartonID
            AND   CartonType <> '9999'
         )
         BEGIN
            SET @cStatusMessage = 'LOOSE PICK: NO UCCs'
            SET @cStatusCode    = 'NO UCCs'
         END
         -- Priority 3: Carton not packed
         ELSE IF EXISTS (
            SELECT 1 FROM dbo.PACKINFO WITH (NOLOCK)
            WHERE REFNO   = @cCartonID
            AND   STATUS  <> 'PACKED'
         )
         BEGIN
            SET @cStatusMessage = 'CARTON NOT PACKED'
            SET @cStatusCode    = 'CARTON NOT PACKED'
         END
         ELSE
         BEGIN
            -- Priority 4: Wrong pallet / Priority 5: Floor checked
            SELECT @cStatusMessage    = CASE
                     WHEN PalletKey <> ISNULL(@cFromID, '') THEN 'CARTON DIFF PALLET:'
                     ELSE 'FLOOR CHECKED'
                  END,
                  @cStatusCode       = CASE
                     WHEN PalletKey <> ISNULL(@cFromID, '') THEN 'WRONG PALLET'
                     ELSE 'GOOD'
                  END,
                  @cActualPalletKey  = CASE
                     WHEN PalletKey <> ISNULL(@cFromID, '') THEN PalletKey
                     ELSE ''
                  END
            FROM dbo.PALLETDETAIL WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND   CaseID    = @cCartonID
         END

         INSERT INTO RDT.RDTDataCapture
            (STORERKEY, FACILITY, V_ID, V_STRING1, V_Loc, V_String4, V_String2, V_STRING3)
         VALUES
            (@cStorerKey, @cFacility, @cFromID, TRY_CAST(@nFunc AS NVARCHAR(10)) + 'C',
             @cFromLoc, @cCartonID, CONVERT(NVARCHAR(19), GETDATE(), 120), @cStatusCode)

         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = @cFromID
         SET @cOutField03 = @cCartonID
         SET @cOutField04 = @cStatusMessage
         SET @cOutField05 = ISNULL(@cActualPalletKey, '')

         SET @nScn  = @nScn_CartonMsg
         SET @nStep = @nStep_CartonMsg
      END
      ELSE
      BEGIN
         -- Fetch next page; rows (@nScanned-1)*5+1 to @nScanned*5
         DELETE FROM @tUCC
         INSERT INTO @tUCC (RowNum, UCC)
         SELECT ROW_NUMBER() OVER (ORDER BY PD.PickDetailKey), U.UCCNo
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         JOIN dbo.UCC U WITH (NOLOCK)
            ON  U.SKU       = PD.SKU
            AND U.Lot       = PD.Lot
            AND U.WaveKey   = PD.WaveKey
            AND U.StorerKey = PD.StorerKey
         WHERE PD.StorerKey = @cStorerKey
         AND   PD.CaseID    = @cCartonID
         AND   PD.Status   <> '4'

         SELECT @cUCC01 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 1 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC02 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 2 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC03 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 3 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC04 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 4 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC05 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 5 THEN UCC END), '') FROM @tUCC

         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = @cFromID
         SET @cOutField03 = @cCartonID
         SET @cOutField04 = @cUCC01
         SET @cOutField05 = @cUCC02
         SET @cOutField06 = @cUCC03
         SET @cOutField07 = @cUCC04
         SET @cOutField08 = @cUCC05
         SET @cOutField09 = RIGHT('00' + TRY_CAST(@nScanned AS NVARCHAR(2)), 2)
                          + '/' + RIGHT('00' + TRY_CAST((@nTotal + 4) / 5 AS NVARCHAR(2)), 2)

         SET @nScn  = @nScn_UCCList
         SET @nStep = @nStep_UCCList
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      IF ISNULL(@nScanned, 1) <= 1
      BEGIN
         -- Already on first page, go back to Step 3
         SET @cCartonID   = ''
         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = @cFromID
         SET @cOutField03 = ''

         SET @nScn  = @nScn_CartonID
         SET @nStep = @nStep_CartonID
      END
      ELSE
      BEGIN
         -- Go back one page
         SET @nScanned = @nScanned - 1

         DELETE FROM @tUCC
         INSERT INTO @tUCC (RowNum, UCC)
         SELECT ROW_NUMBER() OVER (ORDER BY PD.PickDetailKey), U.UCCNo
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         JOIN dbo.UCC U WITH (NOLOCK)
            ON  U.SKU       = PD.SKU
            AND U.Lot       = PD.Lot
            AND U.WaveKey   = PD.WaveKey
            AND U.StorerKey = PD.StorerKey
         WHERE PD.StorerKey = @cStorerKey
         AND   PD.CaseID    = @cCartonID
         AND   PD.Status   <> '4'

         SELECT @cUCC01 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 1 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC02 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 2 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC03 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 3 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC04 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 4 THEN UCC END), '') FROM @tUCC
         SELECT @cUCC05 = ISNULL(MAX(CASE WHEN RowNum = (@nScanned - 1) * 5 + 5 THEN UCC END), '') FROM @tUCC

         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = @cFromID
         SET @cOutField03 = @cCartonID
         SET @cOutField04 = @cUCC01
         SET @cOutField05 = @cUCC02
         SET @cOutField06 = @cUCC03
         SET @cOutField07 = @cUCC04
         SET @cOutField08 = @cUCC05
         SET @cOutField09 = RIGHT('00' + TRY_CAST(@nScanned AS NVARCHAR(2)), 2)
                          + '/' + RIGHT('00' + TRY_CAST((@nTotal + 4) / 5 AS NVARCHAR(2)), 2)

         SET @nScn  = @nScn_UCCList
         SET @nStep = @nStep_UCCList
      END
   END
   GOTO Quit

END
GOTO Quit

/********************************************************************************
Step 5. Scn = 6584. Msg
   FROM LOC      (field01, display)
   FROM ID       (field02, display)
   MESSAGE TEXT  (field03, display)
   Instructions: Press ENTER to scan next ID. Press ESC to scan next LOC.
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- ENTER: scan next FROM ID (back to Step 2)
      SET @cFromID     = ''
      SET @cCartonID   = ''
      SET @cOutField01 = @cFromLoc
      SET @cOutField02 = ''

      SET @nScn  = @nScn_FromID
      SET @nStep = @nStep_FromID
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- ESC: scan next LOC (back to Step 1)
      SET @cFromLoc    = ''
      SET @cFromID     = ''
      SET @cCartonID   = ''
      SET @cOutField01 = ''

      SET @nScn  = @nScn_FROMLOC
      SET @nStep = @nStep_FROMLOC
   END
   GOTO Quit

END
GOTO Quit

/********************************************************************************
Step 6. Scn = 6585. Carton Msg
   FROM LOC      (field01, display)
   FROM ID       (field02, display)
   CARTON ID     (field03, display)
   MESSAGE TEXT  (field04, display)
   Instructions: Press ENTER to scan next CARTON/ID. Press ESC to scan next LOC.
********************************************************************************/
Step_6:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Check if pallet has unchecked cartons (in PALLETDETAIL but not yet in RDTDATACAPTURE)
      IF EXISTS (
         SELECT 1 FROM dbo.PALLETDETAIL PD WITH (NOLOCK)
         WHERE PD.PalletKey = @cFromID
         AND   PD.StorerKey = @cStorerKey
         AND   NOT EXISTS (
            SELECT 1 FROM RDT.RDTDATACAPTURE DC WITH (NOLOCK)
            WHERE DC.StorerKey = @cStorerKey
            AND   DC.V_ID      = @cFromID
            AND   DC.V_String4 = PD.CaseID
         )
      )
      BEGIN
         -- More cartons to check: go to Screen 3
         SET @cCartonID   = ''
         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = @cFromID
         SET @cOutField03 = ''

         SET @nScn  = @nScn_CartonID
         SET @nStep = @nStep_CartonID
      END
      ELSE
      BEGIN
         -- All cartons checked: go to Screen 2 to scan new pallet
         SET @cFromID     = ''
         SET @cCartonID   = ''
         SET @cOutField01 = @cFromLoc
         SET @cOutField02 = ''

         SET @nScn  = @nScn_FromID
         SET @nStep = @nStep_FromID
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- ESC: go back to Screen 1 to scan new LOC
      SET @cFromLoc    = ''
      SET @cFromID     = ''
      SET @cCartonID   = ''
      SET @cOutField01 = ''

      SET @nScn  = @nScn_FROMLOC
      SET @nStep = @nStep_FROMLOC
   END
   GOTO Quit

END
GOTO Quit

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
      V_String3 = @cFromID,
      V_String4 = @cSealNo1,
      V_String5 = @cSealNo2,
      V_String6 = @cSealNo3,
      V_String7 = @c_ContainerKey,
      V_String8 = @cExtScnSP,
      V_String9 = @cFromLoc,
      V_String10 = @cCartonID,
      V_String11 = @cDisplayUCC,
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
