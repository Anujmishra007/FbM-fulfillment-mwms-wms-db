IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[rdt].[rdt_839ExtValidSP09]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [rdt].[rdt_839ExtValidSP09]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

  
/************************************************************************/    
/* Store procedure: rdt_839ExtValidSP09                                 */    
/* Purpose: Validate Dropid format based on orders.type                 */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date       Rev  Author     Purposes                                  */    
/* 2021-10-28 1.0  James      WMS-18174. Created                        */    
/************************************************************************/    
CREATE PROC rdt.rdt_839ExtValidSP09 (    
   @nMobile      INT,             
   @nFunc        INT,             
   @cLangCode    NVARCHAR( 3),    
   @nStep        INT,             
   @nInputKey    INT,             
   @cFacility    NVARCHAR( 5) ,   
   @cStorerKey   NVARCHAR( 15),   
   @cType        NVARCHAR( 10),   
   @cPickSlipNo  NVARCHAR( 10),   
   @cPickZone    NVARCHAR( 10),    
   @cDropID      NVARCHAR( 20),   
   @cLOC         NVARCHAR( 10),   
   @cSKU         NVARCHAR( 20),   
   @nQTY         INT,             
   @nErrNo       INT           OUTPUT,   
   @cErrMsg      NVARCHAR(250) OUTPUT    
)    
AS    
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
    
IF @nFunc = 839    
BEGIN    
   DECLARE @cOrderKey         NVARCHAR( 10) = ''  
   DECLARE @cOrdType          NVARCHAR( 10) = ''  
   DECLARE @cWaveKey          NVARCHAR( 10) = ''  
   DECLARE @cDocType          NVARCHAR( 1) = ''  
     
   SET @nErrNo          = 0  
   SET @cErrMSG         = ''  
     
   IF @nStep = 2   
   BEGIN  
      IF @nInputKey = 1 -- ENTER  
      BEGIN  
         SELECT TOP 1 @cOrderKey = OrderKey  
         FROM dbo.PICKDETAIL WITH (NOLOCK)  
         WHERE PickSlipNo = @cPickSlipNo  
         ORDER BY 1  
           
         SELECT @cOrdType = DocType,   
                @cWaveKey = UserDefine09,  
                @cDocType = DocType  
         FROM dbo.ORDERS WITH (NOLOCK)  
         WHERE OrderKey = @cOrderKey  
        
         IF @cOrdType IN ('E', 'N')  
         BEGIN  
            IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'DROPID' + RTRIM( @cOrdType), @cDropID) = 0    
            BEGIN    
               SET @nErrNo = 178101    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format    
               GOTO QUIT    
            END    
         END   
  
         IF EXISTS ( SELECT 1 FROM dbo.PICKDETAIL PD WITH (NOLOCK)   
                     JOIN dbo.ORDERS O WITH (NOLOCK) ON ( PD.OrderKey = O.OrderKey)  
                     WHERE PD.Storerkey = @cStorerKey                           
                     AND   PD.[Status] = '5'                        
                     AND   PD.DropID = @cDropID  
                     AND   O.UserDefine09 <> @cWaveKey                           
                     AND   NOT EXISTS (SELECT 1 FROM dbo.PackHeader PH WITH (NOLOCK)                           
                                       WHERE PH.OrderKey = PD.Orderkey                           
                                       AND   PH.StorerKey = PD.Storerkey  
                                       AND   PH.Status = '9'))      
         BEGIN      
            SET @nErrNo = 178102              
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'DropID In Use'              
            GOTO QUIT      
         END     
           
         IF @cDocType = 'N'  
         BEGIN  
            IF EXISTS ( SELECT 1 FROM dbo.PackDetail PD WITH (NOLOCK)  
                        JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)  
                        WHERE PH.StorerKey = @cStorerKey  
                        AND   PH.OrderKey <> @cOrderKey  
                        AND   PD.DropID = @cDropID)  
            BEGIN      
               SET @nErrNo = 178103              
             SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'DropID In Use'              
               GOTO QUIT      
            END    
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

GRANT EXECUTE ON [rdt].[rdt_839ExtValidSP09] TO NSQL
GO  
  