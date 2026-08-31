      
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/      
/* Store procedure: rdt_664ExtValid01HRP                                  */      
/* Purpose: Move By ID Extended Validate                                  */      
/*                                                                        */      
/* Called from: rdtfnc_MoveIDBeforeFinalization                           */      
/*                                                                        */      
/* Modifications log:                                                     */      
/*                                                                        */      
/* Date        Rev  Author   Purposes                                     */      
/* 2025-07-02  1.0  WSE016   Created                                      */      
/* 2025-08-22  1.1  WSE016   Commented out @c_LocType = 'PICK' as per OPS */
/* 2026-05-07  1.2  PYW009   UWP-57351 INC9288582 New Req : Dedicated     */
/*                           & Non-Dedicated Goods                        */        
/*                                                                        */      
/**************************************************************************/      
      
CREATE OR ALTER PROC [RDT].[rdt_664ExtValid01HRP] (      
   @nMobile            INT,      
   @nFunc              INT,       
   @cLangCode          NVARCHAR( 3),       
   @nStep              INT,       
   @nInputKey          INT,       
   @cFacility          NVARCHAR( 5),      
   @cStorerKey         NVARCHAR( 15),      
   @cID                NVARCHAR( 18),          
   @cFromLOC           NVARCHAR( 10),      
   @cToLOC             NVARCHAR( 10),      
   @c_SKU              NVARCHAR(20),      
   @cReceiptKey        NVARCHAR( 10),      
   @cReceiptLineNumber NVARCHAR( 5),      
   @nErrNo             INT           OUTPUT,       
   @cErrMsg            NVARCHAR( 20) OUTPUT      
)      
AS      
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
      
   DECLARE       
     @c_AsnSKU   NVARCHAR(20)      
   , @c_AsnSKU1   NVARCHAR(20)      
   , @c_LocSKU NVARCHAR(20)      
   , @c_SKUCnt  INT      
   , @c_SKUCOD INT      
   , @c_LocLLI NVARCHAR(20)      
   , @c_LocType NVARCHAR(10)  
   , @c_Lottable10 NVARCHAR(50)  
      
      
   SET @nErrNo = 0      
      
      
   IF @nFunc = 664      
   BEGIN      
      IF @nStep = 3      
      BEGIN      
         IF @nInputKey = 1      
         BEGIN      
      
            -- get LocationType      
            SELECT @c_LocType = locationType       
            FROM dbo.LOC WITH (NOLOCK)       
            WHERE Facility = @cFacility and LOC = @cToLOC      
      
            IF @c_LocType = 'OTHER'      
            BEGIN       
               -- Not allow to move Pallet to location with Stock where locationType <> PICK      
               SELECT  @c_LocLLI = LLI.LOC      
                  FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)       
                  INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)      
                  WHERE LOC.Facility = @cFacility      
                  AND   LOC.Loc = @cToLOC      
                  AND LOC.LocationType ='OTHER'      
                  --AND LLI.QTY <>0      
                  GROUP BY LLI.LOC        
                  HAVING ISNULL(SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.PendingMoveIn), 0) <> 0      
               
               IF @c_LocLLI = @cToLOC      
               BEGIN      
                  SET @nErrNo = 218372  --LOC in use      
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')      
                  GOTO Quit      
               END      
            
               IF EXISTS (SELECT  1      
                     FROM dbo.RECEIPTDETAIL WITH (NOLOCK)       
                     WHERE StorerKey = @cStorerKey       
                     AND receiptkey = @cReceiptKey      
                     AND ToLoc = @cToLOC)      
               BEGIN      
                  SET @nErrNo = 218373  -- Loc Allocated on ASN      
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')      
                  GOTO Quit      
               END      
            END --LocType = Other      
      
      
            /*     
            IF @c_LocType = 'PICK'      
            BEGIN      
  
               -- Not allow to Mix SKU in locationType = PICK      
  
               IF EXISTS (      
                     SELECT 1      
                     FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)      
                     INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON LLI.LOC = LOC.LOC      
                     WHERE LLI.StorerKey = @cStorerKey      
                     AND LOC.Facility = @cFacility      
                     AND LOC.Loc = @cToLOC      
                     AND LOC.LocationType = 'PICK'      
                     AND LLI.Qty > 0      
               )      
               OR EXISTS (      
                     SELECT 1      
                     FROM RECEIPTDETAIL WITH (NOLOCK)      
                     WHERE StorerKey = @cStorerKey      
                     AND ReceiptKey = @cReceiptKey      
                     AND ToLoc = @cToLOC      
               )      
                     BEGIN      
                        SELECT TOP 1      
                        @c_LocSKU = ISNULL(LLI.SKU, '')      
                              FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)       
                              INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)      
                              WHERE LLI.StorerKey = @cStorerKey       
                              AND LOC.Facility =  @cFacility       
                              AND   LOC.Loc = @cToLOC      
                              AND LOC.LocationType ='PICK'      
                              AND  ISNULL(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.PendingMoveIn, 0) <> 0      
   
                        SELECT  @c_AsnSKU = ISNULL(MIN(SKU), '')       
                           ,  @c_SKUCnt = count(distinct SKU)      
                           ,  @c_SKUCOD = LEN(Lottable03)      
                              FROM RECEIPTDETAIL WITH (NOLOCK)       
                              WHERE StorerKey = @cStorerKey       
                              AND receiptkey = @cReceiptKey      
                              AND ToId = @cID      
                              --AND LEN(Lottable03) >3      
                              GROUP BY Lottable03      
                        
                        
                           SELECT  @c_AsnSKU1 = ISNULL(MIN(SKU), '')       
                              FROM RECEIPTDETAIL WITH (NOLOCK)       
                              WHERE StorerKey = @cStorerKey       
                              AND receiptkey = @cReceiptKey      
                              AND ToLoc = @cToLOC      
   
   
   
                        IF @c_LocSKU  <> @c_AsnSKU  and @c_AsnSKU <> @c_AsnSKU1 --and Sum(@c_SKUCnt) >1 and @c_SKUCOD <4      
   
                              BEGIN      
                              SET @nErrNo = 218374  --Different SKU in PICK location      
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')      
                              GOTO Quit      
                        END      
                     END      
            END
             */      
   
            -------------------------------------------------------------------  
            -- NEW REQUIREMENT: Dedicated vs Non-Dedicated Goods Allocation  
            -------------------------------------------------------------------  
            SELECT TOP 1 @c_Lottable10 = LOTTABLE10  
            FROM dbo.RECEIPTDETAIL WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
               AND ReceiptKey = @cReceiptKey  
               AND RECEIPTLINENUMBER = @cReceiptLineNumber  
                  
            -- NON-DEDICATED GOODS (LOTTABLE10 blank)  
            IF ISNULL(@c_Lottable10, '') = ''  
            BEGIN  
               IF NOT EXISTS (  
                  SELECT 1  
                  FROM dbo.LOC WITH (NOLOCK)  
                  WHERE Facility = @cFacility  
                     AND LOC = @cToLOC  
                     AND LocationType = 'PICK'  
               )  
               BEGIN  
                  SET @nErrNo = 267851; -- Invalid non-dedicated allocation  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP');  
                  GOTO Quit;  
               END  
            END  
            ELSE  
            BEGIN  
               -- DEDICATED GOODS (LOTTABLE10 has value)  
               IF NOT EXISTS (  
                  SELECT 1  
                  FROM dbo.LOC WITH (NOLOCK)  
                  WHERE Facility = @cFacility  
                     AND LOC = @cToLOC  
                     AND LocationType = 'OTHER'  
               )  
               BEGIN  
                  SET @nErrNo = 267852; -- Invalid dedicated allocation  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP');  
                  GOTO Quit;  
               END  
            END  
            -------------------------------------------------------------------  
         END --inputkey = 1    
      END --step3      
   END --664      
      
   QUIT: 

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_664ExtValid01HRP TO NSQL
GO