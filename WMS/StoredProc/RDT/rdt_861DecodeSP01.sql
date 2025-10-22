
  
/******************************************************************************/  
/* Store procedure: rdt_861DecodeSP01                                         */ 
/* Copyright: LF Logistics                                                    */  
/*                                                                            */  
/* Purpose: Extended putaway                                                  */  
/*                                                                            */  
/* Date        Author    Ver.  Purposes                                       */  
/* 2025-09-09  Jackc     1.0   FCR-7545 Created                               */  
/******************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_861DecodeSP01] (  
   @nMobile         INT,      
   @nFunc           INT,      
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,         
   @nInputKey       INT,         
   @cStorerKey      NVARCHAR( 15),
   @cPickSlipNo     NVARCHAR( 10),
   @cBarcode        NVARCHAR( 60),
   @cDropID         NVARCHAR(60)   OUTPUT, 
   @cLOC            NVARCHAR(10)   OUTPUT, 
   @cID             NVARCHAR(18)   OUTPUT, 
   @cSKU            NVARCHAR(20)   OUTPUT,   
   @nQty            INT            OUTPUT,
   @cUCC            NVARCHAR(20)   OUTPUT,   
   @cLottable01     NVARCHAR( 18)  OUTPUT,   
   @cLottable02     NVARCHAR( 18)  OUTPUT,   
   @cLottable03     NVARCHAR( 18)  OUTPUT,   
   @dLottable04     DATETIME       OUTPUT,   
   @dLottable05     DATETIME       OUTPUT,   
   @cLottable06     NVARCHAR( 30)  OUTPUT,   
   @cLottable07     NVARCHAR( 30)  OUTPUT,   
   @cLottable08     NVARCHAR( 30)  OUTPUT,   
   @cLottable09     NVARCHAR( 30)  OUTPUT,   
   @cLottable10     NVARCHAR( 30)  OUTPUT,   
   @cLottable11     NVARCHAR( 30)  OUTPUT,   
   @cLottable12     NVARCHAR( 30)  OUTPUT,   
   @dLottable13     DATETIME       OUTPUT,   
   @dLottable14     DATETIME       OUTPUT,   
   @dLottable15     DATETIME       OUTPUT,   
   @nErrNo          INT OUTPUT,             
   @cErrMsg         NVARCHAR( 20) OUTPUT 
    
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE @nDebugFlag  INT
   DECLARE @cUCCNo      NVARCHAR(20)
   DECLARE @cUCCSKU     NVARCHAR(20)
   DECLARE @cFacility   NVARCHAR( 5)

   SELECT @cFacility = Facility FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile
  
   IF @nFunc = 861 -- UCC Pick 
   BEGIN  
      IF @nStep = 5 -- UCC  
      BEGIN  
         IF @nInputKey = 1 -- ENTER  
         BEGIN
            IF @cBarCode <> '' 
            BEGIN 
               SET @cBarcode = LTRIM(RTRIM(@cBarcode))
               
               IF LEN(@cBarCode) = 49 --Fertin label
               BEGIN
                  SET @cUCCNo = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 246151
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 246152
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END--Fertin label
               ELSE IF LEN(@cBarcode) = 57 --Swedish label
               BEGIN
                  SET @cUCCNo = SUBSTRING(@cBarcode, 19, 17)
                  SET @cUCCSKU = SUBSTRING(@cBarcode, 39, 11)

                  IF LEFT(@cUCCSKU, 2) <> 'NP'
                  BEGIN
                     SET @nErrNo = 246153
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  IF NOT EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cUCCSKU)
                  BEGIN
                     SET @nErrNo = 246154
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END
               END -- swedish label 
               --V1.1 end
               ELSE -- existing standard logic
               BEGIN
                  SET @cUCCNo = ''
                  EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                     @cUCCNo  = @cUCCNo        OUTPUT,
                     @nErrNo  = @nErrNo      OUTPUT,
                     @cErrMsg = @cErrMsg     OUTPUT,
                     @cType   = 'UCCNo'

                  IF @nErrNo <> 0
                     GOTO Quit
               END

               SET @cUCC = @cUCCNo
            END -- UCC Decoding
         END  --inputkey=1
      END  
   END  
  
Quit:  
  
END 
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_861DecodeSP01 TO NSQL
GO