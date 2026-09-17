SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/******************************************************************************/  
/* Store procedure: rdt_1812ExtScn12                                          */  
/* Copyright      : MAERSK                                                    */  
/*                                                                            */  
/* Purpose:                                                                   */  
/*                                                                            */  
/* Date       Rev     Author   Purposes                                       */  
/* 2026-07-30 1.0.0   JackC    FCR-14961                                      */
/* 2026-09-04 1.0.1   JackC    FCR-14961 Skip toLoc screen if nothing picked  */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1812ExtScn12] (  
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
   @nAction          INT, --0 Jump Screen, 1 Prepare output fields .....
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
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, 
   @cUDF30 NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nDebugFlag  INT = 0

   DECLARE
      @cTaskdetailKey   NVARCHAR( 10), 
      @cDropID          NVARCHAR( 20),
      @cQTY             NVARCHAR( 20),
      @nQTY             INT, 
      @cToLOC           NVARCHAR( 10),
      @cSQL             NVARCHAR(MAX),
      @cSQLParam        NVARCHAR(MAX),
      @cExtendedInfo1   NVARCHAR(20),
      @cExtendedInfoSP  NVARCHAR(20),
      @cSuggSKU         NVARCHAR(20),
      @cFromID          NVARCHAR(18),
      @cOption          NVARCHAR(1),
      @tExtData         VariableTable,
      @cTaskDetailPUOM  NVARCHAR(20),
      @cReasonCode      NVARCHAR(10)

   -- Screen constant  
   DECLARE @nScn_ToLane    INT = 6520  
   DECLARE @nScn_ReasonCode INT = 6620  
   DECLARE @nScn_Message   INT = 4026  
   DECLARE @nStep_Message  INT = 7  

   -- Session var  
   DECLARE @cContinueProcess         NVARCHAR(10)
   DECLARE @cRemoveTaskFromUserQueue NVARCHAR(10)
   DECLARE @cTaskStatus              NVARCHAR(10)
   DECLARE @cToLane        NVARCHAR( 20)
   DECLARE @cSuggToLane    NVARCHAR( 20)
   DECLARE @cExtMbolKey    NVARCHAR( 15)
   DECLARE @cMbolKey       NVARCHAR( 10)
   DECLARE @cPickMethod    NVARCHAR( 10)
   DECLARE @cSuggFromLOC   NVARCHAR( 10)
   DECLARE @cSuggID        NVARCHAR( 18)
   DECLARE @cWaveKey       NVARCHAR( 10)
   DECLARE @cOrderKey      NVARCHAR( 10)
   DECLARE @cOrderLineNum  NVARCHAR( 10)
   DECLARE @nShipperCnt INT = 0
   DECLARE @nFromStep   INT
   DECLARE @nCartonQTY INT
   DECLARE @nFromScn    INT,
      @cBarcode            NVARCHAR( MAX)='',
      @cHoldID             NVARCHAR( 20),
      @cSKU                NVARCHAR(20),
      @cSKUValidated       NVARCHAR( 2),
      @cHoldLoc            NVARCHAR( 20),
      @cMoveQTYAlloc       NVARCHAR( 1),
      @cAreaKey            NVARCHAR(10),
      @cTaskDetailUOM      NVARCHAR( 5),
      @cTTMTaskType        NVARCHAR(10),
      @cUserName           NVARCHAR(18),
      @cSuggToLOC          NVARCHAR(10),
      @c_outstring         NVARCHAR(255),
      @b_success           INT = 1,
      @cSuggLOT            NVARCHAR(10),
      @nPQTY_RPL           INT,
      @nMQTY_RPL           INT,
      @cListKey            NVARCHAR(10),
      @cAutoGenDropID      NVARCHAR( 1),
      @cAutoGenDROPIDSP    NVARCHAR(20),
      @cExtendedValidateSP NVARCHAR(20),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cDefaultFromID      NVARCHAR( 1),
      @cSwapTaskSP         NVARCHAR(20),
      @cLottableCode       NVARCHAR( 20),
      @cPUOM               NVARCHAR( 1),
      @cDefaultToLOC       NVARCHAR( 10),
      @cDispStyleColorSize NVARCHAR( 1),
      @cSKUDesc            NVARCHAR(60),
      @cDisableQTYField    NVARCHAR(1),
      @nPUOM_Div           INT,
      @cPUOM_Desc          NVARCHAR( 5),
      @cMUOM_Desc          NVARCHAR( 5),
      @cPrinter_Paper      NVARCHAR( 10),
      @cPrinter            NVARCHAR( 10),
      @nQTY_RPL            INT,
      @nPQTY               INT,
      @nMQTY               INT,
      @nMorePage           INT,
      @cAutoID             NVARCHAR( 18)
   DECLARE @c_InventoryHoldKey NVARCHAR(10)
   DECLARE @nTranCount  INT
   DECLARE @cNewTaskDetailKey NVARCHAR( 10)
   DECLARE @bSuccess INT
   DECLARE @nTransit INT

   --ExtScn var
   DECLARE
      @nMOBRECStep      INT,
      @nMOBRECScn       INT,
      @nRowCount        INT

   --ExtScn business var
   DECLARE
      @cOrderGroup         NVARCHAR( 20),
      @cNewDropID          NVARCHAR( 20),
      @cNewDropIDLabel     NVARCHAR( 20),
      @tNewDropIDLabel     VariableTable

   DECLARE @tOptions TABLE
   (
      count     INT IDENTITY(1,1),
      LOC       NVARCHAR(10),
      ID        NVARCHAR(18),
      SKU       NVARCHAR(20),
      QTY       INT
   )
   DECLARE @tInventory TABLE
   (
      count     INT IDENTITY(1,1),
      LOC       NVARCHAR(10),
      ID        NVARCHAR(18),
      SKU       NVARCHAR(20),
      QTY       INT
   )

   -- Get session info  
   SELECT 
      @nMOBRECStep            = [Step]
      ,@nMOBRECScn            = [Scn]
      ,@cPrinter              = Printer
      ,@cPrinter_Paper        = Printer_Paper
      ,@nFromScn              = [V_FromScn]
      ,@nFromStep             = [V_FromStep]
      ,@cSuggSKU              = V_SKU
      ,@cPUOM                 = V_UOM
      ,@cSuggLOT              = V_LOT
      ,@nQTY_RPL              = V_TaskQTY
      ,@nQTY                  = V_QTY
      ,@cTaskDetailKey        = V_TaskDetailKey
      ,@cSuggFromLOC          = V_LOC
      ,@cSuggID               = V_ID
      ,@nPQTY                 = V_PQTY
      ,@nMQTY                 = V_MQTY
      ,@cAreaKey              = V_String1
      ,@cDropID               = V_String3
      ,@cPickMethod           = V_String4
      ,@cSuggToloc            = V_String5
      ,@cListKey              = V_String7
      ,@cDisableQTYField      = V_String8
      ,@cSwapTaskSP           = V_String9
      ,@cLottableCode         = V_String13
      ,@cTaskDetailUOM        = V_String14
      ,@cTaskDetailPUOM       = V_String15
      ,@cDispStyleColorSize   = V_String17
      ,@cExtendedUpdateSP     = V_String22
      ,@cDefaultToLOC         = V_String23
      ,@cMoveQTYAlloc         = V_String24
      ,@cSKUValidated         = V_String25
      ,@cDefaultFromID        = V_String26
      ,@cExtendedInfoSP       = V_String27
      ,@cExtendedValidateSP   = V_String31
      ,@cTTMTaskType          = V_String34
      ,@cAutoGenDROPIDSP      = V_String43
      ,@cToLOC                = V_String44
      ,@cUserName             = UserName
      ,@cOrderGroup           = C_String1
   FROM rdt.rdtMobRec WITH (NOLOCK)  
   WHERE Mobile = @nMobile 
   
   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812ExtScn12', @nMobrecStep AS MobrecStep, @nMobrecScn AS MobrecScn, @nScn AS Scn, @nStep AS Step, 
         @cTaskDetailKey AS TaskDetailKey

   SET @cAutoGenDropID = rdt.RDTGetConfig( @nFunc, 'AutoGenDropID', @cStorerKey)
   SET @cNewDropIDLabel = rdt.RDTGetConfig( @nFunc, 'DropIDLabel', @cStorerKey)
   IF @cNewDropIDLabel = '0'
      SET @cNewDropIDLabel = ''

   SELECT TOP 1 @cOrderKey = OrderKey, @cOrderLineNum = OrderLineNumber FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey AND Storerkey = @cStorerKey

   IF @nFunc = 1812 -- TM Case Pick  
   BEGIN  
      IF (@nMobrecSCN <> 4020 AND @nScn = 4020) OR @nAfterScn = 4020 -- if next screen is DROPID SCREEN
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'Executing rdt_1812ExtScn12 - jump to DROPID SCREEN'

         SET @cOutField01 = ''
         SET @nRowCount = 0

         SELECT 
            @cPickMethod = TD.PickMethod,
            @cOrderGroup = OrderGroup
         FROM dbo.PickDetail PD WITH (NOLOCK) 
         JOIN dbo.TASKDETAIL TD WITH (NOLOCK) ON PD.TaskDetailKey = TD.TaskDetailKey
         JOIN dbo.ORDERS O WITH (NOLOCK) ON PD.OrderKey = O.OrderKey 
         WHERE PD.TaskDetailKey = @cTaskdetailKey 
            AND PD.StorerKey = @cStorerKey

         SET @nRowCount = @@ROWCOUNT

         IF @nRowCount = 0
         BEGIN
            SET @nErrNo = 276001
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickDetailNotFound
            GOTO Quit
         END

         IF @cAutoGenDropID = '1' AND @cPickMethod = 'PP'
         BEGIN
            SET @cNewDropID = ''
            BEGIN TRY
               EXECUTE dbo.nspg_GetKey_AlphaSeq    
                  'PalletID_AD',    
                  9,    
                  @cNewDropID    OUTPUT,
                  @bSuccess      OUTPUT,    
                  @nErrNo        OUTPUT,    
                  @cErrMsg       OUTPUT 

               IF @bSuccess <> 1    
               BEGIN    
                  SET @nErrNo = 276002    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenDropIDFail  
                  GOTO Quit    
               END
            END TRY
            BEGIN CATCH
               SET @nErrNo = 276003   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenDropIDFail  
               GOTO Quit    
            END CATCH

            IF @cOrderGroup = 'STANDARD' AND ISNULL(@cNewDropID, '') <> ''
            BEGIN
               SET @cNewDropID = 'D' + @cNewDropID
               -- Common params
               INSERT INTO @tNewDropIDLabel (Variable, Value) VALUES
               ( '@cStorerKey', @cStorerKey),
               ( '@cDropID', @cNewDropID)

               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPrinter, @cPrinter_Paper,
                  @cNewDropIDLabel, -- Report type
                  @tNewDropIDLabel, -- Report params
                  'rdt_1812ExtScn12',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT            
               IF @nErrNo <> 0
                  GOTO Quit
            END -- print label

            IF @cNewDropID <> ''
            BEGIN
               SET @cOutField01 = @cNewDropID -- disable dropID field
               --SET @cFieldAttr01 = 'O' --Frontend doesn't support.
            END
         END

         GOTO QUIT
      END

      IF @nStep = 3 AND @nScn = 4022 --redirct to st99, new fromID logic
      BEGIN
         IF @nDebugFlag = 1
            SELECT '1812ExtScn12 - Step3, Scn4022, redirect to Step99'

         SET @nAfterStep = 99
         SET @nAfterScn = 4022
         GOTO QUIT
      END

      IF @nMobRecStep = 9 AND @nMobRecScn = 6620 --From Reason Screen
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT '1812ExtScn12 - From Reason Screen, ENTER'

            IF @cPickMethod = 'FP' -- Pallet is close. Next task / Exit
            BEGIN
               SET @nAfterScn  = 4026
               SET @nAfterStep = 7
            END

            IF @cPickMethod = 'PP' -- Cont next replen task / Close pallet
            BEGIN
               SET @cOutField01 = '' -- Option
               SET @nAfterScn  = 4024 
               SET @nAfterStep = 5
            END
         END

         IF @nInputKey = 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT '1812ExtScn12 - From Reason Screen, ESC'

            IF @nFromScn = 4022 AND @nFromStep = 99
            BEGIN
               --back to new FromID screen
               SET @nAfterScn = 4022
               SET @nAfterStep = 99
               SET @cInField05 = '' -- clear FromID field
            END
         END
         GOTO Quit
      END

      IF @nMobRecStep = 5 AND @nMobRecScn = 4024 -- Close Pallet screen 
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT '1812ExtScn12 - Close Pallet Screen, ENTER'

            IF @cInField01 = '9' -- Close Pallet
            BEGIN
               --V1.0.1
                IF NOT EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE ListKey = @cListKey AND Status = '5')
                AND EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskdetailKey AND Status = '0')
               BEGIN
                  SET @nAfterStep = 7
                  SET @nAfterScn = 4026
                  SET @cOutField01 = ''
                  GOTO Quit
               END
               --V1.0.1
            END
         END
         GOTO Quit
      END

      IF @nStep = 99
      BEGIN
         IF @nScn = 4022 --New FromID logic
         BEGIN
            IF @nMobRecStep = 9 AND @nMobRecScn = 6620 AND @nInputkey = 0 -- ESC from Reason code screen
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '1812ExtScn12 - Step99, Scn4022, ESC from Reason code screen, skip new logics'

               GOTO Quit
            END

            SET @cUDF01 = 'NO UPD RDTMOBREC'
            IF @nInputKey = 1 -- ENTER
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '1812ExtScn12 - Step99, Scn4022, ENTER'
               -- Screen mapping
               SET @cFromID  = @cInField05

               IF @cFromID = '99'
               BEGIN
                  SET @nAfterStep = 9
                  SET @nAfterScn = 6620
                  SET @nFromStep = 99
                  SET @nFromScn = 4022
                  SET @cOutField01 = ''

                  GOTO SCN_4022_Quit
               END

               -- Check FromID match
               IF @cFromID <> @cSuggID
               BEGIN
                  IF @cSwapTaskSP = ''
                  BEGIN
                     SET @nErrNo = 276005
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID not match
                     GOTO SCN_4022_Fail
                  END

                  -- Swap ID
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSwapTaskSP AND type = 'P')
                  BEGIN
                     SET @cNewTaskDetailKey = ''

                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cSwapTaskSP) +
                        ' @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cFromID, @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile            INT,           ' +
                        '@nFunc              INT,           ' +
                        '@cLangCode          NVARCHAR( 3),  ' +
                        '@cTaskdetailKey     NVARCHAR( 10), ' +
                        '@cFromID            NVARCHAR( 18), ' +
                        '@cNewTaskDetailKey  NVARCHAR( 10)  OUTPUT, ' +
                        '@nErrNo             INT            OUTPUT, ' +
                        '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cFromID, @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO SCN_4022_Fail

                     -- New task
                     IF @cNewTaskDetailKey <> ''
                        SET @cTaskDetailKey = @cNewTaskDetailKey

                     -- Reload task
                     SELECT
                        @cTTMTaskType = TaskType,
                        @cStorerKey   = Storerkey,
                        @cSuggID      = FromID,
                        @cSuggLOT     = LOT,
                        @cSuggFromLOC = FromLOC,
                        @cSuggToLOC   = ToLOC,
                        @cSuggSKU     = SKU,
                        @nQTY_RPL     = QTY,
                        @cPickMethod  = PickMethod,
                        @nTransit     = TransitCount,
                        @cDropID      = CASE WHEN ISNULL(DROPID,'')='' THEN @cDropID ELSE DROPID END , --(yeekung02)
                        @cListKey     = ListKey,
                        @cTaskDetailUOM = UOM
                     FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE TaskDetailKey = @cTaskDetailKey

                     IF @cTaskDetailPUOM = '1'
                     BEGIN
                        -- Task Detail UoM as preferred UOM
                        SET @cPUOM = @cTaskDetailUOM
                     END
                     ELSE
                     BEGIN
                        -- Get preferred UOM
                        SELECT @cPUOM = DefaultUOM FROM rdt.rdtUser WITH (NOLOCK) WHERE UserName = @cUserName
                     END
                  END
               END

               -- Extended validate
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cDropID         NVARCHAR( 20), ' +
                        '@nQTY            INT,           ' +
                        '@cToLOC          NVARCHAR( 10), ' +
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO SCN_4022_Fail
                  END
               END

               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep '
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@nInputKey       INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cDropID         NVARCHAR( 20), ' +
                        '@nQTY            INT,           ' +
                        '@cToLOC          NVARCHAR( 10), ' +
                        '@nErrNo          INT OUTPUT,    ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT            '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

                     IF @nErrNo <> 0
                        GOTO SCN_4022_Fail
                  END
               END

               -- Full pallet
               IF @cPickMethod = 'FP'
               BEGIN
                  -- Prepare next screen var
                  SET @cToLOC = ''
                  SET @cOutField01 = @cSuggFromLOC
                  SET @cOutField02 = @cSuggToLOC
                  SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC ELSE '' END

                  -- Go to ToLOC screen
                  SET @nFromScn = 4022
                  SET @nFromStep = 99
                  SET @nAfterScn = 4025
                  SET @nAfterStep = 6
               END

               -- Partial pallet
               IF @cPickMethod = 'PP'
               BEGIN
                  -- Get SKU info
                  SELECT
                     @cSKUDesc = 
                        CASE WHEN @cDispStyleColorSize = '0'
                           THEN ISNULL( S.Descr, '')
                           ELSE CAST( S.Style AS NCHAR(20)) +
                                 CAST( S.Color AS NCHAR(10)) +
                                 CAST( S.Size  AS NCHAR(10))
                        END,
                     @cLottableCode = S.LottableCode, 
                     @cMUOM_Desc = Pack.PackUOM3,
                     @cPUOM_Desc =
                        CASE @cPUOM
                           WHEN '2' THEN Pack.PackUOM1 -- Case
                           WHEN '3' THEN Pack.PackUOM2 -- Inner pack
                           WHEN '6' THEN Pack.PackUOM3 -- Master unit
                           WHEN '1' THEN Pack.PackUOM4 -- Pallet
                           WHEN '4' THEN Pack.PackUOM8 -- Other unit 1
                           WHEN '5' THEN Pack.PackUOM9 -- Other unit 2
                        END,
                     @nPUOM_Div = CAST(
                        CASE @cPUOM
                           WHEN '2' THEN Pack.CaseCNT
                           WHEN '3' THEN Pack.InnerPack
                           WHEN '6' THEN Pack.QTY
                           WHEN '1' THEN Pack.Pallet
                           WHEN '4' THEN Pack.OtherUnit1
                           WHEN '5' THEN Pack.OtherUnit2
                        END AS INT)
                  FROM dbo.SKU S WITH (NOLOCK)
                     INNER JOIN dbo.Pack Pack (nolock) ON (S.PackKey = Pack.PackKey)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSuggSKU

                  SELECT 
                     @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,
                     @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',
                     @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL

                  -- Get lottable
                  SELECT
                     @cLottable01 = LA.Lottable01,
                     @cLottable02 = LA.Lottable02,
                     @cLottable03 = LA.Lottable03,
                     @dLottable04 = LA.Lottable04,
                     @dLottable05 = LA.Lottable05,
                     @cLottable06 = LA.Lottable06,
                     @cLottable07 = LA.Lottable07,
                     @cLottable08 = LA.Lottable08,
                     @cLottable09 = LA.Lottable09,
                     @cLottable10 = LA.Lottable10,
                     @cLottable11 = LA.Lottable11,
                     @cLottable12 = LA.Lottable12,
                     @dLottable13 = LA.Lottable13,
                     @dLottable14 = LA.Lottable14,
                     @dLottable15 = LA.Lottable15
                  FROM dbo.LOTAttribute LA WITH (NOLOCK)
                  WHERE LOT = @cSuggLOT

                  -- Dynamic lottable
                  EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 4,
                     @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,
                     @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,
                     @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,
                     @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,
                     @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,
                     @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,
                     @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,
                     @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,
                     @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,
                     @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,
                     @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
                     @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
                     @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
                     @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
                     @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
                     @nMorePage   OUTPUT,
                     @nErrNo      OUTPUT,
                     @cErrMsg     OUTPUT,
                     '',      -- SourceKey
                     @nFunc   -- SourceType

                  -- Restore scanned carton QTY
                  SELECT @nCartonQTY = ISNULL( SUM( QTY), 0)
                  FROM rdt.rdtFCPLog WITH (NOLOCK)
                  WHERE TaskDetailKey = @cTaskDetailKey

                  IF @nCartonQTY = 0
                     SET @cSKUValidated = '0'
                  ELSE
                     SET @cSKUValidated = '1'

                  -- Disable QTY field
                  SET @cFieldAttr14 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- PQTY
                  SET @cFieldAttr15 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- MQTY

                  -- Convert to prefer UOM QTY
                  IF @cPUOM = '6' OR -- When preferred UOM = master unit
                     @nPUOM_Div = 0 -- UOM not setup
                  BEGIN
                     SET @cPUOM_Desc = ''
                     SET @nPQTY_RPL = 0
                     SET @nPQTY = 0
                     SET @nMQTY = @nCartonQTY
                     SET @nMQTY_RPL = @nQTY_RPL
                     SET @cFieldAttr14 = 'O' -- @nPQTY_PWY
                  END
                  ELSE
                  BEGIN
                     SET @nPQTY = 0
                     SET @nMQTY = @nCartonQTY

                     SET @nPQTY = @nCartonQTY / @nPUOM_Div -- Calc QTY in preferred UOM
                     SET @nMQTY = @nCartonQTY % @nPUOM_Div -- Calc the remaining in master unit

                     SET @nPQTY_RPL = @nQTY_RPL / @nPUOM_Div -- Calc QTY in preferred UOM
                     SET @nMQTY_RPL = @nQTY_RPL % @nPUOM_Div -- Calc the remaining in master unit
                  END

                  -- Prepare next screen variable
                  SET @cOutField01 = @cSuggSKU
                  SET @cOutField02 = SUBSTRING( @cSKUDesc, 1, 20)
                  SET @cOutField03 = SUBSTRING( @cSKUDesc, 21, 20)
                  SET @cBarcode    = '' -- SKU
                  SET @cOutField09 = ''
                  SET @cOutField10 = ''
                  SET @cOutField11 = '1:' + CAST( @nPUOM_Div AS NCHAR( 6)) + ' ' + @cPUOM_Desc + ' ' + @cMUOM_Desc
                  SET @cOutField12 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY_RPL AS NVARCHAR( 6)) END
                  SET @cOutField13 = CAST( @nMQTY_RPL AS NVARCHAR( 6))
                  SET @cOutField14 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 6)) END -- PQTY
                  SET @cOutField15 = CAST( @nMQTY AS NVARCHAR( 6)) -- MQTY
                  EXEC rdt.rdtSetFocusField @nMobile, 'V_Barcode' -- SKU

                  SET @nFromScn = 4022
                  SET @nFromStep = 99
                  SET @nAfterScn = 4023
                  SET @nAfterStep = 4
               END

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cExtendedInfo1 = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +
                        '@nErrNo          INT           OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, 3, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep

                     SET @cOutField10 = @cExtendedInfo1
                  END
               END
            END

            IF @nInputKey = 0
            BEGIN
               IF @nDebugFlag = 1
                  SELECT '1812ExtScn12 - Step99, Scn4022, ESC'
               -- Prepare prev screen var
               SET @cOutField01 = @cPickMethod
               SET @cOutField02 = @cDropID
               SET @cOutField03 = @cSuggFromLOC
               SET @cOutField04 = '' -- FromLOC
               SET @cOutField10 = '' -- ExtendedInfo

               SET @nAfterScn = 4021
               SET @nAfterStep = 2

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cExtendedInfo1 = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
                     SET @cSQLParam =
                        '@nMobile         INT,           ' +
                        '@nFunc           INT,           ' +
                        '@cLangCode       NVARCHAR( 3),  ' +
                        '@nStep           INT,           ' +
                        '@cTaskdetailKey  NVARCHAR( 10), ' +
                        '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +
                        '@nErrNo          INT           OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
                        '@nAfterStep      INT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, 3, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

                     SET @cOutField10 = @cExtendedInfo1
                  END
               END
            END
            
            SCN_4022_Quit:
               GOTO Quit

            SCN_4022_Fail:
               SET @cOutField05 = ''
               SET @cFromID = ''
               GOTO Quit
         END--New FromID logic
      END
      
   END --1812

   GOTO Quit

Quit:
   IF @cUDF01 = 'NO UPD RDTMOBREC'
   BEGIN
      BEGIN TRY
         UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
            EditDate     = GETDATE(),
            ErrMsg       = @cErrMsg,
            Func         = @nFunc,
            Step         = @nAfterStep,
            Scn          = @nAfterScn,

            StorerKey    = @cStorerKey,
            Facility     = @cFacility,
            Printer      = @cPrinter,

            V_TaskDetailKey = @cTaskDetailKey,
            V_SKU        = @cSuggSKU,
            V_SKUDescr   = @cSKUDesc,
            V_LOT        = @cSuggLOT,
            V_LOC        = @cSuggFromLOC,
            V_ID         = @cSuggID,
            V_UOM        = @cPUOM,
            V_Lottable01 = @cLottable01,
            V_Lottable02 = @cLottable02,
            V_Lottable03 = @cLottable03,
            V_Lottable04 = @dLottable04,
            V_Lottable05 = @dLottable05,
            V_Lottable06 = @cLottable06,
            V_Lottable07 = @cLottable07,
            V_Lottable08 = @cLottable08,
            V_Lottable09 = @cLottable09,
            V_Lottable10 = @cLottable10,
            V_Lottable11 = @cLottable11,
            V_Lottable12 = @cLottable12,
            V_Lottable13 = @dLottable13,
            V_Lottable14 = @dLottable14,
            V_Lottable15 = @dLottable15,
            V_PQTY       = @nPQTY,
            V_MQTY       = @nMQTY,
            V_TaskQTY    = @nQTY_RPL,
            V_PTaskQTY   = @nPQTY_RPL,
            V_MTaskQTY   = @nMQTY_RPL,
            V_PUOM_Div   = @nPUOM_Div,
            V_FromScn    = @nFromScn,
            V_FromStep   = @nFromStep,
            V_Barcode    = @cBarcode,

            V_String3    = @cDropID,
            V_String4    = @cPickMethod,
            V_String5    = @cSuggToloc,
            V_String7    = @cListKey,
            V_String10   = @cMUOM_Desc,
            V_String11   = @cPUOM_Desc,
            V_String13   = @cLottableCode,
            V_String14   = @cTaskDetailUOM,
            V_String25   = @cSKUValidated,
            V_String26   = @cDefaultFromID,
            V_String34   = @cTTMTaskType,

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
      END TRY
      BEGIN CATCH
         SET @nErrNo = 276004
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdateMobrecFail
         RETURN
      END CATCH   

   END

   IF @nDebugFlag = 1
      SELECT 'Exiting rdt_1812ExtScn12', @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nAfterScn AS AfterScn, @nAfterStep AS AfterStep
END    
GO
  
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1812ExtScn12 TO NSQL 
GO  
