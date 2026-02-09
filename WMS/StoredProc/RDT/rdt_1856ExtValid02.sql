SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/************************************************************************/        
/* Store procedure: rdt_1856ExtValid02                                  */        
/* Copyright      : IDS                                                 */        
/*                                                                      */        
/* Called from: rdtfnc_MbolCreation                                     */        
/*                                                                      */        
/* Purpose: Validate @cRefNo1 is null                                   */        
/*                                                                      */        
/* Modifications log:                                                   */        
/* Date        Rev  Author   Purposes                                   */        
/* 2025-12-12  1.0  PSJ036   UWP-48145. Created                         */      
/************************************************************************/        
        
CREATE OR ALTER     PROC [RDT].[rdt_1856ExtValid02] (        
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cMBOLKey       NVARCHAR( 10),  
   @cOrderKey      NVARCHAR( 10),  
   @cLoadKey       NVARCHAR( 10),  
   @cRefNo1        NVARCHAR( 20),  
   @cRefNo2        NVARCHAR( 20),
   @cRefNo3        NVARCHAR( 20),
   @tExtValidate   VariableTable READONLY,   
   @nErrNo         INT           OUTPUT,  
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS        
BEGIN        
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF        
       
   IF @nStep = 2    
   BEGIN    
      IF @nInputKey = 1    
      BEGIN    
      	IF ISNULL( @cRefNo1, '') <> ''
         BEGIN    
            IF NOT EXISTS ( SELECT 1 FROM dbo.ORDERS WITH (NOLOCK)    
                            WHERE Storerkey = @cStorerKey    
                            AND   DeliveryNote = @cRefNo1)    
            BEGIN    
               SET @nErrNo = 257581    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inv Pallet No    
               GOTO Quit    
            END
			--IF EXISTS 	  ( SELECT 1 FROM dbo.ORDERS WITH (NOLOCK)    
            --                WHERE Storerkey = @cStorerKey    
            --                AND   DeliveryNote = @cRefNo1
			--				AND   DocType = 'N')
			--BEGIN    
            --   SET @nErrNo = 191611    
            --   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need to B2C Orders    
            --   GOTO Quit    
            --END
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

GRANT EXECUTE ON [RDT].[rdt_1856ExtValid02] TO [NSQL]
GO
