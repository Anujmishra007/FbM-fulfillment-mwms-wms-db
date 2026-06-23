
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Stored Procedure: rdt_600ExtValARLA                                       */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : Validation of SSCC Number during Receiving    UWP-59503         */
/*                                                                           */
/* Called By:  rdt_600ExtValARLA                                             */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043   1.0  Initial version created                        */
/*****************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_600ExtValARLA] (
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
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 600 -- Normal receiving
   BEGIN
      IF @nStep = 3 -- ToID
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Receive to ID
            IF @cID <> ''
            BEGIN
               -- New ID
               IF NOT EXISTS( SELECT 1 FROM dbo.ReceiptDetail RD WITH (NOLOCK)
               INNER JOIN dbo.RECEIPT R WITH (NOLOCK) 
                  ON R.RECEIPTKEY=RD.RECEIPTKEY 
                  AND R.STORERKEY=RD.STORERKEY
               LEFT JOIN dbo.LOTXLOCXID LLI WITH (NOLOCK) 
                  ON LLI.STORERKEY=@cStorerKey 
                  AND LLI.ID IN (@cID)
               --WHERE RD.ReceiptKey = @cReceiptKey AND RD.ToID = @cID AND R.RECType IN ('DXDOCK','IXDOCK','PACKED','XDOCK'))   

                  WHERE RD.ReceiptKey = @cReceiptKey 
                  AND RD.ToID = @cID 
                  AND R.RECType IN (
               SELECT CODE FROM dbo.CODELKUP WITH (NOLOCK) 
               WHERE STORERKEY=@cStorerKey
               AND LISTNAME='RECTYPE' AND UDF01='Y') )  
              
                  BEGIN
                     SET @nErrNo = 271351
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SSCC
                     GOTO Quit
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

GRANT EXECUTE ON [RDT].[rdt_600ExtValARLA] TO NSQL
GO

