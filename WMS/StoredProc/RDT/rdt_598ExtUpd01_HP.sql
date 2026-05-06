SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Stored procedure: RDT.rdt_598ExtUpd01_HP                                   */
/* Based on:      rdt_598ExtUpd01 (Extended Putaway – Container Receive)      */
/* Purpose:       Implements noted fixes for Function 598, Step 6 (QTY/ENTER) */
/*                - Promote other RECEIPT rows on same container from 0 -> 1  */
/*                - If fully received, promote current RECEIPT from 1 -> X4   */
/* Notes:         Uses @cRefNo as container key and @cReceiptKey as current   */
/*                receipt. Filters by @cStorerKey.                            */
/* Author:        Andrew Betteridge                                           */
/* Date:          2025-09-18                                                  */
/******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_598ExtUpd01_HP] (
     @nMobile             INT
   , @nFunc               INT
   , @cLangCode           NVARCHAR(3)
   , @nStep               INT
   , @nInputKey           INT
   , @cFacility           NVARCHAR(5)
   , @cStorerKey          NVARCHAR(15)
   , @cRefNo              NVARCHAR(20)   -- containerkey
   , @cColumnName         NVARCHAR(20)
   , @cLOC                NVARCHAR(10)
   , @cID                 NVARCHAR(18)
   , @cSKU                NVARCHAR(20)
   , @cLottable01         NVARCHAR(18)
   , @cLottable02         NVARCHAR(18)
   , @cLottable03         NVARCHAR(18)
   , @dLottable04         DATETIME
   , @dLottable05         DATETIME
   , @cLottable06         NVARCHAR(30)
   , @cLottable07         NVARCHAR(30)
   , @cLottable08         NVARCHAR(30)
   , @cLottable09         NVARCHAR(30)
   , @cLottable10         NVARCHAR(30)
   , @cLottable11         NVARCHAR(30)
   , @cLottable12         NVARCHAR(30)
   , @dLottable13         DATETIME
   , @dLottable14         DATETIME
   , @dLottable15         DATETIME
   , @nQTY                INT
   , @cReasonCode         NVARCHAR(10)
   , @cSuggToLOC          NVARCHAR(10)
   , @cFinalLOC           NVARCHAR(10)
   , @cReceiptKey         NVARCHAR(10)
   , @cReceiptLineNumber  NVARCHAR(10)
   , @nErrNo              INT           OUTPUT
   , @cErrMsg             NVARCHAR(20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON;
   SET ANSI_NULLS OFF;
   SET QUOTED_IDENTIFIER OFF;
   SET CONCAT_NULL_YIELDS_NULL OFF;

   DECLARE @sumBefore DECIMAL(18,4) = 0
         , @sumExpect DECIMAL(18,4) = 0;

   BEGIN TRY
      -- default success
      SET @nErrNo  = 0;
     -- SET @cErrMsg = 'OK'; --+@cReceiptKey+@cStorerKey+@nStep+@nInputKey

      IF @nFunc = 598           -- Container receive
      AND @nStep = 14            -- QTY
      AND @nInputKey = 1        -- ENTER
      BEGIN

		--WAITFOR DELAY '00:00:01'
         BEGIN TRAN;


         ----------------------------------------------------------------------
         -- 1) If current RECEIPT is fully received (sum BeforeReceivedQty = sum
         --    QtyExpected), promote its asnstatus from '1' to 'X4'.
         --    (Adjust column names if your schema differs.)
         ----------------------------------------------------------------------
         SELECT
              @sumBefore = SUM(COALESCE(rd.BeforeReceivedQty, 0.0))
            , @sumExpect = SUM(COALESCE(rd.QtyExpected,       0.0))
         FROM dbo.ReceiptDetail rd
         WHERE rd.ReceiptKey = @cReceiptKey;

         IF @sumBefore = @sumExpect
         BEGIN
            UPDATE r
               SET r.asnstatus = 'X4'
            FROM dbo.Receipt r
            WHERE r.receiptkey = @cReceiptKey
              AND r.asnstatus  = '1';
         END

         COMMIT TRAN;
      END

      GOTO Quit;
   END TRY
   BEGIN CATCH
      IF XACT_STATE() <> 0 ROLLBACK TRAN;

      SET @nErrNo  = ERROR_NUMBER();
      SET @cErrMsg = LEFT(CONCAT(N'ERR ', CONVERT(NVARCHAR(10), ERROR_NUMBER())), 20);

      GOTO Quit;
   END CATCH

Quit:
PRINT 'Error message '  + LEFT(CONCAT(N'ERR ', CONVERT(NVARCHAR(10), ERROR_NUMBER())), 20);
PRINT 'Error message '  + @cErrMsg;
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_598ExtUpd01_HP] TO NSQL
GO
