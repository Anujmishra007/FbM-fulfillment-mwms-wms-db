SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

    
/******************************************************************************/      
/* Store procedure: isp_TPS_SkipSKUAD01                                       */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */ 
/* Purpose        : Customize the order which  Skip AD Scn                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */      
/* 2025-04-04   1.0  YeeKung    FCR-3751 Created                              */      
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPS_SkipSKUAD01] (      
   @cStorerKey    NVARCHAR( 15),
   @cFacility     NVARCHAR( 5),
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @cPickslipNo   NVARCHAR( 20),
   @cDropID       NVARCHAR( 20),
   @cOrderKey     NVARCHAR( 10),
   @cSkipSKUADScn NVARCHAR( 1) OUTPUT,
   @b_Success     INT = 1      OUTPUT,
   @n_Err         INT = 0      OUTPUT,
   @c_ErrMsg      NVARCHAR( 255) = ''  OUTPUT
)      
AS    
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUDF01  NVARCHAR(20)
   DECLARE @cConsigneeKey  NVARCHAR(20)
   DECLARE @cLoadkey   NVARCHAR(20)
   DECLARE @cMarketSegment  NVARCHAR(20)

   SET @b_Success = 0

   SELECT @cLoadkey = ExternOrderKey
   FROM PICKHEADER (NOLOCK)
   WHERE PickHeaderKey =  @cPickslipNo


   SELECT TOP 1 @cOrderkey = OrderKey
   FROM Orders (NOLOCK)
   WHERE StorerKey = @cStorerKey 
      AND Loadkey = @cLoadkey 

   IF EXISTS ( Select 1
               FROM Orders (NOLOCK)
               WHERE Orderkey = @cOrderkey
                  AND Storerkey = @cStorerkey 
                  AND BillToKey IN (   SELECT  Code  
                                       FROM Codelkup (NOLOCK)
                                       WHERE Listname = 'SKIPBILLTO'
                                          AND Storerkey = @cStorerkey 
                                    ))
   BEGIN
      SET @cSkipSKUADScn = '1'
   END
   ELSE
   BEGIN
      SET @cSkipSKUADScn = '0' 
   END
   SET @b_Success = 1
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPS_SkipSKUAD01 TO NSQL
GO


