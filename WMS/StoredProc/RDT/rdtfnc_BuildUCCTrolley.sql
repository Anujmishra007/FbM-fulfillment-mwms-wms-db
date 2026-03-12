IF NOT EXISTS(SELECT 1 FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID = 1875 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
   INSERT INTO rdt.RDTMsg(Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
   VALUES( 1875, 'ENG', 'FNC', 'Build Trolley', 'rdtfnc_BuildUCCTrolley', '0', '0', '', '' )

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  

/*******************************************************************************/
/* Store procedure: rdtfnc_BuildUCCTrolley                                     */
/* Copyright      : Maersk                                                     */
/*                                                                             */
/* Date       Rev  Author     Purposes                                         */
/* 2025-12-19 1.0  Nickt      FCR-9734 Create                                  */
/*******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdtfnc_BuildUCCTrolley] (
   @nMobile    int,
   @nErrNo     int  OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cTrolleyID          NVARCHAR(20),
      @cTrolleyStatus      NVARCHAR(10),
      @nRowCount           INT,

      @cUCC                NVARCHAR(20),
      @cTaskDetailKey      NVARCHAR(10),
      @nLoopRowRef         INT

   -- rdt.rdtMobRec variable
   DECLARE
      @nFunc               INT,
      @nScn                INT,
      @nStep               INT,
      @nMenu               INT,
      @cLangCode           NVARCHAR( 3),
      @nInputKey           INT,
      @cOption             NVARCHAR(5),

      @cStorerKey          NVARCHAR( 15),
      @cFacility           NVARCHAR( 5),
      @cUserName           NVARCHAR(18),
      @cPrinter            NVARCHAR( 10),
      @cPrinterPpr         NVARCHAR( 10),
      @cDeviceProfileKey   NVARCHAR(10),
      @nPosition           INT,
      @nMaxPosition        INT,
      @nTranCount          INT,
      

      @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),    @cFieldAttr01 NVARCHAR( 1), @cLottable01     NVARCHAR( 18),
      @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),    @cFieldAttr02 NVARCHAR( 1), @cLottable02     NVARCHAR( 18),
      @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),    @cFieldAttr03 NVARCHAR( 1), @cLottable03     NVARCHAR( 18),
      @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),    @cFieldAttr04 NVARCHAR( 1), @dLottable04     DATETIME,
      @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),    @cFieldAttr05 NVARCHAR( 1), @dLottable05     DATETIME,
      @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),    @cFieldAttr06 NVARCHAR( 1), @cLottable06     NVARCHAR( 30),
      @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),    @cFieldAttr07 NVARCHAR( 1), @cLottable07     NVARCHAR( 30),
      @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),    @cFieldAttr08 NVARCHAR( 1), @cLottable08     NVARCHAR( 30),
      @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),    @cFieldAttr09 NVARCHAR( 1), @cLottable09     NVARCHAR( 30),
      @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),    @cFieldAttr10 NVARCHAR( 1), @cLottable10     NVARCHAR( 30),
      @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),    @cFieldAttr11 NVARCHAR( 1), @cLottable11     NVARCHAR( 30),
      @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),    @cFieldAttr12 NVARCHAR( 1), @cLottable12     NVARCHAR( 30),
      @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),    @cFieldAttr13 NVARCHAR( 1), @dLottable13     DATETIME,
      @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),    @cFieldAttr14 NVARCHAR( 1), @dLottable14     DATETIME,
      @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),    @cFieldAttr15 NVARCHAR( 1), @dLottable15     DATETIME,
      @cInField16 NVARCHAR( 60),   @cOutField16 NVARCHAR( 60),    @cFieldAttr16 NVARCHAR( 1), 
      @cInField17 NVARCHAR( 60),   @cOutField17 NVARCHAR( 60),    @cFieldAttr17 NVARCHAR( 1), 
      @cInField18 NVARCHAR( 60),   @cOutField18 NVARCHAR( 60),    @cFieldAttr18 NVARCHAR( 1), 
      @cInField19 NVARCHAR( 60),   @cOutField19 NVARCHAR( 60),    @cFieldAttr19 NVARCHAR( 1), 
      @cInField20 NVARCHAR( 60),   @cOutField20 NVARCHAR( 60),    @cFieldAttr20 NVARCHAR( 1),
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

   -- Getting Mobile information
   SELECT
      @nFunc      = Func,
      @nScn       = Scn,
      @nStep      = Step,
      @nMenu      = Menu,
      @cLangCode  = Lang_code,
      @nInputKey  = InputKey,

      @cStorerKey = StorerKey,
      @cFacility  = Facility,
      @cPrinter   = Printer,
      @cPrinterPpr= Printer_Paper,
      @cUserName  = UserName,

      @cTrolleyID          = V_String1,
      @cDeviceProfileKey   = V_String2,
      @nPosition           = V_Integer1,
      @nMaxPosition        = V_Integer2,

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
      @cInField15 = I_Field15,   @cOutField15 = O_Field15,  @cFieldAttr15 = FieldAttr15,

      @cInField16 = I_Field16,   @cOutField16 = O_Field16,  @cFieldAttr16 = FieldAttr16,
      @cInField17 = I_Field17,   @cOutField17 = O_Field17,  @cFieldAttr17 = FieldAttr17,
      @cInField18 = I_Field18,   @cOutField18 = O_Field18,  @cFieldAttr18 = FieldAttr18,
      @cInField19 = I_Field19,   @cOutField19 = O_Field19,  @cFieldAttr19 = FieldAttr19,
      @cInField20 = I_Field20,   @cOutField20 = O_Field20,  @cFieldAttr20 = FieldAttr20

   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1875
   BEGIN
      IF @nStep = 0 GOTO Step_0  -- Menu. Func = 1875
      IF @nStep = 1 GOTO Step_1  -- Scn = 6750. Trolley ID
      IF @nStep = 2 GOTO Step_2  -- Scn = 6751. Option, trolley is in use, proceed?
      IF @nStep = 3 GOTO Step_3  -- Scn = 6752. Carton/UCC
      IF @nStep = 4 GOTO Step_4  -- Scn = 6753. Option. empty trolley?
      IF @nStep = 5 GOTO Step_5  -- Scn = 6754. Option. Close trolley?
   END

   /********************************************************************************
   Step 0. Func = 1875
   ********************************************************************************/
   Step_0:
   BEGIN
      -- Init var
      SELECT
         @cTaskDetailKey  = '',
         @nLoopRowRef     = 0,
         @cFieldAttr01  =  '',
         @cFieldAttr02  =  '',
         @cFieldAttr03  =  '',
         @cFieldAttr04  =  '',
         @cFieldAttr05  =  '',
         @cFieldAttr06  =  '',
         @cFieldAttr07  =  '',
         @cFieldAttr08  =  '',
         @cFieldAttr09  =  '',
         @cFieldAttr10  =  ''

      -- EventLog - Sign In Function  
      -- (ChewKP02) 
      EXEC RDT.rdt_STD_EventLog  
      @cActionType = '1', -- Sign in function  
      @cUserID     = @cUserName,  
      @nMobileNo   = @nMobile,  
      @nFunctionID = @nFunc,  
      @cFacility   = @cFacility,  
      @cStorerKey  = @cStorerKey

      -- Go to next screen
      SET @nScn = 6750
      SET @nStep = 1
      SET @cOutField01 = ''

   END
   GOTO Quit


   /********************************************************************************
   Step 1. Scn = 6750
      Trolley ID: (field01, input)
   ********************************************************************************/
   Step_1:
   BEGIN
      IF @nInputKey = 1 -- Yes or Send
      BEGIN
         SET @cTrolleyID = TRIM(@cInField01) -- Trolley

         IF @cTrolleyID = ''
         BEGIN
            SET @nErrNo = 254401
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Trolley ID is needed
            GOTO Step_1_Fail
         END

         IF LEN(@cTrolleyID) > 10
         BEGIN
            SET @nErrNo = 254402
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Trolley ID must be <= 10 characters
            GOTO Step_1_Fail
         END

         SELECT @cTrolleyStatus = Status,
            @cDeviceProfileKey = DeviceProfileKey
         FROM dbo.DeviceProfile WITH(NOLOCK)
         WHERE DeviceID = @cTrolleyID
            AND DeviceType = 'CART'
            AND StorerKey = @cStorerKey

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 254403
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Trolley ID not in Device Profile
            GOTO Step_1_Fail
         END

         IF NOT EXISTS(SELECT 1 
                        FROM dbo.CODELKUP WITH(NOLOCK)
                        WHERE LISTNAME = 'DVCStatus'
                        AND StorerKey = @cStorerKey
                        AND Code = @cTrolleyStatus)
         BEGIN
            SET @nErrNo = 254404
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Trolley ID bad status
            GOTO Step_1_Fail
         END

         IF @cTrolleyStatus = '9'
         BEGIN
            SET @nErrNo = 254405
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Trolley ID not in Device Profile
            GOTO Step_1_Fail
         END

         SELECT @nPosition = MAX(CAST(Position AS INT))
         FROM rdt.RDTTROLLEYLOG WITH (NOLOCK)
         WHERE TrolleyNo = @cTrolleyID
            AND TRY_CAST(Position AS INT) IS NOT NULL

         IF @nPosition IS NULL
            SET @nPosition = 0

         SELECT @nMaxPosition = TRY_CAST(DevicePosition AS INT)
         FROM dbo.DeviceProfile WITH(NOLOCK)
         WHERE DeviceID = @cTrolleyID
            AND DeviceType = 'CART'
            AND StorerKey = @cStorerKey

         IF ISNULL(@nMaxPosition, 0) < 1
         BEGIN
            SET @nErrNo = 254406
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad trolley configuration
            GOTO Step_1_Fail
         END

         IF @nPosition < @nMaxPosition
            SET @nPosition = @nPosition + 1
         ELSE
            SET @nPosition = 0

         -- Trolley is in use, proceed?
         IF @cTrolleyStatus = '3'
         BEGIN
            SET @nStep = @nStep + 1
            SET @nScn = @nScn + 1
            SET @cOutField01 = @cTrolleyID
            SET @cOutField02 = IIF(@nPosition = 0, 'FULL', CAST(@nPosition AS NVARCHAR(10)))
            GOTO Quit
         END

         UPDATE dbo.DeviceProfile WITH(ROWLOCK)
         SET 
            Status = '3',
            EditDate = GETDATE(),
            EditWho = SUSER_NAME()
         WHERE DeviceProfileKey = @cDeviceProfileKey

         SET @nStep = @nStep + 2
         SET @nScn = @nScn + 2
         SET @cOutField01 = @cTrolleyID
         SET @cOutField02 = IIF(@nPosition = 0, 'FULL', CAST(@nPosition AS NVARCHAR(10)))
         SET @cOutField03 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 3
         GOTO Quit
      END

      IF @nInputKey = 0 -- Esc or No
      BEGIN
         -- (ChewKP02) 
         EXEC RDT.rdt_STD_EventLog
            @cActionType = '9', -- Sign in function  
            @cUserID     = @cUserName,  
            @nMobileNo   = @nMobile,  
            @nFunctionID = @nFunc,  
            @cFacility   = @cFacility,  
            @cStorerKey  = @cStorerKey

         SET @nFunc = @nMenu
         SET @nScn  = @nMenu
         SET @nStep = 0
         SET @cOutField01 = ''

         -- Enable all fields
         SET @cFieldAttr01 = ''
         SET @cFieldAttr02 = ''
         SET @cFieldAttr03 = ''
         SET @cFieldAttr04 = ''
         SET @cFieldAttr05 = ''

      SELECT 
         @cFieldAttr01  =  '',
         @cFieldAttr02  =  '',
         @cFieldAttr03  =  '',
         @cFieldAttr04  =  '',
         @cFieldAttr05  =  '',
         @cFieldAttr06  =  '',
         @cFieldAttr07  =  '',
         @cFieldAttr08  =  '',
         @cFieldAttr09  =  '',
         @cFieldAttr10  =  ''
      END
      GOTO Quit

      Step_1_Fail:
      BEGIN
         EXEC rdt.rdtSetFocusField @nMobile, 1
      END
   END
   GOTO Quit

   /********************************************************************************
   Step 1. Scn = 6751 Trolley ID in use, proceed?
      Trolley ID: (field01, Output)
   ********************************************************************************/
   Step_2:
   BEGIN
      IF @nInputKey = 1 -- Yes
      BEGIN
         SET @cOutField01 = @cTrolleyID
         SET @cOutField02 = IIF(@nPosition = 0, 'FULL', CAST(@nPosition AS NVARCHAR(10)))
         SET @cOutField03 = ''

         SET @nStep = @nStep + 1
         SET @nScn = @nScn + 1
         EXEC rdt.rdtSetFocusField @nMobile, 1
      END

      IF @nInputKey = 0 -- Esc
      BEGIN
         SET @nScn = @nScn - 1
         SET @nStep = @nStep - 1
         SET @cOutField01 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
      END
   END
   GOTO Quit

   /********************************************************************************
   Step 3. Scn = 6752 Carton/UCC Screen
      Trolley ID: (field01, Output)
      Position  : (field02, Output)
      Carton/UCC: (field03, Input)
   ********************************************************************************/
   Step_3:
   BEGIN
      IF @nInputKey = 1 -- Yes
      BEGIN
         SET @cUCC = TRIM(@cInField03)
         SET @cOption = TRIM(@cInField04)

         IF @cOption <> ''
         BEGIN
            IF @cOption NOT IN ('1', '9')
            BEGIN
               SET @nErrNo = 254412
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invlid option
               GOTO Step_3_Fail
            END

            IF @cOption = '1'
            BEGIN
               SET @nScn = @nScn + 1
               SET @nStep = @nStep + 1
               SET @cOutField01 = @cTrolleyID
               GOTO Quit
            END

            IF @cOption = '9'
            BEGIN
               SET @nScn = @nScn + 2
               SET @nStep = @nStep + 2
               SET @cOutField01 = @cTrolleyID
               GOTO Quit
            END
         END

         DECLARE @nPositionOccupied INT

         SELECT @nPositionOccupied = MAX(CAST(Position AS INT))
         FROM rdt.RDTTROLLEYLOG WITH (NOLOCK)
         WHERE TrolleyNo = @cTrolleyID
            AND TRY_CAST(Position AS INT) IS NOT NULL

         IF @nPositionOccupied IS NULL
            SET @nPositionOccupied = 0

         IF @nPositionOccupied = @nMaxPosition
         BEGIN
            SET @nErrNo = 254413
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Trolley is full
            GOTO Step_3_Fail
         END

         IF @cUCC = ''
         BEGIN
            SET @nErrNo = 254408
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UCC is needed
            GOTO Step_3_Fail
         END

         DECLARE @cUCCStatus NVARCHAR(1)

         SELECT TOP 1 @cUCCStatus = Status
         FROM dbo.UCC WITH(NOLOCK)
         WHERE UCCNo = @cUCC
            AND StorerKey = @cStorerKey

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 254409
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UCC does not exist
            GOTO Step_3_Fail
         END

         IF @cUCCStatus <> '3'
         BEGIN
            SET @nErrNo = 254410
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Bad UCC Status
            GOTO Step_3_Fail
         END

         SELECT TOP 1
            @cTaskDetailKey = TaskDetailKey
         FROM dbo.TaskDetail WITH(NOLOCK)
         WHERE StorerKey = @cStorerKey
            AND TaskType IN ('RPF', 'RP1', 'RPT', 'ASTTPA')
            AND Status = '0'
            AND CaseID = @cUCC

         SELECT @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 254411
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UCC has no open replenishment task
            GOTO Step_3_Fail
         END

         IF EXISTS(SELECT 1 
                    FROM rdt.rdtTrolleyLog WITH(NOLOCK)
                    WHERE TrolleyNo = @cTrolleyID
                       AND UCCNo = @cUCC)
         BEGIN
            SET @nErrNo = 254419
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  UCC already scanned
            GOTO Step_3_Fail
         END

         SET @nPosition = @nPositionOccupied + 1

         SELECT @nTranCount = @@TRANCOUNT
         
         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdtfnc_BuildUCCTrolley_Step3 -- For rollback or commit only our own transaction

         BEGIN TRY
            INSERT INTO rdt.rdtTrolleyLog (TrolleyNo, Position, UCCNo, LOC, ID, Status, TaskDetailKey)
            VALUES (@cTrolleyID, CAST(@nPosition AS NVARCHAR(10)), @cUCC, '', '', '0', @cTaskDetailKey)
         END TRY
         BEGIN CATCH
            SET @nErrNo = 254417
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert trolley log failed

            ROLLBACK TRAN rdtfnc_BuildUCCTrolley_Step3
            WHILE @@TRANCOUNT > @nTranCount
               COMMIT TRAN

            GOTO Step_3_Fail
         END CATCH

         BEGIN TRY
            UPDATE dbo.TaskDetail WITH(ROWLOCK)
            SET DeviceID = @cTrolleyID,
               Message01 = CAST(@nPosition AS NVARCHAR(10)),
               EditDate = GETDATE(),
               EditWho = @cUserName
            WHERE TaskDetailKey = @cTaskDetailKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 254420
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update Pickdetail failed

            ROLLBACK TRAN rdtfnc_BuildUCCTrolley_Step3
            WHILE @@TRANCOUNT > @nTranCount
               COMMIT TRAN

            GOTO Step_3_Fail
         END CATCH

         COMMIT TRAN rdtfnc_BuildUCCTrolley_Step3
         WHILE @@TRANCOUNT > @nTranCount
            COMMIT TRAN

         IF @nPosition < @nMaxPosition
            SET @nPosition = @nPosition + 1
         ELSE
         BEGIN
            SET @nPosition = 0
         END

         SET @cOutField01 = @cTrolleyID
         SET @cOutField02 = IIF ( @nPosition = 0, 'FULL', CAST(@nPosition AS NVARCHAR(10)) )
         SET @cOutField03 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 3
      END

      IF @nInputKey = 0 -- Esc
      BEGIN
         SET @nScn = @nScn - 2
         SET @nStep = @nStep - 2
         SET @cOutField01 = ''
      END

      GOTO Quit

      Step_3_Fail:
      BEGIN
         EXEC rdt.rdtSetFocusField @nMobile, 1
      END
   END
   GOTO Quit

   /********************************************************************************
   Step 1. Scn = 6753 Confirm Empty Troley
      Trolley ID: (field01, Output)
   ********************************************************************************/
   Step_4:
   BEGIN
      IF @nInputKey = 1 -- Yes
      BEGIN
         DECLARE @tTrolleyLog TABLE
         (
            RowRef INT PRIMARY KEY
         )
         INSERT INTO @tTrolleyLog (RowRef)
         SELECT RowRef 
         FROM RDT.rdtTrolleyLog WITH(NOLOCK)
         WHERE TrolleyNo = @cTrolleyID
         ORDER BY RowRef

         SELECT @nTranCount = @@TRANCOUNT
         
         BEGIN TRAN  -- Begin our own transaction
         SAVE TRAN rdtfnc_BuildUCCTrolley_Step4 -- For rollback or commit only our own transaction

         BEGIN TRY
            SET @nLoopRowRef = -1
            WHILE 1 = 1
            BEGIN
               SELECT TOP 1
                  @nLoopRowRef = RowRef
               FROM @tTrolleyLog
               WHERE RowRef > @nLoopRowRef
               ORDER BY RowRef

               SELECT @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
                  BREAK

               DELETE FROM rdt.rdtTrolleyLog
               WHERE RowRef = @nLoopRowRef
            END
         END TRY
         BEGIN CATCH
            SET @nErrNo = 254414
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Delete trolley log failed

            ROLLBACK TRAN rdtfnc_BuildUCCTrolley_Step4
            WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
            GOTO Step_4_Fail
         END CATCH

         BEGIN TRY
            UPDATE dbo.DeviceProfile WITH(ROWLOCK)
            SET 
               Status = '0',
               EditDate = GETDATE(),
               EditWho = SUSER_NAME()
            WHERE DeviceProfileKey = @cDeviceProfileKey
         END TRY
         BEGIN CATCH
            SET @nErrNo = 254415
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update DeviceProfile failed

            ROLLBACK TRAN rdtfnc_BuildUCCTrolley_Step4
            WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
            GOTO Step_4_Fail
         END CATCH

         COMMIT TRAN rdtfnc_BuildUCCTrolley_Step4
         WHILE @@TRANCOUNT > @nTranCount
            COMMIT TRAN

         SET @nStep = @nStep - 3
         SET @nScn = @nScn - 3
         SET @cOutField01 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
      END

      IF @nInputKey = 0 -- Esc
      BEGIN
         SET @cOutField01 = @cTrolleyID
         SET @cOutField02 = IIF( @nPosition = 0, 'FULL', CAST(@nPosition AS NVARCHAR(10)) )
         SET @cOutField03 = ''

         SET @nStep = @nStep - 1
         SET @nScn = @nScn - 1
         EXEC rdt.rdtSetFocusField @nMobile, 3
      END

      Step_4_Fail:
   END
   GOTO Quit

   /********************************************************************************
   Step 1. Scn = 6754 Close Trolley Screen
      Trolley ID: (field01, Output)
   ********************************************************************************/
   Step_5:
   BEGIN
      IF @nInputKey = 1 -- Yes
      BEGIN
         IF NOT EXISTS(SELECT 1 
                        FROM rdt.RDTTROLLEYLOG WITH (NOLOCK)
                        WHERE TrolleyNo = @cTrolleyID)
         BEGIN
            SET @nErrNo = 254416
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Trolley is empty, cannot close
            GOTO Step_5_Fail
         END

         UPDATE dbo.DeviceProfile WITH(ROWLOCK)
         SET Status = '9',
            EditDate = GETDATE(),
            EditWho = SUSER_NAME()
         WHERE DeviceProfileKey = @cDeviceProfileKey
            AND Status <> '9'

         SET @nStep = @nStep - 4
         SET @nScn = @nScn - 4
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
      END

      IF @nInputKey = 0 -- Esc
      BEGIN
         SET @cOutField01 = @cTrolleyID
         SET @cOutField02 = IIF ( @nPosition = 0, 'FULL', CAST(@nPosition AS NVARCHAR(10)) )
         SET @cOutField03 = ''

         SET @nStep = @nStep - 2
         SET @nScn = @nScn - 2
         EXEC rdt.rdtSetFocusField @nMobile, 3
      END

      Step_5_Fail:
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

         StorerKey    = @cStorerKey,
         Facility     = @cFacility,
         Printer      = @cPrinter,
         Printer_Paper= @cPrinterPpr,

         V_String1    = @cTrolleyID,
         V_String2    = @cDeviceProfileKey,

         V_Integer1   = @nPosition,
         V_Integer2   = @nMaxPosition,

         I_Field01 = @cInField01,  O_Field01 = @cOutField01,   FieldAttr01 = @cFieldAttr01,
         I_Field02 = @cInField02,  O_Field02 = @cOutField02,   FieldAttr02 = @cFieldAttr02,
         I_Field03 = @cInField03,  O_Field03 = @cOutField03,   FieldAttr03 = @cFieldAttr03,
         I_Field04 = @cInField04,  O_Field04 = @cOutField04,   FieldAttr04 = @cFieldAttr04,
         I_Field05 = @cInField05,  O_Field05 = @cOutField05,   FieldAttr05 = @cFieldAttr05,
         I_Field06 = @cInField06,  O_Field06 = @cOutField06,   FieldAttr06 = @cFieldAttr06,
         I_Field07 = @cInField07,  O_Field07 = @cOutField07,   FieldAttr07 = @cFieldAttr07,
         I_Field08 = @cInField08,  O_Field08 = @cOutField08,   FieldAttr08 = @cFieldAttr08,
         I_Field09 = @cInField09,  O_Field09 = @cOutField09,   FieldAttr09 = @cFieldAttr09,
         I_Field10 = @cInField10,  O_Field10 = @cOutField10,   FieldAttr10 = @cFieldAttr10,
         I_Field11 = @cInField11,  O_Field11 = @cOutField11,   FieldAttr11 = @cFieldAttr11,
         I_Field12 = @cInField12,  O_Field12 = @cOutField12,   FieldAttr12 = @cFieldAttr12,
         I_Field13 = @cInField13,  O_Field13 = @cOutField13,   FieldAttr13 = @cFieldAttr13,
         I_Field14 = @cInField14,  O_Field14 = @cOutField14,   FieldAttr14 = @cFieldAttr14,
         I_Field15 = @cInField15,  O_Field15 = @cOutField15,   FieldAttr15 = @cFieldAttr15,
         I_Field16 = @cInField16,  O_Field16 = @cOutField16,   FieldAttr16 = @cFieldAttr16,
         I_Field17 = @cInField17,  O_Field17 = @cOutField17,   FieldAttr17 = @cFieldAttr17,
         I_Field18 = @cInField18,  O_Field18 = @cOutField18,   FieldAttr18 = @cFieldAttr18,
         I_Field19 = @cInField19,  O_Field19 = @cOutField19,   FieldAttr19 = @cFieldAttr19,
         I_Field20 = @cInField20,  O_Field20 = @cOutField20,   FieldAttr20 = @cFieldAttr20

      WHERE Mobile = @nMobile
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_BuildUCCTrolley TO NSQL
GO
