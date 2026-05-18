
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_600ExtUpd15BRF                                        */
/* Copyright    Maersk                                                        */
/*                                                                            */
/* Purpose:     Line split for PVAR (Catchweight) items with Case ID capture  */
/*                                                                            */
/* Date           Author    Ver.       Purposes                               */
/* 2026-04-16     Cuize     1.0.0      FCR-12508 Created From rdt_600ExtUpd15 */
/******************************************************************************/

   CREATE OR ALTER PROC rdt.rdt_600ExtUpd15BRF (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR( 3),
   @nStep        INT,
   @nInputKey    INT,
   @cFacility    NVARCHAR( 5),
   @cStorerKey   NVARCHAR( 15),
   @cReceiptKey  NVARCHAR( 10),
   @cPOKey       NVARCHAR( 10),
   @cLOC         NVARCHAR( 10),
   @cID          NVARCHAR( 18),
   @cSKU         NVARCHAR( 20),
   @cLottable01  NVARCHAR( 18),
   @cLottable02  NVARCHAR( 18),
   @cLottable03  NVARCHAR( 18),
   @dLottable04  DATETIME,
   @dLottable05  DATETIME,
   @cLottable06  NVARCHAR( 30),
   @cLottable07  NVARCHAR( 30),
   @cLottable08  NVARCHAR( 30),
   @cLottable09  NVARCHAR( 30),
   @cLottable10  NVARCHAR( 30),
   @cLottable11  NVARCHAR( 30),
   @cLottable12  NVARCHAR( 30),
   @dLottable13  DATETIME,
   @dLottable14  DATETIME,
   @dLottable15  DATETIME,
   @nQTY         INT,            --pass in decode count
   @cReasonCode  NVARCHAR( 10),
   @cSuggToLOC   NVARCHAR( 10),
   @cFinalLOC    NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 10),
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCaseID              NVARCHAR( 60)
   DECLARE @cItemClass           NVARCHAR( 10)
   DECLARE @nQTYExpected         INT
   DECLARE @nBeforeReceivedQTY   INT
   DECLARE @nRemainingQTY        INT
   DECLARE @cNewReceiptLineNumber NVARCHAR( 5)
   DECLARE @cActualLineNumber    NVARCHAR( 5)

   BEGIN

      SELECT @cCaseID = C_String1
      FROM RDT.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile

      IF @nFunc = 600
      BEGIN
         IF @nStep = 6 -- QTY screen
         BEGIN
            IF @nInputKey = 1
            BEGIN

               IF ISNULL(@cCaseID,'') = ''
                  GOTO Quit

               -- Check if SKU is PVAR (Catchweight Item)
               SELECT @cItemClass = ItemClass
               FROM dbo.SKU WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                 AND SKU = @cSKU

               IF @cItemClass = 'PVAR'
               BEGIN
                  -- Handle split receiving scenario: multiple lines may receive qty
                  -- Loop through all lines that received qty and need CaseID update
                  DECLARE curLines CURSOR LOCAL FAST_FORWARD FOR
                     SELECT ReceiptLineNumber, QTYExpected, ISNULL(BeforeReceivedQTY, 0)
                     FROM dbo.ReceiptDetail WITH (NOLOCK)
                     WHERE ReceiptKey = @cReceiptKey
                       AND StorerKey = @cStorerKey
                       AND SKU = @cSKU
                       AND BeforeReceivedQTY > 0
                       AND (UserDefine10 IS NULL OR UserDefine10 = '' OR UserDefine10 = 'KG' OR UserDefine10 = 'CX')
                     ORDER BY ReceiptLineNumber

                  OPEN curLines
                  FETCH NEXT FROM curLines INTO @cActualLineNumber, @nQTYExpected, @nBeforeReceivedQTY

                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     -- Calculate RemainingQTY
                     SET @nRemainingQTY = @nQTYExpected - @nBeforeReceivedQTY

                     -- If receiving QTY is less than expected, split the line
                     -- Like ispFinalizeReceipt: original line keeps received, new line gets remaining
                     IF @nRemainingQTY > 0
                     BEGIN
                        -- Get new receipt line number
                        SELECT @cNewReceiptLineNumber =
                           RIGHT( '00000' + CAST( CAST( ISNULL( MAX( ReceiptLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
                        FROM dbo.ReceiptDetail WITH (NOLOCK)
                        WHERE ReceiptKey = @cReceiptKey

                        -- Insert new receipt line for the RECEIVED portion (with CaseID)
                        INSERT INTO dbo.ReceiptDetail (
                           ReceiptKey, ReceiptLineNumber, POKey, StorerKey, SKU, QTYExpected, BeforeReceivedQTY, ToID, ToLOC,
                           Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
                           Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
                           Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                           Status, DateReceived, UOM, PackKey, ConditionCode, EffectiveDate, TariffKey, FinalizeFlag, SplitPalletFlag,
                           ExternReceiptKey, ExternLineNo, AltSku, VesselKey,
                           VoyageKey, XdockKey, ContainerKey, UnitPrice, ExtendedPrice, FreeGoodQtyExpected,
                           FreeGoodQtyReceived, ExportStatus, LoadKey, ExternPoKey,
                           Notes, Notes2, GrossWgt, Cube,
                           UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05,
                           UserDefine06, UserDefine07, UserDefine08, UserDefine09, UserDefine10,
                           POLineNumber, SubReasonCode, DuplicateFrom, Channel,
                           AddDate, AddWho, EditDate, EditWho
                        )
                        SELECT
                           @cReceiptKey, @cNewReceiptLineNumber, POKey, @cStorerKey, @cSKU,
                           @nBeforeReceivedQTY, @nBeforeReceivedQTY, ToID, ToLOC,
                           Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,
                           Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
                           Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
                           Status, DateReceived, UOM, PackKey, ConditionCode, EffectiveDate, TariffKey, 'N', SplitPalletFlag,
                           ISNULL(ExternReceiptKey,''), ISNULL(ExternLineNo,''), ISNULL(AltSku,''), ISNULL(VesselKey,''),
                           ISNULL(VoyageKey,''), ISNULL(XdockKey,''), ISNULL(ContainerKey,''), ISNULL(UnitPrice,0), ISNULL(ExtendedPrice,0), ISNULL(FreeGoodQtyExpected,0),
                           ISNULL(FreeGoodQtyReceived,0), ISNULL(ExportStatus,'0'), LoadKey, ExternPoKey,
                           ISNULL(Notes,''), ISNULL(Notes2,''), ISNULL(GrossWgt,0), ISNULL(Cube,0),
                           ISNULL(UserDefine01,''), ISNULL(UserDefine02,''), ISNULL(UserDefine03,''), ISNULL(UserDefine04,''), ISNULL(UserDefine05,''),
                           UserDefine06, UserDefine07, ISNULL(UserDefine08,''), ISNULL(UserDefine09,''), @cCaseID,
                           ISNULL(POLineNumber,''), SubReasonCode, @cActualLineNumber, Channel,
                           GETDATE(), SUSER_SNAME(), GETDATE(), SUSER_SNAME()
                        FROM dbo.ReceiptDetail WITH (NOLOCK)
                        WHERE ReceiptKey = @cReceiptKey
                          AND ReceiptLineNumber = @cActualLineNumber

                        -- Update original line: REMAINING portion
                        -- Set ToID='#' to prevent Exact Match and Blank Line selection
                        -- This forces next receive to use Step 3.2 (borrow from this line)
                        UPDATE dbo.ReceiptDetail
                        SET QTYExpected = @nRemainingQTY,
                            BeforeReceivedQTY = 0,
                            ToID = '#',
                            EditWho = SUSER_SNAME(),
                            EditDate = GETDATE()
                        WHERE ReceiptKey = @cReceiptKey
                          AND ReceiptLineNumber = @cActualLineNumber
                     END
                     ELSE
                     BEGIN
                        -- No split needed, just update Case ID
                        UPDATE dbo.ReceiptDetail
                        SET UserDefine10 = @cCaseID,
                            EditWho = SUSER_SNAME(),
                            EditDate = GETDATE()
                        WHERE ReceiptKey = @cReceiptKey
                          AND ReceiptLineNumber = @cActualLineNumber
                     END

                     FETCH NEXT FROM curLines INTO @cActualLineNumber, @nQTYExpected, @nBeforeReceivedQTY
                  END

                  CLOSE curLines
                  DEALLOCATE curLines
               END
               ELSE
               BEGIN
                  -- Non-PVAR item, just update Case ID on all lines that received qty
                  UPDATE dbo.ReceiptDetail
                  SET UserDefine10 = @cCaseID,
                      EditWho = SUSER_SNAME(),
                      EditDate = GETDATE()
                  WHERE ReceiptKey = @cReceiptKey
                    AND StorerKey = @cStorerKey
                    AND SKU = @cSKU
                    AND BeforeReceivedQTY > 0
                    AND (UserDefine10 IS NULL OR UserDefine10 = '' OR UserDefine10 = 'KG' OR UserDefine10 = 'CX')
               END
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

GRANT EXECUTE ON rdt.rdt_600ExtUpd15BRF TO NSQL
GO
