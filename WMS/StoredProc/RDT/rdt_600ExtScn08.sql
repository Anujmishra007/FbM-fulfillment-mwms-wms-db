SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/************************************************************************/  
/* Store procedure: rdt_600ExtScn08                                     */
/* CUSTOMER :   LCL SHIPPING CO                                         */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2025-05-19 1.0  Cuize      FCR-4500  Created                         */
/* 2025-06-02 1.1  AGA399     Return Qty = 1 if SKU = LCLPLT            */
/* 2025-06-26 1.2  Cuize      After close pallet to TOID scn            */
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_600ExtScn08] (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep INT,
   @nScn  INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),

   @cSuggLOC     NVARCHAR( 10) OUTPUT,
   @cLOC         NVARCHAR( 20) OUTPUT,
   @cID          NVARCHAR( 20) OUTPUT,
   @cSKU         NVARCHAR( 20) OUTPUT,
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cReasonCode  NVARCHAR( 10),
   @cReceiptLineNumber  NVARCHAR( 5),
   @cPalletType  NVARCHAR( 10),

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
   @cErrMsg            NVARCHAR( 20)  OUTPUT
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
      @cOption              NVARCHAR( 10),
      @cPalletLineNumber    NVARCHAR( 5),
      @nqty                 INT,
      @cPalletSKU           NVARCHAR( 20),
      @cAutoGenID           NVARCHAR( 20),
      @cSKUDesc             NVARCHAR( 60),
      @cAutoID              NVARCHAR( 18),
      @tExtData             VariableTable,
      @cCursorPalletDetail  CURSOR,
      @curDel               CURSOR

--       SET @nOringinStep = @nStep
--       SET @nOringinScn  = @nScn
--

   SELECT
      @nStep         = Step,
      @nScn          = Scn,
      @cSKUDesc      = V_SKUDescr,
      @cAutoGenID    = V_String24
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 600
   BEGIN -- AGA399  Return Qty = 1 if SKU = LCLPAL
      IF @nStep = 4 -- SKU Screen
      BEGIN
         IF @nInputKey = 1 AND @nAction  = 3
         BEGIN
            IF @cSKU = 'LCLPLT'
            BEGIN
               -- @cOutField08 = '55'
               SET @cOutField09 = '1'
            END
         END
      END --AGA399 END

      IF @nStep = 15 -- Close Pallet?
      BEGIN
         IF @nInputKey = 1 AND @cInField01 = '1' -- 'YES'
         BEGIN

            --Check TOID not received qty
            IF NOT EXISTS(
               SELECT 1
               FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND TOID = @cID
                 AND ( BeforeReceivedQTY > 0 OR QtyReceived > 0)
            )
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
               GOTO Quit
            END


            DECLARE @attrLWHX NVARCHAR (10)

            SELECT @attrLWHX = ConfigDesc
            FROM rdt.StorerConfig (NOLOCK)
            WHERE Function_ID = @nFunc
              AND StorerKey = @cStorerKey
              AND ConfigKey = 'ExtendedScreenSP'
              AND SValue = 'rdt_600ExtScn08'

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
            SET @nAfterStep = 99
         END

         IF @nInputKey = 1 AND @cInField01 = '2' -- 'NO' = 'ESC'
         BEGIN
            -- Prepare next screen
            SET @cOutField01 = @cID
--             SET @cMax = '' -- SKU
            SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)
            SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20)

            -- Go back to SKU screen
            SET @nAfterScn = 4033
            SET @nAfterStep = 4
            GOTO Quit
         END

      END

      IF @nStep = 99 -- Pallet Capture
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
               IF ISNULL( @cFieldAttr02, '') <> '0' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Length', @cLength) = 0
               BEGIN
                  SET @nErrNo = 238751
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Length
                  SET @cOutField02 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 2
                  GOTO Quit
               END

               IF ISNULL( @cFieldAttr03, '') <> '0' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Width', @cWidth) = 0
               BEGIN
                  SET @nErrNo = 238752
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Width
                  SET @cOutField03 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 3
                  GOTO Quit
               END

               IF ISNULL( @cFieldAttr04, '') <> '0' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Height', @cHeight) = 0
               BEGIN
                  SET @nErrNo = 238753
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Height
                  SET @cOutField04 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 4
                  GOTO Quit
               END

               IF ISNULL( @cFieldAttr05, '') <> '0' AND rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'Weight', @cWeight) = 0
               BEGIN
                  SET @nErrNo = 238754
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Weight
                  SET @cOutField05 = ''
                  EXEC rdt.rdtSetFocusField @nMobile, 5
                  GOTO Quit
               END

               IF EXISTS ( SELECT 1 FROM PALLET WITH (NOLOCK) WHERE PalletKey = @cID AND Status NOT IN ('0','9'))
               BEGIN
                  SET @nErrNo = 238756
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Received
                  GOTO Quit
               END


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
                        SET @nErrNo = 238757
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltDtl Err
                        GOTO Quit
                     END

                     FETCH NEXT FROM @curDel INTO @cPalletLineNumber
                  END

                  UPDATE PALLET SET ArchiveCop = '9' WHERE PalletKey = @cID

                  DELETE FROM PALLET WHERE PalletKey = @cID

                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 238758
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltHdr Err
                     GOTO Quit
                  END
               END

               --INSERT Pallet TABLE
               SET @cPalletType = rdt.RDTGetConfig( @nFunc, 'DefaultPalletType', @cStorerKey)
               IF @cPalletType = '0'
                  SET @cPalletType = ''

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
                     SET @nErrNo = 238759
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PLDtl Err
                     GOTO Quit
                  END

                  FETCH NEXT FROM @cCursorPalletDetail INTO @cReceiptLineNumber, @cPalletSKU, @nqty
               END

               CLOSE @cCursorPalletDetail
               DEALLOCATE @cCursorPalletDetail

               -- Check if pallet label setup
               IF EXISTS( SELECT 1 FROM RDT.RDTReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ReportType IN ('PalletLBL'))
               BEGIN
                  -- Prepare next screen var
                  SET @cOutField01 = '' -- Option
                  SET @cOutField02 = ''
                  SET @cOutField03 = ''
                  SET @cOutField04 = ''
                  SET @cOutField05 = ''

                  -- Go to print pallet label screen
                  SET @nAfterScn = 4038
                  SET @nAfterStep = 9
               END
               ELSE
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
               SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = ''
               GOTO Quit
            END
            ELSE IF @nInputKey = 0 -- ESC
            BEGIN

               -- Enable field
               SELECT @cFieldAttr02 = '', @cFieldAttr03 = '', @cFieldAttr04 = '', @cFieldAttr05 = ''

               -- Prepare next screen var
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''

               -- Go to prev screen
               SET @nAfterScn  = 4042
               SET @nAfterStep = 15
               GOTO Quit
            END
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

GRANT EXECUTE ON rdt.rdt_600ExtScn08 to nSQL
GO
