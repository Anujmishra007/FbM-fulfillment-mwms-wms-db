IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnc_EncryptURLQueryString]')  AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')) 
   DROP FUNCTION [dbo].[fnc_EncryptURLQueryString]
GO

/************************************************************************/    
/* Function:  fnc_EncryptURLQueryString                                 */    
/* Creation Date:                                                       */    
/* Copyright: LFL                                                       */    
/* Written by:                                                          */    
/*                                                                      */    
/* Purpose: SOS#247809 Encrypt URL                                      */    
/*                                                                      */    
/* Input Parameters:                                                    */    
/*                                                                      */    
/* Output Parameters:                                                   */    
/*                                                                      */  
/* Usage:  Common Function for Encryption.                              */    
/*                                                                      */    
/* Called By:  Any Stored Procedures.                                   */  
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 5.4                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Ver.  Purposes                                */  
/************************************************************************/    

CREATE FUNCTION [dbo].[fnc_EncryptURLQueryString](@cStrToEncrypt [nvarchar](max), @cEncryptionKey [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [URLQueryStringEncryption].[URLQueryStringEncryption.URLQueryStringEncryption].[Encrypt]
GO
GRANT EXECUTE ON [dbo].[fnc_EncryptURLQueryString] TO public 
GO
