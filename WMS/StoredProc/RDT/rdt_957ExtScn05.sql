SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_957ExtScn05                                     */
/* Copyright: Maersk WMS                                                */
/* Customer : South Africa                                              */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev   Author   Purposes                                   */
/* 2025-12-20 1.0   CYU027   FCR-9678                                   */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_957ExtScn05] (
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
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSuggSKU       NVARCHAR( 20)
   DECLARE @cDropIDMandatory NVARCHAR(1)
   DECLARE @cDropID        NVARCHAR(20)
   DECLARE @cPickSlipNo    NVARCHAR(10)

   DECLARE 
      @nCurrentStep           INT,
      @nCurrentScn            INT,
      @nNextStep              INT,
      @nStep_5                INT = 5, --Short Confirm Screen
      @nStep_3                INT = 3, --Keep old SKU Qty Step
      @nStep_3_Scn            INT = 6443, --but New SKU Qty Screen
      @nStep_4                INT = 4, --No more task Step
      @nStep_4_Scn            INT = 5293, --No more task Screen
      @cOption                NVARCHAR(1),
      @cSQL                   NVARCHAR(MAX),
      @cSQLParam              NVARCHAR(MAX),
      @cMsg01                 NVARCHAR(20) = '',
      @cMsg02                 NVARCHAR(20) = '',
      @cMsg03                 NVARCHAR(20) = '',
      @cMsg04                 NVARCHAR(20) = '',
      @cMsg05                 NVARCHAR(20) = '',
      @cMsg06                 NVARCHAR(20) = '',
      @cMsg07                 NVARCHAR(20) = '',
      @cMsg08                 NVARCHAR(20) = '',
      @cMsg09                 NVARCHAR(20) = '',
      @cMsg10                 NVARCHAR(20) = '',
      @cPickZone              NVARCHAR(10),
      @cSuggLOC               NVARCHAR(10),
      @cSuggID                NVARCHAR(18),
      @cBarcode               NVARCHAR(60),
      @cLottableCode          NVARCHAR(30),
      @cSKUDescr              NVARCHAR( 60),
      @cUserKey               NVARCHAR( 128),
      @cSKUValidated          NVARCHAR( 2),
      @nActQTY                INT,
      @nSuggQTY               INT,
      @cExtendedUpdateSP      NVARCHAR(20),
      @cExtendedScreenSP      NVARCHAR( 20),
      @nGetTaskSuccess        INT = 0,
      @nTotalQty              INT,
      @nTranCount             INT,
      @nInnerErrorNo          INT = 0

   SET @nNextStep = @nStep

   SELECT 
      @nStep = Step,
      @nCurrentStep = Step,
      @nCurrentScn = Scn,
      @cUserKey = UserName
   FROM rdt.RDTMOBREC WHERE Mobile = @nMobile  

   SELECT @cSuggSKU     = Value FROM @tExtScnData WHERE Variable = '@cSuggSKU'
   SELECT @cDropID     = Value FROM @tExtScnData WHERE Variable = '@cDropID'
   SELECT @cPickSlipNo     = Value FROM @tExtScnData WHERE Variable = '@cPickSlipNo'
   SELECT @cPickZone     = Value FROM @tExtScnData WHERE Variable = '@cPickZone'
   SELECT @cSuggLOC     = Value FROM @tExtScnData WHERE Variable = '@cSuggLOC'
   SELECT @cSuggID     = Value FROM @tExtScnData WHERE Variable = '@cSuggID'
   SELECT @cBarcode     = Value FROM @tExtScnData WHERE Variable = '@cBarcode'
   SELECT @cLottableCode     = Value FROM @tExtScnData WHERE Variable = '@cLottableCode'
   SELECT @cExtendedUpdateSP     = Value FROM @tExtScnData WHERE Variable = '@cExtendedUpdateSP'
   SELECT @nActQTY     = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nActQTY'
   SELECT @nSuggQTY     = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nSuggQTY'

   SET @nTranCount = @@TRANCOUNT

   IF @nAction = 0
   BEGIN
      IF @nFunc = 957
      BEGIN
         IF @nNextStep = @nStep_5  --Next Step is Short Confirm
         BEGIN
            SET @nAfterScn = 6469 --Jump to New Confirm Short Screen
            SET @nAfterStep = 99

            SET @cOutField01 = ''

            GOTO Quit
         END
      END
   END
   ELSE
   BEGIN
      IF @nFunc = 957
      BEGIN
         IF @nCurrentStep = 99
         BEGIN
            IF @nCurrentScn = 6469 -- New Confirm Short Screen
            BEGIN
               IF @nInputKey = 1
               BEGIN
                  -- Screen mapping
                  SET @cOption = @cInField01
                  
                  -- Validate blank
                  IF @cOption = ''
                  BEGIN
                     SET @nErrNo = 230602
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required
                     GOTO Quit
                  END

                  IF @cOption NOT IN ('0', '1', '9')
                  BEGIN
                     SET @nErrNo = 230603
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                     GOTO Quit
                  END

                  IF @cOption = '1' -- Yes
                  BEGIN
                     BEGIN TRAN  
                     SAVE TRAN rdt_957ExtScn05_6469

                     -- Confirm    
                     EXEC RDT.rdt_PickCase_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'SHORT'
                        ,@cPickSlipNo
                        ,@cPickZone
                        ,@cDropID
                        ,@cSuggLOC
                        ,@cSuggID 
                        ,@cBarcode
                        ,@cSuggSKU
                        ,@nActQTY
                        ,@nErrNo       OUTPUT
                        ,@cErrMsg      OUTPUT
                     IF @nErrNo <> 0
                        GOTO ROLLBACK_rdt_957ExtScn05_6469

                     -- Extended update
                     IF @cExtendedUpdateSP <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
                        BEGIN
                           SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                              ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
                              ' @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggID, @cSuggSKU, @nSuggQTY, @cOption, @cLottableCode, ' +
                              ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                              ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                              ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                              ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                           SET @cSQLParam =
                              ' @nMobile         INT                      ' +
                              ',@nFunc           INT                      ' +
                              ',@cLangCode       NVARCHAR( 3)             ' +
                              ',@nStep           INT                      ' +
                              ',@nInputKey       INT                      ' +
                              ',@cFacility       NVARCHAR( 5)             ' +
                              ',@cStorerKey      NVARCHAR( 15)            ' +
                              ',@cPickSlipNo     NVARCHAR( 10)            ' +
                              ',@cPickZone       NVARCHAR( 10)            ' +
                              ',@cDropID         NVARCHAR( 20)            ' +
                              ',@cSuggLOC        NVARCHAR( 10)            ' +
                              ',@cSuggID         NVARCHAR( 18)            ' +
                              ',@cSuggSKU        NVARCHAR( 20)            ' +
                              ',@nSuggQTY        INT                      ' +
                              ',@cOption         NVARCHAR( 1)             ' +
                              ',@cLottableCode   NVARCHAR( 30)            ' +
                              ',@cLottable01     NVARCHAR( 18)            ' +
                              ',@cLottable02     NVARCHAR( 18)            ' +
                              ',@cLottable03     NVARCHAR( 18)            ' +
                              ',@dLottable04     DATETIME                 ' +
                              ',@dLottable05     DATETIME                 ' +
                              ',@cLottable06     NVARCHAR( 30)            ' +
                              ',@cLottable07     NVARCHAR( 30)            ' +
                              ',@cLottable08     NVARCHAR( 30)            ' +
                              ',@cLottable09     NVARCHAR( 30)            ' +
                              ',@cLottable10     NVARCHAR( 30)            ' +
                              ',@cLottable11     NVARCHAR( 30)            ' +
                              ',@cLottable12     NVARCHAR( 30)            ' +
                              ',@dLottable13     DATETIME                 ' +
                              ',@dLottable14     DATETIME                 ' +
                              ',@dLottable15     DATETIME                 ' +
                              ',@nErrNo          INT           OUTPUT     ' +
                              ',@cErrMsg         NVARCHAR(250) OUTPUT     '

                              EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                                 @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey,
                                 @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggID, @cSuggSKU, @nSuggQTY, @cOption, @cLottableCode, 
                                 @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                                 @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                                 @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                                 @nErrNo OUTPUT, @cErrMsg OUTPUT

                              IF @nErrNo <> 0
                                 GOTO ROLLBACK_rdt_957ExtScn05_6469
                        END
                     END

                     SET @cExtendedScreenSP =  ISNULL(rdt.RDTGetConfig( @nFunc, '957ExtendedScreenSP', @cStorerKey), '')
                     SET @nAction = 1
                     IF @cExtendedScreenSP <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedScreenSP AND type = 'P')
                        BEGIN
                           EXECUTE [RDT].[rdt_957ExtScnEntry]
                              @cExtendedScreenSP,
                              @nMobile, @nFunc, @cLangCode, @nCurrentStep, @nInputKey, @cFacility, @cStorerKey,
                              @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggID, @cSuggSKU, @nSuggQTY, @cOption, @cLottableCode,
                              @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                              @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                              @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                              @cBarcode,@nAction,
                              @nAfterScn OUTPUT,  @nAfterStep OUTPUT,
                              @nErrNo OUTPUT, @cErrMsg OUTPUT

                              IF @nErrNo <> 0
                                 GOTO ROLLBACK_rdt_957ExtScn05_6469
                        END
                     END
                  END
                  ELSE IF @cOption = '0'  -- No
                  BEGIN
                     -- Prepare SKU QTY screen var
                     SET @cOutField01 = @cSuggLOC
                     SET @cOutField02 = ''--@cSuggSKU
                     SET @cOutField03 = ''--rdt.rdtFormatString( @cSKUDescr, 1, 20)
                     SET @cOutField04 = ''--rdt.rdtFormatString( @cSKUDescr, 21, 20)
                     SET @cOutField05 = '' -- SKU/UPC
                     SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(5))
                     SET @cOutField07 = CAST( @nTotalQty AS NVARCHAR(5))
                     SET @cOutField08 = @cSuggID 
                     SET @cOutField09 = ''

                     IF @cFieldAttr07 = 'O'
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                     ELSE
                        EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY

                     -- Go to new SKU QTY screen
                     SET @nAfterStep = @nStep_3
                     SET @nAfterScn = @nStep_3_Scn
                     GOTO Quit
                  END

                  IF @cOption = '9'
                  BEGIN

                     DECLARE @cOrderKey      NVARCHAR( 10)
                     DECLARE @cLoadKey       NVARCHAR( 10)
                     DECLARE @cZone          NVARCHAR( 18)
                     DECLARE @cWavekey               NVARCHAR(10)
                     DECLARE @cPickDetailKey NVARCHAR( 18)
                     DECLARE @cPickConfirmStatus NVARCHAR( 1)

                     -- Get storer config
                     SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
                     IF @cPickConfirmStatus = '0'
                        SET @cPickConfirmStatus = '5'



                     --                      EXEC RDT.rdt_PickCase_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'SHORT'
--                         ,@cPickSlipNo
--                         ,@cPickZone
--                         ,@cDropID
--                         ,@cSuggLOC
--                         ,@cSuggID
--                         ,@cBarcode
--                         ,@cSuggSKU
--                         ,@nActQTY
--                         ,@nErrNo       OUTPUT
--                         ,@cErrMsg      OUTPUT
--                      IF @nErrNo <> 0
--                         GOTO ROLLBACK_rdt_957ExtScn05_6469

                     DECLARE @cUCCNo NVARCHAR( 20)

                     SELECT TOP 1
                        @cPickdetailkey = PD.PickDetailKey,
                        @cWavekey = WD.wavekey,
                        @cUCCNo = PD.dropID
                     FROM dbo.PickDetail PD WITH (NOLOCK)
                        JOIN WAVEDETAIL WD on WD.OrderKey = PD.OrderKey
                        JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)
                     WHERE PD.PickSlipNo = @cPickSlipNo
                       AND PD.LOC = @cSuggLOC
                       AND PD.SKU = @cSuggSKU
                       AND PD.ID  = @cSuggID
                       AND PD.QTY > 0
                       AND PD.Status <> '4'
                       AND PD.Status < @cPickConfirmStatus
                     ORDER BY PD.OrderKey,PD.OrderLineNumber,PD.PICKDETAILKEY

                     -- Confirm PickDetail
                     UPDATE dbo.PickDetail WITH (ROWLOCK) SET
                         Status = '4',
                         EditDate = GETDATE(),
                         EditWho  = SUSER_SNAME(),
                         --DropID = @cDropID,
                         TrafficCop = NULL
                     WHERE PickDetailKey = @cPickDetailKey
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 100103
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UPD PKDtl Fail
                        GOTO ROLLBACK_rdt_957ExtScn05_6469
                     END

                     --If @cPickZone is blank, get the pickzone from loc table
                     IF @cPickZone = ''
                     BEGIN
                        SELECT @cPickZone = PickZone
                        FROM dbo.Loc WITH(NOLOCK)
                        WHERE Facility = @cFacility
                           AND Loc = @cSuggLOC
                     END


                     DECLARE @c_APP_DB_Name         NVARCHAR(20)=''
                        ,@c_DataStream          VARCHAR(10)=''
                        ,@n_ThreadPerAcct       INT=0
                        ,@n_ThreadPerStream     INT=0
                        ,@n_MilisecondDelay     INT=0
                        ,@c_IP                  NVARCHAR(20)=''
                        ,@c_PORT                NVARCHAR(5)=''
                        ,@c_IniFilePath         NVARCHAR(200)=''
                        ,@c_CmdType             NVARCHAR(10)=''
                        ,@c_TaskType            NVARCHAR(1)=''
                        ,@n_Priority            INT = 0
                        ,@cTransmitLogKey       NVARCHAR( 10) = ''



                     DECLARE   @cExecStatements           NVARCHAR(MAX)
                     DECLARE   @cDataStream               VARCHAR(10)
                     DECLARE   @cCmdType                  NVARCHAR(10)


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
                          , @n_Priority = ISNULL([Priority],0)
                          , @cDataStream = DataStream
                           ,@cExecStatements = StoredProcName
                           ,@cCmdType             = CmdType
                     FROM QCmd_TransmitlogConfig WITH (NOLOCK)
                     WHERE TableName = 'ShortPickHold'
                       AND [App_Name] = 'WMS'
                       AND StorerKey = @cStorerKey


                     SET @cExecStatements =
                    'EXEC ' + @c_APP_DB_Name + '.dbo.msp_ProcessShortPickReAlloc04 '
                       + '@c_Wavekey        = ''' + @cWavekey   + ''', '
                       + '@c_SKU            = ''' + @cSuggSKU   + ''', '
                       + '@c_UCCNo          = ''' + @cUCCNo    + ''', '
                       + '@c_Taskdetailkey  = '''' '



                     EXEC isp_QCmd_SubmitTaskToQCommander
                          @cTaskType = 'O' -- D=By Datastream, T=Transmitlog, O=Others
                        , @cStorerKey = @cStorerKey
                        , @cDataStream = @cDataStream
                        , @cCmdType = @cCmdType
                        , @cCommand = @cExecStatements
                        , @cTransmitlogKey = @cTransmitLogKey
                        , @nThreadPerAcct = @n_ThreadPerAcct
                        , @nThreadPerStream = @n_ThreadPerStream
                        , @nMilisecondDelay = @n_MilisecondDelay
                        , @nSeq = 1
                        , @cIP = @c_IP
                        , @cPORT = @c_PORT
                        , @cIniFilePath = @c_IniFilePath
                        , @cAPPDBName = @c_APP_DB_Name
                        , @bSuccess = 1
                        , @nErr = 0
                        , @cErrMsg = ''
                        , @nPriority = @n_Priority

                     IF @nErrNo <> 0
                        GOTO Quit

                  END

                  SET @cSKUValidated = '0'
                  SET @nActQTY = 0
                  -- Get the remaining pick task, go to SKU Qty screen
                  EXEC rdt.rdt_PickCase_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTUCC'
                     ,@cPickSlipNo
                     ,@cPickZone
                     ,@cSuggLOC         OUTPUT
                     ,@cSuggSKU         OUTPUT
                     ,@cSKUDescr        OUTPUT
                     ,@nSuggQTY         OUTPUT
                     ,@cSuggID          OUTPUT
                     ,@cBarcode     
                     ,@nTotalQty        OUTPUT
                     ,@nErrNo           OUTPUT
                     ,@cErrMsg          OUTPUT
                     
                  IF @nErrNo = 0
                  BEGIN
                     -- Prepare SKU QTY screen var
                     SET @cOutField01 = @cSuggLOC
                     SET @cOutField02 = @cSuggSKU
                     SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)
                     SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20)
                     SET @cOutField05 = '' -- SKU/UPC
                     SET @cOutField06 = CAST (@nSuggQTY AS NVARCHAR(5))
                     SET @cOutField07 = CAST (@nTotalQty AS NVARCHAR(5)) -- QTY
                     SET @cOutField08 = @cSuggID 
                     SET @cOutField09 = ''

                     EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU

                     -- Go to SKU QTY screen
                     SET @nAfterStep = @nStep_3
                     SET @nAfterScn = @nStep_3_Scn

                     SET @nGetTaskSuccess = 1
                     SET @cUDF01 = CAST(@nGetTaskSuccess AS NVARCHAR(5))
                     SET @cUDF02 = @cSuggLOC
                     SET @cUDF03 = @cSuggSKU
                     SET @cUDF04 = @cSKUDescr
                     SET @cUDF05 = CAST(@nSuggQTY AS NVARCHAR(5))
                     SET @cUDF06 = @cSuggID
                     SET @cUDF07 = CAST(@nTotalQty AS NVARCHAR(5))
                     SET @cUDF08 = @cSKUValidated
                     SET @cUDF09 = CAST(@nActQTY AS NVARCHAR(5))

                     GOTO Quit
                  END
                  ELSE
                  BEGIN -- Go to no more task in loc screen
                     SET @nAfterStep = @nStep_4
                     SET @nAfterScn = @nStep_4_Scn
                  END
               END
               ELSE IF @nInputKey = 0 --ESC
               BEGIN
                  -- Prepare SKU QTY screen var
                  SET @cOutField01 = @cSuggLOC
                  SET @cOutField02 = ''--@cSuggSKU
                  SET @cOutField03 = ''--rdt.rdtFormatString( @cSKUDescr, 1, 20)
                  SET @cOutField04 = ''--rdt.rdtFormatString( @cSKUDescr, 21, 20)
                  SET @cOutField05 = '' -- SKU/UPC
                  SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(5))
                  SET @cOutField07 = CAST( @nTotalQty AS NVARCHAR(5))
                  SET @cOutField08 = @cSuggID 
                  SET @cOutField09 = ''

                  IF @cFieldAttr07 = 'O'
                     EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                  ELSE
                     EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY

                  -- Go to SKU QTY screen
                  SET @nAfterStep = @nStep_3
                  SET @nAfterScn = @nStep_3_Scn
                  GOTO Quit
               END
            END
            GOTO Quit
         END
      END
   END

   GOTO Quit

ROLLBACK_rdt_957ExtScn05_6469:
   ROLLBACK TRAN rdt_957ExtScn05_6469 -- Only rollback change made here

   IF @nInnerErrorNo = -1
   BEGIN
      SET @cMsg01 = 'No alternate'
      SET @cMsg02 = 'location found'
      SET @cMsg03 = ''
      SET @cMsg04 = ''
      EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
                     @nErrNo = @nErrNo,
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
      SET @nErrNo = 0
      SET @cErrMsg = ''
   END

   INSERT dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, Step3, Step4, Step5,
      Col1, Col2, Col3, Col4, Col5)
   VALUES('rdt_957ExtScn05', GETDATE(), CAST(@nMobile AS NVARCHAR(10)), CAST(@nCurrentScn AS NVARCHAR(10)), @cOption, CAST(@nInnerErrorNo AS NVARCHAR(10)), @cPickZone,
      @cPickSlipNo, @cSuggLOC, @cSuggID, @cSuggSKU, CAST(@nActQTY AS NVARCHAR(10)))
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_957ExtScn05 TO NSQL
GO
