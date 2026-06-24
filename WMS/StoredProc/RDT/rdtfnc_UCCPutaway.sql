  
/*****************************************************************************/  
/* Store procedure: rdtfnc_UCCPutaway                                        */  
/* Copyright      : Maersk                                                   */  
/*                                                                           */  
/* Purpose: Putaway by UCC                                                   */  
/*                                                                           */  
/* Called from: 3                                                            */  
/*    1. From PowerBuilder                                                   */  
/*    2. From scheduler                                                      */  
/*    3. From others stored procedures or triggers                           */  
/*    4. From interface program. DX, DTS                                     */  
/*                                                                           */  
/* Exceed version: 5.4                                                       */  
/*                                                                           */  
/* Modifications log:                                                        */  
/*                                                                           */  
/* Date        Rev      Author   Purposes                                    */  
/* 08-Aug-2006 1.0      MaryVong Created                                     */  
/* 14-Feb-2014 1.1      James    SOS301473 - Rewrite (james01)               */  
/* 05-Oct-2015 1.2      James    SOS353559 - Add ExtendedValidateSP(james02) */  
/*                               Add ExtendedUpdateSP                        */  
/* 30-Jun-2016 1.2      James    Bug fix (james02)                           */  
/* 03-Aug-2016 1.3      James    SOS373949 Add PAZone & ExtendedInfoSP       */  
/*                               to screen 2 (james03)                       */  
/* 10-Sep-2016 1.4      Ung      IN00147078 Fix missing transaction protect  */  
/* 30-Sep-2016 1.5      Ung      Performance tuning                          */  
/* 31-Mar-2017 1.6      James    WMS1481-Add GetSuggestedLoc sp (james04)    */  
/* 31-Jan-2018 1.7      Ung      INC0120413 Fix move UCC without LOT         */  
/* 04-Oct-2018 1.8      TungGH   Performance                                 */  
/* 09-Oct-2018 1.9      ChewKP   WMS-5157 Add ExtendedUpdate SP config       */  
/*                               to step 1 (chewKP01)                        */  
/* 08-Oct-2019 2.0      Chermain WMS-10753 Change a paramater                */  
/*                      when exec rdt_Putaway (cc01)                         */  
/* 30-Sep-2019 2.1      Ung      WMS-10642 Fix NoSuitableLOC not go next scn */  
/* 27-Mar-2020 2.2      Ung      WMS-12634 ConfirmSP                         */  
/*                               Performance tuning                          */  
/* 29-Mar-2021 2.3      Chermain WMS-16559 Add PAMatchSuggestLOC config(cc02)*/  
/* 19-Aug-2021 2.4      Chermain WMS-17673 Add ExtendedInfo in st2&5 (cc03)  */  
/* 03-SEP-2021 2.5      James    WMS-17795 Remove hardcode PA Zone display   */  
/*                               by config (james05)                         */  
/* 21-Feb-2022 2.6      Yeekung  JSM-52910 comment step_1_fail (yeekung01)   */
/* 16-Apr-2024 2.7      James    WMS-25257 Skip mix sku ucc scn (james06)    */
/* 17-Oct-2024 2.8      ShaoAn   FCR-759-1000 ID and UCC Length Issue        */
/* 24-Oct-2024 2.8.1             Remove Customer Recode                      */
/* 14-Mar-2025 2.9.0    Dennis   FCR-3449 Extended Screen                    */
/* 29-May-2025 3.0.0    Dennis   UWP-35136 Fix Bug (de01)                    */
/************************** Merged Into V0 ***********************************/
/* 26-Aug-2025 3.1.0    Dennis   UWP-40042 Fix Bug                           */
/* 23-Oct-2025 3.2      Ung      FCR-8111 Add 2D UCC barcode                 */
/*                               Add suggest alternate LOC                   */
/* 23-Jun-2026 3.3.0    Jack     FCR-14022 Add LOC check digit in step 2     */
/*****************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdtfnc_UCCPutaway] (  
   @nMobile    INT,  
   @nErrNo     INT  OUTPUT,  
   @cErrMsg    NVARCHAR( 20) OUTPUT -- screen limitation, 20 char max  
) AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
-- Other var use in this stor proc  
DECLARE  
   @cSQL                NVARCHAR( MAX),  
   @cSQLParam           NVARCHAR( MAX)  
  
DECLARE  
   @nFunc               INT,  
   @nScn                INT,  
   @nCurScn             INT,  -- Current screen variable  
   @nStep               INT,  
   @nCurStep            INT,  
   @cLangCode           NVARCHAR( 3),  
   @nInputKey           INT,  
   @nMenu               INT,  
  
   @cStorerkey          NVARCHAR( 15),  
   @cFacility           NVARCHAR( 5),  
   @cPrinter            NVARCHAR( 10),  
   @cUserName           NVARCHAR( 18),  
   @cPUOM               NVARCHAR( 10),  
  
   @cBarcode            NVARCHAR( MAX),
   @cUCCNo              NVARCHAR( 20),  
   @cFromLOC            NVARCHAR( 10),  
   @cID                 NVARCHAR( 18),  
   @cToLOC              NVARCHAR( 10),  
   @cSuggestedLOC       NVARCHAR( 10),  
   @cPickAndDropLoc     NVARCHAR( 10),  
   @cSKU                NVARCHAR( 20),  
   @cOption             NVARCHAR( 1),  
   @cExtScnSP           NVARCHAR( 20),
   @tExtScnData         VariableTable,
   @nAction             INT,
   @nAfterScn           INT,
   @nAfterStep          INT,
  
   @nMultiSKU           INT,  
   @nUCCQTY             INT,  
   @nQTYAlloc           INT,  
   @nTotalRec           INT,  
   @cExtendedValidateSP NVARCHAR( 20),    -- (james02)  
   @cExtendedUpdateSP   NVARCHAR( 20),    -- (james02)  
   @cExtendedInfo       NVARCHAR( 20),    -- (james03)  
   @cExtendedInfoSP     NVARCHAR( 20),    -- (james03)  
   @cPAZone             NVARCHAR( 10),    -- (james03)  
   @cLOT                NVARCHAR( 10),    -- (james04)  
   @nPABookingKey       INT,              -- (james04)  
   @nPAErrNo            INT,              -- (james04)  
   @cPAMatchSuggestLOC  NVARCHAR( 1),     -- (cc02)  
   @cNotDisplayPAZone   NVARCHAR( 1),
   @cPutawayMixSKUUCC   NVARCHAR( 1),     -- (james06)  
   @cDecodeSP           NVARCHAR( 20),    ---(ShaoAn)
   @cLOCCheckDigitSP    NVARCHAR( 20),    -- FCR-14022
   @cCheckDigitLOC      NVARCHAR( 20),    -- FCR-14022

   @cLottable01         NVARCHAR( 18),
   @cLottable02         NVARCHAR( 18),
   @cLottable03         NVARCHAR( 18),
   @dLottable04         DATETIME,
   @dLottable05         DATETIME,
   @cLottable06         NVARCHAR( 30),
   @cLottable07         NVARCHAR( 30),
   @cLottable08         NVARCHAR( 30),
   @cLottable09         NVARCHAR( 30),
   @cLottable10         NVARCHAR( 30),
   @cLottable11         NVARCHAR( 30),
   @cLottable12         NVARCHAR( 30),
   @dLottable13         DATETIME,
   @dLottable14         DATETIME,
   @dLottable15         DATETIME,

   @cInField01 NVARCHAR( 60),  @cOutField01 NVARCHAR( 60),  @cFieldAttr01 NVARCHAR( 1),  
   @cInField02 NVARCHAR( 60),  @cOutField02 NVARCHAR( 60),  @cFieldAttr02 NVARCHAR( 1),  
   @cInField03 NVARCHAR( 60),  @cOutField03 NVARCHAR( 60),  @cFieldAttr03 NVARCHAR( 1),  
   @cInField04 NVARCHAR( 60),  @cOutField04 NVARCHAR( 60),  @cFieldAttr04 NVARCHAR( 1),  
   @cInField05 NVARCHAR( 60),  @cOutField05 NVARCHAR( 60),  @cFieldAttr05 NVARCHAR( 1),  
   @cInField06 NVARCHAR( 60),  @cOutField06 NVARCHAR( 60),  @cFieldAttr06 NVARCHAR( 1),  
   @cInField07 NVARCHAR( 60),  @cOutField07 NVARCHAR( 60),  @cFieldAttr07 NVARCHAR( 1),  
   @cInField08 NVARCHAR( 60),  @cOutField08 NVARCHAR( 60),  @cFieldAttr08 NVARCHAR( 1),  
   @cInField09 NVARCHAR( 60),  @cOutField09 NVARCHAR( 60),  @cFieldAttr09 NVARCHAR( 1),  
   @cInField10 NVARCHAR( 60),  @cOutField10 NVARCHAR( 60),  @cFieldAttr10 NVARCHAR( 1),  
   @cInField11 NVARCHAR( 60),  @cOutField11 NVARCHAR( 60),  @cFieldAttr11 NVARCHAR( 1),  
   @cInField12 NVARCHAR( 60),  @cOutField12 NVARCHAR( 60),  @cFieldAttr12 NVARCHAR( 1),  
   @cInField13 NVARCHAR( 60),  @cOutField13 NVARCHAR( 60),  @cFieldAttr13 NVARCHAR( 1),  
   @cInField14 NVARCHAR( 60),  @cOutField14 NVARCHAR( 60),  @cFieldAttr14 NVARCHAR( 1),  
   @cInField15 NVARCHAR( 60),  @cOutField15 NVARCHAR( 60),  @cFieldAttr15 NVARCHAR( 1),    
    
   @cUDF01  NVARCHAR( 250), @cUDF02 NVARCHAR( 250), @cUDF03 NVARCHAR( 250),
   @cUDF04  NVARCHAR( 250), @cUDF05 NVARCHAR( 250), @cUDF06 NVARCHAR( 250),
   @cUDF07  NVARCHAR( 250), @cUDF08 NVARCHAR( 250), @cUDF09 NVARCHAR( 250),
   @cUDF10  NVARCHAR( 250), @cUDF11 NVARCHAR( 250), @cUDF12 NVARCHAR( 250),
   @cUDF13  NVARCHAR( 250), @cUDF14 NVARCHAR( 250), @cUDF15 NVARCHAR( 250),
   @cUDF16  NVARCHAR( 250), @cUDF17 NVARCHAR( 250), @cUDF18 NVARCHAR( 250),
   @cUDF19  NVARCHAR( 250), @cUDF20 NVARCHAR( 250), @cUDF21 NVARCHAR( 250),
   @cUDF22  NVARCHAR( 250), @cUDF23 NVARCHAR( 250), @cUDF24 NVARCHAR( 250),
   @cUDF25  NVARCHAR( 250), @cUDF26 NVARCHAR( 250), @cUDF27 NVARCHAR( 250),
   @cUDF28  NVARCHAR( 250), @cUDF29 NVARCHAR( 250), @cUDF30 NVARCHAR( MAX)  
  
-- Getting Mobile information  
SELECT  
   @nFunc      = Func,  
   @nScn       = Scn,  
   @nStep      = Step,  
   @nInputKey  = InputKey,  
   @nMenu      = Menu,  
   @cLangCode  = Lang_code,  
  
   @cStorerkey = StorerKey,  
   @cFacility  = Facility,  
   @cPrinter   = Printer,  
   @cUserName  = UserName,  
  
   @cFromLOC      = V_LOC,  
   @cUCCNo        = V_UCC,  
   @cID           = V_ID,  
   @cSKU          = V_SKU,  
   @cLOT          = V_LOT,  
   @nUCCQTY       = V_QTY,  
   @cBarcode      = V_Barcode,
  
   @cSuggestedLOC       = V_String1,  
   @cPAZone             = V_String2,
   @cPutawayMixSKUUCC   = V_String3,  
   @cPickAndDropLoc     = V_String4,
     
   @cExtendedInfoSP     = V_String21,  
   @cExtendedInfo       = V_String22,  
   @cExtendedUpdateSP   = V_String23,  
   @cExtendedValidateSP = V_String24,  
   @cPAMatchSuggestLOC  = V_String25, --(cc02)  
   @cToLOC              = V_String26, --(cc02)  
   @cNotDisplayPAZone   = V_String27,  
   @cDecodeSP           = V_String28, --(ShaoAn) 
   @cExtScnSP           = V_String29,
   @cLOCCheckDigitSP    = V_String30,  -- FCR-14022

   @nPABookingKey = V_Integer1,
  
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
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,  @cFieldAttr15 = FieldAttr15  
  
FROM RDT.RDTMOBREC (NOLOCK)  
WHERE Mobile = @nMobile  
  
-- Redirect to respective screen  
IF @nFunc = 521  
BEGIN  
   IF @nStep = 0 GOTO Step_0   -- Func = 521. Menu  
   IF @nStep = 1 GOTO Step_1   -- Scn  = 926. UCC  
   IF @nStep = 2 GOTO Step_2   -- Scn  = 927. SuggestedLOC, ToLOC  
   IF @nStep = 3 GOTO Step_3   -- Scn  = 928. Successful putaway message  
   IF @nStep = 4 GOTO Step_4   -- Scn  = 929. Mixed carton, continue?  
   IF @nStep = 5 GOTO Step_5   -- Scn  = 930. Loc Not Match, continue? --(cc02)
   IF @nStep = 6 GOTO Step_6   -- Scn  = 931. Suggest alternate LOC?
   IF @nStep = 7 GOTO Step_7   -- Scn  = 932. Reason code
   IF @nStep = 99 GOTO Step_99 -- Scn  = Extended Screen
END  
RETURN -- Do nothing if incorrect step  
  
  
/********************************************************************************  
Step 0. func = 521. Menu  
   @nStep = 0  
********************************************************************************/  
Step_0:  
BEGIN  
   -- (Vicky06) EventLog - Sign In Function  
   EXEC RDT.rdt_STD_EventLog  
      @cActionType = '1', -- Sign in function  
      @cUserID     = @cUserName,  
      @nMobileNo   = @nMobile,  
      @nFunctionID = @nFunc,  
      @cFacility   = @cFacility,  
      @cStorerkey  = @cStorerkey  
  
   -- Get prefer UOM  
   SELECT @cPUOM = IsNULL( DefaultUOM, '6') -- If not defined, default as EA  
   FROM RDT.rdtMobRec M WITH (NOLOCK)  
      INNER JOIN RDT.rdtUser U WITH (NOLOCK) ON (M.UserName = U.UserName)  
   WHERE M.Mobile = @nMobile  
  
   SET @cExtendedInfoSP = rdt.rdtGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)  
   IF @cExtendedInfoSP = '0'  
      SET @cExtendedInfoSP = ''  
   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)  
   IF @cExtendedUpdateSP = '0'  
      SET @cExtendedUpdateSP = ''  
   SET @cExtendedValidateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)  
   IF @cExtendedValidateSP = '0'  
      SET @cExtendedValidateSP = ''  
   SET @cPAMatchSuggestLOC = rdt.RDTGetConfig( @nFunc, 'PutawayMatchSuggestLOC', @cStorerKey) --(cc02)  
  
   -- (james05)  
   SET @cNotDisplayPAZone = rdt.RDTGetConfig( @nFunc, 'NotDisplayPAZone', @cStorerKey)

   -- (james06)
   SET @cPutawayMixSKUUCC = rdt.RDTGetConfig( @nFunc, 'PutawayMixSKUUCC', @cStorerKey)  
  
   SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
   IF @cDecodeSP = '0'
      SET @cDecodeSP = ''
   SET @cExtScnSP = rdt.RDTGetConfig( @nFunc, 'ExtScnSP', @cStorerKey)
   IF @cExtScnSP = '0'
      SET @cExtScnSP = ''
   SET @cLOCCheckDigitSP = rdt.RDTGetConfig( @nFunc, 'LOCCheckDigitSP', @cStorerKey)  -- FCR-14022

   -- reset all output
   SET @cUCCNo = ''  
  
   -- Init screen  
   SET @cBarcode = '' 
   SET @cOutField01 = '' -- UCC  
  
   -- Set the entry point  
   SET @nScn = 926  
   SET @nStep = 1  

   IF @cExtScnSP <> ''
   BEGIN
      GOTO Step_99
   END
END  
GOTO Quit  
  
/********************************************************************************  
Step 1. Scn = 926  
   UCC         (field01, input)  
********************************************************************************/  
Step_1:  
BEGIN  
   IF @nInputKey = 1 -- Yes or Send  
   BEGIN  
      -- Screen mapping  
      SET @cUCCNo = LEFT( @cBarcode, 20)

      -- Check blank
      IF @cUCCNo = ''  
      BEGIN  
         SET @nErrNo = 50011  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'UCC req'  
         GOTO Step_1_Fail  
      END  

      -- Decode
      IF @cDecodeSP = '1'
      BEGIN
         -- Standard decode
         EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
               @cUCCNo  = @cUCCNo  OUTPUT,
               -- @nErrNo  = @nErrNo   OUTPUT,
               -- @cErrMsg = @cErrMsg  OUTPUT,
               @cType   = 'UCCno'
            -- IF @nErrNo <> 0
            --    GOTO Step_1_Fail
      END
      ELSE
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode, ' + 
               ' @cUCCNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               '@nMobile        INT, ' +
               '@nFunc          INT, ' +
               '@cLangCode      NVARCHAR( 3),  ' +
               '@nStep          INT, ' +
               '@nInputKey      INT, ' + 
               '@cFacility      NVARCHAR( 5),  ' +
               '@cStorerKey     NVARCHAR( 15), ' +
               '@cBarcode       NVARCHAR( MAX), ' +
               '@cUCCNo         NVARCHAR( 20) OUTPUT, ' +
               '@nErrNo         INT           OUTPUT, ' + 
               '@cErrMsg        NVARCHAR( 20) OUTPUT  '
           
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode, 
               @cUCCNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT 
         
            IF @nErrNo <> 0
               GOTO Step_1_Fail
         END
      END

      IF NOT EXISTS (SELECT 1 FROM dbo.UCC WITH (NOLOCK)  
                     WHERE StorerKey = @cStorerKey  
                     AND   UCCNo = @cUCCNo  
                     AND   Status = '1')  
      BEGIN  
         SET @nErrNo = 50012  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'INVALID UCC'  
         GOTO Step_1_Fail  
      END  
  
      -- Get LOC, ID  
      SET @cFromLOC = ''  
      SET @cID = ''  
      SELECT TOP 1  
         @cFromLOC = LOC,  
         @cID = ID,  
         @cSKU = SKU,  
         @nUCCQTY = QTY,  
         @cLOT = LOT  
      FROM dbo.UCC WITH (NOLOCK)  
      WHERE StorerKey = @cStorerKey  
      AND   UCCNo = @cUCCNo  
      AND   Status = '1'  
  
      SET @nTotalRec = 0  
      SELECT  
         @nTotalRec = COUNT( DISTINCT UCC.SKU), -- Total no of SKU  
         @nQTYAlloc = IsNULL( SUM( QTYAllocated + (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)), 0)  -- SHONG 26022013  
      FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)  
      JOIN dbo.UCC UCC WITH (NOLOCK) ON (LLI.StorerKey = UCC.StorerKey AND LLI.SKU = UCC.SKU AND LLI.LOT = UCC.LOT AND LLI.LOC = UCC.LOC AND LLI.ID = UCC.ID)  
      WHERE LLI.StorerKey = @cStorerKey  
      AND   (LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked - (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)) > 0  
      AND   UCC.UCCNo = @cUCCNo  
      AND   UCC.Status = '1'  
  
      IF @nTotalRec = 0  
      BEGIN  
         SET @nErrNo = 85605  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'No record'  
         GOTO Step_1_Fail  
      END  
  
      -- Validate QTY allocated  
      IF @nQTYAlloc > 0  
      BEGIN  
         SET @nErrNo = 85606  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'QTY allocated'  
         GOTO Step_1_Fail  
      END  
  
      -- Check if UCC multi SKU  
      SET @nMultiSKU = 0  
      SELECT @nMultiSKU = COUNT( DISTINCT SKU)  
      FROM dbo.UCC WITH (NOLOCK)  
      WHERE StorerKey = @cStorerKey  
      AND   UCCNo = @cUCCNo  
      AND   [Status] = '1'  
  
      IF @nMultiSKU > 1  
      BEGIN  
         -- If it is multi sku, check if it is allow to putaway with mix sku ucc  
         IF @cPutawayMixSKUUCC = '1'
         BEGIN  
            -- Check if we have inventory to move  
  
            SET @cOutField01 = ''  
  
            -- Go to next screen  
            SET @nScn = @nScn + 3  
            SET @nStep = @nStep + 3  
  
            GOTO Quit  
         END
         ELSE
         BEGIN -- (james06)
            -- Flow thru screen mix sku ucc without prompt to user input
         	IF @cPutawayMixSKUUCC = '2'
            BEGIN
               SET @cInField01 = '1'
               
               -- Go to next screen  
               SET @nScn = @nScn + 3  
               SET @nStep = @nStep + 3 

               GOTO Step_4
            END
            ELSE  -- config not turn on then error  
            BEGIN  
               SET @nErrNo = 50014  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'MIX SKU UCC'  
               GOTO Step_1_Fail
            END  
         END
      END  
  
      -- Extended update  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,       '     +  
               '@nFunc           INT,       '     +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,       '     +  
               '@nInputKey       INT,       '     +  
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cUCCNo          NVARCHAR( 20), ' +  
               '@cSuggestedLOC   NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@nErrNo          INT OUTPUT,    ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
            BEGIN  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
               GOTO Step_1_Fail  
            END  
         END  
      END  
  
      SELECT @nUCCQTY = ISNULL( SUM( Qty), 0)  
      FROM dbo.UCC WITH (NOLOCK)  
      WHERE StorerKey = @cStorerKey  
      AND   UCCNo = @cUCCNo  
      AND   Status = '1'  
  
      -- Get suggest LOC  
      SET @nPAErrNo = 0  
      SET @nPABookingKey = 0  
      EXEC rdt.rdt_UCCPutaway_GetSuggestLOC @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility  
         ,@cFromLOC  
         ,@cID  
         ,@cLOT  
         ,@cUCCNo  
         ,@cSKU  
         ,@nUCCQTY  
         ,@cSuggestedLOC   OUTPUT  
         ,@cPickAndDropLoc OUTPUT  
         ,@nPABookingKey   OUTPUT  
         ,@nPAErrNo  OUTPUT  
         ,@cErrMsg         OUTPUT  
      IF @nPAErrNo <> 0 AND  
         @nPAErrNo <> -1 -- No suggested LOC  
      BEGIN  
         SET @nErrNo = @nPAErrNo  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
         GOTO Step_1_Fail  
      END  
  
      -- Check any suggested LOC  
      IF ISNULL( @cSuggestedLOC, '') = ''  
      BEGIN  
         SET @nErrNo = 50016  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSuitableLOC  
         -- GOTO Step_1_Fail  
      END  
      ELSE  
      BEGIN  
         SELECT @cPAZone = PutAwayZone  
         FROM dbo.SKU WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
            AND SKU = @cSKU  
  
         -- Extended update -- (ChewKP01)  
         IF @cExtendedUpdateSP <> ''  
         BEGIN  
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')  
            BEGIN  
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +  
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
               SET @cSQLParam =  
                  '@nMobile         INT,       '     +  
                  '@nFunc           INT,       '     +  
                  '@cLangCode       NVARCHAR( 3),  ' +  
                  '@nStep           INT,       '     +  
                  '@nInputKey       INT,       '     +  
                  '@cStorerKey      NVARCHAR( 15), ' +  
                  '@cUCCNo          NVARCHAR( 20), ' +  
                  '@cSuggestedLOC   NVARCHAR( 10), ' +  
                  '@cToLOC          NVARCHAR( 10), ' +  
                  '@nErrNo          INT OUTPUT,    ' +  
                  '@cErrMsg         NVARCHAR( 20) OUTPUT'  
  
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
               IF @nErrNo <> 0  
               BEGIN  
  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
                  GOTO Step_1_Fail  
               END  
            END  
         END  
      END  
  
      -- Extended info  
      SET @cExtendedInfo = ''  
      IF @cExtendedInfoSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
               ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,           ' +  
               '@nFunc           INT,           ' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,           ' +  
               '@nInputKey       INT,           ' +  
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cUCCNo          NVARCHAR( 20), ' +  
               '@cSuggestedLOC   NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
               '@nErrNo          INT           OUTPUT, ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT  '  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
               @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
            BEGIN  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
               GOTO Step_1_Fail  
            END  
         END  
      END  
  
      SET @cOutField01 = @cUCCNo  
      SET @cOutField02 = @cFromLOC  
      SET @cOutField03 = @cSuggestedLOC  
      SET @cOutField04 = ''  
      SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END-- (james03)/(james05)  
      SET @cOutField06 = @cExtendedInfo   -- (james03)  
  
      -- Go to next screen  
      SET @nScn = @nScn + 1  
      SET @nStep = @nStep + 1  
   END  
  
   IF @nInputKey = 0 -- Esc or No  
   BEGIN  
     -- (Vicky06) EventLog - Sign Out Function  
     EXEC RDT.rdt_STD_EventLog  
       @cActionType = '9', -- Sign Out function  
       @cUserID     = @cUserName,  
       @nMobileNo   = @nMobile,  
       @nFunctionID = @nFunc,  
       @cFacility   = @cFacility,  
       @cStorerkey  = @cStorerkey  
  
      -- Back to menu  
      SET @nFunc = @nMenu  
      SET @nScn  = @nMenu  
      SET @nStep = 0  
   END  
   GOTO Quit  
  
   Step_1_Fail:  
   BEGIN  
      SET @cBarcode = ''
      SET @cOutField01 = ''  
      SET @cUCCNo = ''  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 2. Scn = 927  
   UCC            (field01)  
   Suggested LOC  (field02)  
   To LOC         (field03, input)  
********************************************************************************/  
Step_2:  
BEGIN  
   IF @nInputKey = 1 -- Yes or Send  
   BEGIN  
      -- Screen mapping  
      SET @cToLOC = @cInField04  
  
      IF ISNULL( @cToLOC, '') = ''  
      BEGIN  
         SET @nErrNo = 50017  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'ToLOC req'  
         GOTO Step_2_Fail  
      END  

      -- Suggest alternate LOC
      IF @cToLOC = '99'
      BEGIN
         -- Check suggest LOC
         IF @cSuggestedLOC = ''
         BEGIN
            SET @nErrNo = 85609
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSuggLOC No99
            GOTO Step_2_Fail
         END
         
         SET @cOutField01 = '' -- Option
         
         -- Go to suggest alternative LOC screen
         SET @nScn = @nScn + 4
         SET @nStep = @nStep + 4
         
         GOTO Quit
      END

      -- FCR-14022
      IF @cLOCCheckDigitSP = '1'
      BEGIN
         SET @cCheckDigitLOC = @cToLOC
         EXEC rdt.rdt_LOCLookUp_CheckDigit @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility,
            @cCheckDigitLOC OUTPUT,
            @nErrNo         OUTPUT,
            @cErrMsg        OUTPUT
         IF @nErrNo <> 0
         BEGIN
            GOTO Step_2_Fail
         END
         SET @cToLOC = @cCheckDigitLOC
      END
      -- FCR-14022

      IF NOT EXISTS (SELECT 1 FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND Facility = @cFacility)  
      BEGIN  
         SET @nErrNo = 50019  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'Invalid ToLOC  
         GOTO Step_2_Fail  
      END  
        
      -- Check if suggested LOC match  --(cc02)    
      IF @cSuggestedLOC <> '' AND @cSuggestedLOC <> @cToLOC          
      BEGIN          
         IF @cPAMatchSuggestLOC = '1'          
         BEGIN          
            SET @nErrNo = 50018          
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- LOC Not Match          
            GOTO Step_2_Fail          
         END          
         ELSE IF @cPAMatchSuggestLOC = '2'          
         BEGIN          
            -- Prepare next screen var          
            SET @cOutField01 = '' -- Option          
          
            -- Go to LOC not match screen          
            SET @nScn = @nScn + 3          
            SET @nStep = @nStep + 3          
          
            GOTO Quit          
         END          
      END      
  
      -- Extended update  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,       '     +  
               '@nFunc           INT,       '     +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,       '     +  
               '@nInputKey       INT,       '     +  
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cUCCNo          NVARCHAR( 20), ' +  
               '@cSuggestedLOC   NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@nErrNo          INT OUTPUT,    ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
            BEGIN  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
               GOTO Step_2_Fail  
            END  
         END  
      END  
  
      -- Handling transaction  
      DECLARE @nTranCount INT  
      SET @nTranCount = @@TRANCOUNT  
      BEGIN TRAN  -- Begin our own transaction  
      SAVE TRAN rdtfnc_UCCPutaway -- For rollback or commit only our own transaction  
  
      EXEC rdt.rdt_UCCPutaway_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility  
         ,@cFromLOC  
         ,@cID  
         ,@cLOT  
         ,@cUCCNo  
         ,@cSKU  
         ,@nUCCQTY  
         ,@cToLOC  
         ,@cSuggestedLOC  
         ,@cPickAndDropLoc  
         ,@nPABookingKey  
         ,@nErrNo        OUTPUT  
         ,@cErrMsg       OUTPUT  
      IF @nErrNo <> 0  
      BEGIN  
         ROLLBACK TRAN rdtfnc_UCCPutaway  
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
            COMMIT TRAN  
  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
         GOTO Step_2_Fail  
      END  
  
      -- Extended update  
      IF @cExtendedUpdateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,       '     +  
               '@nFunc           INT,       '     +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,       '     +  
               '@nInputKey       INT,       '     +  
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cUCCNo          NVARCHAR( 20), ' +  
               '@cSuggestedLOC   NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@nErrNo          INT OUTPUT,    ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
            BEGIN  
               ROLLBACK TRAN rdtfnc_UCCPutaway  
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
                  COMMIT TRAN  
  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
               GOTO Step_2_Fail  
            END  
         END  
      END  
        
      COMMIT TRAN rdtfnc_UCCPutaway  
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
         COMMIT TRAN  
           
      --(cc03)  
      IF @cExtendedInfoSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
               ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,           ' +  
               '@nFunc           INT,           ' +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,           ' +  
               '@nInputKey       INT,           ' +  
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cUCCNo          NVARCHAR( 20), ' +  
               '@cSuggestedLOC   NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
               '@nErrNo          INT           OUTPUT, ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT  '  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
               @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
            BEGIN  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
               GOTO Step_2_Fail  
            END  
              
            SET @cOutField01 = @cExtendedInfo  
         END  
      END    
  
      -- Go to next screen  
      SET @nScn = @nScn + 1  
      SET @nStep = @nStep + 1  
   END  
  
   IF @nInputKey = 0 -- Esc or No  
   BEGIN  
      -- Unlock current session suggested LOC    
      IF @nPABookingKey <> 0    
      BEGIN  
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'  
            ,'' -- @cSuggFromLOC  
            ,'' -- @cID  
            ,'' -- @cSuggestedLOC  
            ,'' -- @cStorerKey  
            ,@nErrNo  OUTPUT  
            ,@cErrMsg OUTPUT  
            ,@nPABookingKey = @nPABookingKey  
         IF @nErrNo <> 0    
            GOTO Step_2_Fail  
              
         SET @nPABookingKey = 0    
      END  
      
      -- Unlock putaway skipped LOC
      IF EXISTS( SELECT TOP 1 1
         FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
         WHERE Mobile = @nMobile
            AND Func = @nFunc)
      BEGIN
         DECLARE @nRowRef INT 
         DECLARE @curSkipLOC CURSOR 
         SET @curSkipLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT RowRef
            FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
            WHERE Mobile = @nMobile
               AND Func = @nFunc
         OPEN @curSkipLOC
         FETCH NEXT FROM @curSkipLOC INTO @nRowRef
         WHILE @@FETCH_STATUS = 0
         BEGIN
            DELETE rdt.rdtPutawaySkipLOCLog WHERE RowRef = @nRowRef
            FETCH NEXT FROM @curSkipLOC INTO @nRowRef
         END
      END
      
      -- Prepare prev screen variable  
      SET @cBarcode = ''
      SET @cOutField01 = ''  
      SET @cUCCNo = ''  
  
      -- Go to prev screen  
      SET @nScn  = @nScn  - 1  
      SET @nStep = @nStep - 1  
   END  
   
   IF @cExtScnSP <> ''
   BEGIN
      GOTO Step_99
   END

   GOTO Quit  
  
   Step_2_Fail:  
   BEGIN  
      SET @cOutField01 = @cUCCNo  
      SET @cOutField02 = @cFromLOC  
      SET @cOutField03 = @cSuggestedLOC  
      SET @cOutField04 = ''  
      SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END -- (james03)/(james05)  
      SET @cOutField06 = @cExtendedInfo  -- (james03)  
  
      SET @cToLOC = ''  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 3. scn = 928. Message screen  
   Msg  
********************************************************************************/  
Step_3:  
BEGIN  
   IF @nInputKey = 0 OR @nInputKey = 1 -- Esc or No / Yes or Send  
   BEGIN  
      -- Prepare screen variable  
      SET @cBarcode = '' 
      SET @cOutField01 = '' -- UCC  
      SET @cUCCNo = ''  
  
      -- Go back to UCC screen  
      SET @nScn  = @nScn  - 2  
      SET @nStep = @nStep - 2  
   END  
   IF @cExtScnSP <> ''
   BEGIN
      GOTO Step_99
   END
END  
GOTO Quit  
  
/********************************************************************************  
Step 4. scn = 929. Opt screen  
   OPT            (field01, input)  
********************************************************************************/  
Step_4:  
BEGIN  
   IF @nInputKey = 1 -- Yes or Send  
   BEGIN  
      -- Field mapping  
      SET @cOption = @cInField01  
  
      IF ISNULL( @cOption, '') = ''  
      BEGIN  
         SET @nErrNo = 85601  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'OPTION REQ  
         GOTO Step_4_Fail  
      END  
  
      IF @cOption NOT IN ('1', '2')  
      BEGIN  
         SET @nErrNo = 85602  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'INVALID OPTION  
         GOTO Step_4_Fail  
      END  
  
      IF @cOption = '1'  
      BEGIN  
         -- Get LOC, ID  
         SET @cFromLOC = ''  
         SET @cID = ''  
         SELECT TOP 1  
            @cFromLOC = LOC,  
            @cID = ID,  
            @cSKU = SKU  
        FROM dbo.UCC WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
         AND   UCCNo = @cUCCNo  
         AND   Status = '1'  
         ORDER BY Qty  
  
         SELECT @nUCCQTY = ISNULL( SUM( Qty), 0)  
         FROM dbo.UCC WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
         AND   UCCNo = @cUCCNo  
         AND   Status = '1'  
  
         -- Get suggest LOC  
         SET @nPAErrNo = 0  
         SET @nPABookingKey = 0  
         EXEC rdt.rdt_UCCPutaway_GetSuggestLOC @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility  
            ,@cFromLOC  
            ,@cID  
            ,@cLOT  
            ,@cUCCNo  
            ,@cSKU  
            ,@nUCCQTY  
            ,@cSuggestedLOC   OUTPUT  
            ,@cPickAndDropLoc OUTPUT  
            ,@nPABookingKey   OUTPUT  
            ,@nPAErrNo        OUTPUT  
            ,@cErrMsg         OUTPUT  
         IF @nPAErrNo <> 0 AND  
            @nPAErrNo <> -1 -- No suggested LOC  
         BEGIN  
            SET @nErrNo = @nPAErrNo  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
            GOTO Step_4_Fail  
         END  
  
         -- Check any suggested LOC  
         IF ISNULL( @cSuggestedLOC, '') = ''  
         BEGIN  
            SET @nErrNo = 85604  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSuitableLOC  
            --GOTO Step_1_Fail  (yeekung01)
         END  
  
         SELECT @cPAZone = PutAwayZone  
         FROM dbo.SKU WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
         AND   SKU = @cSKU  
  
         -- Extended info  
         SET @cExtendedInfo = ''  
         IF @cExtendedInfoSP <> ''  
         BEGIN  
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
            BEGIN  
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
                  ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
               SET @cSQLParam =  
                  '@nMobile         INT,           ' +  
                  '@nFunc           INT,           ' +  
                  '@cLangCode       NVARCHAR( 3),  ' +  
                  '@nStep           INT,           ' +  
                  '@nInputKey       INT,           ' +  
                  '@cStorerKey      NVARCHAR( 15), ' +  
                  '@cUCCNo          NVARCHAR( 20), ' +  
                  '@cSuggestedLOC   NVARCHAR( 10), ' +  
                  '@cToLOC          NVARCHAR( 10), ' +  
                  '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
                  '@nErrNo          INT           OUTPUT, ' +  
                  '@cErrMsg         NVARCHAR( 20) OUTPUT  '  
  
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
                  @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
               IF @nErrNo <> 0  
               BEGIN  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
                  GOTO Step_1_Fail  
               END  
            END  
         END  
  
         SET @cOutField01 = @cUCCNo  
         SET @cOutField02 = @cFromLOC  
         SET @cOutField03 = @cSuggestedLOC  
         SET @cOutField04 = ''  
         SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END -- (james03)/(james05)  
         SET @cOutField06 = @cExtendedInfo   -- (james03)  
  
         -- Go to next screen  
         SET @nScn = @nScn - 2  
         SET @nStep = @nStep - 2  
      END  
  
      IF @cOption = '2'  
      BEGIN  
         -- reset all output  
         SET @cUCCNo = ''  
  
         -- Init screen  
         SET @cBarcode = '' 
         SET @cOutField01 = '' -- UCC  
  
         -- Set the entry point  
         SET @nScn = @nScn - 3  
         SET @nStep = @nStep - 3  
      END  
   END  
  
   IF @nInputKey = 0 -- Esc or No  
   BEGIN  
      -- reset all output  
      SET @cUCCNo = ''  
  
      -- Init screen  
      SET @cBarcode = '' 
      SET @cOutField01 = '' -- UCC  
  
      -- Set the entry point  
      SET @nScn = @nScn - 3  
      SET @nStep = @nStep - 3  
   END  
   GOTO Quit  
  
   Step_4_Fail:  
   BEGIN  
      SET @cOutField01 = ''  
  
      SET @cOption = ''  
   END  
END  
GOTO Quit  
  
/********************************************************************************          
Step 5. Scn = 930.          
   LOC not match. Proceed?          
   1 = YES          
   2 = NO          
   OPTION (Input, Field01)          
********************************************************************************/          
Step_5:          
BEGIN          
   IF @nInputKey = 1          
   BEGIN          
      SET @cOption = @cInField01          
          
      -- Check blank          
      IF @cOption = ''          
      BEGIN          
         SET @nErrNo = 85607          
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --Option req          
         GOTO Quit          
      END          
          
      -- Check optin valid          
      IF @cOption NOT IN ('1', '2')          
      BEGIN          
         SET @nErrNo = 85608          
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --Invalid Option          
         SET @cOutField01 = ''          
         GOTO Quit          
      END               
          
      IF @cOption = '1' -- YES          
      BEGIN          
         -- Putaway          
         EXEC rdt.rdt_UCCPutaway_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility  
         ,@cFromLOC  
         ,@cID  
         ,@cLOT  
         ,@cUCCNo  
         ,@cSKU  
         ,@nUCCQTY  
         ,@cToLOC  
         ,@cSuggestedLOC  
         ,@cPickAndDropLoc  
         ,@nPABookingKey  
         ,@nErrNo        OUTPUT  
         ,@cErrMsg       OUTPUT         
         IF @nErrNo <> 0  
         BEGIN  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
            GOTO Quit  
         END        
           
         --(cc03)  
         IF @cExtendedInfoSP <> ''  
         BEGIN  
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
            BEGIN  
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
                  ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
               SET @cSQLParam =  
                  '@nMobile         INT,           ' +  
                  '@nFunc           INT,           ' +  
                  '@cLangCode       NVARCHAR( 3),  ' +  
                  '@nStep           INT,           ' +  
                  '@nInputKey       INT,           ' +  
                  '@cStorerKey      NVARCHAR( 15), ' +  
                  '@cUCCNo          NVARCHAR( 20), ' +  
                  '@cSuggestedLOC   NVARCHAR( 10), ' +  
                  '@cToLOC          NVARCHAR( 10), ' +  
                  '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
                  '@nErrNo          INT           OUTPUT, ' +  
                  '@cErrMsg         NVARCHAR( 20) OUTPUT  '  
  
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
                  @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
               IF @nErrNo <> 0  
               BEGIN  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
                  GOTO Quit  
               END  
                 
               SET @cOutField01 = @cExtendedInfo  
            END  
         END     
          
         -- Go to successful putaway screen          
         SET @nScn = @nScn - 2          
         SET @nStep = @nStep - 2          
          
         GOTO Quit          
      END          
   END              
          
   IF @cExtendedInfoSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
      BEGIN  
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
         SET @cSQLParam =  
            '@nMobile         INT,           ' +  
            '@nFunc           INT,           ' +  
            '@cLangCode       NVARCHAR( 3),  ' +  
            '@nStep           INT,           ' +  
            '@nInputKey       INT,           ' +  
            '@cStorerKey      NVARCHAR( 15), ' +  
            '@cUCCNo          NVARCHAR( 20), ' +  
            '@cSuggestedLOC   NVARCHAR( 10), ' +  
            '@cToLOC          NVARCHAR( 10), ' +  
            '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
            '@nErrNo    INT           OUTPUT, ' +  
            '@cErrMsg         NVARCHAR( 20) OUTPUT  '  
  
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
         IF @nErrNo <> 0  
         BEGIN  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
            GOTO Quit  
         END  
      END  
   END     
        
   -- Prepare next screen var          
   SET @cOutField01 = @cUCCNo          
   SET @cOutField02 = '' -- FinalLOC          
   SET @cOutField03 = @cSuggestedLOC  
   SET @cOutField04 = ''  
   SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END -- (james03)/(james05)          
   SET @cOutField06 = @cExtendedInfo      
          
   -- Go to suggested LOC screen          
   SET @nScn = @nScn - 3          
   SET @nStep = @nStep - 3     
END          
GOTO Quit   

/********************************************************************************
Step 6. Scn = 931.
   SUGGEST ALTERNATE
   PUTAWAY LOC?
   1 = YES
   2 = NO
   OPTION (Input, Field01)
********************************************************************************/
Step_6:
BEGIN
   IF @nInputKey = 1
   BEGIN
      SET @cOption = @cInField01

      -- Check blank
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 85610
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --Option req
         GOTO Quit
      END

      -- Check optin valid
      IF @cOption NOT IN ('1', '2')
      BEGIN
         SET @nErrNo = 85611
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --Invalid Option
         SET @cOutField01 = ''
         GOTO Quit
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,       '     +  
               '@nFunc           INT,       '     +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,       '     +  
               '@nInputKey       INT,       '     +  
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cUCCNo          NVARCHAR( 20), ' +  
               '@cSuggestedLOC   NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@nErrNo          INT OUTPUT,    ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
               GOTO Quit  
         END  
      END  

      IF @cOption = '1' -- YES
      BEGIN
         -- Go to reason code screen
         SET @nScn = @nScn + 1
         SET @nStep = @nStep + 1
      END
      
      IF @cOption = '2' -- NO
      BEGIN
         -- Prepare next screen var
         SET @cOutField01 = @cUCCNo  
         SET @cOutField02 = @cFromLOC  
         SET @cOutField03 = @cSuggestedLOC  
         SET @cOutField04 = ''  -- @cToLOC
         SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END
         SET @cOutField06 = '' -- @cExtendedInfo

         -- Go to suggested LOC screen
         SET @nScn = @nScn - 4
         SET @nStep = @nStep - 4
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare next screen var
      SET @cOutField01 = @cUCCNo  
      SET @cOutField02 = @cFromLOC  
      SET @cOutField03 = @cSuggestedLOC  
      SET @cOutField04 = ''  -- @cToLOC
      SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END
      SET @cOutField06 = '' -- @cExtendedInfo

      -- Go to suggested LOC screen
      SET @nScn = @nScn - 4
      SET @nStep = @nStep - 4
   END
   
   -- Extended info
   IF @cExtendedInfoSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
         SET @cSQLParam =  
            '@nMobile         INT,           ' +  
            '@nFunc           INT,           ' +  
            '@cLangCode       NVARCHAR( 3),  ' +  
            '@nStep           INT,           ' +  
            '@nInputKey       INT,           ' +  
            '@cStorerKey      NVARCHAR( 15), ' +  
            '@cUCCNo          NVARCHAR( 20), ' +  
            '@cSuggestedLOC   NVARCHAR( 10), ' +  
            '@cToLOC          NVARCHAR( 10), ' +  
            '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
            '@nErrNo          INT           OUTPUT, ' +  
            '@cErrMsg         NVARCHAR( 20) OUTPUT  '  

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  

         IF @cExtendedInfo <> ''
            SET @cOutField06 = @cExtendedInfo
      END  
   END  
END
GOTO Quit

/********************************************************************************
Step 7. Scn = 932.
   REASON CODE (Input, Field01)
********************************************************************************/
Step_7:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      DECLARE @cReasonCode NVARCHAR( 10)
      SET @cReasonCode = @cInField01

      -- Check blank
      IF @cReasonCode = ''
      BEGIN
         SET @nErrNo = 85612
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --NeedReasonCode
         GOTO Quit
      END

      -- Check ReasonCode valid
      IF NOT EXISTS( SELECT TOP 1 1 
         FROM dbo.CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'RDTREASON'
            AND Code = @nFunc
            AND Code2 = @cReasonCode
            AND StorerKey = @cStorerKey)
      BEGIN
         SET @nErrNo = 85613
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo ,@cLangCode ,'DSP') --Bad ReasonCode
         SET @cOutField01 = ''
         GOTO Quit
      END

      -- Extended validate
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               '@nMobile         INT,       '     +  
               '@nFunc           INT,       '     +  
               '@cLangCode       NVARCHAR( 3),  ' +  
               '@nStep           INT,       '     +  
               '@nInputKey       INT,       '     +  
               '@cStorerKey      NVARCHAR( 15), ' +  
               '@cUCCNo          NVARCHAR( 20), ' +  
               '@cSuggestedLOC   NVARCHAR( 10), ' +  
               '@cToLOC          NVARCHAR( 10), ' +  
               '@nErrNo          INT OUTPUT,    ' +  
               '@cErrMsg         NVARCHAR( 20) OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
               GOTO Quit  
         END  
      END  

      -- Insert skip LOC
      IF @cPickAndDropLOC = ''
      BEGIN
         IF NOT EXISTS( SELECT 1
            FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
            WHERE Mobile = @nMobile
               AND Func = @nFunc 
               AND LOC = @cSuggestedLOC)
         BEGIN
            INSERT INTO rdt.rdtPutawaySkipLOCLog (Mobile, Func, LOC)
            VALUES( @nMobile, @nFunc, @cSuggestedLOC)
         END
      END
      ELSE
      BEGIN
         IF NOT EXISTS( SELECT 1
            FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK) 
            WHERE Mobile = @nMobile
               AND Func = @nFunc 
               AND LOC = @cPickAndDropLOC)
         BEGIN
            INSERT INTO rdt.rdtPutawaySkipLOCLog (Mobile, Func, LOC)
            VALUES( @nMobile, @nFunc, @cPickAndDropLOC)
         END
      END
      
      -- Get suggest LOC
      DECLARE @cSuggAltLOC        NVARCHAR( 10) = ''
      DECLARE @cPickAndDropAltLOC NVARCHAR( 10) = ''
      DECLARE @nAltPABookingKey   INT = 0
      SET @nPAErrNo = 0
      EXEC rdt.rdt_UCCPutaway_GetSuggestLOC @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility
         ,@cFromLOC
         ,@cID
         ,@cLOT  
         ,@cUCCNo  
         ,@cSKU  
         ,@nUCCQTY  
         ,@cSuggAltLOC        OUTPUT
         ,@cPickAndDropAltLOC OUTPUT
         ,@nAltPABookingKey   OUTPUT
         ,@nPAErrNo           OUTPUT
         ,@cErrMsg            OUTPUT
      IF @nPAErrNo <> 0 AND
         @nPAErrNo <> -1 -- No suggested LOC
      BEGIN
         SET @nErrNo = @nPAErrNo
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO Quit
      END      
      
      -- Release original booking
      IF @nPABookingKey <> 0
      BEGIN
         EXEC rdt.rdt_Putaway_PendingMoveIn '', 'UNLOCK'
            ,'' --FromLOC
            ,'' --FromID
            ,'' --SuggLOC
            ,'' --Storer
            ,@nErrNo  OUTPUT
            ,@cErrMsg OUTPUT
            ,@nPABookingKey = @nPABookingKey OUTPUT
         IF @nErrNo <> 0  
            GOTO Quit
      END
      
      -- Generate alert
      DECLARE @c_AlertMessage NVARCHAR( 255)
      DECLARE @cCRLF NVARCHAR( 2) = CHAR(13) + CHAR(10)
      IF @cPickAndDropAltLOC = ''
         SET @c_AlertMessage = 
            'SUGGESTED LOC = ' + @cSuggestedLOC + @cCRLF + 
            'ALTERNATE LOC = ' + @cSuggAltLOC + @cCRLF + 
            'REASON CODE = ' + @cReasonCode
      ELSE
         SET @c_AlertMessage = 
            'SUGGESTED LOC = ' + @cPickAndDropLOC + @cCRLF + 
            'ALTERNATE LOC = ' + @cPickAndDropAltLOC + @cCRLF + 
            'REASON CODE = ' + @cReasonCode
      EXEC nspLogAlert
           @c_modulename       = 'Putaway by UCC'
         , @c_AlertMessage     = @c_AlertMessage
         , @n_Severity         = 5
         , @b_Success          = 0
         , @n_err              = 0
         , @c_errmsg           = ''
         , @c_Activity         = 'SUGGEST ALTERNATE LOC'
         , @c_Storerkey        = @cStorerKey
         , @c_Loc              = @cFromLOC
         , @c_ID               = @cID
         , @c_UCCNo            = @cUCCNo
      
      -- Save to suggested LOC
      SET @cSuggestedLOC = @cSuggAltLOC
      SET @cPickAndDropLOC = @cPickAndDropAltLOC
      
      -- Save booking
      SET @nPABookingKey = @nAltPABookingKey
   END

   -- Prepare next screen var
   SET @cOutField01 = @cUCCNo  
   SET @cOutField02 = @cFromLOC  
   SET @cOutField03 = @cSuggestedLOC  
   SET @cOutField04 = ''  -- @cToLOC
   SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END
   SET @cOutField06 = '' -- @cExtendedInfo

   -- Go to suggested LOC screen
   SET @nScn = @nScn - 5
   SET @nStep = @nStep - 5

   -- Extended info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
         SET @cSQLParam =  
            '@nMobile         INT,           ' +  
            '@nFunc           INT,           ' +  
            '@cLangCode       NVARCHAR( 3),  ' +  
            '@nStep           INT,           ' +  
            '@nInputKey       INT,           ' +  
            '@cStorerKey      NVARCHAR( 15), ' +  
            '@cUCCNo          NVARCHAR( 20), ' +  
            '@cSuggestedLOC   NVARCHAR( 10), ' +  
            '@cToLOC          NVARCHAR( 10), ' +  
            '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
            '@nErrNo          INT           OUTPUT, ' +  
            '@cErrMsg         NVARCHAR( 20) OUTPUT  '  

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  

         IF @cExtendedInfo <> ''
            SET @cOutField06 = @cExtendedInfo
      END
   END
END
GOTO Quit

/********************************************************************************          
Step 99. Extended Screen      
********************************************************************************/         
Step_99:
BEGIN
   IF @cExtScnSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
      BEGIN      
         DECLARE @nStepBak INT
         DECLARE @nScnBak INT
         SELECT @nStepBak = @nStep, @nScnBak = @nScn, @nErrNo=0, @cErrMsg=''
         DELETE FROM @tExtScnData
         INSERT INTO @tExtScnData (Variable, Value) VALUES
         ('@cUCCNo',  @cUCCNo)

         EXECUTE [RDT].[rdt_ExtScnEntry] 
         @cExtScnSP, 
         @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @nInputKey, @cFacility, @cStorerKey, @tExtScnData ,
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,  
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,  
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,  
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,  
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,  
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT, 
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT, 
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT, 
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT, 
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT, 
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,
         @nAction, 
         @nScn     OUTPUT,  @nStep OUTPUT,
         @nErrNo   OUTPUT, 
         @cErrMsg  OUTPUT,
         @cUDF01   OUTPUT, @cUDF02 OUTPUT, @cUDF03 OUTPUT,
         @cUDF04   OUTPUT, @cUDF05 OUTPUT, @cUDF06 OUTPUT,
         @cUDF07   OUTPUT, @cUDF08 OUTPUT, @cUDF09 OUTPUT,
         @cUDF10   OUTPUT, @cUDF11 OUTPUT, @cUDF12 OUTPUT,
         @cUDF13   OUTPUT, @cUDF14 OUTPUT, @cUDF15 OUTPUT,
         @cUDF16   OUTPUT, @cUDF17 OUTPUT, @cUDF18 OUTPUT,
         @cUDF19   OUTPUT, @cUDF20 OUTPUT, @cUDF21 OUTPUT,
         @cUDF22   OUTPUT, @cUDF23 OUTPUT, @cUDF24 OUTPUT,
         @cUDF25   OUTPUT, @cUDF26 OUTPUT, @cUDF27 OUTPUT,
         @cUDF28   OUTPUT, @cUDF29 OUTPUT, @cUDF30 OUTPUT

         IF @nErrNo <> 0 AND @nErrNo <> 50016 --de01--50016 indicates no loc found. It is not an exception
            GOTO Step_99_Fail

         IF @cExtScnSP = 'rdt_521ExtScn01'
         BEGIN
            IF @nStepBak = 99 AND @nStep = 0
               SET @nFunc = @nMenu
            IF @nStepBak = 99 AND @nStep = 2
            BEGIN
               SET @cUCCNo = @cUDF01
               SET @cFromLOC = @cUDF02
               SET @cID = @cUDF03
               SET @cSKU = @cUDF04
               SET @nUCCQTY = CAST(@cUDF05 AS INT)  
               SET @cLOT = @cUDF06
               SET @cSuggestedLOC = @cUDF07
               SET @nPABookingKey = @cUDF08
            END
         END

      END
   END

   GOTO Quit

Step_99_Fail:
   BEGIN
      GOTO Quit
   END
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
      Func = @nFunc,  
      Step = @nStep,  
      Scn = @nScn,  
  
      StorerKey   = @cStorerkey,  
      Facility    = @cFacility,  
      -- UserName    = @cUserName,  
      Printer     = @cPrinter,  
  
      V_LOC       = @cFromLOC,  
      V_UCC       = @cUCCNo,  
      V_ID        = @cID,  
      V_SKU       = @cSKU,  
      V_LOT       = @cLOT,  
      V_QTY       = @nUCCQTY,  
      V_Barcode   = @cBarcode,
  
      V_String1   = @cSuggestedLOC,  
      V_String2   = @cPAZone,
      V_String3   = @cPutawayMixSKUUCC,
      V_String4   = @cPickAndDropLoc,
  
      V_String21 = @cExtendedInfoSP,  
      V_String22 = @cExtendedInfo,  
      V_String23 = @cExtendedUpdateSP,  
      V_String24 = @cExtendedValidateSP,  
      V_String25 = @cPAMatchSuggestLOC, --(cc02)  
      V_String26 = @cToLOC, --(cc02)  
      V_String27 = @cNotDisplayPAZone,  
      V_String28 = @cDecodeSP,
      V_String29 = @cExtScnSP,
      V_String30 = @cLOCCheckDigitSP,  -- FCR-14022

      V_Integer1 = @nPABookingKey,  
  
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

GRANT EXECUTE ON [rdt].[rdtfnc_UCCPutaway] TO NSQL
GO
