SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_573ExtValSP09HRP                                */  
/* Purpose: Validate  UCC                                               */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2025-04-01 1.0  WSE016     WCEET-2988 Fn573 COD Validation           */  
/************************************************************************/  
  
CREATE OR ALTER         PROC [RDT].[rdt_573ExtValSP09HRP] (
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
      @cCOD      NVARCHAR(20),
      @cCOD_Cnt  INT,
      @cUCC_Cnt  INT,
      @cUCC_COD  NVARCHAR(20),
      @cCOD_SKU  NVARCHAR(20),
      @cUCC_SKU  NVARCHAR(20),
      @cCOD_Plant NVARCHAR(20),   -- Bonded 1001 / Non-Bonded 1001
      @cUCC_Plant NVARCHAR(20),   -- Bonded 1001 / Non-Bonded 1001
      @cCOD_SO    NVARCHAR(20),   
      @cUCC_SO    NVARCHAR(20)  

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
                      FROM LOC WITH (NOLOCK)
                       WHERE facility = @cFacility
                        AND LOC = @cLoc
                        AND locationtype <> 'STAGING'
                        AND LocationCategory <>'STAGE')
            

         BEGIN
            SET @nErrNo = 218357
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --LOC In STAGING Area
            GOTO Quit
         END 
        END
        END


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
              -- AND LOC.LocationType ='OTHER'
               )

         BEGIN
            SET @nErrNo = 218356
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --ID in STORAGE Loc
            GOTO Quit
         END 
        END
        END


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
               

         SELECT  TOP 1  @cCOD = ISNULL(Lottable03,''),
                       -- @cCOD_Cnt = ISNULL(LEN(Lottable03),'0'),
                        @cCOD_SKU = SKU,
                        @cCOD_Plant = ISNULL(Lottable01,'')
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
         JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON ( RD.ReceiptKey = CRL.ReceiptKey)
          WHERE ToId = @cID
            AND   BeforeReceivedQty > 0
            AND   CRL.Mobile =  @nMobile


      -- WS 20250715 
        SELECT TOP 1  @cCOD_Cnt = Count(Distinct(ISNULL(Lottable03,'0')))
             --       , @cCOD_SO = SUM(CASE WHEN RD.Lottable10 IS NOT NULL AND RD.Lottable10 <> '' THEN 1 ELSE 0 END) 
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
         JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON ( RD.ReceiptKey = CRL.ReceiptKey)
          WHERE ToId = @cID
            AND   BeforeReceivedQty > 0
            AND   CRL.Mobile =  @nMobile


         SELECT TOP 1 @cUCC_COD = ISNULL(Lottable03,''), 
                      @cUCC_SKU = SKU,
                    --  @cUCC_Cnt = ISNULL(LEN(Lottable03),'0'),
                      @cUCC_Plant = ISNULL(Lottable01,'')
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
         JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON ( RD.ReceiptKey = CRL.ReceiptKey)
          WHERE UserDefine01 = @cUCC
            AND   CRL.Mobile = @nMobile

-- WS 20250715 
        SELECT TOP 1  @cUCC_Cnt = Count(Distinct(ISNULL(Lottable03,'0')))
               --     , @cUCC_SO = SUM(CASE WHEN RD.Lottable10 IS NOT NULL AND RD.Lottable10 <> '' THEN 1 ELSE 0 END) 
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
         JOIN rdt.rdtConReceiveLog CRL WITH (NOLOCK) ON ( RD.ReceiptKey = CRL.ReceiptKey)
          WHERE UserDefine01 = @cUCC
            AND   CRL.Mobile = @nMobile


    -- WS 20250109 - check lottable10 -to test

        SELECT TOP 1  @cCOD_SO = SUM(CASE WHEN RD.Lottable10 IS NOT NULL AND RD.Lottable10 <> '' THEN 1 ELSE 0 END) 
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
          WHERE ToId = @cID
            AND   BeforeReceivedQty > 0


        SELECT TOP 1  @cUCC_SO = SUM(CASE WHEN RD.Lottable10 IS NOT NULL AND RD.Lottable10 <> '' THEN 1 ELSE 0 END) 
         FROM dbo.ReceiptDetail RD WITH (NOLOCK)
          WHERE UserDefine01 = @cUCC





         -- Bonded 1001 / Non-Bonded 1001 (cant be mixed)
        IF  @cUCC_Plant = 'Bonded'  and @cCOD_Plant <> @cUCC_Plant
         BEGIN
            SET @nErrNo = 218358
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --BONDED CANT MIX
            GOTO Quit
         END 

                 IF  @cUCC_Plant = 'Non-Bonded' and  @cCOD_Plant <> @cUCC_Plant 
         BEGIN
            SET @nErrNo = 218359
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --NON-BONDED CANT MIX
            GOTO Quit
         END 



-- new logic

IF  @cCOD_SO <> 0 and @cUCC_SO = 0 or @cCOD_SO = 0 and @cUCC_SO <> 0
         BEGIN
            SET @nErrNo = 218382
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') -- No SO in lottable10
            GOTO Quit
         END  


IF @cCOD_Cnt =1 and @cUCC_Cnt =1 and @cCOD <> @cUCC_COD  and (@cCOD_SO > 0 or  @cUCC_SO > 0)
         BEGIN
            SET @nErrNo = 218354
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') -- Mix COD Pallet   
            GOTO Quit
         END  


IF @cCOD_Cnt =1  and @cUCC_Cnt >1  and  (@cCOD_SO > 0 or  @cUCC_SO > 0)
         BEGIN
            SET @nErrNo = 218379
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') -- Pallet with 1 COD - Xock Pallet
            GOTO Quit
         END  

IF @cCOD_Cnt >1  and @cUCC_Cnt =1   and  (@cCOD_SO > 0 or  @cUCC_SO > 0)
         BEGIN
            SET @nErrNo = 218380
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --  Pallet with 2  COD - FF Pallet
            GOTO Quit
         END  

IF  @cUCC_Cnt = 0    and  (@cCOD_SO > 0 or  @cUCC_SO > 0)
         BEGIN
            SET @nErrNo = 218381
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode,'DSP') --  Missing COD on Lottable03
            GOTO Quit
         END  

      END    
   END
  
QUIT:  

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_573ExtValSP09HRP TO NSQL
GO

