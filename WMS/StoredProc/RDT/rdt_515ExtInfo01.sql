
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/***************************************************************************/  
/* Store procedure: rdt_515ExtInfo01                                       */  
/* Copyright: Maersk                                                       */  
/* Customer: DAMIND                                                        */
/*                                                                         */  
/* Modifications log:                                                      */  
/*                                                                         */  
/* Date       Rev  Author     Purposes                                     */  
/* 2026-01-19 1.0  Jackc      FCR-9660 Show pre-allocated qty              */  
/***************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_515ExtInfo01 (  
   @nMobile             INT,            
   @nFunc               INT,            
   @cLangCode           NVARCHAR( 3),   
   @nStep               INT,                      
   @nInputKey           INT,            
   @cFacility           NVARCHAR( 5),   
   @cStorerKey          NVARCHAR( 15),  
   @cFromLoc            NVARCHAR( 10),  
   @cFromID             NVARCHAR( 18),   
   @cSKU                NVARCHAR( 20),   
   @nQTY_Move           INT,
   @cToID               NVARCHAR( 18),
   @cToLoc              NVARCHAR( 10),
   @cLottable01         NVARCHAR( 18),
   @cLottable02         NVARCHAR( 18),
   @cLottable03         NVARCHAR( 18),
   @dLottable04         DATETIME,
   @cSearchLottable01   NVARCHAR( 18),
   @cSearchLottable02   NVARCHAR( 18),
   @cSearchLottable03   NVARCHAR( 18),
   @dSearchLottable04   DATETIME,             
   @tExtInfo            VariableTable READONLY,    
   @cExtendedInfo       NVARCHAR( 20) OUTPUT,
   @nErrNo              INT           OUTPUT,
   @cErrMsg             NVARCHAR( 20) OUTPUT    
)  
AS  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTotalPreAlloQty   INT
   DECLARE @nMovedQty      INT
   DECLARE @nPreAlloQty     INT
   DECLARE @cLot           NVARCHAR(10)  
   
   IF @nFunc = 515
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @nStep = 5 -- SKU, QTY
         BEGIN  
            SELECT TOP 1
               @cLot = Lot 
            FROM dbo.LotAttribute WITH (NOLOCK) 
            WHERE StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND Lottable02 = @cSearchLottable02
               --AND Lottable01 = @cSearchLottable01 --test
			      --AND lottable03 = @cSearchLottable03 -- test
               --AND IsNULL( LA.Lottable04, 0) = CASE WHEN @dSearchLottable04 = 0 THEN IsNULL( LA.Lottable04, 0) ELSE @dSearchLottable04 END
            
            SELECT 
               @nMovedQty = ISNULL(SUM(Qty-(QtyAllocated + QtyPicked)), 0)
            FROM dbo.LOTXLOCXID LLI WITH (NOLOCK)
            JOIN dbo.LOC WITH (NOLOCK) 
               ON LOC.LOC = LLI.LOC
            JOIN dbo.CodeLKUP CL WITH (NOLOCK)
               ON CL.code=LOC.PUTAWAYZONE 
               AND CL.code2=LOC.Facility
            WHERE LLI.StorerKey = @cStorerKey 
               AND LLI.LOT = @cLot
               AND LLI.SKU = @cSKU
               AND CL.LISTNAME ='VORZONE'

            SELECT 
               @nTotalPreAlloQty = ISNULL(QtyPreAllocated, 0) 
            FROM dbo.LOT WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND Lot = @cLot

            IF @nTotalPreAlloQty - @nMovedQty > 0
            BEGIN
               SET @nPreAlloQty = @nTotalPreAlloQty - @nMovedQty
               SET @cExtendedInfo = 'PreAlloQty: ' + CAST(@nPreAlloQty AS NVARCHAR(6))
            END
            ELSE
            BEGIN
               SET @nPreAlloQty = 0
               SET @cExtendedInfo = ''
            END

            

         END --st5
      END --Enter
   END
   
Quit:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_515ExtInfo01 TO NSQL
GO
