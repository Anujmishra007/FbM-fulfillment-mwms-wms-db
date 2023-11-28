SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_573ExtValidSP09                                 */  
/* Copyright: MAERSK                                                    */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2023-11-09 1.0  James      WMS-24089 Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_573ExtValidSP09 (
   @nMobile       INT, 
   @nFunc         INT, 
   @cLangCode     NVARCHAR(3), 
   @nStep         INT, 
   @cStorerKey    NVARCHAR(15),
   @cFacility     NVARCHAR(5), 
   @cReceiptKey1  NVARCHAR(20),          
   @cReceiptKey2  NVARCHAR(20),          
   @cReceiptKey3  NVARCHAR(20),          
   @cReceiptKey4  NVARCHAR(20),          
   @cReceiptKey5  NVARCHAR(20),          
   @cLoc          NVARCHAR(20),           
   @cID           NVARCHAR(18),           
   @cUCC          NVARCHAR(20),           
   @nErrNo        INT          OUTPUT,            
   @cErrMsg       NVARCHAR(20) OUTPUT
)  
AS  
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   DECLARE @cRDLottable02     NVARCHAR( 18)
   DECLARE @cPIDLottable02    NVARCHAR( 18)
   
   IF @nFunc = 573 -- UCC inbound receiving
   BEGIN
      IF @nStep = 4 -- UCC
      BEGIN
      	-- Only RECTpye = 'ZPTO'
      	IF NOT EXISTS ( SELECT 1
      	                FROM dbo.RECEIPT R WITH (NOLOCK)
                         JOIN rdt.rdtConReceiveLog CR WITH (NOLOCK) ON R.ReceiptKey = CR.ReceiptKey
                         WHERE CR.Mobile = @nMobile
                         AND   R.RECType = 'ZPTO')
            GOTO Quit
         
 INSERT INTO TRACEINFO (TraceName, TimeIn, Step1, Step2) VALUES ('573', GETDATE(), @cID, @cUCC)
         -- Get this pallet id lottable02 (PO)
      	SELECT TOP 1 @cPIDLottable02 = Lottable02
      	FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
      	JOIN rdt.rdtConReceiveLog CR WITH (NOLOCK) ON RD.ReceiptKey = CR.ReceiptKey
         WHERE CR.Mobile = @nMobile
         AND   RD.ToId = @cID
         AND   rd.BeforeReceivedQty > 0   -- Received something b4
      	ORDER BY 1

      	-- Nothing received, skip checking
      	IF @@ROWCOUNT = 0
      	   GOTO Quit 

         -- Get this ucc lottable02 (PO)
      	SELECT TOP 1 @cRDLottable02 = RD.Lottable02 
         FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
         JOIN rdt.rdtConReceiveLog CR WITH (NOLOCK) ON RD.ReceiptKey = CR.ReceiptKey
         WHERE CR.Mobile = @nMobile
         AND   RD.UserDefine01 = @cUCC
      	ORDER BY 1

         -- UCCs in One Pallet Id must have the same Lottable02 (PO)
      	IF @cRDLottable02 <> @cPIDLottable02
         BEGIN
      	   SET @nErrNo = 208601
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC Diff PO#
            GOTO Quit
         END
      END
   END
   
Quit:  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_573ExtValidSP09 TO NSQL
GO



