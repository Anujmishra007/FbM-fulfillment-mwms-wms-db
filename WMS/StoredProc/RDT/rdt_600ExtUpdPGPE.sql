/******************************************************************************/
/* Store procedure: rdt_600ExtUpdPGPE                                         */
/* Copyright      : LF Logistics                                              */
/* Customer       : PGPE                                                      */
/*                                                                            */
/* Purpose: Assign STICKERING value within ReceiptDetail.Lottable11 and       */
/* automatic printing of Senasa labels                                        */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-03-25   FRO014    1.0   RITM9002088/UWP-61804                         */
/*                              Assigns the STICKERING flag to specific SKUs, */
/*                              and auto-prints the SENASA label once per     */
/*                              pallet.                                       */
/* 2026-07-03   FRO014    2.0   RITM9054096/UWP-63764                         */
/*                              Change to the trigger of the Stickering       */
/*                              process: from Step 4 to Step 6 and  update    */
/*                                the LOTATTRIBUTE table                        */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_600ExtUpdPGPE]
   @nMobile            INT,
   @nFunc              INT,
   @cLangCode          NVARCHAR( 3),
   @nStep              INT,
   @nInputKey          INT,
   @cFacility          NVARCHAR( 5),
   @cStorerKey         NVARCHAR( 15),
   @cReceiptKey        NVARCHAR( 10),
   @cPOKey             NVARCHAR( 10),
   @cLOC               NVARCHAR( 10),
   @cID                NVARCHAR( 18),
   @cSKU               NVARCHAR( 20),
   @cLottable01        NVARCHAR( 18),
   @cLottable02        NVARCHAR( 18),
   @cLottable03        NVARCHAR( 18),
   @dLottable04        DATETIME,
   @dLottable05        DATETIME,
   @cLottable06        NVARCHAR( 30),
   @cLottable07        NVARCHAR( 30),
   @cLottable08        NVARCHAR( 30),
   @cLottable09        NVARCHAR( 30),
   @cLottable10        NVARCHAR( 30),
   @cLottable11        NVARCHAR( 30),
   @cLottable12        NVARCHAR( 30),
   @dLottable13        DATETIME,
   @dLottable14        DATETIME,
   @dLottable15        DATETIME,
   @nQTY               INT,
   @cReasonCode        NVARCHAR( 10),
   @cSuggToLOC         NVARCHAR( 10),
   @cFinalLOC          NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 10),
   @nErrNo             INT           OUTPUT,
   @cErrMsg            NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStickering        NVARCHAR( 10)
   DECLARE @cLot             NVARCHAR( 10)

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 6 -- Input QTY  --> Change UWP-63764
      BEGIN
       -- Logic for applying stickering --Start
         SELECT TOP 1 @cSKU = SKU
         FROM dbo.UPC WITH (NOLOCK)
         WHERE (SKU = @cSKU OR UPC = @cSKU)
            AND StorerKey = @cStorerKey

         SELECT @cStickering = BUSR9
         FROM dbo.SKU WITH (NOLOCK)
         WHERE SKU = ISNULL(@cSKU, '')
            AND StorerKey = @cStorerKey

        SELECT  TOP 1    @cLot = LLI.Lot
        FROM    dbo.RECEIPTDETAIL RD WITH (NOLOCK) INNER JOIN
                dbo.LOTxLOCxID LLI  WITH (NOLOCK) ON
                RD.ToLoc = LLI.Loc
        AND     RD.ToId = LLI.ID
        AND     RD.StorerKey = LLI.StorerKey
        AND        RD.Sku = LLI.SKU
        WHERE    RD.ReceiptKey = @cReceiptKey
        AND        RD.ReceiptLineNumber = @cReceiptLineNumber
        AND        RD.StorerKey = @cStorerKey

         IF ISNULL(@cStickering, '') <> ''
         BEGIN
             BEGIN TRY
                UPDATE    dbo.RECEIPTDETAIL WITH (ROWLOCK)
                SET        Lottable11 = 'STICKERING'
                WHERE    ReceiptKey = @cReceiptKey
                   AND    ReceiptLineNumber = @cReceiptLineNumber
                   AND    StorerKey = @cStorerKey

                UPDATE    dbo.LOTATTRIBUTE WITH (ROWLOCK)
                SET        Lottable11 = 'STICKERING'
                WHERE    StorerKey = @cStorerKey
                   AND  SKU = @cSKU
                   AND  Lot = @cLot

             END TRY
             BEGIN CATCH
                SET @nErrNo = 275058
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdStickerFail
                GOTO Quit
             END CATCH
         END
         -- Logic for applying stickering -- end

         -- Report configure - Start
         DECLARE @cPalletLabel  NVARCHAR( 10)
         DECLARE @cPrintedLabel NVARCHAR( 60)

         SET @cPalletLabel = ISNULL((
            SELECT ReportType
            FROM rdt.RDTReport WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND ReportType = 'SenasaLBL'
         ), '')

         SET @cPrintedLabel = ISNULL((
            SELECT TOP 1 UserDefine10
            FROM dbo.RECEIPTDETAIL WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND ReceiptKey = @cReceiptKey
               AND ToId = @cID
               AND UserDefine10 <> ''
         ), '')

         -- Label exists and has not been printed for this pallet
         IF @cPalletLabel <> '' AND @cPrintedLabel = ''
         BEGIN
            -- Get printer
            DECLARE @cPrinter      NVARCHAR( 10)
            DECLARE @cPaperPrinter NVARCHAR( 10)

            SELECT
               @cPrinter      = Printer,
               @cPaperPrinter = Printer_Paper
            FROM rdt.rdtMobRec WITH (NOLOCK)
            WHERE Mobile = @nMobile

            IF @cPrinter <> ''
            BEGIN
               -- Mark as printed before sending to avoid double-print on retry
               BEGIN TRY
                  UPDATE dbo.RECEIPTDETAIL WITH (ROWLOCK)
                  SET UserDefine10 = 'LBL_IMPRESO'
                  WHERE ReceiptKey = @cReceiptKey
                     AND ReceiptLineNumber = @cReceiptLineNumber
                     AND StorerKey = @cStorerKey
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 275059
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UpdPrintedFail
                  GOTO Quit
               END CATCH

               -- Common params
               DECLARE @tPalletLabel dbo.VariableTable
               INSERT INTO @tPalletLabel (Variable, Value) VALUES
                  ('@cReceiptKey', @cReceiptKey),
                  ('@cToID',       @cID)

               -- Print label
               EXEC RDT.rdt_Print
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey,
                  @cFacility, @cStorerKey, @cPrinter, @cPaperPrinter,
                  @cPalletLabel,  -- Report type
                  @tPalletLabel,  -- Report params
                  'rdt_600ExtUpdPGPE',
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit
            END
         END
         -- Report configure - End
      END
   END

Quit:
END
GO

GRANT EXECUTE ON [RDT].[rdt_600ExtUpdPGPE] TO [NSQL]
GO
