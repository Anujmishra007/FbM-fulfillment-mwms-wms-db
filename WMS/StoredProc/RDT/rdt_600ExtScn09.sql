SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/************************************************************************/  
/* Store procedure: rdt_600ExtScn09                                     */
/* CUSTOMER :   LCL SHIPPING CO                                         */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2025-05-19 1.0  Cuize      FCR-6888  Created                         */
/* 2025-09-01 1.1  Cuize      FCR-6888  New Requirement                 */
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_600ExtScn09] (
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
      @cWeight              NVARCHAR( 10),
      @cLength              NVARCHAR( 10),
      @cWidth               NVARCHAR( 10),
      @cHeight              NVARCHAR( 10),
      @cIVAS               NVARCHAR( 20),
      @cPalletLineNumber    NVARCHAR( 5),
      @cDispStyleColorSize NVARCHAR( 1),
      @cPUOM               NVARCHAR(  1),
      @cPUOM_Desc          NCHAR( 5),
      @cMUOM_Desc          NCHAR( 5),
      @nPUOM_Div           INT,
      @nPQTY               INT,
      @nMQTY               INT,
      @nqty                 INT,
      @cPalletSKU           NVARCHAR( 20),
      @cAutoGenID           NVARCHAR( 20),
      @cDropListSP         NVARCHAR( 20),
      @cLottableCode       NVARCHAR( 30),
      @cPalletType         NVARCHAR(10),

      @cReceiptKey          NVARCHAR(10),
      @cReceiptLineNumber   NVARCHAR( 5),
      @cPOKey               NVARCHAR( 10),
      @cID                  NVARCHAR( 18),
      @cSKU                 NVARCHAR(20),
      @cLOC                 NVARCHAR( 20),
      @cReasonCode            NVARCHAR( 10),
      @cRcptConfirmSP      NVARCHAR( 20),
      @cPalletTypeSave      NVARCHAR( 10),
      @cSQL           NVARCHAR( MAX),
      @cSQLParam      NVARCHAR( MAX),
      @nMorePage        NVARCHAR( 10) = '',




      @cSKUDesc             NVARCHAR( 60),
      @cAutoID              NVARCHAR( 18),
      @cPrinter_Paper       NVARCHAR( 10),
      @cPrinter             NVARCHAR( 10),
      @cPalletRecvSP       NVARCHAR( 20),
      @tExtData             VariableTable,
      @cCursorPalletDetail  CURSOR,
      @curDel               CURSOR



   SELECT
      @nStep               = Step,
      @nScn                = Scn,
      @cIVAS               = V_String2,
      @cLottableCode       = V_String3,
      @cReasonCode         = V_String4,
      @cMUOM_Desc          = V_String10,
      @cPUOM_Desc          = V_String11,
      @cDropListSP         = V_String13,
      @cRcptConfirmSP      = V_String32,
      @cReceiptKey        = V_Receiptkey,
      @cReceiptLineNumber = V_String7,
      @cID                = V_ID,
      @nQTY                = V_QTY,
      @cPOKey             = V_POKey,
      @cLOC               = V_Loc,
      @cPUOM               = V_UOM,
      @nPUOM_Div           = V_PUOM_Div,
      @cSKUDesc            = V_SKUDescr,
      @cDispStyleColorSize = V_String20,
      @cAutoGenID          = V_String24,
      @cPrinter            = Printer,
      @cPrinter_Paper      = Printer_Paper,
      @cPalletTypeSave     = C_String2
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
   SELECT @cPalletType = Value FROM @tExtScnData WHERE Variable = '@cPalletType'
   SELECT @nMorePage = Value FROM @tExtScnData WHERE Variable = '@nMorePage'



   -- Get UOM
   DECLARE @cUOM NVARCHAR(10)
   SELECT @cUOM = PackUOM3
   FROM dbo.SKU WITH (NOLOCK)
           JOIN dbo.Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)
   WHERE StorerKey = @cStorerKey
     AND SKU = @cSKU

   -- NOPO flag
   DECLARE @nNOPOFlag INT
   SET @nNOPOFlag = CASE WHEN @cPOkey = 'NOPO' THEN 1 ELSE 0 END

   -- Reason code
   IF @cReasonCode = ''
      SET @cReasonCode = 'OK'


   IF @nFunc = 600
   BEGIN

      IF @nStep = 4 -- SKU Screen
      BEGIN
         IF @nInputKey = 1
         BEGIN

            IF @cUOM = 'PLT' AND @nMorePage = '0' --No lottable scns
            BEGIN
               SET @cOutField09 = '1'
            END
         END
         IF @nInputKey = 0-- ESC
         BEGIN

            -- Auto generate ID
            SET @cID = ''
            IF @cAutoGenID <> ''
               BEGIN
                  EXEC rdt.rdt_AutoGenID @nMobile, @nFunc, @nStep, @cLangCode
                     ,@cAutoGenID
                     ,@tExtData
                     ,@cAutoID  OUTPUT
                     ,@nErrNo   OUTPUT
                     ,@cErrMsg  OUTPUT
                  IF @nErrNo <> 0
                     GOTO Quit

                  SET @cID = @cAutoID
               END

            -- Prepare next screen var
            SET @cOutField01 = @cLOC
            SET @cOutField02 = @cID -- @cID
            SET @cOutField03 = ''
            SET @cOutField04 = ''
            SET @cOutField05 = ''

            -- Go to ID screen
            SET @nAfterScn = 4032
            SET @nAfterStep = 3

         END
      END

      IF @nStep = 5
      BEGIN
         IF @nInputKey = 1 --LOTTABLE
         BEGIN
            IF @cUOM = 'PLT' --No lottable scns
            BEGIN
               SET @cOutField09 = '1'
            END
         END
      END

      IF @nStep = 6 -- QTY screen
      BEGIN

         IF @nInputKey = 1
         BEGIN

            DECLARE @attrLWHX NVARCHAR (10)

            SELECT @attrLWHX = ConfigDesc
            FROM rdt.StorerConfig (NOLOCK)
            WHERE Function_ID = @nFunc
              AND StorerKey = @cStorerKey
              AND ConfigKey = 'ExtScnSP'
              AND SValue = 'rdt_600ExtScn09'

            SET @cFieldAttr02 = CASE WHEN CHARINDEX('L', @attrLWHX) > 0 THEN '' ELSE 'O' END
            SET @cFieldAttr03 = CASE WHEN CHARINDEX('W', @attrLWHX) > 0 THEN '' ELSE 'O' END
            SET @cFieldAttr04 = CASE WHEN CHARINDEX('H', @attrLWHX) > 0 THEN '' ELSE 'O' END
            SET @cFieldAttr05 = CASE WHEN CHARINDEX('X', @attrLWHX) > 0 THEN '' ELSE 'O' END

            SET @cOutField01 = @cID

            SET @cInField02 = ''
            SET @cInField03 = ''
            SET @cInField04 = ''
            SET @cInField05 = ''

            SET @cOutField02 = ''
            SET @cOutField03 = ''
            SET @cOutField04 = ''
            SET @cOutField05 = ''



            SET @nAfterScn = 4043
            SET @nAfterStep = 98

         END

      END

      IF @nStep = 7
      BEGIN
         IF @nAction = 2
         BEGIN

            DECLARE @cPalletLabel NVARCHAR( 10)
            DECLARE @tPalletLabel   VariableTable

            SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)
            IF @cPalletLabel = '0'
               SET @cPalletLabel = ''

            -- Auto print pallet label if setup
            IF @cPalletLabel <> ''
            BEGIN
               -- Common params
               INSERT INTO @tPalletLabel (Variable, Value) VALUES
              ( '@cStorerKey', @cStorerKey),
              ( '@cReceiptKey', @cReceiptKey),
              ( '@cReceiptLineNumber_Start', @cReceiptLineNumber),
              ( '@cReceiptLineNumber_End', @cReceiptLineNumber),
              ( '@cPOKey', @cPOKey),
              ( '@cToID', @cID)

               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPrinter, @cPrinter_Paper,
                    @cPalletLabel, -- Report type
                    @tPalletLabel, -- Report params
                    'rdt_600ExtScn09',
                    @nErrNo  OUTPUT,
                    @cErrMsg OUTPUT

               IF @nErrNo <> 0 -- error, keep current screen
               BEGIN
                  SET @nAfterScn = 4036
                  SET @nAfterStep = 7
                  GOTO Quit
               END

            END

         END
      END

      IF @nStep = 98 -- Pallet Capture
      /********************************************************************************
      Scn = 4043. Store pallet info
         PalletKey   (field01)
         Length      (field02, input)
         Width       (field03, input)
         Height      (field04, input)
         Weight      (field05, input)
         (field06)   (field07, input)
      ********************************************************************************/
      BEGIN
         IF @nScn = 4043
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN

               -- Screen mapping
               SET @cLength = LTRIM( RTRIM( @cInField02))
               SET @cWidth = LTRIM( RTRIM( @cInField03))
               SET @cHeight = LTRIM( RTRIM( @cInField04))
               SET @cWeight = LTRIM( RTRIM( @cInField05))

               SET @cOutField02 = LTRIM( RTRIM( @cInField02))
               SET @cOutField03 = LTRIM( RTRIM( @cInField03))
               SET @cOutField04 = LTRIM( RTRIM( @cInField04))
               SET @cOutField05 = LTRIM( RTRIM( @cInField05))

               -- Check all field
               IF ISNULL( @cFieldAttr02, '') = '' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Length', @cLength) = 0
               BEGIN
                  SET @nErrNo = 243751
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Length
                  SET @cOutField02 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 2
                  GOTO Quit
               END

               IF ISNULL( @cFieldAttr03, '') = '' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Width', @cWidth) = 0
               BEGIN
                  SET @nErrNo = 243752
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Width
                  SET @cOutField03 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  GOTO Quit
               END

               IF ISNULL( @cFieldAttr04, '') = '' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Height', @cHeight) = 0
               BEGIN
                  SET @nErrNo = 243753
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Height
                  SET @cOutField04 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 4
                  GOTO Quit
               END

               IF ISNULL( @cFieldAttr05, '') = '' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Weight', @cWeight) = 0
               BEGIN
                  SET @nErrNo = 243754
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Weight
                  SET @cOutField05 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 5
                  GOTO Quit
               END

               IF EXISTS ( SELECT 1 FROM PALLET WITH (NOLOCK) WHERE PalletKey = @cID AND Status NOT IN ('0','9'))
               BEGIN
                  SET @nErrNo = 243756
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Received
                  GOTO Quit
               END

               -- Start receiving
               -- Custom receiving logic
               IF @cRcptConfirmSP <> ''
               BEGIN
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cRcptConfirmSP) +
                              ' @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cReceiptKey, @cPOKey, @cToLOC, @cToID, ' +
                              ' @cSKUCode, @cSKUUOM, @nSKUQTY, @cUCC, @cUCCSKU, @nUCCQTY, @cCreateUCC, ' +
                              ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
                              ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
                              ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
                              ' @nNOPOFlag, @cConditionCode, @cSubreasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cReceiptLineNumberOutput OUTPUT '

                  SET @cSQLParam =
                          '@nFunc          INT,            ' +
                          '@nMobile        INT,            ' +
                          '@cLangCode      NVARCHAR( 3),   ' +
                          '@cStorerKey     NVARCHAR( 15),  ' +
                          '@cFacility      NVARCHAR( 5),   ' +
                          '@cReceiptKey    NVARCHAR( 10),  ' +
                          '@cPOKey         NVARCHAR( 10),  ' +
                          '@cToLOC         NVARCHAR( 10),  ' +
                          '@cToID          NVARCHAR( 18),  ' +
                          '@cSKUCode       NVARCHAR( 20),  ' +
                          '@cSKUUOM        NVARCHAR( 10),  ' +
                          '@nSKUQTY        INT,            ' +
                          '@cUCC           NVARCHAR( 20),  ' +
                          '@cUCCSKU        NVARCHAR( 20),  ' +
                          '@nUCCQTY        INT,            ' +
                          '@cCreateUCC     NVARCHAR( 1),   ' +
                          '@cLottable01    NVARCHAR( 18),  ' +
                          '@cLottable02    NVARCHAR( 18),  ' +
                          '@cLottable03    NVARCHAR( 18),  ' +
                          '@dLottable04    DATETIME,       ' +
                          '@dLottable05    DATETIME,       ' +
                          '@cLottable06    NVARCHAR( 30),  ' +
                          '@cLottable07    NVARCHAR( 30),  ' +
                          '@cLottable08    NVARCHAR( 30),  ' +
                          '@cLottable09    NVARCHAR( 30),  ' +
                          '@cLottable10    NVARCHAR( 30),  ' +
                          '@cLottable11    NVARCHAR( 30),  ' +
                          '@cLottable12    NVARCHAR( 30),  ' +
                          '@dLottable13    DATETIME,       ' +
                          '@dLottable14    DATETIME,       ' +
                          '@dLottable15    DATETIME,       ' +
                          '@nNOPOFlag      INT,            ' +
                          '@cConditionCode NVARCHAR( 10),  ' +
                          '@cSubreasonCode NVARCHAR( 10),  ' +
                          '@nErrNo         INT           OUTPUT, ' +
                          '@cErrMsg        NVARCHAR( 20) OUTPUT, ' +
                          '@cReceiptLineNumberOutput NVARCHAR( 5) OUTPUT '

                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                       @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cReceiptKey, @cPOKey, @cLOC, @cID,
                       @cSKU, @cUOM, @nQTY, '', '', 0, '',
                       @cLottable01, @cLottable02, @cLottable03, @dLottable04, NULL,
                       @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
                       @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
                       @nNOPOFlag, @cReasonCode, '', @nErrNo OUTPUT, @cErrMsg OUTPUT, @cReceiptLineNumber OUTPUT
               END

               IF @nErrNo <> 0
                  GOTO Quit


               IF EXISTS ( SELECT 1 FROM PALLET WITH (NOLOCK) WHERE PalletKey = @cID AND Status in ('0','9'))
               BEGIN
                  SET @curDel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                     SELECT PalletLineNumber
                     FROM dbo.PalletDetail WITH (NOLOCK)
                     WHERE PalletKey = @cID
                  OPEN @curDel
                  FETCH NEXT FROM @curDel INTO @cPalletLineNumber
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     UPDATE PALLETDETAIL SET ArchiveCop = '9'
                     WHERE PalletKey = @cID
                       AND PalletLineNumber = @cPalletLineNumber

                     DELETE FROM PALLETDETAIL
                     WHERE PalletKey = @cID
                       AND PalletLineNumber = @cPalletLineNumber

                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 243757
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltDtl Err
                        GOTO Quit
                     END

                     FETCH NEXT FROM @curDel INTO @cPalletLineNumber
                  END

                  UPDATE PALLET SET ArchiveCop = '9' WHERE PalletKey = @cID

                  DELETE FROM PALLET WHERE PalletKey = @cID

                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 243758
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltHdr Err
                     GOTO Quit
                  END
               END

               IF(ISNULL(rdt.RDTGetConfig( @nFunc, 'ValidatePalletType', @cStorerKey),'0'))!='0' -- Capture pallet type
               BEGIN
                  IF ISNULL(@cPalletTypeSave,'')!=''
                     SET @cPalletType = @cPalletTypeSave
               END

               DECLARE @cPalletTypeDefault NVARCHAR(10)

               SET @cPalletTypeDefault = rdt.RDTGetConfig( @nFunc, 'DefaultPalletType', @cStorerKey)

               IF @cPalletType = ''
                  SET @cPalletType = @cPalletTypeDefault

               UPDATE RECEIPTDETAIL SET PalletType = @cPalletType
               WHERE ReceiptKey = @cReceiptKey
                 AND ReceiptLineNumber = @cReceiptLineNumber

               INSERT INTO dbo.Pallet (PalletKey, StorerKey, Status,Length, Width, Height, GrossWgt, PalletType) -- add palletType
               VALUES (@cID, @cStorerKey, '0',@cLength, @cWidth, @cHeight, @cWeight, @cPalletType)
               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 219103
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PalletFail
                  GOTO Quit
               END

               -- PalletDetail

               SET @cCursorPalletDetail = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR

                  SELECT ReceiptLineNumber, SKU, QtyReceived
                  FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                        AND ReceiptKey = @cReceiptKey
                        AND TOID = @cID


               OPEN @cCursorPalletDetail
               FETCH NEXT FROM @cCursorPalletDetail INTO @cReceiptLineNumber, @cPalletSKU, @nqty
               WHILE (@@FETCH_STATUS <> -1)
               BEGIN

                  SELECT @cPalletLineNumber = RIGHT( '00000' + CAST( CAST( ISNULL(MAX( PalletLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
                  FROM dbo.PalletDetail WITH (NOLOCK)
                  WHERE PalletKey = @cID

                  INSERT INTO dbo.PalletDetail
                  ( PalletKey, PalletLineNumber, StorerKey, SKU, LOC, QTY, Status, SourceType, SourceKey, ReceiptKey, ReceiptLineNumber)
                  VALUES
                     (@cID, @cPalletLineNumber, @cStorerKey, @cPalletSKU,@cLOC, @nqty, '0', 'I', CONCAT(@cReceiptKey,@cReceiptLineNumber), @cReceiptKey,@cReceiptLineNumber  )

                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 243759
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PLDtl Err
                     GOTO Quit
                  END

                  FETCH NEXT FROM @cCursorPalletDetail INTO @cReceiptLineNumber, @cPalletSKU, @nqty
               END

               CLOSE @cCursorPalletDetail
               DEALLOCATE @cCursorPalletDetail



               -- Go Successful received screen
               SET @nAfterScn = 4036
               SET @nAfterStep = 7
               SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               GOTO Quit
            END
            ELSE IF @nInputKey = 0 -- ESC
            BEGIN

               -- Enable field
               SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = ''

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
               SET @cOutField10 = @cDropListSP -- Reason
               SET @cOutField15 = '' -- ExtendedInfo

               -- Go to prev screen
               SET @nAfterScn  = 4035
               SET @nAfterStep = 6
               GOTO Quit
            END
         END
      END

   END

Quit:
   UPDATE RDT.RDTMOBREC SET
      C_String2 = @cPalletTypeSave
   WHERE Mobile = @nMobile

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_600ExtScn09 to nSQL
GO
