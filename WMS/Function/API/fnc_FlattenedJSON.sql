IF EXISTS( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[API].[fnc_FlattenedJSON]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))  
   DROP FUNCTION [API].[fnc_FlattenedJSON]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Function:  fnc_FlattenedJSON                                         */    
/* Creation Date: 15-Dec-2016                                           */    
/* Copyright: LFL                                                       */    
/* Written by: Shong                                                    */    
/*                                                                      */    
/* Purpose:  Convert XML to JSON                                        */    
/*                                                                      */    
/* Input Parameters:  @cXMLString                                       */    
/*                                                                      */    
/* Output Parameters: String - JSON                                     */    
/*                                                                      */    
/*                                                                      */    
/* Called By:  Any Stored Procedures.                                   */  
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 7.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Ver.  Purposes                                */  
/************************************************************************/    
CREATE FUNCTION [API].[fnc_FlattenedJSON] (@XMLResult XML)  
RETURNS NVARCHAR(MAX)  
WITH EXECUTE AS CALLER  
AS  
BEGIN  
   DECLARE  @JSONVersion NVARCHAR(MAX)   
     
   SELECT @JSONVersion = (  
      SELECT Stuff(    
         (  
         SELECT * from    
            (SELECT  ',{'+    
                     Stuff((SELECT ',"' + coalesce(b.c.value('local-name(.)', 'NVARCHAR(MAX)'),'') + '":' + '"' + b.c.value('text()[1]','NVARCHAR(MAX)') + '"'  
                     from x.a.nodes('*') b(c)    
                     for xml path(''),TYPE).value('(./text())[1]','NVARCHAR(MAX)')  
               ,1,1,'')+'}'   
         from @XMLResult.nodes('/root/*') x(a)    
         ) JSON(theLine)    
         for xml path(''),TYPE).value('.','NVARCHAR(MAX)' )  
      ,1,1,'')  
   )  
  
   IF CHARINDEX('},{', @JSONVersion) <> 0  
   BEGIN  
      SET @JSONVersion = '[' + @JSONVersion + ']'  
   END  
  
   SET @JSONVersion =  '{"Data": ' + @JSONVersion + '}'  
   RETURN @JSONVersion  
END 
GO
GRANT EXECUTE ON [API].[fnc_FlattenedJSON] TO nSQL 
GO 