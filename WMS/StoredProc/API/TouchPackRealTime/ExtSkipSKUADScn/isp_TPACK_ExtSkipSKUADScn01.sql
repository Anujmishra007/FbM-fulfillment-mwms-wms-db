SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

    
/******************************************************************************/      
/* Store procedure: isp_TPACK_ExtSkipSKUADScn01                               */      
/* Copyright      : Maersk                                                    */      
/*                                                                            */ 
/* Purpose        : Customize the order which  Skip AD Scn                    */
/*                                                                            */
/* Date         Rev  Author     Purposes                                      */      
/* 2026-01-12   1.0  GCH225     FCR-3751 Created                              */      
/******************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPACK_ExtSkipSKUADScn01] (      
     @cType          NVARCHAR(30)   = ''
   , @bIsDiscrete    BIT            = 0
   , @bIsCustom      BIT            = 0
   , @cPickSlipNo    NVARCHAR(10)   = ''
   , @cOrderKey      NVARCHAR(10)   = ''
   , @cLoadKey       NVARCHAR(10)   = ''
   , @cDropID        NVARCHAR(20)   = ''
   , @cStorerKey     NVARCHAR(15)   = ''
   , @cFacility      NVARCHAR(5)    = ''
   , @c_UserID       NVARCHAR(256)  = ''  
   , @cLangCode      NVARCHAR( 3)   = ''
   , @cSkipSKUADScn  NVARCHAR( 1)   = ''  OUTPUT  
   , @b_Success      INT            = 1   OUTPUT
   , @n_ErrNo        INT            = 0   OUTPUT
   , @c_ErrMsg       NVARCHAR( 255) = ''  OUTPUT
)      
AS    
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @b_Success = 1
   SET @cSkipSKUADScn = '0' 

   IF @cLoadKey = ''
   BEGIN
      GOTO EXIT_SP
   END

   SELECT 1
   FROM ORDERS O (NOLOCK)
   WHERE O.StorerKey = @cStorerKey 
   AND O.Loadkey = @cLoadkey
   AND EXISTS (SELECT 1
               FROM CODELKUP C (NOLOCK)
               WHERE C.Listname = 'SKIPBILLTO'
               AND C.Storerkey = @cStorerkey 
               AND C.Code = O.BillToKey
               )

   IF @@ROWCOUNT > 0
   BEGIN
      SET @cSkipSKUADScn = '1'
   END

EXIT_SP:
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.isp_TPACK_ExtSkipSKUADScn01 TO NSQL
GO


