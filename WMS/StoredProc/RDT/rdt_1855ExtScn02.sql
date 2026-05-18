
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***********************************************************************************/  
/* Store procedure: rdt_1855ExtScn02                                               */  
/*                                                                                 */  
/* Purpose: For US Levis                                                           */
/*                                                                                 */
/* Modifications log:                                                              */  
/*                                                                                 */  
/* Date       Rev    Author     Purposes                                           */  
/* 2026-03-02 1.0    NickT      FCR-10824. Created                                 */
/***********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1855ExtScn02] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep INT,           
   @nScn  INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15), 

   @tExtScnData   VariableTable READONLY,

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
   @nAction      INT, --0 Jump Screen, 2. Prepare output fields, Step = 99 is a new screen
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo             INT            OUTPUT, 
   @cErrMsg            NVARCHAR( 20)  OUTPUT,
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
      @nCurrentStep        INT,
      @nCurrentScn         INT,
      @nMenu               INT,
      @cUserName           NVARCHAR( 18),

      @cPickZone           NVARCHAR( 10),
      @cMethod             NVARCHAR( 1),
      @cCartID             NVARCHAR( 10),
      @cPickNoMixWave      NVARCHAR( 1),
      @cExtendedValidateSP NVARCHAR( 20),
      @cWaveKey            NVARCHAR( 10),
      @cTaskDetailKey      NVARCHAR( 10),
      @cGroupkey           NVARCHAR( 10),
      @cCartonID           NVARCHAR( 20),
      @cResult01           NVARCHAR( 20),
      @cResult02           NVARCHAR( 20),
      @cResult03           NVARCHAR( 20),
      @cResult04           NVARCHAR( 20),
      @cResult05           NVARCHAR( 20),
      @cFromLoc            NVARCHAR( 10),
      @cSKU                NVARCHAR( 20),
      @cSuggFromLOC        NVARCHAR( 10),
      @cPickMethod         NVARCHAR( 10),
      @cLockCaseID         NVARCHAR( 20),
      @cDisableQTYFieldSP  NVARCHAR( 20),
      @cSuggCartonID       NVARCHAR( 20),
      @cSuggToteId         NVARCHAR( 20),
      @cSuggSKU            NVARCHAR( 20),
      @cLockTaskKey        NVARCHAR( 10),
      @cCartonType         NVARCHAR( 10),
      @cDisableQTYField    NVARCHAR( 1),
      @cPickConfirmStatus  NVARCHAR( 1),
      @cOption             NVARCHAR( 5),
      @cContinuePickOnAssignedCart  NVARCHAR( 1),
      @tGetTask            VariableTable,
      @cCartPickMethod     NVARCHAR( 40),
      @nCartLitmit         INT,
      @nCartonCnt          INT,
      @nTranCount          INT,
      @nLoopIndex          INT,
      @nCount              INT,
      @nCartLimit          INT,
      @nQty                INT,
      @nSuggQty            INT,
      @nPickedQty          INT,
      @nNextPage           INT,
      @nCartonScanned      INT,
      @nRowCount           INT,

      @nStep_CartID           INT,  @nScn_CartID            INT,
      @nStep_CartMatrix       INT,  @nScn_CartMatrix        INT,
      @nStep_Loc              INT,  @nScn_Loc               INT,
      @nStep_UnAssign         INT,  @nScn_UnAssign          INT,
      @nStep_ContTask         INT,  @nScn_ContTask          INT

   SELECT
      @nStep_CartID           = 1,  @nScn_CartID            = 6844,
      @nStep_CartMatrix       = 2,  @nScn_CartMatrix        = 6845,
      @nStep_Loc              = 3,  @nScn_Loc               = 5922,
      @nStep_UnAssign         = 8,  @nScn_UnAssign          = 5927,
      @nStep_ContTask         = 10, @nScn_ContTask          = 5929

   DECLARE @tTaskDetail TABLE 
   (
      RowRef INT IDENTITY(1,1),
      TaskDetailKey NVARCHAR( 10) PRIMARY KEY,
      OrderKey NVARCHAR( 10),
      Groupkey NVARCHAR( 10) 
   )
      
   SELECT 
      @nCurrentStep = @nStep, 
      @nCurrentScn = @nScn,
      @cUserName = USerName,

      @nMenu               = Menu,
      @cCartonID           = V_CaseID,

      @nSuggQty            = V_Integer1,
      @cTaskDetailKey      = V_TaskDetailKey,

      @cExtendedValidateSP = V_String2,
      @cDisableQTYFieldSP  = V_String5,
      @cDisableQTYField    = V_String6,
      @cCartID             = V_String8,
      @cSuggFromLOC        = V_String9,
      @cSuggCartonID       = V_String10,
      @cSuggSKU            = V_String11,
      @cGroupKey           = V_String12,
      @cPickZone           = V_String24,
      @cMethod             = V_String25,
      @cResult01           = V_String26,
      @cResult02           = V_String27,
      @cResult03           = V_String28,
      @cResult04           = V_String29,
      @cResult05           = V_String30,
      @cSuggToteId         = V_String31,
      @cCartPickMethod     = V_String41,
      @cContinuePickOnAssignedCart = V_String42,
      @cPickNoMixWave      = V_String43,

      @cWaveKey            = C_String1
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   SET @cUDF01 = ''
   SET @cUDF02 = ''
   SET @cUDF03 = ''
   SET @cUDF04 = ''

   IF @nFunc = 1855
   BEGIN
      IF @nCurrentStep = 10
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SET @cOption = @cInField01
            IF @cOption = '1'
            BEGIN
               SET @nAfterScn = @nScn_CartMatrix
               SET @nAfterStep = @nStep_CartMatrix
            END
         END
      END
      ELSE IF @nCurrentStep = 99
      BEGIN
         IF @nCurrentScn = @nScn_CartID
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Screen mapping
               SET @cPickZone = @cInField01
               SET @cCartID = @cInField02
               SET @cMethod = @cInField03

               -- Retain value
               SET @cOutField01 = @cInField01
               SET @cOutField02 = @cInField02
               SET @cOutField03 = @cInField03

               IF @cContinuePickOnAssignedCart = '1' AND @cCartID <> ''
               BEGIN
                  IF EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                              WHERE Storerkey = @cStorerKey
                                 AND TaskType = 'ASTCPK'
                                 AND Status = '3'
                                 AND Groupkey <> ''
                                 AND UserKey = @cUserName
                                 AND DeviceID = @cCartID)
                  BEGIN
                     SET @cOutField01 = ''

                     SET @nAfterScn = @nScn_ContTask
                     SET @nAfterStep = @nStep_ContTask

                     GOTO UPD_RDTMOBREC
                  END
               END

               -- Check blank
               IF @cPickZone = ''
               BEGIN
                  SET @nErrNo = 260401
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --260401 Need PickZone
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO UPD_RDTMOBREC
               END

               -- Check pickzone valid
               IF NOT EXISTS( SELECT 1 FROM dbo.TaskDetail TD WITH (NOLOCK)
                              INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
                              WHERE TD.Storerkey = @cStorerKey
                                 AND TD.TaskType = 'ASTCPK'
                                 AND TD.Status = '0'
                                 AND TD.UserKey = ''
                                 AND TD.DeviceID = ''
                                 AND LOC.Facility = @cFacility
                                 AND LOC.PickZone = @cPickZone)
               BEGIN
                  SET @nErrNo = 260402
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No task in PickZone
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  SET @cOutField01 = ''
                  GOTO UPD_RDTMOBREC
               END
               SET @cOutField01 = @cPickZone

               -- Check blank
               IF @cCartID = ''
               BEGIN
                  SET @nErrNo = 260403
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Need CartID
                  EXEC rdt.rdtSetFocusField @nMobile, 2
                  GOTO UPD_RDTMOBREC
               END

               -- Check cart valid
               IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK)
                              WHERE DeviceType = 'CART'
                                 AND DeviceID = @cCartID)
               BEGIN
                  SET @nErrNo = 260404
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid CartID
                  EXEC rdt.rdtSetFocusField @nMobile, 2
                  SET @cOutField02 = ''
                  GOTO UPD_RDTMOBREC
               END

               -- Check cart use by other
               IF EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                           WHERE Storerkey = @cStorerKey
                              AND TaskType = 'ASTCPK'
                              AND Status = '3'
                              AND DeviceID = @cCartID
                              AND UserKey <> @cUserName)
               BEGIN
                  SET @nErrNo = 260405
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Cart is in use by other user
                  EXEC rdt.rdtSetFocusField @nMobile, 2
                  SET @cOutField02 = ''
                  GOTO UPD_RDTMOBREC
               END
               SET @cOutField02 = @cCartID

               -- Check blank
               IF @cMethod = ''
               BEGIN
                  SET @nErrNo = 260406
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need Method
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  GOTO UPD_RDTMOBREC
               END

               IF @cMethod NOT IN ('1', '2')
               BEGIN
                  SET @nErrNo = 260423
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Methond must be 1 or 2
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  GOTO UPD_RDTMOBREC
               END

               -- Check Method valid
               SELECT @cCartPickMethod = Long
               FROM dbo.CODELKUP WITH (NOLOCK)
               WHERE LISTNAME = 'TMPickMtd'
                  AND Code = @cMethod
                  AND Storerkey = @cStorerKey

               IF ISNULL( @cCartPickMethod, '') = ''
               BEGIN
                  SET @nErrNo = 260407
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Method
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  SET @cOutField03 = ''
                  GOTO UPD_RDTMOBREC
               END

               DECLARE @n INT
               SELECT @n = CHARINDEX(',', @cCartPickMethod)
               DECLARE @tPickMethod TABLE ( Method    NVARCHAR( 20) )
               IF @n > 0
               BEGIN
                  INSERT INTO @tPickMethod (Method) VALUES (LEFT( @cCartPickMethod, @n-1))
                  INSERT INTO @tPickMethod (Method) VALUES (LTRIM(SUBSTRING( @cCartPickMethod, @n+1, 20)))
               END
               ELSE
                  INSERT INTO @tPickMethod (Method) VALUES (@cCartPickMethod)

               -- Check pickzone + method valid
               IF NOT EXISTS( SELECT 1 FROM dbo.TaskDetail TD WITH (NOLOCK)
                              INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
                              WHERE TD.Storerkey = @cStorerKey
                                 AND TD.TaskType = 'ASTCPK'
                                 AND TD.Status = '0'
                                 AND TD.UserKey = ''
                                 AND TD.DeviceID = ''
                                 AND LOC.Facility = @cFacility
                                 AND LOC.PickZone = @cPickZone
                                 AND EXISTS ( SELECT 1 FROM @tPickMethod PM WHERE TD.PickMethod = PM.Method))
               BEGIN
                  SET @nErrNo = 260408
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No task for the Method
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  SET @cOutField03 = ''
                  GOTO UPD_RDTMOBREC
               END
               SET @cOutField03 = @cMethod

               DECLARE @cCurCaseID  NVARCHAR( 20)
               DECLARE @cNewCaseID  NVARCHAR( 20)
               DECLARE @nCtnCount   INT
               SET @cCurCaseID = ''
               SET @cNewCaseID = ''
               SET @nCtnCount = 0

               DECLARE @cShort                 NVARCHAR(10)

               SELECT @cShort = Short
               FROM dbo.CODELKUP WITH (NOLOCK)
               WHERE LISTNAME = 'TMPICKMTD'
                  AND Code = @cMethod
                  AND Storerkey = @cStorerKey

               SET @nCartLitmit = ISNULL(TRY_CAST(@cShort AS INT), -1)

               IF @nCartLitmit < 1
               BEGIN
                  SET @nErrNo = 260422
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid carton limit configuration for method 2
                  GOTO UPD_RDTMOBREC
               END

               SET @cGroupkey = ''
               SET @cWaveKey = ''
               SET @cTaskDetailKey = ''

               IF @cMethod = '1' -- B2C Single
               BEGIN
                  -- Find the first task
                  SELECT TOP 1
                     @cGroupkey = TD.Groupkey,
                     @cWaveKey = TD.WaveKey,
                     @cTaskDetailKey = TD.TaskDetailKey
                  FROM dbo.TaskDetail TD WITH (ROWLOCK)
                  INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON O.UserDefine09 IS NOT NULL AND TD.WaveKey = O.UserDefine09 AND O.DocType = 'E' AND O.ECOM_SINGLE_Flag = 'S'
                  INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
                  WHERE TD.Storerkey = @cStorerKey
                     AND TD.TaskType = 'ASTCPK'
                     AND TD.Status = '0'
                     AND TD.UserKey = ''
                     AND TD.DeviceID = ''
                     AND TD.UserKeyOverRide IN ('', @cUserName)
                     AND LOC.Facility = @cFacility
                     AND LOC.PickZone = @cPickZone
                     AND EXISTS ( SELECT 1 FROM @tPickMethod PM WHERE TD.PickMethod = PM.Method)
                  ORDER BY CASE WHEN TD.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END, LOC.PALogicalLoc, TD.TaskDetailKey

                  IF ISNULL(@cTaskDetailKey, '') = ''
                  BEGIN
                     SET @nErrNo = 260409
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No task is found
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     SET @cOutField03 = ''
                     GOTO UPD_RDTMOBREC
                  END

                  SET @nCartLimit = 99999 -- For B2C single pick, allow as many cartons as possible on the cart since they are not from the same wave, so the wave limit does not apply
               END
               ELSE IF @cMethod = '2' -- Other pick method, B2C Multies
               BEGIN
                  -- Find the first task
                  SELECT TOP 1
                     @cGroupkey = TD.Groupkey,
                     @cWaveKey = TD.WaveKey,
                     @cTaskDetailKey = TD.TaskDetailKey
                  FROM dbo.TaskDetail TD WITH (ROWLOCK)
                  INNER JOIN dbo.ORDERS O WITH (NOLOCK) ON TD.OrderKey = O.OrderKey AND O.DocType = 'E' AND O.ECOM_SINGLE_Flag = 'M'
                  INNER JOIN dbo.OrderDetail OD WITH(NOLOCK) ON TD.OrderKey= OD.OrderKey AND TD.SKU = OD.SKU
                  INNER JOIN dbo.LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
                  WHERE TD.Storerkey = @cStorerKey
                     AND TD.TaskType = 'ASTCPK'
                     AND TD.Status = '0'
                     AND TD.UserKey = ''
                     AND TD.DeviceID = ''
                     AND TD.UserKeyOverRide IN ('', @cUserName)
                     AND LOC.Facility = @cFacility
                     AND LOC.PickZone = @cPickZone
                     AND EXISTS ( SELECT 1 FROM @tPickMethod PM WHERE TD.PickMethod = PM.Method)
                  ORDER BY CASE WHEN TD.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END, LOC.PALogicalLoc, TD.TaskDetailKey

                  IF ISNULL(@cTaskDetailKey, '') = ''
                  BEGIN
                     SET @nErrNo = 260411
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  No task is found
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     SET @cOutField03 = ''
                     GOTO UPD_RDTMOBREC
                  END
               END

               -- Lock other tasks with the same groupkey
               DELETE FROM @tTaskDetail
               INSERT INTO @tTaskDetail (TaskDetailKey, Groupkey, OrderKey)
               SELECT TD.TaskDetailKey, TD.Groupkey, TD.OrderKey
               FROM dbo.TaskDetail TD WITH (ROWLOCK)
               INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
               WHERE TD.Storerkey = @cStorerKey
                  AND TD.TaskType = 'ASTCPK'
                  AND TD.Status = '0'
                  AND TD.UserKey = ''
                  AND TD.DeviceID = ''
                  AND TD.UserKeyOverRide IN ('', @cUserName)
                  AND TD.WaveKey = @cWaveKey
                  AND TD.Groupkey = @cGroupkey
                  AND LOC.Facility = @cFacility
                  AND LOC.PickZone = @cPickZone
                  AND EXISTS ( SELECT 1 FROM @tPickMethod PM WHERE TD.PickMethod = PM.Method)
               ORDER BY CASE WHEN TD.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END, LOC.PALogicalLoc, TD.TaskDetailKey

               IF @cMethod = '2'
               BEGIN
                  SELECT @nCount = COUNT(DISTINCT OrderKey)
                  FROM @tTaskDetail

                  IF @nCount > @nCartLimit
                  BEGIN
                     SET @nErrNo = 260424
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  More orders than max totes allowed for method 2
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     SET @cOutField03 = ''
                     GOTO UPD_RDTMOBREC
                  END
               END

               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN
               SAVE TRAN rdt_1855ExtScn02_6844

               UPDATE rdt.RDTMOBREC WITH(ROWLOCK) 
               SET 
                  C_String1 = @cWaveKey,
                  V_String12 = @cGroupKey
               WHERE Mobile = @nMobile

               SET @nLoopIndex = -1
               DECLARE @cLoopTaskDetailKey  NVARCHAR( 10) = ''
               DECLARE @cLoopOrderKey       NVARCHAR( 10) = ''
               DECLARE @tOrders TABLE ( OrderKey NVARCHAR( 10) PRIMARY KEY)
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1 
                     @cLoopTaskDetailKey = TaskDetailKey,
                     @cLoopOrderKey = OrderKey,
                     @nLoopIndex = RowRef
                  FROM @tTaskDetail
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0
                     BREAK

                  IF NOT EXISTS(SELECT 1 FROM @tOrders WHERE OrderKey = @cLoopOrderKey)
                  BEGIN
                     INSERT INTO @tOrders (OrderKey)
                     SELECT @cLoopOrderKey
                  END

                  BEGIN TRY
                     UPDATE dbo.TaskDetail WITH (ROWLOCK)
                     SET UserKey = @cUserName,
                        DeviceID = @cCartID,
                        Status = '3',
                        TrafficCop = NULL
                     WHERE TaskDetailKey = @cLoopTaskDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 260410
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update task failed
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     SET @cOutField03 = ''
                     GOTO LockTask_RollBackTran
                  END CATCH

                  SELECT @nCount = COUNT(1) FROM @tOrders

                  IF @nCount >= @nCartLimit
                     BREAK
               END

               -- 1 single order may have more than one task details, so after locking tasks with the same groupkey, need to check if there are still tasks not locked for the orders in the same wave, 
               -- if yes, lock them as well. This is to make sure all tasks for the orders in the same wave are locked to avoid other users can pick them at the same time
               DELETE FROM @tTaskDetail
               INSERT INTO @tTaskDetail (TaskDetailKey, Groupkey, OrderKey)
               SELECT TD.TaskDetailKey, TD.Groupkey, TD.OrderKey
               FROM dbo.TaskDetail TD WITH (ROWLOCK)
               INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON TD.FromLoc = LOC.Loc
               WHERE TD.Storerkey = @cStorerKey
                  AND TD.TaskType = 'ASTCPK'
                  AND TD.Status = '0'
                  AND TD.UserKey = ''
                  AND TD.DeviceID = ''
                  AND TD.UserKeyOverRide IN ('', @cUserName)
                  AND TD.WaveKey = @cWaveKey
                  AND TD.OrderKey IN (SELECT OrderKey FROM @tOrders)
                  AND TD.Groupkey = @cGroupkey
                  AND LOC.Facility = @cFacility
                  AND LOC.PickZone = @cPickZone
                  AND EXISTS ( SELECT 1 FROM @tPickMethod PM WHERE TD.PickMethod = PM.Method)
               ORDER BY CASE WHEN TD.UserKeyOverRide = @cUserName THEN '0' ELSE '1' END, LOC.PALogicalLoc

               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1 
                     @cLoopTaskDetailKey = TaskDetailKey,
                     @cLoopOrderKey = OrderKey,
                     @nLoopIndex = RowRef
                  FROM @tTaskDetail
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0
                     BREAK

                  BEGIN TRY
                     UPDATE dbo.TaskDetail WITH (ROWLOCK)
                     SET UserKey = @cUserName,
                        DeviceID = @cCartID,
                        Status = '3',
                        TrafficCop = NULL
                     WHERE TaskDetailKey = @cLoopTaskDetailKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 260412
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update task failed
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     SET @cOutField03 = ''
                     GOTO LockTask_RollBackTran
                  END CATCH
               END

               GOTO LockTask_Commit

               LockTask_RollBackTran:
                     ROLLBACK TRAN rdt_1855ExtScn02_6844
               LockTask_Commit:
                  WHILE @@TRANCOUNT > @nTranCount
                     COMMIT TRAN

               IF @nErrNo <> 0
                  GOTO UPD_RDTMOBREC

               SET @cResult01 = ''
               SET @cResult02 = ''
               SET @cResult03 = ''
               SET @cResult04 = ''
               SET @cResult05 = ''

               -- Draw matrix
               SET @nNextPage = 0
               EXEC rdt.rdt_TM_Assist_ClusterPick_Matrix
                  @nMobile          = @nMobile,
                  @nFunc            = @nFunc,
                  @cLangCode        = @cLangCode,
                  @nStep            = @nStep,
                  @nInputKey        = @nInputKey,
                  @cFacility        = @cFacility,
                  @cStorerKey       = @cStorerKey,
                  @cPickZone        = @cPickZone,
                  @cCartID          = @cCartID,
                  @cMethod          = @cMethod,
                  @cResult01        = @cResult01   OUTPUT,
                  @cResult02        = @cResult02   OUTPUT,
                  @cResult03        = @cResult03   OUTPUT,
                  @cResult04        = @cResult04   OUTPUT,
                  @cResult05        = @cResult05   OUTPUT,
                  @nNextPage        = @nNextPage   OUTPUT,
                  @nErrNo           = @nErrNo      OUTPUT,
                  @cErrMsg          = @cErrMsg     OUTPUT

               IF @nErrNo <> 0
                  GOTO UPD_RDTMOBREC

               -- Prepare next screen var
               SET @cOutField01 = @cCartPickMethod
               SET @cOutField02 = @cCartID
               SET @cOutField03 = @cResult01
               SET @cOutField04 = @cResult02
               SET @cOutField05 = @cResult03
               SET @cOutField06 = @cResult04
               SET @cOutField07 = @cResult05
               SET @cOutField08 = ''
               SET @cOutField09 = 0
               SET @cOutField15 = ''

               SET @cFromLoc = ''
               SET @cCartonID = ''
               SET @cSKU = ''
               SET @nQTY = 0

               -- Go to next screen
               SET @nAfterScn = @nScn_CartMatrix
               SET @nAfterStep = 99
            END

            IF @nInputKey = 0 -- Esc or No
            BEGIN
               -- Logging
               EXEC RDT.rdt_STD_EventLog
                  @cActionType = '9', -- Sign Out function
                  @cUserID     = @cUserName,
                  @nMobileNo   = @nMobile,
                  @nFunctionID = @nFunc,
                  @cFacility   = @cFacility,
                  @cStorerKey  = @cStorerkey,
                  @nStep       = @nStep

               -- Back to menu
               SET @nFunc = @nMenu
               SET @nAfterScn  = @nMenu
               SET @nAfterStep = 0

               -- Reset all variables
               SET @cOutField01 = ''

               -- Enable field
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
            END
            GOTO UPD_RDTMOBREC
         END
         ELSE IF @nCurrentScn = @nScn_CartMatrix
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            SET @nErrNo = 0
            IF @nInputKey = 1 -- ENTER
            BEGIN
               SET @cCartonId = @cInField08

               SELECT @nCartLimit = ISNULL(TRY_CAST(Short AS INT), 1)
               FROM dbo.CODELKUP WITH (NOLOCK)
               WHERE LISTNAME = 'TMPICKMTD'
                  AND Code = @cMethod
                  AND Storerkey = @cStorerKey

               IF @cMethod = '1'
                  SET @nCartLimit = 1

               SELECT @nCartonScanned = COUNT( DISTINCT DropID)
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE Storerkey = @cStorerKey
                  AND TaskType = 'ASTCPK'
                  AND Status = '3'
                  AND Groupkey = @cGroupKey
                  AND UserKey = @cUserName
                  AND DeviceID = @cCartID
                  AND WaveKey = @cWaveKey
                  AND DropID <> ''

               IF ISNULL( @cCartonId, '') = ''
               BEGIN
                  IF @nCartonScanned = 0
                  BEGIN
                     SET @nErrNo = 260413
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No ToteID is scanned
                     GOTO UPD_RDTMOBREC
                  END

                  SELECT @nCartonCnt = COUNT( DISTINCT DropID)
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                     AND TaskType = 'ASTCPK'
                     AND Status IN ( '3', '5')
                     AND Groupkey = @cGroupkey
                     AND UserKey = @cUserName
                     AND WaveKey = @cWaveKey
                     AND DeviceID = @cCartID
                     AND DropID <> ''

                  IF @nCartonCnt < @nCartLimit AND
                  EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                              WHERE Storerkey = @cStorerKey
                              AND TaskType = 'ASTCPK'
                              AND Status = '3'
                              AND Groupkey = @cGroupkey
                              AND WaveKey = @cWaveKey
                              AND UserKey = @cUserName
                              AND DeviceID = @cCartID
                              AND DropID = '')
                  BEGIN
                     SET @nErrNo = 260414
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Need More ToteID
                     GOTO UPD_RDTMOBREC
                  END
                  ELSE  --Something scanned
                  BEGIN
                     --Get task for next loc
                     SET @nErrNo = 0
                     SET @cSuggFromLOC = ''
                     EXEC [RDT].[rdt_TM_Assist_ClusterPick_GetTask]
                        @nMobile          = @nMobile,
                        @nFunc            = @nFunc,
                        @cLangCode        = @cLangCode,
                        @nStep            = @nStep,
                        @nInputKey        = @nInputKey,
                        @cFacility        = @cFacility,
                        @cStorerKey       = @cStorerKey,
                        @cGroupKey        = @cGroupKey,
                        @cCartId          = @cCartId,
                        @cType            = 'NEXTLOC',
                        @cTaskDetailKey   = @cTaskDetailKey OUTPUT,
                        @cFromLoc         = @cSuggFromLOC   OUTPUT,
                        @cCartonId        = @cSuggCartonID  OUTPUT,
                        @cToteId          = @cSuggToteId    OUTPUT,
                        @cSKU             = @cSuggSKU       OUTPUT,
                        @nQty             = @nSuggQty       OUTPUT,
                        @tGetTask         = @tGetTask,
                        @nErrNo           = @nErrNo         OUTPUT,
                        @cErrMsg          = @cErrMsg        OUTPUT

                     IF @nErrNo <> 0
                        GOTO UPD_RDTMOBREC

                     -- Prepare next screen var
                     SET @cOutField01 = @cCartPickMethod
                     SET @cOutField02 = @cSuggFromLOC
                     SET @cOutField03 = ''

                     -- Go to next screen
                     SET @nAfterScn = @nScn_Loc
                     SET @nAfterStep = @nStep_Loc

                     GOTO UPD_RDTMOBREC
                  END
               END

               IF EXISTS ( SELECT 1
                           FROM dbo.TaskDetail WITH (NOLOCK)
                           WHERE Storerkey = @cStorerKey
                              AND TaskType = 'ASTCPK'
                              AND Status = '3'
                              AND Groupkey = @cGroupKey
                              AND WaveKey = @cWaveKey
                              AND UserKey = @cUserName
                              AND DeviceID = @cCartID
                              AND DropID = @cCartonId)
               BEGIN
                  SET @nErrNo = 260415
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ToteID is scanned already
                  GOTO UPD_RDTMOBREC
               END

               -- Check if all carton assigned
               IF NOT EXISTS ( SELECT 1
                              FROM dbo.TaskDetail WITH (NOLOCK)
                              WHERE Storerkey = @cStorerKey
                                 AND TaskType = 'ASTCPK'
                                 AND Status = '3'
                                 AND Groupkey = @cGroupKey
                                 AND WaveKey = @cWaveKey
                                 AND UserKey = @cUserName
                                 AND DeviceID = @cCartID
                                 AND DropID = '')
               BEGIN
                  SET @nErrNo = 260417
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- All ToteID is assigned
                  GOTO UPD_RDTMOBREC
               END

               IF EXISTS ( SELECT 1
                           FROM dbo.TaskDetail WITH (NOLOCK)
                           WHERE Storerkey = @cStorerKey
                              AND TaskType = 'ASTCPK'
                              AND Status < '9'
                              AND DropID = @cCartonId)
               BEGIN
                  SET @nErrNo = 260416
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ToteID is in use by other user
                  GOTO UPD_RDTMOBREC
               END

               IF EXISTS ( SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK)
                           WHERE Storerkey = @cStorerKey
                              AND DropID = @cCartonID
                              AND  (Status = '4' OR
                                    Status < @cPickConfirmStatus OR
                                    (Status = '3' AND CaseID <> 'SORTED') OR
                                    (Status = '3' AND CaseID <> '')))
               BEGIN
                  SET @nErrNo = 260418
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Tote In Use
                  GOTO UPD_RDTMOBREC
               END

               IF EXISTS ( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                           WHERE Storerkey = @cStorerKey
                              AND DropID = @cCartonID
                              AND TaskType = 'ASTCPK'
                              AND (Groupkey <> @cGroupKey OR WaveKey <> @cWaveKey)
                              AND Status IN ('3', '5'))
               BEGIN
                  SET @nErrNo = 260431
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ToteID is used in other wave/group
                  GOTO UPD_RDTMOBREC
               END

               IF EXISTS(SELECT 1 FROM dbo.DropID WITH(NOLOCK)
                          WHERE DropID = @cCartonID)
               BEGIN
                  IF EXISTS(SELECT 1 FROM TaskDetail TD1 WITH(NOLOCK)
                           INNER JOIN TaskDetail TD2 WITH(NOLOCK) 
                              ON TD1.StorerKey = TD2.StorerKey 
                              AND TD1.WaveKey = TD2.WaveKey 
                              AND TD1.GroupKey = TD2.Groupkey 
                              AND TD1.TaskType = TD2.TaskType
                           WHERE TD1.Storerkey = @cStorerKey
                              AND TD1.TaskType = 'ASTCPK'
                              AND TD1.Status = '9'
                              AND TD1.DropID IS NOT NULL
                              AND TD1.DropID = @cCartonID
                              AND (TD1.WaveKey <> @cWaveKey OR TD1.GroupKey <> @cGroupKey)
                              AND TD2.Status < '5')
                  BEGIN
                     SET @nErrNo = 260432
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ToteID is used in other wave/group
                     GOTO UPD_RDTMOBREC
                  END
               END

               IF @nCartonScanned >= @nCartLimit
               BEGIN
                  SET @nErrNo = 260429
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No need more ToteID
                  GOTO UPD_RDTMOBREC
               END

               SELECT @cCartonType = UDF01
               FROM dbo.CODELKUP WITH (NOLOCK)
               WHERE LISTNAME = 'TMPICKMTD'
                  AND Code = @cMethod
                  AND Storerkey = @cStorerKey

               SET @cPickMethod = ''
               SELECT @cPickMethod = Long
               FROM dbo.CODELKUP WITH (NOLOCK)
               WHERE LISTNAME = 'TMPICKMTD'
                  AND Storerkey = @cStorerKey
                  AND UDF01 = SUBSTRING( @cCartonId, 1, 1)

               DELETE FROM @tTaskDetail

               INSERT INTO @tTaskDetail (TaskDetailKey, OrderKey)
               SELECT TD.TaskDetailKey, TD.OrderKey
               FROM dbo.TaskDetail TD WITH (NOLOCK)
               INNER JOIN dbo.LOC WITH(NOLOCK) ON TD.FromLoc = LOC.Loc
               WHERE TD.Storerkey = @cStorerKey
                  AND TD.TaskType = 'ASTCPK'
                  AND TD.Status = '3'
                  AND TD.Groupkey = @cGroupKey
                  AND TD.WaveKey = @cWaveKey
                  AND TD.UserKey = @cUserName
                  AND TD.DeviceID = @cCartID
                  AND TD.DropID = ''
               ORDER BY LOC.PALogicalLoc, LOC.Loc, TD.TaskDetailKey, TD.Sku

               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN
               SAVE TRAN rdt_1855ExtScn02_6845

               -- B2C Singles
               IF @cMethod = '1'
               BEGIN
                  SET @nLoopIndex = -1
                  WHILE 1 = 1
                  BEGIN
                     SELECT TOP 1 
                        @cLockTaskKey = TaskDetailKey,
                        @nLoopIndex = RowRef
                     FROM @tTaskDetail
                     WHERE RowRef > @nLoopIndex
                     ORDER BY RowRef

                     IF @@ROWCOUNT = 0
                        BREAK

                     BEGIN TRY
                        UPDATE dbo.TaskDetail SET
                           DropID = @cCartonID,
                           StatusMsg = CAST( @nCartonScanned + 1 AS NVARCHAR( 5)) + '-' + ISNULL(@cCartonType, ''),
                           EditWho = @cUserName,
                           EditDate = GETDATE()
                        WHERE TaskDetailKey = @cLockTaskKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 260419
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update task failed
                        SET @cOutField08 = ''
                        GOTO LockDropID_RollBackTran
                     END CATCH
                  END
               END
               ELSE
               -- B2C Multies, assign carton per order level
               BEGIN
                  DECLARE @tOrderTaskDetail TABLE (RowRef INT IDENTITY(1,1), TaskDetailKey NVARCHAR( 10))
                  DECLARE @cStatsuMsg NVARCHAR( 50)

                  SET @nLoopIndex = -1
                  SELECT TOP 1
                     @cLoopOrderKey = OrderKey
                  FROM @tTaskDetail
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  SET @cStatsuMsg = CAST( @nCartonScanned + 1 AS NVARCHAR( 5)) + '-' + ISNULL(@cCartonType, '')

                  DELETE FROM @tOrderTaskDetail
                  BEGIN TRY
                     INSERT INTO @tOrderTaskDetail (TaskDetailKey)
                     SELECT DISTINCT TaskDetailKey
                     FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE Storerkey = @cStorerKey
                        AND TaskType = 'ASTCPK'
                        AND Status = '3'
                        AND Groupkey = @cGroupKey
                        AND WaveKey = @cWaveKey
                        AND UserKey = @cUserName
                        AND DeviceID = @cCartID
                        AND DropID = ''
                        AND OrderKey = @cLoopOrderKey
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 260420
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Insert @tOrderCartonID data failed
                     SET @cOutField08 = ''
                     GOTO LockDropID_RollBackTran
                  END CATCH

                  DECLARE @nLoopIndex2 INT
                  DECLARE @cLockTaskKey2 NVARCHAR( 10)

                  SET @nLoopIndex2 = -1
                  WHILE 1 = 1
                  BEGIN
                     SELECT TOP 1 
                        @cLockTaskKey2 = TaskDetailKey,
                        @nLoopIndex2 = RowRef
                     FROM @tOrderTaskDetail
                     WHERE RowRef > @nLoopIndex2
                     ORDER BY RowRef

                     IF @@ROWCOUNT = 0
                        BREAK

                     BEGIN TRY
                        UPDATE dbo.TaskDetail SET
                           DropID = @cCartonID,
                           StatusMsg = @cStatsuMsg,
                           EditWho = @cUserName,
                           EditDate = GETDATE()
                        WHERE TaskDetailKey = @cLockTaskKey2
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 260421
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update task failed
                        SET @cOutField08 = ''
                        GOTO LockDropID_RollBackTran
                     END CATCH
                  END
               END

               GOTO LockDropID_Commit

               LockDropID_RollBackTran:
                     ROLLBACK TRAN rdt_1855ExtScn02_6845
               LockDropID_Commit:
                  WHILE @@TRANCOUNT > @nTranCount
                     COMMIT TRAN

               IF @nErrNo <> 0
                  GOTO UPD_RDTMOBREC

               -- Prepare next screen var
               SET @cOutField01 = @cCartPickMethod
               SET @cOutField02 = @cCartID
               SET @cOutField03 = @cResult01
               SET @cOutField04 = @cResult02
               SET @cOutField05 = @cResult03
               SET @cOutField06 = @cResult04
               SET @cOutField07 = @cResult05
               SET @cOutField08 = ''
               SET @cOutField09 = ISNULL(TRY_CAST(@nCartonScanned + 1 AS NVARCHAR(5)), '')

               EXEC rdt.rdtSetFocusField @nMobile, 8
               GOTO UPD_RDTMOBREC
            END
            ELSE IF @nInputKey = 0 -- ESC
            BEGIN
               -- Prepare next screen var
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
               SET @cOutField11 = ''
               SET @cOutField12 = ''
               SET @cOutField13 = ''

               EXEC rdt.rdtSetFocusField @nMobile, 1

               -- Go to next screen
               SET @nAfterScn = @nScn_UnAssign
               SET @nAfterStep = 99
               GOTO UPD_RDTMOBREC
            END
         END
         ELSE IF @nCurrentScn = @nScn_UnAssign
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            SET @nErrNo = 0

            IF @nInputKey = 1
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField02

               -- Validate blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 260425
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need Option
                  GOTO UPD_RDTMOBREC
               END

               -- Validate option
               IF @cOption NOT IN ('1', '2')
               BEGIN
                  SET @nErrNo = 260426
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Option
                  GOTO UPD_RDTMOBREC
               END

               IF @cOption = '1'
               BEGIN
                  DELETE FROM @tTaskDetail

                  INSERT INTO @tTaskDetail (TaskDetailKey)
                  SELECT TaskDetailKey
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                     AND TaskType = 'ASTCPK'
                     AND Status = '3'
                     AND Groupkey = @cGroupKey
                     AND WaveKey = @cWaveKey
                     AND UserKey = @cUserName
                     AND DeviceID = @cCartID

                  SET @nTranCount = @@TRANCOUNT
                  BEGIN TRAN
                  SAVE TRAN rdt_1855ExtScn02_5927

                  IF EXISTS(SELECT 1 FROM @tTaskDetail)
                  BEGIN
                     SET @nLoopIndex = -1
                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1 
                           @cLockTaskKey = TaskDetailKey,
                           @nLoopIndex = RowRef
                        FROM @tTaskDetail
                        WHERE RowRef > @nLoopIndex
                        ORDER BY RowRef

                        IF @@ROWCOUNT = 0
                           BREAK

                        BEGIN TRY
                           UPDATE dbo.TaskDetail WITH(ROWLOCK)
                           SET
                              DropID = '',
                              StatusMsg = '',
                              DeviceID = '',
                              Status = '0',
                              UserKey = '',
                              EditWho = @cUserName,
                              EditDate = GETDATE()
                           WHERE Storerkey = @cStorerKey
                              AND TaskDetailKey = @cLockTaskKey
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 260427
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --   Update TaskDetail failed
                           GOTO COMMIT_UNASSIGN_CART_RollBackTran
                        END CATCH
                     END
                  END

                  DELETE FROM @tTaskDetail

                  INSERT INTO @tTaskDetail (TaskDetailKey)
                  SELECT TaskDetailKey
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                     AND TaskType = 'ASTCPK'
                     AND Status = '5'
                     AND Groupkey = @cGroupKey
                     AND WaveKey = @cWaveKey
                     AND UserKey = @cUserName
                     AND DeviceID = @cCartID

                  IF EXISTS(SELECT 1 FROM @tTaskDetail)
                  BEGIN
                     SET @nLoopIndex = -1
                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1 
                           @cLockTaskKey = TaskDetailKey,
                           @nLoopIndex = RowRef
                        FROM @tTaskDetail
                        WHERE RowRef > @nLoopIndex
                        ORDER BY RowRef

                        IF @@ROWCOUNT = 0
                           BREAK

                        BEGIN TRY
                           UPDATE dbo.TaskDetail WITH(ROWLOCK)
                           SET
                              Status = '9',
                              EditWho = @cUserName,
                              EditDate = GETDATE()
                           WHERE Storerkey = @cStorerKey
                              AND TaskDetailKey = @cLockTaskKey
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 260428
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update task failed
                           GOTO COMMIT_UNASSIGN_CART_RollBackTran
                        END CATCH
                     END
                  END

                  GOTO COMMIT_UNASSIGN_CART

                  COMMIT_UNASSIGN_CART_RollBackTran:
                        ROLLBACK TRAN rdt_1855ExtScn02_5927
                  COMMIT_UNASSIGN_CART:
                     WHILE @@TRANCOUNT > @nTranCount
                        COMMIT TRAN

                  SET @nAfterScn = @nScn_CartID
                  SET @nAfterStep = 99

                  SET @cOutField01 = ''
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''
                  GOTO UPD_RDTMOBREC
               END
               ELSE IF @cOption = '2'
               BEGIN
                  SELECT @nCartonScanned = COUNT( DISTINCT DropID)
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                     AND TaskType = 'ASTCPK'
                     AND [Status] = '3'
                     AND Groupkey = @cGroupKey
                     AND UserKey = @cUserName
                     AND DeviceID = @cCartID
                     AND DropID <> ''

                  SET @cOutField01 = @cCartPickMethod
                  SET @cOutField02 = @cCartID
                  SET @cOutField03 = @cResult01
                  SET @cOutField04 = @cResult02
                  SET @cOutField05 = @cResult03
                  SET @cOutField06 = @cResult04
                  SET @cOutField07 = @cResult05
                  SET @cOutField08 = ''
                  SET @cOutField09 = CAST(@nCartonScanned AS NVARCHAR(5))

                  SET @cFromLoc = ''
                  SET @cCartonID = ''
                  SET @cSKU = ''
                  SET @nQTY = 0

                  -- Go to next screen
                  SET @nAfterScn = @nScn_CartMatrix
                  SET @nAfterStep = 99

                  GOTO UPD_RDTMOBREC
               END-- OPTION 2
            END
            ELSE IF @nInputKey = 0
            BEGIN
               SELECT @nCartonScanned = COUNT( DISTINCT DropID)
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE Storerkey = @cStorerKey
                  AND TaskType = 'ASTCPK'
                  AND [Status] = '3'
                  AND Groupkey = @cGroupKey
                  AND UserKey = @cUserName
                  AND DeviceID = @cCartID
                  AND DropID <> ''

               SET @cOutField01 = @cCartPickMethod
               SET @cOutField02 = @cCartID
               SET @cOutField03 = @cResult01
               SET @cOutField04 = @cResult02
               SET @cOutField05 = @cResult03
               SET @cOutField06 = @cResult04
               SET @cOutField07 = @cResult05
               SET @cOutField08 = ''
               SET @cOutField09 = CAST(@nCartonScanned AS NVARCHAR(5))

               SET @cFromLoc = ''
               SET @cCartonID = ''
               SET @cSKU = ''
               SET @nQTY = 0

               -- Go to next screen
               SET @nAfterScn = @nScn_CartMatrix
               SET @nAfterStep = 99

               GOTO UPD_RDTMOBREC
            END
         END
      END

      IF @nAfterStep = 1
      BEGIN
         SET @cOutField15 = 'Method:1-Singles;2-Multi'
         SET @nAfterStep = 99
         SET @nAfterScn = @nScn_CartID
      END
      ELSE IF @nAfterStep = 2
      BEGIN
         DECLARE @cContinuePickFlag NVARCHAR(1) = 'N'
         IF @nCurrentStep = 10
         BEGIN
            IF @cWaveKey = ''
            BEGIN
               SELECT TOP 1 @cWaveKey = WaveKey
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE Storerkey = @cStorerKey
                  AND TaskType = 'ASTCPK'
                  AND Status = '3'
                  AND Groupkey = @cGroupKey
                  AND UserKey = @cUserName
                  AND DeviceID = @cCartID
                  AND DropID <> ''
            END
            SET @cContinuePickFlag= 'Y'
         END

         IF ISNULL(@cWaveKey, '') = ''
         BEGIN
            SET @nErrNo = 260430
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Wavekey is missing
            GOTO Quit
         END

         SELECT @nCartonScanned = COUNT( DISTINCT DropID)
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE Storerkey = @cStorerKey
            AND TaskType = 'ASTCPK'
            AND Status = '3'
            AND Groupkey = @cGroupKey
            AND UserKey = @cUserName
            AND DeviceID = @cCartID
            AND WaveKey = @cWaveKey
            AND DropID <> ''

         SET @cOutField09 = @nCartonScanned
         SET @cOutField15 = ''
            
         SET @nAfterStep = 99
         SET @nAfterScn = @nScn_CartMatrix

         IF @cContinuePickFlag= 'Y'
         BEGIN
            SET @cUDF01 = 'NO UPD RDTMOBREC'
            GOTO UPD_RDTMOBREC
         END
         ELSE
            SET @cUDF01 = ''
      END
      ELSE IF @nAfterStep = 4
      BEGIN
         SELECT @cTaskDetailKey = Value FROM @tExtScnData WHERE Variable = '@cTaskDetailKey'

         SELECT @nSuggQty = ISNULL( SUM(PD.Qty), 0)
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
         WHERE PD.StorerKey = @cStorerKey
            AND TD.TaskDetailKey = @cTaskDetailKey
            AND PD.Status < @cPickConfirmStatus

         SELECT @nPickedQty = ISNULL( SUM(PD.Qty), 0)
         FROM dbo.PICKDETAIL PD WITH (NOLOCK)
         INNER JOIN dbo.TaskDetail TD WITH(NOLOCK) ON PD.StorerKey = TD.StorerKey AND PD.TaskDetailKey = TD.TaskDetailKey
         WHERE PD.StorerKey = @cStorerKey
            AND TD.TaskDetailKey = @cTaskDetailKey
            AND PD.Status = @cPickConfirmStatus

         SET @cOutField08 = @nPickedQty
         SET @cOutField09 = @nSuggQty

         SET @cUDF02 = CAST(@nPickedQty AS NVARCHAR(5))
         SET @cUDF03 = CAST(@nSuggQty AS NVARCHAR(5))

         SELECT @cSuggToteId = DropID FROM dbo.TaskDetail WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND TaskDetailKey = @cTaskDetailKey AND ISNULL(DropID, '') <> ''

         SET @cOutField05 = 'TOTE:' + ISNULL(@cSuggToteId, '')
      END
      ELSE IF @nAfterStep = 7 -- ToLoc
      BEGIN
         DECLARE @cToLoc   NVARCHAR(10)

         SELECT TOP 1 @cToLoc = DI.DropLoc
         FROM TaskDetail TD1 WITH(NOLOCK)
         INNER JOIN TaskDetail TD2 WITH(NOLOCK) 
            ON TD1.StorerKey = TD2.StorerKey 
            AND TD1.WaveKey = TD2.WaveKey 
            AND TD1.GroupKey = TD2.Groupkey 
            AND TD1.TaskType = TD2.TaskType
         INNER JOIN dbo.DropID DI WITH(NOLOCK) ON TD2.DropID = DI.DropID
         WHERE TD1.Storerkey = @cStorerKey
            AND TD1.TaskType = 'ASTCPK'
            AND TD1.Status = '9'
            AND TD1.DropID IS NOT NULL
            AND TD1.WaveKey = @cWaveKey
            AND TD1.GroupKey = @cGroupKey
            AND TD2.Status = '5'
            AND TD2.DeviceID = @cCartID
            AND TD2.Qty > 0
            AND TD2.TaskDetailKey = @cTaskDetailKey

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount > 0
         BEGIN
            SET @cUDF04 = @cToLoc
         END
         ELSE
            SET @cUDF04 = ''
      END

   END -- 1855

   GOTO Quit

UPD_RDTMOBREC:
   UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nAfterStep,
      Scn    = @nAfterScn,

      V_CaseID   = @cCartonID,

      V_Integer1 = @nSuggQty,
      V_TaskDetailKey = @cTaskDetailKey,

      V_String2 = @cExtendedValidateSP,
      V_String8 = @cCartID,
      V_String9 = @cSuggFromLOC,
      V_String10 = @cSuggCartonID,
      V_String11 = @cSuggSKU,
      V_String12 = @cGroupKey,
      V_String24 = @cPickZone,
      V_String25 = @cMethod,
      V_String26 = @cResult01,
      V_String27 = @cResult02,
      V_String28 = @cResult03,
      V_String29 = @cResult04,
      V_String30 = @cResult05,
      V_String31 = @cSuggToteId,
      V_String41 = @cCartPickMethod,
      V_String42 = @cContinuePickOnAssignedCart,
      V_String43 = @cPickNoMixWave,

      C_String1 = @cWaveKey,

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

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1855ExtScn02 TO NSQL
GO


