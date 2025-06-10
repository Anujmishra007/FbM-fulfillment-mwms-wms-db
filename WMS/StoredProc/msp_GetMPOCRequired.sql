SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/  
/* Procedure: msp_GetMPOCRequired                                       */  
/* Creation Date: 28-May-2024                                           */  
/* Copyright: Maersk Logistics                                          */  
/* Written by: Shong                                                    */  
/*                                                                      */  
/* Purpose: UWP-18747 - Levis US MPOC and Cartonization                 */  
/*        :                                                             */  
/* PVCS Version: 1.2                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */  
/* 28-May-2024 Shong    1.1   Create                                    */  
/* 25-Oct-2024 WLChooi  1.2   Fix Listname & remove conditions (WL01)   */  
/* 06-May-2025 SWT01    1.3   Add Condition Group UWP-34063             */    
/* 29-May-2025 SWT02    1.4   Include sub-group for MPOC Flag           */  
/************************************************************************/  
CREATE OR ALTER PROC [dbo].[msp_GetMPOCRequired]  
(  
    @c_OrderKey NVARCHAR(10),  
    @n_MPOCFlag   INT = 0 OUTPUT,  
    @b_Success INT = 1 OUTPUT,  
    @n_Err INT = 0 OUTPUT,  
    @c_ErrMsg NVARCHAR(255) = '' OUTPUT,  
    @b_debug INT = 0  
)  
AS  
BEGIN  
 DECLARE @n_RowCount   INT = 0,   
           @c_SQL        NVARCHAR(4000) = N'',  
           @c_SQLWhere   NVARCHAR(4000) = N'',  
           @c_SQLCond    NVARCHAR(4000) = N'',  
           @c_StorerKey  NVARCHAR(15) = N'',  
           @c_KeyValue   NVARCHAR(30) = N'',   
           @c_Operator   NVARCHAR(10) = N'',   
           @b_CheckFlag  BIT = 0,  
           @n_Counts     INT = 0,  
           @c_ColumnName NVARCHAR(60) = N'',  
           @n_AndFlagCtn INT = 0,   
           @c_AndOrCond  NVARCHAR(10) = '',  
           @c_CondGroup  NVARCHAR(250) = '';  
  
   SELECT @c_StorerKey = StorerKey  
   FROM ORDERS WITH (NOLOCK)  
   WHERE OrderKey = @c_OrderKey;  
  
       
   IF EXISTS(SELECT 1 FROM ORDERS AS O WITH (NOLOCK)  
               JOIN dbo.ORDERDETAIL AS OD WITH (NOLOCK) ON O.OrderKey = OD.OrderKey  
               JOIN dbo.SKU AS S WITH (NOLOCK) ON S.StorerKey = OD.StorerKey AND S.SKU = OD.Sku  
               WHERE O.OrderKey = @c_OrderKey  
               AND (S.PrepackIndicator IS NOT NULL AND S.PrepackIndicator <> '')   --WL01  
               )  
   BEGIN   
      SET @n_MPOCFlag = 0;   
   END;  
   ELSE  
   BEGIN  
      SET @n_MPOCFlag = 0;  
  
      SELECT @n_MPOCFlag =   
               CASE   
                  WHEN C.Short = '0' THEN 0 -- NO MPOC NEEDED  
                  WHEN C.Short = '1' THEN 1 -- JCP MPOC Formula needed  
                  WHEN C.Short = '2' THEN 2 -- MACY MPOC Formula needed  
                  WHEN C.Short = '3' THEN 3 -- WALMART MPOC Formula needed  
                  ELSE 1   
               END  
         FROM dbo.ORDERS AS O WITH (NOLOCK)  
         JOIN dbo.CODELKUP AS C WITH (NOLOCK) ON LISTNAME = 'MPOCPERMIT'   --WL01  
                           AND ( C.Code = O.BillToKey OR C.Code = O.ConsigneeKey )  
                           AND C.Storerkey = O.StorerKey  
         WHERE O.OrderKey = @c_OrderKey;  
   END;   
  
   IF @n_MPOCFlag <> 0   
   BEGIN  
      SET @c_SQLWhere = ''    
  
      IF EXISTS(SELECT 1 FROM dbo.CODELKUP C WITH (NOLOCK)  
       WHERE LISTNAME = 'MPOCEXCEMP'     
       AND Storerkey = @c_StorerKey  
         AND Code2 = CAST(@n_MPOCFlag AS NVARCHAR(5)))  
      BEGIN  
        
       DECLARE CUR_ConditionGroup CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT CASE WHEN ISNULL(C.Long, '') = '' THEN '0' ELSE C.Long END,   
                SUM(CASE WHEN Notes = 'AND' THEN 1 ELSE 0 END) AS AndFlagCtn  
         FROM dbo.CODELKUP C WITH (NOLOCK)  
         WHERE LISTNAME = 'MPOCEXCEMP'     
         AND Storerkey = @c_StorerKey   
         AND Code2 = CAST(@n_MPOCFlag AS NVARCHAR(5))  
         GROUP BY CASE WHEN ISNULL(C.Long, '') = '' THEN '0' ELSE C.Long END  
         Order By 1  
        
         OPEN CUR_ConditionGroup  
         FETCH NEXT FROM CUR_ConditionGroup INTO @c_CondGroup, @n_AndFlagCtn  
        
         WHILE @@FETCH_STATUS = 0  
         BEGIN  
            SET @c_SQLCond = ''  
  
            DECLARE CUR_MPOCEXCEMP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT C.UDF02, C.Short, Code AS KeyValue, Notes  
            FROM dbo.CODELKUP C WITH (NOLOCK)  
            WHERE LISTNAME = 'MPOCEXCEMP'     
            AND Storerkey = @c_StorerKey   
            AND Long = @c_CondGroup   
            AND Code2 = CAST(@n_MPOCFlag AS NVARCHAR(5))  
            ORDER BY C.UDF02, CASE WHEN Notes='OR' THEN 1 ELSE 9 END  
           
  
            OPEN CUR_MPOCEXCEMP;  
            FETCH NEXT FROM CUR_MPOCEXCEMP INTO @c_ColumnName, @c_Operator, @c_KeyValue, @c_AndOrCond  
            WHILE @@FETCH_STATUS <> -1  
            BEGIN   
               IF @c_SQLCond = ''    
               BEGIN  
                  SET @c_SQLCond = @c_SQLCond + ' ' +  @c_ColumnName + ' ' + @c_Operator + '''' + @c_KeyValue + ''''  
               END  
               ELSE  
               BEGIN  
                  SET @c_SQLCond = @c_SQLCond + ' ' + @c_AndOrCond + ' ' + @c_ColumnName + ' ' + @c_Operator + '''' + @c_KeyValue + ''''  
               END  
  
               --IF @b_debug = 1  
               --   PRINT 'COND >>' + @c_SQLCond  
  
               FETCH NEXT FROM CUR_MPOCEXCEMP INTO @c_ColumnName, @c_Operator, @c_KeyValue, @c_AndOrCond  
            END;  
            CLOSE CUR_MPOCEXCEMP;  
            DEALLOCATE CUR_MPOCEXCEMP;   
  
            IF @c_SQLWhere = ''  
            BEGIN  
               SET @c_SQLWhere = 'AND ( (' + @c_SQLCond + ') '  
            END   
            ELSE   
            BEGIN  
               SET @c_SQLWhere = @c_SQLWhere + ' OR (' + @c_SQLCond + ')'  
            END  
  
            FETCH NEXT FROM CUR_ConditionGroup INTO @c_CondGroup, @n_AndFlagCtn  
         END  
        
         CLOSE CUR_ConditionGroup  
         DEALLOCATE CUR_ConditionGroup  
        
         SET @c_SQLWhere = @c_SQLWhere + ')'  
  
         SET @c_SQL = N'SELECT @n_Count = COUNT(1)   
         FROM dbo.ORDERS WITH (NOLOCK)  
         WHERE OrderKey = @c_OrderKey ' + @c_SQLWhere;  
  
         IF @b_Debug=1  
           PRINT @c_SQL  
  
         BEGIN TRY  
            EXEC sp_executesql @c_SQL, N'@c_OrderKey NVARCHAR(10), @n_Count INT OUTPUT', @c_OrderKey, @n_RowCount OUTPUT;   
            
         END TRY  
         BEGIN CATCH  
            SET @b_Success = 0  
            SET @n_Err = 82051  
            SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': ' + 'Error Executing SQL: '  +  @c_SQL + '.(msp_GetMPOCRequired)'  
         END CATCH  
  
         IF @n_RowCount > 0  
         BEGIN  
            SET @n_MPOCFlag = 0;  
            SET @b_CheckFlag =1  
         END;          
      END  
   END    

  
  
   Quit_SP:   
  
   --IF @b_debug=1  
   --   PRINT '@n_MPOCFlag= '+  CAST(@n_MPOCFlag AS VARCHAR(10))  
END;  
GO
