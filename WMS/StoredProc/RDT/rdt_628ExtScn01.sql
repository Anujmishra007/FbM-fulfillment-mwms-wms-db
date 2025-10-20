
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************/
/* Store procedure: rdt_628ExtScn01                                       */
/* Copyright      : Maersk WMS                                            */
/*                                                                        */
/* Purpose:                                                               */
/*                                                                        */
/* Date       Rev    Author   Purposes                                    */
/* 2025-09-22 1.0    Dennis   FCR-7784 Created                            */
/**************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_628ExtScn01] (
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
   @nAction      INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
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
   DECLARE @nShelfLife FLOAT
   DECLARE @cResultCode NVARCHAR( 60)
   DECLARE
   @cLOT          NVARCHAR( 10),
   @cLOC          NVARCHAR( 10),
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
   @cSKUDescr     NVARCHAR( 60),
   @cPUOM         NVARCHAR( 1),

   @nTotalRec     INT,
   @nCurrentRec   INT,
   @cPUOM_Desc  NVARCHAR( 5),
   @cMUOM_Desc  NVARCHAR( 5),
   @cLottableCode NVARCHAR( 30),
   @cLOCLookUP   NVARCHAR(20),  --(yeekung01)
   @cExtScnSP    NVARCHAR( 20),
   @cInquiry_LOC  NVARCHAR( 30),
   @cInquiry_ID   NVARCHAR( 18),
   @cInquiry_SKU  NVARCHAR( 20),
   @cInquiry_LocType  NVARCHAR( 20),
   @nMQty_RPL     FLOAT,
   @nPQty_RPL     FLOAT,
   @nMQty_TTL     FLOAT,
   @nPQty_TTL     FLOAT,
   @nMQty_Pick    FLOAT,
   @nPQty_Pick    FLOAT,
   @nPQTY_Avail FLOAT,
   @nMQTY_Avail FLOAT,
   @nPQTY_Alloc FLOAT,
   @nMQTY_Alloc FLOAT,
   @nPUOM_Div   INT,
   @nPQTY_Hold  FLOAT,
   @nMQTY_Hold  FLOAT,
   @nPQTY_PMV   FLOAT,
   @nMQTY_PMV   FLOAT,
   @b_Success   INT,
   @nMorePage  INT,
   @bSuccess   INT,
   @n_err      INT,
   @c_ErrMsg   NVARCHAR( 200),
   @cIgnoreLot NVARCHAR( 1),
   @cDecodeSP     NVARCHAR( 20),
   @cBarcode      NVARCHAR( 60),
   @nQty          INT,
   @cSQL          NVARCHAR( MAX),
   @cSQLParam     NVARCHAR( MAX),
   @cUserDefine01 NVARCHAR( 60),
   @cUserDefine02 NVARCHAR( 60),
   @cUserDefine03 NVARCHAR( 60),
   @cUserDefine04 NVARCHAR( 60),
   @cUserDefine05 NVARCHAR( 60),
   @cSKUConfig    NVARCHAR( 20),
    @cHasLottable  NVARCHAR( 1),
   @cDecodeLabelNo      NVARCHAR( 20),
   @cSKUBarcode         NVARCHAR( 30),
   @cSKUBarcode1        NVARCHAR( 20),
   @cSKUBarcode2        NVARCHAR( 20),
   @cChkStorerKey       NVARCHAR( 15),
   @cCustomInquiryRule_SP  NVARCHAR( 20),
   @cType               NVARCHAR( 10),
   @nMOBRECScn          INT,  
   @nMOBRECStep         int,
   @nOption             INT,
   @cTempValue          NVARCHAR(60),
   
   @nQTY_TTL            INT,
   @nQTY_Hold           INT,
   @nQTY_Alloc          INT,
   @nQTY_Pick           INT,
   @nQTY_RPL            INT,
   @nQTY_Avail          INT,
   @nMenu               INT,
   @nSKUCnt             INT

   -- Screen constant
   DECLARE
      @nStep_LocIDSKU   INT,  @nScn_LocIDSKU   INT,
      @nStep_Result     INT,  @nScn_Result     INT,
      @nStep_Lottables  INT,  @nScn_Lottables  INT,
      @nStep_DataInquiry INT, @nScn_DataInquiry INT

   DECLARE @tList TABLE
   (
      ID                      INT IDENTITY(1,1),
      DESCR                    NVARCHAR(10),
      SHORT                   NVARCHAR(20)
   )
   
   DECLARE @nLoopIndex INT = -1,
      @cDesc NVARCHAR( 10),
      @nRowCount INT,
      @cOutput NVARCHAR( 100),
      @cShort NVARCHAR( 20)
   SELECT
      @nStep_LocIDSKU   = 1,  @nScn_LocIDSKU    = 5140,
      @nStep_Result     = 2,  @nScn_Result      = 5141,
      @nStep_Lottables  = 3,  @nScn_Lottables   = 5142,
      @nStep_DataInquiry  = 4,  @nScn_DataInquiry   = 5143

   SELECT
      @nMenu      = Menu,
      @cLOT       = V_LOT,
      @cLOC       = V_LOC,
      @cID        = V_ID,
      @cSKU       = V_SKU,
      @cPUOM      = V_UOM,
      @cSKUDescr  = V_SKUDescr,

      @nTotalRec    = V_Integer1,
      @nCurrentRec  = V_Integer2,
      @nPQTY_Avail  = V_Integer3,
      @nPQTY_Alloc  = V_Integer4,
      @nPQTY_PMV    = V_Integer5,
      @nMQTY_Avail  = V_Integer6,
      @nMQTY_Alloc  = V_Integer7,
      @nMQTY_PMV    = V_Integer8,
      @nMQTY_TTL    = V_Integer9,
      @nMQTY_RPL    = V_Integer10,
      @nPQTY_TTL    = V_Integer11,
      @nPQTY_RPL    = V_Integer12,
      @nMQTY_Pick   = V_Integer13,
      @nPQTY_Pick   = V_Integer14,

      @cInquiry_LOC = V_String1,
      @cInquiry_ID  = V_String2,
      @cInquiry_SKU = V_String3,
      @cPUOM_Desc   = V_String4,
      @cMUOM_Desc   = V_String5,
      @cDecodeSP    = V_String6,
      @cHasLottable = V_String7,
      @cSKUBarcode1           = V_String8,
      @cSKUBarcode2           = V_String9,
      @cLottableCode          = V_String10,
      @cCustomInquiryRule_SP  = V_String11,
      @cType                  = V_String12,
      @cLOCLookUP             = V_String13,  --(yeekung01)
      @cUserDefine01          = V_String14,
      @cUserDefine02          = V_String15,
      @cUserDefine03          = V_String16,
      @cUserDefine04          = V_String17,
      @cUserDefine05          = V_String18,
      @cSKUConfig             = V_String19,
      @cExtScnSP              = V_String20,
      @nMOBRECScn = Scn,
      @nMOBRECStep = Step
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 628
   BEGIN
      IF @nMOBRECStep = 0
      BEGIN
         SET @cOutField01 = ''
         SET @cOutField02 = ''
         SET @cOutField03 = ''
         SET @cOutField04 = ''

         SET @nAfterScn = 6677
         SET @nAfterStep = 99
         GOTO QUIT
      END
      IF @nMOBRECStep = 99 AND @nMOBRECScn = 6677
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Screen mapping
            SET @cInquiry_LOC = @cInField01
            SET @cInquiry_ID = @cInField02
            SET @cInquiry_SKU = @cInField03
            SET @cInquiry_LocType = @cInField04

            IF @cInquiry_LocType <> '' AND (@cInquiry_LOC = '' AND @cInquiry_ID = '' AND @cInquiry_SKU = '')
            BEGIN
               SET @nErrNo = 247351
               SET @cErrMsg = rdt.rdtgetmessagelong( @nErrNo, @cLangCode, 'DSP') -- Please enter one more criteria
               GOTO Step_1_Fail
            END

            -- Get no field keyed-in
            DECLARE @i INT
            SET @i = 0
            IF @cInquiry_LOC <> '' AND @cInquiry_LOC IS NOT NULL SET @i = @i + 1
            IF @cInquiry_ID  <> '' AND @cInquiry_ID  IS NOT NULL SET @i = @i + 1
            IF @cInquiry_SKU <> '' AND @cInquiry_SKU IS NOT NULL SET @i = @i + 1

            IF @i = 0
            BEGIN
               SET @nErrNo = 123251
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Value needed'
               EXEC rdt.rdtSetFocusField @nMobile, 1
               GOTO Step_1_Fail
            END

            IF @i > 1
            BEGIN
               SET @nErrNo = 123252
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'ID/LOC/SKUOnly'
               EXEC rdt.rdtSetFocusField @nMobile, 1
               GOTO Step_1_Fail
            END

            SELECT @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL,  @dLottable05 = NULL,
                  @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',    @cLottable10 = '',
                  @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL,  @dLottable15 = NULL,
                  @cLOT = '', @cLOC = '', @cID = '', @cSKU = '', @cHasLottable = '', @nTotalRec = 0

            IF @cDecodeSP <> ''
            BEGIN
               -- Only one value can key in
               SELECT @cBarcode =
                  CASE
                     WHEN @cInquiry_LOC <> '' THEN @cInField01
                     WHEN @cInquiry_ID  <> '' THEN @cInField02
                     WHEN @cInquiry_SKU <> '' THEN @cInField03
                  END

               -- Standard decode
               IF @cDecodeSP = '1'
               BEGIN
                  IF @cInquiry_ID <> ''
                  BEGIN
                     SET @cID = ''
                     EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                        @cID         = @cID         OUTPUT,
                        @nQTY        = @nQTY        OUTPUT,
                        @cLottable01 = @cLottable01 OUTPUT,
                        @cLottable02 = @cLottable02 OUTPUT,
                        @cLottable03 = @cLottable03 OUTPUT,
                        @dLottable04 = @dLottable04 OUTPUT,
                        @dLottable05 = @dLottable05 OUTPUT,
                        @cLottable06 = @cLottable06 OUTPUT,
                        @cLottable07 = @cLottable07 OUTPUT,
                        @cLottable08 = @cLottable08 OUTPUT,
                        @cLottable09 = @cLottable09 OUTPUT,
                        @cLottable10 = @cLottable10 OUTPUT,
                        @cLottable11 = @cLottable11 OUTPUT,
                        @cLottable12 = @cLottable12 OUTPUT,
                        @dLottable13 = @dLottable13 OUTPUT,
                        @dLottable14 = @dLottable14 OUTPUT,
                        @dLottable15 = @dLottable15 OUTPUT,
                        @cType       = 'ID'

                     IF @cID <> ''
                        SET @cInquiry_ID = @cID
                  END

                  IF @cInquiry_SKU <> ''
                  BEGIN
                     DECLARE @cUPC NVARCHAR( 30) = ''
                     EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                        @cUPC        = @cUPC        OUTPUT,
                        @nQTY        = @nQTY        OUTPUT,
                        @cLottable01 = @cLottable01 OUTPUT,
                        @cLottable02 = @cLottable02 OUTPUT,
                        @cLottable03 = @cLottable03 OUTPUT,
                        @dLottable04 = @dLottable04 OUTPUT,
                        @dLottable05 = @dLottable05 OUTPUT,
                        @cLottable06 = @cLottable06 OUTPUT,
                        @cLottable07 = @cLottable07 OUTPUT,
                        @cLottable08 = @cLottable08 OUTPUT,
                        @cLottable09 = @cLottable09 OUTPUT,
                        @cLottable10 = @cLottable10 OUTPUT,
                        @cLottable11 = @cLottable11 OUTPUT,
                        @cLottable12 = @cLottable12 OUTPUT,
                        @dLottable13 = @dLottable13 OUTPUT,
                        @dLottable14 = @dLottable14 OUTPUT,
                        @dLottable15 = @dLottable15 OUTPUT,
                        @cType       = 'UPC'

                     IF @cUPC <> ''
                        SET @cInquiry_SKU = @cUPC
                  END
               END

               -- Customize decode
               ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cBarcode, ' +
                     ' @cLOC           OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT,   ' +
                     ' @cLottable01    OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT, @dLottable04    OUTPUT, @dLottable05    OUTPUT, ' +
                     ' @cLottable06    OUTPUT, @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT, @cLottable10    OUTPUT, ' +
                     ' @cLottable11    OUTPUT, @cLottable12    OUTPUT, @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT, ' +
                     ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'
                  SET @cSQLParam =
                     ' @nMobile        INT,           ' +
                     ' @nFunc          INT,           ' +
                     ' @cLangCode      NVARCHAR( 3),  ' +
                     ' @nStep          INT,           ' +
                     ' @nInputKey      INT,           ' +
                     ' @cStorerKey     NVARCHAR( 15), ' +
                     ' @cBarcode       NVARCHAR( 60), ' +
                     ' @cLOC           NVARCHAR( 10)  OUTPUT, ' +
                     ' @cID            NVARCHAR( 18)  OUTPUT, ' +
                     ' @cSKU           NVARCHAR( 20)  OUTPUT, ' +
                     ' @cLottable01    NVARCHAR( 18)  OUTPUT, ' +
                     ' @cLottable02    NVARCHAR( 18)  OUTPUT, ' +
                     ' @cLottable03    NVARCHAR( 18)  OUTPUT, ' +
                     ' @dLottable04    DATETIME       OUTPUT, ' +
                     ' @dLottable05    DATETIME       OUTPUT, ' +
                     ' @cLottable06    NVARCHAR( 30)  OUTPUT, ' +
                     ' @cLottable07    NVARCHAR( 30)  OUTPUT, ' +
                     ' @cLottable08    NVARCHAR( 30)  OUTPUT, ' +
                     ' @cLottable09    NVARCHAR( 30)  OUTPUT, ' +
                     ' @cLottable10    NVARCHAR( 30)  OUTPUT, ' +
                     ' @cLottable11    NVARCHAR( 30)  OUTPUT, ' +
                     ' @cLottable12    NVARCHAR( 30)  OUTPUT, ' +
                     ' @dLottable13    DATETIME       OUTPUT, ' +
                     ' @dLottable14    DATETIME       OUTPUT, ' +
                     ' @dLottable15    DATETIME       OUTPUT, ' +
                     ' @nErrNo         INT            OUTPUT, ' +
                     ' @cErrMsg        NVARCHAR( 20)  OUTPUT'

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cBarcode,
                     @cLOC          OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT,
                     @cLottable01   OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT, @dLottable04    OUTPUT, @dLottable05    OUTPUT,
                     @cLottable06   OUTPUT, @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT, @cLottable10    OUTPUT,
                     @cLottable11   OUTPUT, @cLottable12    OUTPUT, @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT,
                     @nErrNo        OUTPUT, @cErrMsg        OUTPUT

                  IF ISNULL(@nErrNo, 0) <> 0
                     GOTO Step_1_Fail
                  ELSE
                  BEGIN
                     -- Decode can output any value
                     SET @cInquiry_LOC = CASE WHEN @cLOC <> '' THEN @cLOC ELSE '' END
                     SET @cInquiry_ID = CASE WHEN @cID <> '' THEN @cID ELSE '' END
                     SET @cInquiry_SKU = CASE WHEN @cSKU <> '' THEN @cSKU ELSE '' END

                  END
               END
            END

            -- By LOC
            IF @cInquiry_LOC <> '' AND @cInquiry_LOC IS NOT NULL
            BEGIN
               IF @cLOCLookUP <> ''       --(yeekung01)
               BEGIN

                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cLOCLookUP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cLOCLookUP)
                     + ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey'
                     + ' , @cFacility, @cInquiry_LOC OUTPUT,@nErrNo     OUTPUT, @cErrMsg    OUTPUT '
                     SET @cSQLParam =
                     ' @nMobile        INT,           ' +
                     ' @nFunc          INT,           ' +
                     ' @cLangCode      NVARCHAR( 3),  ' +
                     ' @nStep          INT,           ' +
                     ' @nInputKey      INT,           ' +
                     ' @cStorerKey     NVARCHAR( 15), ' +
                     ' @cFacility      NVARCHAR( 10), ' +
                     ' @cInquiry_LOC   NVARCHAR( 30) OUTPUT, ' +
                     ' @nErrNo         INT OUTPUT, ' +
                     ' @cErrMsg        NVARCHAR(MAX) OUTPUT '

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey
                        , @cFacility, @cInquiry_LOC OUTPUT,@nErrNo     OUTPUT,@cErrMsg    OUTPUT

                     IF @nErrNo <> 0
                        GOTO Step_1_Fail
                  END
                  ELSE IF  @cLOCLookUP='1'
                  BEGIN
                     EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,
                        @cInquiry_LOC OUTPUT,
                        @nErrNo     OUTPUT,
                        @cErrMsg    OUTPUT

                     IF @nErrNo <> 0
                        GOTO Step_1_Fail
                  END
               END


               DECLARE @cChkFacility NVARCHAR( 5)
               SELECT @cChkFacility = Facility
               FROM dbo.LOC WITH (NOLOCK)
               WHERE LOC = @cInquiry_LOC

               -- Validate LOC
               IF @@ROWCOUNT = 0
               BEGIN
                  SET @nErrNo = 123253
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid LOC'
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO Step_1_Fail
               END

               IF @cChkFacility <> @cFacility
               BEGIN
                  SET @nErrNo = 123254
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Diff facility'
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO Step_1_Fail
               END
            END

            -- By ID
            IF @cInquiry_ID <> '' AND @cInquiry_ID IS NOT NULL
            BEGIN
               -- Validate ID
               IF NOT EXISTS (SELECT 1
                  FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                     INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOC.LOC = LLI.LOC)
                  WHERE LOC.Facility = @cFacility
                     AND LLI.ID = @cInquiry_ID)
               BEGIN
                  SET @nErrNo = 123255
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid ID'
                  EXEC rdt.rdtSetFocusField @nMobile, 2
                  GOTO Step_1_Fail
               END

               SET @nTotalRec = 0
               SELECT @nTotalRec = COUNT( 1)
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOC.LOC = LLI.LOC)
               WHERE LOC.Facility = @cFacility
               AND   LLI.ID = @cInquiry_ID
               AND  (LLI.QTY + LLI.QtyAllocated + LLI.QtyPicked + LLI.QtyExpected <> 0)
               AND   EXISTS (SELECT 1 FROM dbo.StorerGroup ST WITH (NOLOCK) WHERE LLI.StorerKey = ST.StorerKey AND StorerGroup = @cStorerKey)
            END

            --WMS7485
            -- By SKU
            IF @cInquiry_SKU <> '' AND @cInquiry_SKU IS NOT NULL
            BEGIN
               EXEC [RDT].[rdt_GETSKUCNT]
               @cStorerKey  = @cStorerKey
               ,@cSKU        = @cInquiry_SKU
               ,@nSKUCnt     = @nSKUCnt       OUTPUT
               ,@bSuccess    = @b_Success     OUTPUT
               ,@nErr        = @n_Err         OUTPUT
               ,@cErrMsg     = @c_ErrMsg      OUTPUT

               -- Validate SKU/UPC
               IF @nSKUCnt = 0
               BEGIN
                  SET @nErrNo = 123257
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid SKU'
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  GOTO Step_1_Fail
               END

               IF @nSKUCnt > 1
               BEGIN
                  SET @nErrNo = 123258
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'MultiSKUBarcod'
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  GOTO Step_1_Fail
               END

               EXEC [RDT].[rdt_GETSKU]
                  @cStorerKey   = @cStorerKey
               ,@cSKU         = @cInquiry_SKU OUTPUT
               ,@bSuccess     = @bSuccess     OUTPUT
               ,@nErr         = @nErrNo       OUTPUT
               ,@cErrMsg      = @cErrMsg      OUTPUT

               IF @bSuccess <> 1
               BEGIN
                  SET @nErrNo = 123256
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid SKU'
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  GOTO Step_1_Fail
               END

               SET @nTotalRec = 0
               SELECT @nTotalRec = COUNT( 1)
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOC.LOC = LLI.LOC)
               WHERE LOC.Facility = @cFacility
               AND   LLI.SKU = @cInquiry_SKU
               AND  (LLI.QTY + LLI.QtyAllocated + LLI.QtyPicked + LLI.QtyExpected <> 0)
               AND   EXISTS (SELECT 1 FROM dbo.StorerGroup ST WITH (NOLOCK) WHERE LLI.StorerKey = ST.StorerKey AND StorerGroup = @cStorerKey)
            END
            
            UPDATE RDT.RDTMOBREC
            SET c_string1 = @cInquiry_LocType
            WHERE Mobile = @nMobile

            IF @cInquiry_SKU <> '' AND (@cInquiry_LOC = '' AND @cInquiry_ID = '' AND @cInquiry_LocType = '')
            BEGIN
               DECLARE @tTempResults TABLE (
                  RowNum INT IDENTITY(1,1),
                  Result VARCHAR(60)
               )

               INSERT INTO @tTempResults (Result)
               SELECT TOP 12 CAST(ROW_NUMBER() OVER(ORDER BY code) AS VARCHAR) + ' - ' + short
               FROM CODELKUP WITH (NOLOCK)
               WHERE Code2 = '628' AND StorerKey = @cStorerKey AND LISTNAME = '628LTList'

               SELECT 
                  @cOutField01 = '',
                  @cOutfield02 = MAX(CASE WHEN RowNum = 1 THEN Result END),
                  @cOutfield03 = MAX(CASE WHEN RowNum = 2 THEN Result END),
                  @cOutfield04 = MAX(CASE WHEN RowNum = 3 THEN Result END),
                  @cOutfield05 = MAX(CASE WHEN RowNum = 4 THEN Result END),
                  @cOutfield06 = MAX(CASE WHEN RowNum = 5 THEN Result END),
                  @cOutfield07 = MAX(CASE WHEN RowNum = 6 THEN Result END),
                  @cOutfield08 = MAX(CASE WHEN RowNum = 7 THEN Result END),
                  @cOutfield09 = MAX(CASE WHEN RowNum = 8 THEN Result END),
                  @cOutfield10 = MAX(CASE WHEN RowNum = 9 THEN Result END),
                  @cOutfield11 = MAX(CASE WHEN RowNum = 10 THEN Result END),
                  @cOutfield12 = MAX(CASE WHEN RowNum = 11 THEN Result END)
               FROM @tTempResults

               SET @cUDF01 = @nTotalRec
               SET @CUDF02 = @nCurrentRec
               SET @cUDF03 = @cSKU
               SET @CUDF04 = @cLOC
               SET @CUDF05 = @cID
               SET @cUDF06 = @cLOT
               SET @cUDF07 = @cSKUDescr
               SET @CUDF08 = @cInquiry_ID
               SET @CUDF09 = @cInquiry_SKU
               SET @CUDF10 = @cInquiry_LOC
               SET @CUDF11 = @cLottableCode
               SET @CUDF12 = @chasLottable

               SET @nAfterScn = 6682
               SET @nAfterStep = 99
               GOTO QUIT
            END

            IF @cCustomInquiryRule_SP <> '' AND
               EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cCustomInquiryRule_SP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cCustomInquiryRule_SP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cType, @cStorerkey, @cPUOM, ' +
               ' @cInquiry_LOC, @cInquiry_ID, @cInquiry_SKU, ' +
               ' @cLOT           OUTPUT, @cLOC           OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT, ' +
               ' @cSKUDescr      OUTPUT, @nTotalRec      OUTPUT, ' +
               ' @nMQty_TTL      OUTPUT, @nMQTY_PMV      OUTPUT, @nMQTY_Alloc    OUTPUT, ' +
               ' @nMQty_Pick     OUTPUT, @nMQty_RPL      OUTPUT, @nMQTY_Avail    OUTPUT, ' +
               ' @nPQty_TTL      OUTPUT, @nPQTY_PMV      OUTPUT, @nPQTY_Alloc    OUTPUT, ' +
               ' @nPQty_Pick     OUTPUT, @nPQty_RPL      OUTPUT, @nPQTY_Avail    OUTPUT, ' +
               ' @cPUOM_Desc     OUTPUT, @cMUOM_Desc     OUTPUT, @cLottableCode  OUTPUT, ' +
               ' @cLottable01    OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT, ' +
               ' @dLottable04    OUTPUT, @dLottable05    OUTPUT, @cLottable06    OUTPUT, ' +
               ' @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT, ' +
               ' @cLottable10    OUTPUT, @cLottable11    OUTPUT, @cLottable12    OUTPUT, ' +
               ' @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT, ' +
               ' @cHasLottable   OUTPUT, @cUserDefine01 OUTPUT, @cUserDefine02  OUTPUT, @cUserDefine03  OUTPUT, @cUserDefine04  OUTPUT, @cUserDefine05  OUTPUT, @cSKUConfig OUTPUT, ' +
               ' @nErrNo         OUTPUT, @cErrMsg        OUTPUT '

               SET @cSQLParam =
                  '@nMobile         INT,                  '+
                  '@nFunc           INT,                  '+
                  '@cLangCode       NVARCHAR( 3),         '+
                  '@nStep           INT,                  '+
                  '@nInputKey       INT,                  '+
                  '@cFacility       NVARCHAR( 5),         '+
                  '@cType           NVARCHAR( 10),        '+
                  '@cStorerkey      NVARCHAR( 15),        '+
                  '@cPUOM           NVARCHAR( 1),         '+
                  '@cInquiry_LOC    NVARCHAR( 10),        '+
                  '@cInquiry_ID     NVARCHAR( 18),        '+
                  '@cInquiry_SKU    NVARCHAR( 20),        '+
                  '@cLOT            NVARCHAR( 10)  OUTPUT,'+
                  '@cLOC            NVARCHAR( 10)  OUTPUT,'+
                  '@cID             NVARCHAR( 18)  OUTPUT,'+
                  '@cSKU            NVARCHAR( 20)  OUTPUT,'+
                  '@cSKUDescr       NVARCHAR( 60)  OUTPUT,'+
                  '@nTotalRec       INT            OUTPUT,'+
                  '@nMQTY_TTL       INT            OUTPUT,'+
                  '@nMQTY_PMV       INT            OUTPUT,'+
                  '@nMQTY_Alloc     INT            OUTPUT,'+
                  '@nMQTY_Pick      INT            OUTPUT,'+
                  '@nMQTY_RPL       INT            OUTPUT,'+
                  '@nMQTY_Avail     INT            OUTPUT,'+
                  '@nPQTY_TTL       INT            OUTPUT,'+
                  '@nPQTY_PMV       INT            OUTPUT,'+
                  '@nPQTY_Alloc     INT            OUTPUT,'+
                  '@nPQTY_Pick      INT            OUTPUT,'+
                  '@nPQTY_RPL       INT            OUTPUT,'+
                  '@nPQTY_Avail     INT            OUTPUT,'+
                  '@cPUOM_Desc      NVARCHAR( 5)   OUTPUT,'+
                  '@cMUOM_Desc      NVARCHAR( 5)   OUTPUT,'+
                  '@cLottableCode   NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable01     NVARCHAR( 18)  OUTPUT,'+
                  '@cLottable02     NVARCHAR( 18)  OUTPUT,'+
                  '@cLottable03     NVARCHAR( 18)  OUTPUT,'+
                  '@dLottable04     DATETIME       OUTPUT,'+
                  '@dLottable05     DATETIME       OUTPUT,'+
                  '@cLottable06     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable07     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable08     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable09     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable10     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable11     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable12     NVARCHAR( 30)  OUTPUT,'+
                  '@dLottable13     DATETIME       OUTPUT,'+
                  '@dLottable14     DATETIME       OUTPUT,'+
                  '@dLottable15     DATETIME       OUTPUT,'+
                  '@cHasLottable    NVARCHAR( 1)   OUTPUT,'+
                  '@cUserDefine01   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine02   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine03   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine04   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine05   NVARCHAR( 60)  OUTPUT,'+
                  '@cSKUConfig      NVARCHAR( 60)  OUTPUT,'+
                  '@nErrNo          INT            OUTPUT,'+
                  '@cErrMsg         NVARCHAR( 20)  OUTPUT '

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cType, @cStorerkey, @cPUOM,
                  @cInquiry_LOC, @cInquiry_ID, @cInquiry_SKU,
                  @cLOT           OUTPUT, @cLOC           OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT,
                  @cSKUDescr      OUTPUT, @nTotalRec      OUTPUT,
                  @nMQty_TTL      OUTPUT, @nMQTY_PMV      OUTPUT, @nMQTY_Alloc    OUTPUT,
                  @nMQty_Pick     OUTPUT, @nMQty_RPL      OUTPUT, @nMQTY_Avail    OUTPUT,
                  @nPQty_TTL      OUTPUT, @nPQTY_PMV      OUTPUT, @nPQTY_Alloc    OUTPUT,
                  @nPQty_Pick     OUTPUT, @nPQty_RPL      OUTPUT, @nPQTY_Avail    OUTPUT,
                  @cPUOM_Desc     OUTPUT, @cMUOM_Desc     OUTPUT, @cLottableCode  OUTPUT,
                  @cLottable01    OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT,
                  @dLottable04    OUTPUT, @dLottable05    OUTPUT, @cLottable06    OUTPUT,
                  @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT,
                  @cLottable10    OUTPUT, @cLottable11    OUTPUT, @cLottable12    OUTPUT,
                  @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT,
                  @cHasLottable   OUTPUT,@cUserDefine01 OUTPUT, @cUserDefine02  OUTPUT, @cUserDefine03  OUTPUT, @cUserDefine04  OUTPUT, @cUserDefine05  OUTPUT, @cSKUConfig OUTPUT,
                  @nErrNo         OUTPUT, @cErrMsg        OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Step_1_Fail
               END
            END
            ELSE
            BEGIN
               EXECUTE [RDT].[rdt_Inquiry_V7]
                  @nMobile,
                  @nFunc,
                  @cLangCode,
                  @nStep,
                  @nInputKey,
                  @cFacility,
                  @cType,
                  @cStorerkey,
                  @cPUOM,
                  @cInquiry_LOC,
                  @cInquiry_ID,
                  @cInquiry_SKU,
                  @cLOT              OUTPUT,
                  @cLOC              OUTPUT,
                  @cID               OUTPUT,
                  @cSKU              OUTPUT,
                  @cSKUDescr         OUTPUT,
                  @nTotalRec         OUTPUT,
                  @nMQTY_TTL         OUTPUT,
                  @nMQTY_PMV         OUTPUT,
                  @nMQTY_Alloc       OUTPUT,
                  @nMQTY_Pick        OUTPUT,
                  @nMQTY_RPL         OUTPUT,
                  @nMQTY_Avail       OUTPUT,
                  @nPQTY_TTL         OUTPUT,
                  @nPQTY_PMV         OUTPUT,
                  @nPQTY_Alloc       OUTPUT,
                  @nPQTY_Pick        OUTPUT,
                  @nPQTY_RPL         OUTPUT,
                  @nPQTY_Avail       OUTPUT,
                  @cPUOM_Desc        OUTPUT,
                  @cMUOM_Desc        OUTPUT,
                  @cLottableCode     OUTPUT,
                  @cLottable01       OUTPUT,
                  @cLottable02       OUTPUT,
                  @cLottable03       OUTPUT,
                  @dLottable04       OUTPUT,
                  @dLottable05       OUTPUT,
                  @cLottable06       OUTPUT,
                  @cLottable07       OUTPUT,
                  @cLottable08       OUTPUT,
                  @cLottable09       OUTPUT,
                  @cLottable10       OUTPUT,
                  @cLottable11       OUTPUT,
                  @cLottable12       OUTPUT,
                  @dLottable13       OUTPUT,
                  @dLottable14       OUTPUT,
                  @dLottable15       OUTPUT,
                  @cHasLottable      OUTPUT,
                  @cUserDefine01     OUTPUT,
                  @cUserDefine02     OUTPUT,
                  @cUserDefine03     OUTPUT,
                  @cUserDefine04     OUTPUT,
                  @cUserDefine05     OUTPUT,
                  @cSKUConfig        OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Step_1_Fail
               END
            END

            -- Prep next screen var
            SET @nCurrentRec = 1
            SET @cOutField01 = CAST( @nCurrentRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
            SET @cOutField02 = @cSKU
            SET @cOutField03 = SUBSTRING( @cSKUDescr, 1, 20)
            SET @cOutField04 = SUBSTRING( @cSKUDescr, 21, 20)
            SET @cOutField05 = @cLOC
            SET @cOutField06 = @cID
            SET @cOutField07 = CASE WHEN @cPUOM_Desc <> ''
                                 THEN SPACE( 9) + LEFT( @cPUOM_Desc + REPLICATE(' ', 5), 5) + ' ' + @cMUOM_Desc
                                 ELSE SPACE( 9) + @cMUOM_Desc END

            DELETE FROM @tList
            INSERT INTO @tList ( DESCR, SHORT)
            SELECT Description, Short
            FROM CODELKUP WITH (NOLOCK)
            WHERE Code2 = '628' AND StorerKey = @cStorerKey AND LISTNAME = '628QtyList'
            ORDER BY code

            WHILE (1=1)
            BEGIN 
               SELECT TOP 1
                  @cDesc = DESCR,
                  @cShort = SHORT,
                  @nLoopIndex = id
               FROM @tList
               WHERE id > @nLoopIndex
               ORDER BY id
               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0 OR @nLoopIndex > 6
                  BREAK
               
               SET @cOutput = ''

               IF @cShort = 'QTYALC'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_Alloc, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Alloc, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Alloc, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYPCK'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_Pick, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Pick, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Pick, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYRPL'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_RPL, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_RPL, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_RPL, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYPMV'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_PMV, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_PMV, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_PMV, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYAVL'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_Avail, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Avail, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Avail, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYPHY'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( @cUserDefine01  + SPACE( 6), 6) + CAST( LEFT(@cUserDefine02, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@cUserDefine02, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYTTL'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_TTL, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_TTL, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_TTL, 5)   AS NVARCHAR( 5)) END
               
               IF @nLoopIndex = 1
                  SET @cOutField08 = @cOutput
               ELSE IF @nLoopIndex = 2
                  SET @cOutField09 = @cOutput
               ELSE IF @nLoopIndex = 3
                  SET @cOutField10 = @cOutput
               ELSE IF @nLoopIndex = 4
                  SET @cOutField11 = @cOutput
               ELSE IF @nLoopIndex = 5
                  SET @cOutField12 = @cOutput
               ELSE IF @nLoopIndex = 6
                  SET @cOutField13 = @cOutput
            END

            SET @cUDF01 = @nTotalRec
            SET @CUDF02 = @nCurrentRec
            SET @cUDF03 = @cSKU
            SET @CUDF04 = @cLOC
            SET @CUDF05 = @cID
            SET @cUDF06 = @cLOT
            SET @cUDF07 = @cSKUDescr
            SET @CUDF08 = @cInquiry_ID
            SET @CUDF09 = @cInquiry_SKU
            SET @CUDF10 = @cInquiry_LOC
            SET @CUDF11 = @cLottableCode
            SET @CUDF12 = @chasLottable

            -- Go to next screen
            SET @nAfterScn = 6679
            SET @nAfterStep = 99
         END

         IF @nInputKey = 0 -- ESC
         BEGIN
            -- Back to menu
            SET @nFunc = @nMenu
            SET @nAfterScn  = @nMenu
            SET @nAfterStep = 0
            SET @cOutField01 = ''
         END
         GOTO Quit

         Step_1_Fail:
         BEGIN
            SET @cOutField01 = '' -- LOC
            SET @cOutField02 = '' -- ID
            SET @cOutField03 = '' -- SKU
            SET @cOutField04 = '' -- SKU
         END
      END
      IF @nMOBRECStep = 99 AND @nMOBRECScn = 6679
      BEGIN
         IF @nInputKey = 1      -- Yes or Send
         BEGIN
            SELECT @cOutField01 = '', @cOutField02 = '', @cOutField03 = '', @cOutField04 = '', @cOutField05 = ''
            SELECT @cOutField06 = '', @cOutField07 = '', @cOutField08 = '', @cOutField09 = '', @cOutField10 = ''

         
            SET @cIgnoreLot = rdt.RDTGetConfig( @nFunc, 'IgnoreLot', @cStorerKey)
            IF @cIgnoreLot = '0'
               SET @cIgnoreLot = ''
            
            IF @cIgnoreLot <> '1'
            BEGIN
               -- Dynamic lottable
               EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'DISPLAY', 'POPULATE', 10, 1,
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

               IF @cHasLottable = '1'
               BEGIN
                  -- Go to lottable screen
                  SET @nScn = @nScn_Lottables
                  SET @nStep = @nStep_Lottables
                  GOTO Quit
               END
            END
            ELSE IF  @cSKUConfig = '1'
            BEGIN
               SET @cOutField01 = @cUserDefine01
               SET @cOutField02 = @cUserDefine02
               SET @cOutField03 = @cUserDefine03
               SET @cOutField04 = @cUserDefine04
               SET @cOutField05 = @cUserDefine05
               -- Go to Data Inquiry screen
               SET @nAfterScn = @nScn_DataInquiry
               SET @nAfterStep = @nStep_DataInquiry

               GOTO Quit
            END
            BEGIN
               IF @nCurrentRec = @nTotalRec
               BEGIN
                  SET @cSKU = ''
                  SET @cLOC = ''
                  SET @cID = ''
                  SET @cLOT = ''
                  SET @nCurrentRec = 0
                  SET @cType = ''
               END
               ELSE
                  SET @cType = 'Next'

               SET @cHasLottable = ''

               IF @cCustomInquiryRule_SP <> '' AND
                  EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cCustomInquiryRule_SP AND type = 'P')
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cCustomInquiryRule_SP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cType, @cStorerkey, @cPUOM, ' +
                     ' @cInquiry_LOC, @cInquiry_ID, @cInquiry_SKU, ' +
                     ' @cLOT           OUTPUT, @cLOC           OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT, ' +
                     ' @cSKUDescr      OUTPUT, @nTotalRec      OUTPUT, ' +
                     ' @nMQty_TTL      OUTPUT, @nMQTY_PMV      OUTPUT, @nMQTY_Alloc    OUTPUT, ' +
                     ' @nMQty_Pick     OUTPUT, @nMQty_RPL      OUTPUT, @nMQTY_Avail    OUTPUT, ' +
                     ' @nPQty_TTL      OUTPUT, @nPQTY_PMV      OUTPUT, @nPQTY_Alloc    OUTPUT, ' +
                     ' @nPQty_Pick     OUTPUT, @nPQty_RPL      OUTPUT, @nPQTY_Avail    OUTPUT, ' +
                     ' @cPUOM_Desc     OUTPUT, @cMUOM_Desc     OUTPUT, @cLottableCode  OUTPUT, ' +
                     ' @cLottable01    OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT, ' +
                     ' @dLottable04    OUTPUT, @dLottable05    OUTPUT, @cLottable06    OUTPUT, ' +
                     ' @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT, ' +
                     ' @cLottable10    OUTPUT, @cLottable11    OUTPUT, @cLottable12    OUTPUT, ' +
                     ' @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT, ' +
                     ' @cHasLottable   OUTPUT, @cUserDefine01 OUTPUT, @cUserDefine02  OUTPUT, @cUserDefine03  OUTPUT, @cUserDefine04  OUTPUT, @cUserDefine05  OUTPUT, @cSKUConfig OUTPUT, ' +
                     ' @nErrNo         OUTPUT, @cErrMsg        OUTPUT '

                  SET @cSQLParam =
                     '@nMobile         INT,                  '+
                     '@nFunc           INT,                  '+
                     '@cLangCode       NVARCHAR( 3),         '+
                     '@nStep           INT,                  '+
                     '@nInputKey       INT,                  '+
                     '@cFacility       NVARCHAR( 5),         '+
                     '@cType           NVARCHAR( 10),        '+
                     '@cStorerkey      NVARCHAR( 15),        '+
                     '@cPUOM           NVARCHAR( 1),         '+
                     '@cInquiry_LOC    NVARCHAR( 10),        '+
                     '@cInquiry_ID     NVARCHAR( 18),        '+
                     '@cInquiry_SKU    NVARCHAR( 20),        '+
                     '@cLOT            NVARCHAR( 10)  OUTPUT,'+
                     '@cLOC            NVARCHAR( 10)  OUTPUT,'+
                     '@cID             NVARCHAR( 18)  OUTPUT,'+
                     '@cSKU            NVARCHAR( 20)  OUTPUT,'+
                     '@cSKUDescr       NVARCHAR( 60)  OUTPUT,'+
                     '@nTotalRec       INT            OUTPUT,'+
                     '@nMQTY_TTL       INT            OUTPUT,'+
                     '@nMQTY_PMV       INT            OUTPUT,'+
                     '@nMQTY_Alloc     INT            OUTPUT,'+
                     '@nMQTY_Pick      INT            OUTPUT,'+
                     '@nMQTY_RPL       INT            OUTPUT,'+
                     '@nMQTY_Avail     INT            OUTPUT,'+
                     '@nPQTY_TTL       INT            OUTPUT,'+
                     '@nPQTY_PMV       INT            OUTPUT,'+
                     '@nPQTY_Alloc     INT            OUTPUT,'+
                     '@nPQTY_Pick      INT            OUTPUT,'+
                     '@nPQTY_RPL       INT            OUTPUT,'+
                     '@nPQTY_Avail     INT            OUTPUT,'+
                     '@cPUOM_Desc      NVARCHAR( 5)   OUTPUT,'+
                     '@cMUOM_Desc      NVARCHAR( 5)   OUTPUT,'+
                     '@cLottableCode   NVARCHAR( 30)  OUTPUT,'+
                     '@cLottable01     NVARCHAR( 18)  OUTPUT,'+
                     '@cLottable02     NVARCHAR( 18)  OUTPUT,'+
                     '@cLottable03     NVARCHAR( 18)  OUTPUT,'+
                     '@dLottable04     DATETIME       OUTPUT,'+
                     '@dLottable05     DATETIME       OUTPUT,'+
                     '@cLottable06     NVARCHAR( 30)  OUTPUT,'+
                     '@cLottable07     NVARCHAR( 30)  OUTPUT,'+
                     '@cLottable08     NVARCHAR( 30)  OUTPUT,'+
                     '@cLottable09     NVARCHAR( 30)  OUTPUT,'+
                     '@cLottable10     NVARCHAR( 30)  OUTPUT,'+
                     '@cLottable11     NVARCHAR( 30)  OUTPUT,'+
                     '@cLottable12     NVARCHAR( 30)  OUTPUT,'+
                     '@dLottable13     DATETIME       OUTPUT,'+
                     '@dLottable14     DATETIME       OUTPUT,'+
                     '@dLottable15     DATETIME       OUTPUT,'+
                     '@cHasLottable    NVARCHAR( 1)   OUTPUT,'+
                     '@cUserDefine01   NVARCHAR( 60)  OUTPUT,'+
                     '@cUserDefine02   NVARCHAR( 60)  OUTPUT,'+
                     '@cUserDefine03   NVARCHAR( 60)  OUTPUT,'+
                     '@cUserDefine04   NVARCHAR( 60)  OUTPUT,'+
                     '@cUserDefine05   NVARCHAR( 60)  OUTPUT,'+
                     '@cSKUConfig      NVARCHAR( 60)  OUTPUT,'+
                     '@nErrNo          INT            OUTPUT,'+
                     '@cErrMsg         NVARCHAR( 20)  OUTPUT '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cType, @cStorerkey, @cPUOM,
                     @cInquiry_LOC, @cInquiry_ID, @cInquiry_SKU,
                     @cLOT           OUTPUT, @cLOC           OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT,
                     @cSKUDescr      OUTPUT, @nTotalRec      OUTPUT,
                     @nMQty_TTL      OUTPUT, @nMQTY_PMV      OUTPUT, @nMQTY_Alloc    OUTPUT,
                     @nMQty_Pick     OUTPUT, @nMQty_RPL      OUTPUT, @nMQTY_Avail    OUTPUT,
                     @nPQty_TTL      OUTPUT, @nPQTY_PMV      OUTPUT, @nPQTY_Alloc    OUTPUT,
                     @nPQty_Pick     OUTPUT, @nPQty_RPL      OUTPUT, @nPQTY_Avail    OUTPUT,
                     @cPUOM_Desc     OUTPUT, @cMUOM_Desc     OUTPUT, @cLottableCode  OUTPUT,
                     @cLottable01    OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT,
                     @dLottable04    OUTPUT, @dLottable05    OUTPUT, @cLottable06    OUTPUT,
                     @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT,
                     @cLottable10    OUTPUT, @cLottable11    OUTPUT, @cLottable12    OUTPUT,
                     @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT,
                     @cHasLottable   OUTPUT,@cUserDefine01 OUTPUT, @cUserDefine02  OUTPUT, @cUserDefine03  OUTPUT, @cUserDefine04  OUTPUT, @cUserDefine05  OUTPUT, @cSKUConfig OUTPUT,
                     @nErrNo         OUTPUT, @cErrMsg        OUTPUT
               END
               ELSE
               BEGIN
                  EXECUTE [RDT].[rdt_Inquiry_V7]
                  @nMobile,
                  @nFunc,
                  @cLangCode,
                  @nStep,
                  @nInputKey,
                  @cFacility,
                  @cType,
                  @cStorerkey,
                  @cPUOM,
                  @cInquiry_LOC,
                  @cInquiry_ID,
                  @cInquiry_SKU,
                  @cLOT              OUTPUT,
                  @cLOC              OUTPUT,
                  @cID               OUTPUT,
                  @cSKU              OUTPUT,
                  @cSKUDescr         OUTPUT,
                  @nTotalRec         OUTPUT,
                  @nMQTY_TTL         OUTPUT,
                  @nMQTY_PMV         OUTPUT,
                  @nMQTY_Alloc       OUTPUT,
                  @nMQTY_Pick        OUTPUT,
                  @nMQTY_RPL         OUTPUT,
                  @nMQTY_Avail       OUTPUT,
                  @nPQTY_TTL         OUTPUT,
                  @nPQTY_PMV         OUTPUT,
                  @nPQTY_Alloc       OUTPUT,
                  @nPQTY_Pick        OUTPUT,
                  @nPQTY_RPL         OUTPUT,
                  @nPQTY_Avail       OUTPUT,
                  @cPUOM_Desc        OUTPUT,
                  @cMUOM_Desc        OUTPUT,
                  @cLottableCode     OUTPUT,
                  @cLottable01       OUTPUT,
                  @cLottable02       OUTPUT,
                  @cLottable03       OUTPUT,
                  @dLottable04       OUTPUT,
                  @dLottable05       OUTPUT,
                  @cLottable06       OUTPUT,
                  @cLottable07       OUTPUT,
                  @cLottable08       OUTPUT,
                  @cLottable09       OUTPUT,
                  @cLottable10       OUTPUT,
                  @cLottable11       OUTPUT,
                  @cLottable12       OUTPUT,
                  @dLottable13       OUTPUT,
                  @dLottable14       OUTPUT,
                  @dLottable15       OUTPUT,
                  @cHasLottable      OUTPUT,
                  @cUserDefine01     OUTPUT,
                  @cUserDefine02     OUTPUT,
                  @cUserDefine03     OUTPUT,
                  @cUserDefine04     OUTPUT,
                  @cUserDefine05     OUTPUT,
                  @cSKUConfig        OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT
               END

               IF @nErrNo <> 0
               BEGIN
                  IF @nTotalRec <> -1  -- -1 indicates no more record
                  BEGIN
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Step_1_Fail
                  END
                  ELSE
                  BEGIN
                     SET @nTotalRec = @nCurrentRec
                  END
               END
               ELSE
                  SET @nCurrentRec += 1

               -- Prep next screen var
               --SET @nCurrentRec = CASE WHEN @nTotalRec = @nCurrentRec THEN @nCurrentRec ELSE @nCurrentRec + 1 END
               SET @cOutField01 = CAST( @nCurrentRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
               SET @cOutField02 = @cSKU
               SET @cOutField03 = SUBSTRING( @cSKUDescr, 1, 20)
               SET @cOutField04 = SUBSTRING( @cSKUDescr, 21, 20)
               SET @cOutField05 = @cLOC
               SET @cOutField06 = @cID
               SET @cOutField07 = CASE WHEN @cPUOM_Desc <> ''
                                 THEN SPACE( 9) + LEFT( @cPUOM_Desc + REPLICATE(' ', 5), 5) + ' ' + @cMUOM_Desc
                                 ELSE SPACE( 9) + @cMUOM_Desc END

               DELETE FROM @tList
               INSERT INTO @tList ( DESCR, SHORT)
               SELECT Description, Short
               FROM CODELKUP WITH (NOLOCK)
               WHERE Code2 = '628' AND StorerKey = @cStorerKey AND LISTNAME = '628QtyList'
               ORDER BY code

               WHILE (1=1)
               BEGIN 
                  SELECT TOP 1
                     @cDesc = DESCR,
                     @cShort = SHORT,
                     @nLoopIndex = id
                  FROM @tList
                  WHERE id > @nLoopIndex
                  ORDER BY id
                  SET @nRowCount = @@ROWCOUNT

                  IF @nRowCount = 0 OR @nLoopIndex > 6
                     BREAK
                  
                  SET @cOutput = ''

                  IF @cShort = 'QTYALC'
                     SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                    THEN LEFT( CAST( LEFT(@nPQTY_Alloc, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Alloc, 5) AS NVARCHAR( 5))
                                    ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Alloc, 5)   AS NVARCHAR( 5)) END
                  ELSE IF @cShort = 'QTYPCK'
                     SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                    THEN LEFT( CAST( LEFT(@nPQTY_Pick, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Pick, 5) AS NVARCHAR( 5))
                                    ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Pick, 5)   AS NVARCHAR( 5)) END
                  ELSE IF @cShort = 'QTYRPL'
                     SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                    THEN LEFT( CAST( LEFT(@nPQTY_RPL, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_RPL, 5) AS NVARCHAR( 5))
                                    ELSE SPACE( 6) + CAST( LEFT(@nMQTY_RPL, 5)   AS NVARCHAR( 5)) END
                  ELSE IF @cShort = 'QTYPMV'
                     SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                    THEN LEFT( CAST( LEFT(@nPQTY_PMV, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_PMV, 5) AS NVARCHAR( 5))
                                    ELSE SPACE( 6) + CAST( LEFT(@nMQTY_PMV, 5)   AS NVARCHAR( 5)) END
                  ELSE IF @cShort = 'QTYAVL'
                     SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                    THEN LEFT( CAST( LEFT(@nPQTY_Avail, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Avail, 5) AS NVARCHAR( 5))
                                    ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Avail, 5)   AS NVARCHAR( 5)) END
                  ELSE IF @cShort = 'QTYPHY'
                     SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                    THEN LEFT( @cUserDefine01 + SPACE( 6), 6) + CAST( LEFT(@cUserDefine02, 5) AS NVARCHAR( 5))
                                    ELSE SPACE( 6) + CAST( LEFT(@cUserDefine02, 5)   AS NVARCHAR( 5)) END
                  ELSE IF @cShort = 'QTYTTL'
                     SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                    THEN LEFT( CAST( LEFT(@nPQTY_TTL, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_TTL, 5) AS NVARCHAR( 5))
                                    ELSE SPACE( 6) + CAST( LEFT(@nMQTY_TTL, 5)   AS NVARCHAR( 5)) END
                  
                  IF @nLoopIndex = 1
                     SET @cOutField08 = @cOutput
                  ELSE IF @nLoopIndex = 2
                     SET @cOutField09 = @cOutput
                  ELSE IF @nLoopIndex = 3
                     SET @cOutField10 = @cOutput
                  ELSE IF @nLoopIndex = 4
                     SET @cOutField11 = @cOutput
                  ELSE IF @nLoopIndex = 5
                     SET @cOutField12 = @cOutput
                  ELSE IF @nLoopIndex = 6
                     SET @cOutField13 = @cOutput
               END

               SET @cUDF01 = @nTotalRec
               SET @CUDF02 = @nCurrentRec
               SET @cUDF03 = @cSKU
               SET @CUDF04 = @cLOC
               SET @CUDF05 = @cID
               SET @cUDF06 = @cLOT
               SET @cUDF07 = @cSKUDescr
               SET @CUDF08 = @cInquiry_ID
               SET @CUDF09 = @cInquiry_SKU
               SET @CUDF10 = @cInquiry_LOC
               SET @CUDF11 = @cLottableCode
               SET @CUDF12 = @chasLottable

            END
         END
         IF @nInputKey = 0
         BEGIN
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''

            SET @nAfterScn = 6677
            SET @nAfterStep = 99
         END
      END
      IF @nMOBRECStep = 99 AND @nMOBRECScn = 6682
      BEGIN
         IF @nInputKey = 1      -- Yes or Send
         BEGIN
            SET @nOption = CAST( @cInField01 AS INT)
            SELECT @cTempValue = CASE WHEN @nOption = 1 THEN @cOutField02
                                 WHEN @nOption = 2 THEN @cOutField03
                                 WHEN @nOption = 3 THEN @cOutField04
                                 WHEN @nOption = 4 THEN @cOutField05
                                 WHEN @nOption = 5 THEN @cOutField06
                                 WHEN @nOption = 6 THEN @cOutField07
                                 WHEN @nOption = 7 THEN @cOutField08
                                 WHEN @nOption = 8 THEN @cOutField09
                                 WHEN @nOption = 9 THEN @cOutField10
                                 WHEN @nOption = 10 THEN @cOutField11
                                 WHEN @nOption = 11 THEN @cOutField12
                                 ELSE '' END
            SELECT @cInquiry_LocType = STUFF(@cTempValue, 1, CHARINDEX( '-', @cTempValue)+1, '')
            
            UPDATE RDT.RDTMOBREC
            SET c_string1 = @cInquiry_LocType
            WHERE Mobile = @nMobile

            IF @cCustomInquiryRule_SP <> '' AND
               EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cCustomInquiryRule_SP AND type = 'P')
            BEGIN
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cCustomInquiryRule_SP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cType, @cStorerkey, @cPUOM, ' +
               ' @cInquiry_LOC, @cInquiry_ID, @cInquiry_SKU, ' +
               ' @cLOT           OUTPUT, @cLOC           OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT, ' +
               ' @cSKUDescr      OUTPUT, @nTotalRec      OUTPUT, ' +
               ' @nMQty_TTL      OUTPUT, @nMQTY_PMV      OUTPUT, @nMQTY_Alloc    OUTPUT, ' +
               ' @nMQty_Pick     OUTPUT, @nMQty_RPL      OUTPUT, @nMQTY_Avail    OUTPUT, ' +
               ' @nPQty_TTL      OUTPUT, @nPQTY_PMV      OUTPUT, @nPQTY_Alloc    OUTPUT, ' +
               ' @nPQty_Pick     OUTPUT, @nPQty_RPL      OUTPUT, @nPQTY_Avail    OUTPUT, ' +
               ' @cPUOM_Desc     OUTPUT, @cMUOM_Desc     OUTPUT, @cLottableCode  OUTPUT, ' +
               ' @cLottable01    OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT, ' +
               ' @dLottable04    OUTPUT, @dLottable05    OUTPUT, @cLottable06    OUTPUT, ' +
               ' @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT, ' +
               ' @cLottable10    OUTPUT, @cLottable11    OUTPUT, @cLottable12    OUTPUT, ' +
               ' @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT, ' +
               ' @cHasLottable   OUTPUT, @cUserDefine01 OUTPUT, @cUserDefine02  OUTPUT, @cUserDefine03  OUTPUT, @cUserDefine04  OUTPUT, @cUserDefine05  OUTPUT, @cSKUConfig OUTPUT, ' +
               ' @nErrNo         OUTPUT, @cErrMsg        OUTPUT '

               SET @cSQLParam =
                  '@nMobile         INT,                  '+
                  '@nFunc           INT,                  '+
                  '@cLangCode       NVARCHAR( 3),         '+
                  '@nStep           INT,                  '+
                  '@nInputKey       INT,                  '+
                  '@cFacility       NVARCHAR( 5),         '+
                  '@cType           NVARCHAR( 10),        '+
                  '@cStorerkey      NVARCHAR( 15),        '+
                  '@cPUOM           NVARCHAR( 1),         '+
                  '@cInquiry_LOC    NVARCHAR( 10),        '+
                  '@cInquiry_ID     NVARCHAR( 18),        '+
                  '@cInquiry_SKU    NVARCHAR( 20),        '+
                  '@cLOT            NVARCHAR( 10)  OUTPUT,'+
                  '@cLOC            NVARCHAR( 10)  OUTPUT,'+
                  '@cID             NVARCHAR( 18)  OUTPUT,'+
                  '@cSKU            NVARCHAR( 20)  OUTPUT,'+
                  '@cSKUDescr       NVARCHAR( 60)  OUTPUT,'+
                  '@nTotalRec       INT            OUTPUT,'+
                  '@nMQTY_TTL       INT            OUTPUT,'+
                  '@nMQTY_PMV       INT            OUTPUT,'+
                  '@nMQTY_Alloc     INT            OUTPUT,'+
                  '@nMQTY_Pick      INT            OUTPUT,'+
                  '@nMQTY_RPL       INT            OUTPUT,'+
                  '@nMQTY_Avail     INT            OUTPUT,'+
                  '@nPQTY_TTL       INT            OUTPUT,'+
                  '@nPQTY_PMV       INT            OUTPUT,'+
                  '@nPQTY_Alloc     INT            OUTPUT,'+
                  '@nPQTY_Pick      INT            OUTPUT,'+
                  '@nPQTY_RPL       INT            OUTPUT,'+
                  '@nPQTY_Avail     INT            OUTPUT,'+
                  '@cPUOM_Desc      NVARCHAR( 5)   OUTPUT,'+
                  '@cMUOM_Desc      NVARCHAR( 5)   OUTPUT,'+
                  '@cLottableCode   NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable01     NVARCHAR( 18)  OUTPUT,'+
                  '@cLottable02     NVARCHAR( 18)  OUTPUT,'+
                  '@cLottable03     NVARCHAR( 18)  OUTPUT,'+
                  '@dLottable04     DATETIME       OUTPUT,'+
                  '@dLottable05     DATETIME       OUTPUT,'+
                  '@cLottable06     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable07     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable08     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable09     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable10     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable11     NVARCHAR( 30)  OUTPUT,'+
                  '@cLottable12     NVARCHAR( 30)  OUTPUT,'+
                  '@dLottable13     DATETIME       OUTPUT,'+
                  '@dLottable14     DATETIME       OUTPUT,'+
                  '@dLottable15     DATETIME       OUTPUT,'+
                  '@cHasLottable    NVARCHAR( 1)   OUTPUT,'+
                  '@cUserDefine01   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine02   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine03   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine04   NVARCHAR( 60)  OUTPUT,'+
                  '@cUserDefine05   NVARCHAR( 60)  OUTPUT,'+
                  '@cSKUConfig      NVARCHAR( 60)  OUTPUT,'+
                  '@nErrNo          INT            OUTPUT,'+
                  '@cErrMsg         NVARCHAR( 20)  OUTPUT '

               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cType, @cStorerkey, @cPUOM,
                  @cInquiry_LOC, @cInquiry_ID, @cInquiry_SKU,
                  @cLOT           OUTPUT, @cLOC           OUTPUT, @cID            OUTPUT, @cSKU           OUTPUT,
                  @cSKUDescr      OUTPUT, @nTotalRec      OUTPUT,
                  @nMQty_TTL      OUTPUT, @nMQTY_PMV      OUTPUT, @nMQTY_Alloc    OUTPUT,
                  @nMQty_Pick     OUTPUT, @nMQty_RPL      OUTPUT, @nMQTY_Avail    OUTPUT,
                  @nPQty_TTL      OUTPUT, @nPQTY_PMV      OUTPUT, @nPQTY_Alloc    OUTPUT,
                  @nPQty_Pick     OUTPUT, @nPQty_RPL      OUTPUT, @nPQTY_Avail    OUTPUT,
                  @cPUOM_Desc     OUTPUT, @cMUOM_Desc     OUTPUT, @cLottableCode  OUTPUT,
                  @cLottable01    OUTPUT, @cLottable02    OUTPUT, @cLottable03    OUTPUT,
                  @dLottable04    OUTPUT, @dLottable05    OUTPUT, @cLottable06    OUTPUT,
                  @cLottable07    OUTPUT, @cLottable08    OUTPUT, @cLottable09    OUTPUT,
                  @cLottable10    OUTPUT, @cLottable11    OUTPUT, @cLottable12    OUTPUT,
                  @dLottable13    OUTPUT, @dLottable14    OUTPUT, @dLottable15    OUTPUT,
                  @cHasLottable   OUTPUT,@cUserDefine01 OUTPUT, @cUserDefine02  OUTPUT, @cUserDefine03  OUTPUT, @cUserDefine04  OUTPUT, @cUserDefine05  OUTPUT, @cSKUConfig OUTPUT,
                  @nErrNo         OUTPUT, @cErrMsg        OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Step_1_Fail
               END
            END
            ELSE
            BEGIN
               EXECUTE [RDT].[rdt_Inquiry_V7]
                  @nMobile,
                  @nFunc,
                  @cLangCode,
                  @nStep,
                  @nInputKey,
                  @cFacility,
                  @cType,
                  @cStorerkey,
                  @cPUOM,
                  @cInquiry_LOC,
                  @cInquiry_ID,
                  @cInquiry_SKU,
                  @cLOT              OUTPUT,
                  @cLOC              OUTPUT,
                  @cID               OUTPUT,
                  @cSKU              OUTPUT,
                  @cSKUDescr         OUTPUT,
                  @nTotalRec         OUTPUT,
                  @nMQTY_TTL         OUTPUT,
                  @nMQTY_PMV         OUTPUT,
                  @nMQTY_Alloc       OUTPUT,
                  @nMQTY_Pick        OUTPUT,
                  @nMQTY_RPL         OUTPUT,
                  @nMQTY_Avail       OUTPUT,
                  @nPQTY_TTL         OUTPUT,
                  @nPQTY_PMV         OUTPUT,
                  @nPQTY_Alloc       OUTPUT,
                  @nPQTY_Pick        OUTPUT,
                  @nPQTY_RPL         OUTPUT,
                  @nPQTY_Avail       OUTPUT,
                  @cPUOM_Desc        OUTPUT,
                  @cMUOM_Desc        OUTPUT,
                  @cLottableCode     OUTPUT,
                  @cLottable01       OUTPUT,
                  @cLottable02       OUTPUT,
                  @cLottable03       OUTPUT,
                  @dLottable04       OUTPUT,
                  @dLottable05       OUTPUT,
                  @cLottable06       OUTPUT,
                  @cLottable07       OUTPUT,
                  @cLottable08       OUTPUT,
                  @cLottable09       OUTPUT,
                  @cLottable10       OUTPUT,
                  @cLottable11       OUTPUT,
                  @cLottable12       OUTPUT,
                  @dLottable13       OUTPUT,
                  @dLottable14       OUTPUT,
                  @dLottable15       OUTPUT,
                  @cHasLottable      OUTPUT,
                  @cUserDefine01     OUTPUT,
                  @cUserDefine02     OUTPUT,
                  @cUserDefine03     OUTPUT,
                  @cUserDefine04     OUTPUT,
                  @cUserDefine05     OUTPUT,
                  @cSKUConfig        OUTPUT,
                  @nErrNo            OUTPUT,
                  @cErrMsg           OUTPUT

               IF @nErrNo <> 0
               BEGIN
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Step_1_Fail
               END
            END

            -- Prep next screen var
            SET @nCurrentRec = 1
            SET @cOutField01 = CAST( @nCurrentRec AS NVARCHAR( 5)) + '/' + CAST( @nTotalRec AS NVARCHAR( 5))
            SET @cOutField02 = @cSKU
            SET @cOutField03 = SUBSTRING( @cSKUDescr, 1, 20)
            SET @cOutField04 = SUBSTRING( @cSKUDescr, 21, 20)
            SET @cOutField05 = @cLOC
            SET @cOutField06 = @cID
            SET @cOutField07 = CASE WHEN @cPUOM_Desc <> ''
                                 THEN SPACE( 9) + LEFT( @cPUOM_Desc + REPLICATE(' ', 5), 5) + ' ' + @cMUOM_Desc
                                 ELSE SPACE( 9) + @cMUOM_Desc END

            DELETE FROM @tList
            INSERT INTO @tList ( DESCR, SHORT)
            SELECT Description, Short
            FROM CODELKUP WITH (NOLOCK)
            WHERE Code2 = '628' AND StorerKey = @cStorerKey AND LISTNAME = '628QtyList'
            ORDER BY code

            WHILE (1=1)
            BEGIN 
               SELECT TOP 1
                  @cDesc = DESCR,
                  @cShort = SHORT,
                  @nLoopIndex = id
               FROM @tList
               WHERE id > @nLoopIndex
               ORDER BY id
               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0 OR @nLoopIndex > 6
                  BREAK
               
               SET @cOutput = ''

               IF @cShort = 'QTYALC'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_Alloc, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Alloc, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Alloc, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYPCK'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_Pick, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Pick, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Pick, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYRPL'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_RPL, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_RPL, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_RPL, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYPMV'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_PMV, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_PMV, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_PMV, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYAVL'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_Avail, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_Avail, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_Avail, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYPHY'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9) + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( @cUserDefine01  + SPACE( 6), 6) + CAST( LEFT(@cUserDefine02, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@cUserDefine02, 5)   AS NVARCHAR( 5)) END
               ELSE IF @cShort = 'QTYTTL'
                  SET @COUTPUT = LEFT( UPPER(@cDesc)+ REPLICATE(' ', 6), 9)  + CASE WHEN @cPUOM_Desc <> ''
                                 THEN LEFT( CAST( LEFT(@nPQTY_TTL, 5) AS NVARCHAR( 5)) + REPLICATE(' ', 6), 6) + CAST( LEFT(@nMQTY_TTL, 5) AS NVARCHAR( 5))
                                 ELSE SPACE( 6) + CAST( LEFT(@nMQTY_TTL, 5)   AS NVARCHAR( 5)) END
               
               IF @nLoopIndex = 1
                  SET @cOutField08 = @cOutput
               ELSE IF @nLoopIndex = 2
                  SET @cOutField09 = @cOutput
               ELSE IF @nLoopIndex = 3
                  SET @cOutField10 = @cOutput
               ELSE IF @nLoopIndex = 4
                  SET @cOutField11 = @cOutput
               ELSE IF @nLoopIndex = 5
                  SET @cOutField12 = @cOutput
               ELSE IF @nLoopIndex = 6
                  SET @cOutField13 = @cOutput
            END

            SET @cUDF01 = @nTotalRec
            SET @CUDF02 = @nCurrentRec
            SET @cUDF03 = @cSKU
            SET @CUDF04 = @cLOC
            SET @CUDF05 = @cID
            SET @cUDF06 = @cLOT
            SET @cUDF07 = @cSKUDescr
            SET @CUDF08 = @cInquiry_ID
            SET @CUDF09 = @cInquiry_SKU
            SET @CUDF10 = @cInquiry_LOC
            SET @CUDF11 = @cLottableCode
            SET @CUDF12 = @chasLottable

            -- Go to next screen
            SET @nAfterScn = 6679
            SET @nAfterStep = 99

            GOTO Quit
         END
         IF @nInputKey = 0
         BEGIN
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''

            SET @nAfterScn = 6677
            SET @nAfterStep = 99
            GOTO QUIT
         END
      END


      IF @nMOBRECStep = 2
      BEGIN
         IF @nInputKey = 0
         BEGIN
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''

            SET @nAfterScn = 6677
            SET @nAfterStep = 99
         END
      END
      IF @nMOBRECStep = 4
      BEGIN
         IF @nInputKey = 0
         BEGIN
            SET @cOutField01 = ''
            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''

            SET @nAfterScn = 6679
            SET @nAfterStep = 99
         END
      END
   END


Quit:


END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_628ExtScn01 to nSQL
GO
