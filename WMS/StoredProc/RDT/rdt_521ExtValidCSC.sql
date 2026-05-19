/************************************************************************/    
/* Store procedure: rdt_521ExtValidCSC                                  */    
/* Purpose: Validate no mix sku ucc and putawayZone                     */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date       Rev  Author     Purposes                                  */    
/* 2025-12-02 1.0  MMA982      Created                                  */    
/************************************************************************/    
    
CREATE PROC [RDT].[rdt_521ExtValidCSC] (    
   @nMobile         INT,         
   @nFunc           INT,         
   @cLangCode       NVARCHAR( 3),    
   @nStep           INT,          
   @nInputKey       INT,         
   @cStorerKey      NVARCHAR( 15),   
   @cUCCNo          NVARCHAR( 20),   
   @cSuggestedLOC   NVARCHAR( 10),   
   @cToLOC          NVARCHAR( 10),   
   @nErrNo          INT OUTPUT,      
   @cErrMsg         NVARCHAR( 20) OUTPUT  
)    
AS    
  
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
  
   DECLARE  @cFromLOC      NVARCHAR( 10),   
            @cFacility     NVARCHAR( 5)  
  
   SET @nErrNo = 0  
   SET @cErrMSG = ''  
  
   SELECT @cFacility = Facility   
   FROM rdt.rdtMOBREC WITH (READCOMMITTEDLOCK)   
   WHERE Mobile = @nMobile  
  
   IF @nInputKey = 1  
   BEGIN  
      IF @nStep = 1  
      BEGIN  
  
          IF EXISTS  
            (  
                SELECT 1  
                FROM  
                (  
                    SELECT COUNT(DISTINCT u.SKU) AS DistSku  
                    FROM dbo.UCC AS u WITH (READCOMMITTEDLOCK)  
                    WHERE u.StorerKey = @cStorerKey  
                      AND u.UCCNo     = @cUCCNo  
                      AND u.Qty       > 0  
                ) AS x  
                WHERE x.DistSku > 1  
            )  
            BEGIN  
                SET @nErrNo  = 173851; -- "Mix SKU UCC"  
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP');  
                GOTO Quit;  
            END  
  
  
  
  
        /*  IF EXISTS  
            (  
                SELECT 1  
                FROM dbo.UCC AS u WITH (READCOMMITTEDLOCK)  
                JOIN dbo.SKU AS s  
                  ON s.SKU = u.SKU AND s.StorerKey = u.StorerKey  
                JOIN dbo.PACK AS p  
                  ON p.PackKey = s.PackKey  
                WHERE u.StorerKey = @cStorerKey  
                  AND u.UCCNo     = @cUCCNo  
                  AND u.Qty       > 0  
                  AND (  
                        s.STDGROSSWGT IS NULL OR s.STDGROSSWGT = 0  
                        OR p.CubeUOM3 IS NULL OR p.CubeUOM3 = 0  
                      )  
            )  
            BEGIN  
                SET @nErrNo  = 1862025; -- "Capture SKU w8 & dims"  
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP');  
                GOTO Quit;  
            END  */  
  
      END  
  
        IF @nStep = 2  
        BEGIN  
            -- Prevent V2/V5 putaway to locations outside allowed zones  
            DECLARE  
                @cDestLOC      NVARCHAR(20),  
                @cLot          NVARCHAR(30),  
                @cLottable01   NVARCHAR(50),  
                @AllowedZone1  NVARCHAR(20) = N'CSCV2H',  
                @AllowedZone2  NVARCHAR(20) = N'CSCV5H';  
  
            -- Prefer explicit ToLOC; fall back to SuggestedLOC if empty  
            SET @cDestLOC = NULLIF(LTRIM(RTRIM(@cToLOC)), N'');  
  
            -- Get the (single) lot from the UCC  
            SELECT TOP (1) @cLot = u.Lot  
            FROM dbo.UCC AS u WITH (READCOMMITTEDLOCK)  
            WHERE u.StorerKey = @cStorerKey  
            AND u.UCCNo     = @cUCCNo  
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
  
  
         -- Ensure @cToLOC and @cSuggestedLOC are in the SAME putaway zone  
                ----------------------------------------------------------------------  
                DECLARE  
                    @cToLocTrim  NVARCHAR(20) = NULLIF(LTRIM(RTRIM(@cToLOC)), N''),  
                    @cSugLocTrim NVARCHAR(20) = NULLIF(LTRIM(RTRIM(@cSuggestedLOC)), N''),  
                    @cToZone     NVARCHAR(20),  
                    @cSugZone    NVARCHAR(20);  
  
                -- Read zones only when values are present  
                IF @cToLocTrim IS NOT NULL  
                BEGIN  
                    SELECT @cToZone = l.PutawayZone  
                    FROM dbo.LOC AS l WITH (READCOMMITTEDLOCK)  
                    WHERE l.Loc = @cToLocTrim  
                    AND l.Facility = @cFacility;  
                END  
  
                IF @cSugLocTrim IS NOT NULL  
                BEGIN  
                    SELECT @cSugZone = l.PutawayZone  
                    FROM dbo.LOC AS l WITH (READCOMMITTEDLOCK)  
                    WHERE l.Loc = @cSugLocTrim  
                    AND l.Facility = @cFacility;  
                END  
  
                -- Only compare when BOTH locs were provided; if either is NULL, skip  
                IF @cToLocTrim IS NOT NULL  
                AND @cSugLocTrim IS NOT NULL  
                AND ISNULL(@cToZone, N'') <> ISNULL(@cSugZone, N'')  
                 BEGIN  
                    SET @nErrNo  = 216155; -- 216155^Invalid PUTAWAY ZONE  
                    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP');  
                    GOTO Quit;  
                END  
              
        END  
  
   END  
    
QUIT:    
  
   