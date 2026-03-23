
/************************************************************************/  
/* Store procedure: rdt_830ExtScn09                                     */
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Date        Rev   Author     Purposes                                */
/* 2026-03-11  1.0.0 Dennis     FCR-9849 Created                        */
/************************************************************************/  
  
CREATE OR ALTER PROC  [RDT].[rdt_830ExtScn09] (
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
   @nAction          INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
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

   DECLARE @nDebugFlag      INT = 0

   --Standard ExtScn variables
   DECLARE
      @nMobrecStep   INT,
      @nMobrecScn    INT,
      @nFromScn      INT,
      @nFromStep     INT,
      @nTempScn      INT,
      @nTempStep     INT
   --Standard ExtScn variables end

   DECLARE @cWhere         NVARCHAR( MAX)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @cLot           NVARCHAR(10)
   DECLARE @cVerifyID         NVARCHAR( 1)
   DECLARE @cErrMsg1    NVARCHAR(125)
   DECLARE @cErrMsg2    NVARCHAR(125)
   DECLARE @cErrMsg3    NVARCHAR(125)
   DECLARE 
      @cSuggSKU               NVARCHAR( 20),
      @cSuggLOC               NVARCHAR( 10),
      @cSKU                   NVARCHAR( 20),
      @cLOC                   NVARCHAR( 10),
      @cToLoc                 NVARCHAR( 10),    
      @cID                    NVARCHAR( 20),
      @cOption                NVARCHAR( 1),
      @cPickSlipNo            NVARCHAR( 10),
      @cPickZone              NVARCHAR( 10),
      @cPutawayZone           NVARCHAR( 10),
      @cDropID                NVARCHAR( 20),
      @cSuggID                NVARCHAR( 20),
      @cMoveQTYAlloc          NVARCHAR( 1),
      @cMoveQTYPick           NVARCHAR( 1),
      @cType                  NVARCHAR( 10),
      @nQTY                   INT,
      @nTaskQTY               INT,
      @cLottableCode          NVARCHAR( 20),
      @cPUOM                  NVARCHAR( 10),
      @cSKUDescr              NVARCHAR( 60),
      @cMUOM_Desc             NVARCHAR( 5),
      @cPUOM_Desc             NVARCHAR( 5),
      @cPPK                   NVARCHAR( 5),
      @cUserDefine01          NVARCHAR( 30) = '',
      @nPUOM_Div              INT,
      @nPQTY                  INT,
      @nMQTY                  INT,
      @nRowcount              INT,
      @b_Success              INT,

      @nTranCount             INT,

      --Extended SP
      @cExtendedValidateSP    NVARCHAR( 20),
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cExtendedInfo          NVARCHAR( 20),
      @cCCTaskType            NVARCHAR( 20),
      @cHoldLocOrID           NVARCHAR( 20),
      @cHoldOrNot             NVARCHAR( 20),
      @cShortLoc              NVARCHAR( 20),
      @cReasonCode            NVARCHAR( 20),
      --Message Queue
      @cMsg01                 NVARCHAR(20) = '',
      @cMsg02                 NVARCHAR(20) = '',
      @cMsg03                 NVARCHAR(20) = '',
      @cMsg04                 NVARCHAR(20) = '',
      @cMsg05                 NVARCHAR(20) = '',
      @cMsg06                 NVARCHAR(20) = '',
      @cMsg07                 NVARCHAR(20) = '',
      @cMsg08                 NVARCHAR(20) = '',
      @cMsg09                 NVARCHAR(20) = '',
      @cMsg10                 NVARCHAR(20) = ''
   DECLARE @curPD             CURSOR
   DECLARE @cPackKey          NVARCHAR( 10)
   DECLARE @cZone          NVARCHAR( 18)
   DECLARE @cMoveRefKey       NVARCHAR( 10),
   @cOrderKey                 NVARCHAR( 10),
   @cWavekey                  NVARCHAR( 10),
   @cLoadkey                  NVARCHAR( 10)
   DECLARE @cPickDetailKey    NVARCHAR(10),
   @nQTY_PD                   INT,
   @nQTY_Move                 INT
   DECLARE 
      @cAPP_DB_Name              NVARCHAR(20),
      @cDataStream               VARCHAR(10),
      @nThreadPerAcct            INT,
      @nThreadPerStream          INT,
      @nMilisecondDelay          INT,
      @nQueueID                  INT,
      @cIP                       NVARCHAR(20),
      @cPORT                     NVARCHAR(5),
      @cIniFilePath              NVARCHAR(200),
      @cCmdType                  NVARCHAR(10),
      @cTaskType                 NVARCHAR(1),
      @c_TransmitlogKey          NVARCHAR(10),
      @cExecStatements           NVARCHAR(MAX),
      @cExecArguments            NVARCHAR(MAX)

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_830ExtScn09'

   SELECT 
      @cPickZone           = V_Zone,
      @cPickSlipNo         = V_PickSlipNo,
      @cLOC                = V_LOC,
      @cID                 = V_ID,
      @cSKU                = V_SKU,
      @cDropID             = V_CaseID,
      @nTaskQTY            = V_Qty,
      @cPUOM               = V_UOM,
      @cSKUDescr           = V_SKUDescr,
      @nPUOM_Div           = V_Integer1,
      @nPQTY               = V_Integer2,
      @nMQTY               = V_Integer3,
      @nQTY                = V_Integer4,
      @cSuggLoc            = V_String1,
      @cLottableCode       = V_String3,
      @cPPK                = V_String4,
      @cMUOM_Desc          = V_String10,
      @cPUOM_Desc          = V_String11,
      @cPickZone           = V_String35,
      @cUserDefine01       = V_String42,
      @cLottable01         = V_Lottable01,
      @cLottable02         = V_Lottable02,
      @cLottable03         = V_Lottable03,
      @dLottable04         = V_Lottable04,
      @dLottable05         = V_Lottable05,
      @cLottable06         = V_Lottable06,
      @cLottable07         = V_Lottable07,
      @cLottable08         = V_Lottable08,
      @cLottable09         = V_Lottable09,
      @cLottable10         = V_Lottable10,
      @cLottable11         = V_Lottable11,
      @cLottable12         = V_Lottable12,
      @dLottable13         = V_Lottable13,
      @dLottable14         = V_Lottable14,
      @dLottable15         = V_Lottable15
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile
   SET @cVerifyID = rdt.RDTGetConfig( @nFunc, 'VerifyID', @cStorerKey)

   IF @nFunc = 830
   BEGIN
      IF @nScn = 4696 --Short pick screen
      BEGIN
         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Step99, Scn 4696'
         END

         SET @nAfterScn = 6846
         SET @nAfterStep = 99
         SET @cOutfield01 = ''
         GOTO QUIT
      END
      ELSE IF @nStep = 99
      BEGIN
         IF @nScn = 6846 --Short pick screen
         /********************************************************************************
         Scn = 6846. Confirm Option?
            1 = Short
            2 = Bal pick later
            9 = Alternate PICK LOC
            Option (field01)
         ********************************************************************************/
         BEGIN
            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Step99, Scn 6846'
            END

            IF @nInputKey = 1 -- ENTER
            BEGIN

               --screnn mapping
               SET @cOption = @cInField01

               IF @nDebugFlag = 1
                  SELECT @cInField01 AS InField01, @cOption AS cOption, @cSuggSKU AS SuggSKU, @cSuggLOC AS SuggLOC, @cSuggID AS SuggID

               -- Validate blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 240401
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required
                  GOTO Scn_6846_Fail
               END

               -- Validate option
               IF @cOption <> '1' AND
                  @cOption <> '2' AND
                  @cOption <> '9'
               BEGIN
                  SET @nErrNo = 240402
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO Scn_6846_Fail
               END

               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cPickZone, @cSuggLOC, @cLOC, @cDropID, @cSKU, ' +
                        ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                        ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                        ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                        ' @nTaskQTY, @nQTY, @cToLOC, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        '@nMobile       INT,           ' +
                        '@nFunc         INT,           ' +
                        '@cLangCode     NVARCHAR( 3),  ' +
                        '@nStep         INT,           ' +
                        '@nInputKey     INT,           ' +
                        '@cFacility     NVARCHAR( 5),  ' +
                        '@cStorerKey    NVARCHAR( 15), ' +
                        '@cPickSlipNo   NVARCHAR( 10), ' +
                        '@cPickZone     NVARCHAR( 10), ' +
                        '@cSuggLOC NVARCHAR( 10), ' +
                        '@cLOC          NVARCHAR( 10), ' +
                        '@cDropID       NVARCHAR( 20), ' +
                        '@cSKU          NVARCHAR( 20), ' +
                        '@cLottable01   NVARCHAR( 18), ' +
                        '@cLottable02   NVARCHAR( 18), ' +
                        '@cLottable03   NVARCHAR( 18), ' +
                        '@dLottable04   DATETIME,      ' +
                        '@dLottable05   DATETIME,      ' +
                        '@cLottable06   NVARCHAR( 30), ' +
                        '@cLottable07   NVARCHAR( 30), ' +
                        '@cLottable08   NVARCHAR( 30), ' +
                        '@cLottable09   NVARCHAR( 30), ' +
                        '@cLottable10   NVARCHAR( 30), ' +
                        '@cLottable11   NVARCHAR( 30), ' +
                        '@cLottable12   NVARCHAR( 30), ' +
                        '@dLottable13   DATETIME,      ' +
                        '@dLottable14   DATETIME,      ' +
                        '@dLottable15   DATETIME,      ' +
                        '@nTaskQTY      INT,           ' +
                        '@nQTY          INT,           ' +
                        '@cToLOC        NVARCHAR( 10), ' +
                        '@cOption       NVARCHAR( 1),  ' +
                        '@nErrNo        INT           OUTPUT, ' +
                        '@cErrMsg       NVARCHAR( 20) OUTPUT  '
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo, @cPickZone, @cSuggLOC, @cLOC, @cDropID, @cSKU,
                        @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                        @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                        @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                        @nTaskQTY, @nQTY, @cToLOC, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END

               /*
                  Option=1 = Short pick sku
                  Option=2 = Balance pick later, go to next sku or next loc or next zone
                  Option=9 = Reallocation
               */
               IF @cOption = '9'
               BEGIN
                  -- GOTO Reason code scn
                  SET @cOutField01 =''
                  SET @nAfterScn = 6847
                  SET @nAfterStep = 99
                  GOTO QUIT
               END --Option = 9

               IF @cOption IN ( '1' , '9')
                  SET @cType = 'SHORT'
               ELSE
                  SET @cType = ''

               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN
               SAVE TRAN rdt_830ExtScn09_6846

               IF @cOption IN ('1') 
               BEGIN

                  IF @nDebugFlag = 1
                  BEGIN
                     SELECT 'Confirm logic', @cOption AS cOption, @cType AS Type,  @cPickSlipNo AS PSNO,  
                        @cLoc AS LOC, @cPickZone AS PKZone, @cDropID AS DropID, @cID AS ID, @cSKU AS SKU, @nQTY AS QTY
                  END

                  -- Confirm task
                  --Not support inventory movement, so @cToLoc is always empty
                  SET @cToLOC = ''

                  SET @cMoveQTYPick = rdt.rdtGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)
                  IF @cMoveQTYPick = '1'
                  BEGIN

                     SET @cToLOC = rdt.rdtGetConfig( @nFunc, 'DefaultToLOC', @cStorerKey)
                     IF @cToLOC = ''
                     BEGIN
                        SET @nErrNo = 240405
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Movement flag cannot be set in reallocation
                        GOTO Scn_6846_Fail
                     END

                     IF NOT EXISTS(
                        SELECT 1 FROM dbo.Loc (NOLOCK) WHERE LOC = @cToLOC AND Facility = @cFacility
                     )
                     BEGIN
                        SET @nErrNo = 240406
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Movement flag cannot be set in reallocation
                        GOTO Scn_6846_Fail
                     END
                  END

                  EXEC rdt.rdt_PickSKU_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,
                     @cPickSlipNo, @cPickZone, @cLOC, @cDropID, @cID, @cSKU, @nQTY, @cToLOC, 
                     @cLottableCode,
                     @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                     @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                     @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                     @nErrNo  OUTPUT,
                     @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                  BEGIN
                     ROLLBACK TRAN rdt_830ExtScn09_6846
                     GOTO Scn_6846_Fail
                  END
               END --Confirm logic

               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo,@cPickZone, @cSuggLOC, @cLOC, @cDropID, @cSKU, ' +
                        ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                        ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                        ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                        ' @cUserDefine01, ' +
                        ' @nTaskQTY, @nQTY, @cToLOC, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        '@nMobile       INT,           ' +
                        '@nFunc         INT,           ' +
                        '@cLangCode     NVARCHAR( 3),  ' +
                        '@nStep         INT,           ' +
                        '@nAfterStep    INT,           ' +
                        '@nInputKey     INT,           ' +
                        '@cFacility     NVARCHAR( 5),  ' +
                        '@cStorerKey    NVARCHAR( 15), ' +
                        '@cPickSlipNo   NVARCHAR( 10), ' +
                        '@cPickZone     NVARCHAR( 10), ' +
                        '@cSuggLOC NVARCHAR( 10), ' +
                        '@cLOC          NVARCHAR( 10), ' +
                        '@cDropID       NVARCHAR( 20), ' +
                        '@cSKU          NVARCHAR( 20), ' +
                        '@cLottable01   NVARCHAR( 18), ' +
                        '@cLottable02   NVARCHAR( 18), ' +
                        '@cLottable03   NVARCHAR( 18), ' +
                        '@dLottable04   DATETIME,      ' +
                        '@dLottable05   DATETIME,      ' +
                        '@cLottable06   NVARCHAR( 30), ' +
                        '@cLottable07   NVARCHAR( 30), ' +
                        '@cLottable08   NVARCHAR( 30), ' +
                        '@cLottable09   NVARCHAR( 30), ' +
                        '@cLottable10   NVARCHAR( 30), ' +
                        '@cLottable11   NVARCHAR( 30), ' +
                        '@cLottable12   NVARCHAR( 30), ' +
                        '@dLottable13   DATETIME,      ' +
                        '@dLottable14   DATETIME,      ' +
                        '@dLottable15   DATETIME,      ' +
                        '@cUserDefine01 NVARCHAR( 30), ' +
                        '@nTaskQTY      INT,           ' +
                        '@nQTY          INT,           ' +
                        '@cToLOC        NVARCHAR( 10), ' +
                        '@cOption       NVARCHAR( 1),  ' +
                        '@nErrNo        INT           OUTPUT, ' +
                        '@cErrMsg       NVARCHAR( 20) OUTPUT  '
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo,@cPickZone, @cSuggLOC, @cLOC, @cDropID, @cSKU,
                        @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                        @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                        @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                        @cUserDefine01,
                        @nTaskQTY, @nPQTY, @cToLOC, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END--ext update
               COMMIT TRAN rdt_830ExtScn09_6846 -- Only commit change made here

               --Go to next screen
               EXEC rdt.rdt_PickSKU_GoToNextScreen @nMobile, @nFunc, @cLangCode, @nInputKey, @cFacility, @cStorerKey, @cPUOM, @cPickSlipNo,@cPickZone, @cLOC, @cID, @cDropID,
               @cSuggLOC   OUTPUT,  @cSuggID     OUTPUT,  @cSKU        OUTPUT,   @nTaskQTY      OUTPUT,  @cLottableCode OUTPUT,
               @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01   OUTPUT,
               @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02   OUTPUT,
               @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03   OUTPUT,
               @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04   OUTPUT,
               @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05   OUTPUT,
               @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06   OUTPUT,
               @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07   OUTPUT,
               @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08   OUTPUT,
               @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09   OUTPUT,
               @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10   OUTPUT,
               @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11   OUTPUT,
               @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12   OUTPUT,
               @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13   OUTPUT,
               @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14   OUTPUT,
               @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15   OUTPUT,
               @cSKUDescr  OUTPUT,  @cMUOM_Desc  OUTPUT,  @cPUOM_Desc   OUTPUT,  @nPUOM_Div     OUTPUT,
               @nTempStep  OUTPUT,  @nTempScn    OUTPUT,  @nErrNo       OUTPUT,  @cErrMsg       OUTPUT,
               @cPPK       OUTPUT
               
               --Return values to main function

               --Go to next screen
               SET @nAfterScn = @nTempScn
               SET @nAfterStep = @nTempStep

               IF @nDebugFlag = 1
                  SELECT 'Step99, Scn6846, inputkey=1 quit'

            END --Inputkey = 1

            IF @nInputkey = 0
            BEGIN
               -- Convert to prefer UOM QTY
               IF @cPUOM = '6' OR -- When preferred UOM = master unit
                  @nPUOM_Div = 0  -- UOM not setup
               BEGIN
                  SET @cPUOM_Desc = ''
                  SET @nPQTY = 0
                  SET @nMQTY = @nTaskQTY
                  SET @cFieldAttr14 = 'O' -- @nPQTY
               END
               ELSE
               BEGIN
                  SET @nPQTY = @nTaskQTY / @nPUOM_Div -- Calc QTY in preferred UOM
                  SET @nMQTY = @nTaskQTY % @nPUOM_Div -- Calc the remaining in master unit
                  SET @cFieldAttr14 = '' -- @nPQTY
               END
               
               SET @cOutField01 = @cPPK
               SET @cOutField02 = @cSKU
               SET @cOutField03 = SUBSTRING( @cSKUDescr, 1, 20)  -- SKU desc 1
               SET @cOutField04 = SUBSTRING( @cSKUDescr, 21, 20) -- SKU desc 2
               SET @cOutField09 = '1:' + CAST( @nPUOM_Div AS NCHAR( 6))
               SET @cOutField10 = @cPUOM_Desc
               SET @cOutField11 = @cMUOM_Desc
               SET @cOutField12 = CASE WHEN @cFieldAttr14 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END
               SET @cOutField13 = CAST( @nMQTY AS NVARCHAR( 5))
               SET @cOutField14 = '' -- @nPQTY
               SET @cOutField15 = '' -- @nMQTY

               SET @nAfterScn = 4693 --Qty screen
               SET @nAfterStep = 4

               IF @nDebugFlag = 1
                  SELECT 'Step99, Scn6846, inputkey=0 quit'
            END

            Scn_6846_Quit:
               GOTO Quit

            Scn_6846_Fail:
            BEGIN
               -- Reset this screen var
               SET @cOutField01 = '' --Option
               GOTO Quit
            END
         END --6846
         IF @nScn = 6847 --Reason code screen for reallocation
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cReasonCode = @cInField01
               SELECT @cCCTaskType = UDF01,@cHoldLocOrID = UDF02, @cHoldOrNot = CASE WHEN ISNULL(UDF03,'')='X' THEN '1' ELSE '0' END,
                     @cShortLoc = NOTES
               FROM CODELKUP WITH(NOLOCK)
               WHERE LISTNAME ='RDTREASON' AND CODE = @nFunc AND STORERKEY = @cStorerKey AND CODE2 = @cReasonCode
               SET @nRowcount = @@ROWCOUNT

               IF @nRowcount = 0
               BEGIN
                  SET @nErrNo = 261001
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid reason code
                  GOTO Quit
               END
               IF ISNULL(@cShortLoc ,'') = ''
               BEGIN
                  SET @nErrNo = 261002
                  SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
               IF NOT EXISTS ( SELECT 1 FROM LOC WITH(NOLOCK) WHERE LOC = @cShortLoc AND Facility = @cFacility AND LocationType = 'HOLD')
               BEGIN
                  SET @nErrNo = 261003
                  SET @cErrMsg = rdt.rdtgetmessageLong( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
               SET @cType = 'SHORT'
               IF @nDebugFlag = 1
               BEGIN
                  SELECT 'Confirm logic', @cOption AS cOption, @cType AS Type,  @cPickSlipNo AS PSNO,  
                     @cLoc AS LOC, @cPickZone AS PKZone, @cDropID AS DropID, @cID AS ID, @cSKU AS SKU, @nQTY AS QTY
               END

               -- Handling transaction
               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN  -- Begin our own transaction
               SAVE TRAN rdt_830ExtScn09_6847

               -- Confirm task
               SET @cMoveQTYPick = rdt.rdtGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)

               EXEC rdt.rdt_PickSKU_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,
                  @cPickSlipNo, @cPickZone, @cLOC, @cDropID, @cID, @cSKU, @nQTY, '', 
                  @cLottableCode,
                  @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                  @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                  @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT
               IF @nErrNo <> 0
               BEGIN
                  ROLLBACK TRAN rdt_830ExtScn09_6847
                  GOTO ROLLBACK_6847
               END

               IF @cHoldLocOrID = 'LOC'
               BEGIN
                  EXEC nspInventoryHoldWrapper
                     '',               -- lot
                     @cLOC,            -- loc
                     '',               -- id
                     @cStorerKey,     -- storerkey
                     @cSKU,           -- sku
                     '',               -- lottable01
                     '',               -- lottable01
                     '',               -- lottable01
                     NULL,             -- lottable01
                     NULL,             -- lottable01
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     NULL,
                     NULL,
                     NULL,
                     @cReasonCode,      -- status
                     @cHoldOrNot,              -- hold
                     @b_success OUTPUT,
                     @nErrNo OUTPUT,
                     @cErrMsg OUTPUT,
                     ''   -- remark
               END
               ELSE IF @cHoldLocOrID = 'ID'
               BEGIN
                  EXEC nspInventoryHoldWrapper
                     '',               -- lot
                     '',               -- loc
                     @cID,               -- id
                     @cStorerKey,     -- storerkey
                     @cSKU,           -- sku
                     '',               -- lottable01
                     '',               -- lottable01
                     '',               -- lottable01
                     NULL,             -- lottable01
                     NULL,             -- lottable01
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     NULL,
                     NULL,
                     NULL,
                     @cReasonCode,      -- status
                     @cHoldOrNot,              -- hold
                     @b_success OUTPUT,
                     @nErrNo OUTPUT,
                     @cErrMsg OUTPUT,
                     ''   -- remark
               END

               SELECT TOP 1
                  @cOrderKey = OrderKey,
                  @cLoadKey = ExternOrderKey,
                  @cWaveKey = WaveKey,
                  @cZone = Zone
               FROM dbo.PickHeader WITH (NOLOCK)
               WHERE PickHeaderKey = @cPickSlipNo

               -- Get lottable filter
               EXEC rdt.rdt_Lottable_GetCurrentSQL @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLottableCode, 4, 'LA', 
                  @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                  @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                  @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                  @cWhere   OUTPUT,
                  @nErrNo   OUTPUT,
                  @cErrMsg  OUTPUT

               -- Cross dock PickSlip
               IF @cZone IN ('XD', 'LB', 'LP')
                  SET @cSQL = 
                     ' SELECT PD.PickDetailKey, PD.QTY ' + 
                     ' FROM dbo.RefKeyLookup RKL WITH (NOLOCK)' + 
                        ' JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)' + 
                        ' JOIN dbo.Loc LOC WITH (NOLOCK) ON (LOC.LOC=PD.LOC)'+ --(yeekung03)
                        ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' + 
                     ' WHERE RKL.PickSlipNo = @cPickSlipNo ' + 
                        ' AND PD.LOC = @cLOC ' + 
                        CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END + 
                        ' AND PD.SKU = @cSKU ' + 
                        ' AND PD.QTY > 0' + 
                        ' AND PD.Status = ''4''' + 
                        CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END + 
                        CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END

               -- Discrete PickSlip
               ELSE IF @cOrderKey <> ''
                  SET @cSQL = 
                     ' SELECT PD.PickDetailKey, PD.QTY ' + 
                     ' FROM dbo.PickDetail PD WITH (NOLOCK) ' + 
                        ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' + 
                        ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' + 
                     ' WHERE PD.OrderKey = @cOrderKey ' + 
                        ' AND PD.LOC = @cLOC ' + 
                        CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END + 
                        ' AND PD.SKU = @cSKU ' + 
                        ' AND PD.QTY > 0' + 
                        ' AND PD.Status = ''4''' + 
                        CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END + 
                        CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END

               -- Conso PickSlip
               ELSE IF @cLoadKey <> ''
                  SET @cSQL = 
                     ' SELECT PD.PickDetailKey, PD.QTY ' + 
                     ' FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) ' +
                        ' JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey) ' + 
                        ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' + 
                        ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' + 
                     ' WHERE LPD.LoadKey = @cLoadKey ' + 
                        ' AND PD.LOC = @cLOC ' + 
                        CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END + 
                        ' AND PD.SKU = @cSKU ' + 
                        ' AND PD.QTY > 0' + 
                        ' AND PD.Status = ''4''' + 
                        CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END + 
                        CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END

               -- Custom PickSlip
               ELSE
                  SET @cSQL = 
                     ' SELECT PD.PickDetailKey, PD.QTY ' + 
                     ' FROM dbo.PickDetail PD WITH (NOLOCK) ' + 
                        ' JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' + 
                        ' JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' + 
                     ' WHERE PD.PickSlipNo = @cPickSlipNo ' + 
                        ' AND PD.LOC = @cLOC ' + 
                        CASE WHEN @cVerifyID = '1' THEN ' AND PD.ID = @cID ' ELSE '' END + 
                        ' AND PD.SKU = @cSKU ' + 
                        ' AND PD.QTY > 0' + 
                        ' AND PD.Status = ''4''' + 
                        CASE WHEN @cPickZone <>'' THEN ' AND LOC.PickZone = @cPickZone ' ELSE '' END + 
                        CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END

               -- Open cursor
               SET @cSQL = 
                  ' SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' + 
                     @cSQL + 
                  ' OPEN @curPD ' 
               
               SET @cSQLParam = 
                  ' @curPD       CURSOR OUTPUT, ' + 
                  ' @cPickSlipNo NVARCHAR( 10), ' + 
                  ' @cOrderKey   NVARCHAR( 10), ' + 
                  ' @cLoadKey    NVARCHAR( 10), ' +
                  ' @cPickZone   NVARCHAR( 10), ' + 
                  ' @cLOC        NVARCHAR( 10), ' + 
                  ' @cID         NVARCHAR( 18), ' +  
                  ' @cSKU        NVARCHAR( 20), ' + 
                  ' @cLottable01 NVARCHAR( 18), ' + 
                  ' @cLottable02 NVARCHAR( 18), ' + 
                  ' @cLottable03 NVARCHAR( 18), ' + 
                  ' @dLottable04 DATETIME,      ' + 
                  ' @dLottable05 DATETIME,      ' + 
                  ' @cLottable06 NVARCHAR( 30), ' + 
                  ' @cLottable07 NVARCHAR( 30), ' + 
                  ' @cLottable08 NVARCHAR( 30), ' + 
                  ' @cLottable09 NVARCHAR( 30), ' + 
                  ' @cLottable10 NVARCHAR( 30), ' + 
                     ' @cLottable11 NVARCHAR( 30), ' + 
                     ' @cLottable12 NVARCHAR( 30), ' + 
                     ' @dLottable13 DATETIME,      ' + 
                     ' @dLottable14 DATETIME,      ' + 
                     ' @dLottable15 DATETIME       ' 

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @curPD OUTPUT, @cPickSlipNo, @cOrderKey, @cLoadKey, @cPickZone, @cLOC, @cID, @cSKU, 
                  @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                  @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                  @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
                        
               -- Loop PickDetail
               FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  UPDATE PICKDETAIL WITH (ROWLOCK)
                  SET QTYMoved = QTY,
                     QTY = 0,
                     TaskManagerReasonKey = @cReasonCode
                  WHERE PickDetailKey = @cPickDetailKey

                  SELECT @cOrderKey = OrderKey,
                     @cLot = lot,
                     @cPUOM = P.PackUOM3,
                     @cPackKey = PD.PackKey,
                     @cID  = ID,
                     @cMoveRefKey = OrderLineNumber
                  FROM PICKDETAIL PD WITH (NOLOCK)
                  INNER JOIN PACK P  WITH (NOLOCK) ON P.PackKey = PD.PackKey
                  WHERE PickDetailKey = @cPickDetailKey

                  -- Move LOTxLOCxID
                  EXEC dbo.nspItrnAddMove
                     @n_ItrnSysId     = NULL            -- int
                     , @c_StorerKey     = @cStorerKey   -- NVARCHAR(15)
                     , @c_Sku           = @cSKU         -- NVARCHAR(20)
                     , @c_Lot           = @cLOT         -- NVARCHAR(10)
                     , @c_FromLoc       = @cLOC         -- NVARCHAR(10)
                     , @c_FromID        = @cID          -- NVARCHAR(18)
                     , @c_ToLoc         = @cShortLoc    -- NVARCHAR(10)
                     , @c_ToID          = @cID          -- NVARCHAR(18)
                     , @c_Status        = 'OK'            -- NVARCHAR(10)
                     , @c_lottable01    = ''            -- NVARCHAR(18)
                     , @c_lottable02    = ''            -- NVARCHAR(18)
                     , @c_lottable03    = ''            -- NVARCHAR(18)
                     , @d_lottable04    = ''            -- datetime
                     , @d_lottable05    = ''            -- datetime
                     , @n_casecnt       = 0             -- int
                     , @n_innerpack     = 0             -- int
                     , @n_qty           = @nQTY_PD    -- int
                     , @n_pallet        = 0             -- int
                     , @f_cube          = 0             -- float
                     , @f_grosswgt      = 0             -- float
                     , @f_netwgt        = 0             -- float
                     , @f_otherunit1    = 0             -- float
                     , @f_otherunit2    = 0             -- float
                     , @c_SourceKey     = ''            -- NVARCHAR(20)
                     , @c_SourceType    = 'RDT_PICK_SHORT'  -- NVARCHAR(30)
                     , @c_PackKey       = @cPackKey     -- NVARCHAR(10)
                     , @c_UOM           = @cPUOM         -- NVARCHAR(10)
                     , @b_UOMCalc       = 1             -- int
                     , @d_EffectiveDate = ''            -- datetime
                     , @c_itrnkey       = ''            -- NVARCHAR(10)   OUTPUT
                     , @b_Success       = @b_Success     -- int        OUTPUT
                     , @n_err           = @nErrNo       -- int        OUTPUT
                     , @c_errmsg        = @cErrMsg      -- NVARCHAR(250)  OUTPUT
                     , @c_MoveRefKey    = @cMoveRefKey
            
                  SET @nErrNo = @@ERROR
                  IF @nErrNo <> 0
                  BEGIN
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO ROLLBACK_6847
                  END
                  FETCH NEXT FROM @curPD INTO @cPickDetailKey, @nQTY_PD
               END

               CLOSE @curPD  --(yeekung02)
               DEALLOCATE @curPD
               -- Generate alert
               EXEC nspLogAlert
                  @c_modulename       = '830-ShortPick'
                  , @c_AlertMessage     = 'Verify Short Pick Location'
                  , @n_Severity         = '5'
                  , @b_Success          = @b_Success      OUTPUT
                  , @n_err              = @nErrNO          OUTPUT
                  , @c_errmsg           = @cErrMSG       OUTPUT
                  , @c_Activity         = ''
                  , @c_Storerkey        = @cStorerKey

               COMMIT TRAN rdt_830ExtScn09_6847

               SELECT 
                  @cAPP_DB_Name         = APP_DB_Name,
                  @cDataStream          = DataStream,
                  @nThreadPerAcct       = ThreadPerAcct,
                  @nThreadPerStream     = ThreadPerStream,
                  @nMilisecondDelay     = MilisecondDelay,
                  @cIP                  = IP,
                  @cPORT                = PORT,
                  @cIniFilePath         = IniFilePath,
                  @cCmdType             = CmdType,
                  @cTaskType            = TaskType,
                  @cExecStatements      = StoredProcName
               FROM dbo.QCmd_TransmitlogConfig WITH (NOLOCK)
               WHERE TableName = '830ShortPickReallo'
                  AND App_Name = 'WMS'
                  AND StorerKey =  @cStorerKey
               
               IF @@ROWCOUNT <= 0
               BEGIN
                  SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                  SET @cErrMsg1 = '261004-NoQcmdConfig'
                  SET @cErrMsg2 = 'Trigger reallocation fail '
                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                  GOTO Reallocation_Fail
               END

               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = LTRIM(RTRIM(@cExecStatements)) AND type = 'P')
               BEGIN
                  SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                                 + ' @c_Wavekey = ''' + ISNULL(@cWaveKey,'') + ''''
                                 + ', @c_SKU = ''' + @cSKU + ''''
                                 + ', @c_InputValue = ''' + @cShortLoc + ''''

                  IF @nDebugFlag = 1
                     SELECT 'Start to submit Qcmd', @cExecStatements

                  -- Submit task to QCommander
                  BEGIN TRY
                     EXEC isp_QCmd_SubmitTaskToQCommander
                        @cTaskType           = 'O'        -- 'T' - TransmitlogKey, 'D' - Data Stream, 'O' - Other
                        , @cStorerKey          = @cStorerKey
                        , @cDataStream         = @cDataStream
                        , @cCmdType            = @cCmdType 
                        , @cCommand            = @cExecStatements
                        , @cTransmitlogKey     = '' 
                        , @nThreadPerAcct      = @nThreadPerAcct 
                        , @nThreadPerStream    = @nThreadPerStream 
                        , @nMilisecondDelay    = @nMilisecondDelay  
                        , @nSeq                = 1
                        , @cIP                 = @cIP
                        , @cPORT               = @cPORT
                        , @cIniFilePath        = @cIniFilePath
                        , @cAPPDBName          = @cAPP_DB_Name
                        , @bSuccess            = @b_Success     OUTPUT 
                        , @nErr                = @nErrNo       OUTPUT 
                        , @cErrMsg             = @cErrMsg      OUTPUT
                        , @nQueueID            = @nQueueID     OUTPUT
                  END TRY
                  BEGIN CATCH
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg3 = ERROR_MESSAGE()
                     SET @cErrMsg1 = '261005-QcmdFail'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Reallocation_Fail
                  END CATCH

                  IF @nErrNo <> 0
                  BEGIN
                     SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                     SET @cErrMsg3 = 'Retrun err: ' + CAST(@nErrNo AS NVARCHAR(10))
                     SET @cErrMsg1 = '261006-GenQcmdTaskFail'
                     SET @cErrMsg2 = 'Trigger reallocation fail '
                     EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                     GOTO Reallocation_Fail
                  END
               END -- submit Qcmd
               ELSE
               BEGIN
                  SELECT @cErrMsg1 = '', @cErrMsg2 = '', @cErrMsg3 = ''
                  SET @cErrMsg1 = '261007-InvalidSPName'
                  SET @cErrMsg2 = 'Trigger reallocation fail '
                  EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cErrMsg1, @cErrMsg2, @cErrMsg3
                  GOTO Reallocation_Fail
               END

               Reallocation_Fail:
               --Go to next screen
               EXEC rdt.rdt_PickSKU_GoToNextScreen @nMobile, @nFunc, @cLangCode, @nInputKey, @cFacility, @cStorerKey, @cPUOM, @cPickSlipNo,@cPickZone, @cLOC, @cID, @cDropID,
               @cSuggLOC   OUTPUT,  @cSuggID     OUTPUT,  @cSKU        OUTPUT,   @nTaskQTY      OUTPUT,  @cLottableCode OUTPUT,
               @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01   OUTPUT,
               @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02   OUTPUT,
               @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03   OUTPUT,
               @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04   OUTPUT,
               @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05   OUTPUT,
               @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06   OUTPUT,
               @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07   OUTPUT,
               @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08   OUTPUT,
               @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09   OUTPUT,
               @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10   OUTPUT,
               @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11   OUTPUT,
               @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12   OUTPUT,
               @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13   OUTPUT,
               @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14   OUTPUT,
               @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15   OUTPUT,
               @cSKUDescr  OUTPUT,  @cMUOM_Desc  OUTPUT,  @cPUOM_Desc   OUTPUT,  @nPUOM_Div     OUTPUT,
               @nTempStep  OUTPUT,  @nTempScn    OUTPUT,  @nErrNo       OUTPUT,  @cErrMsg       OUTPUT,
               @cPPK       OUTPUT
               
               --Return values to main function

               --Go to next screen
               SET @nAfterScn = @nTempScn
               SET @nAfterStep = @nTempStep

               GOTO QUIT

               ROLLBACK_6847:
                  ROLLBACK TRAN
                  GOTO QUIT
            END
            IF @nInputKey = 0
            BEGIN
               SET @nAfterScn = 6846
               SET @nAfterStep = 99
               SET @cOutfield01 = ''
               GOTO QUIT
            END
         END
      END --step 99
   END

   GOTO Quit

Quit:
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Exiting rdt_830ExtScn09'
      SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nAfterScn AS AfterScn, @nAfterStep AS AfterStep
   END

   SET @cUDF01 = @cSuggLOC
   SET @cUDF02 = @cSuggID
   SET @cUDF03 = @cSKU
   SET @cUDF04 = @nTaskQTY
   SET @cUDF05 = @cLottableCode
   SET @cUDF06 = @cSKUDescr
   SET @cUDF07 = @cMUOM_Desc
   SET @cUDF08 = @cPUOM_Desc
   SET @cUDF09 = @nPUOM_Div
   SET @cUDF10 = @cPPK

   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_830ExtScn09 TO NSQL
GO
 
