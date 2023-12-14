SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdt_573ExtValidSP10                                 */  
/* Copyright: LF Logistics                                              */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2023-12-03 1.0  yeekung   WMS-24232 Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_573ExtValidSP10 (
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
   
   IF @nFunc = 573 -- UCC inbound receiving
   BEGIN
      IF @nStep = 4 -- UCC
      BEGIN
         -- Get session info
         DECLARE @nInputKey INT 
         SELECT @nInputKey = InputKey FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile

         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @nWeight      FLOAT


            IF EXISTS (SELECT 1
                       FROM UCC (NOLOCK)
                       WHERE UCCNO = @cUCC
                        AND Storerkey = @cStorerKey)
            BEGIN
               SET @nErrNo = 209251
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DuplicateUCC
               GOTO Quit
            END

                      -- Get SKU info
            SELECT 
               @nWeight = SKU.Weight
            FROM dbo.ReceiptDetail RD WITH (NOLOCK)
               JOIN dbo.SKU SKU WITH (NOLOCK) ON ( RD.StorerKey = SKU.StorerKey AND RD.SKU = SKU.SKU)
            WHERE RD.Userdefine01 = @cUCC

            -- Check weight
            IF ISNULL( @nWeight, 0) = 0
            BEGIN
               SET @nErrNo = 209252
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- CubicSnReq
               GOTO Quit
            END
            
         END
      END
   END
   
Quit:  
GO
GRANT EXECUTE ON RDT.rdt_573ExtValidSP10 TO NSQL
GO



