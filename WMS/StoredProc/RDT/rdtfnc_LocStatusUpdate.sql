
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdtfnc_LocStatusUpdate                              */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* Purpose: Location Status Update with SO Creation for Schneider       */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-04-09 1.0  NYE018     FCR-12369. Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtfnc_LocStatusUpdate] (
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
   @b_success           INT,
   @n_err               INT,
   @c_errmsg            NVARCHAR(20)

-- RDT.RDTMobRec variables
DECLARE
   @nFunc      INT,
   @nScn       INT,
   @nStep      INT,
   @cLangCode  NVARCHAR(3),
   @nInputKey  INT,
   @nMenu      INT,
   @bSuccess   INT,

   @cStorerGroup  NVARCHAR(20),
   @cStorerKey    NVARCHAR(15),
   @cFacility     NVARCHAR(5),

   @cScannedLOC   NVARCHAR(10),
   @cCurrentStatus NVARCHAR(10),
   @cNewStatus    NVARCHAR(10),
   @cLocationType NVARCHAR(10),
   @cPutawayZone  NVARCHAR(10),

   @cInField01 NVARCHAR(60),   @cOutField01 NVARCHAR(60),
   @cInField02 NVARCHAR(60),   @cOutField02 NVARCHAR(60),
   @cInField03 NVARCHAR(60),   @cOutField03 NVARCHAR(60),
   @cInField04 NVARCHAR(60),   @cOutField04 NVARCHAR(60),
   @cInField05 NVARCHAR(60),   @cOutField05 NVARCHAR(60),
   @cInField06 NVARCHAR(60),   @cOutField06 NVARCHAR(60),
   @cInField07 NVARCHAR(60),   @cOutField07 NVARCHAR(60),
   @cInField08 NVARCHAR(60),   @cOutField08 NVARCHAR(60),
   @cInField09 NVARCHAR(60),   @cOutField09 NVARCHAR(60),
   @cInField10 NVARCHAR(60),   @cOutField10 NVARCHAR(60),
   @cInField11 NVARCHAR(60),   @cOutField11 NVARCHAR(60),
   @cInField12 NVARCHAR(60),   @cOutField12 NVARCHAR(60),
   @cInField13 NVARCHAR(60),   @cOutField13 NVARCHAR(60),
   @cInField14 NVARCHAR(60),   @cOutField14 NVARCHAR(60),
   @cInField15 NVARCHAR(60),   @cOutField15 NVARCHAR(60),

   @cFieldAttr01 NVARCHAR(1), @cFieldAttr02 NVARCHAR(1),
   @cFieldAttr03 NVARCHAR(1), @cFieldAttr04 NVARCHAR(1),
   @cFieldAttr05 NVARCHAR(1), @cFieldAttr06 NVARCHAR(1),
   @cFieldAttr07 NVARCHAR(1), @cFieldAttr08 NVARCHAR(1),
   @cFieldAttr09 NVARCHAR(1), @cFieldAttr10 NVARCHAR(1),
   @cFieldAttr11 NVARCHAR(1), @cFieldAttr12 NVARCHAR(1),
   @cFieldAttr13 NVARCHAR(1), @cFieldAttr14 NVARCHAR(1),
   @cFieldAttr15 NVARCHAR(1)

-- Load RDT.RDTMobRec
SELECT
   @nFunc      = Func,
   @nScn       = Scn,
   @nStep      = Step,
   @nInputKey  = InputKey,
   @nMenu      = Menu,
   @cLangCode  = Lang_code,

   @cStorerGroup  = StorerGroup,
   @cStorerKey    = V_StorerKey,
   @cFacility     = Facility,

   @cScannedLOC   = V_LOC,
   @cCurrentStatus = V_String1,
   @cLocationType = V_String2,
   @cPutawayZone  = V_String3,

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

   @cFieldAttr01 = FieldAttr01,    @cFieldAttr02 = FieldAttr02,
   @cFieldAttr03 = FieldAttr03,    @cFieldAttr04 = FieldAttr04,
   @cFieldAttr05 = FieldAttr05,    @cFieldAttr06 = FieldAttr06,
   @cFieldAttr07 = FieldAttr07,    @cFieldAttr08 = FieldAttr08,
   @cFieldAttr09 = FieldAttr09,    @cFieldAttr10 = FieldAttr10,
   @cFieldAttr11 = FieldAttr11,    @cFieldAttr12 = FieldAttr12,
   @cFieldAttr13 = FieldAttr13,    @cFieldAttr14 = FieldAttr14,
   @cFieldAttr15 = FieldAttr15

FROM RDT.RDTMOBREC WITH (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 1879 -- LocStatusUpdate
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Initialize
   IF @nStep = 1 GOTO Step_1   -- Scn = 6870. Location scan
   IF @nStep = 2 GOTO Step_2   -- Scn = 6871. Status selection
END
RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 1879. Menu - Initialize
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   SET @nScn = 6870
   SET @nStep = 1

   -- Initialize variables
   SET @cScannedLOC = ''
   SET @cCurrentStatus = ''
   SET @cLocationType = ''
   SET @cPutawayZone = ''

   -- EventLog - Sign In Function
   EXEC RDT.rdt_STD_EventLog
     @cActionType = '1', -- Sign in function
     @nMobileNo   = @nMobile,
     @nFunctionID = @nFunc,
     @cFacility   = @cFacility,
     @cStorerKey  = @cStorerKey,
     @nStep       = @nStep

   -- Init screen
   SET @cOutField01 = ''

   GOTO Quit
END
GOTO Quit


/********************************************************************************
Step 1. Scn = 6870. Location Scan Screen
   Location (field01)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Get scanned location
      SET @cScannedLOC = LTRIM(RTRIM(@cInField01))

      -- Validate location is not empty
      IF @cScannedLOC = '' OR @cScannedLOC IS NULL
      BEGIN
         SET @nErrNo = 263512
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Location Needed
         GOTO Step_1_Fail
      END

      -- Validate location exists in facility
      SELECT
         @cCurrentStatus = Status,
         @cLocationType = LocationType,
         @cPutawayZone = PutawayZone
      FROM dbo.LOC WITH (NOLOCK)
      WHERE LOC = @cScannedLOC
        AND Facility = @cFacility

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 263501
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid location
         GOTO Step_1_Fail
      END

      -- Get location status options from CODELKUP
      DECLARE @tLocStatus TABLE (
         RowNum INT IDENTITY(1,1),
         Code NVARCHAR(10),
         Short NVARCHAR(10)
      )

      INSERT INTO @tLocStatus (Code, Short)
      SELECT TOP 5 Code, Short
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE ListName = 'LOCSTATUS'
        AND StorerKey = @cStorerKey
      ORDER BY CAST(Short AS INT)

      IF (SELECT COUNT(*) FROM @tLocStatus) = 0
      BEGIN
         SET @nErrNo = 263506
         SET @cErrMsg = rdt.rdtgetmessage(263506, @cLangCode, 'DSP') -- No location status defined
         GOTO Step_1_Fail
      END

      -- Prepare screen 2 display
      SET @nScn = 6871
      SET @nStep = 2

      SET @cOutField01 = @cScannedLOC
      SET @cOutField02 = @cCurrentStatus

      -- Display status options (Short. Code format)
      SELECT @cOutField03 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus WHERE RowNum = 1), '')
      SELECT @cOutField04 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus WHERE RowNum = 2), '')
      SELECT @cOutField05 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus WHERE RowNum = 3), '')
      SELECT @cOutField06 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus WHERE RowNum = 4), '')
      SELECT @cOutField07 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus WHERE RowNum = 5), '')

      SET @cOutField08 = '' -- Option input

      GOTO Quit
   END

   IF @nInputKey = 0 -- ESC
   BEGIN

      -- EventLog - Sign Out Function 
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign out function
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
   END
   GOTO Quit

   Step_1_Fail:
   BEGIN
      SET @nScn = 6870
      SET @nStep = 1
      SET @cOutField01 = ''
      GOTO Quit
   END
END
GOTO Quit


/********************************************************************************
Step 2. Scn = 6871. Status Selection Screen
   LOC (field01 - display)
   Current Status (field02 - display)
   Status Options (field03-07 - display)
   Option Input (field08)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      DECLARE @cOptionInput NVARCHAR(10)
      SET @cOptionInput = LTRIM(RTRIM(@cInField08))

      -- Validate option is not empty
      IF @cOptionInput = '' OR @cOptionInput IS NULL
      BEGIN
         SET @nErrNo = 263513
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Option Needed
         GOTO Step_2_Fail
      END

      -- Validate option exists in CODELKUP
      SELECT @cNewStatus = Code
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE ListName = 'LOCSTATUS'
        AND Short = @cOptionInput
        AND StorerKey = @cStorerKey 

      IF @cNewStatus = '' OR @cNewStatus IS NULL
      BEGIN
         SET @nErrNo = 263502
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid option
         GOTO Step_2_Fail
      END

      -- Extended logic: Check if status = 'FULL' AND LocationType = 'Staging'
      IF @cNewStatus = 'FULL' AND @cLocationType = 'Staging'
      BEGIN
         -- Check for inventory hold on pallets (using InventoryHold table)
         IF EXISTS (
            SELECT 1
            FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               INNER JOIN dbo.InventoryHold IH WITH (NOLOCK) ON LLI.ID = IH.ID
            WHERE LLI.LOC = @cScannedLOC
              AND IH.Hold = '1'
              AND LLI.QTY > 0
         )
         BEGIN
            SET @nErrNo = 263503
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- HOLD pallets in the location
            GOTO Step_2_Fail
         END

         -- Check if any pallets exist on location
         IF NOT EXISTS (
            SELECT 1
            FROM dbo.LOTxLOCxID WITH (NOLOCK)
            WHERE LOC = @cScannedLOC
              AND QTY > 0
         )
         BEGIN
            SET @nErrNo = 263509
            SET @cErrMsg = rdt.rdtgetmessage(263509, @cLangCode, 'DSP') -- No pallets on location
            GOTO Step_2_Fail
         END

         -- Fetch distinct Lottable01 (ShipTo) values for all pallets on location
         DECLARE @tShipTo TABLE (
            Lottable01 NVARCHAR(18),
            SUSR4 NVARCHAR(30)
         )

         INSERT INTO @tShipTo (Lottable01)
         SELECT DISTINCT LA.Lottable01
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
            INNER JOIN dbo.LotAttribute LA WITH (NOLOCK) ON LLI.LOT = LA.LOT
         WHERE LLI.LOC = @cScannedLOC
           AND LLI.QTY > 0

         DECLARE @nShipToCount INT
         SELECT @nShipToCount = COUNT(DISTINCT Lottable01) FROM @tShipTo

         -- If multiple ShipTo values, get STORER.SUSR4 (Group of ShipTo)
         IF @nShipToCount > 1
         BEGIN
             UPDATE t
             SET SUSR4 = s.SUSR4
             FROM @tShipTo t
               INNER JOIN dbo.STORER s WITH (NOLOCK) ON s.Address1 = t.Lottable01
             WHERE s.Type = '2'
               AND s.ConsigneeFor = @cStorerKey

             -- Check if all SUSR4 values are same
             DECLARE @nGroupCount INT
             SELECT @nGroupCount = COUNT(DISTINCT ISNULL(SUSR4, '')) FROM @tShipTo

             IF @nGroupCount > 1
             BEGIN
                SET @nErrNo = 263504
                SET @cErrMsg = rdt.rdtgetmessage(263504, @cLangCode, 'DSP') -- Mixed ShipTo
                GOTO Step_2_Fail
             END
         END

         -- Get STORER.SUSR1 for PutawayZone validation
         DECLARE @cLottable01 NVARCHAR(18)
         DECLARE @cStorerSUSR1 NVARCHAR(30)

         SELECT TOP 1 @cLottable01 = Lottable01 FROM @tShipTo

         SELECT @cStorerSUSR1 = SUSR1
         FROM dbo.STORER WITH (NOLOCK)
         WHERE Type = '2'
           AND ConsigneeFor = @cStorerKey
           AND Address1 = @cLottable01

         -- Validate PutawayZone matches STORER.SUSR1
         IF @cPutawayZone <> @cStorerSUSR1 AND @cStorerSUSR1 IS NOT NULL AND @cStorerSUSR1 <> ''
         BEGIN
            SET @nErrNo = 263510
            SET @cErrMsg = rdt.rdtgetmessage(263510, @cLangCode, 'DSP') -- Invalid PutawayZone for ShipTo
            GOTO Step_2_Fail
         END

         -- All validations passed - trigger SO creation via QCMD
         BEGIN TRY
            DECLARE @cCommand          NVARCHAR(MAX)
            DECLARE @c_APP_DB_Name     NVARCHAR(20) = ''
            DECLARE @c_DataStream      NVARCHAR(10) = ''
            DECLARE @n_ThreadPerAcct   INT = 0
            DECLARE @n_ThreadPerStream INT = 0
            DECLARE @n_MilisecondDelay INT = 0
            DECLARE @c_IP              NVARCHAR(20) = ''
            DECLARE @c_PORT            NVARCHAR(5) = ''
            DECLARE @c_IniFilePath     NVARCHAR(200) = ''
            DECLARE @c_CmdType         NVARCHAR(10) = ''
            DECLARE @c_TaskType        NVARCHAR(1) = ''
            DECLARE @n_Priority        INT = 0
            DECLARE @nQueueID          BIGINT = 0

            -- Get QCommander configuration
            SELECT @c_APP_DB_Name = APP_DB_Name
                 , @c_DataStream = DataStream
                 , @n_ThreadPerAcct = ThreadPerAcct
                 , @n_ThreadPerStream = ThreadPerStream
                 , @n_MilisecondDelay = MilisecondDelay
                 , @c_IP = IP
                 , @c_PORT = PORT
                 , @c_IniFilePath = IniFilePath
                 , @c_CmdType = CmdType
                 , @c_TaskType = TaskType
                 , @n_Priority = ISNULL([Priority], 0)
            FROM dbo.QCmd_TransmitlogConfig WITH (NOLOCK)
            WHERE TableName = 'LOCSTATUSUPD'
              AND [App_Name] = 'WMS'
              AND StorerKey = @cStorerKey

            -- Build command to call msp_CreateSOPickMBOLTask
            SET @cCommand = N'EXEC [dbo].[msp_CreateSOPickMBOLTask] ' +
               N'@c_StorerKey=''' + @cStorerKey + N''', ' +
               N'@c_Facility=''' + @cFacility + N''', ' +
               N'@c_Loc=''' + @cScannedLOC + N''', ' +
               N'@b_debug=0'

            -- Submit task to QCommander
            EXEC isp_QCmd_SubmitTaskToQCommander
                 @cTaskType         = 'O'  -- D=By Datastream, T=Transmitlog, O=Others
               , @cStorerKey        = @cStorerKey
               , @cDataStream       = @c_DataStream
               , @cCmdType          = @c_CmdType
               , @cCommand          = @cCommand
               , @cTransmitlogKey   = ''
               , @nThreadPerAcct    = @n_ThreadPerAcct
               , @nThreadPerStream  = @n_ThreadPerStream
               , @nMilisecondDelay  = @n_MilisecondDelay
               , @nSeq              = 1
               , @cIP               = @c_IP
               , @cPORT             = @c_PORT
               , @cIniFilePath      = @c_IniFilePath
               , @cAPPDBName        = @c_APP_DB_Name
               , @bSuccess          = @bSuccess  OUTPUT
               , @nErr              = @nErrNo    OUTPUT
               , @cErrMsg           = @cErrMsg   OUTPUT
               , @nQueueID          = @nQueueID  OUTPUT

            IF @nErrNo <> 0
            BEGIN
               SET @nErrNo = 263511
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Failed to queue SO creation
               GOTO Step_2_Fail
            END

         END TRY
         BEGIN CATCH
            SET @nErrNo = 263511
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Failed to queue SO creation
            GOTO Step_2_Fail
         END CATCH
      END

      -- Update location status
      BEGIN TRY
         UPDATE dbo.LOC WITH(ROWLOCK)
         SET Status = @cNewStatus,
             EditDate = GETDATE()
         WHERE LOC = @cScannedLOC
           AND Facility = @cFacility
      END TRY
      BEGIN CATCH
         SET @nErrNo = 263505
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Failed to update location status
         GOTO Step_2_Fail
      END CATCH

      -- EventLog - Update Success
      EXEC RDT.rdt_STD_EventLog
        @cActionType = '5', -- Update
        @nMobileNo   = @nMobile,
        @nFunctionID = @nFunc,
        @cFacility   = @cFacility,
        @cStorerKey  = @cStorerKey,
        @nStep       = @nStep

      -- Success - go back to step 1 for next location
      SET @nScn = 6870
      SET @nStep = 1

      -- Reset variables
      SET @cScannedLOC = ''
      SET @cCurrentStatus = ''
      SET @cLocationType = ''
      SET @cPutawayZone = ''

      SET @cOutField01 = ''

      SET @nErrNo = 263508
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Location status updated

      GOTO Quit
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Back to location scan screen
      SET @nScn = 6870
      SET @nStep = 1

      -- Reset variables
      SET @cScannedLOC = ''
      SET @cCurrentStatus = ''
      SET @cLocationType = ''
      SET @cPutawayZone = ''

      SET @cOutField01 = ''

      GOTO Quit
   END

   Step_2_Fail:
   BEGIN
      -- Stay on status selection screen and reload options
      SET @nScn = 6871
      SET @nStep = 2

      -- Reload status options
      DECLARE @tLocStatus2 TABLE (
         RowNum INT IDENTITY(1,1),
         Code NVARCHAR(10),
         Short NVARCHAR(10)
      )

      INSERT INTO @tLocStatus2 (Code, Short)
      SELECT TOP 5 Code, Short
      FROM dbo.CODELKUP WITH (NOLOCK)
      WHERE ListName = 'LOCSTATUS'
        AND (StorerKey = @cStorerKey OR StorerKey = 'ALL')
      ORDER BY CAST(Short AS INT)

      SET @cOutField01 = @cScannedLOC
      SET @cOutField02 = @cCurrentStatus

      SELECT @cOutField03 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus2 WHERE RowNum = 1), '')
      SELECT @cOutField04 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus2 WHERE RowNum = 2), '')
      SELECT @cOutField05 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus2 WHERE RowNum = 3), '')
      SELECT @cOutField06 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus2 WHERE RowNum = 4), '')
      SELECT @cOutField07 = ISNULL((SELECT CAST(Short AS NVARCHAR(2)) + '. ' + Code FROM @tLocStatus2 WHERE RowNum = 5), '')

      GOTO Quit
   END
END
GOTO Quit


/********************************************************************************
Quit - Update RDTMOBREC
********************************************************************************/
Quit:
BEGIN
   UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
   SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Scn    = @nScn,
      Step   = @nStep,

      Facility  = @cFacility,

      V_StorerKey  = @cStorerKey,
      V_LOC        = @cScannedLOC,
      V_String1    = @cCurrentStatus,
      V_String2    = @cLocationType,
      V_String3    = @cPutawayZone,

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

GRANT EXECUTE ON RDT.rdtfnc_LocStatusUpdate TO NSQL
GO
