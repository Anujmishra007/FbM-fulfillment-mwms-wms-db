IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtfnc_TM_Replen]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [RDT].[rdtfnc_TM_Replen]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdtfnc_TM_Replen                                          */
/* Copyright      : IDS                                                       */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2011-02-17 1.0  ChewKP     Created. SOS#205873                             */
/* 2011-10-12 1.1  Ung        Revised. SOS#224379                             */
/* 2014-01-03 1.2  Ung        SOS296465                                       */
/*                            Add DefaultFromID                               */
/*                            Add GetNextTaskSP                               */
/*                            Add ExtendedInfoSP                              */
/*                            Add DisableQTYFieldSP                           */
/* 2015-01-14 1.3  Ung        SOS330683 Add close pallet transaction          */
/* 2015-01-28 1.4  Ung        SOS331666 Add ExtendedInfoSP for step 6, 7      */
/* 2016-06-08 1.5  Ung        SOS359988 Add ListKey to standard event log     */
/* 2016-08-08 1.6  Ung        SOS372531 Fix DisableQTYFieldSP conflict w PQTY */
/*                            Add DisableOverReplen                           */
/*                            Performance tuning                              */
/* 2016-10-12 1.7  Ung        IN00171401 Add MoveQTYReplen                    */
/* 2016-10-18 1.8  Ung        WMS-254 Add DefaultSKU                          */
/* 2017-05-30 1.9  ChewKP     WMS-1992 - Fixes (ChewKP01)                     */
/* 2017-07-24 2.0  Ung        WMS-2440 Add SwapTaskSP                         */
/* 2017-10-19 2.1  Ung        WMS-3258 Add ExtendedInfoSP at step 4           */
/* 2018-03-08 2.2  Ung        WMS-4096 Add ExtendedInfoSP at step 3           */
/* 2018-08-30 2.3  James      WMS-6145 Add rdt_decode (james01)               */
/* 2018-09-28 2.4  TungGH     Performance                                     */
/* 2018-10-17 2.5  ChewKP     WMS-6505 Add DefaultOption Config (ChewKP02)    */
/* 2018-11-29 2.6  Ung        INC0486759 Add SwapUCCSP                        */
/* 2019-05-10 2.7  James      WMS-9004 Add rdtIsValidFormat to DropID screen  */
/*                            (james02)                                       */
/* 2019-05-16 2.8  Ung        WMS-9090 Add fully replen auto go to next screen*/
/* 2019-07-16 2.9  Ung        Fix DropID > 18 chars with MoveQTYAlloc         */
/* 2019-07-17 3.0  James      WMS9859 Add loc prefix (james03)                */
/* 2019-06-10 3.1  YeeKung    WMS-9385 Add EventLog   (yeekung01)             */   
/* 2020-03-17 3.2  James      WMS-12417 Add extendedinfo at screen 1 (james04)*/
/* 2020-06-15 3.3  James      WMS-13602 Add Loc.Descr (james05)               */
/* 2020-11-16 3.4  James      WMS-15573 Add extra param to nspTMTM01 (james06)*/
/*                            Exit module if switch task                      */
/* 2021-02-25 3.5  James      WMS-16271 Add ExtendedValidateSP (james07)      */
/* 2021-04-21 3.6  James      WMS-15656 Add DefaultSuggToLOC config (james08) */
/* 2021-05-07 3.7  James      WMS-16964 Add custom SuggToLOC (james09)        */
/* 2021-11-09 3.8  Chermaine  WMS-17383 Add AutoGen DropID in St1 (cc01)      */
/******************************************************************************/

CREATE PROC [RDT].[rdtfnc_TM_Replen](
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max
) AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

-- Misc variable
DECLARE
   @b_success           INT,
   @cFromLOC            NVARCHAR(10),
   @cToLOC              NVARCHAR(10),
   @cFromID             NVARCHAR(18),
   @cUserPosition       NVARCHAR(1),
   @nTotPickQty         INT,
   @c_outstring         NVARCHAR(255),
   @cOption             NVARCHAR(1),
   @cNextTaskDetailKey  NVARCHAR(10),
   @cReasonCode         NVARCHAR(10),
   @nRowRef             INT,
   @nCurrentTranCount   INT,
   @cUCC                NVARCHAR( 20),
   @cSKU                NVARCHAR(20),
   @cPQTY               NVARCHAR( 5),
   @cMQTY               NVARCHAR( 5),
   @cSQL                NVARCHAR(MAX),
   @cSQLParam           NVARCHAR(MAX),
   @nCartonQTY          INT

-- Define variable on mobrec
DECLARE
   @nFunc               INT,
   @nScn    INT,
   @nStep               INT,
   @cLangCode           NVARCHAR(3),
   @nMenu               INT,
   @nInputKey           NVARCHAR(3),

   @cPrinter            NVARCHAR(10),
   @cUserName           NVARCHAR(18),
   @cStorerKey          NVARCHAR(15),
   @cFacility           NVARCHAR(5),

   @cSuggSKU            NVARCHAR(20),
   @cSKUDesc            NVARCHAR(60),
   @cSuggLOT            NVARCHAR(10),
   @cSuggFromLOC        NVARCHAR(10),
   @cSuggID             NVARCHAR(18),
   @cPUOM               NVARCHAR( 1), -- Prefer UOM
   @nQTY_RPL            INT,
   @cLottable01         NVARCHAR(18),
   @cLottable02         NVARCHAR(18),
   @cLottable03         NVARCHAR(18),
   @dLottable04         DATETIME,

   @cTaskDetailKey      NVARCHAR(10),
   @cTaskStorer         NVARCHAR(15),
   @cDropID             NVARCHAR(20),
   @cPickMethod         NVARCHAR(10),
   @cSuggToLOC          NVARCHAR(10),
   @cListKey            NVARCHAR(10),
   @cDisableQTYField    NVARCHAR(1),
   @cMoveQTYReplen      NVARCHAR(1),
   @cPUOM_Desc          NCHAR( 5),
   @cMUOM_Desc          NCHAR( 5),
   @nPUOM_Div           INT, -- UOM divider
   @nPQTY_RPL           INT,
   @nMQTY_RPL           INT,
   @cDefaultSKU         NVARCHAR(1),
   @nPQTY               INT,
   @nMQTY               INT,
   @nQTY                INT,
   @nFromStep           INT,
   @nFromScn            INT,
   @cDecodeLabelNo      NVARCHAR( 20),
   @cExtendedUpdateSP   NVARCHAR( 20),
   @cDefaultToLOC       NVARCHAR( 10),
   @cMoveQTYAlloc       NVARCHAR( 1),
   @cSKUValidated       NVARCHAR( 2),
   @cDefaultFromID      NVARCHAR( 1),
   @cExtendedInfoSP     NVARCHAR(20),
   @cExtendedInfo1      NVARCHAR(20),
   @cGetNextTaskSP      NVARCHAR(20),
   @cDisableQTYFieldSP  NVARCHAR(20),
   @cDisableOverReplen  NVARCHAR(1),

   @cAreaKey            NVARCHAR(10),
   @cTTMStrategykey     NVARCHAR(10),
   @cTTMTaskType        NVARCHAR(10),
   @cRefKey01           NVARCHAR(20),
   @cRefKey02           NVARCHAR(20),
   @cRefKey03           NVARCHAR(20),
   @cRefKey04           NVARCHAR(20),
   @cRefKey05           NVARCHAR(20),
   @cSystemQTY          NVARCHAR(10),

   @cSwapTaskSP         NVARCHAR( 20),
   @cDecodeSP           NVARCHAR( 20),
   @cBarcode            NVARCHAR( 60),
   @cDefaultOption      NVARCHAR( 1),
   @cSwapUCCSP          NVARCHAR( 20),
   @cLOCLookupSP        NVARCHAR( 20),
   @cLocShowDescr       NVARCHAR( 1),  -- (james05)
   @cLocDescr           NVARCHAR( 20), -- (james05)
   @cContinueTask       NVARCHAR( 1),
   @nIsMultiSKUUCC      INT = 0,
   @cDefaultSuggToLOC   NVARCHAR( 10),
   @nIsToLOCDiff        INT = 0,
   @cSuggToLOCSP        NVARCHAR( 20),
   @cNewSuggToLOC       NVARCHAR( 10),
   @cExtendedValidateSP NVARCHAR( 20),
   @cAutoGenDropID      NVARCHAR( 1),  --(cc01)
   @bSuccess            INT,

   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),

   @cFieldAttr01 NVARCHAR( 1), @cFieldAttr02 NVARCHAR( 1),
   @cFieldAttr03 NVARCHAR( 1), @cFieldAttr04 NVARCHAR( 1),
   @cFieldAttr05 NVARCHAR( 1), @cFieldAttr06 NVARCHAR( 1),
   @cFieldAttr07 NVARCHAR( 1), @cFieldAttr08 NVARCHAR( 1),
   @cFieldAttr09 NVARCHAR( 1), @cFieldAttr10 NVARCHAR( 1),
   @cFieldAttr11 NVARCHAR( 1), @cFieldAttr12 NVARCHAR( 1),
   @cFieldAttr13 NVARCHAR( 1), @cFieldAttr14 NVARCHAR( 1),
   @cFieldAttr15 NVARCHAR( 1)

-- Getting Mobile information
SELECT
   @nFunc           = Func,
   @nScn    = Scn,
   @nStep           = Step,
   @nInputKey       = InputKey,
   @cLangCode       = Lang_code,
   @nMenu           = Menu,

   @cPrinter        = Printer,
   @cUserName       = UserName,
   @cFacility       = Facility,
   @cStorerKey      = StorerKey,

   @cTaskDetailKey  = V_TaskDetailKey,
   @cSuggSKU        = V_SKU,
   @cSKUDesc        = V_SKUDescr,
   @cSuggLOT        = V_LOT,
   @cSuggFromLOC    = V_LOC,
   @cSuggID         = V_ID,
   @cPUOM           = V_UOM,
   @cLottable01     = V_Lottable01,
   @cLottable02     = V_Lottable02,
   @cLottable03     = V_Lottable03,
   @dLottable04     = V_Lottable04,

   @cAreaKey           = V_String1,
   @cTaskStorer        = V_String2,
   @cDropID            = V_String3,
   @cPickMethod        = V_String4,
   @cSuggToloc         = V_String5,
   @cReasonCode        = V_String6,
   @cListKey           = V_String7,
   @cDisableQTYField   = V_String8,
   @cMoveQTYReplen     = V_String9,

   @cMUOM_Desc         = V_String10,
   @cPUOM_Desc         = V_String11,
   @cDefaultOption     = V_String12, -- (ChewKP02)
   @cLOCLookupSP       = V_String13,
   @cLocShowDescr      = V_String14,
   @cDefaultSKU        = V_String15,
   @cContinueTask      = V_String16,
   @cExtendedValidateSP= V_String17,
   @cDefaultSuggToLOC  = V_String18,
   @cSuggToLOCSP       = V_String19,
   @cDecodeLabelNo     = V_String21,
   @cExtendedUpdateSP  = V_String22,
   @cDefaultToLOC      = V_String23,
   @cMoveQTYAlloc      = V_String24,
   @cSKUValidated      = V_String25,
   @cDefaultFromID     = V_String26,
   @cExtendedInfoSP    = V_String27,
   @cExtendedInfo1     = V_String28,
   @cGetNextTaskSP     = V_String29,
   @cDisableQTYFieldSP = V_String30,
   @cDisableOverReplen = V_String31,
   @cAutoGenDropID     = V_String32,   --(cc01)

   @nQTY_RPL           = V_Integer1,
   @nPQTY_RPL          = V_Integer2,
   @nMQTY_RPL          = V_Integer3,
   @nQTY               = V_Integer4,

   @nPUOM_Div          = V_PUOM_Div,
   @nPQTY              = V_PQTY,
   @nMQTY              = V_MQTY,
   @nFromScn           = V_FromScn,
   @nFromStep          = V_FromStep,

   @cAreakey           = V_String32,
   @cTTMStrategykey    = V_String33,
   @cTTMTaskType       = V_String34,
   @cRefKey01          = V_String35,
   @cRefKey02          = V_String36,
   @cRefKey03          = V_String37,
   @cRefKey04          = V_String38,
   @cRefKey05          = V_String39,
   @cSystemQTY         = V_String40,

   @cSwapTaskSP        = V_String41,
   @cDecodeSP          = V_String42,
   @cSwapUCCSP         = V_String43,

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,
   @cInField04 = I_Field04,   @cOutField04 = O_Field04,
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,

   @cFieldAttr01  = FieldAttr01,    @cFieldAttr02   = FieldAttr02,
   @cFieldAttr03 =  FieldAttr03,    @cFieldAttr04   = FieldAttr04,
   @cFieldAttr05 =  FieldAttr05,    @cFieldAttr06   = FieldAttr06,
   @cFieldAttr07 =  FieldAttr07,    @cFieldAttr08   = FieldAttr08,
   @cFieldAttr09 =  FieldAttr09,    @cFieldAttr10   = FieldAttr10,
   @cFieldAttr11 =  FieldAttr11,    @cFieldAttr12   = FieldAttr12,
   @cFieldAttr13 =  FieldAttr13,    @cFieldAttr14   = FieldAttr14,
   @cFieldAttr15 =  FieldAttr15

FROM   RDT.RDTMOBREC WITH (NOLOCK)
WHERE  Mobile = @nMobile

-- Redirect to respective screen
IF @nFunc = 1764
BEGIN
   IF @nStep = 0 GOTO Step_0   -- Initialize
   IF @nStep = 1 GOTO Step_1   -- Scn = 2680 DropID
   IF @nStep = 2 GOTO Step_2   -- Scn = 2681 FromLOC
   IF @nStep = 3 GOTO Step_3   -- Scn = 2682 FromID
   IF @nStep = 4 GOTO Step_4   -- Scn = 2683 SKU, QTY
   IF @nStep = 5 GOTO Step_5   -- Scn = 2684 Cont next replen task / Close pallet
   IF @nStep = 6 GOTO Step_6   -- Scn = 2685 To LOC
   IF @nStep = 7 GOTO Step_7   -- Scn = 2686 Pallet is close. Next task / Exit
   IF @nStep = 8 GOTO Step_8   -- Scn = 2687 Short pick / Close pallet
   IF @nStep = 9 GOTO Step_9   -- Scn = 2688 Reason code
END

RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. Initialize
********************************************************************************/
Step_0:
BEGIN
   -- Get task manager data
   SET @cTaskDetailKey  = @cOutField06
   SET @cAreaKey        = @cOutField07
   SET @cTTMStrategyKey = @cOutField08

   -- Get task info
   DECLARE @nTransit INT
   SELECT
      @cTTMTaskType = TaskType,
      @cStorerKey   = Storerkey,
      @cSuggID      = FromID,
      @cSuggLOT     = LOT,
      @cSuggFromLOC = FromLOC,
      @cSuggToLOC   = ToLOC,
      @cSuggSKU     = SKU,
      @nQTY_RPL     = QTY,
      @cSystemQTY   = SystemQTY,
      @cPickMethod  = PickMethod,
      @nTransit     = TransitCount,
      @cDropID      = DropID,
      @cListKey     = ListKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey

   -- Initial var
   SET @cUserPosition = '1'
   SET @cDropID = ''
   SET @cReasonCode = ''
   SET @cDisableQTYField = ''

   -- Get preferred UOM
   SELECT @cPUOM = DefaultUOM FROM rdt.rdtUser WITH (NOLOCK) WHERE UserName = @cUserName

   -- Get storer configure
   SET @cMoveQTYAlloc = rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey)
   SET @cMoveQTYReplen = rdt.RDTGetConfig( @nFunc, 'MoveQTYReplen', @cStorerKey)
   SET @cDefaultFromID = rdt.rdtGetConfig( @nFunc, 'DefaultFromID', @cStorerKey)
   SET @cDefaultSKU = rdt.rdtGetConfig( @nFunc, 'DefaultSKU', @cStorerKey)
   SET @cDisableOverReplen = rdt.rdtGetConfig( @nFunc, 'DisableOverReplen', @cStorerKey)

   SET @cDecodeLabelNo = rdt.RDTGetConfig( @nFunc, 'DecodeLabelNo', @cStorerKey)
   IF @cDecodeLabelNo = '0'
      SET @cDecodeLabelNo = ''
   SET @cDefaultOption = rdt.RDTGetConfig( @nFunc, 'DefaultOption', @cStorerKey)
   IF @cDefaultOption = '0'
      SET @cDefaultOption = ''
   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''
   SET @cGetNextTaskSP = rdt.RDTGetConfig( @nFunc, 'GetNextTaskSP', @cStorerKey)
   IF @cGetNextTaskSP = '0'
      SET @cGetNextTaskSP = ''
   SET @cDefaultToLOC = rdt.rdtGetConfig( @nFunc, 'DefaultToLOC', @cStorerKey)
   IF @cDefaultToLOC = '0'
      SET @cDefaultToLOC = ''
   SET @cDisableQTYFieldSP = rdt.RDTGetConfig( @nFunc, 'DisableQTYFieldSP', @cStorerKey)
   IF @cDisableQTYFieldSP = '0'
      SET @cDisableQTYFieldSP = ''
   SET @cSwapTaskSP = rdt.RDTGetConfig( @nFunc, 'SwapTaskSP', @cStorerKey)
   IF @cSwapTaskSP = '0'
      SET @cSwapTaskSP = ''
   SET @cSwapUCCSP = rdt.RDTGetConfig( @nFunc, 'SwapUCCSP', @cStorerKey)
   IF @cSwapUCCSP = '0'
      SET @cSwapUCCSP = ''

   -- (james01)
   SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
   IF @cDecodeSP = '0'
      SET @cDecodeSP = ''

   -- (james03)
   SET @cLOCLookupSP = rdt.rdtGetConfig( @nFunc, 'LOCLookupSP', @cStorerKey)

   -- (james05)
   SET @cLocShowDescr = rdt.RDTGetConfig( @nFunc, 'LocShowDescr', @cStorerkey)

   SET @cContinueTask = rdt.RDTGetConfig( @nFunc, 'ContinueALLTaskWithinAisle', @cStorerKey)

	-- (james07)
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''

   -- (james08)
   SET @cDefaultSuggToLOC = rdt.RDTGetConfig( @nFunc, 'DefaultSuggToLOC', @cStorerKey)
   IF @cDefaultSuggToLOC = '0'
      SET @cDefaultSuggToLOC = ''

   -- (james09)
   SET @cSuggToLOCSP = rdt.RDTGetConfig( @nFunc, 'SuggToLOCSP', @cStorerKey)
   IF @cSuggToLOCSP = '0'
      SET @cSuggToLOCSP = ''
   
 --(cc01)      
   SET @cAutoGenDropID = rdt.RDTGetConfig( @nFunc, 'AutoGenDropID', @cStorerKey)

   -- Disable QTY field
   IF @cDisableQTYFieldSP <> ''
   BEGIN
      IF @cDisableQTYFieldSP = '1'
         SET @cDisableQTYField = @cDisableQTYFieldSP
      ELSE
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDisableQTYFieldSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDisableQTYFieldSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile            INT,           ' +
               '@nFunc              INT,           ' +
               '@cLangCode          NVARCHAR( 3),  ' +
               '@nStep              INT,           ' +
               '@cTaskdetailKey     NVARCHAR( 10), ' +
               '@cDisableQTYField   NVARCHAR( 1)   OUTPUT, ' +
               '@nErrNo INT            OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END
   END

   -- Extended update
   IF @cExtendedUpdateSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
      BEGIN
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            '@nMobile         INT,        ' +
            '@nFunc           INT,        ' +
            '@cLangCode       NVARCHAR( 3),   ' +
            '@nStep           INT,        ' +
            '@cTaskdetailKey  NVARCHAR( 10),  ' +
            '@nErrNo          INT OUTPUT, ' +
            '@cErrMsg         NVARCHAR( 20) OUTPUT'

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

         IF @nErrNo <> 0
            GOTO Quit
      END
   END

   -- Sign-in
   EXEC RDT.rdt_STD_EventLog
      @cActionType     = '1', -- Sign in function
      @cUserID         = @cUserName,
      @nMobileNo       = @nMobile,
      @nFunctionID     = @nFunc,
      @cFacility       = @cFacility,
      @cStorerKey      = @cStorerKey,
      @cLocation       = @cSuggFromLoc,
      @cToLocation     =  @cSuggToLoc,
      @cID             = @cSuggID,
      @cAreaKey        = @cAreaKey,
      @cTTMStrategyKey = @cTTMStrategyKey,
      --@cRefNo4         = '',
      @cListKey        = @cListKey,
      @cTaskdetailKey  = @cTaskdetailKey,
      @nStep           = @nStep

   -- Enable all fields
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
   SET @cFieldAttr11 = ''
   SET @cFieldAttr12 = ''
   SET @cFieldAttr13 = ''
   SET @cFieldAttr14 = ''
   SET @cFieldAttr15 = ''

   -- Set the entry point
   SET @nScn  = 2680
   SET @nStep = 1

   -- (james04)
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
            @nMobile, @nFunc, @cLangCode, @nStep , @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

         IF @cExtendedInfo1 <> ''
            SET @cOutField15 = @cExtendedInfo1
      END
   END

 
   --(cc01)
   IF @cAutoGenDropID = '1'
   BEGIN
   	-- Get MBOLKey    
      EXECUTE dbo.nspg_GetKey_AlphaSeq    
         'PalletID_AD',    
         10,    
         @cDropID    OUTPUT,    
         @bSuccess   OUTPUT,    
         @nErrNo     OUTPUT,    
         @cErrMsg    OUTPUT    
      IF @bSuccess <> 1    
      BEGIN    
         SET @nErrNo = 72304    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenDropIDFail  
         GOTO Quit    
      END    
   END
   
   -- Prompt DropID only if partial pallet replen and initial task
   IF @cPickMethod = 'PP' AND @nTransit = 0
   BEGIN
      -- Prepare next screen var
      SET @cOutField01 = @cDropID

      -- Remain in same screen
      -- SET @nScn = @nScn + 1
      -- SET @nStep = @nStep + 1
   END
   ELSE
   BEGIN
      SET @nQTY = @nQTY_RPL

      -- Prepare next screen var
      SET @cOutField01 = @cPickMethod
      SET @cOutField02 = @cDropID
      SET @cOutField03 = @cSuggFromLOC
      SET @cOutField04 = '' -- FromID

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END
END
GOTO Quit


/********************************************************************************
Step 1. Screen = 2680. Please take an empty pallet
    DROPID   (Field01, input)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cDropID   = @cInField01
      SET @cBarcode  = @cInField01

      -- Check blank DropID
      IF @cDropID = ''
      BEGIN
         SET @nErrNo = 72266
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID needed
         GOTO Step_1_Fail
      END

      -- (james02)
      -- Check barcode format
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'DropID', @cDropID) = 0
      BEGIN
         SET @nErrNo = 72303
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format
         GOTO Step_1_Fail
      END

      -- Decode
      IF @cDecodeSP <> ''
      BEGIN
         -- Standard decode
         IF @cDecodeSP = '1'
         BEGIN
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
               @cDropID = @cDropID OUTPUT,
               @nErrNo  = @nErrNo  OUTPUT,
               @cErrMsg = @cErrMsg OUTPUT,
               @cType   = 'DropID'
         END

         -- Customize decode
         ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode, ' +
               ' @cFromID OUTPUT, @cSKU OUTPUT, @nQTY OUTPUT, @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               ' @nMobile        INT,           ' +
               ' @nFunc          INT,           ' +
               ' @cLangCode      NVARCHAR( 3),  ' +
               ' @nStep          INT,           ' +
               ' @nInputKey      INT,           ' +
               ' @cTaskdetailKey NVARCHAR( 10), ' +
               ' @cBarcode       NVARCHAR( 60), ' +
               ' @cFromID        NVARCHAR( 18)  OUTPUT, ' +
               ' @cSKU           NVARCHAR( 20)  OUTPUT, ' +
               ' @nQTY           INT            OUTPUT, ' +
               ' @cDropID        NVARCHAR( 20)  OUTPUT, ' +
               ' @nErrNo         INT            OUTPUT, ' +
               ' @cErrMsg        NVARCHAR( 20)  OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode,
               @cFromID OUTPUT, @cSKU OUTPUT, @nQTY OUTPUT, @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
         END

         IF @nErrNo <> 0
            GOTO Step_1_Fail
      END

      -- Check DropID length
      IF @cMoveQTYAlloc = '1'
      BEGIN
         -- DropID lenght (20 chars) should not over pallet ID (max 18 chars)
         IF LEN( @cDropID) > 18
         BEGIN
            SET @nErrNo = 72303
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID TooLong
            GOTO Step_1_Fail
         END
      END

      -- Check if DropID is use by others
      IF EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE DropID = @cDropID
            AND Status NOT IN ('9','X')
            AND UserKey <> @cUserName)
      BEGIN
         SET @nErrNo = 72267
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID in used
         GOTO Step_1_Fail
      END

      -- Check if DropID already exist
      IF EXISTS( SELECT 1
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
            INNER JOIN dbo.LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
         WHERE LOC.Facility = @cFacility
            AND LLI.ID = @cDropID
            AND LLI.QTY > 0)
      BEGIN
         SET @nErrNo = 72268
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID in used
         GOTO Step_1_Fail
      END

      -- Check DropID exist
      IF EXISTS( SELECT 1 FROM dbo.DropID WITH (NOLOCK) WHERE DropID = @cDropID)
      BEGIN
         SET @nErrNo = 72300
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID used
         GOTO Step_1_Fail
      END

/*
      BEGIN TRAN

      -- Delete used DropID
      IF EXISTS( SELECT 1 FROM dbo.DropID WITH (NOLOCK) WHERE DropID = @cDropID AND Status = '9')
      BEGIN
         -- Delete DropIDDetail
         DELETE dbo.DropIDDetail WHERE DropID = @cDropID
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK TRAN
            SET @nErrNo = 72270
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DelDropIDFail
            GOTO Step_1_Fail
         END

         -- Delete used DropID
         DELETE dbo.DropID WHERE DropID = @cDropID AND Status = '9'
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK TRAN
            SET @nErrNo = 72271
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DelDropIDFail
            GOTO Step_1_Fail
         END
      END

      COMMIT TRAN
*/
      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cDropID = @cDropID '
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,           ' +
               '@cTaskdetailKey  NVARCHAR( 10), ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
               '@cDropID         NVARCHAR( 20)  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cDropID = @cDropID

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- (james04)
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
               @nMobile, @nFunc, @cLangCode, @nStep , @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, 2

            IF @cExtendedInfo1 <> ''
               SET @cOutField15 = @cExtendedInfo1
         END
      END

      SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
      IF ISNULL( @cLocDescr, '') = ''
         SET @cLocDescr = @cSuggFromLOC

      -- Prepare next screen variable
      SET @cOutField01 = @cPickMethod
      SET @cOutField02 = @cDropID
      SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
      SET @cOutField04 = '' -- FromLOC 

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      /*
      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = '' -- Option
      */
      -- Go to Reason Code Screen
      SET @cOutField01 = ''
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutfield04 = ''
      SET @cOutField05 = ''
      SET @cOutField09 = ''

      SET @nFromScn = @nScn
      SET @nFromStep = @nStep
      SET @nScn  = 2109
      SET @nStep = @nStep + 8 -- Step 9

   END
   GOTO Quit

   Step_1_Fail:
   BEGIN
      SET @cDropID = ''
      SET @cOutField01 = '' -- DropID
   END
END
GOTO Quit


/********************************************************************************
Step 2. Screen = 2681. From LOC screen
    PICKTYPE (Field01)
    DROP ID  (Field02)
    SUGG LOC (Field03)
    FROM LOC (Field04, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cFromLOC = @cInField04

      -- Check blank FromLOC
      IF @cFromLOC = ''
      BEGIN
         SET @nErrNo = 72272
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FromLOC needed
         GOTO Step_2_Fail
      END

		-- (james03)        
		IF @cLOCLookupSP = 1              
		BEGIN              
			EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,               
			   @cFromLOC   OUTPUT,               
			   @nErrNo     OUTPUT,               
			   @cErrMsg    OUTPUT              

			IF @nErrNo <> 0              
				GOTO Step_2_Fail              
		END 

      -- Check if FromLOC match
      IF @cFromLOC <> @cSuggFromLOC
      BEGIN
         SET @nErrNo = 72273
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FromLOC Diff
        GOTO Step_2_Fail
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        ' +
               '@nFunc           INT,        ' +
               '@cLangCode       NVARCHAR( 3),   ' +
               '@nStep           INT,        ' +
               '@cTaskdetailKey  NVARCHAR( 10),  ' +
               '@nErrNo          INT OUTPUT, ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
      IF ISNULL( @cLocDescr, '') = ''
         SET @cLocDescr = @cSuggFromLOC

      -- Prepare Next Screen
      SET @cOutField01 = @cPickMethod
      SET @cOutField02 = @cDropID
      SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
      SET @cOutField04 = @cSuggID
      SET @cOutField05 = CASE WHEN @cDefaultFromID = '1' THEN @cSuggID ELSE '' END -- FromID
      SET @cOutField10 = '' -- ExtendedInfo

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1

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
               @nMobile, @nFunc, @cLangCode, 2, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
/*
      SET @cDropID = ''
      SET @cOutField01 = '' -- DropID

      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
*/
      -- Partial pallet
      IF @cPickMethod = 'PP'
      BEGIN
         -- Not yet picked anything
         IF NOT EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE DropID = @cDropID AND UserKey = @cUserName AND Status = '5')
         BEGIN
            -- Prepare prev screen var
            SET @cDropID = ''
            SET @cOutField01 = '' -- DropID

            SET @nScn  = @nScn - 1
            SET @nStep = @nStep - 1

            GOTO Quit
         END
      END

      -- Go to Reason Code Screen
      SET @cOutField01 = ''
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutfield04 = ''
      SET @cOutField05 = ''
      SET @cOutField09 = ''
          SET @nFromScn = @nScn
      SET @nFromStep = @nStep
      SET @nScn  = 2109
      SET @nStep = @nStep + 7 -- Step 9
   END
   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cFromLOC = ''
      SET @cOutfield04 = '' -- FromLOC
   END
END
GOTO Quit

/********************************************************************************
Step 3. Screen = 2682. FromID screen
    PICKTYPE (Field01)
    DROP ID  (Field02)
    FROM LOC (Field03)
    SUGG ID  (Field04)
    FROM ID  (Field05, input)
********************************************************************************/
Step_3:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cFromID  = @cInField05
      SET @cBarcode = @cInField05

      --SET @cFromID = 'S201808162'
/*
      -- Check blank FromID
      IF @cFromID = ''
      BEGIN
         SET @nErrNo = 72274
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --FROM ID needed
         GOTO Step_3_Fail
      END
*/

      -- Decode
      IF @cDecodeSP <> ''
      BEGIN
         -- Standard decode
         IF @cDecodeSP = '1'
         BEGIN
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
               @cID     = @cFromID OUTPUT,
               @nErrNo  = @nErrNo  OUTPUT,
               @cErrMsg = @cErrMsg OUTPUT,
               @cType   = 'ID'
         END

         -- Customize decode
         ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode, ' +
               ' @cFromID OUTPUT, @cSKU OUTPUT, @nQTY OUTPUT, @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
            SET @cSQLParam =
               ' @nMobile        INT,           ' +
               ' @nFunc          INT,           ' +
               ' @cLangCode      NVARCHAR( 3),  ' +
               ' @nStep          INT,           ' +
               ' @nInputKey      INT,           ' +
               ' @cTaskdetailKey NVARCHAR( 10), ' +
               ' @cBarcode       NVARCHAR( 60), ' +
               ' @cFromID        NVARCHAR( 18)  OUTPUT, ' +
               ' @cSKU           NVARCHAR( 20)  OUTPUT, ' +
               ' @nQTY           INT            OUTPUT, ' +
               ' @cDropID        NVARCHAR( 20)  OUTPUT, ' +
               ' @nErrNo         INT            OUTPUT, ' +
               ' @cErrMsg        NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode,
               @cFromID OUTPUT, @cSKU OUTPUT, @nQTY OUTPUT, @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
         END

         IF @nErrNo <> 0
            GOTO Step_3_Fail
      END

      -- Check FromID match
      IF @cFromID <> @cSuggID
      BEGIN
         IF @cSwapTaskSP = '' OR @cPickMethod = 'PP'
         BEGIN
            SET @nErrNo = 72275
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID not match
            GOTO Step_3_Fail
         END

         -- Swap ID
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSwapTaskSP AND type = 'P')
         BEGIN
            DECLARE @cNewTaskDetailKey NVARCHAR( 10)
            SET @cNewTaskDetailKey = ''

            SET @cSQL = 'EXEC rdt.' + RTRIM( @cSwapTaskSP) +
               ' @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cFromID, @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile            INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode          NVARCHAR( 3),  ' +
               '@cTaskdetailKey     NVARCHAR( 10), ' +
               '@cFromID            NVARCHAR( 18), ' +
               '@cNewTaskDetailKey  NVARCHAR( 10)  OUTPUT, ' +
               '@nErrNo             INT  OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @cTaskdetailKey, @cFromID, @cNewTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit

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
               @cSystemQTY   = SystemQTY,
               @cPickMethod  = PickMethod,
               @cDropID      = DropID,
               @cListKey     = ListKey
            FROM dbo.TaskDetail WITH (NOLOCK)
            WHERE TaskDetailKey = @cTaskDetailKey
         END
      END

      -- Check QTYAlloc, QTYReplen
      IF @cPickMethod = 'FP'
      BEGIN
         IF EXISTS( SELECT 1
            FROM dbo.LOTxLOCxID WITH (NOLOCK)
            WHERE LOC = @cFromLOC
               AND ID = @cFromID
               AND (QTYReplen > 0 OR
                    QTYAllocated > (CASE WHEN @cMoveQTYAlloc = '1' THEN QTYAllocated ELSE 0 END)))
         BEGIN
            SET @nErrNo = 72297
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QTYALC/QTYRPL
            GOTO Step_3_Fail
       END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        ' +
               '@nFunc           INT,        ' +
               '@cLangCode       NVARCHAR( 3),   ' +
               '@nStep           INT,        ' +
               '@cTaskdetailKey  NVARCHAR( 10),  ' +
               '@nErrNo          INT OUTPUT, ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- Full pallet
      IF @cPickMethod = 'FP'
      BEGIN
         -- (james09)
         -- Get custom SuggToLOC
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSuggToLOCSP AND type = 'P')
         BEGIN
            SET @cNewSuggToLOC = ''
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cSuggToLOCSP) +
               ' @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey, @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile            INT,           ' +
               '@nFunc              INT,           ' +
               '@cLangCode          NVARCHAR( 3),  ' +
               '@cUserName          NVARCHAR( 18), ' +
               '@cTaskDetailKey     NVARCHAR( 10), ' +
               '@cSuggToLOC         NVARCHAR( 10), ' +
               '@cNewSuggToLOC      NVARCHAR( 10) OUTPUT, ' +
               '@nErrNo             INT           OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey, @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_5_Fail

            IF @cNewSuggToLOC <> ''   
               SET @cSuggToLOC = @cNewSuggToLOC
         END

         -- Prepare next screen var
         SET @cToLOC = ''

         SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
         IF ISNULL( @cLocDescr, '') = ''
            SET @cLocDescr = @cSuggFromLOC

         SET @cOutField01 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END

         SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) 
         FROM dbo.LOC WITH (NOLOCK) 
         WHERE Facility = @cFacility 
         AND   (( @cDefaultSuggToLOC <> '' AND LOC = @cDefaultSuggToLOC) OR ( LOC = @cSuggToLOC))
         
         IF ISNULL( @cLocDescr, '') = ''
            SET @cLocDescr = CASE WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC ELSE @cSuggToLOC END

         SET @cOutField02 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr 
                                 WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                 ELSE @cSuggToLOC END

         SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC 
                                 WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC 
                                 ELSE '' END
         SET @cOutField10 = '' -- ExtendedInfo

         -- Go to ToLOC screen
         SET @nFromScn = @nScn
         SET @nFromStep = @nStep
         SET @nScn = @nScn + 3
         SET @nStep = @nStep + 3
      END

      -- Partial pallet
      IF @cPickMethod = 'PP'
     BEGIN
         -- Get SKU info
         SELECT
            @cSKUDesc = S.Descr,
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

         -- Get lottable
         SELECT
            @cLottable01 = LA.Lottable01,
            @cLottable02 = LA.Lottable02,
            @cLottable03 = LA.Lottable03,
            @dLottable04 = LA.Lottable04
         FROM dbo.LOTAttribute LA WITH (NOLOCK)
         WHERE LOT = @cSuggLOT

         -- Restore scanned carton QTY
         SELECT @nCartonQTY = ISNULL( SUM( QTY), 0)
         FROM rdt.rdtRPFLog WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         -- (ChewKP01)
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
         SET @cOutField04 = @cLottable01
         SET @cOutField05 = @cLottable02
         SET @cOutField06 = @cLottable03
         SET @cOutField07 = rdt.rdtFormatDate( @dLottable04)
         SET @cOutField08 = CASE WHEN @cDefaultSKU = '1' THEN @cSuggSKU ELSE '' END -- SKU
         SET @cOutField09 = ''
         SET @cOutField10 = ''
         SET @cOutField11 = '1:' + CAST( @nPUOM_Div AS NCHAR( 6)) + ' ' + @cPUOM_Desc + ' ' + @cMUOM_Desc
         SET @cOutField12 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY_RPL AS NVARCHAR( 5)) END
         SET @cOutField13 = CAST( @nMQTY_RPL AS NVARCHAR( 5))
         SET @cOutField14 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END -- PQTY
         SET @cOutField15 = CAST( @nMQTY AS NVARCHAR( 5)) -- MQTY
         EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU

         SET @nFromScn = @nScn
         SET @nFromStep = @nStep
         SET @nScn = @nScn + 1
         SET @nStep = @nStep + 1
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
               @nMobile, @nFunc, @cLangCode, 3, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
      IF ISNULL( @cLocDescr, '') = ''
         SET @cLocDescr = @cSuggFromLOC

      -- Prepare prev screen var
      SET @cFromLOC = ''
      SET @cOutField01 = @cPickMethod
      SET @cOutField02 = @cDropID
      SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
      SET @cOutField04 = '' -- FromLOC

      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1
   END
   GOTO Quit

   Step_3_Fail:
   BEGIN
      SET @cFromID = ''
      SET @cOutField05 = '' -- FromID
   END
END
GOTO Quit


/********************************************************************************
Step 4. screen = 2683
    SKU        (Field01)
    SKUDESCR   (Field02)
    SKUDESCR (Field03)
    Lottable01 (Field04)
    Lottable02 (Field05)
    Lottable03 (Field06)
    Lottable04 (Field07)
    SKU/UPC    (Field08, input)
    UOM ratio  (Field09)
    PUOM       (Field10)
    MUOM       (Field11)
    PQTY_RPL   (Field12)
    PQTY       (Field13, input)
    MQTY_RPL   (Field14)
    MQTY       (Field15, input)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      DECLARE @cLabelNo NVARCHAR( 32)
      DECLARE @nUCCQTY  INT

      SET @nUCCQTY = 0

      -- Screen mapping
      SET @cLabelNo = @cInField08
      SET @cSKU = @cInField08
      SET @cPQTY = CASE WHEN @cFieldAttr14 = 'O' THEN @cOutField14 ELSE @cInField14 END
      SET @cMQTY = CASE WHEN @cFieldAttr15 = 'O' THEN @cOutField15 ELSE @cInField15 END
      SET @cBarcode = @cLabelNo

      --SET @cLabelNo = '999704/NVBL8'
      --SET @cMQty = 6

      --SELECT @cMQTY '@cMQTY'

      -- Retain value
      SET @cOutField14 = CASE WHEN @cFieldAttr14 = 'O' THEN @cOutField14 ELSE @cInField14 END -- PQTY
      SET @cOutField15 = CASE WHEN @cFieldAttr15 = 'O' THEN @cOutField15 ELSE @cInField15 END -- MQTY

      -- Check SKU blank
      IF @cLabelNo = '' AND @cSKUValidated = '0' -- False
      BEGIN
         SET @nErrNo = 72276
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need SKU
         EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU
         GOTO Step_4_Fail
      END

      -- Validate SKU
      IF @cLabelNo <> ''
      BEGIN
         IF @cLabelNo = '99' -- Fully short
         BEGIN
            SET @cSKUValidated = '99'
            SET @cPQTY = ''
            SET @cMQTY = '0'
            SET @cOutField14 = ''
            SET @cOutField15 = '0'
         END
         ELSE
         BEGIN
            DECLARE @cDecodeSKU  NVARCHAR( 20)
            DECLARE @nDecodeQTY  INT

            SET @cDecodeSKU = @cSKU
            SET @nDecodeQTY = @nUCCQTY

            -- Standard decode
            IF @cDecodeSP = '1'
            BEGIN
               EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                  @cUPC    = @cDecodeSKU  OUTPUT,
                  @nQTY    = @nDecodeQTY  OUTPUT,
                  @nErrNo  = @nErrNo      OUTPUT,
                  @cErrMsg = @cErrMsg     OUTPUT,
                  @cType   = 'UPC'

               IF @nErrNo <> 0
                  GOTO Step_4_Fail
               ELSE
               BEGIN
                  SET @cSKU = @cDecodeSKU

                  IF ISNULL( @nDecodeQTY, 0) <> 0
                     SET @nUCCQTY = CAST( @nDecodeQTY AS NVARCHAR( 5))
               END
            END

            -- Customize decode
            ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode, ' +
                  ' @cFromID OUTPUT, @cSKU OUTPUT, @nQTY OUTPUT, @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '
               SET @cSQLParam =
                  ' @nMobile        INT,           ' +
                  ' @nFunc          INT,           ' +
                  ' @cLangCode      NVARCHAR( 3),  ' +
                  ' @nStep          INT,           ' +
                  ' @nInputKey      INT,           ' +
                  ' @cTaskdetailKey NVARCHAR( 10),  ' +
                  ' @cBarcode       NVARCHAR( 60),  ' +
                  ' @cFromID        NVARCHAR( 18)  OUTPUT, ' +
                  ' @cSKU           NVARCHAR( 20)  OUTPUT, ' +
                  ' @nQTY           INT            OUTPUT, ' +
                  ' @cDropID        NVARCHAR( 20)  OUTPUT, ' +
                  ' @nErrNo         INT            OUTPUT, ' +
                  ' @cErrMsg        NVARCHAR( 20)  OUTPUT'

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode,
                  @cFromID OUTPUT, @cDecodeSKU OUTPUT, @nDecodeQTY OUTPUT, @cDropID OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Step_4_Fail
               ELSE
               BEGIN
                  SET @cSKU = @cDecodeSKU

                  IF ISNULL( @nDecodeQTY, 0) <> 0
                     SET @nUCCQTY = CAST( @nDecodeQTY AS NVARCHAR( 5))
               END
            END
            ELSE
            BEGIN
               -- Decode label
               IF @cDecodeLabelNo <> ''
               BEGIN
                  DECLARE
                     @c_oFieled01 NVARCHAR(20), @c_oFieled02 NVARCHAR(20),
                     @c_oFieled03 NVARCHAR(20), @c_oFieled04 NVARCHAR(20),
                     @c_oFieled05 NVARCHAR(20), @c_oFieled06 NVARCHAR(20),
                     @c_oFieled07 NVARCHAR(20), @c_oFieled08 NVARCHAR(20),
                     @c_oFieled09 NVARCHAR(20), @c_oFieled10 NVARCHAR(20)

                  SET @c_oFieled09 = @cDropID
                  SET @c_oFieled10 = @cTaskDetailKey

                  SET @cErrMsg = ''
                  SET @nErrNo = 0
                  EXEC dbo.ispLabelNo_Decoding_Wrapper
                      @c_SPName     = @cDecodeLabelNo
                     ,@c_LabelNo    = @cLabelNo
                     ,@c_Storerkey  = @cStorerKey
                     ,@c_ReceiptKey = ''
                     ,@c_POKey      = ''
                     ,@c_LangCode   = @cLangCode
                     ,@c_oFieled01  = @c_oFieled01 OUTPUT   -- SKU
                     ,@c_oFieled02  = @c_oFieled02 OUTPUT   -- STYLE
                     ,@c_oFieled03  = @c_oFieled03 OUTPUT   -- COLOR
                     ,@c_oFieled04  = @c_oFieled04 OUTPUT   -- SIZE
                     ,@c_oFieled05  = @c_oFieled05 OUTPUT   -- QTY
                     ,@c_oFieled06  = @c_oFieled06 OUTPUT   -- LOT
                     ,@c_oFieled07 =  @c_oFieled07 OUTPUT   -- Label Type
                     ,@c_oFieled08  = @c_oFieled08 OUTPUT   -- UCC
                     ,@c_oFieled09  = @c_oFieled09 OUTPUT
                     ,@c_oFieled10  = @c_oFieled10 OUTPUT
                     ,@b_Success    = @b_Success   OUTPUT
                     ,@n_ErrNo      = @nErrNo      OUTPUT
                     ,@c_ErrMsg     = @cErrMsg     OUTPUT

                  IF @nErrNo <> 0
                     GOTO Step_4_Fail

                  SET @cSKU    = ISNULL( @c_oFieled01, '')
                  SET @nUCCQTY = CAST( ISNULL( @c_oFieled05, '') AS INT)
                  SET @cUCC    = ISNULL( @c_oFieled08, '')

                  --PRINT   @nUCCQTY
               END
            END

            -- Swap UCC (must be same FromLOC, FromID, SKU, QTY)
            IF @cSwapUCCSP <> ''
            BEGIN
               IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cSwapUCCSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cSwapUCCSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode, ' +
                     ' @cSKU OUTPUT, @cUCC OUTPUT, @nUCCQTY OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                  SET @cSQLParam =
                     '@nMobile            INT,           ' +
                     '@nFunc              INT,           ' +
                     '@cLangCode          NVARCHAR( 3),  ' +
                     '@nStep              INT,           ' +  
                     '@nInputKey          INT,           ' + 
                     '@cTaskdetailKey     NVARCHAR( 10), ' +
                     '@cBarcode           NVARCHAR( 60), ' +
                     '@cSKU               NVARCHAR( 20)  OUTPUT, ' +
                     '@cUCC               NVARCHAR( 20)  OUTPUT, ' +
                     '@nUCCQTY            INT            OUTPUT, ' +
                     '@nErrNo             INT            OUTPUT, ' +
                     '@cErrMsg            NVARCHAR( 20)  OUTPUT  '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cBarcode, 
                     @cSKU OUTPUT, @cUCC OUTPUT, @nUCCQTY OUTPUT,  @nErrNo OUTPUT, @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit

                  -- Reload task 
                  SELECT
                     @cSuggLOT     = LOT,
                     @nQTY_RPL     = QTY,
                     @cSystemQTY   = SystemQTY
                  FROM dbo.TaskDetail WITH (NOLOCK)
                  WHERE TaskDetailKey = @cTaskDetailKey
                  
                  IF EXISTS ( SELECT 1 FROM DBO.UCC WITH (NOLOCK) WHERE Storerkey = @cStorerKey AND UCCNo = @cUCC 
                              GROUP BY UCCNo HAVING COUNT( DISTINCT SKU) > 1)
                     SET @nIsMultiSKUUCC = 1
                  
               END
            END

            -- Get SKU barcode count
            DECLARE @nSKUCnt INT
            EXEC rdt.rdt_GETSKUCNT
                @cStorerKey  = @cStorerKey
               ,@cSKU        = @cSKU
               ,@nSKUCnt     = @nSKUCnt       OUTPUT
               ,@bSuccess    = @b_Success     OUTPUT
               ,@nErr        = @nErrNo        OUTPUT
               ,@cErrMsg     = @cErrMsg       OUTPUT

            -- Check SKU/UPC
            IF @nSKUCnt = 0
            BEGIN
               SET @nErrNo = 72277
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid SKU
               EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU
               GOTO Step_4_Fail
            END

            -- Check multi SKU barcode
            IF @nSKUCnt > 1
            BEGIN
               SET @nErrNo = 72278
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- MultiSKUBarCod
               EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU
               GOTO Step_4_Fail
            END

            -- Get SKU code
            EXEC rdt.rdt_GETSKU
                @cStorerKey  = @cStorerKey
               ,@cSKU        = @cSKU          OUTPUT
               ,@bSuccess    = @b_Success     OUTPUT
               ,@nErr        = @nErrNo        OUTPUT
               ,@cErrMsg     = @cErrMsg       OUTPUT

            -- Check SKU same as suggested
            IF @cSKU <> @cSuggSKU AND @nIsMultiSKUUCC = 0
            BEGIN
               SET @nErrNo = 72279
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Different SKU
               EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU
               GOTO Step_4_Fail
            END
            SET @cSuggSKU = @cSKU
            
            -- Mark SKU as validated
            SET @cSKUValidated = '1'
         END
      END

      -- Validate PQTY
      IF @cPQTY <> '' AND RDT.rdtIsValidQTY( @cPQTY, 0) = 0
      BEGIN
         SET @nErrNo = 72280
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
         EXEC rdt.rdtSetFocusField @nMobile, 14 -- PQTY
         GOTO Step_4_Fail
      END
      SET @nPQTY = CAST( @cPQTY AS INT)

      -- Validate MQTY
      IF @cMQTY <> '' AND RDT.rdtIsValidQTY( @cMQTY, 0) = 0
      BEGIN
         SET @nErrNo = 72281
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
         EXEC rdt.rdtSetFocusField @nMobile, 15 -- MQTY
         GOTO Step_4_Fail
      END
      SET @nMQTY = CAST( @cMQTY AS INT)

      -- Check full short with QTY
      IF @cSKUValidated = '99' AND
         ((@cMQTY <> '0' AND @cMQTY <> '') OR
         (@cPQTY <> '0' AND @cPQTY <> ''))
      BEGIN
         SET @nErrNo = 72302
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- FullShortNoQTY
         GOTO Step_4_Fail
      END

			-- (james07)
			IF @cExtendedValidateSP <> ''
			BEGIN
	       IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
	       BEGIN
	          SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
	             ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
	          SET @cSQLParam =
	             '@nMobile         INT,        ' +
               '@nFunc           INT,        ' +
	             '@cLangCode       NVARCHAR( 3),   ' +
	             '@nStep           INT,        ' +
	             '@cTaskdetailKey  NVARCHAR( 10),  ' +
	             '@nErrNo          INT OUTPUT, ' +
	             '@cErrMsg         NVARCHAR( 20) OUTPUT'

	          EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
	             @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

	          IF @nErrNo <> 0
	             GOTO Quit
	       END
			END
			
      -- Calc total QTY in master UOM
      SET @nQTY = rdt.rdtConvUOMQTY( @cStorerKey, @cSuggSKU, @cPQTY, @cPUOM, 6) -- Convert to QTY in master UOM
      SET @nQTY = @nQTY + @nMQTY

                --SELECT   @nQTY '@nQTY' ,@nMQTY '@nMQTY' ,'test' 'test'

      -- Top up QTY
      IF @cSKUValidated = '99' -- Fully short
         SET @nQTY = 0
      ELSE IF @nUCCQTY > 0
         SET @nQTY = @nQTY + @nUCCQTY
      ELSE
         IF @cSKU <> '' AND @cDisableQTYField = '1'
            SET @nQTY = @nQTY + 1

                          --SELECT  @nMQTY '@nMQTY' ,  @nQTY '@nQTY' , @cSKUValidated '@cSKUValidated'

      DECLARE @nSystemQTY INT
      SET @nSystemQTY = CAST( @cSystemQTY AS INT)

      -- Check QTY available
      DECLARE @nQTYAllowToMove INT
      IF @nIsMultiSKUUCC = 0
      SELECT @nQTYAllowToMove = ISNULL( SUM( QTY - QTYAllocated - QTYPicked   -- QTYAvail
         - CASE WHEN QtyReplen < 0 THEN 0 ELSE QTYReplen END                  -- Minus all booking
         + CASE WHEN @cMoveQTYAlloc = '1' THEN @nSystemQTY ELSE 0 END         -- If QTYAlloc can be moved, add own QTYAlloc
         + CASE WHEN @cMoveQTYReplen = '1' THEN                               -- If booked QTYReplen, add own booking
                     CASE WHEN @cMoveQTYAlloc = '1'
                          THEN @nQTY_RPL - @nSystemQTY
                          ELSE @nQTY_RPL
                     END
                ELSE 0
           END
         ), 0)
      FROM dbo.LOTxLOCxID (NOLOCK)
      WHERE StorerKey = @cStorerKey
         AND LOC = @cSuggFromLOC
         AND ID = @cSuggID
         AND SKU = @cSuggSKU
         AND LOT = @cSuggLOT
      ELSE
      SELECT @nQTYAllowToMove = ISNULL( SUM( LLI.QTY - QTYAllocated - QTYPicked   -- QTYAvail
         - CASE WHEN QtyReplen < 0 THEN 0 ELSE QTYReplen END                  -- Minus all booking
         + CASE WHEN @cMoveQTYAlloc = '1' THEN @nSystemQTY ELSE 0 END         -- If QTYAlloc can be moved, add own QTYAlloc
         + CASE WHEN @cMoveQTYReplen = '1' THEN                               -- If booked QTYReplen, add own booking
                     CASE WHEN @cMoveQTYAlloc = '1'
                          THEN @nQTY_RPL - @nSystemQTY
                          ELSE @nQTY_RPL
                     END
                ELSE 0
           END
         ), 0)
      FROM dbo.LOTxLOCxID LLI (NOLOCK)
      JOIN dbo.UCC UCC WITH (NOLOCK) ON 
      ( LLI.StorerKey = UCC.Storerkey AND LLI.Sku = UCC.SKU AND LLI.Lot = UCC.Lot)
      WHERE LLI.StorerKey = @cStorerKey
         AND LLI.LOC = @cSuggFromLOC
         AND LLI.ID = @cSuggID
         AND UCC.UCCNo = @cUCC
      /*            
      IF @nQTYAllowToMove < @nQTY
      BEGIN
         SET @nErrNo = 72269
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- QTYAVLNotEnuf
         GOTO Step_4_Fail
      END
*/
      -- Check over replenish
      IF @cDisableOverReplen = '1'
      BEGIN
         IF @nQTY > @nQTY_RPL
         BEGIN
            SET @nErrNo = 72301
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Over replenish
            GOTO Step_4_Fail
         END
      END

      -- UCC scanned
      IF @nUCCQTY > 0 AND @cUCC <> ''
      BEGIN
         -- Mark UCC scanned
         INSERT INTO rdt.rdtRPFLog (TaskDetailKey, DropID, UCCNo, QTY) VALUES (@cTaskDetailKey, @cDropID, @cUCC, @nUCCQTY)
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 72298
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS RPFLogFail
            GOTO Quit
         END
      END

      -- Top up MQTY, PQTY
      IF @nUCCQTY > 0
      BEGIN
         -- Top up decoded QTY
         IF @cPUOM = '6' OR -- When preferred UOM = master unit
            @nPUOM_Div = 0  -- UOM not setup
         BEGIN
            SET @nMQTY = @nMQTY + @nUCCQTY
         END
         ELSE
         BEGIN
            SET @nPQTY = @nPQTY + (@nUCCQTY / @nPUOM_Div) -- Calc QTY in preferred UOM
            SET @nMQTY = @nMQTY + (@nUCCQTY % @nPUOM_Div) -- Calc the remaining in master unit
         END
      END
      ELSE
      BEGIN
         IF @cSKU <> '' AND @cDisableQTYField = '1' -- QTY field disabled
      BEGIN
            IF @cPUOM = '6' OR -- When preferred UOM = master unit
               @nPUOM_Div = 0  -- UOM not setup
            BEGIN
               SET @nMQTY = @nQTY
            END
            ELSE
            BEGIN
               SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM
               SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit
            END
         END
      END

      SET @cOutField14 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END -- PQTY
      SET @cOutField15 = CAST( @nMQTY AS NVARCHAR( 5)) -- MQTY

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
            @nMobile, @nFunc, @cLangCode, 4, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END

      -- SKU scanned, not fully replen, remain in current screen
      INSERT INTO TraceInfo (traceName,timein,col1,col2)
      VALUES ('cc',GETDATE(),@nQTY, @nQTY_RPL)
      IF @cLabelNo <> ''
      BEGIN
         -- Not fully replen
         IF NOT (@cDisableOverReplen = '1' AND @nQTY = @nQTY_RPL)
         BEGIN
            SET @cOutField08 = '' -- SKU

            IF @cDisableQTYField = '1'
               EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU
            ELSE
               IF @cFieldAttr14 = 'O'
                  EXEC rdt.rdtSetFocusField @nMobile, 15 -- MQTY
               ELSE
                  EXEC rdt.rdtSetFocusField @nMobile, 14 -- PQTY
            GOTO Quit
         END
      END

      --(yeekung01)        
      EXEC RDT.rdt_STD_EventLog               
         @cActionType   = '3',    
         @nFunctionID   = @nFunc,       
         @nMobileNo     = @nMobile,    
         @cStorerKey    = @cStorerkey,                 
         @cFacility     = @cFacility,        
         @cDropID       = @cDropID,   
         @cUCC          = @cLabelNo, 
         @cLocation     = @cFromLOC,
         @cID           = @cFromID


      -- QTY short
      IF @nQTY < @nQTY_RPL
      BEGIN
         -- Prepare next screen var
         SET @cOption = ''
         SET @cOutField01 = '' -- Option

         SET @nScn = @nScn + 4
         SET @nStep = @nStep + 4
      END

      -- QTY fulfill
      IF @nQTY >= @nQTY_RPL
      BEGIN
         -- Prepare next screen var
         SET @cOption = ''
         SET @cOutField01 = CASE WHEN ISNULL(@cDefaultOption,'')  <> '' THEN @cDefaultOption ELSE '' END -- Option -- (ChewKP02)

         SET @nScn = @nScn + 1
         SET @nStep = @nStep + 1
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
               @nMobile, @nFunc, @cLangCode, 4, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END
END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Enable field
      SET @cFieldAttr14 = ''
      SET @cFieldAttr15 = ''

      SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
      IF ISNULL( @cLocDescr, '') = ''
         SET @cLocDescr = @cSuggFromLOC

      -- Prepare next screen var
      SET @cFromID = ''
      SET @cOutField01 = @cPickMethod
      SET @cOutField02 = @cDropID
      SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
      SET @cOutField04 = @cSuggID
      SET @cOutField05 = '' -- FromID
      SET @cOutField10 = '' -- ExtendedInfo

      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1

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
               @nMobile, @nFunc, @cLangCode, 4, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END
   END
   GOTO Quit

   Step_4_Fail:
END
GOTO Quit


/********************************************************************************
Step 5. screen = 2685.
    1 = Cont Next Replen Task
    9 = Close Pallet
    Option (Field01, input)
********************************************************************************/
Step_5:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cOption = @cInField01

      -- Check blank option
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 72282
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option needed
         GOTO Step_5_Fail
      END

      -- Check option is valid
      IF @cOption <> '1' AND @cOption <> '9'
      BEGIN
         SET @nErrNo = 72283
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
         GOTO Step_5_Fail
      END

    -- New replen task
      IF @cOption = '1'
      BEGIN
         -- Confirm current replen task (update TaskDetail to status 5)
         EXEC rdt.rdt_TM_Replen_Confirm @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey,
            @cTaskDetailKey,
            @cDropID,
            @nQTY,
            @cReasonCode,
            @cListKey,
            @nErrNo             OUTPUT,
            @cErrMsg            OUTPUT
         IF @nErrNo <> 0
            GOTO Step_5_Fail

         -- Save current task and get new replen task
         SET @cNextTaskDetailKey = ''

         -- Get next task
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGetNextTaskSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cGetNextTaskSP) +
               ' @nMobile, @nFunc, @cLangCode, @cUserName, @cAreaKey, @cListKey, @cDropID, @cNextTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile            INT,           ' +
               '@nFunc              INT,           ' +
               '@cLangCode          NVARCHAR( 3),  ' +
               '@cUserName          NVARCHAR( 18), ' +
               '@cAreaKey           NVARCHAR( 10), ' +
               '@cListKey           NVARCHAR( 10), ' +
               '@cDropID            NVARCHAR( 20), ' +
               '@cNextTaskDetailKey NVARCHAR( 10) OUTPUT, ' +
               '@nErrNo             INT           OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @cUserName, @cAreaKey, @cListKey, @cDropID, @cNextTaskDetailKey OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_5_Fail
         END
         ELSE
            GOTO Step_5_Fail

         SET @cTaskDetailKey = @cNextTaskDetailKey
/*
         EXEC rdt.rdt_TM_Replen_GetNextTask @nMobile, @nFunc, @cLangCode,
            @cUserName,
            @cAreaKey,
            @cListKey,
            @cDropID,
            @cNextTaskDetailKey OUTPUT,
            @nErrNo             OUTPUT,
            @cErrMsg            OUTPUT
         IF @nErrNo <> 0
            GOTO Step_5_Fail
*/

         -- Disable QTY field
         IF @cDisableQTYFieldSP <> ''
         BEGIN
            IF @cDisableQTYFieldSP = '1'
               SET @cDisableQTYField = @cDisableQTYFieldSP
            ELSE
            BEGIN
               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDisableQTYFieldSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cDisableQTYFieldSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cDisableQTYField, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
                     '@nMobile            INT,  ' +
                     '@nFunc              INT,           ' +
                     '@cLangCode          NVARCHAR( 3),  ' +
                     '@nStep              INT,           ' +
                     '@cTaskdetailKey     NVARCHAR( 10), ' +
                     '@cDisableQTYField   NVARCHAR( 1)   OUTPUT, ' +
                     '@nErrNo             INT            OUTPUT, ' +
                     '@cErrMsg            NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @cDisableQTYField OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                  IF @nErrNo <> 0
                     GOTO Quit
               END
            END
         END

         -- Remember last task setting
         SET @cFromLOC = @cSuggFromLOC
         SET @cFromID = @cSuggID

         SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
         IF ISNULL( @cLocDescr, '') = ''
            SET @cLocDescr = @cSuggFromLOC
         
         -- Get task info
         SELECT
            @cTaskStorer  = StorerKey,
            @cSuggID      = FromID,
            @cSuggLOT     = LOT,
            @cSuggFromLOC = FromLOC,
            @cSuggToloc   = ToLoc,
            @cSuggSKU     = SKU,
            @nQTY_RPL     = QTY,
            @cSystemQTY   = SystemQTY,
            @cReasonCode  = ''
            -- @cListKey     = ListKey,
            -- @nTransit     = TransitCount,
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskDetailKey

         -- Go to DropID screen
         IF @cDropID = '' -- 1st PP task ESC from DropID screen that clear DropID
         BEGIN
            -- Prepare next screen var
            SET @cDropID = ''
            SET @cOutField01 = '' -- @cDropID

            SET @nScn = @nScn - 4
            SET @nStep = @nStep - 4
         END

         -- Go to SKU screen
         ELSE IF @cSuggFromLOC = @cFromLOC AND @cSuggID = @cFromID
         BEGIN
            -- Mark SKU not yet validate
            SET @cSKUValidated = '0'

            -- Get SKU info
            SELECT
               @cSKUDesc = S.Descr,
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

            -- Get lottable
            SELECT
               @cLottable01 = LA.Lottable01,
               @cLottable02 = LA.Lottable02,
               @cLottable03 = LA.Lottable03,
               @dLottable04 = LA.Lottable04
            FROM dbo.LOTAttribute LA WITH (NOLOCK)
            WHERE LOT = @cSuggLOT

            -- Disable QTY field
            SET @cFieldAttr14 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- PQTY
            SET @cFieldAttr15 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- MQTY

            -- Convert to prefer UOM QTY
            IF @cPUOM = '6' OR -- When preferred UOM = master unit
               @nPUOM_Div = 0 -- UOM not setup
            BEGIN
               SET @cPUOM_Desc = ''
               SET @nPQTY_RPL = 0
               SET @nPQTY  = 0
               SET @nMQTY_RPL = @nQTY_RPL
               SET @cFieldAttr14 = 'O' -- @nPQTY_PWY
            END
            ELSE
            BEGIN
               SET @nPQTY_RPL = @nQTY_RPL / @nPUOM_Div -- Calc QTY in preferred UOM
               SET @nMQTY_RPL = @nQTY_RPL % @nPUOM_Div -- Calc the remaining in master unit
            END

            -- Prepare next screen var
            SET @cOutField01 = @cSuggSKU
            SET @cOutField02 = SUBSTRING( @cSKUDesc, 1, 20)
            SET @cOutField03 = SUBSTRING( @cSKUDesc, 21, 20)
            SET @cOutField04 = @cLottable01
            SET @cOutField05 = @cLottable02
            SET @cOutField06 = @cLottable03
            SET @cOutField07 = rdt.rdtFormatDate( @dLottable04)
            SET @cOutField08 = '' -- SKU
            SET @cOutField09 = ''
            SET @cOutField10 = ''
            SET @cOutField11 = '1:' + CAST( @nPUOM_Div AS NCHAR( 6)) + ' ' + @cPUOM_Desc + ' ' + @cMUOM_Desc
            SET @cOutField12 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY_RPL AS NVARCHAR( 5)) END
            SET @cOutField13 = CAST( @nMQTY_RPL AS NVARCHAR( 5))
            SET @cOutField14 = '' -- PQTY
            SET @cOutField15 = '' -- MQTY
            EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU

            SET @nScn = @nScn - 1
            SET @nStep = @nStep - 1
         END

         -- Go to ID screen
         ELSE IF @cSuggFromLOC = @cFromLOC
         BEGIN
            -- Prepare next screen var
            SET @cFromID = ''
            SET @cOutField01 = @cPickMethod
            SET @cOutField02 = @cDropID
            SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
            SET @cOutField04 = @cSuggID
            SET @cOutField05 = '' -- FromID

            SET @nScn = @nScn - 2
            SET @nStep = @nStep - 2
         END

         -- Go to LOC screen
         ELSE IF @cSuggFromLOC <> @cFromLOC
         BEGIN
            -- Prepare next screen var
            SET @cFromLOC = ''
            SET @cOutField01 = @cPickMethod
            SET @cOutField02 = @cDropID
            SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
            SET @cOutField04 = '' -- FromLOC

            SET @nScn = @nScn - 3
            SET @nStep = @nStep - 3
         END
      END

      -- Close pallet
      IF @cOption = '9'
      BEGIN
         -- (james09)
         -- Get custom SuggToLOC
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSuggToLOCSP AND type = 'P')
         BEGIN
            SET @cNewSuggToLOC = ''
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cSuggToLOCSP) +
               ' @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey, @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile            INT,           ' +
               '@nFunc              INT,           ' +
               '@cLangCode          NVARCHAR( 3),  ' +
               '@cUserName          NVARCHAR( 18), ' +
               '@cTaskDetailKey     NVARCHAR( 10), ' +
               '@cSuggToLOC         NVARCHAR( 10), ' +
               '@cNewSuggToLOC      NVARCHAR( 10) OUTPUT, ' +
               '@nErrNo             INT           OUTPUT, ' +
               '@cErrMsg            NVARCHAR( 20) OUTPUT  '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey, @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Step_5_Fail

            IF @cNewSuggToLOC <> ''   
               SET @cSuggToLOC = @cNewSuggToLOC
         END
         
         -- Prepare next screen var
         SET @cToLOC = ''
         SET @cOutField01 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END

         SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) 
         FROM dbo.LOC WITH (NOLOCK) 
         WHERE Facility = @cFacility 
         AND   (( @cDefaultSuggToLOC <> '' AND LOC = @cDefaultSuggToLOC) OR ( LOC = @cSuggToLOC))
         
         IF ISNULL( @cLocDescr, '') = ''
            SET @cLocDescr = CASE WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC ELSE @cSuggToLOC END

         SET @cOutField02 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr 
                                 WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                 ELSE @cSuggToLOC END
         SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC 
                                 WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                 ELSE '' END
         SET @cOutField10 = '' -- ExtendedInfo

         SET @nFromScn = @nScn
         SET @nFromStep = @nStep
         SET @nScn = @nScn + 1
         SET @nStep = @nStep + 1
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
               @nMobile, @nFunc, @cLangCode, 5, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
            SET @cSQLParam =
               '@nMobile         INT,        ' +
               '@nFunc           INT,        ' +
               '@cLangCode       NVARCHAR( 3),   ' +
               '@nStep           INT,        ' +
               '@cTaskdetailKey  NVARCHAR( 10),  ' +
               '@nErrNo          INT OUTPUT, ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
               '@nAfterStep      INT         '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, 5, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            IF @nErrNo <> 0
               GOTO Quit
         END
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Current task confirmed/SKIP/CANCEL, cannot go back
      IF EXISTS( SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey AND Status IN ('5', '0', 'X'))
         GOTO Quit

      -- Prepare next screen variable
      SET @cOutField01 = @cSuggSKU
      SET @cOutField02 = SUBSTRING( @cSKUDesc, 1, 20)
      SET @cOutField03 = SUBSTRING( @cSKUDesc, 21, 20)
      SET @cOutField04 = @cLottable01
      SET @cOutField05 = @cLottable02
      SET @cOutField06 = @cLottable03
      SET @cOutField07 = rdt.rdtFormatDate( @dLottable04)
      SET @cOutField08 = '' -- SKU
      SET @cOutField09 = ''
      SET @cOutField10 = @cExtendedInfo1
      SET @cOutField11 = '1:' + CAST( @nPUOM_Div AS NCHAR( 6)) + ' ' + @cPUOM_Desc + ' ' + @cMUOM_Desc
      SET @cOutField12 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY_RPL AS NVARCHAR( 5)) END
      SET @cOutField13 = CAST( @nMQTY_RPL AS NVARCHAR( 5))
      SET @cOutField14 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END
      SET @cOutField15 = CAST( @nMQTY AS NVARCHAR( 5))
      EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU

      -- Go to SKU screen
      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1
   END
   GOTO Quit

   Step_5_Fail:
   BEGIN
      SET @cOption = ''
      SET @cOutField01 = ''
   END
END
GOTO Quit


/********************************************************************************
Step 6. screen = 2686. To LOC screen
    FROM LOC (Field01)
    SUGG LOC (Field02)
    TO LOC   (Field03, input)
********************************************************************************/
Step_6:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cToLOC = @cInField03

      -- Check blank FromLOC
      IF @cToLOC = ''
      BEGIN
         SET @nErrNo = 72285
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLOC needed
         GOTO Step_6_Fail
      END

		-- (james03)        
		IF @cLOCLookupSP = 1              
		BEGIN              
			EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,               
			   @cToLOC     OUTPUT,               
			   @nErrNo     OUTPUT,               
			   @cErrMsg    OUTPUT              

			IF @nErrNo <> 0              
				GOTO Step_6_Fail              
		END 

      SET @nIsToLOCDiff = 0
      -- Check if FromLOC match
      IF @cDefaultSuggToLOC <> '' 
      BEGIN
         IF @cToLOC <> @cDefaultSuggToLOC
            SET @nIsToLOCDiff = 1
      END
      ELSE
         IF @cToLOC <> @cSuggToLOC
            SET @nIsToLOCDiff = 1
      
      IF @nIsToLOCDiff = 1
      BEGIN
         SET @nErrNo = 72286
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToLOC Diff
        GOTO Step_6_Fail
      END

      -- Handling transaction
      DECLARE @nTranCount INT
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN  -- Begin our own transaction
      SAVE TRAN rdtfnc_TM_Replen -- For rollback or commit only our own transaction

      -- Confirm (update TaskDetail to status 5)
      EXEC rdt.rdt_TM_Replen_Confirm @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey,
         @cTaskDetailKey,
         @cDropID,
         @nQTY,
         @cReasonCode,
         @cListKey,
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT
      IF @nErrNo <> 0
      BEGIN
         ROLLBACK TRAN rdtfnc_TM_Replen
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN
         GOTO Quit
      END

      -- Close pallet (TaskDetail to status 9, move inventory)
      EXEC rdt.rdt_TM_Replen_ClosePallet @nMobile, @nFunc, @cLangCode,
         @cUserName,
         @cListKey,
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT
      IF @nErrNo <> 0
      BEGIN
         ROLLBACK TRAN rdtfnc_TM_Replen
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN
         GOTO Quit
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,           ' +
               '@cTaskdetailKey  NVARCHAR( 10), ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN rdtfnc_TM_Replen
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN
               GOTO Quit
            END
         END
      END

      COMMIT TRAN rdtfnc_TM_Replen -- Only commit change made here
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN

      -- Prepare next screen var
      SET @cOutField01 = @cToLOC

      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1

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
               @nMobile, @nFunc, @cLangCode, 6, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Back to FromID screen (full pallet)
      IF @nFromStep = 3
      BEGIN
         SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
         IF ISNULL( @cLocDescr, '') = ''
            SET @cLocDescr = @cSuggFromLOC

         -- Prepare next screen variable
         SET @cFromID = ''
         SET @cOutField01 = @cPickMethod
         SET @cOutField02 = @cDropID
         SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
         SET @cOutField04 = @cSuggID
         SET @cOutField05 = '' -- FromID
         SET @cOutField10 = '' -- ExtendedInfo
      END

      -- Back to close pallet screen
      IF @nFromStep = 5
      BEGIN
         -- Prepare next screen variable
         SET @cOption = ''
         SET @cOutField01 = '' -- Option
      END

      -- Back to short pick screen
      IF @nFromStep = 8
      BEGIN
         -- Prepare next screen variable
     SET @cOption = ''
         SET @cOutField01 = '' -- Option
      END

      -- Back to prev screen
      SET @nScn = @nFromScn
      SET @nStep = @nFromStep

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
               @nMobile, @nFunc, @cLangCode, 6, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            IF @nStep = 3 -- From ID
               SET @cOutField10 = @cExtendedInfo1
         END
      END
   END
   GOTO Quit

   Step_6_Fail:
   BEGIN
    SET @cToLOC = ''
      SET @cOutField03 = '' -- To LOC
   END
END
GOTO Quit


/********************************************************************************
Step 7. screen = 2688. Message screen
   Pallet is Close
   ENTER = Next Task
   ESC   = Exit TM
********************************************************************************/
Step_7:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      DECLARE @cNextTaskType NVARCHAR(10)

      SET @cErrMsg = ''
      SET @cNextTaskDetailKey = ''
      SET @cNextTaskType = ''

      -- Get next task
      EXEC dbo.nspTMTM01
          @c_sendDelimiter = null
         ,@c_ptcid         = 'RDT'
         ,@c_userid        = @cUserName
         ,@c_taskId        = 'RDT'
         ,@c_databasename  = NULL
         ,@c_appflag       = NULL
         ,@c_recordType    = NULL
         ,@c_server        = NULL
         ,@c_ttm           = NULL
         ,@c_areakey01     = @cAreaKey
         ,@c_areakey02     = ''
         ,@c_areakey03  = ''
         ,@c_areakey04     = ''
         ,@c_areakey05     = ''
         ,@c_lastloc       = @cSuggToLOC
         ,@c_lasttasktype  = @cTTMTaskType
         ,@c_outstring     = @c_outstring    OUTPUT
         ,@b_Success       = @b_Success      OUTPUT
         ,@n_err           = @nErrNo         OUTPUT
         ,@c_errmsg        = @cErrMsg        OUTPUT
         ,@c_TaskDetailKey = @cNextTaskDetailKey OUTPUT
         ,@c_ttmtasktype   = @cNextTaskType  OUTPUT
         ,@c_RefKey01      = @cRefKey01      OUTPUT -- this is the field value to parse to 1st Scn in func
         ,@c_RefKey02      = @cRefKey02      OUTPUT -- this is the field value to parse to 1st Scn in func
         ,@c_RefKey03      = @cRefKey03      OUTPUT -- this is the field value to parse to 1st Scn in func
         ,@c_RefKey04      = @cRefKey04      OUTPUT -- this is the field value to parse to 1st Scn in func
         ,@c_RefKey05      = @cRefKey05      OUTPUT -- this is the field value to parse to 1st Scn in func
         ,@n_Mobile        = @nMobile
         ,@n_Func          = @nFunc
         ,@c_StorerKey     = @cStorerKey

      IF @b_Success = 0 OR @nErrNo <> 0
      BEGIN
         IF @cContinueTask = '1'
         BEGIN
            EXEC dbo.nspTMTM01    
                @c_sendDelimiter = null    
               ,@c_ptcid         = 'RDT'    
               ,@c_userid        = @cUserName    
               ,@c_taskId        = 'RDT'    
               ,@c_databasename  = NULL    
               ,@c_appflag       = NULL    
               ,@c_recordType    = NULL    
               ,@c_server        = NULL    
               ,@c_ttm           = NULL    
               ,@c_areakey01     = @cAreaKey    
               ,@c_areakey02     = ''    
               ,@c_areakey03     = ''    
               ,@c_areakey04     = ''    
               ,@c_areakey05     = ''    
               ,@c_lastloc       = ''    
               ,@c_lasttasktype  = ''    
               ,@c_outstring     = @c_outstring    OUTPUT    
               ,@b_Success       = @b_Success      OUTPUT    
               ,@n_err           = @nErrNo         OUTPUT    
               ,@c_errmsg        = @cErrMsg        OUTPUT    
               ,@c_taskdetailkey = @cNextTaskDetailKey OUTPUT    
               ,@c_ttmtasktype   = @cNextTaskType   OUTPUT    
               ,@c_RefKey01      = @cRefKey01      OUTPUT -- this is the field value to parse to 1st Scn in func    
               ,@c_RefKey02      = @cRefKey02      OUTPUT -- this is the field value to parse to 1st Scn in func    
               ,@c_RefKey03      = @cRefKey03      OUTPUT -- this is the field value to parse to 1st Scn in func    
               ,@c_RefKey04      = @cRefKey04  OUTPUT -- this is the field value to parse to 1st Scn in func    
               ,@c_RefKey05      = @cRefKey05      OUTPUT -- this is the field value to parse to 1st Scn in func                   
               ,@n_Mobile        = @nMobile
               ,@n_Func          = @nFunc
               ,@c_StorerKey     = @cStorerKey
         END
         ELSE
            GOTO Step_7_Fail
      END

      -- No task
      IF @cNextTaskDetailKey = ''
      BEGIN
         -- Logging
         EXEC RDT.rdt_STD_EventLog
             @cActionType = '9', -- Sign out function
             @cUserID     = @cUserName,
             @nMobileNo   = @nMobile,
             @nFunctionID = @nFunc,
             @cFacility   = @cFacility,
             @cStorerKey  = @cStorerKey,
             @nStep       = @nStep

         -- Go back to Task Manager Main Screen
         SET @cErrMsg = 'No More Task'
         SET @cAreaKey = ''
         SET @cOutField01 = ''  -- Area
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutField04 = ''
         SET @cOutField05 = ''
         SET @cOutField06 = ''
         SET @cOutField07 = ''
         SET @cOutField08 = ''

         SET @nFunc = 1756
         SET @nScn = 2100
         SET @nStep = 1
         GOTO QUIT
      END

      -- Have next task
      IF @cNextTaskDetailKey <> ''
      BEGIN
         SET @cTaskDetailKey = @cNextTaskDetailKey
         SET @cTTMTaskType = @cNextTaskType
   SET @cOutField01 = @cRefKey01
         SET @cOutField02 = @cRefKey02
 SET @cOutField03 = @cRefKey03
   SET @cOutField04 = @cRefKey04
         SET @cOutField05 = @cRefKey05
         SET @cOutField06 = @cTaskDetailKey
         SET @cOutField07 = @cAreaKey
         SET @cOutField08 = @cTTMStrategykey
         SET @cOutField09 = ''
         SET @nFromStep = '0'
      END

      DECLARE @nToFunc INT
      DECLARE @nToScn  INT
      DECLARE @nToStep INT
      SET @nToFunc = 0
      SET @nToScn  = 0
      SET @nToStep = 0

      -- Check if function setup
      SELECT
         @nToFunc = Function_ID,
         @nToStep = Step
      FROM rdt.rdtTaskManagerConfig WITH (NOLOCK)
      WHERE TaskType = @cTTMTaskType
      IF @nToFunc = 0
      BEGIN
         SET @nErrNo = 72287
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NextTaskFncErr
         GOTO Step_7_Fail
      END

      -- Check if screen setup
      SELECT TOP 1 @nToScn = Scn FROM RDT.RDTScn WITH (NOLOCK) WHERE Func = @nToFunc ORDER BY Scn
      IF @nToScn = 0
      BEGIN
         SET @nErrNo = 72288
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NextTaskScnErr
         GOTO Step_7_Fail
      END

      -- Logging
      EXEC RDT.rdt_STD_EventLog
         @cActionType = '9', -- Sign Out function
         @cUserID     = @cUserName,
         @nMobileNo   = @nMobile,
         @nFunctionID = @nFunc,
         @cFacility   = @cFacility,
         @cStorerKey  = @cStorerKey,
         @nStep       = @nStep

      SET @nFunc = @nToFunc
      SET @nScn  = @nToScn
      SET @nStep = @nToStep

      IF @cTTMTaskType IN ('RPF', 'RP1')
         GOTO Step_0
      ELSE
      BEGIN
         SET @cOutField09 = @cTTMTasktype      
         SET @cOutField10 = @cFromLoc 
         SET @cOutField11 = ''   
         SET @cOutField12 = ''   
         SET @nInputKey = 3 -- NOT to auto ENTER when it goes to first screen of next task    
         SET @nFunc = @nToFunc    
         SET @nScn = @nToScn    
         SET @nStep = @nToStep 
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      EXEC RDT.rdt_STD_EventLog
       @cActionType = '9', -- Sign Out function
       @cUserID     = @cUserName,
       @nMobileNo   = @nMobile,
       @nFunctionID = @nFunc,
       @cFacility   = @cFacility,
       @cStorerKey  = @cStorerKey,
       @nStep       = @nStep

      -- Enable field
      SET @cFieldAttr14 = '' -- @nPQTY
      SET @cFieldAttr15 = '' -- @nMQTY

      -- Go back to Task Manager Main Screen
      SET @nFunc = 1756
      SET @nScn = 2100
      SET @nStep = 1

      SET @cAreaKey = ''
      SET @cOutField01 = ''  -- Area
   END
   GOTO Quit

   Step_7_Fail:
END
GOTO Quit


/********************************************************************************
Step 8. screen = 2686. Short pick screen
    1 = SHORT PICK
    9 = CLOSE PALLET
    Option (Field01, input)
********************************************************************************/
Step_8:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cOption = @cInField01

      -- Check blank option
      IF @cOption = ''
      BEGIN
         SET @nErrNo = 72290
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Option needed
         GOTO Step_8_Fail
      END
      -- Check option is valid
      IF @cOption NOT IN ('1', '9')
      BEGIN
         SET @nErrNo = 72291
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
         GOTO Step_8_Fail
      END

      -- Short pick
      IF @cOption = '1'
      BEGIN
         -- Prev next screen var
         SET @cOutField01 = '' -- Reason code

         -- Go to reason code screen
         SET @nFromScn = @nScn
         SET @nFromStep = @nStep
         SET @nScn  = 2109
         SET @nStep = @nStep + 1 -- Step 10
      END

      -- Close pallet
      IF @cOption = '9'
      BEGIN
         -- Close pallet with QTY
         IF @nQTY > 0
         BEGIN
            -- (james09)
            -- Get custom SuggToLOC
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSuggToLOCSP AND type = 'P')
            BEGIN
               SET @cNewSuggToLOC = ''
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cSuggToLOCSP) +
                  ' @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey, @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
               SET @cSQLParam =
                  '@nMobile            INT,           ' +
                  '@nFunc              INT,           ' +
                  '@cLangCode          NVARCHAR( 3),  ' +
                  '@cUserName          NVARCHAR( 18), ' +
                  '@cTaskDetailKey     NVARCHAR( 10), ' +
                  '@cSuggToLOC         NVARCHAR( 10), ' +
                  '@cNewSuggToLOC      NVARCHAR( 10) OUTPUT, ' +
                  '@nErrNo             INT           OUTPUT, ' +
                  '@cErrMsg            NVARCHAR( 20) OUTPUT  '

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @cUserName, @cTaskDetailKey, @cSuggToLOC, @cNewSuggToLOC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Step_8_Fail

               IF @cNewSuggToLOC <> ''   
                  SET @cSuggToLOC = @cNewSuggToLOC
            END
         
            -- Prepare next screen var
            SET @cToLOC = ''
            SET @cOutField01 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END

            SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) 
            FROM dbo.LOC WITH (NOLOCK) 
            WHERE Facility = @cFacility 
            AND   (( @cDefaultSuggToLOC <> '' AND LOC = @cDefaultSuggToLOC) OR ( LOC = @cSuggToLOC))
         
            IF ISNULL( @cLocDescr, '') = ''
               SET @cLocDescr = CASE WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC ELSE @cSuggToLOC END

            SET @cOutField02 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr 
                                    WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                    ELSE @cSuggToLOC END

            SET @cOutField03 = CASE WHEN @cDefaultToLOC = '1' THEN @cSuggToLOC 
                                    WHEN @cDefaultSuggToLOC <> '' THEN @cDefaultSuggToLOC
                                    ELSE '' END
            SET @cOutField10 = '' -- ExtendedInfo

            -- Go to To LOC screen
            SET @nFromScn = @nScn
            SET @nFromStep = @nStep
            SET @nScn  = @nScn - 2
            SET @nStep = @nStep - 2
         END
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
               @nMobile, @nFunc, @cLangCode, 8, @cTaskdetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nStep

            SET @cOutField10 = @cExtendedInfo1
         END
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare next screen variable
      SET @cOutField01 = @cSuggSKU
      SET @cOutField02 = SUBSTRING( @cSKUDesc, 1, 20)
      SET @cOutField03 = SUBSTRING( @cSKUDesc, 21, 20)
      SET @cOutField04 = @cLottable01
      SET @cOutField05 = @cLottable02
      SET @cOutField06 = @cLottable03
      SET @cOutField07 = rdt.rdtFormatDate( @dLottable04)
      SET @cOutField08 = '' -- SKU
      SET @cOutField09 = ''
      SET @cOutField10 = @cExtendedInfo1
      SET @cOutField11 = '1:' + CAST( @nPUOM_Div AS NCHAR( 6)) + ' ' + @cPUOM_Desc + ' ' + @cMUOM_Desc
      SET @cOutField12 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY_RPL AS NVARCHAR( 5)) END
      SET @cOutField13 = CAST( @nMQTY_RPL AS NVARCHAR( 5))
      SET @cOutField14 = CASE WHEN (@cPUOM = '6' OR @nPUOM_Div = 0) THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 5)) END
      SET @cOutField15 = CAST( @nMQTY AS NVARCHAR( 5))
      EXEC rdt.rdtSetFocusField @nMobile, 8 -- SKU

      -- Go to SKU screen
      SET @nScn = @nScn - 4
      SET @nStep = @nStep - 4
   END
   GOTO Quit

   Step_8_Fail:
   BEGIN
      SET @cOption = ''
      SET @cOutField01 = '' -- Option
   END

END
GOTO Quit


/********************************************************************************
Step 9. screen = 2109. Reason code screen
     REASON CODE (Field01, input)
********************************************************************************/
Step_9:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      DECLARE @nShortQTY INT
      SET @cReasonCode = @cInField01

      -- Check blank reason
      IF @cReasonCode = ''
      BEGIN
        SET @nErrNo = 72292
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reason needed
        GOTO Step_9_Fail
      END

      IF NOT EXISTS( SELECT TOP 1 1
         FROM CodeLKUP WITH (NOLOCK)
         WHERE ListName = 'RDTTASKRSN'
            AND StorerKey = @cStorerKey
            AND Code = @cTTMTaskType
            AND @cReasonCode IN (UDF01, UDF02, UDF03, UDF04, UDF05))
      BEGIN
        SET @nErrNo = 72299
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Reason
        GOTO Step_9_Fail
      END

      -- Update ReasonCode
      SET @nShortQTY = @nQTY_RPL - @nQTY
      EXEC dbo.nspRFRSN01
          @c_sendDelimiter = NULL
         ,@c_ptcid         = 'RDT'
         ,@c_userid        = @cUserName
         ,@c_taskId        = 'RDT'
         ,@c_databasename  = NULL
         ,@c_appflag       = NULL
         ,@c_recordType    = NULL
         ,@c_server        = NULL
         ,@c_ttm           = NULL
         ,@c_TaskDetailKey = @cTaskDetailKey
         ,@c_fromloc       = @cSuggFromLOC
         ,@c_fromid        = @cSuggID
         ,@c_toloc         = @cSuggToloc
         ,@c_toid          = @cDropID
         ,@n_qty           = @nShortQTY
         ,@c_PackKey       = ''
         ,@c_uom           = ''
         ,@c_reasoncode    = @cReasonCode
         ,@c_outstring     = @c_outstring    OUTPUT
         ,@b_Success       = @b_Success      OUTPUT
         ,@n_err           = @nErrNo         OUTPUT
         ,@c_errmsg        = @cErrMsg        OUTPUT
         ,@c_userposition  = '1' -- 1=at from LOC
      IF @b_Success = 0 OR @nErrNo <> 0
         GOTO Step_9_Fail

      -- Confirm (update TaskDetail to status 5)
      IF @nFromStep = 8 --Short pick
      BEGIN
         EXEC rdt.rdt_TM_Replen_Confirm @nMobile, @nFunc, @cLangCode, @cUserName, @cFacility, @cStorerKey,
            @cTaskDetailKey,
            @cDropID,
            @nQTY,
            @cReasonCode,
            @cListKey,
            @nErrNo  OUTPUT,
            @cErrMsg OUTPUT
         IF @nErrNo <> 0
            GOTO Quit
      END

      -- Get task reason info
      DECLARE @cContinueProcess         NVARCHAR(10)
      DECLARE @cRemoveTaskFromUserQueue NVARCHAR(10)
      DECLARE @cTaskStatus              NVARCHAR(10)
      SELECT
         @cContinueProcess = ContinueProcessing,
         @cRemoveTaskFromUserQueue = RemoveTaskFromUserQueue,
         @cTaskStatus = TaskStatus
      FROM dbo.TaskManagerReason WITH (NOLOCK)
      WHERE TaskManagerReasonKey = @cReasonCode

      IF @cRemoveTaskFromUserQueue = '1'
      BEGIN
         INSERT INTO TaskManagerSkipTasks (UserID, TaskDetailKey, TaskType, LOT, FromLOC, ToLOC, FromID, ToID, CaseID)
         SELECT UserKey, TaskDetailKey, TaskType, LOT, FromLOC, ToLOC, FromID, ToID, CaseID
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskdetailKey
         IF @@ERROR <> 0
         BEGIN
            SET @nErrNo = 72293
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsSkipTskFail
            GOTO Step_9_Fail
         END
      END

      -- Update TaskDetail.Status
      IF @cTaskStatus <> ''
      BEGIN
         -- Skip task
         IF @cTaskStatus = '0'
         BEGIN
            UPDATE dbo.TaskDetail SET
                UserKey = ''
               ,ReasonKey = ''
               ,Status = '0'
               ,EditDate = GETDATE()
               ,EditWho  = SUSER_SNAME()
               ,TrafficCop = NULL
            WHERE TaskDetailKey = @cTaskDetailKey
            IF @@ERROR <> 0
            BEGIN
             SET @nErrNo = 72294
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
               GOTO Step_9_Fail
            END
         END

         -- Cancel task
         IF @cTaskStatus = 'X'
         BEGIN
            UPDATE dbo.TaskDetail SET
                Status = 'X'
               ,EditDate = GETDATE()
               ,EditWho  = SUSER_SNAME()
               ,TrafficCop = NULL
            WHERE TaskDetailKey = @cTaskDetailKey
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 72295
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdTaskdetFail
               GOTO Step_9_Fail
            END
         END

         -- Cancel picked UCC
         IF EXISTS( SELECT 1 FROM rdt.rdtRPFLog WITH (NOLOCK) WHERE TaskDetailKey = @cTaskDetailKey)
         BEGIN
            DELETE rdt.rdtRPFLog WHERE TaskDetailKey = @cTaskDetailKey
            IF @@ERROR <> 0
            BEGIN
               SET @nErrNo = 72296
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DelRPFLogFail
               GOTO Step_9_Fail
            END
         END
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,        ' +
               '@nFunc           INT,        ' +
               '@cLangCode       NVARCHAR( 3),   ' +
               '@nStep           INT,        ' +
               '@cTaskdetailKey  NVARCHAR( 10),  ' +
               '@nErrNo          INT OUTPUT, ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END

      -- Continue process current task
      IF @cContinueProcess = '1'
      BEGIN
         -- Back to DropID screen
         IF @nFromStep = 1
         BEGIN
            SET @cOutField01 = '' -- DropID
            SET @nScn = @nFromScn
            SET @nStep = @nFromStep
         END

         -- Back to FromLOC screen
         IF @nFromStep = 2
         BEGIN
            SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
            IF ISNULL( @cLocDescr, '') = ''
               SET @cLocDescr = @cSuggFromLOC

            SET @cOutField01 = @cPickMethod
            SET @cOutField02 = @cDropID
            SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
            SET @cOutField04 = '' -- FromLOC
            SET @nScn = @nFromScn
            SET @nStep = @nFromStep
         END

         -- Go to next task screen
         IF @nFromStep = 8 -- Short pick screen
         BEGIN
            SET @cOption = ''
            SET @cOutField01 = '' -- Option
            SET @nScn = @nFromScn - 3
            SET @nStep = @nFromStep - 3
         END
      END
      ELSE
      BEGIN
         -- Setup RDT storer config ContProcNotUpdTaskStatus, to avoid nspRFRSN01 set TaskDetail.Status = '9', when ContinueProcess <> 1

         -- Go to next task/exit TM screen
         IF @cPickMethod = 'FP'
         BEGIN
            SET @nScn  = CASE WHEN @nFromStep = 1 THEN @nFromScn + 6
                              WHEN @nFromStep = 2 THEN @nFromScn + 5
            WHEN @nFromStep = 8 THEN @nFromScn - 1
                         END
            SET @nStep = 7
         END

         -- Go to next task screen
         IF @cPickMethod = 'PP'
         BEGIN
            SET @cOption = ''
            SET @cOutField01 = '' -- Option
            SET @nScn  = CASE WHEN @nFromStep = 1 THEN @nFromScn + 4
                              WHEN @nFromStep = 2 THEN @nFromScn + 3
                              WHEN @nFromStep = 8 THEN @nFromScn - 3
                         END
            SET @nStep = 5
         END
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Go to DropID screen
      IF @nFromStep = 1
      BEGIN
         -- Prepare next screen variable
         SET @cDropID = ''
         SET @cOutField01 = '' -- DropID
      END

      -- Go to FromLOC screen
      IF @nFromStep = 2
      BEGIN
         SELECT @cLocDescr = SUBSTRING( Descr, 1, 20) FROM dbo.LOC WITH (NOLOCK) WHERE Facility = @cFacility AND LOC = @cSuggFromLOC
         IF ISNULL( @cLocDescr, '') = ''
            SET @cLocDescr = @cSuggFromLOC

         -- Prepare next screen variable
         SET @cFromLOC = ''
         SET @cOutField01 = @cPickMethod
         SET @cOutField02 = @cDropID
         SET @cOutField03 = CASE WHEN @cLocShowDescr = '1' THEN @cLocDescr ELSE @cSuggFromLOC END
         SET @cOutField04 = '' -- FromLOC
      END

      -- Go to short pick screen
      IF @nFromStep = 8
      BEGIN
         -- Prepare next screen variable
         SET @cOption = ''
         SET @cOutField01 = '' -- Option
      END

      -- Back to prev screen
      SET @nScn = @nFromScn
      SET @nStep = @nFromStep
   END
   GOTO Quit

   Step_9_Fail:
   BEGIN
      SET @cReasonCode = ''

      -- Reset this screen var
      SET @cOutField01 = ''
   END
END
GOTO Quit


/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE RDTMOBREC WITH (ROWLOCK) SET
      EditDate     = GETDATE(),
      ErrMsg       = @cErrMsg,
      Func         = @nFunc,
      Step         = @nStep,
      Scn          = @nScn,

      StorerKey    = @cStorerKey,
      Facility     = @cFacility,
      Printer      = @cPrinter,
      -- UserName     = @cUserName,

      V_TaskDetailKey = @cTaskDetailKey,
      V_SKU        = @cSuggSKU,
      V_SKUDescr   = @cSKUDesc,
      V_LOT        = @cSuggLOT,
      V_LOC        = @cSuggFromLOC,
      V_ID      = @cSuggID,
      V_UOM        = @cPUOM,
      V_Lottable01 = @cLottable01,
      V_Lottable02 = @cLottable02,
      V_Lottable03 = @cLottable03,
      V_Lottable04 = @dLottable04,

      V_String1    = @cAreaKey,
      V_String2    = @cTaskStorer,
      V_String3    = @cDropID,
      V_String4    = @cPickMethod,
      V_String5    = @cSuggToloc,
      V_String6    = @cReasonCode,
      V_String7    = @cListKey,
      V_String8    = @cDisableQTYField,
      V_String9    = @cMoveQTYReplen,

      V_String10   = @cMUOM_Desc,
      V_String11   = @cPUOM_Desc,
      V_String12   = @cDefaultOption,
      V_String13   = @cLOCLookupSP,
      V_String14   = @cLocShowDescr,
      V_String15   = @cDefaultSKU,
      V_String16   = @cContinueTask,
      V_String17   = @cExtendedValidateSP,
      V_String18   = @cDefaultSuggToLOC,
      V_String19   = @cSuggToLOCSP,
      V_String21   = @cDecodeLabelNo,
      V_String22   = @cExtendedUpdateSP,
      V_String23   = @cDefaultToLOC,
      V_String24   = @cMoveQTYAlloc,
      V_String25   = @cSKUValidated,
      V_String26   = @cDefaultFromID,
      V_String27   = @cExtendedInfoSP,
      V_String28   = @cExtendedInfo1,
      V_String29   = @cGetNextTaskSP,
      V_String30   = @cDisableQTYFieldSP,
      V_String31   = @cDisableOverReplen,

      V_String32   = @cAreakey,
      V_String33   = @cTTMStrategykey,
      V_String34   = @cTTMTaskType,
      V_String35   = @cRefKey01,
      V_String36   = @cRefKey02,
      V_String37   = @cRefKey03,
      V_String38   = @cRefKey04,
      V_String39   = @cRefKey05,
      V_String40   = @cSystemQTY,

      V_String41   = @cSwapTaskSP,
      V_String42   = @cDecodeSP,
      V_String43   = @cSwapUCCSP,

      V_Integer1   = @nQTY_RPL,
      V_Integer2   = @nPQTY_RPL,
      V_Integer3   = @nMQTY_RPL,
      V_Integer4   = @nQTY,

      V_PUOM_Div   = @nPUOM_Div,
      V_PQTY       = @nPQTY,
      V_MQTY       = @nMQTY,
      V_FromScn    = @nFromScn,
      V_FromStep   = @nFromStep,

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
      FieldAttr07  = @cFieldAttr07,   FieldAttr08 = @cFieldAttr08,
      FieldAttr09  = @cFieldAttr09,   FieldAttr10  = @cFieldAttr10,
      FieldAttr11  = @cFieldAttr11,   FieldAttr12  = @cFieldAttr12,
      FieldAttr13  = @cFieldAttr13,   FieldAttr14  = @cFieldAttr14,
      FieldAttr15  = @cFieldAttr15

   WHERE Mobile = @nMobile

   -- Execute TM module initialization (ung01)
   IF (@nFunc <> 1764 AND @nStep = 0) AND -- Other module that begin with step 0
      (@nFunc <> @nMenu)                  -- Not ESC from screen to menu
   BEGIN
      -- Get the stor proc to execute
      DECLARE @cStoredProcName NVARCHAR( 1024)
      SELECT @cStoredProcName = StoredProcName
      FROM RDT.RDTMsg WITH (NOLOCK)
      WHERE Message_ID = @nFunc

      -- Execute the stor proc
      SELECT @cStoredProcName = N'EXEC RDT.' + RTRIM(@cStoredProcName)
      SELECT @cStoredProcName = RTRIM(@cStoredProcName) + ' @InMobile, @nErrNo OUTPUT,  @cErrMsg OUTPUT'
      EXEC sp_executesql @cStoredProcName , N'@InMobile int, @nErrNo int OUTPUT,  @cErrMsg NVARCHAR(125) OUTPUT',
         @nMobile,
         @nErrNo OUTPUT,
         @cErrMsg OUTPUT
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdtfnc_TM_Replen TO NSQL
GO
