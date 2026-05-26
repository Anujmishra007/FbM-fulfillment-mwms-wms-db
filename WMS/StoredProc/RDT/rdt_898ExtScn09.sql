

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_898ExtScn09                                           */  
/*                                                                            */  
/* Customer: AMERICAN EAGLE                                                   */ 
/*                                                                            */  
/* Date        Rev     Author   Purposes                                      */  
/* 2026-05-22  1.0.0   Jackc    FCR-12891 Cond code scn                       */  
/******************************************************************************/  
  
CREATE OR ALTER PROC  [RDT].[rdt_898ExtScn09] (
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

   DECLARE @nDebugFlag     INT = 0

   -- Misc variable
   DECLARE
      @cUCC                NVARCHAR(20),
      @nMOBRECStep         INT,
      @nMOBRECScn          INT,

      --main sp parameters
      @cDesc               NVARCHAR(60),
      @cSKU                NVARCHAR(20),
      @nQTY                INT,
      @cTotalCarton        NVARCHAR( 4),
      @cCartonCnt          NVARCHAR( 4),
      @cMax                NVARCHAR(MAX),
      @cSkipEstUCCOnID     NVARCHAR(1),
      @cUCCWithMultiSKU    NVARCHAR(1),
      @cPQIndicator        NVARCHAR(10),
      @cPPK                NVARCHAR(30),
      @nNewUCCWithMultiSKURcv INT,

      --ExtScn variable
      @cConditionCode      NVARCHAR(10)

   -- Screen constant  
   /*
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
   */

   SELECT
      @nMOBRECStep               = Step,
      @nMOBRECScn                = Scn,
      @cSKU                      = V_SKU,
      @cDesc                     = V_SkuDescr,
      @cUCC                      = V_UCC,
      @cTotalCarton              = V_String2,
      @cCartonCnt                = v_String3,
      @cPQIndicator              = ISNULL(RTRIM(V_String8),'0'),
      @cPPK                      = ISNULL(RTRIM(V_String9),'0'),
      @cUCCWithMultiSKU          = V_String16,
      @cSkipEstUCCOnID           = V_String22,
      @cMax                      = V_Max,
      @nQTY                      = V_Integer1,
      @nNewUCCWithMultiSKURcv    = V_Integer5
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 898
   BEGIN
      IF @nMOBRECStep = 6 AND @nMOBRECScn = 1305 AND @nStep = 8 AND @nScn = 1307 -- UCC Scn to SKU Scn
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'UCC Scn to SKU Scn, Enter'

            SET @cOutField01 = SUBSTRING( @cMax, 1, 20)
            SET @cOutField02 = 'GOO'
            SET @cConditionCode = ''

            SET @nAfterScn = 6893
            SET @nAfterStep = 99

            GOTO Quit
         END
      END

      IF @nStep = 99
      BEGIN
         /********************************************************************************
         Screen = 6893
            UCC (Field01)
            COND CODE  (Field02, input)
         ********************************************************************************/
         IF @nScn = 6893
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cConditionCode = @cInField02

               IF ISNULL(@cConditionCode, '') = ''
               BEGIN
                  SET @nErrNo = 267401
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Condition code required
                  GOTO SCN_6893_Fail
               END

               IF NOT EXISTS( SELECT Code
                  FROM dbo.CodeLKUP WITH (NOLOCK)
                  WHERE ListName = 'ASNREASON'
                     AND Storerkey = @cStorerkey
                     AND Code = @cConditionCode)
               BEGIN
                  SET @nErrNo = 267402
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad ReasonCode
                  GOTO SCN_6893_Fail
               END

               BEGIN TRY
                  -- Only UPDATE C_StringXXX, because C_StringXXX is used for ExtScnSP
                  UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                  SET
                     C_String1 = ISNULL(@cConditionCode, '')
                  WHERE Mobile = @nMobile
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 267403
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Upd MOBREC Fail
                  GOTO SCN_6893_Fail
               END CATCH

               --prepare next screen var
               SET @cOutField01 = @cUCC
               SET @cOutField02 = '' --sku
               SET @cOutField03 = RTRIM(CAST( @cCartonCnt AS NVARCHAR( 4))) + CASE WHEN @cSkipEstUCCOnID = '1' THEN '' ELSE '/' + CAST( @cTotalCarton AS NVARCHAR( 4)) END --(ChewKP02)
               SET @cOutField04 = ''

               SET @nAfterStep = 8
               SET @nAfterScn = 1307
            END

            IF @nInputKey = 0
            BEGIN
               -- Received multi SKU UCC
               IF @cUCC <> '' AND @cUCC <> 'NOUCC' AND @cUCCWithMultiSKU = '1' AND @nNewUCCWithMultiSKURcv = 1
               BEGIN
                  --increase carton count by one if it is not loose qty
                  IF UPPER(@cUCC) <> 'NOUCC'
                     SET @cCartonCnt = Convert(char,Cast( @cCartonCnt as Int) + 1 )
               END

               --go back to UCC
               SET @cOutField01 = ''
               SET @cOutField02 = @cSku
               SET @cOutField02 = @cSKU
               SET @cOutField03 = SUBSTRING( @cDesc,1,20)
               SET @cOutField04 = SUBSTRING( @cDesc,21,40)
               SET @cOutField05 = CASE WHEN IsNULL(@cPPK, '') = '' THEN '0'  ELSE @cPPK END +
                                 '/' +
                                 CASE WHEN IsNULL(@cPQIndicator, '') = '' THEN '0' ELSE @cPQIndicator END
               SET @cOutField06 = @cOutField06
               SET @cOutField07 = @cOutField07
               SET @cOutField08 = @cOutField08
               SET @cOutField09 = @cOutField09
               SET @cOutField10 = CAST( @nQTY AS NVARCHAR( 5))
               SET @cOutField11 = RTRIM(CAST( @cCartonCnt AS NVARCHAR( 4))) + CASE WHEN @cSkipEstUCCOnID = '1' THEN '' ELSE '/' + CAST( @cTotalCarton AS NVARCHAR( 4)) END -- (ChewKP02)

               -- Go to previous screen
               SET @nAfterScn = 1305
               SET @nAfterStep = 6
            END

            SCN_6893_Quit:
               GOTO Quit

            SCN_6893_Fail:
               SET @cConditionCode = ''
               SET @cOutField02 = ''
               GOTO Quit
         END -- SCN 6893
      END --St99
   END

   Quit:
      IF @nDebugFlag = 1
         SELECT 'Exit 898ExtScn09', @nAfterScn, @nAfterStep, @nErrNo, @cErrMsg
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_898ExtScn09 to nSQL
GO
