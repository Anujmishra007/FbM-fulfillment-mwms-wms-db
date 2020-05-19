IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Cursor_PreAllocate_Candidates]')
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 )
DROP PROCEDURE [dbo].[isp_Cursor_PreAllocate_Candidates]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Stored Procedure: isp_Cursor_PreAllocate_Candidates                  */    
/* Creation Date: 2020-04-08                                            */    
/* Copyright: LF                                                        */    
/* Written by:                                                          */    
/*                                                                      */    
/* Purpose: Dynamic SQL review, impact SQL cache log                    */
/*                                                                      */    
/* Called By: Insert #temp Table PickCode                               */    
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 1.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date        Author   Ver.  Purposes                                  */    
/************************************************************************/ 
CREATE PROC [dbo].[isp_Cursor_PreAllocate_Candidates] 
AS  
BEGIN 
   SET NOCOUNT ON 

   DECLARE PREALLOCATE_CURSOR_CANDIDATES  CURSOR FAST_FORWARD READ_ONLY     
   FOR    
      SELECT StorerKey    
            ,Sku    
            ,Lot    
            ,QtyAvailable
      FROM  #PREALLOCATE_CANDIDATES   
      ORDER BY RowID
END
GO
GRANT EXECUTE ON [dbo].[isp_Cursor_PreAllocate_Candidates] TO nSQL
GO