

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/************************************************************************/  
/* Store procedure: rdt_523ExtPA64                                      */  
/* Copyright      : Maersk                                              */
/*                                                                      */  
/* Purpose: Get preset loc on ASN (Tamburins)                           */  
/*                                                                      */  
/* Date         Rev  Author   Purposes                                  */  
/* 2023-12-03   1.0  yeekung  WMS-24252 Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC [rdt].[rdt_523ExtPA64] (  
   @nMobile          INT,   
   @nFunc            INT,   
   @cLangCode        NVARCHAR( 3),   
   @cUserName        NVARCHAR( 18),  
   @cStorerKey       NVARCHAR( 15),  
   @cFacility        NVARCHAR( 5),   
   @cLOC             NVARCHAR( 10),  
   @cID              NVARCHAR( 18),  
   @cLOT             NVARCHAR( 10),  
   @cUCC             NVARCHAR( 20),  
   @cSKU             NVARCHAR( 20),  
   @nQty             INT,            
   @cSuggestedLOC    NVARCHAR( 10) OUTPUT,    
   @nPABookingKey    INT           OUTPUT,    
   @nErrNo           INT           OUTPUT,   
   @cErrMsg          NVARCHAR( 20) OUTPUT    
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @cLottable03 NVARCHAR(20),
           @dLottable04 DATETIME


   SELECT TOP 1 @cLottable03 = LOttable03,
                @dLottable04 = LOttable04
   FROM LOTxLOCxID(NOLOCK) LLI
      JOIN LOTATTRIBUTE(NOLOCK) LA ON LLI.StorerKey=LA.StorerKey and LLI.SKU=LA.SKU and LLI.Lot=LA.lot
    WHERE LLI.StorerKey = @cStorerkey
      AND LLI.Sku = @cSKU 
      AND LLI.loc = @cLOC 
      AND LLI.ID = @cID
   GROUP BY LA.Lottable03,LA.Lottable04
   HAVING SUM(LLI.QTY - LLI.QTYPicked - LLI.QTYAllocated ) > 0

     
   SELECT TOP 1 @cSuggestedLOC = LLI.Loc  
   FROM LOTxLOCxID(NOLOCK) LLI
      JOIN LOTATTRIBUTE(NOLOCK) LA ON LLI.StorerKey=LA.StorerKey and LLI.SKU=LA.SKU and LLI.Lot=LA.lot
      JOIN LOC  (NOLOCK) LOC ON LOC.LOC =LLI.LOC
   WHERE LOC.Facility= @cFacility
      AND LLI.StorerKey = @cStorerkey
      AND LLI.Sku = @cSKU 
      AND LLI.loc <> @cLOC 
      AND LOC.LocationType ='PICK'
      AND LOC.HOSTWHCODE='TB-ZP'  
      AND LOC.Status = 'OK'
      AND LA.LOttable03 = @cLottable03
      AND LA.Lottable04 = @dLottable04
   GROUP BY LLI.Loc,LOC.LogicalLocation,LA.Lottable03,LA.Lottable04
   HAVING SUM(LLI.QTY - LLI.QTYPicked - LLI.QTYAllocated + LLI.PendingMoveIn) > 0 and 
         SUM(LLI.QTY - LLI.QTYPicked - LLI.QTYAllocated + LLI.PendingMoveIn) < 10
   ORDER by LOC.LogicalLocation,SUM(LLI.QTY - LLI.QTYPicked - LLI.QTYAllocated) ,LA.Lottable03,LA.Lottable04

   IF ISNULL(@cSuggestedLOC,'')=''
   BEGIN
      SELECT TOP 1 
         @cSuggestedLOC = LOC.LOC  
      FROM dbo.LOC LOC WITH (NOLOCK)   
         LEFT OUTER JOIN LOTxLOCxID LLI WITH (NOLOCK) ON (LLI.LOC = LOC.LOC)   
      WHERE LOC.Facility = @cFacility
         AND LOC.LocationType = 'PICK'
         AND LOC.HostWHCode = 'TB-ZP'  
         AND LOC.Status = 'OK'
      GROUP BY LOC.LogicalLocation, LOC.LOC  
      HAVING SUM( ISNULL( LLI.QTY, 0) - ISNULL( LLI.QTYPicked, 0)) = 0   
         AND SUM( ISNULL( LLI.PendingMoveIn, 0)) = 0  
      ORDER BY LOC.LogicalLocation  
   END

   
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_523ExtPA64 TO NSQL
GO
