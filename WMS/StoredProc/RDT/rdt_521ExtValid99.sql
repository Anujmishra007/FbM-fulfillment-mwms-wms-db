SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_521ExtValid99                                   */  
/* Purpose: Validade If Exists PickFace For the SKU                     */  
/* Copy of rdt_521ExtValid01                                            */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2025-09-16 1.0  elb012     PROJECT - RITM8172881                     */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_521ExtValid99] (  
   @nMobile         INT,       
   @nFunc           INT,       
   @cLangCode       NVARCHAR( 3),  
   @nStep           INT,        
   @nInputKey       INT,       
   @cStorerKey      NVARCHAR( 15), 
   @cUCCNo          NVARCHAR( 18), 
   @cSuggestedLOC   NVARCHAR( 10), 
   @cToLOC          NVARCHAR( 10), 
   @nErrNo          INT OUTPUT,    
   @cErrMsg         NVARCHAR( 20) OUTPUT
)  
AS  
BEGIN
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    

   DECLARE  @cSkuCnt       INT, 
            @cPickFaceCnt  INT,
            @cSKUxPickFace VARCHAR(20)

   SET @nErrNo = ''
   SET @cErrMSG = ''

   IF @nStep = 1
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SELECT 
            @cSkuCnt = COUNT (DISTINCT SKU) -- COUNT SKU IN UCC
         FROM dbo.UCC WITH (NOLOCK)
         WHERE UCCNo = @cUCCNo
         AND UCC.Storerkey = @cStorerKey
       
         SELECT
            @cPickFaceCnt = COUNT (DISTINCT SKU) --COUNT SKU WITHIN PICKFACE
         FROM DBO.SKUxLOC AS PF WITH (NOLOCK)
         WHERE PF.QtyLocationLimit > 0
            AND PF.QtyLocationMinimum > 0
            AND PF.LocationType = 'PICK'
         AND PF.SKU IN(SELECT 
                     DISTINCT SKU
                     FROM dbo.UCC WITH (NOLOCK)
                     WHERE UCCNo = @cUCCNo
                     AND UCC.Storerkey = @cStorerKey)

         IF @cSkuCnt <> @cPickFaceCnt
         BEGIN
            SET @nErrNo = 154001
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NoPickFace'
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
GRANT EXECUTE ON  [RDT].[rdt_521ExtValid99] TO [NSQL]
GO
