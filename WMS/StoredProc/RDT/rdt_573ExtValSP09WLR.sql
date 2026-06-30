SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_573ExtValSP09WLR                                */  
/* Purpose: Validate  UCC                                               */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-04-03 1.0  WSE016     Fn573 COD Validation fir Wolverine (NLD)  */  
/************************************************************************/  

CREATE OR ALTER PROC [RDT].[rdt_573ExtValSP09WLR] (
      @nMobile     INT,
      @nFunc       INT,
      @cLangCode   NVARCHAR(3),
      @nStep       INT,
      @cStorerKey  NVARCHAR(15),
      @cFacility   NVARCHAR(5), 
      @cReceiptKey1 NVARCHAR(20),          
      @cReceiptKey2 NVARCHAR(20),          
      @cReceiptKey3 NVARCHAR(20),          
      @cReceiptKey4 NVARCHAR(20),          
      @cReceiptKey5 NVARCHAR(20),          
      @cLoc        NVARCHAR(20),           
      @cID         NVARCHAR(18),           
      @cUCC        NVARCHAR(20),         
      @nErrNo      INT  OUTPUT,            
      @cErrMsg     NVARCHAR(1024) OUTPUT

)  
AS  
  
SET NOCOUNT ON    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS OFF    
SET CONCAT_NULL_YIELDS_NULL OFF    
  
SET @nErrNo = 0   

Declare  
   @nInputKey INT,     
   @cPO_ToID NVARCHAR(20),  -- UCC PO To LPN
   @cPO_InID NVARCHAR(20)   -- UCC PO In LPN

   IF @nFunc = 573 -- UCC inbound receiving
   BEGIN
      -- check of LOC is part of STAGING area
      IF @nStep = 2 -- LOC
      BEGIN
         -- Get session info
         SELECT @nInputKey = InputKey FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile 
    
         IF @nInputKey = 1    
         BEGIN    
            IF EXISTS (SELECT LOC
                        FROM dbo.LOC WITH (NOLOCK)
                        WHERE facility = @cFacility
                           AND LOC = @cLoc
                           AND locationtype <> 'STAGING'
                           AND LocationCategory <>'STAGE')
            BEGIN
               SET @nErrNo = 218393
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --LOC In STAGING Area
               GOTO Quit
            END 
         END
      END--st3

      -- check if ID is already in Racking / Storage
      IF @nStep = 3 --LPN / ID
      BEGIN
         -- Get session info
         SELECT @nInputKey = InputKey FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile 
    
         IF @nInputKey = 1    
         BEGIN    
            IF EXISTS (SELECT LLI.ID
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                  INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)
               WHERE LLI.[ID] =@cID
                  AND LLI.QTY > 0
                  AND LOC.Facility = @cFacility
                  --AND LOC.LocationType ='OTHER'
            )
            BEGIN
               SET @nErrNo = 218392
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --ID in STORAGE Loc
               GOTO Quit
            END 
        END
      END --st3

      -- Check CODs
      IF @nStep = 4 -- UCC
      BEGIN
         -- Get session info
         SELECT @nInputKey = InputKey FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile 
      
         IF @nInputKey = 1    
         BEGIN    
            -- If pallet not receive before then no need further check
            IF NOT EXISTS ( SELECT 1 FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
                           JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON ( RD.ReceiptKey = CRL.ReceiptKey)
                           WHERE ToId = @cID
                           GROUP BY RD.ReceiptKey
                           HAVING ISNULL( SUM( RD.BeforeReceivedQty), 0) > 0)
               GOTO Quit
               
            SELECT  TOP 1  
               @cPO_InID = ISNULL(Lottable03,'')
            FROM dbo.ReceiptDetail RD WITH (NOLOCK)
            JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON ( RD.ReceiptKey = CRL.ReceiptKey)
            WHERE ToId = @cID
               AND   BeforeReceivedQty > 0
               AND   CRL.Mobile =  @nMobile

            SELECT TOP 1 @cPO_ToID = ISNULL(Lottable03,'')
            FROM dbo.ReceiptDetail RD WITH (NOLOCK)
            JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON ( RD.ReceiptKey = CRL.ReceiptKey)
            WHERE UserDefine01 = @cUCC
               AND   CRL.Mobile = @nMobile

            -- PO / Lottable06 mismatch (cant be mixed)
            IF  @cPO_InID <> @cPO_ToID
            BEGIN
               SET @nErrNo = 218394
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --PO CANT BE MIXED
               GOTO Quit
            END 
         END
      END --st4
   END --nFunc = 573   
QUIT:  

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_573ExtValSP09WLR TO NSQL 
GO