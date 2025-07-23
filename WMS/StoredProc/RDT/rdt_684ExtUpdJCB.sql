
/****** Object:  StoredProcedure [RDT].[rdt_684ExtUpdJCB]    Script Date: 7/15/2025 2:06:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************************************************************/
/* Store procedure: [rdt_684ExtUpdJCB]                                                               */
/* Copyright: Maersk                                                                                 */
/*                                                                                                   */
/* Date         Rev   Author   Purposes                                                              */
/* 12/03/2025   1.0   PPA374   Created                                      	                     */
/* 12/03/2025   1.0   PPA374   Update the LOC in the table ReceiptJCBLPNCounter	                     */
/* 12/03/2025   1.0   PPA374   Delete the record from ReceiptJCBLPNCounter when going back to step 2 */
/*****************************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_684ExtUpdJCB] (
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
   @nQTY         INT,
   @cReasonCode  NVARCHAR( 10),
   @cSuggToLOC   NVARCHAR( 10),
   @cFinalLOC    NVARCHAR( 10),
   @cReceiptLineNumber NVARCHAR( 10),
   @nErrNo             INT            OUTPUT,
   @cErrMsg            NVARCHAR( 20)  OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE
      @cAddUser AS NVARCHAR(20),
	  @nLength AS INT,
	  @nWidth AS INT,
	  @nHeight AS INT,
	  @nWeight AS float,
	  @cPalletType AS NVARCHAR(20),
	  @nTempErr AS INT,
	  @cLPRINTER AS NVARCHAR(20)

   SELECT TOP 1 @cLPRINTER = Printer FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile

   SET @nTempErr = 0

   SELECT 
      @cAddUser = UserName, 
      @cLottable11 = V_Lottable11
   FROM RDT.RDTMOBREC WITH(NOLOCK) 
   WHERE Mobile = @nMobile

   IF @nFunc = 684
   BEGIN
      IF @nStep = 3 --ID
      BEGIN

		 IF @nInputKey = 0
         BEGIN
            -- Deleting inserted row, as receipt has not happened.
            DELETE FROM ReceiptJCBLPNCounter 
            WHERE LPN = (SELECT MAX(LPN) 
                         FROM ReceiptJCBLPNCounter WITH(NOLOCK) 
                         WHERE AddUser = @cAddUser 
                         AND ISNULL(STATUS,'') IN ('NOT RECEIVED',''))
         END
      END

	  IF @nStep = 4 --SKU
	  BEGIN
	     IF @nInputKey = 1
		 BEGIN
		    IF EXISTS (SELECT 1 FROM SKU S WITH(NOLOCK) WHERE SKU = @cSKU AND ISNULL(IVAS,'') = '' AND ISNULL(STDGROSSWGT,'') IN (0,''))
			BEGIN
			   UPDATE SKU WITH(ROWLOCK)
			   SET IVAS = '!Weight is 0!'
			   WHERE SKU = @cSKU
			END

			IF EXISTS (SELECT 1 FROM SKU S WITH(NOLOCK) WHERE SKU = @cSKU AND ISNULL(IVAS,'') = '!Weight is 0!' AND ISNULL(STDGROSSWGT,'') NOT IN (0,''))
			BEGIN
			   UPDATE SKU WITH(ROWLOCK)
			   SET IVAS = ''
			   WHERE SKU = @cSKU
			END
		 END
	  END

      IF @nStep = 6 --QTY
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE
               @dAddDate AS DATETIME,
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
               @cUDF12 AS NVARCHAR(50)

            SELECT TOP 1
               @cReceiptKey = V_ReceiptKey,
               @cPOKey = V_POKey,
               @cLoc = V_Loc,
               @cID = V_ID,
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
               @cUDF12 = ''
            FROM rdt.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile 

			--IF Provided LPN is not in the table, then inserting the record in the table
            IF NOT EXISTS (SELECT 1 
                           FROM ReceiptJCBLPNCounter WITH(NOLOCK) 
                           WHERE LPN = @cID)
            BEGIN
               INSERT INTO ReceiptJCBLPNCounter (
                  PO, ASN, LOC, LPN, AddDate, AddUser, 
                  UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, 
                  UDF07, UDF08, UDF09, UDF10, UDF11, UDF12, STATUS
               )
               VALUES (
                  @cPOKey, @cReceiptKey, @cLoc, @cID, @dAddDate, @cAddUser, 
				  @cUDF01, @cUDF02, @cUDF03, @cUDF04, @cUDF05, @cUDF06, 
				  @cUDF07, @cUDF08, @cUDF09, @cUDF10, @cUDF11, @cUDF12, 'RECEIVED'
               );
            END

			--If provided record is in the table then updating it on receipt
            IF EXISTS (SELECT 1 
                       FROM ReceiptJCBLPNCounter WITH(NOLOCK) 
                       WHERE LPN = @cID)
            BEGIN 
               UPDATE ReceiptJCBLPNCounter WITH(ROWLOCK)
               SET PO = @cPOKey, ASN = @cReceiptKey, LOC = @cLoc, 
                   AddUser = @cAddUser, STATUS = 'RECEIVED'
               WHERE LPN = @cID
            END

			--If provided CASE_LPN is not in the table, then inserting the record in the table
            IF NOT EXISTS (SELECT 1 
                           FROM ReceiptJCBCaseCounter WITH(NOLOCK) 
                           WHERE CaseLPN = @cLottable11) 
               AND @cLottable11 <> ''
            BEGIN
               INSERT INTO ReceiptJCBCaseCounter (
                  PO, ASN, LOC, CaseLPN, AddDate, AddUser, 
                  UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, 
                  UDF07, UDF08, UDF09, UDF10, UDF11, UDF12, STATUS
               )
               VALUES (
                  @cPOKey, @cReceiptKey, @cLoc, @cLottable11, @dAddDate, @cAddUser,
                  @cUDF01, @cUDF02, @cUDF03, @cUDF04, @cUDF05, @cUDF06,
                  @cUDF07, @cUDF08, @cUDF09, @cUDF10, @cUDF11, @cUDF12, 'RECEIVED'
               );
            END

			--If provided record is in the table then updating it on receipt
            IF EXISTS (SELECT 1 
                       FROM ReceiptJCBCaseCounter WITH(NOLOCK) 
                       WHERE CaseLPN = @cLottable11)
            BEGIN 
               UPDATE ReceiptJCBCaseCounter WITH(ROWLOCK)
               SET PO = @cPOKey, ASN = @cReceiptKey, LOC = @cLoc, 
                   AddUser = @cAddUser, STATUS = 'RECEIVED'
               WHERE CaseLPN = @cLottable11
            END

            --Check if printing is required
            DECLARE @cPalletLabel NVARCHAR( 10)
            SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'CaseLabel', @cStorerKey)
            IF @cPalletLabel = '0' OR TRIM(@cLPRINTER) = ''
               SET @cPalletLabel = ''

            -- Pallet label
            IF @cPalletLabel <> '' AND @cLottable11 <> ''
            BEGIN
               -- Get printer
               DECLARE @cLabelPrinter NVARCHAR( 10)
               DECLARE @cPaperPrinter NVARCHAR( 10)
               SELECT 
                  @cLabelPrinter = Printer, 
                  @cPaperPrinter = Printer_Paper 
               FROM rdt.rdtMobRec WITH (NOLOCK) 
               WHERE Mobile = @nMobile

               -- Common params
               DECLARE @tPalletLabel AS VariableTable
               INSERT INTO @tPalletLabel (Variable, Value) VALUES 
                  ( '@nMobile',            CONVERT(NVARCHAR(50),@nMobile)),
				  ( '@cStorerKey',         @cStorerKey),  
				  ( '@cFacility',          @cFacility),
                  ( '@cReceiptKey',        @cReceiptKey),  
                  ( '@cReceiptLineNumber', @cReceiptLineNumber),  
                  ( '@cPOKey',             @cPOKey),  
                  ( '@cToID',              @cID),
				  ( '@cLottable11',        @cLottable11),
				  ( '@cSKU',               @cSKU),
				  ( '@nQTY',               CONVERT(NVARCHAR(50),@nQTY))
				  
               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter, @cPaperPrinter, 
                  @cPalletLabel, -- Report type
                  @tPalletLabel, -- Report params
                  'rdt_684ExtUpdJCB', 
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit
            END
		 UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
		 SET UserDefine10 = 'N'
		 WHERE ReceiptKey = @cReceiptKey
		 AND ToId = @cID
		 AND StorerKey = @cStorerKey
         END
      END

	  IF @nStep = 15 AND @nInputKey = 1
	  BEGIN
	     
		 DECLARE @cNotes AS NVARCHAR(MAX) = ''

	     SET @nErrNo = 0

		 IF (SELECT TOP 1 PalletType FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) WHERE ToId = @cID AND ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey) = 'M'
		 BEGIN
		    SET @cPalletType = 'M'
		 END

		 ELSE IF (SELECT COUNT(DISTINCT COL1)
                 FROM (
                      SELECT SKU AS COL1, ToId AS COL2
                      FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
                      WHERE ReceiptKey = @cReceiptKey AND ToId = @cID AND StorerKey = @cStorerKey
                      )T1) = 1
		 BEGIN
		    SELECT TOP 1 @cPalletType = Measurement, @nLength = ISNULL(Length,''), @nWidth = ISNULL(Width,''), @nHeight = ISNULL(Height,'')
			   FROM dbo.SKU S WITH(NOLOCK) 
			   INNER JOIN dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
			   ON S.Sku = RD.Sku 
			   WHERE ToId = @cID 
			   AND RD.SKU <> '' 
			   AND RD.StorerKey = @cStorerKey
		 END

		 ELSE
		 BEGIN
            SELECT TOP 1 @cPalletType = Description, @cNotes = Notes
            FROM (
                 SELECT Code, Description, Notes, STRING_AGG(Value, ',') WITHIN GROUP (ORDER BY Value)SKUSET
                 FROM (
                      SELECT Short AS Value, Description, Code, Notes FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBSKUPAL' AND Storerkey = @cStorerKey
                      UNION
                      SELECT Long, Description, Code, Notes FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBSKUPAL' AND Storerkey = @cStorerKey
                      UNION
                      SELECT UDF01, Description, Code, Notes FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBSKUPAL' AND Storerkey = @cStorerKey
                      UNION
                      SELECT UDF02, Description, Code, Notes FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBSKUPAL' AND Storerkey = @cStorerKey
                      UNION
                      SELECT UDF03, Description, Code, Notes FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBSKUPAL' AND Storerkey = @cStorerKey
                      UNION ALL
                      SELECT UDF04, Description, Code, Notes FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBSKUPAL' AND Storerkey = @cStorerKey
                      UNION ALL
                      SELECT UDF05, Description, Code, Notes FROM CODELKUP WITH(NOLOCK) WHERE LISTNAME = 'JCBSKUPAL' AND Storerkey = @cStorerKey
                      ) AS AllValues
                  WHERE Value IS NOT NULL AND LTRIM(RTRIM(Value)) <> ''
                  GROUP BY Description, Code, Notes
                  ) AS ST1
                  JOIN (
                       SELECT 
                          COL2, 
                          CASE WHEN LEFT(STRING_AGG(COL1, ',')WITHIN GROUP(ORDER BY COL2),1)=',' THEN SUBSTRING(STRING_AGG(COL1, ',')WITHIN GROUP(ORDER BY COL2),2,LEN(STRING_AGG(COL1, ',')WITHIN GROUP(ORDER BY COL2))) ELSE STRING_AGG(COL1, ',')WITHIN GROUP(ORDER BY COL2) END AS SKUSET
                          FROM (
                               SELECT DISTINCT COL1, COL2
                               FROM (
                                    SELECT SKU AS COL1, ToId AS COL2
                                    FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
                                    WHERE ReceiptKey = @cReceiptKey AND ToId = @cID AND Storerkey = @cStorerKey
                                    ) AS T1
                               ) AS T2
                       GROUP BY COL2
                       ) AS ST2
                  ON ST1.SKUSET = ST2.SKUSET;

		    SELECT TOP 1
            @nLength = ISNULL(MAX(IIF(rn = 1, VAL, '')),0),
            @nWidth = ISNULL(MAX(IIF(rn = 2, VAL, '')),0),
            @nHeight = ISNULL(MAX(IIF(rn = 3, VAL, '')),0)
            FROM
            (SELECT 
               LTRIM(RTRIM(value)) AS val,
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
               FROM STRING_SPLIT(@cNotes, ','))T1

		 END

		 IF @cPalletType IS NULL OR @cPalletType = 'U'
		 BEGIN
		    SET @cPalletType = 'U'
			SET @nTempErr = -1
		 END

		 IF EXISTS (SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) WHERE ToId = @cID AND PalletType <> 'M' AND (@cPalletType IS NULL OR @cPalletType = 'U') AND 
		 EXISTS (SELECT 1 FROM SKU S WITH(NOLOCK) WHERE RD.SKU = S.Sku AND ISNULL(STDGROSSWGT,'') IN ('0','')))
		 OR (SELECT TOP 1 PalletType FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) WHERE ToId = @cID AND ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey) <> @cPalletType
		 OR (SELECT TOP 1 PalletType FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) WHERE ToId = @cID AND ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey) = 'U'
		 BEGIN
		    UPDATE dbo.RECEIPTDETAIL
		    SET PalletType = 'U'
		    WHERE ToId = @cID

			SET @cPalletType = 'U'
			SET @nTempErr = -1
		 END

		 IF NOT EXISTS (SELECT 1 FROM PALLET P WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND PalletKey = @cID) AND @cPalletType NOT IN ('U','')
		 BEGIN

		    SELECT TOP 1 @nWeight = SUM(BeforeReceivedQty * CAST(STDGROSSWGT AS FLOAT))
		    , @nLength = IIF(ISNULL(@nLength,0) = 0,Length/10,@nLength)
			, @nWidth = IIF(ISNULL(@nWidth,0) = 0,Width/10,@nWidth)
			, @nHeight = IIF(ISNULL(@nHeight,0) = 0,Height/10,@nHeight)
			, @cPalletType = PalletType FROM
            (SELECT RD.PalletType, RD.SKU, BeforeReceivedQty, STDGROSSWGT, PTM.Length, PTM.Width, PTM.Height FROM RECEIPTDETAIL RD WITH(NOLOCK)
            INNER JOIN SKU S WITH(NOLOCK)
            ON RD.Sku = S.Sku
            INNER JOIN PalletTypeMaster PTM WITH(NOLOCK)
            ON PTM.PalletType = RD.PalletType
            WHERE RD.StorerKey = @cStorerKey
            AND ToId = @cID)T1
            GROUP BY Length, Width, Height, PalletType

		    INSERT INTO PALLET (
		    PalletKey, StorerKey, Status, EffectiveDate, AddDate, AddWho, EditDate, EditWho, TrafficCop, ArchiveCop, TimeStamp, Length, Width, Height, GrossWgt, PalletType)
		    VALUES(@cID, @cStorerKey, '0', GETDATE(), GETDATE(), @cAddUser, GETDATE(), @cAddUser, NULL, NULL, NULL, @nLength, @nWidth, @nHeight, @nWeight, @cPalletType)
		 END

		 IF EXISTS (SELECT 1 FROM PALLET P WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND PalletKey = @cID) AND @cPalletType <> 'U'
		 BEGIN
		    UPDATE PALLET WITH(ROWLOCK)
			SET EditDate = GETDATE(), EditWho = @cAddUser, Length = @nLength, Width = @nWidth, Height = @nHeight, GrossWgt = @nWeight, PalletType = @cPalletType
			WHERE PalletKey = @cID
		 END

		 IF EXISTS (SELECT 1 FROM PALLET P WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND PalletKey = @cID) AND @cPalletType = 'U'
		 BEGIN
		    DELETE FROM PALLET WITH(ROWLOCK)
			WHERE PalletKey = @cID
		 END

		 UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
		 SET UserDefine10 = 'Y'
		 WHERE ReceiptKey = @cReceiptKey
		 AND ToId = @cID
		 AND StorerKey = @cStorerKey

		    --Check if printing is required
            DECLARE @cPalletLabel2 NVARCHAR( 20)
            SET @cPalletLabel2 = rdt.RDTGetConfig( @nFunc, 'PalLabel', @cStorerKey)
            IF @cPalletLabel2 = '0' OR TRIM(@cLPRINTER) = ''
               SET @cPalletLabel2 = ''

			IF @cPalletLabel2 <> '' AND EXISTS(SELECT 1 FROM RECEIPTDETAIL WITH(NOLOCK) WHERE ReceiptKey = @cReceiptKey AND ToId = @cID AND Lottable11 <> '')
			BEGIN
			   SET @cPalletLabel2 = 'MPalletLBL'
			END

            -- Pallet label
            IF @cPalletLabel2 <> ''
            BEGIN
               -- Get printer
               DECLARE @cLabelPrinter2 NVARCHAR( 10)
               DECLARE @cPaperPrinter2 NVARCHAR( 10)
               SELECT 
                  @cLabelPrinter2 = Printer, 
                  @cPaperPrinter2 = Printer_Paper 
               FROM rdt.rdtMobRec WITH (NOLOCK) 
               WHERE Mobile = @nMobile

               -- Common params
               DECLARE @tPalletLabel2 AS VariableTable
               INSERT INTO @tPalletLabel2 (Variable, Value) VALUES 
                  ( '@nMobile',            CONVERT(NVARCHAR(50),@nMobile)),
				  ( '@cStorerKey',         @cStorerKey),  
				  ( '@cFacility',          @cFacility),
                  ( '@cReceiptKey',        @cReceiptKey),  
                  ( '@cReceiptLineNumber', @cReceiptLineNumber),  
                  ( '@cPOKey',             @cPOKey),  
                  ( '@cToID',              @cID),
				  ( '@cLottable11',        @cLottable11),
				  ( '@cSKU',               @cSKU),
				  ( '@nQTY',               CONVERT(NVARCHAR(50),@nQTY))
				  
               -- Print label
               EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cLabelPrinter2, @cPaperPrinter2, 
                  @cPalletLabel2, -- Report type
                  @tPalletLabel2, -- Report params
                  'rdt_684ExtUpdJCB', 
                  @nErrNo  OUTPUT,
                  @cErrMsg OUTPUT

               IF @nErrNo <> 0
                  GOTO Quit
            END
      END
   END
   IF @nTempErr <> '0' SET @nErrNo = @nTempErr
Quit:
END

GO
GRANT EXECUTE ON [RDT].[rdt_684ExtUpdJCB] TO [NSQL]
GO

