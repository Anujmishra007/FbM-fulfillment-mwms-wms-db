SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/************************************************************************/  
/* Store procedure: rdt_600ExtScn05                                     */  
/* CUSTOMER :   Unilever                                                */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2024-10-11 1.0  LJQ006     FCR-911  Created                          */  
/* 2025-07-11 1.1  Dennis     FCR-5716 For Cold Store                   */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_600ExtScn05] (
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


   DECLARE 
      @cRcptUoMConf         NVARCHAR(50),
      @cRcptUoM             NVARCHAR(1),
      @cReceiptKey          NVARCHAR(10),
      @cSKU                 NVARCHAR(20),
      @cRcptUomDesc         NVARCHAR(10),
      @cDispStyleColorSize  NVARCHAR( 1),
      @cBarcode             NVARCHAR(100),
      @cBUSR10              NVARCHAR(20),
      @nUOM_Div             INT,
      @cPackKey             NVARCHAR(10),
      @cMUOM_Desc           NVARCHAR(10),
      @nMOBScn              INT,
      @cCaseID              NVARCHAR(18),
      @cLottableCode        NVARCHAR(30),   
      @cSKUDesc             NVARCHAR( 60),
      @cIVAS                NVARCHAR( 20),
      @cDropListSP          NVARCHAR( 20),
      @nMorePage            INT, 
      @cSQL                 NVARCHAR( MAX),
      @cSQLParam            NVARCHAR( MAX),
      @cPOKey               NVARCHAR( 10),
      @cLOC                 NVARCHAR( 20),
      @cID                  NVARCHAR( 18),
      @nPUOM_Div            INT,
      @cPUOM_Desc           NCHAR( 5),
      @cPUOM                NVARCHAR(  1),
      @cReasonCode          NVARCHAR( 10),
      @nQTY                 INT,  
      @cSuggToLOC           NVARCHAR( 10),
      @cFinalLOC            NVARCHAR( 10),
      @cReceiptLineNumber   NVARCHAR( 5),
      @cExtendedInfoSP      NVARCHAR( 20),
      @cExtendedInfo        NVARCHAR( 20),
      @nPQTY                INT,  
      @nMQTY                INT,    
      @cOption              NVARCHAR(1)
      
   DECLARE @tTmpPackUom TABLE (
      UomDesc NVARCHAR(10),
      UomDiv  INT,
      UomNo   NVARCHAR(1)
   );
      
   SELECT
   @nStep            = Step
   ,@nMOBScn            = Scn
   ,@cCaseID            = C_String1
   ,@cLottableCode      = V_String3
   ,@cPUOM              = V_UOM
   ,@cDropListSP        = V_String13
   ,@cPOKey             = V_POKey
   ,@cLOC               = V_Loc
   ,@cID                = V_ID
   ,@cReceiptKey        = V_Receiptkey
   ,@cSuggToLOC         = V_String5
   ,@cFinalLOC          = V_String6
   ,@cReceiptLineNumber = V_String7
   ,@cDispStyleColorSize = V_String20
   ,@cExtendedInfoSP    = V_String33
   ,@cExtendedInfo      = V_String34
   ,@nQTY               = V_QTY
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile
   
   SET @cRcptUoMConf = rdt.rdtGetConfig(@nFunc,'RcptUoM',@cStorerKey)
   SELECT @cOption = Value FROM @tExtScnData WHERE Variable = '@cOption'
   SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'

   SET @cUDF06 = @cRcptUomConf

   IF @nFunc = 600
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @nStep = 4 AND @nAfterScn <> 4033 --Step SKU and Next Scn is not SKU Scn (4033)
         BEGIN
            IF EXISTS (SELECT 1 FROM SKU WHERE itemclass='PVAR' AND BUSR10 IN ( 'BRAZIL','NewZealand') AND SKU = @cSKU)
            BEGIN
               IF ISNULL(@cCaseID,'') <> ''
                  SET @cOutField01 = @cCaseID
               ELSE
                  SET @cOutField01 = ''
               SET @nAfterStep = 98
               SET @nAfterScn = 6622
               GOTO QUIT
            END
         END
         IF ( @nStep IN (4, 5) OR (@nStep = 8 AND @cOption = 1) ) AND @nAfterScn = 4035
         BEGIN
            IF @nErrNo <> 0
            BEGIN
               GOTO Quit
            END
            
            IF @cRcptUomConf = 1
            BEGIN
               SELECT @cReceiptKey = Value FROM @tExtScnData WHERE Variable = '@cReceiptKey'
               SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
               SELECT @cMUOM_Desc = Value FROM @tExtScnData WHERE Variable = '@cMUOM_Desc'
               SELECT @cPackKey = PackKey FROM dbo.SKU WITH(NOLOCK) WHERE SKU = @cSKU AND StorerKey = @cStorerKey
               -- insert all pack uoms into a table variable
               DELETE FROM @tTmpPackUom;
               INSERT INTO @tTmpPackUom (UomDesc, UomDiv, UomNo)
               (
                  SELECT PackUOM1, CaseCNT,'2' FROM dbo.PACK WITH(NOLOCK) WHERE PackKey = @cPackKey
                  UNION ALL
                  SELECT PackUOM2, InnerPack, '3' FROM dbo.PACK WITH(NOLOCK) WHERE PackKey = @cPackKey
                  UNION ALL
                  SELECT PackUOM3, QTY, '6' FROM dbo.PACK WITH(NOLOCK) WHERE PackKey = @cPackKey
                  UNION ALL
                  SELECT PackUOM4, Pallet, '1' FROM dbo.PACK WITH(NOLOCK) WHERE PackKey = @cPackKey
                  UNION ALL
                  SELECT PackUOM8, OtherUnit1, '4' FROM dbo.PACK WITH(NOLOCK) WHERE PackKey = @cPackKey
                  UNION ALL
                  SELECT PackUOM9, OtherUnit2, '5' FROM dbo.PACK WITH(NOLOCK) WHERE PackKey = @cPackKey
               )
               SELECT TOP 1 @cRcptUomDesc = UOM 
               FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
               WHERE ReceiptKey = @cReceiptKey
                  AND Sku = @cSKU
                  AND StorerKey = @cStorerKey
               ORDER BY ReceiptLineNumber ASC
               -- match the rcpt uom with pack uom and get the uom no
               SELECT TOP 1 
                  @cRcptUoM = UomNo,
                  @nUOM_Div = UomDiv
               FROM @tTmpPackUom 
               WHERE UomDesc = @cRcptUomDesc
                  AND UomDesc IS NOT NULL
               SET @cUDF04 = @cRcptUoM
               SET @cUDF05 = @nUOM_Div
               SET @cUDF07 = @cRcptUomDesc
               SET @cOutField05 = '1:' + CASE WHEN @nUOM_Div > 99999 THEN '*' ELSE CAST( @nUOM_Div AS NCHAR( 5)) END
               SET @cOutField06 = rdt.rdtRightAlign( @cRcptUomDesc, 5)
               -- when pd uom equals to master uom, only show one input box
               IF (@cRcptUomDesc = @cMUOM_Desc)
               BEGIN
                  SET @cOutField06 = ''
                  SET @cFieldAttr08 = 'O'
               END
               ELSE
               BEGIN
                  SET @cFieldAttr08 = ''
               END
               IF @cFieldAttr08 = ''
               BEGIN
                  EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY
               END
               -- IF @cFieldAttr08 = 'O'
               -- BEGIN
               --    UPDATE RDT.RDTXML_Root WITH (ROWLOCK) SET Focus = NULL
               -- END
               SET @nAfterScn = 4035 -- GOTO Qty Scn
               SET @nAfterStep = 6 -- GOTO Qty Step
            END
         END

         IF @nStep = 98 AND @nScn = 6622 --CASE ID
         BEGIN
            SET @cBarcode = @cInField01
            
            SELECT TOP 1 @cBUSR10 = BUSR10 FROM SKU WHERE itemclass='PVAR' AND SKU = @cSKU
            IF @cBUSR10 = 'BRAZIL'
            BEGIN
               SELECT @cCaseID = SUBSTRING(@cBarcode, 5, 18)
            END
            ELSE
               SET @cCaseID = @cBarcode
            IF EXISTS (SELECT 1 FROM ReceiptDetail(NOLOCK) WHERE ReceiptKey = @cReceiptKey AND UserDefine10 = @cCaseID)
            BEGIN
               SET @nErrNo = 240751
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --case already received
               GOTO Quit
            END

            -- Dynamic lottable
            EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,
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
               @cReceiptKey,
               @nFunc

            IF @nErrNo <> 0
               GOTO Quit

            IF @nMorePage = 1 -- Yes
            BEGIN
               -- Go to dynamic lottable screen
               SET @cUDF01 = @nScn
               SET @nAfterScn = 3990
               SET @nAfterStep = 5
            END
            ELSE
            BEGIN
               -- Get SKU info
               SELECT
                  @cSKUDesc = 
                     CASE WHEN @cDispStyleColorSize = '0'
                        THEN ISNULL( DescR, '')
                        ELSE CAST( Style AS NCHAR(20)) +
                              CAST( Color AS NCHAR(10)) +
                              CAST( Size  AS NCHAR(10))
                     END,
                  @cIVAS = IsNULL( IVAS, ''),
                  @cLottableCode = LottableCode,
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
                     @nPUOM_Div = CAST( IsNULL(
                     CASE @cPUOM
                        WHEN '2' THEN Pack.CaseCNT
                        WHEN '3' THEN Pack.InnerPack
                        WHEN '6' THEN Pack.QTY
                        WHEN '1' THEN Pack.Pallet
                        WHEN '4' THEN Pack.OtherUnit1
                        WHEN '5' THEN Pack.OtherUnit2
                     END, 1) AS INT)
               FROM dbo.SKU SKU WITH (NOLOCK)
                  INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
               WHERE SKU.StorerKey = @cStorerKey
                  AND SKU.SKU = @cSKU

               -- Convert to prefer UOM QTY
               IF @cPUOM = '6' OR -- When preferred UOM = master unit
                  @nPUOM_Div = 0  -- UOM not setup
               BEGIN
                  SET @cPUOM_Desc = ''
                  SET @nPQTY = 0
                  SET @nMQTY = @nQTY
                  SET @cFieldAttr08 = 'O' -- @nPQTY
               END
               ELSE
               BEGIN
                  SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM
                  SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit
                  SET @cFieldAttr08 = '' -- @nPQTY
               END

               -- Prepare next screen variable
               SET @cOutField01 = @cSKU
               SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)
               SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20)
               SET @cOutField04 = SUBSTRING( @cIVAS, 1, 20)
               SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END
               SET @cOutField06 = rdt.rdtRightAlign( @cPUOM_Desc, 5)
               SET @cOutField07 = rdt.rdtRightAlign( @cMUOM_Desc, 5)
               SET @cOutField08 = CASE WHEN @nPQTY = 0 OR @cFieldAttr08 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 7)) END -- PQTY
               SET @cOutField09 = CASE WHEN @nMQTY = 0 THEN '' ELSE CAST( @nMQTY AS NVARCHAR( 7)) END -- MQTY
               SET @cOutField10 = @cDropListSP -- Reason List
               SET @cOutField15 = '' -- ExtendedInfo

               IF @cFieldAttr08 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY

               -- Go to QTY screen
               SET @nAfterScn = 4035
               SET @nAfterStep = 6

               -- Extended info
               IF @cExtendedInfoSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
                  BEGIN
                     SET @cExtendedInfo = ''
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +
                        ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                        ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                        ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                        ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +
                        ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile       INT,           ' +
                        '@nFunc         INT,           ' +
                        '@cLangCode     NVARCHAR( 3),  ' +
                        '@nStep         INT,           ' +
                        '@nAfterStep    INT,           ' +
                        '@nInputKey     INT,           ' +
                        '@cFacility     NVARCHAR( 5),  ' +
                        '@cStorerKey    NVARCHAR( 15), ' +
                        '@cReceiptKey   NVARCHAR( 10), ' +
                        '@cPOKey        NVARCHAR( 10), ' +
                        '@cLOC          NVARCHAR( 10), ' +
                        '@cID           NVARCHAR( 18), ' +
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
                        '@nQTY          INT,           ' +
                        '@cReasonCode   NVARCHAR( 10), ' +
                        '@cSuggToLOC    NVARCHAR( 10), ' +
                        '@cFinalLOC     NVARCHAR( 10), ' +
                        '@cReceiptLineNumber NVARCHAR( 10),   ' +
                        '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +
                        '@nErrNo        INT           OUTPUT, ' +
                        '@cErrMsg       NVARCHAR( 20) OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,
                        @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
                        @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                        @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                        @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,
                        @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO QUIT

                     SET @cOutField15 = @cExtendedInfo
                  END
               END
            END
         END
      END
      IF @nInputKey = 0
      BEGIN
         IF @nStep = 98 AND @nScn = 6622 --CASE ID
         BEGIN
            -- Init next screen var
            SET @cOutField01 = @cID
            SET @cOutField02 = ''
            SET @cOutField03 = '' -- SKUDesc1
            SET @cOutField04 = '' -- SKUDesc2

            -- Go to next screen
            SET @nAfterScn = 4033
            SET @nAfterStep = 4
         END
      END
   END
Quit:
   UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
      C_String1 = @cCaseID
   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600ExtScn05 to nSQL
GO
