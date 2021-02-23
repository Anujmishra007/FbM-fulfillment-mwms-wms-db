if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_DysonGenTransZO]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_DysonGenTransZO]
GO
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/    
/* Stored Procedure: isp_DysonGenTransZO                                */    
/* Creation Date: 28-May-2020                                           */    
/* Copyright: LF Logistics                                              */    
/* Written by: TLTING                                                   */    
/*                                                                      */    
/* Purpose:                                                             */    
/*                                                                      */    
/* Called By:                                                           */    
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 1.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author  Rev   Purposes                                  */    
/* 28-May-2020  TLTING  1.0   Initital                                  */   
/************************************************************************/  

CREATE PROC [dbo].[isp_DysonGenTransZO] (
   @c_storerkey NVARCHAR(18) = 'DYSON'
)
AS 
BEGIN

SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  

DECLARE  @c_orderkey  NVARCHAR(10) = '', 
      @c_tablename NVARCHAR(30)


--SET  @c_storerkey = 'DYSON'
SET @c_tablename = 'WSCRSOADDZO'

 
IF EXISTS (  SELECT 1 
             FROM orders a (NOLOCK) 
             WHERE a.storerkey = @c_storerkey 
             AND a.doctype = 'E' 
             AND a.status NOT IN ('9', 'CANC')
             AND a.userdefine04 = '' 
             AND a.shipperkey = 'ZTO'
             AND NOT EXISTS ( SELECT 1 FROM Transmitlog2 c(NOLOCK) 
                     WHERE c.key3 = a.storerkey  
                     AND c.key1 = a.orderkey 
                     AND c.tablename = @c_tablename   )         
                     )
BEGIN
   DECLARE OrdItems_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
    SELECT orderkey 
    FROM Orders a (NOLOCK) 
    WHERE a.storerkey = @c_storerkey 
    AND a.doctype = 'E' 
    AND a.status NOT IN ('9', 'CANC')
    AND a.userdefine04 = '' 
    AND a.shipperkey = 'ZTO'
    AND NOT EXISTS ( SELECT 1 FROM Transmitlog2 c(NOLOCK) 
            WHERE c.key3 = a.storerkey  
            AND c.key1 = a.orderkey 
            AND c.tablename = @c_tablename   )

    OPEN OrdItems_cur

    FETCH NEXT FROM OrdItems_cur INTO @c_orderkey 
    WHILE @@FETCH_STATUS=0
    BEGIN       

	      EXEC ispGenTransmitLog2 @c_tablename, @c_orderkey, '0', @c_storerkey, '', 0, 0,'' 
                                  
      FETCH NEXT FROM OrdItems_cur INTO @c_orderkey 
    END
 
   CLOSE OrdItems_cur 
   DEALLOCATE OrdItems_cur
END 

 
END
GO

 

GRANT EXECUTE ON isp_DysonGenTransZO to nSQL
GO

