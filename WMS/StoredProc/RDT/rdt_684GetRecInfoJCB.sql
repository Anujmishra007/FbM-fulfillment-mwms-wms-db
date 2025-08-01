
/****** Object:  StoredProcedure [RDT].[rdt_684GetRecInfoJCB]    Script Date: 7/15/2025 1:47:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************************************/
/* Store procedure: rdt_684GetRecInfoJCB                                                           */
/* Copyright      : Maersk WMS                                                                     */
/*                                                                                                 */
/* Date         Rev   Author   Purposes                                                            */
/* 18-03-2025   1.0   PPA374   Adding step = 3 to allow lottable 03 to be updated                  */
/* 19-03-2025   2.0   PPA374   Adding lottable11 auto-gen and renaming the SP as per standards     */
/***************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_684GetRecInfoJCB]
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
  -- @ExternReceiptKey  NVARCHAR( 50), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18)  OUTPUT, 
   @cSKU         NVARCHAR( 20)  OUTPUT, 
   @nQTY         INT         OUTPUT, 
   @cLottable01  NVARCHAR( 18)  OUTPUT, 
   @cLottable02  NVARCHAR( 18)  OUTPUT, 
   @cLottable03  NVARCHAR( 18)  OUTPUT, 
   @dLottable04  DATETIME       OUTPUT, 
   @dLottable05  DATETIME       OUTPUT, 
   @cLottable06  NVARCHAR( 30)  OUTPUT, 
   @cLottable07  NVARCHAR( 30)  OUTPUT, 
   @cLottable08  NVARCHAR( 30)  OUTPUT, 
   @cLottable09  NVARCHAR( 30)  OUTPUT, 
   @cLottable10  NVARCHAR( 30)  OUTPUT, 
   @cLottable11  NVARCHAR( 30)  OUTPUT, 
   @cLottable12  NVARCHAR( 30)  OUTPUT, 
   @dLottable13  DATETIME       OUTPUT, 
   @dLottable14  DATETIME       OUTPUT, 
   @dLottable15  DATETIME       OUTPUT, 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @dAddDate AS DATETIME,
      @cAddUser AS NVARCHAR(20),
      @cUDF01 AS NVARCHAR(50),
      @cUDF02 AS NVARCHAR(50),
      @cUDF03 AS NVARCHAR(50),
      @cUDF04 AS NVARCHAR(50),
      @cUDF05 AS NVARCHAR(50),
      @cUDF06 AS NVARCHAR(50),
      @cUDF07 AS NVARCHAR(50),
      @cUDF08 AS NVARCHAR(50),
      @cUDF09 AS NVARCHAR(50),
      @cUDF10 AS NVARCHAR(50),
      @cUDF11 AS NVARCHAR(50),
      @cUDF12 AS NVARCHAR(50),
      @cPalletType AS NVARCHAR(20)

   SELECT TOP 1
      @cReceiptKey = V_ReceiptKey,
      @cPOKey = V_POKey,
      @cLoc = V_Loc,
      @dAddDate = GETDATE(),
      @cAddUser = UserName,
      @cUDF01 = '',
      @cUDF02 = '',
      @cUDF03 = '',
      @cUDF04 = '',
      @cUDF05 = '',
      @cUDF06 = '',
      @cUDF07 = '',
      @cUDF08 = '',
      @cUDF09 = '',
      @cUDF10 = '',
      @cUDF11 = '',
      @cUDF12 = '',
      @cPalletType = C_String2
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile 

   IF @nFunc = 684
   BEGIN
      IF @nStep = 4
      BEGIN
         SET @cLottable02 = @cReceiptKey
         SET @cLottable03 = ''
      
         SELECT TOP 1 @cLottable03 = LEFT(ISNULL(RTRIM(RD.lottable03),'') + ' ' + ISNULL(RTRIM(C.Description),''),18)
         FROM RECEIPTDETAIL RD WITH (NOLOCK)
		 INNER JOIN CODELKUP C WITH(NOLOCK)
		 ON RD.Lottable03 = C.Short AND C.LISTNAME = 'JCBPLANT#' AND RD.StorerKey = C.Storerkey
         WHERE ReceiptKey = @cReceiptKey 
            AND Sku = @cSKU
			AND RD.StorerKey = @cStorerKey
            AND (POKey = @cPOKey OR @cPOKey = 'NOPO')                           -- TO HANDLE MULTIPLE PO

         SELECT TOP 1 @cLottable07 = ISNULL(RTRIM(receiptdetail.lottable07),'') --EXTENAL PO (JCB PO-55)
         FROM Receiptdetail WITH (NOLOCK)
         WHERE ReceiptKey = @cReceiptKey 
            AND Sku = @cSKU 
			AND StorerKey = @cStorerKey
            AND (POKey = @cPOKey OR @cPOKey = 'NOPO')                           -- TO HANDLE MULTIPLE PO

         SELECT TOP 1 @cLottable08 = LEFT(ISNULL(RTRIM(RD.Lottable08),'') + ' ' + ISNULL(RTRIM(S.Company),''),30) -- SUPPLIER ID
         FROM RECEIPTDETAIL RD WITH (NOLOCK)
         INNER JOIN STORER S WITH(NOLOCK)
         ON RD.Lottable08 = S.StorerKey AND S.type = '5'
         WHERE ReceiptKey = @cReceiptKey
            AND Sku = @cSKU 
            AND RD.StorerKey = @cStorerKey
            AND (POKey = @cPOKey OR @cPOKey = 'NOPO')                           -- TO HANDLE MULTIPLE PO

         SELECT TOP 1 @cLottable09 = ISNULL(RTRIM(receiptdetail.lottable09),'') --INVOICE NO
         FROM Receiptdetail WITH (NOLOCK)
         WHERE ReceiptKey = @cReceiptKey 
            AND Sku = @cSKU 
			AND StorerKey = @cStorerKey
            AND (POKey = @cPOKey OR @cPOKey = 'NOPO')                              -- TO HANDLE MULTIPLE PO
	   
         --Delete not received records for the lottable11
         DELETE FROM ReceiptJCBCaseCounter
         WHERE AddUser = @cAddUser AND STATUS = 'NOT RECEIVED'

         --Setting lottable11 to be the next case LPN
		 DECLARE @cCASEMAX AS NVARCHAR(20)

		 SELECT TOP 1 @cCASEMAX = MAX(Lottable11) FROM
         (SELECT Lottable11 FROM LOTATTRIBUTE WITH(NOLOCK)
         WHERE StorerKey = 'JCB'
         AND Lottable11 LIKE 'C_________'

         UNION ALL

         SELECT Lottable11 FROM RECEIPTDETAIL WITH(NOLOCK)
         WHERE StorerKey = 'JCB'
         AND ToId LIKE 'C_________')T1

         SELECT TOP 1 @cLottable11 = CASE WHEN @cPalletType <> 'M' THEN ''
         WHEN MAX(CaseLPN) IS NULL OR MAX(CaseLPN) = 'C999999999' THEN 'C000000001' 
         ELSE 'C'+RIGHT('000000000'+convert(NVARCHAR(10),right(MAX(CaseLPN),9)+1),9)
         END FROM ReceiptJCBCaseCounter WITH(NOLOCK)

		 IF 'C'+RIGHT('000000000'+convert(NVARCHAR(10),right(@cCASEMAX,9)+1),9) > @cLottable11 AND @cPalletType = 'M'
		 BEGIN
		    SET @cLottable11 = 'C'+RIGHT('000000000'+convert(NVARCHAR(10),right(@cCASEMAX,9)+1),9)
		 END

         --Inserting record in the table for 'M' type pallets
         IF @cPalletType = 'M'
         BEGIN
            INSERT INTO ReceiptJCBCaseCounter (
               PO, ASN, LOC, CaseLPN, AddDate, AddUser, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, UDF07, UDF08, UDF09, UDF10, UDF11, UDF12, STATUS
            )
            VALUES (
               @cPOKey, @cReceiptKey, ''/*@cLoc*/, @cLottable11, @dAddDate, @cAddUser, @cUDF01, @cUDF02, @cUDF03, @cUDF04, @cUDF05, @cUDF06, @cUDF07, @cUDF08, @cUDF09, @cUDF10, @cUDF11, @cUDF12, 'NOT RECEIVED'
            );
         END
      END
      
	  IF @nStep = 5
	  BEGIN
         SELECT TOP 1 @cLottable03 = LEFT(ISNULL(RTRIM(RD.lottable03),'') + ' ' + ISNULL(RTRIM(C.Description),''),18)
         FROM RECEIPTDETAIL RD WITH (NOLOCK)
		 INNER JOIN CODELKUP C WITH(NOLOCK)
		 ON RD.Lottable03 = C.Short AND C.LISTNAME = 'JCBPLANT#' AND RD.StorerKey = C.Storerkey
         WHERE ReceiptKey = @cReceiptKey 
            AND Sku = @cSKU
			AND RD.StorerKey = @cStorerKey
            AND (POKey = @cPOKey OR @cPOKey = 'NOPO')                           -- TO HANDLE MULTIPLE PO

		 SELECT TOP 1 @cLottable08 = LEFT(ISNULL(RTRIM(RD.Lottable08),'') + ' ' + ISNULL(RTRIM(S.Company),''),30) -- SUPPLIER ID
         FROM RECEIPTDETAIL RD WITH (NOLOCK)
         INNER JOIN STORER S WITH(NOLOCK)
         ON RD.Lottable08 = S.StorerKey AND S.type = '5'
         WHERE ReceiptKey = @cReceiptKey
            AND Sku = @cSKU 
            AND RD.StorerKey = @cStorerKey
            AND (POKey = @cPOKey OR @cPOKey = 'NOPO')                           -- TO HANDLE MULTIPLE PO
	  END

	  --If user goes back from the step 6 to the step 5, lottable11 remains the same
      IF @nStep = 6 AND @nInputKey = 0
	  BEGIN
         SELECT TOP 1 @cLottable11 = MAX(CaseLPN)
         FROM ReceiptJCBCaseCounter WITH(NOLOCK)
         WHERE @cPalletType = 'M' AND AddUser = @cAddUser AND STATUS = 'NOT RECEIVED'
	  END

      --Keeping no more than 1000 records in the table
      IF (SELECT COUNT(1) FROM ReceiptJCBCaseCounter WITH(NOLOCK)) >= 2000
      BEGIN
         DELETE FROM ReceiptJCBCaseCounter
         WHERE CaseLPN IN (
            SELECT TOP 1000 CaseLPN
            FROM ReceiptJCBCaseCounter
            ORDER BY AddDate ASC
            );
      END
   END
END -- End Procedure

GO
GRANT EXECUTE ON [RDT].[rdt_684GetRecInfoJCB] TO [NSQL]
GO

