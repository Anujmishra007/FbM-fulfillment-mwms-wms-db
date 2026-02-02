
/****** Object:  StoredProcedure [RDT].[rdt_685ExtUpdJCB]    Script Date: 7/15/2025 2:41:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/
/* Store procedure: [rdt_685ExtUpdJCB]                                                              */
/* Copyright: Maersk                                                                                */
/*                                                                                                  */
/* Date         Rev   Author   Purposes                                                             */
/* 12/03/2025   1.0   SKE140   Created                                                              */
/****************************************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_685ExtUpdJCB] (
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
   @nQTY         INT,            
   @cReasonCode  NVARCHAR( 10),  
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
   @cReceiptLineNumber NVARCHAR( 5),     
   @nErrNo       INT            OUTPUT,  
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cAddUser       NVARCHAR(20),
      @nLength        INT,
      @nWidth         INT,
      @nHeight        INT,
      @nWeight        INT,
      @cPalletType    NVARCHAR(20);

   SELECT 
      @cAddUser = UserName, 
	  @cStorerKey = StorerKey
    --  @cLottable11 = V_Lottable11
   FROM RDT.RDTMOBREC WITH(NOLOCK) 
   WHERE Mobile = @nMobile;

   IF @nFunc = 685
   BEGIN
      IF @nStep = 6
      BEGIN
         IF @nInputKey = 1
         BEGIN
            DECLARE
               @dAddDate     DATE,
               @cUDF01       NVARCHAR(50),
               @cUDF02       NVARCHAR(50),
               @cUDF03       NVARCHAR(50),
               @cUDF04       NVARCHAR(50),
               @cUDF05       NVARCHAR(50),
               @cUDF06       NVARCHAR(50),
               @cUDF07       NVARCHAR(50),
               @cUDF08       NVARCHAR(50),
               @cUDF09       NVARCHAR(50),
               @cUDF10       NVARCHAR(50),
               @cUDF11       NVARCHAR(50),
               @cUDF12       NVARCHAR(50);

            SELECT TOP 1
               @cReceiptKey = V_ReceiptKey,
               @cPOKey = V_POKey,
               @cLOC = V_LOC,
               @cID = V_ID,
             --  @dAddDate = GETDATE(),
               @cAddUser = UserName,
               @cUDF01 = '', @cUDF02 = '', @cUDF03 = '', @cUDF04 = '', @cUDF05 = '',
               @cUDF06 = '', @cUDF07 = '', @cUDF08 = '', @cUDF09 = '', @cUDF10 = '',
               @cUDF11 = '', @cUDF12 = ''
            FROM rdt.RDTMOBREC WITH(NOLOCK)
            WHERE Mobile = @nMobile;

            --IF Provided LPN is not in the table, then inserting the record in the table
            IF NOT EXISTS (
			   SELECT 1 
               FROM ReceiptJCBXLPNCounter WITH(NOLOCK) 
               WHERE LPN = @cID
			)
            BEGIN
               INSERT INTO ReceiptJCBXLPNCounter (
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
            IF EXISTS (
			   SELECT 1 
               FROM ReceiptJCBXLPNCounter WITH(NOLOCK) 
               WHERE LPN = @cID
			)
            BEGIN 
               UPDATE ReceiptJCBXLPNCounter WITH(ROWLOCK)
               SET PO = @cPOKey, ASN = @cReceiptKey, LOC = @cLoc, 
                   AddUser = @cAddUser, STATUS = 'RECEIVED'
               WHERE LPN = @cID
            END

            --Check if printing is required
            DECLARE @cPalletLabel NVARCHAR(10);
            SET @cPalletLabel = rdt.RDTGetConfig(@nFunc, 'XDOCKPrint', @cStorerKey);
                    
            IF @cPalletLabel = '0'
               SET @cPalletLabel = '';

            IF @cPalletLabel <> '' --AND @cLottable11 <> ''
            BEGIN
               -- Get printers
               DECLARE 
                  @cLabelPrinter NVARCHAR(10),
                  @cPaperPrinter NVARCHAR(10);

               SELECT 
                  @cLabelPrinter = Printer, 
                  @cPaperPrinter = Printer_Paper 
               FROM rdt.RDTMOBREC WITH(NOLOCK) 
               WHERE Mobile = @nMobile;

               -- Common parameters table
               DECLARE @tPalletLabel VariableTable;
               INSERT INTO @tPalletLabel (Variable, Value)
               VALUES 
                  /*('@nMobile',           convert(nvarchar,@nMobile)),
                  ('@cStorerKey',         @cStorerKey),  
                  ('@cFacility',          @cFacility),
                  ('@cReceiptKey',        @cReceiptKey),  
                  ('@cReceiptLineNumber', @cReceiptLineNumber),  
                  ('@cPOKey',             @cPOKey),  
                  ('@cToID',              @cID),
               --   ('@cLottable11',        @cLottable11),
                  ('@cSKU',               @cSKU),
                  ('@nQTY',               convert(nvarchar,@nQTY));*/

				  ('@cReceiptKey',        @cReceiptKey),
				  ('@cToID',              convert(NVARCHAR(20),@cID)),
                  ('@nMobile',            convert(nvarchar,@nMobile))

               -- Print label
               EXEC RDT.rdt_Print 
                  @nMobile, 
                  @nFunc, 
                  @cLangCode, 
                  @nStep, 
                  @nInputKey, 
                  @cFacility, 
                  @cStorerKey, 
                  @cLabelPrinter, 
                  @cPaperPrinter, 
                  @cPalletLabel, 
                  @tPalletLabel, 
                  'rdt_685ExtUpdJCB', 
                  @nErrNo OUTPUT,
                  @cErrMsg OUTPUT;

               IF @nErrNo <> 0
                  RETURN;
            END
         END
      END
   END
END

GO
GRANT EXECUTE ON [RDT].[rdt_685ExtUpdJCB] TO [NSQL]
GO
