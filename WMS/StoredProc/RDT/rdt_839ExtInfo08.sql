GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO   
/************************************************************************/    
/* Store procedure: rdt_839ExtInfo08                                    */    
/* Purpose:                                                             */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date       Rev  Author     Purposes                                  */    
/* 2021-09-23 1.0  James      WMS-18004. Created                        */ 
/* 2022-04-20 1.1  YeeKung    WMS-19311 Add Data capture (yeekung01)    */
/************************************************************************/    
    
CREATE OR ALTER PROC rdt.rdt_839ExtInfo08 (    
   @nMobile      INT,    
   @nFunc        INT,    
   @cLangCode    NVARCHAR( 3),    
   @nStep        INT,    
   @nAfterStep   INT,    
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
   @nActQty      INT,    
   @nSuggQTY     INT,    
   @cPackData1   NVARCHAR( 30),
   @cPackData2   NVARCHAR( 30),
   @cPackData3   NVARCHAR( 30),  
   @cExtendedInfo NVARCHAR(20) OUTPUT,    
   @nErrNo       INT           OUTPUT,    
   @cErrMsg      NVARCHAR(250) OUTPUT    
)    
AS    
    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
     
   DECLARE @cOrderKey   NVARCHAR( 10) = ''  
   DECLARE @cECOM_SINGLE_FLAG    NVARCHAR(1) = ''  
   DECLARE @cTempPKZone NVARCHAR( 20) = ''  
   DECLARE @cPKZone     NVARCHAR( 10) = ''  
     
   SET @cExtendedInfo = ''  
     
   IF @nAfterStep = 2  
   BEGIN  
      IF @nInputKey = 1  
      BEGIN  
         SELECT TOP 1    
            @cOrderKey = OrderKey  
         FROM dbo.PickDetail WITH (NOLOCK)    
         WHERE PickSlipNo = @cPickSlipNo    
         ORDER BY 1  
           
         SELECT @cECOM_SINGLE_FLAG = ECOM_SINGLE_FLAG    
         FROM dbo.ORDERS WITH (NOLOCK)  
         WHERE OrderKey = @cOrderKey   
              
           
           
         DECLARE @curPickZone CURSOR  
         SET @curPickZone = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
         SELECT DISTINCT LOC.PickZone  
         FROM dbo.PickDetail PD WITH (NOLOCK)  
         JOIN dbo.LOC LOC WITH (NOLOCK) ON ( PD.LOC = LOC.LOC)  
         WHERE PD.PickSlipNo = @cPickSlipNo  
         AND   PD.Qty > 0  
         AND   PD.[Status] <> '4'  
         AND   LOC.Facility = @cFacility  
         ORDER BY LOC.PickZone  
         OPEN @curPickZone  
         FETCH NEXT FROM @curPickZone INTO @cPKZone  
         WHILE @@FETCH_STATUS = 0  
         BEGIN  
            SET @cTempPKZone = @cTempPKZone + '/' + RTRIM( @cPKZone)   
              
            FETCH NEXT FROM @curPickZone INTO @cPKZone  
         END  
  
         SET @cTempPKZone =  RIGHT( @cTempPKZone, LEN( @cTempPKZone) - 1)   
           
         SET @cExtendedInfo = 'TYPE:' + @cECOM_SINGLE_FLAG + ' ZONE:' + @cTempPKZone  
      END  
   END  
    
QUIT:  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_839ExtInfo08 TO NSQL
GO
  