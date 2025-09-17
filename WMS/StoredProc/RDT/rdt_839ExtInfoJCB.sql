
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************/
/* Store procedure: [rdt_839ExtInfoJCB]                                              */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 16/09/2025   1.0   PPA374   Mark order as started                                 */
/*************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_839ExtInfoJCB] (
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
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cOrderKey AS NVARCHAR( 20)

   SELECT 
      @cOrderKey = OrderKey 
   FROM dbo.PICKHEADER WITH(NOLOCK) 
   WHERE PickHeaderKey = @cPickSlipNo

   IF @nFunc = 839
   BEGIN
      IF @nStep = 2
	     AND @nInputKey = 0 --PickSlipNo
      BEGIN
	     UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
		 SET Notes = ''
		 WHERE OrderKey = @cOrderKey
		    AND Notes = 'Started'
	  END
   END
Quit:
END
GO

GRANT EXECUTE ON rdt_839ExtInfoJCB TO NSQL
GO
