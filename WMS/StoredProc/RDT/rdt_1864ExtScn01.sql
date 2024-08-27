
/****** Object:  StoredProcedure [RDT].[rdt_1864ExtScn01]    Script Date: 8/26/2024 17:50:00 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1864ExtScn01                                    */  
/*                                                                      */  
/* Purpose:       Peru - Hicense - Short Pick New Screen                */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2024-08-26 1.0  LJQ006     FCR-735 init                              */  
/************************************************************************/  
  
CREATE OR ALTER PROC  [RDT].[rdt_1864ExtScn01] (
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

   -- variables
   DECLARE
      @cOption        NVARCHAR( 1),
      @cSQL           NVARCHAR( MAX),
      @cSQLParam      NVARCHAR( MAX),
      @cBarcode       NVARCHAR( 60),
      @nMorePage      INT,
      @cPickSlipNo   NVARCHAR( 10),
      @cOrderKey     NVARCHAR( 10),
      @cLoadKey      NVARCHAR( 10),
      @cPickZone     NVARCHAR( 10),
      @cLOC          NVARCHAR( 10),
      @cID           NVARCHAR( 18),
      @cSKU          NVARCHAR( 20),
      @cSKUDescr     NVARCHAR( 60),
      @cPUOM         NVARCHAR( 1),
      @nPUOM_Div     INT,
      @nTaskQTY      INT,
      @nPTaskQTY     INT,
      @nMTaskQTY     INT,
      @cSuggLOC      NVARCHAR( 10),  
      @cSuggID       NVARCHAR( 18),  
      @cLottableCode NVARCHAR( 20),
      @cPUOM_Desc    NVARCHAR( 5),
      @cMUOM_Desc    NVARCHAR( 5),
      @cToLOC        NVARCHAR( 10),
      @cZone         NVARCHAR( 18),
      @cSuggToLOC    NVARCHAR( 10), 
      @cCheckDigitLOC NVARCHAR( 20),

      @cExtendedInfo       NVARCHAR( 20),
      @cExtendedInfoSP     NVARCHAR( 20),
      @cExtendedValidateSP NVARCHAR( 20),
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cAutoScanIn         NVARCHAR( 1),
      @cSuggestLOC         NVARCHAR( 1),   
      @cDecodeSP           NVARCHAR( 20),
      @cSwapIDSP           NVARCHAR( 20),
      @cDefaultToLOC       NVARCHAR( 10),
      @cMoveQTYAlloc       NVARCHAR( 1), 
      @cMoveQTYPick        NVARCHAR( 1), 
      @cVerifyPickZone     NVARCHAR( 1),
      @cSuggestToLOCSP     NVARCHAR( 20),
      @cOverrideToLOC      NVARCHAR( 20),
      @cLOCCheckDigitSP    NVARCHAR( 20),
      @cShortOption        NVARCHAR( 1),

      @cExtScnSP           NVARCHAR( 20),


   SET @nAfterScn = @nScn
   SET @nAfterStep = @nStep

   IF @nFunc = 1864
   BEGIN
      -- Getting Mobile information
      SELECT
         @nFunc            = Func,
         @nScn             = Scn,
         @nStep            = Step,
         @nInputKey        = InputKey,
         @nMenu            = Menu,
         @cLangCode        = Lang_code,

         @cStorerKey       = StorerKey,
         @cFacility        = Facility,

         @cPickSlipNo      = V_PickSlipNo,
         @cLoadKey         = V_LoadKey,
         @cOrderKey        = V_OrderKey,
         @cPickZone        = V_Zone,
         @cLOC             = V_LOC,
         @cID              = V_ID,
         @cSKU             = V_SKU,
         @cSKUDescr        = V_SKUDescr,
         @cPUOM            = V_UOM,
         @nPUOM_Div        = V_PUOM_Div, 
         @nTaskQTY         = V_TaskQTY,
         @nPTaskQTY        = V_PTaskQTY,
         @nMTaskQTY        = V_MTaskQTY,
         @cLottable01      = V_Lottable01,    
         @cLottable02      = V_Lottable02,    
         @cLottable03      = V_Lottable03,    
         @dLottable04      = V_Lottable04,    
         @dLottable05      = V_Lottable05,    
         @cLottable06      = V_Lottable06,    
         @cLottable07      = V_Lottable07,    
         @cLottable08      = V_Lottable08,    
         @cLottable09      = V_Lottable09,    
         @cLottable10      = V_Lottable10,    
         @cLottable11      = V_Lottable11,    
         @cLottable12      = V_Lottable12,    
         @dLottable13      = V_Lottable13,    
         @dLottable14      = V_Lottable14,    
         @dLottable15      = V_Lottable15,

         @cSuggLOC         = V_String1,
         @cSuggID          = V_String2,
         @cLottableCode    = V_String3,
         @cPUOM_Desc       = V_String4,
         @cMUOM_Desc       = V_String5,
         @cToLOC           = V_String6,
         @cZone            = V_String7,
         @cSuggToLOC       = V_String8,

         @cExtendedInfo       = V_String21,
         @cExtendedInfoSP     = V_String22,
         @cExtendedValidateSP = V_String23,
         @cExtendedUpdateSP   = V_String24,
         @cAutoScanIn         = V_String25,
         @cSuggestLOC         = V_String26,
         @cDecodeSP           = V_String27,
         @cSwapIDSP           = V_String28,
         @cDefaultToLOC       = V_String29,
         @cMoveQTYAlloc       = V_String30,
         @cMoveQTYPick        = V_String31,
         @cVerifyPickZone     = V_string32,
         @cSuggestToLOCSP     = V_string33,
         @cOverrideToLOC      = V_string34,
         @cLOCCheckDigitSP    = V_string35,
         @cShortOption        = V_string36,
         @cExtScnSP           = V_string37,

         @cBarcode            = V_String41,

         @cInField01 = I_Field01,   @cOutField01 = O_Field01,  @cFieldAttr01  = FieldAttr01,
         @cInField02 = I_Field02,   @cOutField02 = O_Field02,  @cFieldAttr02  = FieldAttr02,
         @cInField03 = I_Field03,   @cOutField03 = O_Field03,  @cFieldAttr03  = FieldAttr03,
         @cInField04 = I_Field04,   @cOutField04 = O_Field04,  @cFieldAttr04  = FieldAttr04,
         @cInField05 = I_Field05,   @cOutField05 = O_Field05,  @cFieldAttr05  = FieldAttr05,
         @cInField06 = I_Field06,   @cOutField06 = O_Field06,  @cFieldAttr06  = FieldAttr06,
         @cInField07 = I_Field07,   @cOutField07 = O_Field07,  @cFieldAttr07  = FieldAttr07,
         @cInField08 = I_Field08,   @cOutField08 = O_Field08,  @cFieldAttr08  = FieldAttr08,
         @cInField09 = I_Field09,   @cOutField09 = O_Field09,  @cFieldAttr09  = FieldAttr09,
         @cInField10 = I_Field10,   @cOutField10 = O_Field10,  @cFieldAttr10  = FieldAttr10,
         @cInField11 = I_Field11,   @cOutField11 = O_Field11,  @cFieldAttr11  = FieldAttr11,
         @cInField12 = I_Field12,   @cOutField12 = O_Field12,  @cFieldAttr12  = FieldAttr12,
         @cInField13 = I_Field13,   @cOutField13 = O_Field13,  @cFieldAttr13  = FieldAttr13,
         @cInField14 = I_Field14,   @cOutField14 = O_Field14,  @cFieldAttr14  = FieldAttr14,
         @cInField15 = I_Field15,   @cOutField15 = O_Field15,  @cFieldAttr15  = FieldAttr15
      FROM rdt.rdtMobRec (NOLOCK)
      WHERE  Mobile = @nMobile

      SET @cID = @cSuggID
      SET @cBarcode = @cID

      IF @nInputKey = 1
      BEGIN
         -- screen mapping
         SET @cOption = @cInField01
         -- Validate blank
         IF @cOption = ''
         BEGIN
            SET @nErrNo = 201673
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need option
            GOTO Short_Option_Fail
         END

         -- Validate option
         IF @cOption NOT IN ('1', '2')
         BEGIN
            SET @nErrNo = 201674
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
            GOTO Short_Option_Fail
         END

         -- Short Pick
         IF @cOption = '1'
         BEGIN
            -- short pick here
            DECLARE @cUPC      NVARCHAR( 30),
               @cChkLottable01 NVARCHAR( 18), @cChkLottable02 NVARCHAR( 18), @cChkLottable03 NVARCHAR( 18), @dChkLottable04 DATETIME,      @dChkLottable05 DATETIME,
               @cChkLottable06 NVARCHAR( 30), @cChkLottable07 NVARCHAR( 30), @cChkLottable08 NVARCHAR( 30), @cChkLottable09 NVARCHAR( 30), @cChkLottable10 NVARCHAR( 30),
               @cChkLottable11 NVARCHAR( 30), @cChkLottable12 NVARCHAR( 30), @dChkLottable13 DATETIME,      @dChkLottable14 DATETIME,      @dChkLottable15 DATETIME

            SELECT @cUPC       = '', 
               @cChkLottable01 = '', @cChkLottable02 = '', @cChkLottable03 = '',    @dChkLottable04 = NULL,  @dChkLottable05 = NULL,
               @cChkLottable06 = '', @cChkLottable07 = '', @cChkLottable08 = '',    @cChkLottable09 = '',    @cChkLottable10 = '',
               @cChkLottable11 = '', @cChkLottable12 = '', @dChkLottable13 = NULL,  @dChkLottable14 = NULL,  @dChkLottable15 = NULL

            IF @cDecodeSP <> ''
            BEGIN
               -- Standard decode
               IF @cDecodeSP = '1'

               BEGIN
                  EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                     @cID         = @cID            OUTPUT,
                     @cUPC        = @cUPC           OUTPUT,
                     @cLottable01 = @cChkLottable01 OUTPUT,
                     @cLottable02 = @cChkLottable02 OUTPUT,
                     @cLottable03 = @cChkLottable03 OUTPUT,
                     @dLottable04 = @dChkLottable04 OUTPUT,
                     @dLottable05 = @dChkLottable05 OUTPUT,
                     @cLottable06 = @cChkLottable06 OUTPUT,
                     @cLottable07 = @cChkLottable07 OUTPUT,
                     @cLottable08 = @cChkLottable08 OUTPUT,
                     @cLottable09 = @cChkLottable09 OUTPUT,
                     @cLottable10 = @cChkLottable10 OUTPUT,
                     @cLottable11 = @cChkLottable11 OUTPUT,
                     @cLottable12 = @cChkLottable12 OUTPUT,
                     @dLottable13 = @dChkLottable13 OUTPUT,
                     @dLottable14 = @dChkLottable14 OUTPUT,
                     @dLottable15 = @dChkLottable15 OUTPUT, 
                     @cType = 'ID'
               END
               ELSE
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cBarcode, @cPickSlipNo, ' +
                        ' @cLOC        OUTPUT, @cID         OUTPUT, @cUPC        OUTPUT, @nTaskQTY    OUTPUT, ' +
                        ' @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,' +
                        ' @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,' +
                        ' @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,' +
                        ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT, '            +
                        '@nFunc           INT, '            +
                        '@cLangCode       NVARCHAR( 3), '   +
                        '@nStep           INT, '            +
                        '@nInputKey       INT, '            +
                        '@cFacility       NVARCHAR( 5),  '  +
                        '@cStorerKey      NVARCHAR( 15), '  +
                        '@cBarcode        NVARCHAR( 60), '  +
                        '@cPickSlipNo     NVARCHAR( 10), '  +
                        '@cLOC            NVARCHAR( 10)  OUTPUT, ' +
                        '@cID             NVARCHAR( 18)  OUTPUT, ' +
                        '@cUPC            NVARCHAR( 30)  OUTPUT, ' +
                        '@nTaskQTY        INT            OUTPUT, ' +
                        '@cLottable01     NVARCHAR( 18)  OUTPUT, ' +
                        '@cLottable02     NVARCHAR( 18)  OUTPUT, ' +
                        '@cLottable03     NVARCHAR( 18)  OUTPUT, ' +
                        '@dLottable04     DATETIME       OUTPUT, ' +
                        '@dLottable05     DATETIME       OUTPUT, ' +
                        '@cLottable06     NVARCHAR( 30)  OUTPUT, ' +
                        '@cLottable07     NVARCHAR( 30)  OUTPUT, ' +
                        '@cLottable08     NVARCHAR( 30)  OUTPUT, ' +
                        '@cLottable09     NVARCHAR( 30)  OUTPUT, ' +
                        '@cLottable10     NVARCHAR( 30)  OUTPUT, ' +
                        '@cLottable11     NVARCHAR( 30)  OUTPUT, ' +
                        '@cLottable12     NVARCHAR( 30)  OUTPUT, ' +
                        '@dLottable13     DATETIME       OUTPUT, ' +
                        '@dLottable14     DATETIME       OUTPUT, ' +
                        '@dLottable15     DATETIME       OUTPUT, ' +
                        '@nErrNo          INT            OUTPUT, ' +
                        '@cErrMsg         NVARCHAR( 20)  OUTPUT  '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode, @cPickSlipNo,
                        @cLOC           OUTPUT, @cID            OUTPUT, @cUPC           OUTPUT, @nTaskQTY       OUTPUT, 
                        @cChkLottable01 OUTPUT, @cChkLottable02 OUTPUT, @cChkLottable03 OUTPUT, @dChkLottable04 OUTPUT, @dChkLottable05 OUTPUT,
                        @cChkLottable06 OUTPUT, @cChkLottable07 OUTPUT, @cChkLottable08 OUTPUT, @cChkLottable09 OUTPUT, @cChkLottable10 OUTPUT,
                        @cChkLottable11 OUTPUT, @cChkLottable12 OUTPUT, @dChkLottable13 OUTPUT, @dChkLottable14 OUTPUT, @dChkLottable15 OUTPUT,
                        @nErrNo         OUTPUT, @cErrMsg        OUTPUT

                     IF @nErrNo <> 0
                        GOTO ID_Fail
                  END
               END
            END

            -- Check decoded SKU
            IF @cUPC <> ''
            BEGIN
               DECLARE @bSuccess INT
               DECLARE @nSKUCnt INT
               EXEC RDT.rdt_GetSKUCNT
                   @cStorerKey  = @cStorerKey
                  ,@cSKU        = @cUPC
                  ,@nSKUCnt     = @nSKUCnt   OUTPUT
                  ,@bSuccess    = @bSuccess  OUTPUT
                  ,@nErr        = @nErrNo    OUTPUT
                  ,@cErrMsg     = @cErrMsg   OUTPUT

               -- Check SKU valid
               IF @nSKUCnt = 0
               BEGIN
                  SET @nErrNo = 201679
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
                  GOTO ID_Fail
               END

               -- Check barcode return multiple SKU
               IF @nSKUCnt > 1
               BEGIN
                  SET @nErrNo = 201680
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod
                  GOTO ID_Fail
               END

               -- Get SKU
               EXEC rdt.rdt_GetSKU
                   @cStorerKey  = @cStorerKey
                  ,@cSKU        = @cUPC      OUTPUT
                  ,@bSuccess    = @bSuccess  OUTPUT
                  ,@nErr        = @nErrNo    OUTPUT
                  ,@cErrMsg     = @cErrMsg   OUTPUT

               -- Validate SKU
               IF @cSKU <> @cUPC
               BEGIN
                  SET @nErrNo = 201681
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong SKU
                  GOTO ID_Fail
               END
            END

            -- Check lottables
            IF @cLottable01 <> '' AND @cChkLottable01 <> '' AND @cLottable01 <> @cChkLottable01 SET @nErrNo = 201682 ELSE
            IF @cLottable02 <> '' AND @cChkLottable02 <> '' AND @cLottable02 <> @cChkLottable02 SET @nErrNo = 201683 ELSE
            IF @cLottable03 <> '' AND @cChkLottable03 <> '' AND @cLottable03 <> @cChkLottable03 SET @nErrNo = 201684 ELSE
            IF (@dLottable04 <> 0 AND @dLottable04 IS NOT NULL) AND (@dChkLottable04 <> 0 AND @dChkLottable04 IS NOT NULL) AND @dLottable04 <> @dChkLottable04 SET @nErrNo = 201685 ELSE
            IF (@dLottable05 <> 0 AND @dLottable05 IS NOT NULL) AND (@dChkLottable05 <> 0 AND @dChkLottable05 IS NOT NULL) AND @dLottable05 <> @dChkLottable05 SET @nErrNo = 201686 ELSE
            IF @cLottable06 <> '' AND @cChkLottable06 <> '' AND @cLottable06 <> @cChkLottable06 SET @nErrNo = 201687 ELSE
            IF @cLottable07 <> '' AND @cChkLottable07 <> '' AND @cLottable07 <> @cChkLottable07 SET @nErrNo = 201688 ELSE
            IF @cLottable08 <> '' AND @cChkLottable08 <> '' AND @cLottable08 <> @cChkLottable08 SET @nErrNo = 201689 ELSE
            IF @cLottable09 <> '' AND @cChkLottable09 <> '' AND @cLottable09 <> @cChkLottable09 SET @nErrNo = 201690 ELSE
            IF @cLottable10 <> '' AND @cChkLottable10 <> '' AND @cLottable10 <> @cChkLottable10 SET @nErrNo = 201691 ELSE
            IF @cLottable11 <> '' AND @cChkLottable11 <> '' AND @cLottable11 <> @cChkLottable11 SET @nErrNo = 201692 ELSE
            IF @cLottable12 <> '' AND @cChkLottable12 <> '' AND @cLottable12 <> @cChkLottable12 SET @nErrNo = 201693 ELSE
            IF (@dLottable13 <> 0 AND @dLottable13 IS NOT NULL) AND (@dChkLottable13 <> 0 AND @dChkLottable13 IS NOT NULL) AND @dLottable13 <> @dChkLottable13 SET @nErrNo = 201694 ELSE
            IF (@dLottable14 <> 0 AND @dLottable14 IS NOT NULL) AND (@dChkLottable14 <> 0 AND @dChkLottable14 IS NOT NULL) AND @dLottable14 <> @dChkLottable14 SET @nErrNo = 201695 ELSE
            IF (@dLottable15 <> 0 AND @dLottable15 IS NOT NULL) AND (@dChkLottable15 <> 0 AND @dChkLottable15 IS NOT NULL) AND @dLottable15 <> @dChkLottable15 SET @nErrNo = 201696
            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Different L0X
               GOTO ID_Fail
            END

            -- Suggest TO LOC
            SET @cSuggToLOC = ''
            IF @cSuggestToLOCSP <> ''
            BEGIN
               IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cSuggestToLOCSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cSuggestToLOCSP) + 
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
                     ' @cPickSlipNo, @cPickZone, @cLOC, @cID, @cSKU, @nTaskQTY, ' +
                     ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' + 
                     ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' + 
                     ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' + 
                     ' @cSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
                  SET @cSQLParam = 
                     ' @nMobile       INT,           ' + 
                     ' @nFunc         INT,           ' + 
                     ' @cLangCode     NVARCHAR( 3),  ' + 
                     ' @nStep         INT,           ' + 
                     ' @nInputKey     INT,           ' + 
                     ' @cFacility     NVARCHAR( 5),  ' + 
                     ' @cStorerKey    NVARCHAR( 15), ' + 
                     ' @cPickSlipNo   NVARCHAR( 10), ' + 
                     ' @cPickZone     NVARCHAR( 10), ' + 
                     ' @cLOC          NVARCHAR( 10), ' + 
                     ' @cID           NVARCHAR( 18), ' + 
                     ' @cSKU          NVARCHAR( 20), ' + 
                     ' @nTaskQTY      INT,           ' + 
                     ' @cLottable01   NVARCHAR( 18), ' + 
                     ' @cLottable02   NVARCHAR( 18), ' + 
                     ' @cLottable03   NVARCHAR( 18), ' + 
                     ' @dLottable04   DATETIME,      ' + 
                     ' @dLottable05   DATETIME,      ' + 
                     ' @cLottable06   NVARCHAR( 30), ' + 
                     ' @cLottable07   NVARCHAR( 30), ' + 
                     ' @cLottable08   NVARCHAR( 30), ' + 
                     ' @cLottable09   NVARCHAR( 30), ' + 
                     ' @cLottable10   NVARCHAR( 30), ' + 
                     ' @cLottable11   NVARCHAR( 30), ' + 
                     ' @cLottable12   NVARCHAR( 30), ' + 
                     ' @dLottable13   DATETIME,      ' + 
                     ' @dLottable14   DATETIME,      ' + 
                     ' @dLottable15   DATETIME,      ' + 
                     ' @cSuggToLOC    NVARCHAR( 10) OUTPUT, ' + 
                     ' @nErrNo        INT           OUTPUT, ' + 
                     ' @cErrMsg       NVARCHAR( 20) OUTPUT  ' 
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                     @cPickSlipNo, @cPickZone, @cLOC, @cID, @cSKU, @nTaskQTY, 
                     @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, 
                     @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, 
                     @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, 
                     @cSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT 
                  IF @nErrNo <> 0
                     GOTO Quit
               END
               ELSE
                  SET @cSuggToLOC = @cSuggestToLOCSP
            END

            -- Confirm
            EXECUTE rdt.rdt_PickPallet_ConfirmShort @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 
               @cPickSlipNo, @cPickZone, @cLOC, @cID, @cSKU, @nTaskQTY, @cToLOC, @cLottableCode, 
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, 
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, 
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, 
               @nErrNo OUTPUT, @cErrMsg OUTPUT 
            IF @nErrNo <> 0
               GOTO Quit

            -- Go to next screen
            EXEC rdt.rdt_PickPallet_GoToNextScreen @nMobile, @nFunc, @cLangCode, @nInputKey, @cFacility, @cStorerKey, 
               @cPUOM, @cPickSlipNo, @cPickZone, @cLOC, @cID, 
               @cSuggLOC   OUTPUT,  @cSuggID     OUTPUT,  @cSKU         OUTPUT,    
               @nTaskQTY   OUTPUT,  @nPTaskQTY   OUTPUT,  @nMTaskQTY    OUTPUT,  @cLottableCode OUTPUT,
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
               @nStep      OUTPUT,  @nScn        OUTPUT,  @nErrNo       OUTPUT,  @cErrMsg       OUTPUT
            
            SET @nAfterScn = @nScn
            SET @nAfterStep = @nStep

            UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
               EditDate = GETDATE(),
               ErrMsg = @cErrMsg,
               Func   = @nFunc,

               V_SKU = @cSKU,
               V_TaskQTY = @nTaskQTY,
               V_LOC = @cLOC,
               V_ID = @cID,
               V_String8 = @cSuggToLOC,
               V_MTaskQTY = @nMTaskQTY,
               V_PTaskQTY = @nPTaskQTY,
               V_String3 = @cLottableCode,
               V_SKUDescr = @cSKUDescr,
               V_String5 = @cMUOM_Desc,
               V_String4 = @cPUOM_Desc,
               V_PUOM_Div = @nPUOM_Div,
            WHERE Mobile = @nMobile

         END

         -- Skip Task
         IF @cOption = '2'
         BEGIN
            -- skip task here
            -- Go to next screen
            EXEC rdt.rdt_PickPallet_GoToNextScreen @nMobile, @nFunc, @cLangCode, @nInputKey, @cFacility, @cStorerKey, 
               @cPUOM, @cPickSlipNo, @cPickZone, @cLOC, @cID, 
               @cSuggLOC   OUTPUT,  @cSuggID     OUTPUT,  @cSKU         OUTPUT,    
               @nTaskQTY   OUTPUT,  @nPTaskQTY   OUTPUT,  @nMTaskQTY    OUTPUT,  @cLottableCode OUTPUT,
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
               @nStep      OUTPUT,  @nScn        OUTPUT,  @nErrNo       OUTPUT,  @cErrMsg       OUTPUT

            SET @nAfterScn = @nScn
            SET @nAfterStep = @nStep

            -- Extended Info
            IF @cExtendedInfoSP <> ''
            BEGIN
               IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
               BEGIN
                  SET @cExtendedInfo = ''
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) + 
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, ' +
                     ' @cPickSlipNo, @cPickZone, @cSuggLOC, @cLOC, @cID, @cSKU, ' +
                     ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' + 
                     ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' + 
                     ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' + 
                     ' @nTaskQTY, @cToLOC, @cOption, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
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
                     '@cSuggLOC      NVARCHAR( 10), ' +
                     '@cLOC          NVARCHAR( 10), ' +
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
                     '@cToLOC        NVARCHAR( 10), ' +
                     '@cOption       NVARCHAR( 1),  ' +
                     '@cExtendedInfo NVARCHAR( 20) OUTPUT, ' +
                     '@nErrNo        INT           OUTPUT, ' +
                     '@cErrMsg       NVARCHAR( 20) OUTPUT  '
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @nMobile, 
                     @nFunc, @cLangCode, @nStep_SkipTask, @nStep, @nInputKey, @cFacility, @cStorerKey, 
                     @cPickSlipNo, @cPickZone, @cSuggLOC, @cLOC, @cID, @cSKU, 
                     @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, 
                     @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, 
                     @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, 
                     @nTaskQTY, @cToLOC, @cOption, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit

                  IF @cExtendedInfo <> ''
                     IF @nStep = @nStep_ID
                        SET @cOutField15 = @cExtendedInfo
               END
            END
            
            UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
               EditDate = GETDATE(),
               ErrMsg = @cErrMsg,
               Func   = @nFunc,
               
               V_SKU = @cSKU,
               V_TaskQTY = @nTaskQTY,
               V_LOC = @cLOC,
               V_ID = @cID,
               V_MTaskQTY = @nMTaskQTY,
               V_PTaskQTY = @nPTaskQTY,
               V_String3 = @cLottableCode,
               V_SKUDescr = @cSKUDescr,
               V_String5 = @cMUOM_Desc,
               V_String4 = @cPUOM_Desc,
               V_PUOM_Div = @nPUOM_Div,
            WHERE Mobile = @nMobile
         END
         GOTO Quit
      END

      IF @nInputKey = 0 -- ESC
      BEGIN
         -- Go to ID screen
         SET @nScn = @nScn_ID
         SET @nStep = @nStep_ID
      END
      GOTO Quit

      Short_Option_Fail:
      BEGIN
         SET @cOutField01 = '' -- Option
         GOTO Quit
      END
   END

   ID_Fail:
   BEGIN
      SET @cOutField14 = '' -- ID
      GOTO Quit
   END

Quit:
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_1864ExtScn01 TO NSQL
GO
 
