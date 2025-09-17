
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************************************************************************/
/* Store procedure: [rdt_839ExtUpdJCB]                                               */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 16/09/2025   1.0   PPA374   Mark order as started                                 */
/*************************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_839ExtUpdJCB] (
   @nMobile         INT          
   ,@nFunc           INT          
   ,@cLangCode       NVARCHAR( 3)              
   ,@nStep           INT          
   ,@nInputKey       INT          
   ,@cFacility       NVARCHAR( 5)              
   ,@cStorerKey      NVARCHAR( 15)             
   ,@cPickSlipNo     NVARCHAR( 10)             
   ,@cPickZone       NVARCHAR( 10)             
   ,@cDropID         NVARCHAR( 20)             
   ,@cLOC            NVARCHAR( 10)             
   ,@cSKU            NVARCHAR( 20)             
   ,@nQTY            INT          
   ,@cOption         NVARCHAR( 1)              
   ,@cLottableCode   NVARCHAR( 30)             
   ,@cLottable01     NVARCHAR( 18)             
   ,@cLottable02     NVARCHAR( 18)             
   ,@cLottable03     NVARCHAR( 18)             
   ,@dLottable04     DATETIME     
   ,@dLottable05     DATETIME     
   ,@cLottable06     NVARCHAR( 30)             
   ,@cLottable07     NVARCHAR( 30)             
   ,@cLottable08     NVARCHAR( 30)             
   ,@cLottable09     NVARCHAR( 30)             
   ,@cLottable10     NVARCHAR( 30)             
   ,@cLottable11     NVARCHAR( 30)             
   ,@cLottable12     NVARCHAR( 30)             
   ,@dLottable13     DATETIME     
   ,@dLottable14     DATETIME     
   ,@dLottable15     DATETIME     
   ,@cPackData1      NVARCHAR( 30)             
   ,@cPackData2      NVARCHAR( 30)             
   ,@cPackData3      NVARCHAR( 30)             
   ,@nErrNo          INT           OUTPUT      
   ,@cErrMsg         NVARCHAR(250) OUTPUT     
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
      IF @nStep = 1
	     AND @nInputKey = 1 --PickSlipNo
      BEGIN
	     UPDATE dbo.PICKDETAIL WITH(ROWLOCK)
		 SET Notes = 'Started'
		 WHERE OrderKey = @cOrderKey
	  END
   END
Quit:
END
GO

GRANT EXECUTE ON rdt_839ExtUpdJCB TO NSQL
GO

