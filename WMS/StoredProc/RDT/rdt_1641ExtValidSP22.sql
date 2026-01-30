SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************/            
/* Store procedure: rdt_1641ExtValidSP22                                      */            
/* Purpose: Validate Pallet DropID                                            */            
/*                                                                            */            
/* Modifications log:                                                         */            
/*                                                                            */            
/* Date       Rev  Author     Purposes                                        */            
/* 2025-12-12 1.0  PSJ036     UWP-48078 Created                               */  
/******************************************************************************/            
            
CREATE OR ALTER      PROC [RDT].[rdt_1641ExtValidSP22] (           
   @nMobile      INT,            
   @nFunc        INT,            
   @cLangCode    NVARCHAR(3),            
   @nStep        INT,            
   @nInputKey    INT,             
   @cStorerKey   NVARCHAR(15),            
   @cDropID      NVARCHAR(20),            
   @cUCCNo       NVARCHAR(20),            
   @cPrevLoadKey NVARCHAR(10),            
   @cParam1      NVARCHAR(20),            
   @cParam2      NVARCHAR(20),            
   @cParam3      NVARCHAR(20),            
   @cParam4      NVARCHAR(20),            
   @cParam5      NVARCHAR(20),            
   @nErrNo       INT          OUTPUT,            
   @cErrMsg      NVARCHAR(20) OUTPUT            
)            
AS            
            
SET NOCOUNT ON            
SET QUOTED_IDENTIFIER OFF            
SET ANSI_NULLS OFF            
            
IF @nFunc = 1641            
BEGIN            
   DECLARE @cPickSlipNo       			NVARCHAR(10),            
           @cOrderKey         			NVARCHAR(10),             
           @cRoute            			NVARCHAR(30),            
           @cDocType          			NVARCHAR(1),          
           @cMVat             			NVARCHAR(18),          
           @cOdrCountry       			NVARCHAR(30),          
           @cStrCountry       			NVARCHAR(30),          
           @cShipperKey       			NVARCHAR(15),          
           @cSalesMan         			NVARCHAR(30),          
           @cPlatform         			NVARCHAR(30),           
           @nCartonNo         			INT,              
           @nDebug            			INT,  
           @cOrderGroup       			NVARCHAR(20),  
           @cAccomPlatform    			NVARCHAR(30),  
           @cBID              			NVARCHAR(20),
		   @cConsigneeKey				NVARCHAR(20),
		   @cPalletConsigneeKey			NVARCHAR(20),
           @cIntermodalVehicle   		NVARCHAR(30),
		   @cPalletIntermodalVehicle	NVARCHAR(30)
 
		   
   SET @nDebug = 0            
               
            
--if suser_sname() = 'wmsgt'            
--set @nDebug = 1            
            
   SET @nErrNo = 0            
              
   IF @nStep = 3 -- UCC            
   BEGIN            
    IF @nInputKey = 1 -- ENTER            
      BEGIN             
--CCH
         SELECT           
            @cPickSlipNo 			= PD.PickSlipNo,          
            @cOrderkey 				= PH.OrderKey,          
            @cDocType 				= Doctype,          
            @nCartonNo 				= PD.CartonNo,          
            @cRoute 				= O.Route,          
            @cShipperKey 			= O.ShipperKey,          
            @cSalesMan 				= O.Salesman,          
            @cOrderGroup 			= O.ordergroup,    
            @cBID       			= O.userdefine10, --(yeekung03)
			@cIntermodalVehicle 	= O.IntermodalVehicle,
			@cConsigneeKey			= O.ConsigneeKey
	     From dbo.PackDetail PD WITH (NOLOCK)           
         JOIN dbo.PackHeader PH WITH (NOLOCK) ON (PH.StorerKey = PD.StorerKey AND PH.PickSlipNo = PD.PickSlipNo)          
         JOIN dbo.Orders O WITH (NOLOCK) ON (PH.StorerKey = O.StorerKey AND O.OrderKey = PH.OrderKey)       
         WHERE PH.Storerkey = @cStorerKey                
         AND PD.DropID = @cUCCNo        
         AND PD.DropID <> ''        
         AND PH.Status = '9'
		 AND O.Status  = '5'
         
		 IF @@ROWCOUNT = 0          
         BEGIN 
			SELECT           
				@cPickSlipNo 			= PD.PickSlipNo,          
				@cOrderkey 				= PH.OrderKey,          
				@cDocType 				= Doctype,          
				@nCartonNo 				= PD.CartonNo,          
				@cRoute 				= O.Route,          
				@cShipperKey 			= O.ShipperKey,          
				@cSalesMan 				= O.Salesman,          
				@cOrderGroup 			= O.ordergroup,    
				@cBID       			= O.userdefine10, --(yeekung03)
				@cIntermodalVehicle 	= O.IntermodalVehicle,
			    @cConsigneeKey			= O.ConsigneeKey
			From dbo.PackDetail PD WITH (NOLOCK)           
			JOIN dbo.PackHeader PH WITH (NOLOCK) ON (PH.StorerKey = PD.StorerKey AND PH.PickSlipNo = PD.PickSlipNo)          
			JOIN dbo.Orders O WITH (NOLOCK) ON (PH.StorerKey = O.StorerKey AND O.OrderKey = PH.OrderKey)       
			WHERE PH.Storerkey = @cStorerKey                
			AND PD.LabelNo = @cUCCNo        
			AND PD.LabelNo <> ''        
			AND PH.Status = '9'          
		    AND O.Status  = '5'
			
			IF @@ROWCOUNT = 0          
			BEGIN          
				SELECT           
				@cPickSlipNo 			= PD.PickSlipNo,          
				@cOrderkey 				= PH.OrderKey,          
				@cDocType 				= Doctype,          
				@nCartonNo 				= PD.CartonNo,          
				@cRoute 				= O.Route,          
				@cShipperKey 			= O.ShipperKey,          
				@cSalesMan 				= O.Salesman,          
				@cOrderGroup 			= O.ordergroup,  
				@cBID       			= O.userdefine10, --(yeekung03)
				@cIntermodalVehicle 	= O.IntermodalVehicle,
				@cConsigneeKey			= O.ConsigneeKey
				From dbo.PackDetail PD WITH (NOLOCK)           
				JOIN dbo.PackHeader PH WITH (NOLOCK) ON (PH.StorerKey = PD.StorerKey AND PH.PickSlipNo = PD.PickSlipNo)          
				JOIN dbo.Orders O WITH (NOLOCK) ON (PH.StorerKey = O.StorerKey AND O.OrderKey = PH.OrderKey)          
			WHERE PH.Storerkey = @cStorerKey           
				AND PD.Refno = @cUCCNo      
				AND PD.Refno <> ''      
				AND PH.Status = '9'
				AND O.Status  = '5'				
				
				IF @@ROWCOUNT = 0          
				BEGIN          
					SELECT           
					@cPickSlipNo 			= PD.PickSlipNo,          
					@cOrderkey 				= PH.OrderKey,          
					@cDocType 				= Doctype,          
					@nCartonNo 				= PD.CartonNo,          
					@cRoute 				= O.Route,          
					@cShipperKey 			= O.ShipperKey,          
					@cSalesMan 				= O.Salesman,          
					@cOrderGroup 			= O.ordergroup,  
					@cBID       			= O.userdefine10, --(yeekung03)
					@cIntermodalVehicle 	= O.IntermodalVehicle,
					@cConsigneeKey			= O.ConsigneeKey
					From dbo.PackDetail PD WITH (NOLOCK)           
					JOIN dbo.PackHeader PH WITH (NOLOCK) ON (PH.StorerKey = PD.StorerKey AND PH.PickSlipNo = PD.PickSlipNo)          
					JOIN dbo.Orders O WITH (NOLOCK) ON (PH.StorerKey = O.StorerKey AND O.OrderKey = PH.OrderKey)          
				WHERE PH.Storerkey = @cStorerKey           
					AND PD.Refno2 = @cUCCNo      
					AND PD.Refno2 <> ''      
					AND PH.Status = '9'
					AND O.Status  = '5'
		
					IF @@ROWCOUNT = 0          
					BEGIN          
					SET @nErrNo = 257541            
					SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Ucc          
					GOTO Quit          
					END
				END
			END	
         END
		 
                  
         IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader WHERE Storerkey = @cStorerKey AND pickslipNo = @cPickSlipNo AND Status = '9' )            
         BEGIN          
            SET @nErrNo = 257542            
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Pack Not Done          
            GOTO Quit          
         END          
                      
         IF EXISTS (SELECT * FROM dbo.PalletDetail WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND caseID = @cUCCNo)          
         BEGIN          
            SET @nErrNo = 257543            
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Scanned UCC          
            GOTO Quit            
         END          
                   
         IF @cDocType = 'N' --B2B          
         BEGIN          
            /* IF Exists (Select 1 From Codelkup   
                        Where Listname = 'CUSTPARAM'  
                           And Storerkey = @cStorerKey   
                           And Code = 'B2BPPA'   
                           And Code2 = 'YES')  
            BEGIN  
               IF (EXISTS (SELECT 1               
                              FROM PackDetail PD WITH (NOLOCK)               
                              LEFT JOIN RDT.RDTPPA R (NOLOCK) ON PD.STORERKEY = R.STORERKEY AND PD.DROPID = R.DROPID AND PD.SKU = R.SKU            
                              WHERE PD.StorerKey = @cStorerKey               
                              AND PD.DropID = @cUCCNo               
                              AND Qty <> ISNULL(R.CQty,0))  )            
                  OR (EXISTS (SELECT 1 FROM RDT.RDTPPA R WITH (NOLOCK)            
                                 WHERE R.StorerKey = @cStorerKey            
                                 AND R.DropID = @cUCCNo            
                                 AND CQty > 0            
                                 AND NOT EXISTS (SELECT 1 FROM PackDetail PD WITH (NOLOCK)            
                                                WHERE PD.STORERKEY = R.STORERKEY AND PD.DROPID = R.DROPID AND PD.SKU = R.SKU)))            
               BEGIN          
                  SET @nErrNo = 200954            
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid PPA          
                  GOTO Quit           
               END          
            END */         
                    
            --SELECT @cStrCountry = Country FROM storer (NOLOCK) WHERE StorerKey = @cStorerKey            
                        
            IF EXISTS (SELECT 1              
                     FROM dbo.palletDetail PltD WITH (NOLOCK)              
                     JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PD.StorerKey = PltD.StorerKey AND PD.LabelNo = PltD.caseID)              
                     JOIN dbo.PackHeader PH WITH (NOLOCK) ON (PD.StorerKey = PH.storerKey AND PH.PickSlipNo = PD.PickSlipNo)              
                     JOIN dbo.Orders O WITH (NOLOCK) ON (PH.StorerKey = O.StorerKey AND PH.OrderKey = O.OrderKey)              
                     WHERE PltD.Palletkey = @cDropID              
                     AND PltD.StorerKey = @cStorerKey              
                     --AND (O.C_Country <> @cOdrCountry              
                     --OR O.Route <> @cRoute)          
                     AND (O.ConsigneeKey <> @cConsigneeKey
					   OR O.IntermodalVehicle <> @cIntermodalVehicle)
					 AND ISNULL(PltD.caseID,'') <> '')                                  
            BEGIN          
               SET @nErrNo = 257544            
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Batch             
               GOTO Quit          
            END                    
         END          
                   
         IF @cDocType = 'E' --B2C          
         BEGIN          
            IF EXISTS (SELECT 1      
                     FROM dbo.palletDetail PltD WITH (NOLOCK)      
                     JOIN dbo.PackDetail PD WITH (NOLOCK) ON (PD.StorerKey = PltD.StorerKey AND PD.LabelNo = PltD.caseID)      
                     JOIN dbo.PackHeader PH WITH (NOLOCK) ON (PD.StorerKey = PH.storerKey AND PH.PickSlipNo = PD.PickSlipNo)      
                     JOIN dbo.Orders O WITH (NOLOCK) ON (PH.StorerKey = O.StorerKey AND PH.OrderKey = O.OrderKey)      
                     WHERE PltD.Palletkey = @cDropID      
                     AND PltD.StorerKey = @cStorerKey      
                     --AND (LEFT(o.C_Country,2)<> LEFT(@cOdrCountry,2)   
                     --      OR O.ShipperKey <> @cShipperKey)      
					 AND (O.IntermodalVehicle <> @cIntermodalVehicle)
                     AND ISNULL(PltD.caseID,'') <> '')                         
            BEGIN  
               SET @nErrNo = 257545    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Diff Batch     
               GOTO Quit  
            END  
         END          
      END          
   END            
END            
            
Quit:

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1641ExtValidSP22] TO [NSQL]
GO