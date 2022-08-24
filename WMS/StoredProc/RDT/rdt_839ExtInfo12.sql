


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Store procedure: rdt_839ExtInfo12                                    */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2022-07-05  1.0  yeekung   WMS-20134 Created                         */  
/************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdt_839ExtInfo12 (  
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
   @cExtendedInfo NVARCHAR(20) OUTPUT, 
   @nErrNo       INT           OUTPUT, 
   @cErrMsg      NVARCHAR(250) OUTPUT  
)  
AS  

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cID         NVARCHAR( 18)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)  
   DECLARE @ccurPD      CURSOR
   DECLARE @nPD_Qty     INT
   DECLARE @cOrderkey   NVARCHAR(20)
   
   SET @cExtendedInfo = ''

   IF @nStep IN (2) 
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SELECT @cOrderkey=orderkey
         FROM Pickheader (NOLOCK)
         WHERE pickheaderkey=@cPickSlipNo

         SELECT @cExtendedInfo=id
         FROM  pickdetail (nolock)
         where orderkey=@cOrderkey
      END
   END
  
QUIT:  
 
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_839ExtInfo12 TO NSQL
GO
  
 