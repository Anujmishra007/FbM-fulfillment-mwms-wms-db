
/************************************************************************/  
/* Store procedure: rdt_830ExtScn02                                     */
/*                                                                      */  
/* Purpose:       For MATTEL                                            */  
/*                                                                      */  
/* Date        Rev   Author     Purposes                                */
/* 2025-06-05  1.0.0 JACKC      FCR-4328 Short Pick Screen              */
/************************************************************************/  
  
CREATE OR ALTER PROC  [RDT].[rdt_830ExtScn02] (
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

      @nTranCount             INT,

      --Extended SP
      @cExtendedValidateSP    NVARCHAR( 20),
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cExtendedInfo          NVARCHAR( 20),

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

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_830ExtScn02'

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

   IF @nFunc = 830
   BEGIN
      IF @nScn = 4696 --Short pick screen
      BEGIN
         IF @nDebugFlag = 1
         BEGIN
            SELECT 'Step99, Scn 4696'
         END

         SET @nAfterScn = 6528
         SET @nAfterStep = 99
         SET @cOutfield01 = ''
         GOTO QUIT
      END
      ELSE IF @nStep = 99
      BEGIN
         IF @nScn = 6528 --Short pick screen
         /********************************************************************************
         Scn = 6528. Confirm Option?
            1 = Short
            2 = Bal pick later
            9 = Alternate PICK LOC
            Option (field01)
         ********************************************************************************/
         BEGIN
            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Step99, Scn 6528'
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
                  GOTO Scn_6528_Fail
               END

               -- Validate option
               IF @cOption <> '1' AND
                  @cOption <> '2' AND
                  @cOption <> '9'
               BEGIN
                  SET @nErrNo = 240402
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO Scn_6528_Fail
               END

               IF @cOption = '9'
               BEGIN

                  SELECT @cPutawayZone = PutawayZone FROM dbo.Loc (NOLOCK) WHERE LOC = @cLOC
                  
                  IF ISNULL(@cPutawayZone, '') = ''
                  BEGIN
                     SET @nErrNo = 240404
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Putaway Zone Required
                     GOTO Scn_6528_Fail
                  END

                  --Movement flag cannot be set in reallocation
                  SET @cMoveQTYAlloc = rdt.rdtGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
                  SET @cMoveQTYPick = rdt.rdtGetConfig( @nFunc, 'MoveQTYPick', @cStorerKey)

                  IF @cMoveQTYAlloc = '1' OR @cMoveQTYPick = '1'
                  BEGIN
                     SET @nErrNo = 240405
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Movement flag cannot be set in reallocation
                     GOTO Scn_6528_Fail
                  END
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
               IF @cOption IN ( '1' , '9')
                  SET @cType = 'SHORT'
               ELSE
                  SET @cType = ''

               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN
               SAVE TRAN rdt_830ExtScn02_6528

               IF @cOption IN ('1', '9') 
               BEGIN

                  IF @nDebugFlag = 1
                  BEGIN
                     SELECT 'Confirm logic', @cOption AS cOption, @cType AS Type,  @cPickSlipNo AS PSNO,  
                        @cLoc AS LOC, @cPickZone AS PKZone, @cDropID AS DropID, @cID AS ID, @cSKU AS SKU, @nQTY AS QTY
                  END

                  -- Confirm task
                  --Not support inventory movement, so @cToLoc is always empty
                  SET @cToLOC = ''
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
                     ROLLBACK TRAN rdt_830ExtScn02_6528
                     WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                        COMMIT TRAN
                     GOTO Scn_6528_Fail
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
               
               IF @cOption = '9'
               BEGIN

                  IF @nDebugFlag = 1
                  BEGIN
                     SELECT 'Option 9 - reallocation logic'
                  END


                  DECLARE @cRealloPickZone      NVARCHAR(10)
                  DECLARE @cRealloPickSlipNo    NVARCHAR(10)
                  DECLARE @cRealloLOC           NVARCHAR(10)
                  DECLARE @cRealloID            NVARCHAR(18)
                  DECLARE @cOrderKey           NVARCHAR( 10)
                  DECLARE @tAdditionalData      [dbo].[VariableTable]

                  SELECT TOP 1 @cOrderKey = OrderKey FROM dbo.PickHeader WITH (NOLOCK) WHERE PickHeaderKey = @cPickSlipNo

                  --Find inventory for re-allocation
                  --Reallocation, To Do
                  -- Get lottable filter
                  EXEC rdt.rdt_Lottable_GetCurrentSQL @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLottableCode, 4, 'LA',
                     @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                     @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                     @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                     @cWhere   OUTPUT,
                     @nErrNo   OUTPUT,
                     @cErrMsg  OUTPUT

                  SET @cSQL =
                  ' SELECT TOP 1 @cLot = PD.LOT ' +
                  ' FROM dbo.PickDetail PD WITH (NOLOCK) ' +
                  '    JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC) ' +
                  '    JOIN LotAttribute LA WITH (NOLOCK) ON (LA.LOT = PD.LOT) ' +
                  ' WHERE PD.Orderkey = @cOrderkey ' +
                  '    AND PD.LOC = @cLOC ' +
                  '    AND PD.SKU = @cSKU ' +
                  '    AND PD.Status = ''4'' ' +
                  CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END
                  SET @cSQL = @cSQL + ' ORDER BY PD.EditDate DESC '

                  SET @cSQLParam =
                     ' @cLot        NVARCHAR( 10) OUTPUT, ' +
                     ' @cPickSlipNo NVARCHAR( 10), ' +
                     ' @cOrderKey   NVARCHAR( 10), ' +
                     ' @cLoadKey    NVARCHAR( 10), ' +
                     ' @cLOC        NVARCHAR( 10), ' +
                     ' @cDropID     NVARCHAR( 20), ' +
                     ' @cSKU        NVARCHAR( 20), ' +
                     ' @cPickConfirmStatus NVARCHAR( 1), ' +
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

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @cLot OUTPUT, @cPickSlipNo, @cOrderKey, '', @cLOC, @cDropID, @cSKU, '5',
                     @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                     @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                     @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

                  IF @nDebugFlag = 1
                  BEGIN
                     SELECT 'Get lot number', @cLot AS Lot, @cSQL AS GetLotSQL
                  END

                  SET @cRealloPickSlipNo = @cPickSlipNo
                  SET @CRealloPickZone = @cPickZone
                  
                  EXECUTE [RDT].[rdt_PickReallo02]
                     @nMobile = @nMobile
                     ,@nFunc = @nFunc
                     ,@cLangCode = @cLangCode
                     ,@cFacility = @cFacility
                     ,@cStorerKey = @cStorerKey
                     ,@cPickSlipNo = @cRealloPickSlipNo OUTPUT
                     ,@tAdditionalData = @tAdditionalData
                     ,@cType = 'SKU'
                     ,@cLOC = @cLOC
                     ,@cID = @cID
                     ,@cSKU = @cSKU
                     ,@nQTY = ''
                     ,@cLot = @cLot OUTPUT
                     ,@cPickZone = @cRealloPickZone OUTPUT
                     ,@cSuggestLOC = @cRealloLOC OUTPUT
                     ,@cSuggestID = @cRealloID OUTPUT
                     ,@nErrNo = @nErrNo OUTPUT
                     ,@cErrMsg = @cErrMsg OUTPUT
                  
                  IF @nErrNo <> 0
                  BEGIN
                     ROLLBACK TRAN rdt_830ExtScn02_6528
                     WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                        COMMIT TRAN
                     
                     IF @nErrNo > 0
                     BEGIN
                        INSERT dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                           Step3, Step4, Step5,
                           Col1, Col2, Col3, Col4, Col5)
                        VALUES('rdt_830ExtScn02', GETDATE(), 'rdt_830ExtScn02', CAST(@nMobile AS NVARCHAR(10)), 
                           CAST(@nScn AS NVARCHAR(10)), CAST(@nErrNo AS NVARCHAR(10)), @cPickSlipNo,
                               @cLOC, @cSKU, @cID, @cLot, @cErrMsg)

                        SET @nErrNo = 235853
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reallocation failed

                        GOTO Scn_6528_Fail
                     END
                  END

                  --1. New allocation in same zone, prompt a message, continue the picking
                  --Alternate location found and is added to current pickslip
                  IF ISNULL(@cRealloLoc, '') <> ''
                  BEGIN
--                      IF ISNULL(@cRealloPickZone, '') = @cPickZone AND @cRealloPickSlipNo = @cPickSlipNo
--                      BEGIN
                        --i. Display message like "Alternate location found and is added to current pickslip"
                        SET @cMsg01 = 'Alternate location '
                        SET @cMsg02 = 'found and is added '
                        SET @cMsg03 = 'to the pickslip'
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
-- --                      END
-- --                      ELSE
--                      --2. New allocation in different zone, prompt a message, continue the picking
--                      --Alternate location found and is added to pickslip **********
--                      BEGIN
--                         SET @cMsg01 = 'Alternate location '
--                         SET @cMsg02 = 'found and is added '
--                         SET @cMsg03 = 'to pickslip '
--                         SET @cMsg04 = @cRealloPickSlipNo
--                         EXEC rdt.rdtInsertMsgQueue @nMobile = @nMobile,
--                                        @nErrNo = @nErrNo,
--                                        @cErrMsg = @cErrMsg,
--                                        @cLine01 = @cMsg01,
--                                        @cLine02 = @cMsg02,
--                                        @cLine03 = @cMsg03,
--                                        @cLine04 = @cMsg04,
--                                        @cLine05 = @cMsg05,
--                                        @cLine06 = @cMsg06,
--                                        @cLine07 = @cMsg07,
--                                        @cLine08 = @cMsg08,
--                                        @cLine09 = @cMsg09,
--                                        @nDisplayMsg = 0
--                      END
                  END
                  ELSE -- Errno = -1
                  --3. No loc found
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
                     
                     -- If no location found, then user has to choose short by manul
                     -- So stay at the option screen
                     SET @cOutField01 = '' --Option

                     GOTO Scn_6528_Fail
                  END --Errno = -1

               END --Option = 9

               COMMIT TRAN rdt_830ExtScn02_6528 -- Only commit change made here
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN

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

               --Go to next screen
               SET @nAfterScn = @nTempScn
               SET @nAfterStep = @nTempStep

               IF @nDebugFlag = 1
                  SELECT 'Step99, Scn6528, inputkey=1 quit'

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
                  SELECT 'Step99, Scn6528, inputkey=0 quit'
            END

            Scn_6528_Quit:
               GOTO Quit

            Scn_6528_Fail:
            BEGIN
               -- Reset this screen var
               SET @cOutField01 = '' --Option
               GOTO Quit
            END
         END --6528
      END --step 99
   END

   GOTO Quit

Quit:
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Exiting rdt_830ExtScn02'
      SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nAfterScn AS AfterScn, @nAfterStep AS AfterStep
   END
END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_830ExtScn02 TO NSQL
GO
 
