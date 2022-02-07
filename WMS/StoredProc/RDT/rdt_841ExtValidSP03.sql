IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_841ExtValidSP03]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_841ExtValidSP03]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Store procedure: rdt_841ExtValidSP03                                 */  
/* Purpose: Validate tote only contain single sku orders                */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2020-01-03 1.0  James      WMS-11634. Created                        */  
/* 2021-04-01 1.1  YeeKung    WMS-16718 Add serialno and serialqty      */
/*                            Params (yeekung02)                        */ 
/************************************************************************/  
  
CREATE PROC rdt.rdt_841ExtValidSP03 (  
   @nMobile     INT,  
   @nFunc       INT,   
   @cLangCode   NVARCHAR(3),   
   @nStep       INT,   
   @cStorerKey  NVARCHAR(15),   
   @cDropID     NVARCHAR(20),  
   @cSKU        NVARCHAR(20), 
   @cPickSlipNo NVARCHAR(10),
   @cSerialNo   NVARCHAR( 30), 
   @nSerialQTY  INT,  
   @nErrNo      INT       OUTPUT,   
   @cErrMsg     CHAR( 20) OUTPUT
)  
AS  

SET NOCOUNT ON       
SET QUOTED_IDENTIFIER OFF       
SET ANSI_NULLS OFF      
SET CONCAT_NULL_YIELDS_NULL OFF   

   DECLARE @nInputKey      INT
   DECLARE @cLoadKey       NVARCHAR( 10)
   
   SELECT @nInputKey = InputKey, 
          @cLoadKey = I_Field03
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nStep = 1
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @cLoadKey <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                       JOIN dbo.ORDERS O WITH (NOLOCK) ON ( PD.OrderKey = O.OrderKey)
                       WHERE PD.Storerkey = @cStorerKey
                       AND   O.LoadKey = @cLoadKey
                       AND   O.ECOM_SINGLE_Flag <> 'S')
            BEGIN            
               SET @nErrNo = 147301            
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong ord type            
               GOTO QUIT              
            END
         END
         ELSE
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.PICKDETAIL PD WITH (NOLOCK)
                       JOIN dbo.ORDERS O WITH (NOLOCK) ON ( PD.OrderKey = O.OrderKey)
                       WHERE PD.Storerkey = @cStorerKey
                       AND   PD.DropID = @cDropID
                       AND   O.ECOM_SINGLE_Flag <> 'S')
            BEGIN            
               SET @nErrNo = 147302            
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Wrong ord type            
               GOTO QUIT              
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
GRANT EXEC ON RDT.rdt_841ExtValidSP03 TO NSQL
GO