SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 

/******************************************************************************/ 
/* Copyright: Maersk                                                          */ 
/* Purpose: For Barry                                                         */ 
/*                                                                            */ 
/* Modifications log:                                                         */ 
/*                                                                            */ 
/* Date       Rev  Author     Purposes                                        */ 
/* 2024-07-01 1.0  Dennis     Created                                         */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtfnc_ScanToTruck_Barry] (
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
   @cSealNo1      NVARCHAR(10),
   @cSealNo2      NVARCHAR(10),
   @cSealNo3      NVARCHAR(10),
   @cSealNo4      NVARCHAR(10),
   @cSealNo5      NVARCHAR(10),
   @cSealNo6      NVARCHAR(10),
   @nTotal         INT,
   @nScanned       INT,
   @c_ContainerKey       NVARCHAR(10),

   
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
 --@cOrderKey   = V_OrderKey,
   
   @cMBOLKey      = V_String1,
   @cTruckID      = V_String2,     
   @cSealNo1      = V_String4,
   @cSealNo2      = V_String5,
   @cSealNo3      = V_String6,
   @c_ContainerKey = V_String7,

   @nTotal        = V_Integer1,
   @nScanned      = V_Integer2,

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
   @nStep_MBOL             INT,  @nScn_MBOL              INT,  
   @nStep_Truck            INT,  @nScn_Truck             INT,  
   @nStep_Option           INT,  @nScn_Option            INT,  
   @nStep_ScanPalletID     INT,  @nScn_ScanPalletID      INT,  
   @nStep_SealNo1st        INT,  @nScn_SealNo1st         INT,  
   @nStep_SealNo2nd        INT,  @nScn_SealNo2nd         INT,  
   @nStep_Success          INT,  @nScn_Success           INT  
  
SELECT  
   @nStep_MBOL             = 1,   @nScn_MBOL             = 6400,  
   @nStep_Truck            = 2,   @nScn_Truck            = 6401,  
   @nStep_Option           = 3,   @nScn_Option           = 6402,  
   @nStep_ScanPalletID     = 4,   @nScn_ScanPalletID     = 6403,  
   @nStep_SealNo1st        = 5,   @nScn_SealNo1st        = 6404,  
   @nStep_SealNo2nd        = 6,   @nScn_SealNo2nd        = 6405,  
   @nStep_Success          = 7,   @nScn_Success   = 6406
  


IF @nFunc = 925  -- TruckLoading Barry
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Truck Loading
   IF @nStep = 1 GOTO Step_1   -- Scn = 6400. MBOLKey
   IF @nStep = 2 GOTO Step_2   -- Scn = 6401. Truck ID
   IF @nStep = 3 GOTO Step_3   -- Scn = 6402. Option
   IF @nStep = 4 GOTO Step_4   -- Scn = 6403. Scan Pallet ID
   IF @nStep = 5 GOTO Step_5   -- Scn = 6404. SEAL NO 1 - 3
   IF @nStep = 6 GOTO Step_6   -- Scn = 6405. SEAL NO 4 - 6
   IF @nStep = 7 GOTO Step_7   -- Scn = 6406. Message
   
END

RETURN -- Do nothing if incorrect step

/********************************************************************************
Step 0. func = 925. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Get prefer UOM
   SET @cPUOM = ''
   SELECT @cPUOM = IsNULL( DefaultUOM, '6') -- If not defined, default as EA
   FROM RDT.rdtMobRec M WITH (NOLOCK)
   INNER JOIN RDT.rdtUser U WITH (NOLOCK) ON (M.UserName = U.UserName)
   WHERE M.Mobile = @nMobile

   -- Initiate var
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
   
   SET @cMBOLKey = ''

   -- Set the entry point
   SET @nScn = @nScn_MBOL
   SET @nStep = @nStep_MBOL
   
END
GOTO Quit


/********************************************************************************
Step 1. Scn = 6400. 
   MBOLKey (Input , Field01)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      SET @cMBOLKey = ISNULL(RTRIM(@cInField01),'')
      
      -- Validate blank
      IF ISNULL(RTRIM(@cMBOLKey), '') = ''
      BEGIN
         SET @nErrNo = 77301
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL# req
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      IF NOT EXISTS (SELECT 1 FROM dbo.MBOL WITH (NOLOCK) WHERE MBOLKEY =  @cMBOLKey)
      BEGIN
         SET @nErrNo = 77302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid MBOL#
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END
      
      IF NOT EXISTS (SELECT 1 FROM ORDERS where MBOLKey = @cMBOLKey and StorerKey = @cStorerKey)
      BEGIN
         SET @nErrNo = 77302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid MBOL#
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      SELECT 
             @cStatus = Status
      FROM dbo.MBOL WITH (NOLOCK)
      WHERE MbolKey = @cMBOLKey

      IF @cStatus = '9'
      BEGIN
         SET @nErrNo = 77303
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL Shipped
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END
      
       -- Prepare Next Screen Variable
       SET @cOutField01 = ''
       
       -- GOTO Next Screen
       SET @nScn = @nScn_Truck
       SET @nStep = @nStep_Truck
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
Step 2. Scn = 6401. 
   Truck ID (field01, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      SET @cTruckID = ISNULL(RTRIM(@cInField01),'')
      -- Validate blank
      IF @cTruckID = ''
      BEGIN
         SET @nErrNo = 218451
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Truck ID
         GOTO Step_2_Fail
      END

      IF NOT EXISTS (SELECT 1 FROM dbo.IDS_VEHICLE WITH (NOLOCK) WHERE  VehicleNumber =  @cTruckID)
      BEGIN
         SET @nErrNo = 218452
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Truck Not Check In
         GOTO Step_2_Fail
      END

      -- Prepare Next Screen Variable
      SET @cOutField01 = @cTruckID
       
      -- GOTO Next Screen
      SET @nScn = @nScn_Option
      SET @nStep = @nStep_Option
      
   END  -- Inputkey = 1

   IF @nInputKey = 0 
   BEGIN
        -- Prepare Previous Screen Variable
       SET @cOutField01 = ''
          
       -- GOTO Previous Screen
       SET @nScn = @nScn_MBOL
       SET @nStep = @nStep_MBOL
   END
   GOTO Quit

   STEP_2_FAIL:
   BEGIN
      SET @cOutField01 = ''
      SET @cTruckID = ''
   END
   

END 
GOTO QUIT


/********************************************************************************
Step 3. Scn = 6402. 
   Option (field02, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      SET @cOption = ISNULL(RTRIM(@cInField02),'')
      IF @cOption = '1' -- Close Truck
      BEGIN
         SET @cOutField01 = @cTruckID
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutField04 = ''
         SET @cOutField05 = ''

         SET @nScn = @nScn_SealNo1st
         SET @nStep = @nStep_SealNo1st
      END
      ELSE IF @cOption = '9' -- Add Pallet
      BEGIN

         SELECT @nTotal = COUNT(DISTINCT ID) 
         FROM PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
         AND EXISTS(SELECT 1 
            FROM MBOL MD WITH (NOLOCK)
            INNER JOIN ORDERS O WITH (NOLOCK) ON O.MbolKey = MD.MbolKey
            WHERE MD.MbolKey = @cMBOLKey AND PD.OrderKey = O.OrderKey)
         
         SELECT @nScanned = COUNT(PalletKey) 
         FROM CONTAINERDETAIL CD (NOLOCK)
         INNER JOIN CONTAINER C (NOLOCK) ON C.Containerkey = CD.Containerkey
         WHERE C.MBOLKey = @cMBOLKey

         SET @cOutField01 = @cMBOLKey
         SET @cOutField02 = @cTruckID
         SET @cOutField04 = CONCAT(@nScanned,'/',@nTotal)
         SET @nScn = @nScn_ScanPalletID
         SET @nStep = @nStep_ScanPalletID
      END
      ELSE
      BEGIN
         SET @nErrNo = 218453
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
         GOTO Step_3_Fail
      END
     
   END  -- Inputkey = 1


   IF @nInputKey = 0 
   BEGIN
      -- Prepare Previous Screen Variable
      SET @cOutField01 = ''
            
      -- GOTO Previous Screen
      SET @nScn = @nScn_Truck
      SET @nStep = @nStep_Truck
   END

   GOTO Quit

   STEP_3_FAIL:
   BEGIN
      SET @cOutField01 = @cTruckID
      SET @cOutField02 = ''
   END
   

END 
GOTO QUIT

/********************************************************************************
Step 4. Scn = 6403. 
   Pallet     (Field03, Input)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
      DECLARE @nTotalCarton INT = 0,
      @cOrderKey            NVARCHAR(10),
      @cLottable01          NVARCHAR(18),
      @nTranCount           INT,
      @n_LineNo             INT,
      @c_LineNo             NVARCHAR(5)

      SET @cPallet = ISNULL(RTRIM(@cInField03),'')
      IF @cPallet = ''
      BEGIN
         SET @nErrNo = 218456
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Connot Be Blank
         GOTO Step_4_Fail
      END
      IF EXISTS (SELECT 1 from CONTAINERDETAIL CD WITH (NOLOCK) 
                     INNER JOIN CONTAINER C WITH (NOLOCK) ON C.Containerkey = CD.Containerkey
                     WHERE CD.PalletKey = @cPallet AND C.MbolKey = @cMBOLKey AND C.CarrierKey = @cTruckID)
      BEGIN
         SET @nErrNo = 218455
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet ID
         GOTO Step_4_Fail
      END

      SELECT 
         @nTotalCarton = COUNT (DISTINCT PD.CaseID)
         ,@cOrderKey = OrderKey
         ,@cLottable01 = MAX(LOTR.Lottable01)
      FROM PICKDETAIL PD WITH (NOLOCK)
      INNER JOIN LOTATTRIBUTE LOTR WITH(NOLOCK)
      ON PD.Storerkey = LOTR.StorerKey
      AND PD.Lot = LOTR.Lot
      AND PD.Sku = LOTR.Sku
      WHERE ID = @cPallet AND PD.Storerkey= @cStorerKey
      GROUP BY ID ,OrderKey

      IF ISNULL(@cOrderKey,'') = ''
      BEGIN
         SET @nErrNo = 218454
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Pallet ID
         GOTO Step_4_Fail
      END
      -- Handling transaction
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdtfnc_ScanToTruck_Barry  -- For rollback or commit only our own transaction

      IF NOT EXISTS (SELECT 1 FROM CONTAINER WHERE MBOLKey = @cMBOLKey AND CarrierKey = @cTruckID)
      BEGIN
         SET @b_success = 0
         EXECUTE nspg_GetKey
            'CONTAINERKEY',
            10,
            @c_ContainerKey  OUTPUT,
            @b_success       OUTPUT,
            @n_err           OUTPUT,
            @c_errmsg        OUTPUT

         IF @b_success = 1
         BEGIN
            INSERT INTO CONTAINER (Containerkey,CarrierKey, MBOLKey,Status)
            VALUES (@c_ContainerKey,@cTruckID,@cMBOLKey,0) 

            SELECT @n_err = @@ERROR
   	   	IF @n_err <> 0
   	      BEGIN
               GOTO RollBackTran
            END
         END
         ELSE
         BEGIN
            GOTO RollBackTran
         END
      END

      SELECT @n_LineNo = ISNULL(CAST(MAX(ContainerLineNumber) AS INT),0),
      @c_ContainerKey = C.Containerkey
      FROM CONTAINERDETAIL CD (NOLOCK)
      INNER JOIN CONTAINER C (NOLOCK) ON C.Containerkey = CD.Containerkey
      WHERE MBOLKey = @cMBOLKey AND CarrierKey = @cTruckID
      GROUP BY C.Containerkey

      SET @n_LineNo = ISNULL(@n_LineNo,0) + 1
      SET @c_LineNo = RIGHT('00000' + LTRIM(RTRIM(CAST(@n_LineNo AS NVARCHAR))), 5)

      INSERT INTO CONTAINERDETAIL (Containerkey, ContainerLineNumber, Palletkey,Userdefine04,Userdefine05)
      VALUES (@c_Containerkey, @c_LineNo, @cPallet,@cOrderKey,@cLottable01)

      COMMIT TRAN rdtfnc_ScanToTruck_Barry

      SELECT @nScanned = COUNT(PalletKey) 
      FROM CONTAINERDETAIL CD (NOLOCK)
      INNER JOIN CONTAINER C (NOLOCK) ON C.Containerkey = CD.Containerkey
      WHERE C.MBOLKey = @cMBOLKey

      SET @cOutField03 = ''
      SET @cOutField04 = CONCAT(@nScanned,'/',@nTotal)
      SET @cOutField05 = @cOrderKey
      
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN
      GOTO Quit
      RollBackTran:
         ROLLBACK TRAN rdtfnc_ScanToTruck_Barry -- Only rollback change made here
   END  -- Inputkey = 1


   IF @nInputKey = 0 
   BEGIN
      -- Prepare Next Screen Variable
      SET @cOutField01 = @cTruckID
      SET @cOutField02 = ''  
      -- GOTO Next Screen
      SET @nScn = @nScn_Option
      SET @nStep = @nStep_Option
   END
   GOTO Quit

   STEP_4_FAIL:
   BEGIN
         -- Prepare Next Screen Variable
         SET @cOutField01 = @cMBOLKey
         SET @cOutField02 = @cTruckID
         SET @cOutField03 = ''
         SET @cOutField04 = CONCAT(@nScanned,'/',@nTotal)
   END
   

END 
GOTO QUIT

/********************************************************************************
Step 5. Scn = 6404. 
   SEAL NO 1 (field02, input)
   SEAL NO 2 (field03, input)
   SEAL NO 3 (field04, input)
   OPTION    (field05, input)
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1
   BEGIN
      SET @cSealNo1 = @cInField02
      SET @cSealNo2 = @cInField03
      SET @cSealNo3 = @cInField04
      SET @cOption = @cInField05
      IF @cOption = '1'
      BEGIN
         UPDATE CONTAINER SET 
         Seal01 = @cSealNo1,
         Seal02 = @cSealNo2,
         Seal03 = @cSealNo3
         WHERE MBOLKey = @cMBOLKey 
         AND CarrierKey = @cTruckID

         SET @nScn = @nScn + 2
         SET @nStep = @nStep + 2
         GOTO Quit
      END

      -- Prepare Next Screen Variable
      SET @cOutField01 = @cTruckID
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutField04 = ''

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
      
      
   END  -- Inputkey = 1

   IF @nInputKey = 0
   BEGIN
      SET @cOutField01 = @cTruckID
      SET @cOutField02 = ''

      SET @nScn = @nScn_Option
      SET @nStep = @nStep_Option
   END
END 
GOTO QUIT
/********************************************************************************
Step 6. Scn = 6405. 
   SEAL NO 4 (field02, input)
   SEAL NO 5 (field03, input)
   SEAL NO 6 (field04, input)
********************************************************************************/
Step_6:
BEGIN
   IF @nInputKey = 1
   BEGIN
      SET @cSealNo4 = @cInField02
      SET @cSealNo5 = @cInField03
      SET @cSealNo6 = @cInField04
   
      UPDATE CONTAINER SET 
      Seal01 = @cSealNo1,
      Seal02 = @cSealNo2,
      Seal03 = @cSealNo3,
      UserDefine01 = @cSealNo4,
      UserDefine02 = @cSealNo5,
      UserDefine03 = @cSealNo6
      WHERE MBOLKey = @cMBOLKey 
      AND CarrierKey = @cTruckID

      -- Prepare Next Screen Variable
      SET @cOutField01 = @cTruckID
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutField04 = ''

      SET @nScn = @nScn_Success
      SET @nStep = @nStep_Success
      
      
   END  -- Inputkey = 1

   IF @nInputKey = 0
   BEGIN
      SET @cOutField01 = @cTruckID
      SET @cOutField02 = @cSealNo1
      SET @cOutField03 = @cSealNo2
      SET @cOutField04 = @cSealNo3
      SET @cOutField05 = ''

      SET @nScn = @nScn_SealNo1st
      SET @nStep = @nStep_SealNo1st
   END
END 
GOTO QUIT
/********************************************************************************
Step 7. Scn = 6406. 
   Success Message
********************************************************************************/
Step_7:
BEGIN
   SET @nScn = @nScn_MBOL
   SET @nStep = @nStep_MBOL
   SET @cOutField01 = ''
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

GRANT EXECUTE ON [RDT].[rdtfnc_ScanToTruck_Barry] to nSQL
GO
