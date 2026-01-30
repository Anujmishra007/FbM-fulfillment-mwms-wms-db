SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**************************************************************************************/      
/* Store procedure: rdt_1813ExtValid07                                                */      
/* Purpose: Move By ID Extended Validate                                              */      
/*                                                                                    */      
/* Called from: rdtfnc_PalletConsolidate                                              */      
/*                                                                                    */      
/*                                                                                    */      
/* Modifications log:                                                                 */      
/*                                                                                    */      
/* Date       Rev  Author     Purposes                                                */      
/* 12-12-2025 1.0  PSJ036     UWP-48149 - Created - Don't mix Order Type (B2C x B2B)  */      
/**************************************************************************************/      
      
CREATE OR ALTER   PROC [RDT].[rdt_1813ExtValid07] (      
   @nMobile          INT,      
   @nFunc            INT,       
   @cLangCode        NVARCHAR( 3),       
   @nStep            INT,       
   @nInputKey        INT,       
   @cStorerKey       NVARCHAR( 15),       
   @cFromID          NVARCHAR( 20),       
   @cOption          NVARCHAR( 1),       
   @cSKU             NVARCHAR( 20),       
   @nQty             INT,       
   @cToID            NVARCHAR( 20),       
   @nErrNo           INT           OUTPUT,       
   @cErrMsg          NVARCHAR( 20) OUTPUT      
)      
AS      
         
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
      
   DECLARE @cFacility                   NVARCHAR( 5)      
   DECLARE @cOnScreenSKU                NVARCHAR( 20)      
   DECLARE @cItemClass                  NVARCHAR( 10)      
   DECLARE @cFromScn                    NVARCHAR( 4)      
   DECLARE @cFromLOC                    NVARCHAR( 10)      
   DECLARE @cToLOC                      NVARCHAR( 10)      
          ,@cOrderKey                   NVARCHAR( 10)             
          ,@cDocType                    NVARCHAR( 1)
		  ,@cConsigneeKey				NVARCHAR( 20)
		  ,@cPalletConsigneeKey			NVARCHAR( 20)
          ,@cProductModel               NVARCHAR( 30)      
          ,@cPQty                       NVARCHAR( 5)      
          ,@cMQty                       NVARCHAR( 5)      
          ,@cLocationCategory           NVARCHAR( 10)      
		  ,@cInField02 					NVARCHAR( 60)  
  
   DECLARE @nLLI_Qty       INT      
   DECLARE @nLLI_QtyAlloc  INT      
   DECLARE @nLLI_QtyPick   INT      
   DECLARE @nToID_Qty       INT      
   DECLARE @nToID_QtyAlloc  INT      
   DECLARE @nToID_QtyPick   INT      
      
   SELECT @cFacility 	= Facility,      
          @cOption 		= I_Field09,      
          @cFromScn 	= V_String25,      
          @cOnScreenSKU = O_Field05,      
          @cFromLOC 	= V_LOC,      
          @cPQTY    	= I_Field08,      
          @cMQTY    	= I_Field13
   FROM RDT.RDTMOBREC WITH (NOLOCK)       
   WHERE Mobile = @nMobile      
      
   SET @nErrNo = 0      
      
   IF @nInputKey = 1      
   BEGIN      
      IF @nStep IN (4, 5)      
      BEGIN      
         SELECT           
            @cOrderkey 				= PD.OrderKey,          
            @cDocType 				= Doctype          
	     From dbo.PickDetail PD WITH (NOLOCK)           
         JOIN dbo.Orders O WITH (NOLOCK) ON (PD.StorerKey = O.StorerKey AND O.OrderKey = PD.OrderKey)       
         WHERE PD.Storerkey = @cStorerKey                
         AND PD.ID = @cFromID  -- FROMID        
         AND PD.Status = '3'

         IF @cDocType = 'N' --B2B          
         BEGIN          
            IF EXISTS (SELECT 1              
                     FROM dbo.PickDetail PD WITH (NOLOCK)              
                     JOIN dbo.Orders O WITH (NOLOCK) ON (PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey)              
                     WHERE PD.ID = @cToID              
                     AND PD.StorerKey = @cStorerKey              
                     AND O.Doctype <> @cDocType)

            BEGIN          
               SET @nErrNo = 257621            
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Only B2B            
               GOTO Quit          
            END                    
         END          
		 
		 IF @cDocType = 'E' --B2C 
         BEGIN          
            IF EXISTS (SELECT 1              
                     FROM dbo.PickDetail PD WITH (NOLOCK)              
                     JOIN dbo.Orders O WITH (NOLOCK) ON (PD.StorerKey = O.StorerKey AND PD.OrderKey = O.OrderKey)              
                     WHERE PD.ID = @cToID              
                     AND PD.StorerKey = @cStorerKey              
                     AND O.Doctype <> @cDocType)
            BEGIN          
               SET @nErrNo = 257622            
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Only B2C             
               GOTO Quit          
            END                    
         END          
      END
   END      
      
QUIT:   

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1813ExtValid07] TO [NSQL]
GO