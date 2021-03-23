IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnc_GetCharASCII]')  AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')) 
   DROP FUNCTION [dbo].[fnc_GetCharASCII]
GO

/************************************************************************/    
/* Function:  fnc_GetCharASCII                                          */    
/* Creation Date: 15-July-2012                                          */    
/* Copyright: IDS                                                       */    
/* Written by: TING TUCK LUNG                                           */    
/*                                                                      */    
/* Purpose:  Convert Char ASCII function.                               */    
/*                                                                      */    
/* Input Parameters:  @cString     - Numeric Field                      */    
/*                                                                      */    
/* Output Parameters: Char ASCII                                        */    
/*                    Tab               char(9)                         */  
/*                    Line feed         char(10)                        */  
/*                    Carriage return   char(13)                        */  
/*                    Space             char(13)                        */    
/*                                                                      */  
/* Usage:  Common Function for CHAR ASCII.                              */    
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
/* DD-MMM-YYYY                                                          */  
/************************************************************************/    
  
CREATE FUNCTION [dbo].[fnc_GetCharASCII] (@Code INT)  
RETURNS Char(1)  
AS  
BEGIN   
   RETURN  char(@Code)  
END  
GO
GRANT EXECUTE ON [dbo].[fnc_GetCharASCII] TO public 
GO
