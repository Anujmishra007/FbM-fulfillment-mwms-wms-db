

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_898ExtScn03                                           */  
/*                                                                            */  
/*                                                                            */  
/* Date        Rev     Author   Purposes                                      */  
/* 2025-10-28  1.0.0   Dennis   FCR-8472 Created                              */  
/******************************************************************************/  
  
CREATE OR ALTER PROC  [RDT].[rdt_898ExtScn03] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nScn         INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15), 

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
   @nAction          INT, 
   @nAfterScn        INT            OUTPUT, 
   @nAfterStep       INT            OUTPUT, 
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

   -- Misc variable
   DECLARE
      @b_success                       INT,
      @cDisAllowDuplicateIdsOnRFRcpt   NVARCHAR(1),
      @cAllow_OverReceipt              NVARCHAR(1),
      @cOption                         NVARCHAR(1),
      @cUOM                            NVARCHAR(10),
      @cPOKeyValue                     NVARCHAR(10),
      @cReceiveAllowAddNewUCC          NVARCHAR(10),
      @cUCCWithDynamicCaseCnt          NVARCHAR(10),
      @cTempAddNewUCC                  NVARCHAR(10),
      @cUCC                            NVARCHAR(20),
      @cTempUCC                        NVARCHAR(20),
      @cListName                       NVARCHAR(20),
      @cLottableCode                   NVARCHAR( 30),
      @cShort                          NVARCHAR(10),
      @cStoredProd                     NVARCHAR(250),
      @nCount                          INT,
      @cTempLotLabel                   NVARCHAR(20),
      @cLottableLabel                  NVARCHAR(20),
      @dTempLottable04                 DATETIME,
      @dTempLottable09                 DATETIME,
      @nSKUCnt                         INT,
      @cSQL                            NVARCHAR(1000),
      @cSQLParam                       NVARCHAR(1000),
      @cParam1                         NVARCHAR(20),                                       
      @cParam2                         NVARCHAR(20),
      @cParam3                         NVARCHAR(20),
      @cParam4                         NVARCHAR(20),
      @cParam5                         NVARCHAR(20),
      @nMOBRECStep                        INT,
      @nMOBRECScn                         INT,
      @cDocType                        NVARCHAR(1)

   DECLARE
      @cPaperPrinter  NVARCHAR( 10),  --(cc01)
      @cLabelPrinter  NVARCHAR( 10),  --(cc01)
      @cReceiptKey          NVARCHAR(10),
      @cReceiptLineNumber   NVARCHAR( 5),
      @cPOKey               NVARCHAR(10),
      @cPOKeyDefaultValue   NVARCHAR(10),
      @cLOC                 NVARCHAR(10),
      @cTOID                NVARCHAR(18),
      @cSKU                 NVARCHAR(20),
      @cTotalCarton         NVARCHAR(4), -- (ChewKP02)
      @cCartonCnt           NVARCHAR(4), -- (ChewKP02)
      @cDesc                NVARCHAR(60),
      @nQTY                 INT,
      @cPackKey             NVARCHAR(10),
      @cPQIndicator         NVARCHAR(10),
      @cPPK                 NVARCHAR(30),
      @nCaseCntQty          INT,
      @nCnt                 INT,
      @nFromScn             INT, --(yeekung01)
      @cExtendedUpdateSP    NVARCHAR(20),
      @cUCCExtValidate      NVARCHAR(20),
      @cClosePallet         NVARCHAR(1),
      @cSkipEstUCCOnID      NVARCHAR( 1),
      @cSkipLottable01      NVARCHAR( 1),
      @cSkipLottable02      NVARCHAR( 1),
      @cSkipLottable03      NVARCHAR( 1),
      @cSkipLottable04      NVARCHAR( 1),
      @cDispStyleColorSize  NVARCHAR( 1),
      @cClosePalletCountUCC NVARCHAR( 1),
      @cExtendedValidateSP  NVARCHAR(20),
      @cDisableQTYField     NVARCHAR( 1),
      @cExtendedInfoSP      NVARCHAR( 20),
      @cExtendedInfo        NVARCHAR( 20),
      @cVerifySKU           NVARCHAR( 1),
      @cMultiUCC            NVARCHAR(  1),
      @nMorePage            INT,
      @cDecodeSP            NVARCHAR( 20), --(yeekung01)
      @cDecodeQty           NVARCHAR(1) ,--(yeekung01)
      @cExtendedScreenSP    NVARCHAR(20) ,--(wsa099)

      @cTempLottable01   NVARCHAR(18), --input field lottable01 from lottable screen
      @cTempLottable02   NVARCHAR(18), --input field lottable02 from lottable screen
      @cTempLottable03   NVARCHAR(18), --input field lottable03 from lottable screen
      @cTempLottable04   NVARCHAR(16), --input field lottable04 from lottable screen

      @cTempLotLabel01   NVARCHAR(20),
      @cTempLotLabel02   NVARCHAR(20),
      @cTempLotLabel03   NVARCHAR(20),
      @cTempLotLabel04   NVARCHAR(20),

      @cCheckPOUCC        NVARCHAR(1), -- (Vicky01)
      @cUCCWithMultiSKU   NVARCHAR(1),

      @cUserName          NVARCHAR(18), -- (Vicky06)
      @cUCCLabel          NVARCHAR(20), --(cc01)

      @cRetUCCCreate     NVARCHAR(1),    --(WSA099))
      @cRetUCCNoMixSKU   NVARCHAR(1)     --(WSA099)

   -- Screen constant  
   DECLARE  
      @nStep_1             INT,  @nStep_1_Scn              INT,  
      @nStep_2             INT,  @nStep_2_Scn              INT,  
      @nStep_3             INT,  @nStep_3_Scn              INT,  
      @nStep_4             INT,  @nStep_4_Scn              INT,  
      @nStep_5             INT,  @nStep_5_Scn              INT,  
      @nStep_6             INT,  @nStep_6_Scn              INT, 
      @nStep_7             INT,  @nStep_7_Scn              INT,   
      @nStep_8             INT,  @nStep_8_Scn              INT,   
      @nStep_9             INT,  @nStep_9_Scn              INT,   
      @nStep_10            INT,  @nStep_10_Scn             INT,   
      @nStep_11            INT,  @nStep_11_Scn             INT,   
      @nStep_12            INT,  @nStep_12_Scn             INT,   
      @nStep_13            INT,  @nStep_13_Scn             INT,   
      @nStep_99            INT,  @nStep_99_Scn             INT

   SELECT  
      @nStep_1                = 1,      @nStep_1_Scn             = 1300,  
      @nStep_2                = 2,      @nStep_2_Scn             = 1301, 
      @nStep_3                = 3,      @nStep_3_Scn             = 1302, 
      @nStep_4                = 4,      @nStep_4_Scn             = 1303, 
      @nStep_5                = 5,      @nStep_5_Scn             = 1304, 
      @nStep_6                = 6,      @nStep_6_Scn             = 1305, 
      @nStep_7                = 7,      @nStep_7_Scn             = 1306, 
      @nStep_8                = 8,      @nStep_8_Scn             = 1307, 
      @nStep_9                = 9,      @nStep_9_Scn             = 1308, 
      @nStep_10               = 10,     @nStep_10_Scn            = 1309, 
      @nStep_11               = 11,     @nStep_11_Scn            = 1310, 
      @nStep_12               = 12,     @nStep_12_Scn            = 1311, 
      @nStep_13               = 13,     @nStep_13_Scn            = 3950, 
      @nStep_99               = 99
   
   SELECT
      @cReceiptKey   = V_ReceiptKey,
      @cPOKey        = V_POKey,
      @cLOC          = V_LOC,
      @cTOID         = V_ID,
      @cSKU          = V_SKU,
      @cUCC          = V_UCC,
      @cUOM          = V_UOM,
      @cDesc         = V_SkuDescr,
      @nMOBRECStep      = Step,
      @nMOBRECScn       = Scn,

      /*CS01 End*/
      @cTotalCarton     = v_String2,
      @cCartonCnt       = v_String3,
      @cPackKey         = V_String6,
      @cPQIndicator     = ISNULL(RTRIM(V_String8),'0'),
      @cPPK             = ISNULL(RTRIM(V_String9),'0'),
      @cTempLottable01  = V_String12,
      @cTempLottable02  = V_String13,
      @cTempLottable03  = V_String14,
      @cTempLottable04  = V_String15,
      @cUCCWithMultiSKU = V_String16,
      @cReceiveAllowAddNewUCC = V_String17,
      @cCheckPOUCC            = V_String18, -- Vicky01
      @cExtendedUpdateSP      = V_String19,
      @cUCCExtValidate        = V_String20,
      @cClosePallet           = V_String21,
      @cSkipEstUCCOnID        = V_String22,
      @cSkipLottable01        = V_String23,
      @cSkipLottable02        = V_String24,
      @cSkipLottable03        = V_String25,
      @cSkipLottable04        = V_String26,
      @cDispStyleColorSize    = V_String27,
      @cClosePalletCountUCC   = V_String28,
      @cExtendedValidateSP    = V_String29,
      @cDisableQTYField       = V_String30,
      @cExtendedInfoSP        = V_String31,
      @cExtendedInfo          = V_String32,
      @cUCCLabel              = V_String33, --(cc01)
      @cMultiUCC              = V_String34,
      @cDecodeSP              = V_String35, --(yeekung01)
      @cDecodeQty             = V_String36, --(yeekung01)
      @cVerifySKU             = V_String37, --(yeekung01)
      @cExtendedScreenSP      = V_String38, 

      --@nQTY             = V_Integer1,
      @nCaseCntQty      = V_Integer2,
      @nCnt             = V_Integer3,
      @nFromScn         = V_Integer4
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   --(WSA099)
   SET @cRetUCCCreate = rdt.rdtGetConfig( @nFunc, 'RetUCCCreate', @cStorerKey)
   SET @cRetUCCNoMixSKU = rdt.rdtGetConfig( @nFunc, 'RetUCCNoMixSKU', @cStorerKey)

   IF @nFunc = 898
   BEGIN
      IF @nStep = 8 AND @nMOBRECStep = 6
      BEGIN
         SELECT @cOutField02 = ISNULL(Value,'') FROM @tExtScnData WHERE Variable = '@cUserDefine01'
         SET @cUDF01 = @cOutField02
         GOTO QUIT
      END
      IF (@nMOBRECStep = 8 AND @nStep = 9) OR (@nMOBRECStep = 9 AND @nStep = 8)
      BEGIN
         SELECT @cOutField01 = @cLottable01, @cOutField02 = @cLottable02 ,
         @cOutField03 = @cLottable03 , @cOutField04 = CONVERT(NVARCHAR(16),@dLottable04,120)

         SET @nAfterStep = 99
         SET @nAfterScn = 1304
         GOTO QUIT
      END
      IF @nMOBRECStep = 99 AND @nMOBRECScn = 1304
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cLottable01 = @cInField01
            SET @cLottable02 = @cInField02
            SET @cLottable03 = @cInField03
            SET @dLottable04 = CASE WHEN ISNULL(@cInField04,'') = '' THEN NULL ELSE rdt.rdtConvertToDate(@cInField04) END
            SET @cOutField06 = CASE WHEN @cLottable01 <> '' THEN @cLottable01 ELSE @cTempLottable01 END
            SET @cOutField07 = CASE WHEN @cLottable02 <> '' THEN @cLottable02 ELSE @cTempLottable02 END
            SET @cOutField08 = CASE WHEN @cLottable03 <> '' THEN @cLottable03 ELSE @cTempLottable03 END
            SET @cOutField09 = CASE WHEN @dLottable04 <> 0  THEN rdt.rdtFormatDate( @dLottable04) ELSE @cTempLottable04 END

            SET @cOutField01 = @cUCC
            SET @cOutField02 = @cSKU
            SET @cOutField03 = SUBSTRING( @cDesc,  1, 20)
            SET @cOutField04 = SUBSTRING( @cDesc, 21, 20)
            SET @cOutField05 = CASE WHEN IsNULL(@cPPK, '') = '' THEN '0' ELSE  @cPPK END +
                              '/' +
                              CASE WHEN IsNULL(@cPQIndicator, '') = '' THEN '0' ELSE @cPQIndicator END
            SET @cOutField10 = CASE WHEN @nQTY > 0 THEN CAST( @nQTY AS NVARCHAR( 5)) ELSE '' END --qty
            SET @cOutField11 = RTRIM(CAST( @cCartonCnt AS NVARCHAR( 4))) + CASE WHEN @cSkipEstUCCOnID = '1' THEN '' ELSE '/' + CAST( @cTotalCarton AS NVARCHAR( 4)) END -- (ChewKP02)

            SET @nAfterStep = 9
            SET @nAfterScn = 1308
         END
         IF @nInputKey = 0
         BEGIN
            --go to screen SKU
            SET @nAfterScn  = 1307
            SET @nAfterStep = 8

            SET @cSKU = ''
            SET @nQTY = 0

            --prepare next screen var
            SET @cOutField01 = @cUCC
            SET @cOutField02 = @cSku --sku
            SET @cOutField03 = RTRIM(CAST( @cCartonCnt AS NVARCHAR( 4))) + CASE WHEN @cSkipEstUCCOnID = '1' THEN '' ELSE '/' + CAST( @cTotalCarton AS NVARCHAR( 4)) END --(ChewKP02)
            SET @cOutField04 = ''
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

GRANT EXECUTE ON rdt.rdt_898ExtScn03 to nSQL
GO
