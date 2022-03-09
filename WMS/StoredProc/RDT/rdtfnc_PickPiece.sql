
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO    
      
/******************************************************************************/        
/* Store procedure: rdtfnc_PickPiece                                          */        
/* Copyright      : LFLogistics                                               */        
/*                                                                            */        
/* Date         Rev  Author      Purposes                                     */        
/* 2016-11-09   1.0  Ung         SOS368792 Created                            */        
/* 2016-07-26   1.1  Ung         SOS374283 Add DropID, confirm LOC            */        
/*                               Remove message screen                        */        
/* 2018-03-06   1.2  ChewKP      WMS-4093 Add Close DropID Option (ChewKP01)  */        
/* 2018-06-14   1.3  James       WMS-5407 Modify rdt_decode (james02)         */        
/* 2018-08-28   1.4  ChewKP      Bug Fixes (ChewKP02)                         */        
/* 2018-09-06   1.5  Ung         WMS-6238 Further fixes for ver 1.4           */        
/* 2018-10-29   1.6  Gan         Performance tuning                           */        
/* 2018-05-21   1.7  James       WMS-5057 Add dynamic lottable (james01)      */        
/* 2018-09-06   1.8  ChewKP      WMS-4542 Add Default PickZone, ExtendInfoSP  */        
/*                               config, Implement ExtendedValidateSP         */                
/*                               on Step 2 (ChewKP04)                         */         
/* 2018-10-11   1.9  ChewKP      WMS-5156 Add ExtendedUpdateSP Scn2 (ChewKP05)*/         
/* 2019-06-14   2.0  James       WMS9209 Rearrange display @ scn3 (james02)   */        
/*                               Extend @cPickZone variable                   */        
/*                               Add ABORT screen                             */        
/* 2019-07-10   2.1  James       INC0764433 - Add missing lottable display    */        
/*                               Bug fix on @cSuggSKU usage for ExtSP(james03)*/        
/* 2019-08-21   2.2  James       WMS-10241 Add ExtendedInfoSP @step3 (james04)*/        
/* 2019-09-04   2.3  YeeKung     WMS-10357 Add Balance SKU qty (yeekung01)    */        
/* 2020-01-02   2.4  YeeKung     Fix Bugs (yeekung02)                         */         
/* 2020-01-21   2.5  James       WMS-11654 Revamp short pick option (james05) */        
/* 2020-03-31   2.6  James       WMS-12707 Add config determine Pickzone      */        
/*                               is mandatory (james06)                       */        
/* 2020-08-13   2.7  YeeKung     WMS-14630 Add CartonID screen (yeekung03)    */        
/* 2020-09-10   2.8  Pakyuen     INC1286925 - Changed to nvarchar(6)          */          
/* 2021-01-08   2.9  James       WMS-15993 Enhance BalPickLater (james07)     */        
/* 2021-01-20   3.0  James       WMS-15754 Add Option Skip Loc (james08)      */        
/*                               Add config to remove usage of keyword 99     */        
/* 2021-03-30   3.1  LZG         INC1461882 - Reduced Qty when scan (ZG01)    */      
/* 2020-10-12   3.2  James       WMS-14522 Add ExtendedSKUInfo (james08)      */      
/* 2021-04-30   3.3  Chermaine   WMS-16868 Add Config to skip confirm op2 (cc01)*/      
/* 2021-11-09   3.4  James       WMS-18174 Clear variable b4 gettask (james09)*/      
/* 2021-11-09   3.5  James       WMS-18293 Allow MultiSKUBarcode (james10)    */      
/******************************************************************************/        
        
CREATE OR ALTER PROC [RDT].[rdtfnc_PickPiece] (        
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
   @bSuccess   INT,        
   @nTranCount INT,        
   @cOption    NVARCHAR( 1),        
   @cSQL  NVARCHAR( MAX),        
   @cSQLParam  NVARCHAR( MAX)        
        
-- RDT.RDTMobRec variables        
DECLARE        
   @nFunc        INT,        
   @nScn           INT,        
   @nStep          INT,        
   @cLangCode      NVARCHAR( 3),        
   @nInputKey      INT,       
   @nMenu          INT,        
        
   @cStorerKey     NVARCHAR( 15),        
   @cUserName      NVARCHAR( 18),        
   @cFacility      NVARCHAR( 5),        
        
   @cLoadKey       NVARCHAR( 10),        
   @cOrderKey      NVARCHAR( 10),        
   @cPickSlipNo    NVARCHAR( 10),        
   @cPickZone      NVARCHAR( 10),        
   @cSuggLOC       NVARCHAR( 10),        
   @cSuggSKU       NVARCHAR( 20),        
   @cSKUDescr      NVARCHAR( 60),        
   @nSuggQTY       INT,        
   @nTtlBalQty     INT,            
   @nBalQty        INT,            
        
   @cZone          NVARCHAR( 18),        
   @cSKUValidated  NVARCHAR( 2),        
   @nActQTY        INT,        
   @cDropID        NVARCHAR( 20),        
        
   @cExtendedValidateSP NVARCHAR( 20),        
   @cExtendedUpdateSP   NVARCHAR( 20),        
   @cExtendedInfoSP     NVARCHAR( 20),        
   @cExtendedInfo       NVARCHAR( 20),        
   @cDecodeSP           NVARCHAR( 20),        
   @cDefaultQTY         NVARCHAR( 1),        
   @cAllowSkipLOC       NVARCHAR( 1),        
   @cConfirmLOC         NVARCHAR( 1),        
   @cDisableQTYField    NVARCHAR( 1),        
   @cPickConfirmStatus  NVARCHAR( 1),        
   @cAutoScanOut        NVARCHAR( 1),        
   @cType               NVARCHAR( 10),        
   @cBarcode            NVARCHAR( 60),        
   @cUPC                NVARCHAR( 30),        
   @cSKU                NVARCHAR( 20),        
   @cQTY                NVARCHAR( 6),        
   @nQTY                INT,        
   @nMorePage           INT,        
   @nLottableOnPage     INT,        
   @cLottableCode       NVARCHAR( 30),         
   @cDefaultPickZone    NVARCHAR(1),            
   @cCurrSKU            NVARCHAR( 20),        
   @cSkippedSKU         NVARCHAR( 20),        
   @cCurrLOC            NVARCHAR( 10),        
   @cPickZoneMandatory  NVARCHAR( 1),        
   @cCartonID           NVARCHAR( 20),        
   @cScanCIDSCN         NVARCHAR( 1),        
   @cDecodeIDSP         NVARCHAR(20),        
   @cSuggID             NVARCHAR(20),        
   @cDefaultSKU         NVARCHAR(20),        
   @cDefaultPickQTY     NVARCHAR( 5),        
   @cDiscardKeyword99   NVARCHAR( 5),        
   @cExtSkuInfoSP       NVARCHAR( 20),      
   @cExtDescr1          NVARCHAR( 20),      
   @cExtDescr2          NVARCHAR( 20),      
   @cSkipConfirmBalPick NVARCHAR( 1), --(cc01)      
   @cMultiSKUBarcode    NVARCHAR( 1),      
   @nFromScn            INT,      
   @nFromStep           INT,      
         
   @cLottable01 NVARCHAR( 18),      @cLottable02 NVARCHAR( 18),      @cLottable03 NVARCHAR( 18),        
   @dLottable04 DATETIME,           @dLottable05 DATETIME,           @cLottable06 NVARCHAR( 30),        
   @cLottable07 NVARCHAR( 30),      @cLottable08 NVARCHAR( 30),      @cLottable09 NVARCHAR( 30),        
   @cLottable10 NVARCHAR( 30),      @cLottable11 NVARCHAR( 30),      @cLottable12 NVARCHAR( 30),        
   @dLottable13 DATETIME,           @dLottable14 DATETIME,           @dLottable15 DATETIME,        
        
   @cChkLottable01 NVARCHAR( 18),   @cChkLottable02 NVARCHAR( 18),   @cChkLottable03 NVARCHAR( 18),         
   @dChkLottable04 DATETIME,        @dChkLottable05 DATETIME,        @cChkLottable06 NVARCHAR( 30),         
   @cChkLottable07 NVARCHAR( 30),   @cChkLottable08 NVARCHAR( 30),   @cChkLottable09 NVARCHAR( 30),         
   @cChkLottable10 NVARCHAR( 30),   @cChkLottable11 NVARCHAR( 30),   @cChkLottable12 NVARCHAR( 30),         
   @dChkLottable13 DATETIME,        @dChkLottable14 DATETIME,        @dChkLottable15 DATETIME,        
        
   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),    @cFieldAttr01 NVARCHAR( 1),        
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),    @cFieldAttr02 NVARCHAR( 1),           @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),    @cFieldAttr03 NVARCHAR( 1),        
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),    @cFieldAttr04 NVARCHAR( 1),        
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),    @cFieldAttr05 NVARCHAR( 1),        
  @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),    @cFieldAttr06 NVARCHAR( 1),        
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),    @cFieldAttr07 NVARCHAR( 1),        
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),    @cFieldAttr08 NVARCHAR( 1),        
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),    @cFieldAttr09 NVARCHAR( 1),        
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),    @cFieldAttr10 NVARCHAR( 1),        
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),    @cFieldAttr11 NVARCHAR( 1),        
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),    @cFieldAttr12 NVARCHAR( 1),        
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),    @cFieldAttr13 NVARCHAR( 1),        
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),    @cFieldAttr14 NVARCHAR( 1),        
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),    @cFieldAttr15 NVARCHAR( 1)        
        
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
   @cUserName        = UserName,        
        
   @cLoadKey         = V_LoadKey,        
   @cOrderKey        = V_OrderKey,        
   @cPickZone        = V_Zone,        
   @cPickSlipNo      = V_PickSlipNo,        
   @cSuggLOC         = V_LOC,        
   @cSuggSKU         = V_SKU,        
   @cSKUDescr        = V_SKUDescr,        
   @nSuggQTY         = V_QTY,        
           
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
        
   @nFromStep        = V_FromStep,        
   @nFromScn         = V_FromScn,        
        
   @nActQTY          = V_Integer1,        
   @nTtlBalQty       = V_Integer2,        
   @nBalQty          = V_Integer3,        
           
   @cZone            = V_String1,        
   @cSKUValidated    = V_String2,        
   @cMultiSKUBarcode = V_String3,      
   @cDropID          = V_String4,        
   @cCurrSKU         = V_String5,        
   @cLottableCode    = V_String6,        
   @cCurrLOC         = V_String7,        
   @cSkippedSKU      = V_String8,        
   @cPickZoneMandatory  = V_String9,        
   @cDefaultPickQTY     = V_String10,        
   @cDiscardKeyword99   = V_String11,        
   @cExtDescr1        = V_String12,      
   @cExtDescr2        = V_String13,      
   @cSkipConfirmBalPick = V_String14, --(cc01)      
         
   @cExtendedValidateSP = V_String21,        
   @cExtendedUpdateSP   = V_String22,        
   @cExtendedInfoSP     = V_String23,        
   @cExtendedInfo       = V_String24,        
   @cDecodeSP           = V_String25,        
   @cDefaultQTY         = V_String27,        
   @cAllowSkipLOC       = V_String28,        
   @cConfirmLOC         = V_String29,        
   @cDisableQTYField    = V_String30,        
   @cPickConfirmStatus  = V_String31,        
   @cAutoScanOut        = V_String32,        
   @cDefaultPickZone    = V_String33,             
   @cExtendedInfo       = V_String34,        
   @cCartonID           = V_String35,  --(yeekung02)          
   @cScanCIDSCN         = V_String36, --(yeekung02)        
   @cDecodeIDSP         = V_String37, --(yeekung02)        
   @cSuggID             = V_String38,        
   @cDefaultSKU         = V_String39,        
   @cExtSkuInfoSP       = V_String40,  -- (james08)      
         
   @cInField01 = I_Field01, @cOutField01 = O_Field01,  @cFieldAttr01 = FieldAttr01,        
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
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,  @cFieldAttr15 = FieldAttr15        
        
FROM rdt.rdtMobRec WITH (NOLOCK)        
WHERE Mobile = @nMobile        
        
IF @nFunc = 839 -- Pick piece        
BEGIN        
   -- Redirect to respective screen        
   IF @nStep = 0  GOTO Step_0  -- Menu. Func = 839        
   IF @nStep = 1  GOTO Step_1  -- Scn = 4640. PickSlipNo        
   IF @nStep = 2  GOTO Step_2  -- Scn = 4641. PickZone, DropID        
   IF @nStep = 3  GOTO Step_3  -- Scn = 4642. SKU QTY        
   IF @nStep = 4  GOTO Step_4  -- Scn = 4643. No more task in LOC        
   IF @nStep = 5  GOTO Step_5  -- Scn = 4644. Confrim Short Pick?        
   IF @nStep = 6  GOTO Step_6  -- Scn = 4645. Skip LOC?        
   IF @nStep = 7  GOTO Step_7  -- Scn = 4646. Confirm LOC        
   IF @nStep = 8  GOTO Step_8  -- Scn = 4647. Abort Picking?        
   IF @nStep = 9  GOTO Step_9  -- Scn = 4648. CartonID        
   IF @nStep = 10 GOTO Step_10 -- Scn = 3570 Multi SKU selection        
END        
RETURN -- Do nothing if incorrect step        
        
        
/********************************************************************************        
Step_0. Func = 839        
********************************************************************************/        
Step_0:        
BEGIN        
   -- Get storer configure        
   SET @cAllowSkipLOC = rdt.rdtGetConfig( @nFunc, 'AllowSkipLOC', @cStorerKey)        
   SET @cConfirmLOC = rdt.rdtGetConfig( @nFunc, 'ConfirmLOC', @cStorerKey)        
   SET @cDefaultQTY = rdt.rdtGetConfig( @nFunc, 'DefaultQTY', @cStorerKey)        
        
   SET @cDecodeSP = rdt.rdtGetConfig( @nFunc, 'DecodeSP', @cStorerKey)        
   IF @cDecodeSP = '0'        
      SET @cDecodeSP = ''        
   SET @cExtendedValidateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)        
   IF @cExtendedValidateSP = '0'        
      SET @cExtendedValidateSP = ''        
   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)        
   IF @cExtendedUpdateSP = '0'        
      SET @cExtendedUpdateSP = ''        
   SET @cExtendedInfoSP = rdt.rdtGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)        
   IF @cExtendedInfoSP = '0'        
      SET @cExtendedInfoSP = ''      
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)        
   IF @cPickConfirmStatus = '0'        
      SET @cPickConfirmStatus = '5'        
           
   -- (yeekung01)                           
   SET @cScanCIDSCN = rdt.RDTGetConfig( @nFunc, 'ScanCartonIDScn', @cStorerkey)                            
   IF @cScanCIDSCN = '0'                          
    SET @cScanCIDSCN = ''         
   SET @cDecodeIDSP = rdt.RDTGetConfig( @nFunc, 'DecodeIDSP', @cStorerkey)                            
   IF @cDecodeIDSP = '0'                          
    SET @cDecodeIDSP = ''         
        
   -- (ChewKP04)             
   SET @cDefaultPickZone = rdt.rdtGetConfig( @nFunc, 'DefaultPickZone', @cStorerKey)                
   IF @cDefaultPickZone = '0'                
      SET @cDefaultPickZone = ''                
        
   -- (james06)        
   SET @cPickZoneMandatory = rdt.rdtGetConfig( @nFunc, 'PickZoneMandatory', @cStorerKey)        
           
   -- (james07)        
   SET @cDefaultPickQTY = rdt.rdtGetConfig( @nFunc, 'DefaultPickQTY', @cStorerKey)        
           
   -- (james07)        
   SET @cDiscardKeyword99 = rdt.rdtGetConfig( @nFunc, 'DiscardKeyword99', @cStorerKey)        
      
   -- (james08)      
   SET @cExtSkuInfoSP = rdt.rdtGetConfig( @nFunc, 'ExtSkuInfoSP', @cStorerKey)      
   IF @cExtSkuInfoSP = '0'      
      SET @cExtSkuInfoSP = ''      
            
   --(cc01)       
   SET @cSkipConfirmBalPick = rdt.rdtGetConfig( @nFunc, 'SkipConfirmBalPick', @cStorerKey)      
   IF @cSkipConfirmBalPick = '0'      
      SET @cSkipConfirmBalPick = ''      
      
   SET @cMultiSKUBarcode = rdt.RDTGetConfig( @nFunc, 'MultiSKUBarcode', @cStorerKey)      
      
   -- EventLog        
   EXEC RDT.rdt_STD_EventLog        
      @cActionType = '1', -- Sign-in        
      @cUserID     = @cUserName,        
      @nMobileNo   = @nMobile,        
      @nFunctionID = @nFunc,        
      @cFacility   = @cFacility,        
      @cStorerKey  = @cStorerKey,        
      @nStep       = @nStep        
        
   -- Prepare next screen var        
 SET @cOutField01 = '' -- PickSlipNo        
 SET @nTtlBalQty  = 0            
 SET @nBalQty      = 0            
        
   -- Go to PickSlipNo screen        
   SET @nScn = 4640        
   SET @nStep = 1        
END        
GOTO Quit        
        
        
/************************************************************************************        
Scn = 4640. PickSlipNo screen        
   PSNO    (field01)        
************************************************************************************/        
Step_1:        
BEGIN        
   IF @nInputKey = 1 -- ENTER        
   BEGIN        
      -- Screen mapping        
      SET @cPickSlipNo = @cInField01        
        
      -- Check blank        
      IF @cPickSlipNo = ''        
      BEGIN        
         SET @nErrNo = 100051        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PSNO required        
         GOTO Step_1_Fail        
      END        
        
      SET @cOrderKey = ''        
      SET @cLoadKey = ''        
      SET @cZone = ''        
        
      -- Get PickHeader info        
      SELECT TOP 1        
         @cOrderKey = OrderKey,        
         @cLoadKey = ExternOrderKey,        
         @cZone = Zone        
      FROM dbo.PickHeader WITH (NOLOCK)        
     WHERE PickHeaderKey = @cPickSlipNo        
        
      -- Cross dock PickSlip        
      IF @cZone IN ('XD', 'LB', 'LP')        
      BEGIN        
         -- Check PickSlipNo valid        
         IF NOT EXISTS( SELECT TOP 1 1 FROM dbo.RefKeyLookup RKL WITH (NOLOCK) WHERE RKL.PickSlipNo = @cPickSlipNo)        
         BEGIN        
            SET @nErrNo = 100052        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO        
            GOTO Step_1_Fail        
         END        
        
         -- Check diff storer        
         IF EXISTS( SELECT TOP 1 1        
            FROM dbo.RefKeyLookup RKL WITH (NOLOCK)        
               JOIN dbo.Orders O WITH (NOLOCK) ON (O.OrderKey = RKL.Orderkey)        
            WHERE RKL.PickSlipNo = @cPickSlipNo        
               AND O.StorerKey <> @cStorerKey)        
         BEGIN        
            SET @nErrNo = 100053        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer        
            GOTO Step_1_Fail        
         END        
      END        
        
      -- Discrete PickSlip        
      ELSE IF @cOrderKey <> ''        
      BEGIN        
         DECLARE @cChkStorerKey NVARCHAR( 15)        
         DECLARE @cChkStatus    NVARCHAR( 10)        
        
         -- Get Order info        
         SELECT        
            @cChkStorerKey = StorerKey,        
            @cChkStatus = Status        
         FROM dbo.Orders WITH (NOLOCK)        
         WHERE OrderKey = @cOrderKey        
        
         -- Check PickSlipNo valid        
         IF @@ROWCOUNT = 0        
         BEGIN        
            SET @nErrNo = 100054        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO        
            GOTO Step_1_Fail        
         END        
        
         -- Check order shipped        
         IF @cChkStatus >= '5'        
         BEGIN        
            SET @nErrNo = 100055        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order picked        
            GOTO Step_1_Fail        
         END        
        
         -- Check storer        
         IF @cChkStorerKey <> @cStorerKey        
         BEGIN        
            SET @nErrNo = 100056        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff storer        
            GOTO Step_1_Fail        
         END        
      END        
        
      -- Conso PickSlip        
      ELSE IF @cLoadKey <> ''        
      BEGIN        
         -- Check PickSlip valid        
         IF NOT EXISTS( SELECT TOP 1 1 FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) WHERE LPD.LoadKey = @cLoadKey)        
         BEGIN        
            SET @nErrNo = 100057        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO        
            GOTO Step_1_Fail        
         END        
/*        
         -- Check order shipped        
         IF EXISTS( SELECT TOP 1 1        
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)        
               JOIN dbo.Orders O (NOLOCK) ON (LPD.OrderKey = O.OrderKey)        
            WHERE LPD.LoadKey = @cLoadKey        
               AND O.Status >= '5')        
         BEGIN        
            SET @nErrNo = 100058        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order picked        
            GOTO Step_1_Fail        
         END        
*/        
         -- Check diff storer        
         IF EXISTS( SELECT TOP 1 1        
            FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)        
               JOIN dbo.Orders O (NOLOCK) ON (LPD.OrderKey = O.OrderKey)        
            WHERE LPD.LoadKey = @cLoadKey        
               AND O.StorerKey <> @cStorerKey)        
         BEGIN        
            SET @nErrNo = 100059        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer        
            GOTO Step_1_Fail        
         END        
      END        
        
      -- Custom PickSlip        
      ELSE        
      BEGIN        
         -- Check PickSlip valid        
         IF NOT EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)        
         BEGIN        
            SET @nErrNo = 100060        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid PSNO        
            GOTO Step_1_Fail        
         END        
/*        
         -- Check order picked        
         IF EXISTS( SELECT 1        
            FROM Orders O WITH (NOLOCK)        
               JOIN PickDetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey)        
            WHERE PD.PickSlipNo = @cPickSlipNo        
               AND O.Status >= '5')        
         BEGIN        
            SET @nErrNo = 100061        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Order picked        
          GOTO Step_1_Fail        
         END        
*/        
         -- Check diff storer        
         IF EXISTS( SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo AND StorerKey <> @cStorerKey)        
         BEGIN        
            SET @nErrNo = 100062        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer        
            GOTO Step_1_Fail        
         END        
      END        
        
      DECLARE @dScanInDate DATETIME        
      DECLARE @dScanOutDate DATETIME        
        
      -- Get picking info        
      SELECT TOP 1        
         @dScanInDate = ScanInDate,        
         @dScanOutDate = ScanOutDate        
      FROM dbo.PickingInfo WITH (NOLOCK)        
 WHERE PickSlipNo = @cPickSlipNo        
        
      IF @@ROWCOUNT = 0        
      BEGIN        
         INSERT INTO dbo.PickingInfo (PickSlipNo, ScanInDate, PickerID)        
         VALUES (@cPickSlipNo, GETDATE(), @cUserName)        
         IF @@ERROR <> 0        
         BEGIN        
            SET @nErrNo = 100083        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Fail scan-in        
            GOTO Step_1_Fail        
         END        
      END        
      ELSE        
      BEGIN        
         -- Scan-in        
         IF @dScanInDate IS NULL        
         BEGIN        
            UPDATE dbo.PickingInfo SET        
               ScanInDate = GETDATE(),        
               PickerID = @cUserName        
            WHERE PickSlipNo = @cPickSlipNo        
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 100063        
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Fail scan-in        
               GOTO Step_1_Fail        
            END        
         END        
        
         -- Check already scan out        
         IF @dScanOutDate IS NOT NULL        
         BEGIN        
            SET @nErrNo = 100064        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PS scanned out        
            GOTO Step_1_Fail        
         END        
      END        
        
      -- Prepare next screen var        
      SET @cOutField01 = @cPickSlipNo        
      SET @cOutField02 = '' --PickZone        
      SET @cOutField03 = '' --DropID        
      SET @nTtlBalQty = 0            
      SET @nBalQty = 0          
      SET @cSuggLOC = ''          
      SET @cCurrLOC = ''        
      SET @cSkippedSKU = ''        
      SET @cSuggSKU = ''      
      
      EXEC rdt.rdtSetFocusField @nMobile, 2 -- PickZone        
        
      -- Go to PickZone screen        
      SET @nScn = @nScn + 1        
      SET @nStep = @nStep + 1        
   END        
        
   IF @nInputKey = 0 -- Esc or No        
   BEGIN        
      -- EventLog        
      EXEC RDT.rdt_STD_EventLog        
         @cActionType = '9', -- Sign-out        
         @cUserID     = @cUserName,        
         @nMobileNo   = @nMobile,        
         @nFunctionID = @nFunc,        
         @cFacility   = @cFacility,        
         @cStorerKey  = @cStorerKey,        
         @nStep       = @nStep        
        
      -- Back to menu        
      SET @nFunc = @nMenu        
      SET @nScn  = @nMenu        
      SET @nStep = 0        
      SET @cOutField01 = '' -- Option        
   END        
   GOTO Quit        
        
   Step_1_Fail:        
   BEGIN        
      SET @cOutField01 = '' -- PSNO        
   END        
END        
GOTO Quit        
        
        
/********************************************************************************        
Scn = 4641. PickZone screen        
   LOC         (field01)        
   PickZone    (field02)        
   DropID      (field03, input)        
********************************************************************************/        
Step_2:        
BEGIN        
   IF @nInputKey = 1 -- ENTER        
   BEGIN        
      -- Screen mapping        
      SET @cPickZone = @cInField02        
      SET @cDropID = @cInField03        
        
      IF @cPickZone = ''        
      BEGIN        
         IF @cPickZoneMandatory = '1'        
         BEGIN        
            SET @nErrNo = 100086        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need PickZone        
            GOTO Step_2_PickZone_Fail          
         END        
      END        
              
      -- Check PickZone        
      IF @cPickZone <> ''        
      BEGIN        
         -- Cross dock PickSlip        
         IF @cZone IN ('XD', 'LB', 'LP')        
         BEGIN        
            -- Check zone in PickSlip        
            IF NOT EXISTS( SELECT TOP 1 1        
               FROM dbo.RefKeyLookup RKL WITH (NOLOCK)        
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (RKL.PickDetailKey = PD.PickDetailKey)        
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)        
               WHERE RKL.PickSlipNo = @cPickSlipNo        
               AND LOC.PickZone = @cPickZone)        
            BEGIN        
               SET @nErrNo = 100065        
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Zone NotInPSNO        
               GOTO Step_2_PickZone_Fail          
            END        
         END        
        
         -- Discrete PickSlip        
         ELSE IF @cOrderKey <> ''        
         BEGIN        
            -- Check zone in PickSlip        
            IF NOT EXISTS( SELECT TOP 1 1        
               FROM dbo.Orders O WITH (NOLOCK)        
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (O.OrderKey = PD.OrderKey)        
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)        
               WHERE O.OrderKey = @cOrderKey        
                  AND LOC.PickZone = @cPickZone)        
            BEGIN        
               SET @nErrNo = 100066        
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Zone NotInPSNO        
               GOTO Step_2_PickZone_Fail        
            END        
         END        
        
         -- Conso PickSlip        
         ELSE IF @cLoadKey <> ''        
         BEGIN        
            -- Check zone in PickSlip        
            IF NOT EXISTS( SELECT TOP 1 1        
               FROM dbo.LoadPlanDetail LPD WITH (NOLOCK)        
                  JOIN dbo.PickDetail PD WITH (NOLOCK) ON (LPD.OrderKey = PD.OrderKey)        
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)        
               WHERE LPD.LoadKey = @cLoadKey        
                  AND LOC.PickZone = @cPickZone)        
            BEGIN        
               SET @nErrNo = 100067        
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Zone NotInPSNO        
               GOTO Step_2_PickZone_Fail          
            END        
         END        
        
         -- Custom PickSlip        
         ELSE        
         BEGIN        
            -- Check zone in PickSlip        
            IF NOT EXISTS( SELECT TOP 1 1        
               FROM dbo.PickDetail PD WITH (NOLOCK)        
                  JOIN dbo.LOC WITH (NOLOCK) ON (LOC.LOC = PD.LOC)        
               WHERE PD.PickSlipNo = @cPickSlipNo        
                  AND LOC.PickZone = @cPickZone)        
            BEGIN        
               SET @nErrNo = 100068        
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Zone NotInPSNO        
               GOTO Step_2_PickZone_Fail          
            END        
         END        
      END        
      SET @cOutField02 = @cPickZone        
        
      -- Check DropID format        
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'DROPID', @cDropID) = 0        
      BEGIN        
         SET @nErrNo = 100080        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format        
         GOTO Step_2_DropID_Fail        
      END        
      SET @cOutField03 = @cDropID        
        
      IF @cExtendedValidateSP <> ''        
      BEGIN        
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')        
         BEGIN        
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +        
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +        
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, @nErrNo OUTPUT, @cErrMsg OUTPUT '        
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
               ' @nErrNo       INT    OUTPUT, ' +        
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '        
        
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,        
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,        
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY, @nErrNo OUTPUT, @cErrMsg OUTPUT        
                    
            IF @nErrNo <> 0         
               GOTO Step_2_Fail        
         END        
      END        
        
      SELECT @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,        
             @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',        
             @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL        
        
      -- Get task        
      SET @cSKUValidated = '0'        
      SET @nActQTY = 0        
        
      -- From close dropid         
      IF @cCurrLOC <> ''        
      BEGIN        
         SET @cSuggLOC = @cCurrLOC        
         SET @cSuggSKU = @cCurrSKU        
    
         EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CLOSE'        
         ,@cPickSlipNo        
         ,@cPickZone        
         ,4        
         ,@nTtlBalQty       OUTPUT            
         ,@nBalQty          OUTPUT            
         ,@cSuggLOC         OUTPUT        
         ,@cSuggSKU         OUTPUT        
         ,@cSKUDescr        OUTPUT        
         ,@nSuggQTY         OUTPUT        
         ,@cDisableQTYField OUTPUT        
         ,@cLottableCode    OUTPUT        
         ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
         ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
         ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
         ,@nErrNo           OUTPUT        
         ,@cErrMsg          OUTPUT        
         ,@cSuggID          OUTPUT  --(yeekung02)        
      IF @nErrNo <> 0        
         GOTO Step_2_Fail        
  
      SET @cCurrLOC = ''        
      SET @cCurrSKU = ''     
      END        
      ELSE     
      BEGIN       
         SET @cSuggSKU = CASE WHEN @cSkippedSKU <> '' THEN @cSkippedSKU ELSE '' END        
        
         EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTLOC'        
            ,@cPickSlipNo        
            ,@cPickZone        
            ,4        
            ,@nTtlBalQty       OUTPUT            
            ,@nBalQty          OUTPUT            
            ,@cSuggLOC         OUTPUT        
            ,@cSuggSKU         OUTPUT        
            ,@cSKUDescr        OUTPUT        
            ,@nSuggQTY         OUTPUT        
            ,@cDisableQTYField OUTPUT        
            ,@cLottableCode    OUTPUT        
            ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
            ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
            ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
            ,@nErrNo           OUTPUT        
            ,@cErrMsg          OUTPUT        
            ,@cSuggID          OUTPUT  --(yeekung02)        
         IF @nErrNo <> 0        
            GOTO Step_2_Fail        
      END    
        
      SET @cCurrLOC = ''        
      SET @cCurrSKU = ''        
              
      IF @cConfirmLOC = '1'        
      BEGIN        
         -- Prepare next screen var        
         SET @cOutField01 = @cSuggLOC        
         SET @cOutField02 = '' -- LOC        
        
         -- Go to confirm LOC screen        
         SET @nScn = @nScn + 5        
         SET @nStep = @nStep + 5        
      END        
      ELSE IF @cScanCIDSCN='1'        
      BEGIN        
         -- Prepare next screen var        
         SET @cOutField04 = @cSuggID --(yeekung02)        
         SET @cOutField05 = ''        
        
         -- Go to confirm LOC screen        
         SET @nScn = @nScn + 7        
         SET @nStep = @nStep + 7        
      END        
      ELSE        
      BEGIN        
         -- Dynamic lottable        
         EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,         
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
            @cInField11  OUTPUT, @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,        
            @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,        
            @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,        
            @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,        
            @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,        
            @nMorePage   OUTPUT,        
            @nErrNo      OUTPUT,        
            @cErrMsg     OUTPUT,        
            '',      -- SourceKey        
            @nFunc   -- SourceType        
      
            -- (james08)      
         IF @cExtSkuInfoSP <> ''      
         BEGIN      
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
            BEGIN      
               SET @cExtDescr1 = ''      
               SET @cExtDescr2 = ''      
      
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                  ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                  ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                  ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                  ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                  @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                  @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
            END      
         END      
               
         -- Prepare next screen var        
         SET @cOutField01 = @cSuggLOC        
         SET @cOutField02 = @cSuggSKU        
         SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
         SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
         SET @cOutField05 = '' -- SKU        
         SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
         SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN  CAST( @nSuggQTY AS NVARCHAR(6))         
                                 WHEN @cDefaultPickQTY <> '0' THEN  @cDefaultPickQTY        
                                 ELSE '' END -- QTY            
         SET @cOutField13 = LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))             
            
         EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU            
            
         -- Disable QTY field            
         SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY            
          
         IF @cFieldAttr07='O'          
            SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                    WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                                    ELSE @nActQTY END -- QTY         
         ELSE        
            SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
        
                     
         -- Go to SKU QTY screen        
         SET @nScn = @nScn + 1        
         SET @nStep = @nStep + 1        
      END        
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
               ',@cLottable02     NVARCHAR( 18)      ' +          
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
               @nMobile, @nFunc, @cLangCode, 2, @nInputKey, @cFacility, @cStorerKey,           
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @cOption, @cLottableCode,           
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,           
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,           
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,           
               @nErrNo OUTPUT, @cErrMsg OUTPUT           
          
            IF @nErrNo <> 0          
               GOTO Step_2_Fail          
         END          
      END          
              
      -- (ChewKP04)         
      IF @cExtendedInfoSP <> ''                
      BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
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
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Step_2_Fail          
                    
            IF @nStep IN (3,9)                                 
          SET @cOutField12 = @cExtendedInfo             
         END                
      END          
   END        
        
   IF @nInputKey = 0 -- ESC        
   BEGIN        
      -- Scan out        
      SET @nErrNo = 0        
      EXEC rdt.rdt_PickPiece_ScanOut @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey        
         ,@cPickSlipNo        
         ,@nErrNo       OUTPUT        
         ,@cErrMsg      OUTPUT        
      IF @nErrNo <> 0        
         GOTO Step_2_Fail        
        
      -- Prepare prev screen var        
      SET @cOutField01 = '' -- PickSlipNo        
      SET @cOutField13 = ''          
      SET @nTtlBalQty = 0          
      SET @nBalQty = 0          
        
      -- Go to PickSlipNo screen        
      SET @nScn = @nScn - 1        
      SET @nStep = @nStep - 1        
   END        
   GOTO Quit        
        
   Step_2_Fail:        
   BEGIN        
      SET @cOutField13 = ''          
      SET @nTtlBalQty = 0          
      SET @nBalQty = 0          
   END        
   GOTO Quit        
           
   Step_2_PickZone_Fail:        
   BEGIN        
      SET @cOutField02 = '' -- PickZone        
      SET @cOutField03 = @cDropID        
      SET @cOutField13 = ''          
      SET @nTtlBalQty = 0          
      SET @nBalQty = 0          
      EXEC rdt.rdtSetFocusField @nMobile, 2 -- PickZone        
   END        
   GOTO Quit        
           
   Step_2_DropID_Fail:        
   BEGIN        
      SET @cOutField02 = @cPickZone        
      SET @cOutField03 = ''        
      SET @cOutField13 = ''          
      SET @nTtlBalQty = 0          
      SET @nBalQty = 0          
      EXEC rdt.rdtSetFocusField @nMobile, 3 -- DropID        
   END        
   GOTO Quit        
END        
GOTO Quit        
        
        
/********************************************************************************        
Scn = 4642. SKU QTY screen        
   LOC         (field01)        
   SKU         (field02)        
   DESCR1      (field03)        
   DESCR1      (field04)        
   SKU/UPC     (field05, input)        
   LOTTABLEXX  (field08)        
   LOTTABLEXX  (field09)        
   LOTTABLEXX  (field10)        
   LOTTABLEXX  (field11)        
   PK QTY      (field06)        
   ACT QTY     (field07)        
********************************************************************************/        
Step_3:        
BEGIN        
   IF @nInputKey = 1 -- Yes or Send        
   BEGIN        
      -- Screen mapping        
      SET @cBarcode = @cInField05 -- SKU        
      SET @cUPC = LEFT( @cInField05, 30)        
      SET @cQTY = CASE WHEN @cFieldAttr07 = 'O' THEN @cOutField07 ELSE @cInField07 END        
      SET @cCurrSKU = @cOutField02        
        
      -- Retain value        
      SET @cOutField07 = CASE WHEN @cFieldAttr07 = 'O' THEN @cOutField07 ELSE @cInField07 END -- MQTY        
        
      SET @cSKU = ''        
      SET @nQTY = 0        
        
      -- Skip LOC        
      IF @cAllowSkipLOC = '1' AND @cBarcode = '' AND @cQTY = ''        
      BEGIN        
         -- Prepare skip LOC screen var        
         SET @cOutField01 = ''        
        
         -- Remember step        
         SET @nFromStep = @nStep        
        
         -- Go to skip LOC screen        
         SET @nScn = @nScn + 3       
         SET @nStep = @nStep + 3        
        
         GOTO Quit_Step3        
      END        
        
      -- Check SKU blank        
      IF @cBarcode = '' AND @cSKUValidated = '0' -- False        
      BEGIN        
         IF @cDiscardKeyword99 = '1'        
            SET @cBarcode = '99'        
         ELSE        
         BEGIN        
            SET @nErrNo = 100069        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need SKU        
            EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
            GOTO Step_3_Fail            
         END        
      END        
        
      SELECT        
         @cChkLottable01 = '', @cChkLottable02 = '', @cChkLottable03 = '',    @dChkLottable04 = NULL,  @dChkLottable05 = NULL,        
         @cChkLottable06 = '', @cChkLottable07 = '', @cChkLottable08 = '',    @cChkLottable09 = '',    @cChkLottable10 = '',        
         @cChkLottable11 = '', @cChkLottable12 = '', @dChkLottable13 = NULL,  @dChkLottable14 = NULL,  @dChkLottable15 = NULL        
        
      -- Validate SKU        
      IF @cBarcode <> ''        
      BEGIN        
         IF @cBarcode = '99' -- Fully short        
         BEGIN        
            SET @cSKUValidated = '99'        
            SET @cQTY = '0'        
            SET @cOutField07 = '0'        
         END        
         ELSE        
         BEGIN        
            -- Decode        
            IF @cDecodeSP <> ''        
            BEGIN        
               -- Standard decode        
               IF @cDecodeSP = '1'        
               BEGIN        
                  EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,        
                     @cUPC        = @cUPC           OUTPUT,        
                     @nQTY        = @nQTY           OUTPUT,        
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
                     @nErrNo      = @nErrNo  OUTPUT,        
                     @cErrMsg     = @cErrMsg OUTPUT,        
                     @cType       = 'UPC'        
               END        
               -- Customize decode        
               ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')        
               BEGIN        
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +        
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode, ' +        
                     ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, ' +        
                     ' @cUPC        OUTPUT, @nQTY        OUTPUT, ' +        
                     ' @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT, ' +        
                     ' @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT, ' +        
                     ' @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT, ' +        
                     ' @nErrNo   OUTPUT, @cErrMsg     OUTPUT'        
                  SET @cSQLParam =        
                     ' @nMobile      INT,           ' +        
                     ' @nFunc        INT,           ' +        
                     ' @cLangCode    NVARCHAR( 3),  ' +                         ' @nStep        INT,           ' +        
                     ' @nInputKey    INT,           ' +        
                     ' @cFacility    NVARCHAR( 5),  ' +        
                     ' @cStorerKey   NVARCHAR( 15), ' +        
                     ' @cBarcode     NVARCHAR( 60), ' +        
                     ' @cPickSlipNo  NVARCHAR( 10), ' +        
                     ' @cPickZone    NVARCHAR( 10), ' +        
                     ' @cDropID      NVARCHAR( 20), ' +        
                     ' @cLOC         NVARCHAR( 10), ' +        
                     ' @cUPC         NVARCHAR( 30)  OUTPUT, ' +        
                     ' @nQTY         INT            OUTPUT, ' +        
                     ' @cLottable01  NVARCHAR( 18)  OUTPUT, ' +        
                     ' @cLottable02  NVARCHAR( 18)  OUTPUT, ' +        
                     ' @cLottable03  NVARCHAR( 18)  OUTPUT, ' +        
                     ' @dLottable04  DATETIME       OUTPUT, ' +        
                     ' @dLottable05  DATETIME       OUTPUT, ' +        
                     ' @cLottable06  NVARCHAR( 30)  OUTPUT, ' +        
                     ' @cLottable07  NVARCHAR( 30)  OUTPUT, ' +        
                     ' @cLottable08  NVARCHAR( 30)  OUTPUT, ' +        
                     ' @cLottable09  NVARCHAR( 30)  OUTPUT, ' +        
                     ' @cLottable10  NVARCHAR( 30)  OUTPUT, ' +        
                     ' @cLottable11  NVARCHAR( 30)  OUTPUT, ' +        
                     ' @cLottable12  NVARCHAR( 30)  OUTPUT, ' +        
                     ' @dLottable13  DATETIME       OUTPUT, ' +        
                     ' @dLottable14  DATETIME       OUTPUT, ' +        
                     ' @dLottable15  DATETIME       OUTPUT, ' +        
                     ' @nErrNo       INT            OUTPUT, ' +        
                     ' @cErrMsg      NVARCHAR( 20)  OUTPUT'        
        
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,        
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode,        
                     @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC,        
                     @cUPC        OUTPUT, @nQTY        OUTPUT,        
                     @cChkLottable01 OUTPUT, @cChkLottable02 OUTPUT, @cChkLottable03 OUTPUT, @dChkLottable04 OUTPUT, @dChkLottable05 OUTPUT,        
                     @cChkLottable06 OUTPUT, @cChkLottable07 OUTPUT, @cChkLottable08 OUTPUT, @cChkLottable09 OUTPUT, @cChkLottable10 OUTPUT,        
                     @cChkLottable11 OUTPUT, @cChkLottable12 OUTPUT, @dChkLottable13 OUTPUT, @dChkLottable14 OUTPUT, @dChkLottable15 OUTPUT,        
                     @nErrNo      OUTPUT, @cErrMsg     OUTPUT        
               END        
        
               IF @nErrNo <> 0        
                  GOTO Step_3_Fail        
            END        
        
            -- Get SKU count        
            DECLARE @nSKUCnt INT        
            SET @nSKUCnt = 0        
            EXEC RDT.rdt_GetSKUCNT        
                @cStorerKey  = @cStorerKey        
               ,@cSKU        = @cUPC        
               ,@nSKUCnt     = @nSKUCnt   OUTPUT        
               ,@bSuccess    = @bSuccess  OUTPUT        
               ,@nErr        = @nErrNo    OUTPUT        
               ,@cErrMsg     = @cErrMsg   OUTPUT        
        
            -- Check SKU        
            IF @nSKUCnt = 0        
            BEGIN        
               SET @nErrNo = 100070        
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU        
               GOTO Step_3_Fail        
            END        
        
            -- Validate barcode return multiple SKU      
            IF @nSKUCnt > 1      
            BEGIN      
               IF @cMultiSKUBarcode IN ('1', '2')      
               BEGIN      
                  EXEC rdt.rdt_MultiSKUBarcode @nMobile, @nFunc, @cLangCode,      
                     @cInField01 OUTPUT,  @cOutField01 OUTPUT,      
                     @cInField02 OUTPUT,  @cOutField02 OUTPUT,      
                     @cInField03 OUTPUT,  @cOutField03 OUTPUT,      
                     @cInField04 OUTPUT,  @cOutField04 OUTPUT,      
                     @cInField05 OUTPUT,  @cOutField05 OUTPUT,      
                     @cInField06 OUTPUT,  @cOutField06 OUTPUT,      
                     @cInField07 OUTPUT,  @cOutField07 OUTPUT,      
                     @cInField08 OUTPUT,  @cOutField08 OUTPUT,      
                     @cInField09 OUTPUT,  @cOutField09 OUTPUT,      
                     @cInField10 OUTPUT,  @cOutField10 OUTPUT,      
                     @cInField11 OUTPUT,  @cOutField11 OUTPUT,      
                     @cInField12 OUTPUT,  @cOutField12 OUTPUT,      
                     @cInField13 OUTPUT,  @cOutField13 OUTPUT,      
                     @cInField14 OUTPUT,  @cOutField14 OUTPUT,      
                     @cInField15 OUTPUT,  @cOutField15 OUTPUT,      
                     'POPULATE',      
                     @cMultiSKUBarcode,      
                     @cStorerKey,      
                     @cUPC     OUTPUT,      
                     @nErrNo   OUTPUT,      
                     @cErrMsg  OUTPUT,        
                     'PICKSLIPNO',    -- DocType        
                     @cPickSlipNo        
      
                  IF @nErrNo = 0      
                  BEGIN      
                     -- Go to Multi SKU screen      
                     SET @nFromScn = @nScn      
                     SET @nScn = 3570      
                     SET @nStep = @nStep + 7      
                     SET @cOutField13 = ''      
                     GOTO Quit      
                  END      
                  ELSE IF @nErrNo = -1 -- Found in Doc, skip multi SKU screen      
                  BEGIN      
                     SET @nErrNo = 0      
                     SET @cSKU = @cUPC      
                  END      
               END      
               ELSE      
               BEGIN     
                  SET @nErrNo = 100071        
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod        
                  GOTO Step_3_Fail        
               END        
            END      
        
            -- Get SKU        
            EXEC rdt.rdt_GetSKU        
                @cStorerKey  = @cStorerKey        
               ,@cSKU        = @cUPC      OUTPUT        
               ,@bSuccess    = @bSuccess  OUTPUT        
               ,@nErr        = @nErrNo    OUTPUT        
               ,@cErrMsg     = @cErrMsg   OUTPUT        
            IF @nErrNo <> 0        
               GOTO Step_3_Fail        
        
            SET @cSKU = @cUPC        
        
            -- Validate SKU        
            IF @cSKU <> @cSuggSKU        
            BEGIN        
               SET @nErrNo = 100072        
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong SKU        
               EXEC rdt.rdtSetFocusField @nMobile, 11  -- SKU        
               GOTO Step_3_Fail        
            END        
        
            -- Mark SKU as validated        
            SET @cSKUValidated = '1'        
            SET @cCurrSKU = @cSKU        
         END        
      END        
        
      -- Validate QTY        
      IF @cQTY <> '' AND RDT.rdtIsValidQTY( @cQTY, 0) = 0        
      BEGIN        
         SET @nErrNo = 100073        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY        
         EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY        
         GOTO Step_3_Fail        
      END        
        
      -- Check full short with QTY        
      IF @cSKUValidated = '99' AND @cQTY <> '0' AND @cQTY <> ''        
      BEGIN        
         SET @nErrNo = 100079        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- AllShortWithQTY        
         EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY        
         GOTO Step_3_Fail        
      END        
        
      -- Top up QTY        
      IF @cSKUValidated = '99' -- Fully short        
         SET @nQTY = 0        
      ELSE IF @nQTY > 0        
         SET @nQTY = @nActQTY + @nQTY        
      ELSE        
         IF @cSKU <> '' AND @cDisableQTYField = '1' AND @cDefaultQTY <> '1'        
            SET @nQTY = @nActQTY + 1        
         ELSE        
         BEGIN        
            IF @cSKU = '' AND @cDisableQTYField = '1'        
               SET @nQTY = @nActQTY        
            ELSE        
               SET @nQTY = CAST( @cQTY AS INT)        
         END        
        
      -- Check over pick        
      IF @nQTY > @nSuggQTY        
      BEGIN        
         SET @nErrNo = 100074        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Over pick        
         EXEC rdt.rdtSetFocusField @nMobile, 7 -- PQTY        
         GOTO Step_3_Fail        
      END        
        
              
      IF @cExtendedValidateSP <> ''                
      BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, @nErrNo OUTPUT, @cErrMsg OUTPUT '                
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
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Quit          
         END                
      END            
        
      -- Save to ActQTY        
      SET @nActQTY = @nQTY        
      SET @cOutField07 = CAST( @nQTY AS NVARCHAR(6))        
        
      -- SKU scanned, remain in current screen        
      IF @cBarcode NOT IN ( '', '99')        
      BEGIN        
         SET @cOutField05 = '' -- SKU        
        
         IF @cDisableQTYField = '1'        
         BEGIN        
            EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
    
            IF @nActQTY <> @nSuggQTY        
            BEGIN        
               IF @cFieldAttr07='O'          
                  SET @cOutField07= CASE WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY ELSE @nActQTY END        
               ELSE        
                  SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @cDefaultQTY ELSE '' END        
               --SET @cOutField13 =LTRIM(CAST((@nBalQty - CAST(@cOutField07 AS INT)) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6)) -- ZG01      
               SET @cOutField13 =LTRIM(CAST((@nBalQty - @nQTY) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))    
               GOTO Quit_Step3        
            END        
         END        
         ELSE        
         BEGIN        
            --SET @cOutField07 = ''        
            SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6)) ELSE '' END -- QTY          
            SET @cOutField13 =LTRIM(CAST((@nBalQty - CAST(@cOutField07 AS INT)) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6)) -- ZG01      
            EXEC rdt.rdtSetFocusField @nMobile, 7 -- MQTY        
            GOTO Quit_Step3             
         END                    
      END        
        
      -- QTY short        
      IF @nActQTY < @nSuggQTY        
      BEGIN        
         -- Prepare next screen var        
         SET @cOption = ''        
         SET @cOutField01 = '' -- Option        
        
         -- Enable field        
         SET @cFieldAttr07 = '' -- QTY        
        
         SET @nScn = @nScn + 2        
         SET @nStep = @nStep + 2        
      END        
        
      -- QTY fulfill        
      IF @nActQTY = @nSuggQTY        
      BEGIN        
         -- Confirm        
         EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CONFIRM'        
            ,@cPickSlipNo        
            ,@cPickZone        
            ,@cDropID        
            ,@cSuggLOC        
            ,@cSuggSKU        
            ,@nActQTY        
            ,@cLottableCode        
            ,@cLottable01        
            ,@cLottable02        
            ,@cLottable03        
            ,@dLottable04        
            ,@dLottable05        
            ,@cLottable06        
            ,@cLottable07        
            ,@cLottable08        
            ,@cLottable09        
            ,@cLottable10        
            ,@cLottable11        
            ,@cLottable12        
            ,@dLottable13        
            ,@dLottable14        
            ,@dLottable15        
            ,@nErrNo       OUTPUT        
            ,@cErrMsg      OUTPUT        
         IF @nErrNo <> 0        
            GOTO Quit        
        
         -- Get task in same LOC        
         SET @cSKUValidated = '0'        
         SET @nActQTY = 0        
         SET @cSuggSKU = CASE WHEN @cSkippedSKU <> '' THEN @cSkippedSKU ELSE '' END        
         EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTSKU'        
            ,@cPickSlipNo        
            ,@cPickZone        
            ,4        
            ,@nTtlBalQty       OUTPUT            
            ,@nBalQty          OUTPUT          
            ,@cSuggLOC         OUTPUT        
            ,@cSuggSKU         OUTPUT        
            ,@cSKUDescr        OUTPUT        
            ,@nSuggQTY         OUTPUT        
            ,@cDisableQTYField OUTPUT        
            ,@cLottableCode    OUTPUT        
            ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
            ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
            ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
            ,@nErrNo           OUTPUT        
            ,@cErrMsg          OUTPUT        
            ,@cSuggID          OUTPUT  --(yeekung02)        
         IF @nErrNo = 0        
         BEGIN        
            -- Dynamic lottable                
            EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,                
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
        
            IF @cScanCIDSCN='1'        
            BEGIN        
               -- Prepare next screen var                       SET @cOutField04 = @cSuggID --(yeekung02)        
               SET @cOutField05 = ''        
        
               -- Go to confirm LOC screen        
               SET @nScn = @nScn + 6        
               SET @nStep = @nStep + 6        
               GOTO QUIT_Step3        
            END        
        
            -- (james08)      
            IF @cExtSkuInfoSP <> ''      
            BEGIN      
               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
               BEGIN      
                  SET @cExtDescr1 = ''      
                  SET @cExtDescr2 = ''      
      
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                     ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                     ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                     ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                     ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                     @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                     @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
               END      
            END      
                  
            -- Prepare SKU QTY screen var      
            SET @cOutField01 = @cSuggLOC      
            SET @cOutField02 = @cSuggSKU      
            SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
            SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
            SET @cOutField05 = '' -- SKU/UPC        
            SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
            SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                    WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                    ELSE '' END -- QTY        
  SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))             
        
            IF @cFieldAttr07='O'          
               SET @cOutField07= CASE WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY ELSE @nActQTY END        
            ELSE        
               SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
                    
            EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
         END        
         ELSE        
         BEGIN        
            /*        
            -- Enable field        
            SET @cFieldAttr07 = '' -- QTY        
        
            -- Goto no more task in loc screen        
            SET @nScn = @nScn + 1        
            SET @nStep = @nStep + 1        
 */        
            SELECT @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,        
                   @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',        
                   @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL        
        
            -- Clear 'No Task' error from previous get task        
            SET @nErrNo = 0        
            SET @cErrMsg = ''        
                    
            -- Get task in next loc        
            SET @cSKUValidated = '0'        
            SET @nActQTY = 0        
            SET @cSuggSKU = ''        
            EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTLOC'        
               ,@cPickSlipNo        
               ,@cPickZone        
               ,4        
               ,@nTtlBalQty       OUTPUT            
               ,@nBalQty          OUTPUT            
               ,@cSuggLOC         OUTPUT        
               ,@cSuggSKU         OUTPUT        
               ,@cSKUDescr        OUTPUT        
               ,@nSuggQTY         OUTPUT        
               ,@cDisableQTYField OUTPUT        
               ,@cLottableCode    OUTPUT        
               ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
               ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
               ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
               ,@nErrNo           OUTPUT        
               ,@cErrMsg          OUTPUT        
               ,@cSuggID          OUTPUT  --(yeekung02)        
            IF @nErrNo = 0        
            BEGIN        
               IF @cConfirmLOC = '1'        
               BEGIN        
                  -- Prepare next screen var        
                  SET @cOutField01 = @cSuggLOC        
                  SET @cOutField02 = '' -- LOC        
        
                  -- Go to confirm LOC screen        
                  SET @nScn = @nScn + 4        
                  SET @nStep = @nStep + 4        
                  GOTO QUIT_Step3        
               END        
               ELSE IF @cScanCIDSCN='1'        
               BEGIN        
                  -- Prepare next screen var        
                  SET @cOutField04 = @cSuggID --(yeekung02)        
                  SET @cOutField05 = ''        
        
                  -- Go to confirm LOC screen        
                  SET @nScn = @nScn + 6        
                  SET @nStep = @nStep + 6        
                  GOTO QUIT_Step3        
        
               END        
               ELSE        
               BEGIN        
                  -- Dynamic lottable                
                  EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,                
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
      
                  -- (james08)      
                  IF @cExtSkuInfoSP <> ''      
                  BEGIN      
                     IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
                     BEGIN      
                        SET @cExtDescr1 = ''      
                        SET @cExtDescr2 = ''      
      
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                           ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                           ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                           ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                           ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                           @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                           @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                    @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
                     END      
                  END      
                        
                  -- Prepare SKU QTY screen var      
                  SET @cOutField01 = @cSuggLOC      
                  SET @cOutField02 = @cSuggSKU      
                  SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
                  SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
                  SET @cOutField05 = '' -- SKU/UPC        
                  SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
                  SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                     WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                          ELSE '' END -- QTY        
                  SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))            
          
                  IF @cFieldAttr07='O'          
                     SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                            WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                                            ELSE @nActQTY END -- QTY         
                  ELSE        
                     SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
                    
                  EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
               END        
            END        
            ELSE        
            BEGIN        
                       
               -- Get task  -- (ChewKP04)              
               SET @cSKUValidated = '0'                
               SET @nActQTY = 0              
               EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTZONE'                
                  ,@cPickSlipNo                
                  ,@cPickZone                
                  ,4               
                  ,@nTtlBalQty       OUTPUT            
                  ,@nBalQty          OUTPUT           
                  ,@cSuggLOC         OUTPUT                
                  ,@cSuggSKU         OUTPUT                
                  ,@cSKUDescr        OUTPUT                
                  ,@nSuggQTY         OUTPUT                
                  ,@cDisableQTYField OUTPUT                
                  ,@cLottableCode    OUTPUT                
                  ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT                
                  ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT                
                  ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT                
                  ,@nErrNo           OUTPUT                
                  ,@cErrMsg          OUTPUT               
                  ,@cSuggID          OUTPUT  --(yeekung02)         
               IF @nErrNo =  0                
               BEGIN            
                  -- Reset here, next screen will fetch task again        
                  SET @cCurrLOC = ''        
                  SET @cSuggLOC = ''        
        
                  -- Prepare next screen var                
                  SET @cOutField01 = @cPickSlipNo -- '' -- PickSlipNo                
                  SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END            
                  SET @cOutField03 = ''            
                              
                  -- Go to PickSlipNo screen                
                  SET @nScn = @nScn - 1                
                  SET @nStep = @nStep - 1             
                              
               END            
               ELSE            
               BEGIN           
                  -- Scan out        
                  SET @nErrNo = 0        
                  EXEC rdt.rdt_PickPiece_ScanOut @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey        
                     ,@cPickSlipNo        
                     ,@nErrNo       OUTPUT        
                     ,@cErrMsg      OUTPUT        
               IF @nErrNo <> 0        
                     GOTO Quit        
        
                  -- Prepare next screen var        
                  SET @cOutField01 = '' -- PickSlipNo        
        
                  -- Go to PickSlipNo screen        
                  SET @nScn = @nScn - 2        
                  SET @nStep = @nStep - 2        
               END        
            END        
         END        
      END        
        
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
               ',@cSKU      NVARCHAR( 20)            ' +                
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
               ',@dLottable14     DATETIME          ' +                
               ',@dLottable15     DATETIME        ' +                
               ',@nErrNo          INT           OUTPUT     ' +                
               ',@cErrMsg         NVARCHAR(250) OUTPUT     '                 
                
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 3, @nInputKey, @cFacility, @cStorerKey,                 
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @cOption, @cLottableCode,                 
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,                 
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,                 
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,                 
               @nErrNo OUTPUT, @cErrMsg OUTPUT                 
                
                         
            IF @nErrNo <> 0                
               GOTO Step_3_Fail                      
         END                
      END             
              
      -- (ChewKP04)         
      Quit_Step3:        
 IF @cExtendedInfoSP <> ''                
      BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
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
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 3, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Step_3_Fail          
                    
            IF @nStep IN (3,9)                             
               SET @cOutField12 = @cExtendedInfo             
         END                
      END         
        
   END        
        
   IF @nInputKey = 0 -- ESC        
   BEGIN        
      IF @cExtendedInfoSP <> ''                
      BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cExtendedInfo = ''        
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
       ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
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
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, @nStep, 8, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
               SET @cOutField12 = @cExtendedInfo             
         END                
      END          
        
      IF ISNULL(@cOutField07,'')=''        
      BEGIN        
         IF @cScanCIDSCN='1'        
         BEGIN        
            -- Prepare next screen var        
            SET @cOutField01 = @cSuggLOC        
            SET @cOutField04 = @cSuggID --(yeekung02)        
            SET @cOutField05 = ''        
            SET @nActQTY=0        
        
            -- Go to confirm LOC screen        
            SET @nScn = @nScn + 6        
            SET @nStep = @nStep + 6        
            GOTO QUIT        
         END        
         ELSE IF @cConfirmLOC = '1'        
         BEGIN        
            -- Prepare next screen var        
            SET @cOutField01 = @cSuggLOC        
            SET @cOutField02 = '' -- LOC        
            SET @nActQTY=0        
        
            -- Go to confirm LOC screen        
            SET @nScn = @nScn +4        
            SET @nStep = @nStep +4        
            GOTO QUIT        
         END        
      END        
        
      SET @nFromStep = @nStep        
      SET @nFromScn = @nScn        
        
      SET @cOutField01 = '' -- Option        
      SET @cOutField12 =''        
        
      -- Go to Abort screen        
      SET @nScn = @nScn + 5        
      SET @nStep = @nStep + 5        
   END        
   GOTO Quit        
        
   Step_3_Fail:        
   BEGIN        
      SET @cOutField08 = '' -- SKU        
   END        
END        
GOTO Quit        
        
        
/********************************************************************************        
Scn = 4643. Message. No more task in LOC        
********************************************************************************/        
Step_4:        
BEGIN        
   SELECT @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,        
          @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',        
          @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL        
        
   -- Get task in next loc        
   SET @cSKUValidated = '0'        
   SET @nActQTY = 0        
   EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTLOC'        
      ,@cPickSlipNo        
      ,@cPickZone        
      ,4        
      ,@nTtlBalQty       OUTPUT            
      ,@nBalQty          OUTPUT          
      ,@cSuggLOC         OUTPUT        
      ,@cSuggSKU         OUTPUT        
      ,@cSKUDescr        OUTPUT        
      ,@nSuggQTY         OUTPUT        
      ,@cDisableQTYField OUTPUT        
      ,@cLottableCode    OUTPUT        
      ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
      ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
      ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
      ,@nErrNo           OUTPUT        
      ,@cErrMsg          OUTPUT        
      ,@cSuggID          OUTPUT  --(yeekung02)        
   IF @nErrNo = 0        
   BEGIN        
      IF @cConfirmLOC = '1'        
      BEGIN        
         -- Prepare next screen var        
         SET @cOutField01 = @cSuggLOC        
         SET @cOutField02 = '' -- LOC        
        
         -- Go to confirm LOC screen        
         SET @nScn = @nScn + 3        
         SET @nStep = @nStep + 3        
      END        
      ELSE IF @cScanCIDSCN='1'        
      BEGIN        
         -- Prepare next screen var        
         SET @cOutField04 = @cSuggID --(yeekung02)        
         SET @cOutField05 = ''        
        
         -- Go to confirm LOC screen        
         SET @nScn = @nScn + 5        
         SET @nStep = @nStep + 5        
      END        
      ELSE        
      BEGIN        
         -- (james03)        
         -- Dynamic lottable        
         EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,         
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
      
         -- (james08)      
        IF @cExtSkuInfoSP <> ''      
         BEGIN      
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
        BEGIN      
               SET @cExtDescr1 = ''      
               SET @cExtDescr2 = ''      
      
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                  ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                  ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                  ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                  ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
    @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                  @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
            END      
         END      
               
         -- Prepare SKU QTY screen var      
         SET @cOutField01 = @cSuggLOC      
         SET @cOutField02 = @cSuggSKU      
         SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
         SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
         SET @cOutField05 = '' -- SKU/UPC        
         SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
         SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                 WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                 ELSE '' END -- QTY        
         SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))            
            
         EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU            
            
         -- Disable QTY field            
         SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END           
                   
         IF @cFieldAttr07='O'          
            SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                    WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                                    ELSE @nActQTY END -- QTY         
         ELSE        
            SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
        
        
         -- Go to SKU QTY screen        
         SET @nScn = @nScn - 1        
         SET @nStep = @nStep - 1        
      END        
   END        
   ELSE        
   BEGIN        
      -- Get task  -- (ChewKP04)              
      SET @cSKUValidated = '0'                
      SET @nActQTY = 0              
      EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTZONE'                
         ,@cPickSlipNo                
         ,@cPickZone      
         ,4        
         ,@nTtlBalQty       OUTPUT            
         ,@nBalQty          OUTPUT                    
         ,@cSuggLOC         OUTPUT                
         ,@cSuggSKU         OUTPUT                
         ,@cSKUDescr        OUTPUT                
         ,@nSuggQTY         OUTPUT             
         ,@cDisableQTYField OUTPUT                
         ,@cLottableCode    OUTPUT                
         ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT                
         ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT                
         ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT                
         ,@nErrNo   OUTPUT                
         ,@cErrMsg          OUTPUT                
         ,@cSuggID          OUTPUT  --(yeekung02)        
      IF @nErrNo =  0                
      BEGIN            
         -- Prepare next screen var                
         SET @cOutField01 = @cPickSlipNo --'' -- PickSlipNo                
         SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END            
         SET @cOutField03 = ''            
                     
         -- Go to PickSlipNo screen                
         SET @nScn = @nScn - 1                
         SET @nStep = @nStep - 1             
                     
      END            
      ELSE            
      BEGIN            
         -- Scan out        
         SET @nErrNo = 0        
         EXEC rdt.rdt_PickPiece_ScanOut @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey        
            ,@cPickSlipNo        
            ,@nErrNo       OUTPUT        
            ,@cErrMsg      OUTPUT        
         IF @nErrNo <> 0        
            GOTO Quit        
        
         -- Prepare next screen var        
         SET @cOutField01 = '' -- PickSlipNo        
        
         -- Go to PickSlipNo screen        
         SET @nScn = @nScn - 3        
         SET @nStep = @nStep - 3        
      END        
   END        
           
   -- (ChewKP04)         
   IF @cExtendedInfoSP <> ''                
   BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
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
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Quit          
                    
            IF @nStep IN (3,9)                                
               SET @cOutField12 = @cExtendedInfo             
         END                
   END           
           
END        
GOTO Quit        
        
        
/********************************************************************************        
Scn = 4644. Confirm Short Pick?            
   Option (field01)        
********************************************************************************/        
Step_5:                
BEGIN                
   IF @nInputKey = 1 -- ENTER                
   BEGIN                
      -- Screen mapping                
      SET @cOption = @cInField01                
                
      -- Validate blank                
      IF @cOption = ''                
      BEGIN                
         SET @nErrNo = 100075                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required                
         GOTO Step_5_Fail                
      END                
                
      -- Validate option                
      IF @cOption <> '1' AND         
         @cOption <> '2' AND         
         @cOption <> '3' AND  -- (ChewKP01)                
         @cOption <> '4'         
      BEGIN                
         SET @nErrNo = 100076                
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option                
         GOTO Step_5_Fail                
      END                
        
      /*        
         Option=1 = Short pick sku        
         Option=2 = Balance pick later, go to next sku or next loc or next zone        
         Option=3 = Close drop id                  
      */        
      DECLARE @cConfirmType NVARCHAR( 10)                
      IF @cOption = '1'        
         SET @cConfirmType = 'SHORT'                
      ELSE                
         SET @cConfirmType = 'CLOSE'            
        
              
      -- Handling transaction                
      SET @nTranCount = @@TRANCOUNT                
      BEGIN TRAN  -- Begin our own transaction                
      SAVE TRAN rdtfnc_PickPiece -- For rollback or commit only our own transaction                
                
      -- Confirm ( Balance pick later proceed only when user do picked something)               
      -- For option = 4, need confirm first if something already picked        
      --IF @cOption IN ('1', '3') OR ( @cOption IN ( 2, 4) AND @nActQTY > 0)           
      IF @cOption IN ('1', '3') OR ( @cOption = '4' AND @nActQTY > 0) OR (@cOption = '2' AND @nActQTY > 0 AND @cSkipConfirmBalPick <> '1')     --(cc01)                
      BEGIN                
         EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cConfirmType,                
             @cPickSlipNo                
            ,@cPickZone                
            ,@cDropID                
            ,@cSuggLOC                
            ,@cSuggSKU                
            ,@nActQTY                
            ,@cLottableCode                
            ,@cLottable01                
            ,@cLottable02                
            ,@cLottable03                
            ,@dLottable04                
            ,@dLottable05                
            ,@cLottable06                
            ,@cLottable07                
            ,@cLottable08                
            ,@cLottable09                
            ,@cLottable10                
            ,@cLottable11                
            ,@cLottable12                
            ,@dLottable13                
            ,@dLottable14                
            ,@dLottable15                
            ,@nErrNo       OUTPUT                
            ,@cErrMsg      OUTPUT                
         IF @nErrNo <> 0                
         BEGIN                
            ROLLBACK TRAN rdtfnc_PickPiece                
            WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started                
               COMMIT TRAN                
            GOTO Step_5_Fail                
         END                
      END                
                
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
               ',@nErrNo          INT           OUTPUT     ' +                
               ',@cErrMsg         NVARCHAR(250) OUTPUT     '                 
                
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 5, @nInputKey, @cFacility, @cStorerKey,                 
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @cOption, @cLottableCode,                 
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,                 
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,                 
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,                 
               @nErrNo OUTPUT, @cErrMsg OUTPUT                 
                
            IF @nErrNo <> 0                
            BEGIN                
               ROLLBACK TRAN rdtfnc_PickPiece                
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started                
                  COMMIT TRAN                
               GOTO Step_5_Fail                
            END                
         END                
      END           
                
      COMMIT TRAN rdtfnc_PickPiece -- Only commit change made here                
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started                
         COMMIT TRAN                
              
      IF @cOption = '1'  -- Short                
      BEGIN                
        -- Get task in current LOC                
         SET @cSKUValidated = '0'                
         SET @nActQTY = 0                
         EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTSKU'                
            ,@cPickSlipNo                
            ,@cPickZone                
            ,4        
            ,@nTtlBalQty       OUTPUT            
            ,@nBalQty          OUTPUT                    
            ,@cSuggLOC         OUTPUT                
            ,@cSuggSKU         OUTPUT                
            ,@cSKUDescr        OUTPUT                
            ,@nSuggQTY         OUTPUT                
            ,@cDisableQTYField OUTPUT                
            ,@cLottableCode    OUTPUT                
            ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT                
            ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT                
            ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT                
            ,@nErrNo           OUTPUT                
           ,@cErrMsg          OUTPUT             
            ,@cSuggID          OUTPUT  --(yeekung02)           
         IF @nErrNo = 0                
         BEGIN                
            -- (james03)        
            -- Dynamic lottable        
            EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,         
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
        
            IF @cScanCIDSCN='1'        
            BEGIN        
               -- Prepare next screen var        
               SET @cOutField04 = @cSuggID --(yeekung02)        
               SET @cOutField05 = ''        
        
               -- Go to confirm LOC screen        
               SET @nScn = @nScn + 4        
               SET @nStep = @nStep + 4        
               GOTO Quit_Step5         
            END        
      
            -- (james08)      
            IF @cExtSkuInfoSP <> ''      
            BEGIN      
               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
               BEGIN      
                  SET @cExtDescr1 = ''      
                  SET @cExtDescr2 = ''      
      
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                     ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                     ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                     ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                     ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                     @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                     @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
               END      
            END      
                  
            -- Prepare SKU QTY screen var      
            SET @cOutField01 = @cSuggLOC      
            SET @cOutField02 = @cSuggSKU      
            SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
            SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
            SET @cOutField05 = '' -- SKU/UPC                
            SET @cOutField06 = RTRIM(CAST( @nSuggQTY AS NVARCHAR(6)))                    
            SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                    WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                    ELSE '' END -- QTY                
            SET @cOutField13 = LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))                 
                        
            EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU                    
                    
            -- Disable QTY field                    
            SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END            
     
            IF @cFieldAttr07='O'          
               SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                       WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                                       ELSE @nActQTY END -- QTY         
            ELSE        
               SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
                       
            -- Go to SKU QTY screen                
            SET @nScn = @nScn - 2                
            SET @nStep = @nStep - 2             
         END                
         ELSE                
         BEGIN                
            -- Go to no more task in loc screen                
            SET @nScn = @nScn - 1                
            SET @nStep = @nStep - 1                
         END                
         GOTO Quit_Step5                
      END                
      -- (james05)        
      ELSE IF @cOption = '2'  -- (james07)        
      BEGIN        
         -- Get task in same LOC        
         SET @cSKUValidated = '0'        
         SET @nActQTY = 0        
         SET @cSuggSKU = @cCurrSKU        
         SET @cSkippedSKU = @cCurrSKU        
         EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTSKU'        
            ,@cPickSlipNo        
            ,@cPickZone        
            ,4        
            ,@nTtlBalQty       OUTPUT            
            ,@nBalQty          OUTPUT          
            ,@cSuggLOC         OUTPUT        
            ,@cSuggSKU         OUTPUT        
            ,@cSKUDescr        OUTPUT        
            ,@nSuggQTY         OUTPUT        
            ,@cDisableQTYField OUTPUT        
            ,@cLottableCode    OUTPUT        
            ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
            ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
            ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
            ,@nErrNo           OUTPUT        
            ,@cErrMsg          OUTPUT        
            ,@cSuggID          OUTPUT  --(yeekung02)        
         IF @nErrNo = 0        
         BEGIN        
            -- Dynamic lottable                
            EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,                
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
      
            -- (james08)      
            IF @cExtSkuInfoSP <> ''      
            BEGIN      
               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
               BEGIN      
                  SET @cExtDescr1 = ''      
                  SET @cExtDescr2 = ''      
      
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                     ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                     ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                     ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                     ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                     @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                     @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
               END      
            END      
                  
           -- Prepare SKU QTY screen var      
            SET @cOutField01 = @cSuggLOC      
            SET @cOutField02 = @cSuggSKU      
            SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
            SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
            SET @cOutField05 = '' -- SKU/UPC        
            SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
            SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                    WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                    ELSE '' END -- QTY        
            SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))             
        
            IF @cFieldAttr07='O'          
               SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                       WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                                       ELSE @nActQTY END -- QTY         
            ELSE        
               SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
        
            EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
                    
            -- Go to SKU QTY screen        
            SET @nScn = @nScn - 2        
            SET @nStep = @nStep - 2        
            GOTO Quit        
         END        
         ELSE        
         BEGIN        
            SELECT @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,        
                   @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',        
                   @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL        
        
            -- Get task in next loc        
            SET @cSKUValidated = '0'        
            SET @nActQTY = 0        
            SET @cSKUDescr = 'BALPICK'        
            EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTLOC'        
               ,@cPickSlipNo        
               ,@cPickZone        
               ,4        
               ,@nTtlBalQty       OUTPUT            
               ,@nBalQty          OUTPUT            
               ,@cSuggLOC         OUTPUT        
               ,@cSuggSKU         OUTPUT        
               ,@cSKUDescr        OUTPUT        
               ,@nSuggQTY         OUTPUT        
               ,@cDisableQTYField OUTPUT        
               ,@cLottableCode    OUTPUT        
               ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
               ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
               ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
               ,@nErrNo           OUTPUT        
               ,@cErrMsg          OUTPUT        
               ,@cSuggID          OUTPUT  --(yeekung02)        
            IF @nErrNo = 0        
            BEGIN        
               IF @cConfirmLOC = '1'        
               BEGIN        
                  -- Prepare next screen var        
                  SET @cOutField01 = @cSuggLOC        
                  SET @cOutField02 = '' -- LOC        
        
                  -- Go to confirm LOC screen        
                  SET @nScn = @nScn + 2        
                  SET @nStep = @nStep + 2        
                  GOTO Quit        
               END        
               ELSE IF @cScanCIDSCN='1'        
               BEGIN        
                  -- Prepare next screen var        
                  SET @cOutField04 = @cSuggID --(yeekung02)        
                  SET @cOutField05 = ''        
        
                  -- Go to confirm LOC screen        
  SET @nScn = @nScn + 4        
                  SET @nStep = @nStep + 4        
               END        
               ELSE        
               BEGIN        
                  -- Dynamic lottable                
                  EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,                
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
      
               IF @cScanCIDSCN='1'      
               BEGIN      
                  -- Prepare next screen var      
                  SET @cOutField04 = @cSuggID --(yeekung02)      
                  SET @cOutField05 = ''      
      
                  -- Go to confirm LOC screen      
                  SET @nScn = @nScn + 4      
                  SET @nStep = @nStep + 4      
                  GOTO Quit_Step5       
               END      
      
               -- (james08)      
               IF @cExtSkuInfoSP <> ''      
               BEGIN      
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
                  BEGIN      
                     SET @cExtDescr1 = ''      
                     SET @cExtDescr2 = ''      
      
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                        ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                        ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
                     SET @cSQLParam =      
                        ' @nMobile      INT,           ' +      
                        ' @nFunc        INT,           ' +      
                        ' @cLangCode    NVARCHAR( 3),  ' +      
                        ' @nStep        INT,           ' +      
                        ' @nInputKey  INT,           ' +      
                        ' @cFacility    NVARCHAR( 5) , ' +      
                        ' @cStorerKey   NVARCHAR( 15), ' +      
                        ' @cType        NVARCHAR( 10), ' +      
                        ' @cPickSlipNo  NVARCHAR( 10), ' +      
                   ' @cPickZone    NVARCHAR( 10), ' +      
                        ' @cDropID      NVARCHAR( 20), ' +      
                        ' @cLOC         NVARCHAR( 10), ' +      
                        ' @cSKU         NVARCHAR( 20), ' +      
                        ' @nQTY         INT,           ' +      
                        ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                        ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                        @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                        @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
                  END      
               END      
                     
               -- Prepare SKU QTY screen var              
               SET @cOutField01 = @cSuggLOC              
               SET @cOutField02 = @cSuggSKU              
               SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
               SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
                  SET @cOutField05 = '' -- SKU/UPC        
                  SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
                  SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                          WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                          ELSE '' END -- QTY        
                  SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))            
          
                  IF @cFieldAttr07='O'          
                     SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                            WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                                            ELSE @nActQTY END -- QTY         
                  ELSE        
                     SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
        
        
                  EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
        
                  -- Go to SKU QTY screen        
                  SET @nScn = @nScn - 2        
                  SET @nStep = @nStep - 2        
                  GOTO Quit        
               END        
            END        
            ELSE        
            BEGIN        
               -- Get task  -- (ChewKP04)              
               SET @cSKUValidated = '0'                
               SET @nActQTY = 0              
               EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTZONE'                
                  ,@cPickSlipNo                
                  ,@cPickZone                
                  ,4               
                  ,@nTtlBalQty       OUTPUT            
                  ,@nBalQty          OUTPUT           
                  ,@cSuggLOC         OUTPUT                
                  ,@cSuggSKU         OUTPUT                
                  ,@cSKUDescr        OUTPUT                
                  ,@nSuggQTY         OUTPUT                
                  ,@cDisableQTYField OUTPUT                
                  ,@cLottableCode    OUTPUT                
                  ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT                
                  ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT                
                  ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT                
                  ,@nErrNo           OUTPUT                
                  ,@cErrMsg          OUTPUT             
                  ,@cSuggID          OUTPUT  --(yeekung02)           
               IF @nErrNo =  0                
       BEGIN            
                              
                  -- Prepare next screen var                
                  SET @cOutField01 = @cPickSlipNo -- '' -- PickSlipNo                
                  SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END            
                  SET @cOutField03 = ''            
                              
                  -- Go to PickZone screen                
                  SET @nScn = @nScn - 3                
                  SET @nStep = @nStep - 3             
                  GOTO Quit        
               END            
               ELSE            
               BEGIN           
                  -- Scan out        
                  SET @nErrNo = 0        
                  EXEC rdt.rdt_PickPiece_ScanOut @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey        
                     ,@cPickSlipNo        
                     ,@nErrNo       OUTPUT        
                     ,@cErrMsg      OUTPUT        
                  IF @nErrNo <> 0        
                     GOTO Quit        
        
        
                  -- Prepare next screen var        
                  SET @cOutField01 = '' -- PickSlipNo        
        
                  -- Go to PickSlipNo screen        
                  SET @nScn = @nScn - 4        
                  SET @nStep = @nStep - 4        
                          
                  GOTO Quit        
               END        
            END        
         END        
      END   -- (james05)        
      ELSE IF @cOption = '3' -- Close DropID                
      BEGIN                
         -- Get task in current LOC                
         SET @cSKUValidated = '0'                
         SET @nActQTY = 0                
         SET @cCurrLOC = @cSuggLOC        
         SET @cCurrSKU = @cSuggSKU        
        
         -- Goto PickZone Screen                
         SET @cOutField01 = @cPickSlipNo                
         SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END            
         SET @cOutField03 = ''                
                
         SET @nScn = @nScn - 3                
         SET @nStep = @nStep - 3                
                
         EXEC rdt.rdtSetFocusField @nMobile, 3 -- DropID                
         GOTO Quit_Step5                
      END                
      ELSE IF @cOption = '4'        
      BEGIN        
         SELECT @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,        
                  @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',        
                  @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL        
        
         -- Get task in next loc        
         SET @cSKUValidated = '0'        
         SET @nActQTY = 0        
         SET @cSKUDescr = 'BALPICK'        
         EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTLOC'        
            ,@cPickSlipNo        
            ,@cPickZone        
            ,4        
            ,@nTtlBalQty       OUTPUT            
            ,@nBalQty          OUTPUT            
            ,@cSuggLOC         OUTPUT        
            ,@cSuggSKU         OUTPUT        
            ,@cSKUDescr        OUTPUT        
 ,@nSuggQTY         OUTPUT        
            ,@cDisableQTYField OUTPUT        
            ,@cLottableCode    OUTPUT        
            ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
            ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
            ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
            ,@nErrNo           OUTPUT        
            ,@cErrMsg          OUTPUT        
            ,@cSuggID          OUTPUT  --(yeekung02)        
         IF @nErrNo = 0        
         BEGIN        
            IF @cConfirmLOC = '1'        
            BEGIN        
               -- Prepare next screen var        
               SET @cOutField01 = @cSuggLOC        
      SET @cOutField02 = '' -- LOC        
        
               -- Go to confirm LOC screen        
               SET @nScn = @nScn + 2        
               SET @nStep = @nStep + 2        
               GOTO Quit        
            END        
            ELSE IF @cScanCIDSCN='1'        
            BEGIN        
               -- Prepare next screen var        
               SET @cOutField04 = @cSuggID --(yeekung02)        
               SET @cOutField05 = ''        
        
               -- Go to confirm LOC screen        
               SET @nScn = @nScn + 4        
               SET @nStep = @nStep + 4        
            END        
            ELSE        
            BEGIN        
               -- Dynamic lottable                
               EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,                
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
      
             IF @cScanCIDSCN='1'      
             BEGIN      
                -- Prepare next screen var                      SET @cOutField04 = @cSuggID --(yeekung02)      
                SET @cOutField05 = ''      
      
                -- Go to confirm LOC screen      
                SET @nScn = @nScn + 4      
                SET @nStep = @nStep + 4      
                GOTO Quit_Step5       
             END      
      
             -- (james08)      
             IF @cExtSkuInfoSP <> ''      
             BEGIN      
                IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
                BEGIN      
                   SET @cExtDescr1 = ''      
                   SET @cExtDescr2 = ''      
      
                   SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                      ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                      ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                      ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                      ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                      ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
                   EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                      @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                      @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                      @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
                END      
             END      
                   
             -- Prepare SKU QTY screen var              
             SET @cOutField01 = @cSuggLOC              
             SET @cOutField02 = @cSuggSKU              
             SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
             SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
              SET @cOutField05 = '' -- SKU/UPC        
              SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
              SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                      WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                      ELSE '' END -- QTY        
              SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))            
      
              IF @cFieldAttr07='O'          
                 SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                        WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                                        ELSE @nActQTY END -- QTY         
              ELSE        
                 SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
      
              EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
      
              -- Go to SKU QTY screen        
              SET @nScn = @nScn - 2        
        SET @nStep = @nStep - 2        
              GOTO Quit        
           END        
         END        
         ELSE        
         BEGIN        
            -- Get task  -- (ChewKP04)              
            SET @cSKUValidated = '0'                
            SET @nActQTY = 0              
            EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTZONE'                
               ,@cPickSlipNo                
               ,@cPickZone                
               ,4               
               ,@nTtlBalQty       OUTPUT            
               ,@nBalQty          OUTPUT           
               ,@cSuggLOC         OUTPUT                
               ,@cSuggSKU         OUTPUT                
               ,@cSKUDescr        OUTPUT                
               ,@nSuggQTY         OUTPUT                
               ,@cDisableQTYField OUTPUT                
               ,@cLottableCode    OUTPUT                
               ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT                
               ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT                
               ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT                
             ,@nErrNo           OUTPUT                
               ,@cErrMsg          OUTPUT             
               ,@cSuggID          OUTPUT  --(yeekung02)           
            IF @nErrNo =  0                
            BEGIN            
                              
               -- Prepare next screen var                
               SET @cOutField01 = @cPickSlipNo -- '' -- PickSlipNo                
               SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END            
               SET @cOutField03 = ''            
                              
               -- Go to PickZone screen      
               SET @nScn = @nScn - 3                
               SET @nStep = @nStep - 3             
               GOTO Quit        
            END            
            ELSE            
            BEGIN           
               -- Scan out        
               SET @nErrNo = 0        
               EXEC rdt.rdt_PickPiece_ScanOut @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey        
                  ,@cPickSlipNo        
                  ,@nErrNo       OUTPUT        
                  ,@cErrMsg      OUTPUT        
               IF @nErrNo <> 0        
                  GOTO Quit        
        
        
               -- Prepare next screen var        
               SET @cOutField01 = '' -- PickSlipNo        
        
               -- Go to PickSlipNo screen        
               SET @nScn = @nScn - 4        
               SET @nStep = @nStep - 4        
                          
               GOTO Quit        
            END        
         END        
      END        
   END                
                
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
                
   IF @cFieldAttr07 = 'O'                
      EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU                
   ELSE                
      EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY                
        
   -- Go to SKU QTY screen                
   SET @nScn = @nScn - 2                
   SET @nStep = @nStep - 2             
           
   -- (ChewKP04)         
   Quit_Step5:        
   IF @cExtendedInfoSP <> ''                
   BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
               ' @nInputKey    INT,           ' +                
               ' @cFacility    NVARCHAR( 5) , ' +                
               ' @cStorerKey   NVARCHAR( 15), ' +                
               ' @cType        NVARCHAR( 10), ' +                
               ' @cPickSlipNo  NVARCHAR( 10), ' +                
               ' @cPickZone    NVARCHAR( 10), ' +                
               ' @cDropID      NVARCHAR( 20), ' +                
               ' @cLOC        NVARCHAR( 10), ' +                
               ' @cSKU         NVARCHAR( 20), ' +                
               ' @nQTY         INT,           ' +                
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 5, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Step_5_Fail          
                    
            IF @nStep IN (3,9)                             
               SET @cOutField12 = @cExtendedInfo             
         END              
   END               
           
   GOTO Quit                
                
   Step_5_Fail:                
   BEGIN                
      -- Reset this screen var                
      SET @cOutField01 = '' --Option                
   END                
           
           
END                
GOTO Quit          
        
        
/********************************************************************************        
Scn = 4645. Skip LOC?        
   Option (field01)        
********************************************************************************/        
Step_6:        
BEGIN        
   IF @nInputKey = 1 -- ENTER        
   BEGIN        
      -- Screen mapping        
      SET @cOption = @cInField01        
        
      -- Validate blank        
      IF @cOption = ''        
      BEGIN        
         SET @nErrNo = 100077        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required        
         GOTO Step_6_Fail        
      END        
        
      -- Validate option        
      IF @cOption <> '1' AND @cOption <> '2'        
      BEGIN        
         SET @nErrNo = 100078        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option        
         GOTO Step_6_Fail        
      END        
        
      IF @cOption = '1'  -- Yes        
      BEGIN        
         SELECT @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,        
                @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',        
                @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL        
        
         -- Get task in current LOC        
         SET @cSKUValidated = '0'        
         SET @nActQTY = 0        
         EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'NEXTLOC'    ---(yeekung02)          
          ,@cPickSlipNo              
          ,@cPickZone              
          ,4              
          ,@nTtlBalQty       OUTPUT              
          ,@nBalQty          OUTPUT            
            ,@cSuggLOC         OUTPUT        
            ,@cSuggSKU         OUTPUT        
            ,@cSKUDescr        OUTPUT        
            ,@nSuggQTY         OUTPUT        
            ,@cDisableQTYField OUTPUT        
            ,@cLottableCode    OUTPUT        
            ,@cLottable01      OUTPUT, @cLottable02  OUTPUT, @cLottable03  OUTPUT, @dLottable04  OUTPUT, @dLottable05  OUTPUT        
            ,@cLottable06      OUTPUT, @cLottable07  OUTPUT, @cLottable08  OUTPUT, @cLottable09  OUTPUT, @cLottable10  OUTPUT        
            ,@cLottable11      OUTPUT, @cLottable12  OUTPUT, @dLottable13  OUTPUT, @dLottable14  OUTPUT, @dLottable15  OUTPUT        
            ,@nErrNo           OUTPUT        
            ,@cErrMsg          OUTPUT        
            ,@cSuggID          OUTPUT  --(yeekung02)        
         IF @nErrNo = 0        
         BEGIN        
            IF @cConfirmLOC = '1'        
            BEGIN        
               -- Prepare next screen var        
               SET @cOutField01 = @cSuggLOC        
               SET @cOutField02 = '' -- LOC        
        
               -- Go to confirm LOC screen        
               SET @nScn = @nScn + 1        
               SET @nStep = @nStep + 1        
            END        
            ELSE IF @cScanCIDSCN='1'        
            BEGIN        
               -- Prepare next screen var        
               SET @cOutField04 = @cSuggID --(yeekung02)        
               SET @cOutField05 = ''        
        
               -- Go to confirm LOC screen        
               SET @nScn = @nScn + 3        
               SET @nStep = @nStep + 3        
            END        
            ELSE        
            BEGIN        
               -- (james03)        
               -- Dynamic lottable        
               EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,         
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
      
               -- (james08)      
               IF @cExtSkuInfoSP <> ''      
               BEGIN      
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
                  BEGIN      
                     SET @cExtDescr1 = ''      
                     SET @cExtDescr2 = ''      
      
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                        ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                        ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                        ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                        ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                        @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                        @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
                  END      
               END      
                     
               -- Prepare SKU QTY screen var      
               SET @cOutField01 = @cSuggLOC      
               SET @cOutField02 = @cSuggSKU      
               SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
               SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
            SET @cOutField05 = '' -- SKU/UPC            
               SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))            
               SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                       WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                       ELSE '' END -- QTY            
            SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))          
        
               EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
        
               -- Disable QTY field        
               SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END        
        
               -- Go to SKU QTY screen        
               SET @nScn = @nScn - 3        
               SET @nStep = @nStep - 3        
            END        
            SET @cSKU =@cSuggSKU        
         END        
         ELSE        
         BEGIN        
            -- Go to no more task in loc screen        
            SET @nScn = @nScn - 2        
            SET @nStep = @nStep - 2        
         END        
                 
         GOTO Quit_Step6        
      END        
   END        
        
   IF @nFromStep = '3'        
   BEGIN        
      -- Prepare SKU QTY screen var        
      SET @cOutField01 = @cSuggLOC        
      SET @cOutField02 = @cSuggSKU        
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)  -- SKU desc 1        
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20) -- SKU desc 2        
      SET @cOutField05 = '' -- SKU/UPC        
      SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
      SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                              WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                              ELSE '' END -- QTY        
        
      -- Disable QTY field        
      SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY        
    SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))         
        
      EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
        
      -- Go to SKU QTY screen        
      SET @nScn = @nScn - 3        
      SET @nStep = @nStep - 3        
   END        
        
   ELSE IF @nFromStep = '7'        
   BEGIN        
      -- Prepare next screen var        
      SET @cOutField01 = @cSuggLOC        
      SET @cOutField02 = '' -- LOC        
        
      -- Go to confirm LOC screen        
      SET @nScn = @nScn + 1        
    SET @nStep = @nStep + 1        
   END        
           
   Quit_Step6:        
   IF @cExtendedInfoSP <> ''                
   BEGIN                
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
      BEGIN                
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
         ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
         SET @cSQLParam =                
            ' @nMobile      INT,           ' +                
            ' @nFunc        INT,           ' +                
            ' @cLangCode    NVARCHAR( 3),  ' +                
            ' @nStep        INT,           ' +                
            ' @nAfterStep   INT,           ' +             
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
            ' @nActQty      INT,           ' +                
            ' @nSuggQTY     INT,           ' +               
            ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
            ' @nErrNo       INT           OUTPUT, ' +                
            ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
             
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
            @nMobile, @nFunc, @cLangCode, 6, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
            @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
             
         IF @nErrNo <> 0                
            GOTO Quit          
                 
         IF @nStep IN (3,9)                                
            SET @cOutField12 = @cExtendedInfo             
      END                
   END          
        
   GOTO Quit        
        
   Step_6_Fail:        
   BEGIN        
      -- Reset this screen var        
      SET @cOutField01 = '' --Option        
   END        
END        
GOTO Quit        
        
        
/********************************************************************************        
Scn = 4646. Confirm LOC        
   Sugg LOC (field01)        
   LOC      (filed02, input)        
********************************************************************************/        
Step_7:        
BEGIN        
   IF @nInputKey = 1 -- ENTER        
   BEGIN        
      DECLARE @cActLOC NVARCHAR(10)        
        
      -- Screen mapping        
      SET @cActLOC = @cInField02        
        
      -- Validate blank        
      IF @cActLOC = ''        
      BEGIN        
         IF @cAllowSkipLOC = '1'        
         BEGIN        
            -- Prepare skip LOC screen var        
            SET @cOutField01 = ''        
        
            -- Remember step        
            SET @nFromStep = @nStep        
        
            -- Go to skip LOC screen        
            SET @nScn = @nScn - 1        
            SET @nStep = @nStep - 1        
        
            GOTO Quit_Step7        
         END        
         ELSE        
         BEGIN        
            SET @nErrNo = 100081        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need LOC        
            GOTO Step_7_Fail        
         END        
      END        
        
      -- Validate option        
      IF @cActLOC <> @cSuggLOC        
      BEGIN        
         SET @nErrNo = 100082        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff LOC        
         GOTO Step_7_Fail        
      END        
        
      -- (james03)        
      -- Dynamic lottable        
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,         
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
        
      IF @cScanCIDSCN='1'        
      BEGIN        
         -- Prepare next screen var        
         SET @cOutField04 = @cSuggID --(yeekung02)        
         SET @cOutField05 = ''        
        
         -- Go to confirm LOC screen        
         SET @nScn = @nScn + 2        
         SET @nStep = @nStep + 2        
      END        
      ELSE        
      BEGIN        
         -- (james08)      
         IF @cExtSkuInfoSP <> ''      
         BEGIN      
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
            BEGIN      
               SET @cExtDescr1 = ''      
               SET @cExtDescr2 = ''      
      
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
                  ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
                  ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
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
                  ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
                  ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
                  @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
                  @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
            END      
         END      
              
         -- Prepare SKU QTY screen var      
         SET @cOutField01 = @cSuggLOC      
         SET @cOutField02 = @cSuggSKU      
         SET @cOutField03 = CASE WHEN ISNULL(@cExtDescr1,'') NOT IN('','0') THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
         SET @cOutField04 = CASE WHEN ISNULL(@cExtDescr2,'') NOT IN('','0') THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
         SET @cOutField05 = '' -- SKU/UPC        
         SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
         SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                 WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                 ELSE '' END -- QTY        
        
         EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
        
         -- Disable QTY field        
         SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END        
        
         SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))           
              
        
         -- Go to SKU QTY screen        
         SET @nScn = @nScn - 4        
         SET @nStep = @nStep - 4        
      END        
              
       Quit_Step7:        
      IF @cExtendedInfoSP <> ''                
      BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
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
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 7, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Quit          
                    
            IF @nStep IN( 3 ,9)                              
               SET @cOutField12 = @cExtendedInfo             
                    
         END                
      END          
   END        
        
   IF @nInputKey = 0 -- ESC        
   BEGIN        
      -- Prepare LOC screen var        
      SET @cOutField01 = @cPickSlipNo        
      SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END            
      SET @cOutField03 = '' --DropID        
  
      SET @cCurrLOC=@cSuggLOC  
      SET @cCurrSKU=@cSuggSKU  
        
      EXEC rdt.rdtSetFocusField @nMobile, 2 -- PickZone        
        
      -- Go to prev screen        
      SET @nScn = @nScn - 5        
      SET @nStep = @nStep - 5        
   END        
   GOTO Quit        
        
   Step_7_Fail:        
   BEGIN        
      -- Reset this screen var        
      SET @cOutField02 = '' --LOC        
   END        
END        
GOTO Quit        
        
/********************************************************************************        
Scn = 4647. ABORT PICK        
   Option (field01, input)        
********************************************************************************/        
Step_8:        
BEGIN        
   IF @nInputKey = 1 -- ENTER        
   BEGIN        
      -- Screen mapping        
      SET @cOption = @cInField01        
        
      -- Validate blank        
      IF @cOption = ''        
      BEGIN        
         SET @nErrNo = 100084        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required        
         GOTO Step_8_Fail        
      END        
        
      -- Validate option        
      IF @cOption <> '1' AND @cOption <> '2'        
      BEGIN        
         SET @nErrNo = 100085        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option        
         GOTO Step_8_Fail        
      END        
        
      IF @cOption = '1'  -- Yes        
      BEGIN        
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
                  ',@nErrNo          INT           OUTPUT     ' +                
                  ',@cErrMsg     NVARCHAR(250) OUTPUT     '                 
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,                 
                  @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @cOption, @cLottableCode,                 
                  @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,                 
                  @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,                 
                  @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,                 
                  @nErrNo OUTPUT, @cErrMsg OUTPUT                 
                
               IF @nErrNo <> 0                
                  GOTO Step_8_Fail                
            END        
         END        
        
         IF @cExtendedInfoSP <> ''                
         BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
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
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 7, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Quit          
                    
            IF @nStep IN( 3 ,9)            
               SET @cOutField12 = @cExtendedInfo             
                    
         END                
      END          
        
         IF @cScanCIDSCN='1'        
         BEGIN        
            -- Prepare next screen var        
            SET @cOutField01 = @cSuggLOC        
            SET @cOutField04 = @cSuggID --(yeekung02)        
            SET @cOutField05 = ''        
            SET @nActQTY=0        
        
            -- Go to confirm LOC screen        
            SET @nScn = @nScn + 1        
            SET @nStep = @nStep + 1        
            GOTO QUIT        
         END        
         ELSE IF @cConfirmLOC = '1'        
         BEGIN        
            -- Prepare next screen var        
            SET @cOutField01 = @cSuggLOC        
            SET @cOutField02 = '' -- LOC        
            SET @nActQTY=0        
        
            -- Go to confirm LOC screen        
            SET @nScn = @nScn - 1        
            SET @nStep = @nStep - 1        
            GOTO QUIT        
         END        
        
         -- Prepare LOC screen var        
         SET @cOutField01 = @cPickSlipNo        
         SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END         
         SET @cOutField03 = '' --DropID        
         SET @nTtlBalQty = 0            
         SET @nBalQty = 0            
        
         EXEC rdt.rdtSetFocusField @nMobile, 2 -- PickZone        
        
         -- Enable field        
         SET @cFieldAttr07 = '' -- QTY        
        
         -- Go to prev screen        
         SET @nScn = @nFromScn - 1        
         SET @nStep = @nFromStep - 1        
      END        
        
      IF @cOption = '2'  -- No        
      BEGIN        
         -- Prepare SKU QTY screen var        
         SET @cOutField01 = @cSuggLOC        
         SET @cOutField02 = @cSuggSKU        
         SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)  -- SKU desc 1        
         SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20) -- SKU desc 2        
         SET @cOutField05 =  '' -- SKU/UPC        
         SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
         SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                                 WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                                 ELSE '' END -- QTY        
        
         -- Disable QTY field        
         SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY        
                 
         IF @cFieldAttr07='O'          
         SET @cOutField07= @nActQTY          
        
         IF @cDefaultSKU ='1'        
         BEGIN        
            SET @cOutField05=@cSuggSKU        
            SET @cOutField07=@nSuggQTY        
         END        
          
         SET @cOutField13 =LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))            
        
         EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
        
         -- Go to SKU QTY screen        
         SET @nScn = @nFromScn        
         SET @nStep = @nFromStep        
      END        
   END        
        
   IF @nInputKey = 0 -- ESC        
   BEGIN        
      -- Prepare SKU QTY screen var        
      SET @cOutField01 = @cSuggLOC        
      SET @cOutField02 = @cSuggSKU        
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)  -- SKU desc 1        
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20) -- SKU desc 2        
      SET @cOutField05 = CASE WHEN @cDefaultSKU='1' THEN @cSuggSKU ELSE '' END-- SKU/UPC        
      SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
      SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                              WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                              ELSE @nActQTY END -- QTY        
        
      -- Disable QTY field        
      SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY        
        
      EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
        
      -- Go to SKU QTY screen        
      SET @nScn = @nFromScn        
      SET @nStep = @nFromStep        
   END        
   GOTO Quit        
        
   Step_8_Fail:        
   BEGIN        
      -- Reset this screen var        
      SET @cOutField01 = '' --Option        
   END        
END        
GOTO Quit        
        
/********************************************************************************        
Scn = 4648. cartionid        
   cartionid (field04, input)        
********************************************************************************/        
Step_9:        
BEGIN        
   IF @nInputKey = 1 -- ENTER        
   BEGIN        
      -- Screen mapping        
      SET @cCartonID = @cInField05        
        
      -- Validate blank        
      IF @cCartonID = ''        
      BEGIN        
         SET @nErrNo = 100087        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option required        
         GOTO Step_9_Fail        
      END        
        
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'CartonID', @cCartonID) = 0        
      BEGIN        
         SET @nErrNo = 100088        
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format        
         GOTO Step_9_Fail        
      END        
        
            -- Decode ID          
      IF @cDecodeIDSP <> ''          
      BEGIN          
         SET @cDefaultSKU=''        
         -- (ChewKP03)           
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeIDSP AND type = 'P')          
         BEGIN          
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeIDSP) +          
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo,@cPickZone,  ' +          
               ' @cDefaultQTY OUTPUT,@cCartonID OUTPUT, @cSuggSKU OUTPUT,@cSKUDescr OUTPUT,@nSuggQTY OUTPUT,@cDefaultSKU OUTPUT,@cSuggID OUTPUT,@cSuggLoc OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'          
            SET @cSQLParam =          
               ' @nMobile      INT,             ' +          
               ' @nFunc        INT,             ' +          
               ' @cLangCode    NVARCHAR( 3),    ' +          
               ' @nStep        INT,             ' +          
               ' @nInputKey    INT,             ' +          
               ' @cFacility    NVARCHAR( 5),    ' +          
               ' @cStorerKey   NVARCHAR( 15),   ' +          
               ' @cPickSlipNo  NVARCHAR( 20),   ' +        
               ' @cPickZone    NVARCHAR( 15),   ' +        
               ' @cDefaultQTY  NVARCHAR(  1)  OUTPUT, ' +        
               ' @cCartonID    NVARCHAR( 20)  OUTPUT, ' +          
               ' @cSuggSKU     NVARCHAR( 20)  OUTPUT, ' +         
               ' @cSKUDescr    NVARCHAR( 60)  OUTPUT, ' +        
               ' @nSuggQTY     INT            OUTPUT, ' +         
               ' @cDefaultSKU  NVARCHAR(  1)  OUTPUT, ' +        
               ' @cSuggID      NVARCHAR(20)   OUTPUT, ' +         
               ' @cSuggLoc     NVARCHAR(20)   OUTPUT, ' +         
               ' @nErrNo       INT            OUTPUT, ' +          
               ' @cErrMsg      NVARCHAR( 20)  OUTPUT '         
             
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,          
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPickSlipNo,@cPickZone,           
               @cDefaultQTY OUTPUT,@cCartonID OUTPUT, @cSuggSKU OUTPUT,@cSKUDescr OUTPUT,@nSuggQTY OUTPUT,@cDefaultSKU OUTPUT,@cSuggID OUTPUT,@cSuggLoc OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT        
            IF @nErrNo <> 0          
               GOTO Step_9_Fail          
                         
         END          
      END          
        
              
        
      IF @cSuggID<>@cCartonID        
      BEGIN        
         IF (@cCartonID='99')        
         BEGIN        
            SET @cInField01='1'        
         END        
         ELSE        
         BEGIN        
            SET @nErrNo = 100089        
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format        
            GOTO Step_9_Fail        
         END        
      END        
        
      -- Dynamic lottable        
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSuggSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 4, 8,         
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
              
      -- Prepare SKU QTY screen var        
      SET @cOutField01 = @cSuggLOC        
      SET @cOutField02 = @cSuggSKU        
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)  -- SKU desc 1        
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20) -- SKU desc 2        
      SET @cOutField05 = CASE WHEN @cDefaultSKU='1' THEN @cSuggSKU ELSE '' END-- SKU/UPC        
      SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
      SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                              WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY        
                              ELSE '' END -- QTY        
        
      -- Disable QTY field        
      SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY        
        
      EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU        
        
      -- Go to SKU QTY screen        
      SET @nScn = @nScn-6        
      SET @nStep = @nStep-6        
        
        
      Quit_STEP_9:        
      IF @cExtendedInfoSP <> ''                
      BEGIN                
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
         BEGIN                
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
               ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
            SET @cSQLParam =                
               ' @nMobile      INT,           ' +                
               ' @nFunc        INT,           ' +                
               ' @cLangCode    NVARCHAR( 3),  ' +                
               ' @nStep        INT,           ' +                
               ' @nAfterStep   INT,           ' +             
               ' @nInputKey    INT,    ' +                
               ' @cFacility    NVARCHAR( 5) , ' +         
               ' @cStorerKey   NVARCHAR( 15), ' +                
               ' @cType        NVARCHAR( 10), ' +                
               ' @cPickSlipNo  NVARCHAR( 10), ' +                
               ' @cPickZone    NVARCHAR( 10), ' +                
               ' @cDropID      NVARCHAR( 20), ' +                
               ' @cLOC         NVARCHAR( 10), ' +                
               ' @cSKU         NVARCHAR( 20), ' +                
               ' @nQTY         INT,           ' +                
               ' @nActQty      INT,           ' +                
               ' @nSuggQTY     INT,           ' +                
               ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
               ' @nErrNo       INT           OUTPUT, ' +                
               ' @cErrMsg      NVARCHAR(250) OUTPUT  '                
                
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
               @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
               @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
            IF @nErrNo <> 0                
               GOTO Step_9_Fail          
                    
            IF @nStep IN (3,9)       
            BEGIN                             
               SET @cOutField12 = @cExtendedInfo         
               IF @cCartonID='99'        
               BEGIN        
                  SET @nStep=@nStep+2        
                  SET @nScn=@nScn+2        
                  GOTO STEP_5        
               END        
            END        
         END                
      END          
        
   END        
        
   IF @nInputKey = 0 -- ESC        
   BEGIN        
        
      IF @cConfirmLOC = '1'        
      BEGIN        
         -- Prepare next screen var        
         SET @cOutField01 = @cSuggLOC        
         SET @cOutField02 = '' -- LOC        
        
         -- Go to confirm LOC screen        
         SET @nScn = @nScn -2        
         SET @nStep = @nStep -2        
      END        
      ELSE        
      BEGIN        
               
         -- Prepare next screen var        
         SET @cOutField01 = @cPickSlipNo        
         SET @cOutField02 = '' --PickZone        
         SET @cOutField03 = '' --DropID        
         SET @nTtlBalQty = 0            
         SET @nBalQty = 0          
         SET @cSuggLOC = ''          
         SET @cCurrLOC = ''        
         SET @cSkippedSKU = ''        
        
         EXEC rdt.rdtSetFocusField @nMobile, 2 -- PickZone        
        
         -- Go to SKU QTY screen        
         SET @nScn = @nScn-7        
         SET @nStep = @nStep-7        
      END        
   END        
   GOTO Quit        
        
   Step_9_Fail:        
   BEGIN        
      -- Reset this screen var        
      SET @cCartonid = '' --Cartonid        
      SET @cOutfield05 = '' --Option        
   END        
END        
GOTO Quit        
      
/********************************************************************************      
Step 10. Screen = 3125. Multi SKU      
   SKU         (Field01)      
   SKUDesc1    (Field02)      
   SKUDesc2    (Field03)      
   SKU         (Field04)      
   SKUDesc1    (Field05)      
   SKUDesc2    (Field06)      
   SKU         (Field07)      
   SKUDesc1    (Field08)      
   SKUDesc2    (Field09)      
   Option      (Field10, input)      
********************************************************************************/      
Step_10:      
BEGIN      
   IF @nInputKey = 1 -- ENTER      
   BEGIN      
      EXEC rdt.rdt_MultiSKUBarcode @nMobile, @nFunc, @cLangCode,      
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,      
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,      
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,      
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,      
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,      
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,      
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,      
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,      
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,      
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,      
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,      
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,      
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,      
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,      
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,      
         'CHECK',      
         @cMultiSKUBarcode,      
         @cStorerKey,      
         @cUPC     OUTPUT,      
         @nErrNo   OUTPUT,      
         @cErrMsg  OUTPUT      
      
      IF @nErrNo <> 0      
      BEGIN      
         IF @nErrNo = -1      
            SET @nErrNo = 0      
         GOTO Quit      
      END      
      
      SET @cSuggSKU = @cUPC      
      
      -- Get SKU info      
      SELECT @cSKUDescr = Descr FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSuggSKU      
   END      
      
   IF @cExtSkuInfoSP <> ''      
   BEGIN      
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtSkuInfoSP AND type = 'P')      
      BEGIN      
         SET @cExtDescr1 = ''      
         SET @cExtDescr2 = ''      
      
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtSkuInfoSP) +      
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +      
            ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, ' +       
            ' @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT '      
         SET @cSQLParam =      
            ' @nMobile      INT,           ' +      
            ' @nFunc        INT,           ' +      
            ' @cLangCode    NVARCHAR( 3),  ' +      
            ' @nStep    INT,           ' +      
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
            ' @cExtDescr1   NVARCHAR( 20) OUTPUT, ' +      
            ' @cExtDescr2   NVARCHAR( 20) OUTPUT  '       
      
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,      
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,      
            @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,       
            @cExtDescr1 OUTPUT, @cExtDescr2 OUTPUT      
      END      
   END      
               
   -- Prepare next screen var        
   SET @cOutField01 = @cSuggLOC        
   SET @cOutField02 = @cSuggSKU        
   SET @cOutField03 = CASE WHEN @cExtDescr1 <> '' THEN @cExtDescr1 ELSE rdt.rdtFormatString( @cSKUDescr, 1, 20) END      
   SET @cOutField04 = CASE WHEN @cExtDescr2 <> '' THEN @cExtDescr2 ELSE rdt.rdtFormatString( @cSKUDescr, 21, 20) END      
   SET @cOutField05 = @cSuggSKU        
   SET @cOutField06 = CAST( @nSuggQTY AS NVARCHAR(6))        
   SET @cOutField07 = CASE WHEN @cDefaultQTY = '1' THEN  CAST( @nSuggQTY AS NVARCHAR(6))         
                           WHEN @cDefaultPickQTY <> '0' THEN  @cDefaultPickQTY        
                           ELSE '' END -- QTY            
   SET @cOutField13 = LTRIM(CAST(@nBalQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))             
            
   EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU            
            
   -- Disable QTY field            
   SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY            
    
   IF @cFieldAttr07='O'          
      SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))         
                              WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY         
                              ELSE @nActQTY END -- QTY         
   ELSE        
      SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END        
      
   IF @cExtendedInfoSP <> ''                
   BEGIN                
     IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')                
      BEGIN                
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +                
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cType, ' +                
            ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY,  @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT     '                
         SET @cSQLParam =                
            ' @nMobile      INT,           ' +                
            ' @nFunc        INT,           ' +                
            ' @cLangCode    NVARCHAR( 3),  ' +                
            ' @nStep        INT,           ' +                
            ' @nAfterStep   INT,           ' +             
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
            ' @nActQty      INT,           ' +                
            ' @nSuggQTY     INT,           ' +                
            ' @cExtendedInfo NVARCHAR(20) OUTPUT,  ' +                
            ' @nErrNo       INT           OUTPUT, ' +                
            ' @cErrMsg      NVARCHAR(250) OUTPUT  '            
                
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,                
            @nMobile, @nFunc, @cLangCode, 2, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,                
            @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @nActQty, @nSuggQTY, @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT                
                
         IF @nErrNo <> 0                
            GOTO Step_2_Fail          
                    
         IF @nStep IN (3,9)                                 
         SET @cOutField12 = @cExtendedInfo             
      END                
   END          
            
   -- Go to SKU screen      
   SET @nScn = @nFromScn      
   SET @nStep = @nStep - 7      
      
END      
GOTO Quit      
      
/********************************************************************************        
Quit. Update back to I/O table, ready to be pick up by JBOSS        
********************************************************************************/        
Quit:        
BEGIN        
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET        
      EditDate = GETDATE(),        
      ErrMsg = @cErrMsg,        
      Func   = @nFunc,        
      Step   = @nStep,        
      Scn    = @nScn,        
        
      StorerKey      = @cStorerKey,        
      Facility       = @cFacility,        
      -- UserName       = @cUserName,        
        
      V_LoadKey      = @cLoadKey,        
      V_OrderKey     = @cOrderKey,        
      V_PickSlipNo   = @cPickSlipNo,        
      V_Zone         = @cPickZone,        
      V_LOC          = @cSuggLOC,        
      V_SKU          = @cSuggSKU,        
      V_SKUDescr     = @cSKUDescr,        
      V_QTY          = @nSuggQTY,        
       
      V_FromStep     = @nFromStep,        
      V_FromScn      = @nFromScn,        
        
      V_Integer1     = @nActQTY,        
      V_Integer2     = @nTtlBalQty,        
      V_Integer3     = @nBalQty,        
        
      V_Lottable01   = @cLottable01,        
      V_Lottable02   = @cLottable02,        
      V_Lottable03   = @cLottable03,        
      V_Lottable04   = @dLottable04,        
      V_Lottable05   = @dLottable05,        
      V_Lottable06   = @cLottable06,        
      V_Lottable07   = @cLottable07,        
      V_Lottable08   = @cLottable08,        
      V_Lottable09   = @cLottable09,        
      V_Lottable10   = @cLottable10,        
      V_Lottable11   = @cLottable11,        
      V_Lottable12   = @cLottable12,        
      V_Lottable13   = @dLottable13,        
      V_Lottable14   = @dLottable14,        
      V_Lottable15   = @dLottable15,        
              
      V_String1      = @cZone,        
      V_String2      = @cSKUValidated,        
      V_String3      = @cMultiSKUBarcode,      
      V_String4      = @cDropID,        
      V_String5      = @cCurrSKU,        
      V_String6      = @cLottableCode,        
      V_String7      = @cCurrLOC,        
      V_String8      = @cSkippedSKU,        
      V_String9      = @cPickZoneMandatory,        
      V_String10     = @cDefaultPickQTY,        
      V_String11     = @cDiscardKeyword99,        
    V_String12   = @cExtDescr1,      
    V_String13     = @cExtDescr2,      
    V_String14     = @cSkipConfirmBalPick,  --(cc01)      
      
      V_String21     = @cExtendedValidateSP,        
      V_String22     = @cExtendedUpdateSP,        
      V_String23     = @cExtendedInfoSP,        
      V_String24     = @cExtendedInfo,        
      V_String25     = @cDecodeSP,        
        
      V_String27     = @cDefaultQTY,        
      V_String28     = @cAllowSkipLOC,        
      V_String29     = @cConfirmLOC,        
      V_String30     = @cDisableQTYField,        
      V_String31     = @cPickConfirmStatus,        
      V_String32     = @cAutoScanOut,        
      V_String33     = @cDefaultPickZone,             
      V_String34     = @cExtendedInfo,        
      V_String35     = @cCartonID,   --(yeekung02)        
      V_String36     = @cScanCIDSCN, --(yeekung02)        
      V_String37     = @cDecodeIDSP, --(yeekung02)        
      V_String38     = @cSuggID, --(yeekung02)        
      V_String39     = @cDefaultsku, --(yeekung02)        
      V_String40     = @cExtSkuInfoSP,  -- (james08)      
            
      I_Field01 = '',  O_Field01 = @cOutField01,   FieldAttr01  = @cFieldAttr01,        
      I_Field02 = '',  O_Field02 = @cOutField02,   FieldAttr02  = @cFieldAttr02,        
      I_Field03 = '',  O_Field03 = @cOutField03,   FieldAttr03  = @cFieldAttr03,        
      I_Field04 = '',  O_Field04 = @cOutField04,   FieldAttr04  = @cFieldAttr04,        
      I_Field05 = '',  O_Field05 = @cOutField05,   FieldAttr05  = @cFieldAttr05,        
      I_Field06 = '',  O_Field06 = @cOutField06,   FieldAttr06  = @cFieldAttr06,        
      I_Field07 = '',  O_Field07 = @cOutField07,   FieldAttr07  = @cFieldAttr07,        
      I_Field08 = '',  O_Field08 = @cOutField08,   FieldAttr08  = @cFieldAttr08,        
      I_Field09 = '',  O_Field09 = @cOutField09,   FieldAttr09  = @cFieldAttr09,        
      I_Field10 = '',  O_Field10 = @cOutField10,   FieldAttr10  = @cFieldAttr10,        
      I_Field11 = '',  O_Field11 = @cOutField11,   FieldAttr11  = @cFieldAttr11,        
      I_Field12 = '',  O_Field12 = @cOutField12,   FieldAttr12  = @cFieldAttr12,        
      I_Field13 = '',  O_Field13 = @cOutField13,   FieldAttr13  = @cFieldAttr13,        
      I_Field14 = '',  O_Field14 = @cOutField14,   FieldAttr14  = @cFieldAttr14,        
      I_Field15 = '',  O_Field15 = @cOutField15,   FieldAttr15  = @cFieldAttr15        
        
   WHERE Mobile = @nMobile        
END 
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtfnc_PickPiece TO NSQL
GO



