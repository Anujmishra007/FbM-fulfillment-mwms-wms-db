/************************************************************************/    
/* Store procedure: rdt_523ExtValidSPCSC                                */    
/* Purpose: Validate UCC and SKU.                                       */  
/*          1. If mix sku, prompt error                                 */    
/*          2. If sku no pick loc assigned, prompt error                */   
/*          3. If sku has no w8 or dims, prompt error                   */     
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date       Rev  Author    Purposes                                   */    
/* 2025-12-16 1.0  MMA982    Created                                    */    
/************************************************************************/    
    
CREATE PROC [RDT].[rdt_523ExtValidSPCSC] (    
   @nMobile         INT,   
   @nFunc           INT,   
   @cLangCode       NVARCHAR( 3),    
   @nStep           INT,   
   @nInputKey       INT,   
   @cStorerKey      NVARCHAR( 15),   
   @cFacility       NVARCHAR( 5),    
   @cFromLOC        NVARCHAR( 10),   
   @cFromID         NVARCHAR( 18),   
   @cSKU            NVARCHAR( 20),   
   @nQty            INT,    
   @cSuggestedLOC   NVARCHAR( 10),   
   @cFinalLOC       NVARCHAR( 10),   
   @cOption         NVARCHAR( 1),    
   @nErrNo          INT           OUTPUT,    
   @cErrMsg         NVARCHAR( 20) OUTPUT  
)    
AS    
  
SET NOCOUNT ON      
SET QUOTED_IDENTIFIER OFF      
SET ANSI_NULLS OFF      
SET CONCAT_NULL_YIELDS_NULL OFF      
  
   DECLARE @cUCC           NVARCHAR( 20)  
  
   SELECT @cUCC = I_Field02  
   FROM rdt.RDTMOBREC WITH (NOLOCK)   
   WHERE Mobile = @nMobile  
  
   IF @nInputKey = 1    
   BEGIN    
      IF @nStep = 1  
      BEGIN  
         -- user not key in ucc, no need validation  
         IF ISNULL( @cUCC, '') = ''  
            GOTO Quit  
  
         -- Check if ucc has mix sku  
         IF EXISTS ( SELECT 1 FROM dbo.UCC WITH (NOLOCK)  
                     WHERE StorerKey = @cStorerKey  
                     AND   UCCNo = @cUCC   
                     AND   [Status] = '1'  
                     GROUP BY UCCNo   
                     HAVING COUNT( DISTINCT SKU) > 1)  
         BEGIN  
            SET @nErrNo = 106201  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Mix ucc sku  
            GOTO Quit  
         END  
  
         SELECT TOP 1 @cSKU = SKU  
         FROM dbo.UCC WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
         AND   UCCNo = @cUCC   
         AND   [Status] = '1'  
  
         -- Check if sku has assigned pick loc  
         IF NOT EXISTS (   
            SELECT 1   
            FROM dbo.SKUxLOC SL WITH (NOLOCK)   
            JOIN dbo.LOC LOC WITH (NOLOCK) ON ( SL.LOC = LOC.LOC)  
            WHERE SL.StorerKey = @cStorerKey  
            AND   SL.LocationType = 'PICK'  
            AND   SL.SKU = @cSKU  
            AND   LOC.Facility = @cFacility)  
         BEGIN  
            SET @nErrNo = 106202  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No home loc  
            GOTO Quit  
         END  
  
            -- ==========================================  
            -- Validate that UCC qty + location qty <= qtylocationlimit  
            -- ==========================================  
              
            DECLARE @nUCCQty INT = 0,  
                    @nLocQty INT = 0,  
                    @nQtyLocLimit INT = 0;  
  
            -- Get total qty in UCC for this SKU  
            SELECT @nUCCQty = SUM(Qty)  
            FROM dbo.UCC WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
            AND   UCCNo = @cUCC  
            AND   [Status] = '1'  
            AND   SKU = @cSKU;  
  
            -- Get pick location qty and limit  
            SELECT TOP 1   
                @nLocQty = SL.Qty,  
                @nQtyLocLimit = SL.QtyLocationLimit  
            FROM dbo.SKUxLOC SL WITH (NOLOCK)  
            JOIN dbo.LOC L WITH (NOLOCK) ON SL.LOC = L.LOC  
            WHERE SL.StorerKey   = @cStorerKey  
            AND   SL.SKU         = @cSKU  
            AND   SL.LocationType = 'PICK'  
            AND   L.Facility     = @cFacility  
  
            -- Perform the check  
            IF (@nUCCQty + @nLocQty) > @nQtyLocLimit  
            BEGIN  
                SET @nErrNo = 102359;  
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 02359^QTY OVER LIMIT  
                GOTO Quit;  
            END;  
      END      
  
      IF @nStep = 2  
      BEGIN  
         -- user not key in sku, no need validation  
         IF ISNULL( @cSKU, '') = ''  
            GOTO Quit  
  
         -- Check if sku has assigned pick loc  
         IF NOT EXISTS (   
            SELECT 1   
            FROM dbo.SKUxLOC SL WITH (NOLOCK)   
            JOIN dbo.LOC LOC WITH (NOLOCK) ON ( SL.LOC = LOC.LOC)  
            WHERE SL.StorerKey = @cStorerKey  
            AND   SL.LocationType = 'PICK'  
            AND   SL.SKU = @cSKU  
            AND   LOC.Facility = @cFacility)  
         BEGIN  
            SET @nErrNo = 106203  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- No home loc  
            GOTO Quit  
         END  
  
        IF  EXISTS ( SELECT 1 FROM  dbo.sku s   
                                JOIN dbo.pack p on s.PACKKey = p.PackKey  
                         WHERE S.StorerKey = @cStorerKey    
                         AND   S.SKU = @cSKU    
                         AND   (s.STDGROSSWGT = null or s.STDGROSSWGT = 0   
                                or p.CubeUOM3 = null   
                                or p.CubeUOM3 = 0 )   
                         )    
         BEGIN  
            SET @nErrNo = 1862025  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Capture SKU w8 & dims'  
            GOTO Quit  
         END  
  
  
        IF @nStep = 4  
        BEGIN  
            -- Prevent V2/V5 putaway to locations outside allowed zones  
            DECLARE  
                @cDestLOC      NVARCHAR(20),  
                @cLot          NVARCHAR(30),  
                @cLottable01   NVARCHAR(50),  
                @AllowedZone1  NVARCHAR(20) = N'CSCV2H',  
                @AllowedZone2  NVARCHAR(20) = N'CSCV5H';  
  
            -- Prefer explicit ToLOC; fall back to SuggestedLOC if empty  
            SET @cDestLOC = NULLIF(LTRIM(RTRIM(@cFinalLOC)), N'');  
  
            -- Get the (single) lot from the UCC  
            SELECT TOP (1) @cLot = u.Lot  
            FROM dbo.UCC AS u WITH (READCOMMITTEDLOCK)  
            WHERE u.StorerKey = @cStorerKey  
            AND u.UCCNo     = @cUCC  
            AND u.Qty       > 0;  
  
            -- Read Lottable01   
            SELECT @cLottable01 = la.Lottable01  
            FROM dbo.LOTATTRIBUTE AS la WITH (READCOMMITTEDLOCK)  
            WHERE la.StorerKey = @cStorerKey  
            AND la.Lot       = @cLot;  
  
            -- Only enforce when Lottable01 explicitly V2 / V5  
            IF ISNULL(@cLottable01, N'') IN (N'V2', N'V5')  
            BEGIN  
                -- Check location's putaway zone  
                IF NOT EXISTS  
                (  
                    SELECT 1  
                    FROM dbo.LOC AS l WITH (READCOMMITTEDLOCK)  
                    WHERE l.Loc         = @cDestLOC  
                    AND l.Facility    = @cFacility     
                    AND l.PutawayZone IN (@AllowedZone1, @AllowedZone2)  
                )  
                BEGIN  
                    SET @nErrNo  = 252904; -- 252904^Invalid LOC  
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP');  
                    GOTO Quit;  
                END  
            END  
        END  
          
      END      
   END  
      
   QUIT:  
   