SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************************************/
/* Store procedure: rdt_839ExtScn06                                            */
/* Copyright      : Maersk                                                     */
/* Customer       : PAGEIND                                                    */
/*                                                                             */
/*                                                                             */
/* Date       Rev    Author     Purposes                                       */
/* 2026-01-04 1.0.0  NickT      FCR-9040. Created                              */
/*******************************************************************************/
  
CREATE OR ALTER PROC  [RDT].[rdt_839ExtScn06] (
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
   @nAction          INT,
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

   DECLARE
      @nCurrentScn            INT,
      @nCurrentStep           INT,
      @nRowCount              INT,
      @cEntryDropID           NVARCHAR( 10),
      @cOption                NVARCHAR( 10),
      @cSuggUCC               NVARCHAR( 20),
      @cSuggLOC               NVARCHAR( 10),
      @cSuggSKU               NVARCHAR( 20),
      @cSKUDescr              NVARCHAR( 60),
      @cSuggLOT               NVARCHAR( 10),
      @cUCC                   NVARCHAR( 20),
      @cPickSlipNo            NVARCHAR( 10),
      @cPickZone              NVARCHAR( 10),
      @cDropID                NVARCHAR( 20),
      @cLottableCode          NVARCHAR( 30),
      @cSuggID                NVARCHAR( 20),
      @cBarcode               NVARCHAR( MAX),
      @nActQTY                INT,
      @nSuggQTY               INT,
      @bSuccess               INT,
      @nFromScn               INT,
      @nFromStep              INT,
      @cUPC                   NVARCHAR( 30),
      @cSKU                   NVARCHAR( 20),
      @cQTY                   NVARCHAR( 6),
      @cCurrSKU               NVARCHAR( 20),
      @cAllowSkipLOC          NVARCHAR( 1),
      @cSKUValidated          NVARCHAR( 2),
      @cDiscardKeyword99      NVARCHAR( 5),
      @cDecodeSP              NVARCHAR( 20),
      @cUserName              NVARCHAR( 18),
      @cScanCIDSCN            NVARCHAR( 1),
      @cPickConfirmStatus     NVARCHAR( 1),
      @cUOM                   NVARCHAR( 1),
      @cScannedUCC            NVARCHAR( 20),
      @cScannedLOC            NVARCHAR( 10),
      @cScannedSKU            NVARCHAR( 20),
      @cScannedLOT            NVARCHAR( 10),
      @cScannedSN             NVARCHAR( 50),
      @cDropIDScn             NVARCHAR( 20),
      @cPackData1             NVARCHAR( 30),
      @cPackData2             NVARCHAR( 30),
      @cPackData3             NVARCHAR( 30),
      @cPackUOM               NVARCHAR(10),
      @cSQL                   NVARCHAR( MAX),
      @cSQLParam              NVARCHAR( MAX),
      @cMultiSKUBarcode       NVARCHAR( 1),
      @cDisableQTYField       NVARCHAR( 1),
      @cDefaultQTY            NVARCHAR( 1),
      @cSerialNoCapture       NVARCHAR( 1),
      @cSKUSerialNoCapture    NVARCHAR( 1),
      @cConfirmLOC            NVARCHAR( 1),
      @cDefaultPickQTY        NVARCHAR( 5),
      @cDataCapture           NVARCHAR( 1),
      @cExtendedValidateSP    NVARCHAR( 20),
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cExtSkuInfoSP          NVARCHAR( 20),
      @cDataCaptureSP         NVARCHAR( 20),
      @cDecodeIDSP            NVARCHAR( 20),
      @cExtendedInfo          NVARCHAR( 20),
      @cType                  NVARCHAR( 10),
      @cZone                  NVARCHAR( 18),
      @cSKUDataCapture        NVARCHAR( 1),
      @cPickZoneMandatory     NVARCHAR( 1),
      @cAutoScanOut           NVARCHAR( 1),
      @cDefaultPickZone       NVARCHAR(1),
      @cExtDescr1             NVARCHAR( 20),
      @cExtDescr2             NVARCHAR( 20),
      @cDefaultSKU            NVARCHAR(20),
      @cCurrLOC               NVARCHAR( 10),
      @cCartonID              NVARCHAR( 20),
      @cSkippedSKU            NVARCHAR( 20),
      @cSkipConfirmBalPick    NVARCHAR( 1),
      @cSerialNo              NVARCHAR( 30) = '',
      @cPackLabel1            NVARCHAR( 20),
      @cPackLabel2            NVARCHAR( 20),
      @cPackLabel3            NVARCHAR( 20),
      @cPackAttr1             NVARCHAR( 1),
      @cPackAttr2             NVARCHAR( 1),
      @cPackAttr3             NVARCHAR( 1),
      @cLoadKey               NVARCHAR( 10),
      @cOrderKey              NVARCHAR( 10),
      @cCurrentOrderKey       NVARCHAR( 10),
      @cPreviousOrderKey      NVARCHAR( 10),
      @cCloseDropIDFlag       NVARCHAR( 1) = '',
      @cPickDetailKey         NVARCHAR( 18),
      @cRowRefTemp            INT,
      @nMorePage              INT,
      @nSerialQTY             INT,
      @cPackQty               INT,
      @nQTY                   INT,
      @nTtlBalQty             INT,
      @nBalQty                INT,
      @nMoreSNO               INT,
      @nTotalSNO              INT,
      @nPre_Step              INT,
      @nUPCQty                INT = 0,
      @nTranCount             INT,
      @nLoopIndex             INT = -1,
      @cRemarks               NVARCHAR( 30),

      @cChkLottable01 NVARCHAR( 18),   @cChkLottable02 NVARCHAR( 18),   @cChkLottable03 NVARCHAR( 18),
      @dChkLottable04 DATETIME,        @dChkLottable05 DATETIME,        @cChkLottable06 NVARCHAR( 30),
      @cChkLottable07 NVARCHAR( 30),   @cChkLottable08 NVARCHAR( 30),   @cChkLottable09 NVARCHAR( 30),
      @cChkLottable10 NVARCHAR( 30),   @cChkLottable11 NVARCHAR( 30),   @cChkLottable12 NVARCHAR( 30),
      @dChkLottable13 DATETIME,        @dChkLottable14 DATETIME,        @dChkLottable15 DATETIME

   DECLARE @tRDTPickLog TABLE 
   (
      RowRef                  INT  PRIMARY KEY,
      PickDetailKey           NVARCHAR( 18),
      OrderKey                NVARCHAR( 10),
      OrderLineNumber         NVARCHAR( 5),
      Remarks                 NVARCHAR( 30)
   )

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

   SELECT 
      @nCurrentStep        = Step,
      @nCurrentScn         = Scn,
      
      @nFunc            = Func,
      @nInputKey        = InputKey,
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
      @cBarcode         = V_Barcode,
      
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
      @nPre_Step        = V_Integer4,

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
      @cSKUSerialNoCapture = V_String15, 

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
      @cSerialNoCapture    = V_String34,  
      @cCartonID           = V_String35,  --(yeekung02)
      @cScanCIDSCN         = V_String36, --(yeekung02)
      @cDecodeIDSP         = V_String37, --(yeekung02)
      @cSuggID             = V_String38,
      @cDefaultSKU         = V_String39,
      @cExtSkuInfoSP       = V_String40,  -- (james08)
      @cPackData1          = V_String41,  --(yeekung04)
      @cPackData2          = V_String42,  --(yeekung04)
      @cPackData3          = V_String43,  --(yeekung04)
      @cDataCaptureSP      = V_String44,
      @cSKUDataCapture     = V_String45,

      @cInField01 = I_Field01,
      @cInField02 = I_Field02,
      @cInField03 = I_Field03,
      @cInField04 = I_Field04,
      @cInField05 = I_Field05,
      @cInField06 = I_Field06,
      @cInField07 = I_Field07,
      @cInField08 = I_Field08,
      @cInField09 = I_Field09,
      @cInField10 = I_Field10,
      @cInField11 = I_Field11,
      @cInField12 = I_Field12,
      @cInField13 = I_Field13,
      @cInField14 = I_Field14,
      @cInField15 = I_Field15,

      @cSuggUCC            = C_String1,
      @cSuggLOT            = C_String2,
      @cDropIDScn          = C_String5,
      @cUOM                = C_String6,
      @cCloseDropIDFlag    = C_String9,
      @cCurrentOrderKey    = C_String11,
      @cPreviousOrderKey   = C_String12

   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SET @cEntryDropID = rdt.rdtGetConfig( @nFunc, 'EntryDropID', @cStorerKey)

   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)
   IF @cPickConfirmStatus = '0'
      SET @cPickConfirmStatus = '5'

   SET @cUDF01 = ''

   IF @nFunc = 839
   BEGIN
      IF @nCurrentStep = 1
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cPickSlipNo = @cInField01

            SELECT @nRowCount = COUNT(DISTINCT ORM.OrderKey)
            FROM dbo.PickHeader PH WITH(NOLOCK)
            INNER JOIN dbo.WaveDetail WD WITH(NOLOCK) ON PH.WaveKey = WD.WaveKey
            INNER JOIN dbo.Orders ORM WITH(NOLOCK) ON PH.StorerKey = ORM.StorerKey AND WD.OrderKey = ORM.OrderKey
            WHERE PH.PickHeaderKey = @cPickSlipNo 
               AND PH.StorerKey = @cStorerkey

            SET @cFieldAttr03 = CASE @cEntryDropID 
                                    WHEN '0' THEN 'O'
                                    WHEN '1' THEN ''
                                    WHEN '2' THEN IIF(@nRowCount = 1, '', 'O')
                                    ELSE ''
                                 END

            UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
            SET C_String5 = IIF(@cFieldAttr03 = '', 'PickZoneScn', 'ToIDScn')
            WHERE Mobile = @nMobile
         END
      END
      ELSE IF @nCurrentStep = @nStep_PickZone
      BEGIN
         IF @nInputKey = 0
         BEGIN
            IF EXISTS(SELECT 1 
                     FROM rdt.rdtPickLog 
                     WHERE Mobile = @nMobile
                        AND PickSlipNo = @cPickSlipNo
                        AND AddWho = @cUserName)
            BEGIN
               SET @nAfterScn = 6840
               SET @nAfterStep = 99

               SET @nPre_Step = @nCurrentStep
            END
         END
      END
      -- Use the existing screen 4644 for step 5, but set next step to 99
      -- Need jump to reason screen after confirming short pick
      -- ELSE IF @nCurrentStep = @nStep_ShortPick
      -- BEGIN
      --    SET @nAfterStep = 99
      --    SET @nAfterScn = 4644
      -- END
      ELSE IF @nCurrentStep = @nStep_SkipLOC
      BEGIN
         -- Skip current suggested LOC, need remove the existing pick log record with 0 pick lock qty
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DELETE FROM @tRDTPickLog

            INSERT INTO @tRDTPickLog ( RowRef, Remarks )
            SELECT RowRef, Remarks
            FROM rdt.rdtPickLog WITH(NOLOCK)
            WHERE Mobile = @nMobile
               AND PickSlipNo = @cPickSlipNo
               AND AddWho = @cUserName
               AND Status = '0'
               AND PickMethod IN( 'GetTask-U', 'GetTask-P') 
               AND PickLockQty = 0
               AND Loc = @cSuggLOC
            
            IF EXISTS(SELECT 1 FROM @tRDTPickLog)
            BEGIN
               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1 @nLoopIndex = RowRef,
                     @cRemarks = Remarks
                  FROM @tRDTPickLog
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0
                     BREAK

                  BEGIN TRY
                     UPDATE dbo.SerialNo WITH(ROWLOCK)
                     SET UserDefine01 = '0'
                     WHERE UCCNo = ISNULL(@cRemarks, '')
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 255537
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update SerialNo failed
                     GOTO UPD_RDTMOBREC
                  END CATCH
                  
                  BEGIN TRY
                     DELETE FROM RDT.rdtPickLog
                     WHERE RowRef = @nLoopIndex
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 255533
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete rdtPickLog failed
                     GOTO UPD_RDTMOBREC
                  END CATCH
               END
            END

            IF @nStep = @nStep_NoMoreTask
               AND EXISTS(SELECT 1 
                     FROM rdt.rdtPickLog WITH(NOLOCK)
                     WHERE Mobile = @nMobile
                        AND PickSlipNo = @cPickSlipNo
                        AND AddWho = @cUserName
                        AND ((Status = '9'AND PickMethod IN( 'GetTask-U', 'GetTask-P') ) OR PickMethod = 'PickTask-P' ) 
                     )
            BEGIN
               SET @nAfterScn = 6828
               SET @nAfterStep = 99
            END
         END
      END
      ELSE IF @nCurrentStep = @nStep_ConfirmLOC
      BEGIN
         IF @nInputKey = 0 -- ESC
         BEGIN
            IF EXISTS(SELECT 1 
                     FROM rdt.rdtPickLog 
                     WHERE Mobile = @nMobile
                        AND PickSlipNo = @cPickSlipNo
                        AND AddWho = @cUserName)
            BEGIN
               SET @nAfterScn = 6840
               SET @nAfterStep = 99
               SET @cOutField01 = ''
            END
         END
         SET @nPre_Step = @nStep_ConfirmLOC
      END
      ELSE IF @nCurrentStep = @nStep_VerifyID
      BEGIN
         SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')
         SELECT @cSuggSKU = Value FROM @tExtScnData WHERE Variable = '@cSuggSKU'
         SELECT @nSuggQty = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nSuggQty'

         SELECT
            @cPackUOM = Pack.PackUOM3
         FROM dbo.SKU S WITH (NOLOCK)
         INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
         WHERE StorerKey = @cStorerKey
            AND SKU = @cSuggSKU

         SET @cOutField08 = ISNULL(@cLottable01, '')
         SET @cOutField09 = '6'
         SET @cOutField10 = @cPackUOM
         SET @cOutField11 = CAST(@nSuggQty AS NVARCHAR(10))

         UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
         SET C_String6 = '6'
         WHERE Mobile = @nMobile
      END
      ELSE IF @nCurrentStep = 99
      BEGIN
         -- Confirm short screen
         IF @nCurrentScn = 4644
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               -- Screen mapping
               SET @cOption = TRIM(@cInField01)
               IF @cOption = '1' -- SHORT
               BEGIN
                  SET @nAfterScn = 6773 -- Short reason screen
                  SET @nAfterStep = 99
                  GOTO Quit
               END
               ELSE
               BEGIN
                  SET @cUDF01 = 'GOTO STEP5'
                  GOTO Quit
               END
            END
            ELSE -- ESC
            BEGIN
               SET @cUDF01 = 'GOTO STEP5'
               GOTO Quit
            END
         END

         /************************************************************************************
         Scn = 6773. Reason Code screen
            Reason Code    (field01, input)
         ************************************************************************************/
         ELSE IF @nCurrentScn = 6773
         BEGIN
            SET @cUDF01 = 'No Need Update RDTMOBREC'
            -- If short reason code is valid
            -- 1. Mark short pick detail in rdtPickLog
            -- 2. Hold the location
            -- 3. Send supervisor alert message
            -- 4. Re-allocate the pick task
            -- 5. Get next pick task
            IF @nInputKey = 1 -- ENTER
            BEGIN
               DECLARE 
                  @cReasonCode NVARCHAR(10),
                  @cAlertMessage NVARCHAR(255),
                  @cRealloMethod NVARCHAR(5)

               SET @cReasonCode = TRIM(@cInField01)

               IF @cReasonCode = ''
               BEGIN
                  SET @nErrNo = 255529
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Reason code is required
                  GOTO Quit
               END

               IF NOT EXISTS(SELECT 1 
                           FROM dbo.CODELKUP WITH(NOLOCK) 
                           WHERE LISTNAME = 'SHRTREASON' 
                              AND Code = @cReasonCode
                              AND StorerKey = @cStorerKey)
               BEGIN
                  SET @nErrNo = 255501
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid reason code
                  GOTO Quit
               END
               
               SET @cRealloMethod = rdt.rdtGetConfig( @nFunc, 'RealloMethod', @cStorerKey)
               
               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN  -- Begin our own transaction
               SAVE TRAN rdt_839ExtScn06_6773 -- For rollback or commit only our own transaction

               -- 1. Mark short pick detail in rdtPickLog
               SELECT @cSuggLOT = C_String2,
                     @cSuggUCC = C_String1
               FROM rdt.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile

               DELETE FROM @tRDTPickLog
               IF @cUOM = '6' -- Piece pick
               BEGIN
                  INSERT INTO @tRDTPickLog (RowRef, PickDetailKey, OrderKey, OrderLineNumber)
                  SELECT RPL.RowRef, RPL.PickDetailKey, PD.OrderKey, PD.OrderLineNumber
                  FROM rdt.rdtPickLog RPL WITH(NOLOCK)
                  INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
                  WHERE RPL.Mobile = @nMobile
                     AND RPL.PickSlipNo = @cPickSlipNo
                     AND PD.SKU = @cSuggSKU
                     AND PD.LOC = @cSuggLOC
                     AND PD.LOT = @cSuggLOT
                     AND RPL.AddWho = @cUserName
                     AND RPL.PickMethod = 'GetTask-P'
               END
               ELSE
               BEGIN
                  INSERT INTO @tRDTPickLog (RowRef, PickDetailKey, OrderKey, OrderLineNumber)
                  SELECT RPL.RowRef, RPL.PickDetailKey, PD.OrderKey, PD.OrderLineNumber
                  FROM rdt.rdtPickLog RPL WITH(NOLOCK)
                  INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON RPL.PickDetailKey = PD.PickDetailKey
                  WHERE RPL.Mobile = @nMobile
                     AND RPL.PickSlipNo = @cPickSlipNo
                     AND RPL.Descr = @cSuggUCC
                     AND RPL.AddWho = @cUserName
                     AND RPL.PickMethod = 'GetTask-U'
               END

               SET @nLoopIndex = -1
               WHILE 1 = 1
               BEGIN
                  SELECT TOP 1
                     @nLoopIndex = RowRef
                  FROM @tRDTPickLog
                  WHERE RowRef > @nLoopIndex
                  ORDER BY RowRef

                  IF @@ROWCOUNT = 0
                     BREAK

                  BEGIN TRY
                     UPDATE rdt.rdtPickLog WITH(ROWLOCK)
                     SET Status = '4',
                        PutawayZone = @cReasonCode
                     WHERE RowRef = @nLoopIndex
                  END TRY
                  BEGIN CATCH
                     IF XACT_STATE() = -1
                        ROLLBACK TRAN rdt_839ExtScn06_6773

                     WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                        COMMIT TRAN

                     SET @nErrNo = 255528
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update rdtPickLog failed
                     GOTO Quit
                  END CATCH
               END

               EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'SHORT'
                  ,@cPickSlipNo
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
                  IF XACT_STATE() = -1
                     ROLLBACK TRAN rdt_839ExtScn06_6773
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN

                  GOTO Quit
               END
                  
               -- 2. Hold the location
               BEGIN TRY
                  EXEC nspInventoryHoldWrapper
                     '',               -- lot
                     @cSuggLOC,        -- loc
                     '',               -- id
                     '',               -- storerkey
                     '',               -- sku
                     '',               -- lottable01
                     '',               -- lottable02
                     '',               -- lottable03
                     NULL,             -- lottable04
                     NULL,             -- lottable05
                     '',               --lottable06
                     '',               --lottable07
                     '',               --lottable08
                     '',               --lottable09
                     '',               --lottable10
                     '',               --lottable11
                     '',               --lottable12
                     NULL,             --lottable13
                     NULL,             --lottable14
                     NULL,             --lottable15
                     'HOLD',           -- status  
                     '1',              -- hold  
                     @bSuccess OUTPUT,  
                     @nErrNo OUTPUT,  
                     @cErrMsg OUTPUT,  
                     @cReasonCode   -- remark
               END TRY
               BEGIN CATCH
                  IF XACT_STATE() = -1
                     ROLLBACK TRAN rdt_839ExtScn06_6773
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN

                  SET @nErrNo = 255502
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Hold Loc failed
                  GOTO Quit
               END CATCH

               IF @nErrNo <> 0  
               BEGIN
                  IF XACT_STATE() = -1
                     ROLLBACK TRAN rdt_839ExtScn06_6773
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN

                  GOTO Quit
               END  

               -- 3. Send supervisor alert message
               BEGIN TRY
                  DECLARE @cVarianceQty NVARCHAR(10) = ISNULL(TRY_CAST((@nSuggQTY - @nActQTY) AS NVARCHAR(10)), '')
                  SET @cAlertMessage =
                        'Short happens while picking(FN839), Loc: ' + @cSuggLOC 
                        + ' ,SKU: ' + @cSuggSKU 
                        + ' ,UCC/SerialNo: ' + @cSuggUCC 
                        + ' ,VARIANCE QTY: ' + @cVarianceQty
                  EXEC nspLogAlert
                        @c_modulename       = 'rdt_839ExtScn06'
                        , @c_AlertMessage     = @cAlertMessage
                        , @n_Severity         = '5'
                        , @b_success          = @bSuccess
                        , @n_err              = @nErrNo
                        , @c_errmsg           = @cErrMsg
                        , @c_Activity         = 'Picking'
                        , @c_Storerkey        = @cStorerkey
                        , @c_SKU              = @cSuggSKU
                        , @c_UOM              = ''
                        , @c_UOMQty           = ''
                        , @c_Qty              = @cVarianceQty
                        , @c_Lot              = ''
                        , @c_Loc              = @cSuggLOC
                        , @c_ID               = ''
                        , @c_TaskDetailKey    = ''
                        , @c_UCCNo            = @cSuggUCC
               END TRY
               BEGIN CATCH
                  IF XACT_STATE() = -1
                     ROLLBACK TRAN rdt_839ExtScn06_6773
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN

                  SET @nErrNo = 255503
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Send alert message failed
                  GOTO Quit
               END CATCH

               -- 4. Re-allocate the pick task
               DECLARE 
                  @cAPP_DB_Name              NVARCHAR(20),
                  @cDataStream               VARCHAR(10),
                  @nThreadPerAcct            INT,
                  @nThreadPerStream          INT,
                  @nMilisecondDelay          INT,
                  @cIP                       NVARCHAR(20),
                  @cPORT                     NVARCHAR(5),
                  @cIniFilePath              NVARCHAR(200),
                  @cCmdType                  NVARCHAR(10),
                  @cTaskType                 NVARCHAR(1),
                  @c_TransmitlogKey          NVARCHAR(10),
                  @cExecStatements           NVARCHAR(MAX),
                  @cExecArguments            NVARCHAR(MAX)

               DECLARE @curPD CURSOR
               SET @curPD = CURSOR FOR
                  SELECT DISTINCT PD.PickDetailKey
                  FROM dbo.PickDetail PD WITH(NOLOCK)
                  INNER JOIN @tRDTPickLog TRPL ON ( (PD.OrderKey = TRPL.OrderKey AND PD.OrderLineNumber = TRPL.OrderLineNumber AND ISNULL(PD.SourceType, '') = TRPL.PickDetailKey) OR (PD.PickDetailKey = TRPL.PickDetailKey) )
                  WHERE PD.StorerKey = @cStorerKey
                     AND PD.Status = '4'

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
               WHERE TableName = 'RealloPickDetail'
                  AND App_Name = 'WMS'
                  AND  StorerKey =  @cStorerKey

               OPEN @curPD
               FETCH NEXT FROM @curPD INTO @cPickDetailKey
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  IF @cRealloMethod = 'Sync'
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExecStatements) +
                           ' @cPickDetailKey, ' +
                           ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                        SET @cSQLParam =
                           ' @cPickDetailKey         NVARCHAR( 18) ' +
                           ',@nErrNo          INT           OUTPUT     ' +
                           ',@cErrMsg         NVARCHAR(250) OUTPUT     '

                        BEGIN TRY
                           EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                              @cPickDetailKey,
                              @nErrNo OUTPUT, @cErrMsg OUTPUT
                        END TRY
                        BEGIN CATCH
                           IF XACT_STATE() = -1
                              ROLLBACK TRAN rdt_839ExtScn06_6773
                           WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                              COMMIT TRAN
                              
                           SET @nErrNo = 255534
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Exec Reallocate SP failed

                           CLOSE @curPD
                           DEALLOCATE @curPD
                           GOTO Quit
                        END CATCH

                        IF @nErrNo <> 0
                        BEGIN
                           IF XACT_STATE() = -1
                              ROLLBACK TRAN rdt_839ExtScn06_6773
                           WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                              COMMIT TRAN

                           CLOSE @curPD
                           DEALLOCATE @curPD
                           GOTO Quit
                        END
                  END
                  ELSE IF @cRealloMethod = 'Async'
                  BEGIN
                     SET @cExecStatements = 'EXEC ' + @cAPP_DB_Name + '.dbo.' + LTRIM(@cExecStatements)
                                          + ' @cPickDetailKey = ''' + @cPickDetailKey + ''''

                     -- Submit task to QCommander
                     BEGIN TRY
                        EXEC isp_QCmd_SubmitTaskToQCommander
                           @cTaskType           = 'D'                  -- 'T' - TransmitlogKey, 'D' - Data Stream 
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
                           , @bSuccess            = @bSuccess     OUTPUT 
                           , @nErr                = @nErrNo       OUTPUT 
                           , @cErrMsg             = @cErrMsg      OUTPUT
                     END TRY
                     BEGIN CATCH
                        IF XACT_STATE() = -1
                           ROLLBACK TRAN rdt_839ExtScn06_6773
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN
                           
                        SET @nErrNo = 255535
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Submit QCommanderTask Failed

                        CLOSE @curPD
                        DEALLOCATE @curPD
                        GOTO Quit
                     END CATCH

                     IF @nErrNo <> 0
                     BEGIN
                        IF XACT_STATE() = -1
                           ROLLBACK TRAN rdt_839ExtScn06_6773
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN

                        CLOSE @curPD
                        DEALLOCATE @curPD
                        GOTO Quit
                     END
                  END
                  FETCH NEXT FROM @curPD INTO @cPickDetailKey
               END
               CLOSE @curPD
               DEALLOCATE @curPD

               COMMIT TRAN rdt_839ExtScn06_6773 -- Only commit change made here
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN

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
                  ,@cSKUSerialNoCapture OUTPUT
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

                  IF @cScanCIDSCN = '1'
                  BEGIN
                     -- Prepare next screen var
                     SET @cOutField01 = @cSuggLOC
                     SET @cOutField04 = @cSuggID --(yeekung02)
                     SET @cOutField05 = ''

                     -- Go to verify ID screen
                     SET @nAfterScn = @nScn_VerifyID
                     SET @nAfterStep = @nStep_VerifyID
                     GOTO UPD_RDTMOBREC
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
                  
                  SET @cBarcode = ''
                  
                  SELECT TOP 1 @cSuggUCC  = Descr
                  FROM rdt.rdtPickLog WITH(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND Mobile = @nMobile
                     AND AddWho = @cUserName
                     AND PickMethod = 'GetTask-U'
                     AND Status = '0'
                  ORDER BY AddDate DESC

                  SELECt @nRowCount = @@ROWCOUNT

                  -- Display UCC
                  IF @nRowCount > 0
                  BEGIN
                     SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                     SET @cOutField08 = 'UCC:'
                     SET @cOutField09 = @cSuggUCC
                     SET @cOutField10 = 'LOT:'
                     SET @cOutField11 = @cSuggLOT
                  END
                  ELSE
                  -- Display Piece info, Lottable01, UOM, UOM Desc
                  BEGIN
                     SELECT TOP 1 @cSuggLOT  = Descr
                     FROM rdt.rdtPickLog WITH(NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND Mobile = @nMobile
                        AND AddWho = @cUserName
                        AND PickMethod = 'GetTask-P'
                        AND Status = '0'
                     ORDER BY AddDate DESC
                     
                     SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                     SELECT
                        @cPackUOM = Pack.PackUOM3
                     FROM dbo.SKU S WITH (NOLOCK)
                     INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                     WHERE StorerKey = @cStorerKey
                        AND SKU = @cSuggSKU

                     SET @cOutField08 = ISNULL(@cLottable01, '')
                     SET @cOutField09 = 'UOM: 6'
                     SET @cOutField10 = @cPackUOM
                     SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
                  END

                  SET @nAfterStep = 99
                  SET @nAfterScn = 6774
                  
                  EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
               END
               ELSE
               BEGIN
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
                     ,@cSKUSerialNoCapture OUTPUT
                  IF @nErrNo = 0
                  BEGIN
                     IF @cConfirmLOC = '1'
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cSuggLOC
                        SET @cOutField02 = '' -- LOC

                        -- Go to confirm LOC screen
                        SET @nAfterScn = @nScn_ConfirmLOC
                        SET @nAfterStep = @nStep_ConfirmLOC
                        GOTO UPD_RDTMOBREC
                     END
                     ELSE IF @cScanCIDSCN='1'
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cSuggLOC
                        SET @cOutField04 = @cSuggID --(yeekung02)
                        SET @cOutField05 = ''

                        -- Go to verify ID screen
                        SET @nAfterScn = @nScn_VerifyID
                        SET @nAfterStep = @nStep_VerifyID
                        GOTO UPD_RDTMOBREC

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
                        
                        SET @cBarcode = ''

                        SELECT TOP 1 @cSuggUCC  = Descr
                  FROM rdt.rdtPickLog WITH(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND Mobile = @nMobile
                     AND AddWho = @cUserName
                     AND PickMethod = 'GetTask-U'
                     AND Status = '0'
                  ORDER BY AddDate DESC

                  SELECt @nRowCount = @@ROWCOUNT

                  -- Display UCC
                  IF @nRowCount > 0
                  BEGIN
                     SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                     SET @cOutField08 = 'UCC:'
                     SET @cOutField09 = @cSuggUCC
                     SET @cOutField10 = 'LOT:'
                     SET @cOutField11 = @cSuggLOT
                  END
                  ELSE
                  -- Display Piece info, Lottable01, UOM, UOM Desc
                  BEGIN
                     SELECT TOP 1 @cSuggLOT  = Descr
                     FROM rdt.rdtPickLog WITH(NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND Mobile = @nMobile
                        AND AddWho = @cUserName
                        AND PickMethod = 'GetTask-P'
                        AND Status = '0'
                     ORDER BY AddDate DESC
                     
                     SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                     SELECT
                        @cPackUOM = Pack.PackUOM3
                     FROM dbo.SKU S WITH (NOLOCK)
                     INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                     WHERE StorerKey = @cStorerKey
                        AND SKU = @cSuggSKU

                     SET @cOutField08 = ISNULL(@cLottable01, '')
                     SET @cOutField09 = 'UOM: 6'
                     SET @cOutField10 = @cPackUOM
                     SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
                  END

                        SET @nAfterScn = 6774
                        SET @nAfterStep = 99
                        
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
                        ,@cSKUSerialNoCapture OUTPUT
                     IF @nErrNo =  0
                     BEGIN
                        -- Reset here, next screen will fetch task again
                        SET @cCurrLOC = ''
                        SET @cSuggLOC = ''

                        -- Prepare next screen var
                        SET @cOutField01 = @cPickSlipNo -- '' -- PickSlipNo
                        SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END
                        SET @cOutField03 = ''
                        SET @cOutField15 = ''

                        -- Go to PickSlipNo screen
                        SET @nAfterScn = @nScn_PickZone
                        SET @nAfterStep = @nStep_PickZone
                     END
                     ELSE
                     BEGIN
                        -- Go to No More Task screen
                        SET @nAfterScn = 6828
                        SET @nAfterStep = 99
                     END
                  END
               END
               GOTO UPD_RDTMOBREC
            END
            ELSE -- ESC
            BEGIN
               SET @cOutField01 = ''
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
               SET @cOutField13 =LTRIM(CAST(@nBalQty - @nActQTY AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))

               IF @cFieldAttr07='O'
                  SET @cOutField07= CASE WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY ELSE @nActQTY END
               ELSE
                  SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END
               
               SET @cBarcode = ''

               SELECT TOP 1 @cSuggUCC  = Descr
               FROM rdt.rdtPickLog WITH(NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
                  AND Mobile = @nMobile
                  AND AddWho = @cUserName
                  AND PickMethod = 'GetTask-U'
                  AND Status = '0'
               ORDER BY AddDate DESC

               SELECt @nRowCount = @@ROWCOUNT

               -- Display UCC
               IF @nRowCount > 0
               BEGIN
                  SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                  SET @cOutField08 = 'UCC:'
                  SET @cOutField09 = @cSuggUCC
                  SET @cOutField10 = 'LOT:'
                  SET @cOutField11 = @cSuggLOT
               END
               ELSE
               -- Display Piece info, Lottable01, UOM, UOM Desc
               BEGIN
                  SELECT TOP 1 @cSuggLOT  = Descr
                  FROM rdt.rdtPickLog WITH(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND Mobile = @nMobile
                     AND AddWho = @cUserName
                     AND PickMethod = 'GetTask-P'
                     AND Status = '0'
                  ORDER BY AddDate DESC
                  
                  SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                  SELECT
                     @cPackUOM = Pack.PackUOM3
                  FROM dbo.SKU S WITH (NOLOCK)
                  INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSuggSKU

                  SET @cOutField08 = ISNULL(@cLottable01, '')
                  SET @cOutField09 = 'UOM: 6'
                  SET @cOutField10 = @cPackUOM
                  SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
               END

               SET @nAfterStep = 99
               SET @nAfterScn = 6774
               
               EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
               GOTO UPD_RDTMOBREC
            END
         END
         /********************************************************************************
         Scn = 6774. SKU QTY screen
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
         ELSE IF @nCurrentScn = 6774
         BEGIN
            SET @cUDF01 = 'No Need Update RDTMOBREC'
            SET @cCloseDropIDFlag = 'N'

            IF @nInputKey = 1
            BEGIN
               -- Screen mapping
               SET @cBarcode = SUBSTRING( @cBarcode, 1, 2000)
               SET @cUPC = SUBSTRING( @cBarcode, 1, 30)        
               -- SET @cQTY = CASE WHEN @cFieldAttr07 = 'O' THEN @cOutField07 ELSE @cInField07 END
               SET @cQTY = IIF( @nActQTY = 0, '', CAST(@nActQTY AS NVARCHAR(10)) )
               SET @cCurrSKU = @cOutField02          

               -- Retain value
               SET @cOutField07 = CASE WHEN @cFieldAttr07 = 'O' THEN @cOutField07 ELSE @cInField07 END -- MQTY

               SET @cSKU = ''
               SET @nQTY = 0

               -- Skip LOC
               IF @cAllowSkipLOC = '1' AND @cBarcode = '' AND @cQTY = ''
               BEGIN
                  IF NOT EXISTS(SELECT 1 FROM rdt.rdtPickLog WITH(NOLOCK)
                                 WHERE PickSlipNo = @cPickSlipNo
                                    AND Mobile = @nMobile
                                    AND AddWho = @cUserName
                                    AND Loc = @cSuggLOC
                                    AND PickMethod IN ('GetTask-P', 'GetTask-U')
                                    AND Status IN ('4', '9') )
                     AND NOT EXISTS(SELECT 1 FROM rdt.rdtPickLog WITH(NOLOCK)
                                 WHERE PickSlipNo = @cPickSlipNo
                                    AND Mobile = @nMobile
                                    AND Loc = @cSuggLOC
                                    AND AddWho = @cUserName
                                    AND PickMethod IN ('Pick-P')
                                    AND Status IN ('4', '9') )
                  BEGIN
                     DECLARE @nFinishedPKDFlag INT = 0
                     -- Cross dock PickSlip
                     IF @cZone IN ('XD', 'LB', 'LP')
                     BEGIN
                        IF EXISTS(SELECT 1
                           FROM dbo.RefKeyLookup RKL WITH (NOLOCK)
                           INNER JOIN dbo.PickDetail PD WITH (NOLOCK) ON (PD.PickDetailKey = RKL.PickDetailKey)
                           WHERE RKL.PickSlipNo = @cPickSlipNo
                              AND PD.EditWho = @cUserName
                              AND (PD.DropID = @cDropID AND PD.Status = '5' OR PD.Status = '4')
                              AND PD.Loc = @cSuggLoc
                        )
                        BEGIN
                           SET @nFinishedPKDFlag = 1
                        END
                     END

                     -- Discrete PickSlip
                     ELSE IF @cOrderKey <> ''
                     BEGIN
                        IF EXISTS(SELECT 1
                           FROM dbo.PickDetail PD WITH (NOLOCK)
                           WHERE PD.OrderKey = @cOrderKey
                              AND PD.EditWho = @cUserName
                              AND (PD.DropID = @cDropID AND PD.Status = '5' OR PD.Status = '4')
                              AND PD.Loc = @cSuggLoc
                        )
                        BEGIN
                           SET @nFinishedPKDFlag = 1
                        END
                     END

                     -- Conso PickSlip
                     ELSE IF @cLoadKey <> ''
                     BEGIN
                        IF EXISTS(SELECT 1
                           FROM dbo.LoadPlanDetail LPD WITH (NOLOCK) 
                           INNER JOIN dbo.PickDetail PD (NOLOCK) ON (PD.OrderKey = LPD.OrderKey)
                           WHERE LPD.LoadKey = @cLoadKey  
                              AND PD.EditWho = @cUserName
                              AND (PD.DropID = @cDropID AND PD.Status = '5' OR PD.Status = '4')
                              AND PD.Loc = @cSuggLoc
                        )
                        BEGIN
                           SET @nFinishedPKDFlag = 1
                        END
                     END

                     -- Custom PickSlip
                     ELSE
                     BEGIN
                        IF EXISTS(SELECT 1
                           FROM dbo.PickDetail PD WITH (NOLOCK)
                           WHERE PD.PickSlipNo = @cPickSlipNo
                              AND PD.EditWho = @cUserName
                              AND (PD.DropID = @cDropID AND PD.Status = '5' OR PD.Status = '4')
                              AND PD.Loc = @cSuggLoc
                        )
                        BEGIN
                           SET @nFinishedPKDFlag = 1
                        END
                     END

                     -- No any pickdetail is finished, can skip current location
                     IF @nFinishedPKDFlag = 0
                     BEGIN
                        -- Prepare skip LOC screen var
                        SET @cOutField01 = ''

                        -- Remember step
                        SET @nFromScn = 4642
                        SET @nFromStep = 3

                        -- Go to skip LOC screen
                        SET @nAfterScn = @nScn_SkipLOC
                        SET @nAfterStep = @nStep_SkipLOC

                        GOTO UPD_RDTMOBREC
                     END
                  END
               END

               -- QTY short
               IF EXISTS(SELECT 1 FROM rdt.rdtPickLog WITH(NOLOCK)
                           WHERE PickSlipNo = @cPickSlipNo
                              AND Mobile = @nMobile
                              AND AddWho = @cUserName
                              AND PickMethod IN ('GetTask-P', 'GetTask-U')
                              AND Status <> '9')
                  AND @cBarcode = ''
               BEGIN
                  -- Prepare next screen var
                  SET @cOption = ''
                  SET @cOutField01 = '' -- Option

                  SET @nAfterScn = 6777
                  SET @nAfterStep = 99
                  GOTO UPD_RDTMOBREC
               END

               -- Check SKU blank
               IF @cBarcode = '' AND @cSKUValidated = '0' -- False
               BEGIN
                  IF @cDiscardKeyword99 = '1'
                     SET @cBarcode = '99'
                  ELSE
                  BEGIN
                     SET @nErrNo = 255504
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Need SKU
                     EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                     GOTO UPD_RDTMOBREC
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
                              -- @nErrNo      = @nErrNo  OUTPUT,
                              -- @cErrMsg     = @cErrMsg OUTPUT,
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
                              ' @cLangCode    NVARCHAR( 3),  ' +
                              ' @nStep        INT,           ' +
                              ' @nInputKey    INT,           ' +
                              ' @cFacility    NVARCHAR( 5),  ' +
                              ' @cStorerKey   NVARCHAR( 15), ' +
                              ' @cBarcode     NVARCHAR( MAX), ' +
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
                              @cUPC           OUTPUT, @nQTY           OUTPUT,
                              @cChkLottable01 OUTPUT, @cChkLottable02 OUTPUT, @cChkLottable03 OUTPUT, @dChkLottable04 OUTPUT, @dChkLottable05 OUTPUT,
                              @cChkLottable06 OUTPUT, @cChkLottable07 OUTPUT, @cChkLottable08 OUTPUT, @cChkLottable09 OUTPUT, @cChkLottable10 OUTPUT,
                              @cChkLottable11 OUTPUT, @cChkLottable12 OUTPUT, @dChkLottable13 OUTPUT, @dChkLottable14 OUTPUT, @dChkLottable15 OUTPUT,
                              @nErrNo      OUTPUT, @cErrMsg     OUTPUT
                        END

                        IF @nErrNo <> 0
                        BEGIN
                           SET @cBarcode = ''
                           GOTO UPD_RDTMOBREC
                        END
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
                        SET @nErrNo = 255505
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
                        GOTO UPD_RDTMOBREC
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
                              SET @nAfterScn = @nScn_MultiSKU
                              SET @nAfterStep = @nStep_MultiSKU
                              SET @cOutField13 = ''
                              GOTO UPD_RDTMOBREC
                           END
                           ELSE IF @nErrNo = -1 -- Found in Doc, skip multi SKU screen
                           BEGIN
                              SET @nErrNo = 0
                              SET @cSKU = @cUPC
                           END
                        END
                        ELSE
                        BEGIN
                           SET @nErrNo = 255506
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod
                           GOTO UPD_RDTMOBREC
                        END
                     END

                     -- Get SKU
                     EXEC rdt.rdt_GetSKU
                        @cStorerKey  = @cStorerKey
                        ,@cSKU        = @cUPC      OUTPUT
                        ,@bSuccess    = @bSuccess  OUTPUT
                        ,@nErr        = @nErrNo    OUTPUT
                        ,@cErrMsg     = @cErrMsg   OUTPUT
                        ,@nUPCQty     = @nUPCQty   OUTPUT

                     IF @nUPCQty > 0
                        SET @cQTY = @nUPCQty

                     IF @nErrNo <> 0
                        GOTO UPD_RDTMOBREC

                     SET @cSKU = @cUPC

                     -- Validate SKU
                     IF @cSKU <> @cSuggSKU
                     BEGIN
                        SET @nErrNo = 255507
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong SKU
                        EXEC rdt.rdtSetFocusField @nMobile, 11  -- SKU
                        GOTO UPD_RDTMOBREC
                     END

                     -- Mark SKU as validated
                     SET @cSKUValidated = '1'
                     SET @cCurrSKU = @cSKU
                  END
               END

               -- Validate QTY
               IF @cQTY <> '' AND RDT.rdtIsValidQTY( @cQTY, 0) = 0
               BEGIN
                  SET @nErrNo = 255508
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid QTY
                  EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY
                  GOTO UPD_RDTMOBREC
               END

               -- Check full short with QTY
               IF @cSKUValidated = '99' AND @cQTY <> '0' AND @cQTY <> ''
               BEGIN
                  SET @nErrNo = 255509
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- AllShortWithQTY
                  EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY
                  GOTO UPD_RDTMOBREC
               END

               -- Top up QTY
               IF @cSKUValidated = '99' -- Fully short
                  SET @nQTY = 0
               ELSE IF @nQTY > 0 -- Decoded QTY
               BEGIN
                  IF @cUOM = '2'
                     SET @nQTY = @nActQTY + @nQTY
                  ELSE
                     SET @nQTY = @nActQTY + 1
               END
               ELSE
                  IF @cSKU <> '' AND @cDisableQTYField = '1' AND @cDefaultQTY <> '1' AND @cSKUSerialNoCapture NOT IN ('1', '3')
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
                  SET @nErrNo = 255510
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Over pick
                  EXEC rdt.rdtSetFocusField @nMobile, 7 -- PQTY
                  GOTO UPD_RDTMOBREC
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
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cType,
                        @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSKU, @nQTY,@cPackData1, @cPackData2, @cPackData3,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT
                     IF @nErrNo <> 0
                        GOTO UPD_RDTMOBREC
                  END
               END

               /*
                  Config:
                  DefaultQTY = default the QTY to be picked, on the QTY field
                  DisableQTYFieldSP = disable the QTY field
                     Only applicable when disabled, DefaultPickQTY = default the SValue, on the QTY field (usually is 1)
               
                  Non serial input patterns:
                  1. SKU->SKU->SKU.... QTY field is disabled and default to 1
                  2. SKU->QTY
                  
                  Serial input pattern:
                  QTY field is hardcode to disable (in GetTaskSP)
                  1. SKU->SNO->SNO->SNO... for inbound and outbound both turned on
                        Commit by piece
                        Update back QTY scanned
                  2. SKU->SNO->SKU->SNO... for turn on only outbound
                  2. SKU->QTY->SNO->SNO->SNO... not support, too complicated, user could change the QTY even after scanned SNO
               */

               SELECT @cSuggUCC = C_String1,
                  @cSuggLOT = C_String2,
                  @cScannedUCC = C_String3
               FROM rdt.RDTMOBREC WITH(NOLOCK)
               WHERE Mobile = @nMobile

               IF @cSKUValidated <> '99'
               BEGIN
                  DECLARE @nrdtPickLogID INT = -1

                  IF @cUOM = '2'
                  BEGIN
                     SELECT TOP 1 @nrdtPickLogID = RowRef,
                        @cCurrentOrderKey = OrderKey
                     FROM RDT.rdtPickLog WITH(NOLOCK) 
                     WHERE PickSlipNo = @cPickSlipNo 
                        AND Mobile = @nMobile 
                        AND AddWho = @cUserName 
                        AND Descr = @cSuggUCC
                        AND PickMethod = 'GetTask-U'

                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0
                     BEGIN
                        SELECT @cSuggLOT = LOT 
                        FROM dbo.UCC WITH(NOLOCK)
                        WHERE UCC.UCCNo = @cSuggUCC

                        SELECT TOP 1 @nrdtPickLogID = RPL.RowRef,
                           @cCurrentOrderKey = RPL.OrderKey
                        FROM RDT.rdtPickLog RPL WITH(NOLOCK)
                        INNER JOIN dbo.UCC WITH(NOLOCK) ON RPL.Descr = UCC.UCCNo
                        WHERE RPL.PickSlipNo = @cPickSlipNo 
                           AND RPL.Mobile = @nMobile 
                           AND RPL.AddWho = @cUserName 
                           AND RPL.Descr <> @cSuggUCC
                           AND UCC.Lot = @cSuggLOT
                           AND RPL.PickMethod = 'GetTask-U'
                        ORDER BY RPL.OrderKey, RPL.PickDetailKey

                        SELECT @nRowCount = @@ROWCOUNT
                           
                        IF @nRowCount = 0
                        BEGIN
                           SET @nErrNo = 255514
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Suggested UCC is missing in rdtPickLog
                           EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                           GOTO UPD_RDTMOBREC
                        END
                     END
                     
                     BEGIN TRY
                        UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                        SET Remarks = @cScannedUCC,
                           DropID = IIF(@cDropIDScn = 'PickZoneScn', @cDropID, ''),
                           PickLockQty = ActQty,
                           Status = '9'
                        WHERE RowRef = @nrdtPickLogID
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255516
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update rdtPickLog failed
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                        GOTO UPD_RDTMOBREC
                     
                     END CATCH
                  END
                  ELSE IF @cUOM = '6'
                  BEGIN
                     SELECT @cScannedSN = C_String7,
                        @cScannedLot = C_String8
                     FROM RDT.RDTMOBREC WITH(NOLOCK)
                     WHERE Mobile = @nMobile

                     DECLARE @cScannedLottable01 NVARCHAR(18)

                     SELECT @cScannedLottable01 = Lottable01
                     FROM dbo.LOTATTRIBUTE WITH(NOLOCK)
                     WHERE Lot = @cScannedLot

                     SELECT TOP 1 
                        @nrdtPickLogID = RowRef,
                        @cCurrentOrderKey = RPL.OrderKey
                     FROM RDT.rdtPickLog RPL WITH(NOLOCK)
                     INNER JOIN dbo.LOT WITH(NOLOCK) ON RPL.Descr IS NOT NULL AND RPL.Descr = LOT.Lot
                     INNER JOIN dbo.LOTATTRIBUTE LA WITH(NOLOCK) ON LOT.Lot = LA.Lot
                     WHERE PickSlipNo = @cPickSlipNo 
                        AND RPL.Mobile = @nMobile 
                        AND RPL.AddWho = @cUserName
                        AND RPL.PickMethod = 'GetTask-P'
                        AND RPL.Status = '0'
                        AND RPL.PickLockQty < RPL.ActQty
                        AND (LOT.Lot = @cScannedLot OR (LOT.Lot <> @cScannedLot AND @cScannedLottable01 = LA.Lottable01))
                     ORDER BY RPL.OrderKey, IIF(LOT.Lot = @cScannedLot, 1, 2), RPL.PickLockQty DESC, RPL.PickDetailKey

                     SELECT @nRowCount = @@ROWCOUNT

                     IF @nRowCount = 0
                     BEGIN
                        SET @nErrNo = 255515
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- uggested SN is missing in rdtPickLog
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                        GOTO UPD_RDTMOBREC
                     END

                     BEGIN TRY
                        INSERT INTO RDT.rdtPickLog (OrderKey, PickZone, PickDetailKey, StorerKey, Remarks, ActQty, Mobile, PickSlipNo, PickMethod, Status, DropID)
                        SELECT OrderKey, PickZone, PickDetailKey, StorerKey, @cScannedSN, 1, Mobile, PickSlipNo, 'Pick-P', '0', IIF(@cDropIDScn = 'PickZoneScn', @cDropID, '')
                        FROM RDT.rdtPickLog RPL WITH(NOLOCK)
                        WHERE RowRef = @nrdtPickLogID
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255518
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Insert rdtPickLog failed
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                        GOTO UPD_RDTMOBREC
                     END CATCH

                     BEGIN TRY
                        UPDATE dbo.SerialNo WITH(ROWLOCK)
                        SET UserDefine01 = '3'
                        WHERE SerialNo = @cScannedSN
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255536
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Update SerialNo failed
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                        GOTO UPD_RDTMOBREC
                     END CATCH

                     BEGIN TRY
                        UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                        SET PickLockQty = PickLockQty + 1,
                           Status = IIF(PickLockQty = ActQty - 1, '9', Status)
                        WHERE RowRef = @nrdtPickLogID
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255519
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update rdtPickLog failed
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                        GOTO UPD_RDTMOBREC
                     END CATCH
                  END
               END
               ELSE
               BEGIN
                  IF @cUOM = '2'
                  BEGIN
                     SELECT TOP 1 @nrdtPickLogID = RowRef,
                        @cCurrentOrderKey = OrderKey
                     FROM RDT.rdtPickLog WITH(NOLOCK) 
                     WHERE PickSlipNo = @cPickSlipNo 
                        AND Mobile = @nMobile 
                        AND AddWho = @cUserName 
                        AND Descr = @cSuggUCC
                        AND PickMethod = 'GetTask-U'

                     BEGIN TRY
                        UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                        SET
                           Status = '4'
                        WHERE RowRef = @nrdtPickLogID
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255531
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update rdtPickLog failed
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                        GOTO UPD_RDTMOBREC
                     END CATCH
                  END
                  ELSE IF @cUOM = '6'
                  BEGIN
                     DELETE FROM @tRDTPickLog

                     INSERT INTO @tRDTPickLog ( RowRef)
                     SELECT RPL.RowRef
                     FROM RDT.rdtPickLog RPL WITH(NOLOCK)
                     WHERE RPL.PickSlipNo = @cPickSlipNo 
                        AND RPL.Mobile = @nMobile 
                        AND RPL.AddWho = @cUserName
                        AND RPL.PickMethod = 'GetTask-P'
                        AND RPL.Status = '0'
                        AND RPL.PickLockQty = 0
                        AND RPL.Descr = @cSuggLOT
                     ORDER BY RPL.RowRef

                     SET @nLoopIndex = -1
                     WHILE 1 = 1
                     BEGIN
                        SELECT TOP 1 @nLoopIndex = RowRef 
                        FROM @tRDTPickLog 
                        WHERE RowRef > @nLoopIndex
                        ORDER BY RowRef

                        IF @@ROWCOUNT = 0
                           BREAK

                        BEGIN TRY
                           UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                           SET Status = '4'
                           WHERE RowRef = @nLoopIndex
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 255532
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update rdtPickLog failed
                           EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                           GOTO UPD_RDTMOBREC
                        END CATCH
                     END
                  END
                  SET @nAfterScn = 6777
                  SET @nAfterStep = 99
                  -- Prepare next screen var
                  SET @cOption = ''
                  SET @cOutField01 = '' -- Option

                  GOTO UPD_RDTMOBREC
               END

               -- EventLog   (yeekung05)
               EXEC RDT.rdt_STD_EventLog
                  @cActionType = '3', -- Picking
                  @cUserID     = @cUserName,
                  @nMobileNo   = @nMobile,
                  @nFunctionID = @nFunc,
                  @cFacility   = @cFacility,
                  @cStorerKey  = @cStorerKey,
                  @nStep       = @nStep,
                  @cLocation   = @cSuggLOC,
                  @cSKU        = @cSKU,
                  @nQTY        = @nActQTY,
                  @cDropID     = @cDropID,
                  @cPickSlipNo = @cPickSlipNo

               -- Save to ActQTY
               SET @nActQTY = @nQTY
               SET @cOutField07 = CAST( @nQTY AS NVARCHAR(6))

               -- SKU scanned, remain in current screen
               IF @cBarcode NOT IN ( '', '99')
               BEGIN
                  SET @cOutField05 = '' -- SKU
                  SET @cBarcode = ''
                  
                  IF @cDisableQTYField = '1'
                  BEGIN
                     -- Serial no SKU
                     IF @cSerialNoCapture IN ('1', '3')  -- 1 = INBOUND & OUTBOUND; 2 = INBOUND ONLY; 3 = OUTBOUND ONLY
                     BEGIN
                        -- Determine capture pattern
                        DECLARE @nScanSNO INT
                        IF @cSKUSerialNoCapture = '1' 
                        BEGIN
                           SET @nScanSNO = @nActQTY
                           SET @nTotalSNO = @nSuggQTY  -- For inbound & outbound, pattern = SKU -> SN->SN->SN...
                        END
                        ELSE
                        BEGIN
                           SET @nScanSNO = 0
                           SET @nTotalSNO = 1          -- For outbound only, pattern = SKU->SN -> SKU->SN -> SKU->SN...
                        END
                        
                        EXEC rdt.rdt_SerialNo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cSuggSKU, @cSKUDescr, @nTotalSNO, 'CHECK', 'PICKSLIP', @cPickSlipNo,
                           @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,
                           @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,
                           @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,
                           @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,
                           @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,
                           @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,
                           @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,
                           @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,
                           @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,
                           @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,
                           @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,
                           @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,
                           @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,
                           @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,
                           @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,
                           @nMoreSNO   OUTPUT,  @cSerialNo   OUTPUT,  @nSerialQTY   OUTPUT,
                           @nErrNo     OUTPUT,  @cErrMsg     OUTPUT,  @nScn = 0,
                           @nBulkSNO = 0,       @nBulkSNOQTY = 0,     @cSerialCaptureType = '3', 
                           @nScan    = @nScanSNO

                        IF @nErrNo <> 0
                           GOTO UPD_RDTMOBREC

                        IF @nMoreSNO = 1
                        BEGIN
                           -- Go to Serial No screen
                           SET @nAfterScn = @nScn_SerialNo
                           SET @nAfterStep = @nStep_SerialNo
                           GOTO UPD_RDTMOBREC
                        END
                     END

                     -- Non serial no SKU
                     EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                     IF @nActQTY <> @nSuggQTY AND @cDropIDScn = 'PickZoneScn'
                     BEGIN
                        IF @cFieldAttr07='O'
                           SET @cOutField07= CASE WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY ELSE @nActQTY END
                        ELSE
                           SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @cDefaultQTY ELSE '' END
                        --SET @cOutField13 =LTRIM(CAST((@nBalQty - CAST(@cOutField07 AS INT)) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6)) -- ZG01
                        SET @cOutField13 = CASE WHEN @nBalQty= 0 THEN  LTRIM(CAST((@nBalQty ) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))   ELSE LTRIM(CAST((@nBalQty - @nQTY) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))    END --(yeekung06)
                        GOTO UPD_RDTMOBREC
                     END
                  END
                  ELSE
                  BEGIN
                     IF @cDropIDScn = 'PickZoneScn'
                     BEGIN
                        --SET @cOutField07 = ''
                        SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6)) ELSE '' END -- QTY
                        SET @cOutField13 =LTRIM(CAST((@nBalQty - CAST(@cOutField07 AS INT)) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6)) -- ZG01
                        EXEC rdt.rdtSetFocusField @nMobile, 7 -- MQTY
                        GOTO UPD_RDTMOBREC
                     END
                  END
               END
               
               -- Get SKU info
               SELECT
                  @cSKUDataCapture = DataCapture
               FROM SKU WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND SKU = @cSuggSKU

               IF @nActQTY <> 0
               BEGIN
                  -- Custom data capture setup
                  SET @cDataCapture = ''
                  IF @cDataCaptureSP = ''
                  BEGIN
                     SET @cPackData1 = ''
                     SET @cPackData2 = ''
                     SET @cPackData3 = ''
                  END
                  ELSE
                  BEGIN
                     -- Get default data capture labels
                     SET @cPackLabel1 = ''
                     SET @cPackLabel2 = ''
                     SET @cPackLabel3 = ''
                     SELECT
                        @cPackLabel1 = UDF01,
                        @cPackLabel2 = UDF02,
                        @cPackLabel3 = UDF03
                     FROM dbo.CodeLKUP WITH (NOLOCK)
                     WHERE ListName = 'RDTDATALBL'
                        AND Storerkey = @cStorerKey
                        AND Code2 = @nFunc

                     SET @cPackAttr1 = CASE WHEN @cPackLabel1 = '' THEN'O' ELSE '' END
                     SET @cPackAttr2 = CASE WHEN @cPackLabel2 = '' THEN'O' ELSE '' END
                     SET @cPackAttr3 = CASE WHEN @cPackLabel3 = '' THEN'O' ELSE '' END

                     -- Custom SP to get data capture setup
                     IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDataCaptureSP AND type = 'P')
                     BEGIN
                        SET @cSQL = 'EXEC rdt.' + RTRIM( @cDataCaptureSP) +
                           ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +
                           ' @cPickSlipNo, @cPickZone, @cDropID, @cLOC, @cSKU, @nQTY, @cOption, @cLottableCode, ' +
                           ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                           ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                           ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                           ' @cPackData1   OUTPUT, @cPackData2  OUTPUT, @cPackData3  OUTPUT, ' +
                           ' @cPackLabel1  OUTPUT, @cPackLabel2 OUTPUT, @cPackLabel3 OUTPUT, ' +
                           ' @cPackAttr1   OUTPUT, @cPackAttr2  OUTPUT, @cPackAttr3  OUTPUT, ' +
                           ' @cDataCapture OUTPUT, @nErrNo      OUTPUT, @cErrMsg     OUTPUT  '
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
                           ',@cPackData1      NVARCHAR( 30)  OUTPUT ' +
                           ',@cPackData2      NVARCHAR( 30)  OUTPUT ' +
                           ',@cPackData3      NVARCHAR( 30)  OUTPUT ' +
                           ',@cPackLabel1     NVARCHAR( 20)  OUTPUT ' +
                           ',@cPackLabel2     NVARCHAR( 20)  OUTPUT ' +
                           ',@cPackLabel3     NVARCHAR( 20)  OUTPUT ' +
                           ',@cPackAttr1      NVARCHAR( 1)   OUTPUT ' +
                           ',@cPackAttr2      NVARCHAR( 1)   OUTPUT ' +
                           ',@cPackAttr3      NVARCHAR( 1)   OUTPUT ' +
                           ',@cDataCapture    NVARCHAR( 1)   OUTPUT ' +
                           ',@nErrNo          INT            OUTPUT ' +
                           ',@cErrMsg         NVARCHAR( 20)  OUTPUT  '

                        EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                           @nMobile, @nFunc, @cLangCode,@nStep, @nInputKey, @cFacility, @cStorerKey,
                           @cPickSlipNo, @cPickZone, @cDropID, @cSuggLOC, @cSuggSKU, @nQTY, @cOption, @cLottableCode,
                           @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                           @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                           @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                           @cPackData1   OUTPUT, @cPackData2  OUTPUT, @cPackData3  OUTPUT,
                           @cPackLabel1  OUTPUT, @cPackLabel2 OUTPUT, @cPackLabel3 OUTPUT,
                           @cPackAttr1   OUTPUT, @cPackAttr2  OUTPUT, @cPackAttr3  OUTPUT,
                           @cDataCapture OUTPUT, @nErrNo      OUTPUT, @cErrMsg     OUTPUT

                        IF @nErrNo <> 0
                           GOTO UPD_RDTMOBREC
                     END
                     ELSE
                     BEGIN
                        -- Setup is non SP
                        SET @cDataCapture = @cDataCaptureSP
                        SET @cPackData1 = ''
                        SET @cPackData2 = ''
                        SET @cPackData3 = ''

                        EXEC rdt.rdtSetFocusField @nMobile, 1 -- PackData1
                     END

                     -- Capture data
                     IF @cDataCapture = '1'
                     BEGIN
                        -- SKU need data capture
                        IF @cSKUDataCapture IN ('1', '3') -- 1=Inbound and outbound, 3=outbound only
                        BEGIN
                           -- Prepare next screen var
                           SET @cOutField01 = @cPackLabel1
                           SET @cOutField02 = @cPackData1
                           SET @cOutField03 = @cPackLabel2
                           SET @cOutField04 = @cPackData2
                           SET @cOutField05 = @cPackLabel3
                           SET @cOutField06 = @cPackData3

                           --(yeekung01)
                           SET @cFieldAttr02 = @cPackAttr1
                           SET @cFieldAttr04 = @cPackAttr2
                           SET @cFieldAttr06 = @cPackAttr3

                           -- Go to capture data screen
                           SET @nFromScn = @nScn
                           SET @nFromStep = @nStep

                           SET @nAfterScn = @nScn_DataCapture
                           SET @nAfterStep = @nStep_DataCapture

                           GOTO UPD_RDTMOBREC
                        END
                     END
                  END
               END

               -- EventLog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType = '3', -- Picking
                  @cUserID     = @cUserName,
                  @nMobileNo   = @nMobile,
                  @nFunctionID = @nFunc,
                  @cFacility   = @cFacility,
                  @cStorerKey  = @cStorerKey,
                  @nStep       = @nStep,
                  @cLocation   = @cSuggLOC,
                  @cSKU        = @cSKU,
                  @nQTY        = @nActQTY,
                  @cSerialNo   = @cScannedSN,
                  @cUCC        = @cScannedUCC,
                  @cDropID     = @cDropID,
                  @cPickSlipNo = @cPickSlipNo

               IF @cDropIDScn = 'PickZoneScn'
               BEGIN
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
                        GOTO UPD_RDTMOBREC

                     STEP_SKUQTY_GETNEXT:
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
                        ,@cSKUSerialNoCapture OUTPUT
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

                        IF @cScanCIDSCN = '1'
                        BEGIN
                           -- Prepare next screen var
                           SET @cOutField01 = @cSuggLOC
                           SET @cOutField04 = @cSuggID --(yeekung02)
                           SET @cOutField05 = ''

                           -- Go to verify ID screen
                           SET @nAfterScn = @nScn_VerifyID
                           SET @nAfterStep = @nStep_VerifyID
                           GOTO UPD_RDTMOBREC
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
                        
                        SET @cBarcode = ''

                        SELECT TOP 1 @cSuggUCC  = Descr
                        FROM rdt.rdtPickLog WITH(NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND Mobile = @nMobile
                           AND AddWho = @cUserName
                           AND PickMethod = 'GetTask-U'
                           AND Status = '0'
                        ORDER BY AddDate DESC

                        SELECt @nRowCount = @@ROWCOUNT

                        -- Display UCC
                        IF @nRowCount > 0
                        BEGIN
                           SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                           SET @cOutField08 = 'UCC:'
                           SET @cOutField09 = @cSuggUCC
                           SET @cOutField10 = 'LOT:'
                           SET @cOutField11 = @cSuggLOT
                        END
                        ELSE
                        -- Display Piece info, Lottable01, UOM, UOM Desc
                        BEGIN
                           SELECT TOP 1 @cSuggLOT  = Descr
                           FROM rdt.rdtPickLog WITH(NOLOCK)
                           WHERE PickSlipNo = @cPickSlipNo
                              AND Mobile = @nMobile
                              AND AddWho = @cUserName
                              AND PickMethod = 'GetTask-P'
                              AND Status = '0'
                           ORDER BY AddDate DESC
                           
                           SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                           SELECT
                              @cPackUOM = Pack.PackUOM3
                           FROM dbo.SKU S WITH (NOLOCK)
                           INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                           WHERE StorerKey = @cStorerKey
                              AND SKU = @cSuggSKU

                           SET @cOutField08 = ISNULL(@cLottable01, '')
                           SET @cOutField09 = 'UOM: 6'
                           SET @cOutField10 = @cPackUOM
                           SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
                        END
                        
                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
                     END
                     ELSE
                     BEGIN
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
                           ,@cSKUSerialNoCapture OUTPUT
                        IF @nErrNo = 0
                        BEGIN
                           IF @cConfirmLOC = '1'
                           BEGIN
                              -- Prepare next screen var
                              SET @cOutField01 = @cSuggLOC
                              SET @cOutField02 = '' -- LOC

                              -- Go to confirm LOC screen
                              SET @nAfterScn = @nScn_ConfirmLOC
                              SET @nAfterStep = @nStep_ConfirmLOC
                              GOTO UPD_RDTMOBREC
                           END
                           ELSE IF @cScanCIDSCN='1'
                           BEGIN
                              -- Prepare next screen var
                              SET @cOutField01 = @cSuggLOC
                              SET @cOutField04 = @cSuggID --(yeekung02)
                              SET @cOutField05 = ''

                              -- Go to verify ID screen
                              SET @nAfterScn = @nScn_VerifyID
                              SET @nAfterStep = @nStep_VerifyID
                              GOTO UPD_RDTMOBREC

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
                              
                              SET @cBarcode = ''

                              SELECT TOP 1 @cSuggUCC  = Descr
                              FROM rdt.rdtPickLog WITH(NOLOCK)
                              WHERE PickSlipNo = @cPickSlipNo
                                 AND Mobile = @nMobile
                                 AND AddWho = @cUserName
                                 AND PickMethod = 'GetTask-U'
                                 AND Status = '0'
                              ORDER BY AddDate DESC

                              SELECt @nRowCount = @@ROWCOUNT

                              -- Display UCC
                              IF @nRowCount > 0
                              BEGIN
                                 SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                                 SET @cOutField08 = 'UCC:'
                                 SET @cOutField09 = @cSuggUCC
                                 SET @cOutField10 = 'LOT:'
                                 SET @cOutField11 = @cSuggLOT
                              END
                              ELSE
                              -- Display Piece info, Lottable01, UOM, UOM Desc
                              BEGIN
                                 SELECT TOP 1 @cSuggLOT  = Descr
                                 FROM rdt.rdtPickLog WITH(NOLOCK)
                                 WHERE PickSlipNo = @cPickSlipNo
                                    AND Mobile = @nMobile
                                    AND AddWho = @cUserName
                                    AND PickMethod = 'GetTask-P'
                                    AND Status = '0'
                                 ORDER BY AddDate DESC
                                 
                                 SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                                 SELECT
                                    @cPackUOM = Pack.PackUOM3
                                 FROM dbo.SKU S WITH (NOLOCK)
                                 INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                                 WHERE StorerKey = @cStorerKey
                                    AND SKU = @cSuggSKU

                                 SET @cOutField08 = ISNULL(@cLottable01, '')
                                 SET @cOutField09 = 'UOM: 6'
                                 SET @cOutField10 = @cPackUOM
                                 SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
                              END
                              
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
                              ,@cSKUSerialNoCapture OUTPUT
                           IF @nErrNo =  0
                           BEGIN
                              -- Reset here, next screen will fetch task again
                              SET @cCurrLOC = ''
                              SET @cSuggLOC = ''

                              -- Prepare next screen var
                              SET @cOutField01 = @cPickSlipNo -- '' -- PickSlipNo
                              SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END
                              SET @cOutField03 = ''
                              SET @cOutField15 = ''

                              -- Go to PickSlipNo screen
                              SET @nAfterScn = @nScn_PickZone
                              SET @nAfterStep = @nStep_PickZone
                           END
                           ELSE
                           BEGIN
                              IF EXISTS( SELECT 1 FROM rdt.rdtPickLog WITH(NOLOCK) 
                                          WHERE PickSlipNo = @cPickSlipNo
                                             AND Mobile = @nMobile
                                             AND AddWho = @cUserName)
                              BEGIN
                                 -- No more task, complete pick slip
                                 SET @nAfterScn = 6828
                                 SET @nAfterStep = 99
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
                                    GOTO UPD_RDTMOBREC

                                 -- Prepare next screen var
                                 SET @cOutField01 = '' -- PickSlipNo

                                 -- Go to PickSlipNo screen
                                 SET @nAfterScn = @nScn_PickSlipNo
                                 SET @nAfterStep = @nStep_PickSlipNo
                              END
                           END
                           GOTO UPD_RDTMOBREC
                        END
                        GOTO UPD_RDTMOBREC
                     END
                  END
                  GOTO UPD_RDTMOBREC
               END
               ELSE IF @cDropIDScn = 'ToIDScn'
               BEGIN
                  SET @nAfterScn = 6775
                  SET @nAfterStep = 99

                  DECLARE @suggestedDropID NVARCHAR( 20)

                  SELECT TOP 1 @suggestedDropID = DropID
                  FROM RDT.rdtPickLog WITH(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND Mobile = @nMobile
                     AND AddWho = @cUserName
                     AND DropID <> ''
                     AND OrderKey = @cCurrentOrderKey

                  SET @cOutField01 = ISNULL(@suggestedDropID, '')
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''

                  SET @cDropID = ISNULL(@suggestedDropID, '')

                  EXEC rdt.rdtSetFocusField @nMobile, 2 -- SKU
                  GOTO UPD_RDTMOBREC
               END
               GOTO UPD_RDTMOBREC
            END
            ELSE IF @nInputKey = 0
            BEGIN
               SET @nPre_Step = @nStep_SKUQTY
               SET @nFromStep = @nStep_SKUQTY
               SET @nFromScn = @nScn_SKUQTY

               SET @cOutField01 = '' -- Option
               SET @cOutField12 =''
               SET @cOutField15 =''

               -- Go to Abort screen
               SET @nAfterScn = 6840
               SET @nAfterStep = 99
               GOTO UPD_RDTMOBREC
            END
         END
         /********************************************************************************
         Scn = 6775. To ID screen
            To ID             (field01)
            To ID             (field02, input)
            Close DropID?     (field03, input)
         ********************************************************************************/
         ELSE IF @nCurrentScn = 6775
         BEGIN
            SET @cUDF01 = 'No Need Update RDTMOBREC'

            SELECT @cSuggUCC = C_String1,
               @cSuggLOT = C_String2,
               @cScannedUCC = C_String3,
               @cScannedSN = C_String7
            FROM rdt.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile

            DECLARE @cScannedUCCorSNQty   INT
            DECLARE @cPickDetailKeyRollback NVARCHAR(18)
            DECLARE @cPickDetailType NVARCHAR(10)

            IF @nInputKey = 1
            BEGIN
               SET @cOption = ISNULL(TRIM(@cInField05), '')

               IF @cOption <> '' AND @cOption <> '1'
               BEGIN
                  SET @nErrNo = 255513
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO UPD_RDTMOBREC
               END

               DECLARE @cScannedDropID NVARCHAR(20)
               SET @cScannedDropID = @cInField02

               IF @cOption = '1'
               BEGIN
                  SET @cCloseDropIDFlag = 'Y'
                  IF @cScannedDropID = ''
                  BEGIN
                     SET @cOutField05 = '1'
                     EXEC rdt.rdtSetFocusField @nMobile, 2 -- SKU
                     
                     GOTO UPD_RDTMOBREC
                  END
                  ELSE
                  BEGIN
                     GOTO VALID_DROPID
                  END
               END
               ELSE 
                  SET @cCloseDropIDFlag = 'N'

               VALID_DROPID:
               IF ISNULL(@cScannedDropID, '') = ''
               BEGIN
                  SET @nErrNo = 255511
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToID is needed
                  GOTO UPD_RDTMOBREC
               END

               IF @cDropID = '' AND @cScannedDropID <> ''
                  AND EXISTS (
                     SELECT 1
                     FROM RDT.rdtPickLog WITH(NOLOCK)
                     WHERE DropID = @cScannedDropID
                  )
               BEGIN
                  SET @nErrNo = 255530
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DropID is in use
                  GOTO UPD_RDTMOBREC
               END
               

               IF @cDropID <> '' AND @cScannedDropID <> @cDropID
               BEGIN
                  SET @nErrNo = 255512
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ToID does not match
                  GOTO UPD_RDTMOBREC
               END

               SET @cDropID = @cScannedDropID

               SELECT @cRowRefTemp = RowRef
               FROM RDT.rdtPickLog WITH(NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
                  AND Mobile = @nMobile
                  AND AddWho = @cUserName
                  AND ISNULL(Remarks, '') = IIF(@cUOM = '2', @cSuggUCC, @cScannedSN)
                  AND OrderKey = @cCurrentOrderKey

               UPDATE rdt.rdtPickLog WITH(ROWLOCK)
               SET DropID = @cDropID
               WHERE RowRef = @cRowRefTemp

               IF @cCloseDropIDFlag = 'Y'
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
                     GOTO UPD_RDTMOBREC

                  -- Need clear dropid
                  SET @cDropID = ''
               END
               ELSE
               BEGIN
                  IF @nActQTY < @nSuggQTY
                  BEGIN
                     SET @nAfterStep = 99
                     SET @nAfterScn = 6774
                     

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

                     SET @cOutField13 = LTRIM(CAST((@nBalQty - @nActQTY) AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6)) 

                     GOTO UPD_RDTMOBREC
                  END
               END

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
                  ,@cSKUSerialNoCapture OUTPUT
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

                  IF @cScanCIDSCN = '1'
                  BEGIN
                     -- Prepare next screen var
                     SET @cOutField01 = @cSuggLOC
                     SET @cOutField04 = @cSuggID --(yeekung02)
                     SET @cOutField05 = ''

                     -- Go to verify ID screen
                     SET @nAfterScn = @nScn_VerifyID
                     SET @nAfterStep = @nStep_VerifyID
                     GOTO UPD_RDTMOBREC
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
                  
                  SET @cBarcode = ''

                  SELECT TOP 1 @cSuggUCC  = Descr
                  FROM rdt.rdtPickLog WITH(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND Mobile = @nMobile
                     AND AddWho = @cUserName
                     AND PickMethod = 'GetTask-U'
                     AND Status = '0'
                  ORDER BY AddDate DESC

                  SELECt @nRowCount = @@ROWCOUNT
                  -- Display UCC
                  IF @nRowCount > 0
                  BEGIN
                     SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                     SET @cOutField08 = 'UCC:'
                     SET @cOutField09 = @cSuggUCC
                     SET @cOutField10 = 'LOT:'
                     SET @cOutField11 = @cSuggLOT

                     UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                     SET C_String6 = '2'
                     WHERE Mobile = @nMobile
                  END
                  ELSE
                  -- Display Piece info, Lottable01, UOM, UOM Desc
                  BEGIN
                     SELECT TOP 1 @cSuggLOT  = Descr
                     FROM rdt.rdtPickLog WITH(NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND Mobile = @nMobile
                        AND AddWho = @cUserName
                        AND PickMethod = 'GetTask-P'
                        AND Status = '0'
                     ORDER BY AddDate DESC
                     
                     SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                     SELECT
                        @cPackUOM = Pack.PackUOM3
                     FROM dbo.SKU S WITH (NOLOCK)
                     INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                     WHERE StorerKey = @cStorerKey
                        AND SKU = @cSuggSKU

                     SET @cOutField08 = ISNULL(@cLottable01, '')
                     SET @cOutField09 = 'UOM: 6'
                     SET @cOutField10 = @cPackUOM
                     SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))

                     UPDATE rdt.RDTMOBREC WITH(ROWLOCK)
                     SET C_String6 = '6'
                     WHERE Mobile = @nMobile
                  END

                  SET @nAfterStep = 99
                  SET @nAfterScn = 6774
                  
                  EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
               END
               ELSE
               BEGIN
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
                     ,@cSKUSerialNoCapture OUTPUT
                  IF @nErrNo = 0
                  BEGIN
                     IF @cConfirmLOC = '1'
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cSuggLOC
                        SET @cOutField02 = '' -- LOC

                        -- Go to confirm LOC screen
                        SET @nAfterScn = @nScn_ConfirmLOC
                        SET @nAfterStep = @nStep_ConfirmLOC
                        GOTO UPD_RDTMOBREC
                     END
                     ELSE IF @cScanCIDSCN='1'
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cSuggLOC
                        SET @cOutField04 = @cSuggID --(yeekung02)
                        SET @cOutField05 = ''

                        -- Go to verify ID screen
                        SET @nAfterScn = @nScn_VerifyID
                        SET @nAfterStep = @nStep_VerifyID
                        GOTO UPD_RDTMOBREC

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
                        
                        SET @cBarcode = ''

                        SELECT TOP 1 @cSuggUCC  = Descr
                        FROM rdt.rdtPickLog WITH(NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND Mobile = @nMobile
                           AND AddWho = @cUserName
                           AND PickMethod = 'GetTask-U'
                           AND Status = '0'
                        ORDER BY AddDate DESC

                        SELECt @nRowCount = @@ROWCOUNT

                        -- Display UCC
                        IF @nRowCount > 0
                        BEGIN
                           SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                           SET @cOutField08 = 'UCC:'
                           SET @cOutField09 = @cSuggUCC
                           SET @cOutField10 = 'LOT:'
                           SET @cOutField11 = @cSuggLOT
                        END
                        ELSE
                        -- Display Piece info, Lottable01, UOM, UOM Desc
                        BEGIN
                           SELECT TOP 1 @cSuggLOT  = Descr
                           FROM rdt.rdtPickLog WITH(NOLOCK)
                           WHERE PickSlipNo = @cPickSlipNo
                              AND Mobile = @nMobile
                              AND AddWho = @cUserName
                              AND PickMethod = 'GetTask-P'
                              AND Status = '0'
                           ORDER BY AddDate DESC
                           
                           SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                           SELECT
                              @cPackUOM = Pack.PackUOM3
                           FROM dbo.SKU S WITH (NOLOCK)
                           INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                           WHERE StorerKey = @cStorerKey
                              AND SKU = @cSuggSKU

                           SET @cOutField08 = ISNULL(@cLottable01, '')
                           SET @cOutField09 = 'UOM: 6'
                           SET @cOutField10 = @cPackUOM
                           SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
                        END

                        SET @nAfterScn = 6774
                        SET @nAfterStep = 99
                        
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
                        ,@cSKUSerialNoCapture OUTPUT
                     IF @nErrNo =  0
                     BEGIN
                        -- Reset here, next screen will fetch task again
                        SET @cCurrLOC = ''
                        SET @cSuggLOC = ''

                        -- Prepare next screen var
                        SET @cOutField01 = @cPickSlipNo -- '' -- PickSlipNo
                        SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END
                        SET @cOutField03 = ''
                        SET @cOutField15 = ''

                        -- Go to PickSlipNo screen
                        SET @nAfterScn = @nScn_PickZone
                        SET @nAfterStep = @nStep_PickZone
                     END
                     ELSE
                     BEGIN
                        -- Go to No More Task screen
                        SET @nAfterScn = 6828
                        SET @nAfterStep = 99
                     END
                  END
               END
               GOTO UPD_RDTMOBREC
            END
            ELSE IF @nInputKey = 0
            BEGIN
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
               SET @cOutField13 = LTRIM(CAST(@nBalQty - @nActQty AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))

               IF @cFieldAttr07='O'
                  SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))
                                       WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY
                                       ELSE @nActQTY END -- QTY
               ELSE
                  SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END
               
               SET @cBarcode = ''

               SELECT TOP 1 @cSuggUCC  = Descr
               FROM rdt.rdtPickLog WITH(NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
                  AND Mobile = @nMobile
                  AND AddWho = @cUserName
                  AND PickMethod = 'GetTask-U'
                  AND Status = '0'
               ORDER BY AddDate DESC

               SELECt @nRowCount = @@ROWCOUNT

               -- Display UCC
               IF @nRowCount > 0
               BEGIN
                  SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                  SET @cOutField08 = 'UCC:'
                  SET @cOutField09 = @cSuggUCC
                  SET @cOutField10 = 'LOT:'
                  SET @cOutField11 = @cSuggLOT
               END
               ELSE
               -- Display Piece info, Lottable01, UOM, UOM Desc
               BEGIN
                  SELECT TOP 1 @cSuggLOT  = Descr
                  FROM rdt.rdtPickLog WITH(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND Mobile = @nMobile
                     AND AddWho = @cUserName
                     AND PickMethod = 'GetTask-P'
                     AND Status = '0'
                  ORDER BY AddDate DESC
                  
                  SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                  SELECT
                     @cPackUOM = Pack.PackUOM3
                  FROM dbo.SKU S WITH (NOLOCK)
                  INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                  WHERE StorerKey = @cStorerKey
                     AND SKU = @cSuggSKU

                  SET @cOutField08 = ISNULL(@cLottable01, '')
                  SET @cOutField09 = 'UOM: 6'
                  SET @cOutField10 = @cPackUOM
                  SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
               END
               
               EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU

               -- Go to SKU/Qty screen
               SET @nAfterScn = 6774
               SET @nAfterStep = 99

               SET @cCloseDropIDFlag = 'N'

               SELECT TOP 1 
                  @cPickDetailKeyRollback = PickDetailKey,
                  @cPickDetailType = PickMethod,
                  @cRowRefTemp = RowRef,
                  @cScannedUCCorSNQty = ActQty,
                  @cRemarks = Remarks
               FROM RDT.rdtPickLog WITH(NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
                  AND Mobile = @nMobile
                  AND AddWho = @cUserName
                  AND Remarks = IIF( @cUOM = '2', @cScannedUCC, @cScannedSN)

               IF @@ROWCOUNT > 0
               BEGIN
                  IF @cPickDetailType = 'GetTask-U'
                  BEGIN
                     BEGIN TRY
                        UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                        SET Status = '0',
                           PickLockQty = PickLockQty - @nSuggQTY,
                           Remarks = ''
                        WHERE RowRef = @cRowRefTemp
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255520
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update rdtPickLog failed
                        GOTO UPD_RDTMOBREC
                     END CATCH
                  END
                  ELSE
                  BEGIN
                     IF @cPickDetailType = 'GetTask-P'
                     BEGIN
                        BEGIN TRY
                           UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                           SET Status = '0',
                              PickLockQty = PickLockQty - 1,
                              Remarks = ''
                           WHERE RowRef = @cRowRefTemp
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 255521
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update rdtPickLog failed
                           GOTO UPD_RDTMOBREC
                        END CATCH

                        SELECT TOP 1 @cRowRefTemp = RowRef,
                           @cRemarks = Remarks
                        FROM RDT.rdtPickLog WITH(NOLOCK)
                        WHERE PickDetailKey =  @cPickDetailKeyRollback
                           AND PickSlipNo = @cPickSlipNo
                           AND Mobile = @nMobile
                           AND AddWho = @cUserName
                           AND Remarks = @cScannedUCC
                           AND PickMethod = 'Pick-P'

                        BEGIN TRY
                           DELETE FROM RDT.rdtPickLog
                           WHERE RowRef = @cRowRefTemp
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 255522
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete rdtPickLog failed
                           GOTO UPD_RDTMOBREC
                        END CATCH

                        BEGIN TRY
                           UPDATE dbo.SerialNo WITH(ROWLOCK)
                           SET UserDefine01 = '0'
                           WHERE SerialNo = @cRemarks
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 255538
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update SerialNo failed
                           GOTO UPD_RDTMOBREC
                        END CATCH
                     END
                     ELSE IF @cPickDetailType = 'Pick-P'
                     BEGIN
                        BEGIN TRY
                           DELETE FROM RDT.rdtPickLog
                           WHERE RowRef = @cRowRefTemp
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 255523
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete rdtPickLog failed
                           GOTO UPD_RDTMOBREC
                        END CATCH

                        BEGIN TRY
                           UPDATE dbo.SerialNo WITH(ROWLOCK)
                           SET UserDefine01 = '0'
                           WHERE SerialNo = @cRemarks
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 255539
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update SerialNo failed
                           GOTO UPD_RDTMOBREC
                        END CATCH

                        SELECT TOP 1 @cRowRefTemp = RowRef
                        FROM RDT.rdtPickLog WITH(NOLOCK)
                        WHERE PickDetailKey =  @cPickDetailKeyRollback
                           AND PickSlipNo = @cPickSlipNo
                           AND Mobile = @nMobile
                           AND AddWho = @cUserName
                           AND PickMethod = 'GetTask-P'

                        BEGIN TRY
                           UPDATE RDT.rdtPickLog WITH(ROWLOCK)
                           SET Status = '0',
                              PickLockQty = PickLockQty - 1,
                              Remarks = ''
                           WHERE RowRef = @cRowRefTemp
                        END TRY
                        BEGIN CATCH
                           SET @nErrNo = 255524
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update rdtPickLog failed
                           GOTO UPD_RDTMOBREC
                        END CATCH
                     END
                     SET @cScannedUCCorSNQty = 1
                  END

                  SET @nActQTY = @nActQTY - @cScannedUCCorSNQty

                  GOTO UPD_RDTMOBREC
               END

               GOTO UPD_RDTMOBREC
            END
         END
         /********************************************************************************
         Scn = 6828. No More Task screen
            To ID             (field01)
            Close DropID
            Close all Drop ID
         ********************************************************************************/
         ELSE IF @nCurrentScn = 6828
         BEGIN
            IF @nInputKey = 1
            BEGIN
               EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CONFIRM'
                     ,@cPickSlipNo
                     ,@cPickZone
                     ,'ALLDROPID'
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
                     GOTO Quit

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
               SET @nAfterScn = @nScn_PickSlipNo
               SET @nAfterStep = @nStep_PickSlipNo
               GOTO Quit
            END
            ELSE
            BEGIN
               SET @nErrNo = 255525
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Press Enter to continue
               GOTO Quit
            END
         END
         /********************************************************************************
         Scn = 6777. Short pick screen
            CONFIRM OPTION?
            1 = SHORT
            2 = BAL PICK LATER
            OPTION:        (field01)
         ********************************************************************************/
         ELSE IF @nCurrentScn = 6777
         BEGIN
            IF @nInputKey = 1
            BEGIN
               -- Screen mapping
               SET @cOption = @cInField01

               -- Validate blank
               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 255526
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Option required
                  GOTO Quit
               END

               -- Validate option
               IF @cOption <> '1' AND
                  @cOption <> '2'
               BEGIN
                  SET @nErrNo = 255527
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option
                  GOTO Quit
               END
               
               IF @cOption = '1'
               BEGIN
                  SET @nAfterScn = 6773
                  SET @nAfterStep = 99

                  SET @cOutField01 = '' --Reason Code
                  GOTO Quit
               END
               ELSE IF @cOption = '2'
               BEGIN
                  --Do nthing, just pick later and go to get task
                  -- Prepare next screen var

                  PRINT 'DO Nothing'

                  -- EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CLOSE',
                  --    @cPickSlipNo
                  --    ,@cPickZone
                  --    ,'ALLDROPID'
                  --    ,@cSuggLOC
                  --    ,@cSuggSKU
                  --    ,0
                  --    ,@cLottableCode
                  --    ,@cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05
                  --    ,@cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10
                  --    ,@cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15
                  --    ,@cPackData1,  @cPackData2,  @cPackData3
                  --    ,@cSuggID
                  --    ,@cSerialNo   = '' 
                  --    ,@nSerialQTY  = 0
                  --    ,@nBulkSNO    = 0
                  --    ,@nBulkSNOQTY = 0
                  --    ,@nErrNo      = @nErrNo  OUTPUT
                  --    ,@cErrMsg     = @cErrMsg OUTPUT

                  -- IF @nErrNo <> 0
                  -- BEGIN
                  --    GOTO Quit
                  -- END
               END

               -- Get task in same LOC
               SET @cSKUValidated = '0'
               SET @nActQTY = 0
               SET @cSuggSKU = @cCurrSKU
               SET @cSkippedSKU = @cCurrSKU
               EXEC rdt.rdt_PickPiece_GetTask @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'BALPICK'
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
                  ,@cSKUSerialNoCapture OUTPUT
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

                  -- Disable QTY field
                  SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY

                  IF @cFieldAttr07='O'
                     SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))
                                             WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY
                                             ELSE @nActQTY END -- QTY
                  ELSE
                     SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END

                  SET @cBarcode = ''

                  SELECT TOP 1 @cSuggUCC  = Descr
                  FROM rdt.rdtPickLog WITH(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                     AND Mobile = @nMobile
                     AND AddWho = @cUserName
                     AND PickMethod = 'GetTask-U'
                     AND Status = '0'
                  ORDER BY AddDate DESC

                  SELECt @nRowCount = @@ROWCOUNT

                  -- Display UCC
                  IF @nRowCount > 0
                  BEGIN
                     SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                     SET @cOutField08 = 'UCC:'
                     SET @cOutField09 = @cSuggUCC
                     SET @cOutField10 = 'LOT:'
                     SET @cOutField11 = @cSuggLOT
                  END
                  ELSE
                  -- Display Piece info, Lottable01, UOM, UOM Desc
                  BEGIN
                     SELECT TOP 1 @cSuggLOT  = Descr
                     FROM rdt.rdtPickLog WITH(NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND Mobile = @nMobile
                        AND AddWho = @cUserName
                        AND PickMethod = 'GetTask-P'
                        AND Status = '0'
                     ORDER BY AddDate DESC
                     
                     SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                     SELECT
                        @cPackUOM = Pack.PackUOM3
                     FROM dbo.SKU S WITH (NOLOCK)
                     INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                     WHERE StorerKey = @cStorerKey
                        AND SKU = @cSuggSKU

                     SET @cOutField08 = ISNULL(@cLottable01, '')
                     SET @cOutField09 = 'UOM: 6'
                     SET @cOutField10 = @cPackUOM
                     SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
                  END
                  
                  EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU

                  -- Go to SKU QTY screen
                  SET @nAfterScn = 6774
                  SET @nAfterStep = 99
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
                     ,@cSKUSerialNoCapture OUTPUT
                  IF @nErrNo = 0
                  BEGIN
                     IF @cConfirmLOC = '1'
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cSuggLOC
                        SET @cOutField02 = '' -- LOC

                        -- Go to confirm LOC screen
                        SET @nAfterScn = @nScn_ConfirmLOC
                        SET @nAfterStep = @nStep_ConfirmLOC
                        GOTO Quit
                     END
                     ELSE IF @cScanCIDSCN='1'
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cSuggLOC
                        SET @cOutField04 = @cSuggID --(yeekung02)
                        SET @cOutField05 = ''

                        -- Go to verify ID screen
                        SET @nAfterScn = @nScn_VerifyID
                        SET @nAfterStep = @nStep_VerifyID
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
                           SET @cOutField01 = @cSuggLOC
                           SET @cOutField04 = @cSuggID --(yeekung02)
                           SET @cOutField05 = ''

                           -- Go to verify ID screen
                           SET @nAfterScn = @nScn_VerifyID
                           SET @nAfterStep = @nStep_VerifyID
                           GOTO Quit
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

                        -- Disable QTY field
                        SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY    (yeekung03)


                        IF @cFieldAttr07='O'
                           SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN CAST( @nSuggQTY AS NVARCHAR(6))
                                                   WHEN @cDefaultPickQTY <> '0' THEN @cDefaultPickQTY
                                                   ELSE @nActQTY END -- QTY
                        ELSE
                           SET @cOutField07= CASE WHEN @cDefaultQTY = '1' THEN @nSuggQTY ELSE '' END

                        SET @cBarcode = ''

                        SELECT TOP 1 @cSuggUCC  = Descr
                        FROM rdt.rdtPickLog WITH(NOLOCK)
                        WHERE PickSlipNo = @cPickSlipNo
                           AND Mobile = @nMobile
                           AND AddWho = @cUserName
                           AND PickMethod = 'GetTask-U'
                           AND Status = '0'
                        ORDER BY AddDate DESC

                        SELECt @nRowCount = @@ROWCOUNT

                        -- Display UCC
                        IF @nRowCount > 0
                        BEGIN
                           SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

                           SET @cOutField08 = 'UCC:'
                           SET @cOutField09 = @cSuggUCC
                           SET @cOutField10 = 'LOT:'
                           SET @cOutField11 = @cSuggLOT
                        END
                        ELSE
                        -- Display Piece info, Lottable01, UOM, UOM Desc
                        BEGIN
                           SELECT TOP 1 @cSuggLOT  = Descr
                           FROM rdt.rdtPickLog WITH(NOLOCK)
                           WHERE PickSlipNo = @cPickSlipNo
                              AND Mobile = @nMobile
                              AND AddWho = @cUserName
                              AND PickMethod = 'GetTask-P'
                              AND Status = '0'
                           ORDER BY AddDate DESC
                           
                           SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

                           SELECT
                              @cPackUOM = Pack.PackUOM3
                           FROM dbo.SKU S WITH (NOLOCK)
                           INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
                           WHERE StorerKey = @cStorerKey
                              AND SKU = @cSuggSKU

                           SET @cOutField08 = ISNULL(@cLottable01, '')
                           SET @cOutField09 = 'UOM: 6'
                           SET @cOutField10 = @cPackUOM
                           SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
                        END

                        EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU

                        -- Go to SKU QTY screen
                        SET @nAfterScn = 6774
                        SET @nAfterStep = 99
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
                        ,@cSKUSerialNoCapture OUTPUT
                     IF @nErrNo =  0
                     BEGIN
                        -- Prepare next screen var
                        SET @cOutField01 = @cPickSlipNo -- '' -- PickSlipNo
                        SET @cOutField02 = CASE WHEN @cDefaultPickZone = '1' THEN @cPickZone ELSE '' END
                        SET @cOutField03 = ''
                        SET @cOutField15 = ''

                        -- Go to PickZone screen
                        SET @nAfterScn = @nScn_PickZone
                        SET @nAfterStep = @nStep_PickZone
                        GOTO Quit
                     END
                     ELSE
                     BEGIN
                        IF @cOption = '2' AND EXISTS (
                                                      SELECT 1
                                                      FROM rdt.rdtPickLog WITH(NOLOCK)
                                                      WHERE PickSlipNo = @cPickSlipNo
                                                         AND Mobile = @nMobile
                                                         AND AddWho = @cUserName
                                                         AND Status IN ( '0', '4')
                                                   )
                        BEGIN
                           -- Prepare next screen var
                           SET @cOutField01 = '' -- PickSlipNo

                           -- Go to No More Task, Close All DropID screen
                           SET @nAfterScn = 6828
                           SET @nAfterStep = 99
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
                           SET @nAfterScn = @nScn_PickSlipNo
                           SET @nAfterStep = @nStep_PickSlipNo

                           GOTO Quit
                        END
                     END
                  END
               END
            END
            ELSE IF @nInputKey = 0
            BEGIN
                -- Prepare SKU QTY screen var
               SET @cOutField01 = @cSuggLOC
               SET @cOutField02 = @cSuggSKU
               SET @cOutField03 = rdt.rdtFormatString( @cSKUDescr, 1, 20)  -- SKU desc 1
               SET @cOutField04 = rdt.rdtFormatString( @cSKUDescr, 21, 20) -- SKU desc 2
               SET @cOutField05 = '' -- SKU/UPC
               SET @cOutField06 = RTRIM(CAST( @nSuggQTY AS NVARCHAR(6)))
               SET @cOutField07 = CAST( @nActQTY AS NVARCHAR(6))
               SET @cOutField13 =LTRIM(CAST(@nBalQty - @nActQTY AS NVARCHAR(6))) + '/' + CAST(@nTtlBalQty AS NVARCHAR(6))

               -- Disable QTY field
               SET @cFieldAttr07 = CASE WHEN @cDisableQTYField = '1' THEN 'O' ELSE '' END -- QTY

               SET @cBarcode = ''
               
               IF @cFieldAttr07 = 'O'
                  EXEC rdt.rdtSetFocusField @nMobile, 5 -- SKU
               ELSE
                  EXEC rdt.rdtSetFocusField @nMobile, 7 -- QTY

               -- Go to SKU QTY screen
               SET @nAfterScn = 6774
               SET @nAfterStep = 99
            END
         END
         /********************************************************************************
         Scn = 6840. Abort pick screen
            CONFIRM OPTION?
            1 = Yes
            2 = No
            9 = Close ALL Pallet
            OPTION:        (field01)
         ********************************************************************************/
         ELSE IF @nCurrentScn = 6840
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
               SET @cOption = TRIM(@cInField01)

               IF @cOption = ''
               BEGIN
                  SET @nErrNo = 255540
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Option required
                  GOTO Quit
               END

               IF @cOption NOT IN ('1', '2', '9')
               BEGIN
                  SET @nErrNo = 255541
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Invalid Option
                  GOTO Quit
               END

               IF @cOption = '1'
               BEGIN
                  SET @nTranCount = @@TRANCOUNT
                  BEGIN TRAN  -- Begin our own transaction
                  SAVE TRAN rdt_839ExtScn06_6840 -- For rollback or commit only our own transaction

                  WHILE 1 = 1
                  BEGIN
                     SELECT TOP 1 @cRowRefTemp = RowRef,
                        @cRemarks = Remarks
                     FROM RDT.rdtPickLog WITH(NOLOCK)
                     WHERE PickSlipNo = @cPickSlipNo
                        AND Mobile = @nMobile
                        AND AddWho = @cUserName

                     IF @@ROWCOUNT = 0
                        BREAK

                     BEGIN TRY
                        DELETE FROM RDT.rdtPickLog
                        WHERE RowRef = @cRowRefTemp
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255542
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Delete rdtPickLog failed

                        IF XACT_STATE() = -1
                           ROLLBACK TRAN rdt_839ExtScn06_6840
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN
                        GOTO Quit
                     END CATCH

                     BEGIN TRY
                        UPDATE dbo.SerialNo WITH(ROWLOCK)
                        SET UserDefine01 = '0'
                        WHERE SerialNo = @cRemarks
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 255543
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Update SerialNo failed
                        IF XACT_STATE() = -1
                           ROLLBACK TRAN rdt_839ExtScn06_6840
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                           COMMIT TRAN
                        GOTO Quit
                     END CATCH
                  END

                  COMMIT TRAN rdt_839ExtScn06_6840 -- Only commit change made here
                  WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                     COMMIT TRAN
                  
                  IF @nPre_Step IN( @nStep_PickZone, @nStep_ConfirmLOC, @nStep_SKUQTY)
                  BEGIN
                     SET @nAfterScn = @nScn_PickSlipNo
                     SET @nAfterStep = @nStep_PickSlipNo

                     SET @cOutField01 = ''
                     SET @cOutField02 = '' --PickZone
                     SET @cOutField03 = '' --DropID

                     EXEC rdt.rdtSetFocusField @nMobile, 21 -- PickZone

                     SET @nPre_Step = @nCurrentStep
                  END
               END
               ELSE IF @cOption = '2'  -- No
               BEGIN
                  IF @nPre_Step = @nStep_PickZone
                  BEGIN
                     SET @nAfterScn = @nScn_PickZone
                     SET @nAfterStep = @nStep_PickZone

                     SET @cOutField01 = @cPickSlipNo
                     SET @cOutField02 = '' --PickZone
                     SET @cOutField03 = '' --DropID
                     SET @nTtlBalQty = 0
                     SET @nBalQty = 0
                     SET @cSuggLOC = ''
                     SET @cCurrLOC = ''
                     SET @cSkippedSKU = ''
                     SET @cSuggSKU = ''
                     SET @cOutField15 = ''

                     EXEC rdt.rdtSetFocusField @nMobile, 2 -- PickZone

                     SET @nPre_Step = @nCurrentStep
                  END
                  ELSE IF @nPre_Step = @nStep_ConfirmLOC
                  BEGIN
                     -- Prepare next screen var
                     SET @cOutField01 = @cSuggLOC
                     SET @cOutField02 = '' -- LOC

                     SET @nAfterScn = @nScn_ConfirmLOC
                     SET @nAfterStep = @nStep_ConfirmLOC
                  END
               END
               ELSE IF @cOption = '9'
               BEGIN
                  EXEC RDT.rdt_PickPiece_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CONFIRM'
                     ,@cPickSlipNo
                     ,@cPickZone
                     ,'ALLDROPID'
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
                     GOTO Quit

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
                  SET @nAfterScn = @nScn_PickSlipNo
                  SET @nAfterStep = @nStep_PickSlipNo
                  GOTO Quit
               END
            END
            ELSE IF @nInputKey = 0 -- ESC
            BEGIN
               IF @nPre_Step = @nStep_PickZone
               BEGIN
                  SET @nAfterScn = @nScn_PickZone
                  SET @nAfterStep = @nStep_PickZone

                  SET @cOutField01 = @cPickSlipNo
                  SET @cOutField02 = '' --PickZone
                  SET @cOutField03 = '' --DropID
                  SET @nTtlBalQty = 0
                  SET @nBalQty = 0
                  SET @cSuggLOC = ''
                  SET @cCurrLOC = ''
                  SET @cSkippedSKU = ''
                  SET @cSuggSKU = ''
                  SET @cOutField15 = ''

                  EXEC rdt.rdtSetFocusField @nMobile, 2 -- PickZone

                  SET @nPre_Step = @nCurrentStep
               END
            END
         END
      END

      IF @nAfterStep = 3
      BEGIN
         SELECT TOP 1 @cSuggUCC  = Descr
         FROM rdt.rdtPickLog WITH(NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
            AND Mobile = @nMobile
            AND AddWho = @cUserName
            AND PickMethod = 'GetTask-U'
            AND Status = '0'
         ORDER BY AddDate DESC

         SELECt @nRowCount = @@ROWCOUNT

         -- Display UCC
         IF @nRowCount > 0
         BEGIN
            SELECT @cSuggLOT = LOT FROM dbo.UCC WITH(NOLOCK) WHERE UCCNo = @cSuggUCC

            SET @cOutField08 = 'UCC:'
            SET @cOutField09 = @cSuggUCC
            SET @cOutField10 = 'LOT:'
            SET @cOutField11 = @cSuggLOT
         END
         ELSE
         -- Display Piece info, Lottable01, UOM, UOM Desc
         BEGIN
            SELECT TOP 1 @cSuggLOT  = Descr
            FROM rdt.rdtPickLog WITH(NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
               AND Mobile = @nMobile
               AND AddWho = @cUserName
               AND PickMethod = 'GetTask-P'
               AND Status = '0'
            ORDER BY AddDate DESC
            
            SELECT @cLottable01 = Lottable01 FROM dbo.LOTATTRIBUTE WITH(NOLOCK) WHERE LOT = ISNULL(@cSuggLOT, '')

            SELECT
               @cPackUOM = Pack.PackUOM3
            FROM dbo.SKU S WITH (NOLOCK)
            INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (S.PackKey = Pack.PackKey)
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSuggSKU

            SET @cOutField08 = ISNULL(@cLottable01, '')
            SET @cOutField09 = 'UOM: 6'
            SET @cOutField10 = @cPackUOM
            SET @cOutField11 = 'UOM Qty: ' + CAST(@nSuggQty AS NVARCHAR(10))
         END
         
         SET @nAfterScn = 6774
         SET @nAfterStep = 99
      END
      ELSE IF @nAfterStep = 5
      BEGIN
         SET @nAfterScn = 6777
         SET @nAfterStep = 99
      END
   END

   GOTO Quit
UPD_RDTMOBREC:
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(),
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nAfterStep,
      Scn    = @nAfterScn,

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
      V_Barcode      = @cBarcode, 
      
      V_FromStep     = @nFromStep,
      V_FromScn      = @nFromScn,

      V_Integer1     = @nActQTY,
      V_Integer2     = @nTtlBalQty,
      V_Integer3     = @nBalQty,
      V_Integer4     = @nPre_Step,

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
      V_String12     = @cExtDescr1,
      V_String13     = @cExtDescr2,
      V_String14     = @cSkipConfirmBalPick,  --(cc01)
      V_String15     = @cSKUSerialNoCapture, 

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
      V_String34     = @cSerialNoCapture, 
      V_String35     = @cCartonID,   --(yeekung02)
      V_String36     = @cScanCIDSCN, --(yeekung02)
      V_String37     = @cDecodeIDSP, --(yeekung02)
      V_String38     = @cSuggID, --(yeekung02)
      V_String39     = @cDefaultsku, --(yeekung02)
      V_String40     = @cExtSkuInfoSP,  -- (james08)
      V_String41     = @cPackData1,
      V_string42     = @cPackData2,
      V_String43     = @cPackData3,
      V_String44     = @cDataCaptureSP,
      V_String45     = @cSKUDataCapture,

      C_String9      = @cCloseDropIDFlag,
      C_String11     = @cCurrentOrderKey,
      C_String12     = @cPreviousOrderKey,

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
Quit:

END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON rdt.rdt_839ExtScn06 TO NSQL
GO
 
