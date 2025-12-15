SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_523ExtInfo14                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log: Laquila project                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2025-11-14 1.0  FRO014   UWP-45490 RITM8493063-Capacity check        */
/*                            for suggest location                      */
/************************************************************************/
    
CREATE OR ALTER PROCEDURE [RDT].[rdt_523ExtInfo14]    
   @nMobile         INT, 
   @nFunc           INT, 
   @cLangCode       NVARCHAR( 3),  
   @nStep           INT, 
   @nAfterStep      INT, 
   @nInputKey       INT,                
   @cStorerKey      NVARCHAR( 15), 
   @cFacility       NVARCHAR( 5),  
   @cLOC            NVARCHAR( 10), 
   @cID             NVARCHAR( 18), 
   @cSKU            NVARCHAR( 20), 
   @nQTY            INT,  
   @cSuggestedLOC   NVARCHAR( 10),  
   @cFinalLOC       NVARCHAR( 10), 
   @cOption         NVARCHAR( 1), 
   @cExtendedInfo1  NVARCHAR( 20) OUTPUT
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
   

   DECLARE @nLLI_Qty             INT
   DECLARE @nLLI_QtyPicked       INT
   DECLARE @nLLI_PendingMoveIn   INT
   DECLARE @nQtyAvaCaseLoc       INT=0 -- quantity available of cases at Location
   DECLARE @nQtyAvaEachLoc       INT=0 -- quantity available of each at Location
   DECLARE @cAvaCaseLoc          NVARCHAR(20)='' -- description of available case location
   DECLARE @cAvaEachLoc          NVARCHAR(20)='' -- description of available each location
   DECLARE @cInfo1               NVARCHAR(20)=''
   DECLARE @cInfo2               NVARCHAR(20)=''
   
   IF @nFunc = 523 -- Putaway by SKU
   BEGIN
      IF @nAfterStep = 3 --AND @cLOC NOT LIKE '%STG%' -- QTY PWY, QTY ACT
      BEGIN
         SELECT TOP 1  
            @cAvaCaseLoc = SL.Loc,
            @nQtyAvaCaseLoc = (SL.QtyLocationLimit - SL.Qty)/ISNULL(PK.CaseCnt,0)
         FROM dbo.SKUxLOC SL WITH (NOLOCK) 
         INNER JOIN	dbo.SKU SKU WITH (NOLOCK) ON ( SL.SKU = SKU.SKU)
         INNER JOIN	dbo.PACK PK WITH (NOLOCK) ON ( SKU.PackKey = PK.PackKey)
         WHERE SL.StorerKey = @cStorerKey
            AND SL.Sku = @cSKU
            AND SL.LocationType = 'CASE'
            AND SL.QtyLocationLimit > 0
            AND SL.QtyLocationLimit - SL.QTY > 0

         SELECT TOP 1 
            @cAvaEachLoc = SL.Loc,
            @nQtyAvaEachLoc = SL.QtyLocationLimit - SL.Qty
         FROM dbo.SKUxLOC SL WITH (NOLOCK) 
         WHERE SL.StorerKey = @cStorerKey
            AND SL.Sku = @cSKU
            AND SL.LocationType = 'PICK'
            AND SL.QtyLocationLimit > 0
            AND SL.QtyLocationLimit - SL.QTY > 0

         SET @cInfo1 = 'CX' +  ':' +  TRIM(CAST( @nQtyAvaCaseLoc AS NVARCHAR(5)))
         SET @cInfo2= 'EA' + ':' + TRIM(CAST( @nQtyAvaEachLoc AS NVARCHAR( 5)))

         IF (@nQtyAvaCaseLoc +  @nQtyAvaEachLoc) > 0
         BEGIN
            SET @cExtendedInfo1 = 'AV:' + @cInfo2 +  @cInfo1  
            GOTO Quit
         END	
         ELSE
         BEGIN
            SET @cExtendedInfo1 = 'LOC NOT AV'
            GOTO Quit
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

GRANT EXECUTE ON rdt.rdt_523ExtInfo14 to nSQL
GO 
