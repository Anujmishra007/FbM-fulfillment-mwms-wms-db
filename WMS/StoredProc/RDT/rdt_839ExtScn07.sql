SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_839ExtScn07                                     */
/*                                                                      */  
/* Purpose:       For GM                                                */  
/*                                                                      */  
/* Date        Rev   Author     Purposes                                */
/* 2026-02-02  1.0.0 JCH507     FCR-10041 Short Pick Screen             */
/************************************************************************/  
  
CREATE OR ALTER PROC  [RDT].[rdt_839ExtScn07] (
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

   DECLARE @cWhere         NVARCHAR( MAX)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @cLot           NVARCHAR(10)

   DECLARE 
      @cSuggSKU               NVARCHAR( 20),
      @cSuggLOC               NVARCHAR( 10),
      @nSuggQTY               INT,
      @cSKU                   NVARCHAR( 20),
      @cSKUDescr              NVARCHAR( 60),
      @cLOC                   NVARCHAR( 10),
      @cID                    NVARCHAR( 20),
      @cOption                NVARCHAR( 1),
      @nActQTY                INT,
      @nTtlBalQty             INT,
      @nBalQty                INT,
      @cSerialNoCapture       NVARCHAR( 1),
      @cSKUSerialNoCapture    NVARCHAR( 1),
      @cPickSlipNo            NVARCHAR( 10),
      @cPickZone              NVARCHAR( 10),
      @cDropID                NVARCHAR( 20),
      @cLottableCode          NVARCHAR( 30),
      @cSkipConfirmBalPick    NVARCHAR( 1),
      @cPackData1             NVARCHAR( 30),   --(yeekung04)
      @cPackData2             NVARCHAR( 30),   --(yeekung04)
      @cPackData3             NVARCHAR( 30),
      @cSuggID                NVARCHAR( 20),
      @cDisableQTYField       NVARCHAR( 1),
      @cBarcode               NVARCHAR( MAX),

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

   -- Screen constant
   DECLARE
      @nStep_PickSlipNo       INT,  @nScn_PickSlipNo     INT,
      @nStep_PickZone         INT,  @nScn_PickZone       INT,
      @nStep_SKUQTY           INT,  @nScn_SKUQTY         INT,
      @nStep_NoMoreTask       INT,  @nScn_NoMoreTask     INT,
      @nStep_ShortPick        INT,  @nScn_ShortPick      INT,
      @nStep_SkipLOC          INT,  @nScn_SkipLOC        INT,
      @nStep_ConfirmLOC       INT,  @nScn_ConfirmLOC     INT,
      @nStep_AbortPick        INT,  @nScn_AbortPick      INT,
      @nStep_VerifyID         INT,  @nScn_VerifyID       INT,
      @nStep_MultiSKU         INT,  @nScn_MultiSKU       INT,
      @nStep_DataCapture      INT,  @nScn_DataCapture    INT,
      @nStep_SerialNo         INT,  @nScn_SerialNo       INT,
      @nStep99                INT
      
   SELECT
      @nStep_PickSlipNo       = 1,  @nScn_PickSlipNo     = 4640,
      @nStep_PickZone         = 2,  @nScn_PickZone       = 4641,
      @nStep_SKUQTY           = 3,  @nScn_SKUQTY         = 4642,
      @nStep_NoMoreTask       = 4,  @nScn_NoMoreTask     = 4643,
      @nStep_ShortPick        = 5,  @nScn_ShortPick      = 4644,
      @nStep_SkipLOC          = 6,  @nScn_SkipLOC        = 4645,
      @nStep_ConfirmLOC       = 7,  @nScn_ConfirmLOC     = 4646,
      @nStep_AbortPick        = 8,  @nScn_AbortPick      = 4647,
      @nStep_VerifyID         = 9,  @nScn_VerifyID       = 4648,
      @nStep_MultiSKU         = 10, @nScn_MultiSKU       = 3570,
      @nStep_DataCapture      = 11, @nScn_DataCapture    = 4649,
      @nStep_SerialNo         = 12, @nScn_SerialNo       = 4830,
      @nStep99                = 99

   SELECT @cSuggSKU = Value FROM @tExtScnData WHERE Variable = '@cSuggSKU'

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_839ExtScn07'

   SELECT 
      @cPickZone           = V_Zone,
      @cPickSlipNo         = V_PickSlipNo,
      @cSuggLOC            = V_LOC,
      @cSuggSKU            = V_SKU,
      @cSKUDescr           = V_SKUDescr,
      @nSuggQTY            = V_QTY,
      @nActQTY             = V_Integer1,
      @nTtlBalQty          = V_Integer2,
      @nBalQty             = V_Integer3,
      @cDropID             = V_String4,
      @cLottableCode       = V_String6,
      @cSkipConfirmBalPick = V_String14,
      @cSKUSerialNoCapture = V_String15,
      @cExtendedValidateSP = V_String21,
      @cExtendedUpdateSP   = V_String22,
      @cDisableQTYField    = V_String30,
      @cSerialNoCapture    = V_String34,
      @cSuggID             = V_String38,
      @cPackData1          = V_String41,  --(yeekung04)
      @cPackData2          = V_String42,  --(yeekung04)
      @cPackData3          = V_String43
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nAction = 1
   BEGIN
      IF @nFunc = 839
      BEGIN
         IF @nScn = 4644 --Short pick screen
         BEGIN
            IF @nDebugFlag = 1
            BEGIN
               SELECT 'Step99, Scn 4644'
            END

            SET @nAfterScn = 6823
            SET @nAfterStep = 99
            SET @cOutfield01 = ''
            GOTO QUIT
         END
         ELSE IF @nStep = 99
         BEGIN
            IF @nScn = 6823 --Short pick screen --v1.1.0
            /********************************************************************************
            Scn = 6823. Confirm Option?
               1 = Short
               2 = Bal pick later
               3 = Close drop ID
               9 = Alternate PICK LOC
               Option (field01)
            ********************************************************************************/
            BEGIN
               IF @nDebugFlag = 1
               BEGIN
                  SELECT 'Step99, Scn 6823'
               END

               IF @nInputKey = 0 --ESC
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Scn 6823 ESC'

                  -- Prepare SKU QTY screen var
                  SET @cOutField01 = @cSuggLOC
                  SET @cOutField02 = @cSuggSKU
                  SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)  -- SKU desc 1
                  SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20) -- SKU desc 2
                  SET @cOutField05 = '' -- SKU/UPC
                  SET @cOutField06 = RTRIM(CAST( @nSuggQTY AS NVARCHAR(6)))
                  SET @cOutField07 = CAST( @nActQTY AS NVARCHAR(6))
                  SET @cOutField13 = LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))

                  -- Disable QTY field
                  SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY

                  SET @cBarcode = ''
                  SET @cOption = ''
                  
                  IF @cFieldAttr07 = 'O'
                     EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                  ELSE
                     EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY

                  -- Go to SKU QTY screen
                  SET @nAfterScn = @nScn_SKUQTY
                  SET @nAfterStep = @nStep_SKUQTY

                  SET @cUDF01 = @cOption
                  SET @cUDF02 = @cBarcode

               END -- ESC

               IF @nInputKey = 1 -- ENTER
               BEGIN

                  --screnn mapping
                  SET @cOption = @cInField01

                  --Set rdtmobrec value to the local parameter
                  SET @cSKU = @cSuggSKU
                  SET @cLOC = @cSuggLOC
                  SET @cID  =  @cSuggID

                  IF @nDebugFlag = 1
                     SELECT @cInField01 AS InField01, @cOption AS cOption

                  -- Validate blank
                  IF @cOption = ''
                  BEGIN
                     SET @nErrNo = 257901
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required
                     GOTO Scn_6823_Fail
                  END

                  -- Validate option
                  IF @cOption <> '1' AND
                     @cOption <> '2' AND
                     @cOption <> '3' AND  -- (ChewKP01)
                     @cOption <> '4' AND
                     @cOption <> '9'
                  BEGIN
                     SET @nErrNo = 257902
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                     GOTO Scn_6823_Fail
                  END

                  IF @cOption = '9'
                  BEGIN
                     --PickZone is not required in 839 but required in reallocation
                     --Get pickzone from suggested loc if pickzone is empty
                     IF @cPickZone = ''
                        SELECT @cPickZone = PickZone FROM dbo.Loc (NOLOCK) WHERE LOC = @cLOC
                     
                     IF ISNULL(@cPickZone, '') = ''
                     BEGIN
                        SET @nErrNo = 257904
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PickZone empty
                        GOTO Scn_6823_Fail
                     END
                  END

                  IF @cExtendedValidateSP <> ''
                  BEGIN
                     IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
                     BEGIN
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +
                           ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,@cPackData1, @cPackData2, @cPackData3,' +
                           ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                        SET @cSQLParam =
                           ' @nMobile      INT,           ' +
                           ' @nFunc        INT,           ' +
                           ' @cLangCode    NVARCHAR( 3),  ' +
                           ' @nStep        INT,           ' +
                           ' @nInputKey    INT,           ' +
                           ' @cFacility    NVARCHAR( 5) , ' +
                           ' @cStorerKey   NVARCHAR( 15), ' +
                           ' @cType        NVARCHAR( 10), ' +
                           ' @cPickSlipNo  NVARCHAR( 10), ' +
                           ' @cPickZone    NVARCHAR( 10), ' +
                           ' @cDropID      NVARCHAR( 20), ' +
                           ' @cLOC         NVARCHAR( 10), ' +
                           ' @cSKU         NVARCHAR( 20), ' +
                           ' @nQTY         INT,           ' +
                           ' @cPackData1      NVARCHAR( 30), ' +
                           ' @cPackData2      NVARCHAR( 30), ' +
                           ' @cPackData3      NVARCHAR( 30), ' +
                           ' @nErrNo       INT    OUTPUT, ' +
                           ' @cErrMsg      NVARCHAR(250) OUTPUT  '

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, '',
                           @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nActQTY,@cPackData1, @cPackData2, @cPackData3,
                           @nErrNo OUTPUT, @cErrMsg OUTPUT

                        IF @nErrNo <> 0
                           GOTO Scn_6823_Fail
                     END
                  END

                  /*
                     Option=1 = Short pick sku
                     Option=2 = Balance pick later, go to next sku or next loc or next zone
                     Option=3 = Close drop id
                     Option=9 = Reallocation
                  */
                  DECLARE @cConfirmType NVARCHAR( 10)
                  IF @cOption IN ( '1' , '9')
                     SET @cConfirmType = 'SHORT'
                  ELSE
                     SET @cConfirmType = 'CLOSE'

                  SET @nTranCount = @@TRANCOUNT
                  BEGIN TRAN
                  SAVE TRAN rdt_839ExtScn07_6823

                  -- Confirm ( Balance pick later proceed only when user do picked something)
                  -- For option = 4, need confirm first if something already picked
                  -- IF @cOption IN ('1', '3', '9') OR ( @cOption IN ( 2, 4) AND @nActQTY > 0)
                  IF @cOption IN ('1', '3','9') 
                  OR ( @cOption = '4' AND @nActQTY > 0) 
                  OR (@cOption = '2' AND @nActQTY > 0 AND @cSkipConfirmBalPick <> '1')     --(cc01)
                  BEGIN
                     DECLARE @nConfirmQTY INT = @nActQTY

                     IF @nDebugFlag = 1
                     BEGIN
                        SELECT 'Confirm logic', @cOption AS cOption, @nActQTY AS ActQTY, @nConfirmQTY AS ConfirmQty, @cSkipConfirmBalPick AS cSkipConfirmBalPick
                     END

                     IF @cSKUSerialNoCapture IN ('1', '3') 
                     BEGIN
                        IF @cOption IN ('1','9') -- Short
                        BEGIN
                           EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cConfirmType,
                              @cPickSlipNo
                              ,@cPickZone
                              ,@cDropID
                              ,@cSuggLOC
                              ,@cSuggSKU
                              ,0 -- @nActQTY, already confirm by piece earlier
                              ,@cLottableCode
                              ,@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05
                              ,@cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10
                              ,@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
                              ,@cPackData1,  @cPackData2,  @cPackData3
                              ,@cSuggID
                              ,@cSerialNo   = '' 
                              ,@nSerialQTY  = 0
                              ,@nBulkSNO    = 0
                              ,@nBulkSNOQTY = 0
                              ,@nErrNo      = @nErrNo  OUTPUT
                              ,@cErrMsg     = @cErrMsg OUTPUT
                           IF @nErrNo <> 0
                           BEGIN
                              ROLLBACK TRAN rdt_839ExtScn07_6823
                              WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                                 COMMIT TRAN
                              GOTO Scn_6823_Fail
                           END
                        END
                     END
                     ELSE
                     BEGIN
                        EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cConfirmType,
                           @cPickSlipNo
                           ,@cPickZone
                           ,@cDropID
                           ,@cSuggLOC
                           ,@cSuggSKU
                           ,@nActQTY
                           ,@cLottableCode
                           ,@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05
                           ,@cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10
                           ,@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
                           ,@cPackData1,  @cPackData2,  @cPackData3
                           ,@cSuggID
                           ,@cSerialNo   = '' 
                           ,@nSerialQTY  = 0
                           ,@nBulkSNO    = 0
                           ,@nBulkSNOQTY = 0
                           ,@nErrNo      = @nErrNo  OUTPUT
                           ,@cErrMsg     = @cErrMsg OUTPUT
                        IF @nErrNo <> 0
                        BEGIN
                           ROLLBACK TRAN rdt_839ExtScn07_6823
                           WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                              COMMIT TRAN
                           GOTO Scn_6823_Fail
                        END
                     END
                  END --Confirm logic

                  IF @cExtendedUpdateSP <> ''
                  BEGIN
                     IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                     BEGIN
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
                           ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, @cOption, @cLottableCode, ' +
                           ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                           ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                           ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                           ' @cPackData1,@cPackData2,@cPackData3, ' +
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
                           ',@cLOC            NVARCHAR( 10)            ' +
                           ',@cSKU            NVARCHAR( 20)            ' +
                           ',@nQTY            INT                      ' +
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
                           ',@cPackData1      NVARCHAR( 30)            ' +
                           ',@cPackData2      NVARCHAR( 30)            ' +
                           ',@cPackData3      NVARCHAR( 30)            ' +
                           ',@nErrNo          INT           OUTPUT     ' +
                           ',@cErrMsg         NVARCHAR(250) OUTPUT     '

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,
                           @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nActQTY, @cOption, @cLottableCode,
                           @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                           @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                           @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                           @cPackData1,@cPackData2,@cPackData3,
                           @nErrNo OUTPUT, @cErrMsg OUTPUT

                        IF @nErrNo <> 0
                        BEGIN
                           ROLLBACK TRAN rdt_839ExtScn07_6823
                           WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                              COMMIT TRAN
                           GOTO Scn_6823_Fail
                        END
                     END
                  END --extupdate
                  
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
                     DECLARE @tAdditionalData      [dbo].[VariableTable]


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
                     ' WHERE PD.PickSlipNo = @cPickSlipNo ' +
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

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @cLot OUTPUT, @cPickSlipNo, '', '', @cLOC, @cDropID, @cSKU, '5',
                        @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                        @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                        @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

                     IF @nDebugFlag = 1
                     BEGIN
                        SELECT 'Get lot number', @cLot AS Lot, @cSQL AS GetLotSQL
                     END

                     SET @cRealloPickSlipNo = @cPickSlipNo
                     SET @CRealloPickZone = @cPickZone
                     
                     EXECUTE [RDT].[rdt_PickReallo05] 
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
                        ,@nQTY = @nActQTY
                        ,@cLot = @cLot OUTPUT
                        ,@cPickZone = @cRealloPickZone OUTPUT
                        ,@cSuggestLOC = @cRealloLOC OUTPUT
                        ,@cSuggestID = @cRealloID OUTPUT
                        ,@nErrNo = @nErrNo OUTPUT
                        ,@cErrMsg = @cErrMsg OUTPUT
                     
                     IF @nErrNo <> 0
                     BEGIN
                        ROLLBACK TRAN rdt_839ExtScn07_6823
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN
                        
                        IF @nErrNo > 0
                        BEGIN
                           INSERT dbo.TraceInfo (TraceName, TimeIn, Step1, Step2, 
                              Step3, Step4, Step5,
                              Col1, Col2, Col3, Col4, Col5)
                           VALUES('rdt_839ExtScn07', GETDATE(), 'rdt_839ExtScn07', CAST(@nMobile AS NVARCHAR(10)), 
                              CAST(@nScn AS NVARCHAR(10)), CAST(@nErrNo AS NVARCHAR(10)), @cPickSlipNo,
                              @cSuggLoc, @cSuggSKU, @cSuggID, @cLot, CAST(@nActQTY AS NVARCHAR(10)))

                           SET @nErrNo = 257903
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reallocation failed

                           GOTO Scn_6823_Fail
                        END
                     END

                     -- loc found, prompt message
                     IF ISNULL(@cRealloLoc, '') <> ''
                     BEGIN
                        SET @cMsg01 = 'Alternate location '
                        SET @cMsg02 = 'found and is added '
                        SET @cMsg03 = 'to current pickslip'
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
                     END
                     ELSE -- Errno = -1
                     --No loc found
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

                        GOTO Scn_6823_Fail
                     END --Errno = -1
                  END --Option = 9

                  COMMIT TRAN rdt_839ExtScn07_6823 -- Only commit change made here
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN
                  
                  --Return values to main function

                  SET @cUDF01 = @cOption

                  IF @nDebugFlag = 1
                  BEGIN
                     SELECT 'Step99, Scn6823, inputkey=1 quit'
                     SELECT @cUDF01 AS UDF01
                  END
               END --Inputkey = 1

               Scn_6823_Quit:
                  GOTO Quit

               Scn_6823_Fail:
               BEGIN
                  -- Reset this screen var
                  SET @cOutField01 = '' --Option
                  GOTO Quit
               END
            END --6823
         END --step 99
      END

   END
   GOTO Quit

Quit:
   IF @nDebugFlag = 1
   BEGIN
      SELECT 'Exiting rdt_839ExtScn07'
      SELECT @nErrNo AS ErrNo, @cErrMsg AS ErrMsg, @nAfterScn AS AfterScn, @nAfterStep AS AfterStep
   END
END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_839ExtScn07 TO NSQL
GO
 
