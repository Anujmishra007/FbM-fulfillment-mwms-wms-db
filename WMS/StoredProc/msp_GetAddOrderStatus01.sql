SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/  
/* Stored Procedure: msp_GetAddOrderStatus01                                         */  
/* Creation Date: 2025-07-15                                                        */  
/* Copyright: Maersk Logistics                                                      */  
/* Written by: Wan                                                                  */  
/*                                                                                  */  
/* Purpose: UWP-29954 - [FCR-2532] [JCB] SO Header Status Update                    */
/*          Get Additional Orders, Orderdetail, Pickdetail Status                   */  
/*          Status: '6' -> 'Marshell'                                               */  
/*          Status: '7' -> 'Loaded'                                                 */  
/*          Storerconfig: GetAddOrderStatus, SValue=<msp_GetAddOrderStatusXX>       */ 
/*                                                                                  */  
/* Called By: JAVA Backend: Orders, Orderdetail, Pickdetail Screen                  */ 
/*          : Orders Header: Orderkey data is mandatory                             */
/*          : Orders Detail: Orderkey & OrderLineNumber are mandatory               */
/*          : PickDetail: Orderkey & Pickdetailkey are mandatory                    */
/*          : @c_RequestString: JSON String for Orderkey,OrderlineNo,Pickdetailkey  */
/*          : @c_ReponseString: JSON String for Orderkey Status,OrderlineNo Status  */
/*            & Pickdetailkey Status Return                                         */
/*                                                                                  */  
/* Version: 1.0                                                                     */  
/*                                                                                  */  
/* Data Modifications:                                                              */  
/*                                                                                  */  
/* Updates:                                                                         */  
/* Date        Author      Ver   Purposes                                           */ 
/* 2025-07-31  Wan         1.0                                                      */
/************************************************************************************/  
CREATE OR ALTER PROC [dbo].[msp_GetAddOrderStatus01]  
  @c_RequestString   NVARCHAR(MAX)   
, @c_ResponseString  NVARCHAR(MAX)  = '{}'   OUTPUT   --JSON String: {"totalRecords":10}
, @b_Success         INT            = 1      OUTPUT    
, @n_Err             INT            = 0      OUTPUT    
, @c_ErrMsg          NVARCHAR(250)  = ''     OUTPUT 
, @b_debug           INT            = 0
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_StartTCnt       INT = @@TRANCOUNT
         , @n_Continue        INT = 1
         , @n_TotalRecords    INT = 0
         , @n_PageNo          INT = 0
         , @n_PageSize        INT = 0

         , @c_TableId         NVARCHAR(10)   = ''
         , @c_OrderlineNumber NVARCHAR(5)    = ''
         , @c_Pickdetailkey   NVARCHAR(10)   = ''

         , @c_SQL             NVARCHAR(MAX)  = ''
         , @c_sqlSelect       NVARCHAR(4000) = '' 
         , @c_sqlFrom         NVARCHAR(4000) = '' 
         , @c_sqlWhere        NVARCHAR(4000) = '' 
         , @c_sqlCondition    NVARCHAR(4000) = '' 
         , @c_SQLGroupBy      NVARCHAR(4000) = '' 
         , @c_sqlHaving       NVARCHAR(4000) = '' 
         , @c_sqlOrderBy      NVARCHAR(4000) = '' 

   SET @b_Success = 1    
   SET @n_Err     = 0      
   SET @c_ErrMsg  = ''   

   SET @c_ResponseString = '{}'
   IF ISJSON(@c_RequestString) = ''
   BEGIN
      SET @n_Continue = 3
      GOTO QUIT_SP 
   END

   BEGIN TRY
      IF OBJECT_ID('tempdb..#TMP_ExtSource') IS NOT NULL                                     
      BEGIN
         DROP TABLE #TMP_ExtSource
      END

      CREATE TABLE #TMP_ExtSource 
      ( RowRef             INT            IDENTITY(1,1) PRIMARY KEY
      , Orderkey           NVARCHAR(10)   DEFAULT('')        
      , OrderLineNumber    NVARCHAR(5)    DEFAULT('')
      , Pickdetailkey      NVARCHAR(10)   DEFAULT('') 
      )

      IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL                                     
      BEGIN
         DROP TABLE #TMP_ORD
      END

      CREATE TABLE #TMP_ORD 
      ( RowRef             INT            IDENTITY(1,1) PRIMARY KEY
      , Orderkey           NVARCHAR(10)   DEFAULT('')        
      , OrderLineNumber    NVARCHAR(5)    DEFAULT('')
      , Pickdetailkey      NVARCHAR(10)   DEFAULT('') 
      , Order_Status       NVARCHAR(10)   DEFAULT('') 
      , OrderLine_Status   NVARCHAR(10)   DEFAULT('') 
      , Pickdetail_Status  NVARCHAR(10)   DEFAULT('') 
      )

      IF @n_Continue = 1
      BEGIN
         IF @b_debug = 1
         BEGIN
            PRINT '@c_RequestString: ' + @c_RequestString
         END

         IF @b_debug = 2
         BEGIN
            SELECT pif.[tableId], pif.[pageNo], pif.[pageSize] 
            FROM OPENJSON(@c_RequestString, '$.pageInfo') 
            WITH (  [tableId]    NVARCHAR(50)   '$.tableId'
                  , [pageNo]     INT            '$.pageNo'
                  , [pageSize]   INT            '$.pageSize'
                  ) AS pif
                  
            SELECT TOP 1 
                     sqlSelect   = [sql].[sqlSelect]   
                  ,  sqlFrom     = [sql].[sqlFrom]     
                  ,  sqlWhere    = [sql].[sqlWhere]    
                  ,  SQLGroupBy  = [sql].[SQLGroupBy]    
                  ,  sqlHaving   = [sql].[sqlHaving]   
                  ,  sqlOrderBy  = [sql].[sqlOrderBy]  
            FROM OPENJSON(@c_RequestString, '$.sql') 
            WITH (  [sqlSelect]  NVARCHAR(4000) '$.sqlSelect'
                  , [sqlFrom]    NVARCHAR(4000) '$.sqlFrom'
                  , [sqlWhere]   NVARCHAR(4000) '$.sqlWhere'
                  , [sqlGroupBy] NVARCHAR(4000) '$.sqlGroupBy' 
                  , [sqlHaving]  NVARCHAR(4000) '$.sqlHaving' 
                  , [sqlOrderBy] NVARCHAR(4000) '$.sqlOrderBy' 
                  ) AS [sql]
                  
            SELECT  *
            FROM OPENJSON(@c_RequestString, '$.searchCriteria.conditions')   
            WITH ( clauses   NVARCHAR(MAX) AS JSON
                 , logicalOperation NVARCHAR(10) '$.logicalOperation'
                  ) AS CC
            CROSS APPLY OPENJSON( CC.clauses )
            WITH (  [column]     NVARCHAR(50)  '$.column'
                  , [operation]  NVARCHAR(10)  '$.operation'
                  , [value]      NVARCHAR(MAX) '$.value'
                  , [logicalOperation] NVARCHAR(10)  '$.logicalOperation'
                  ) AS SC
         END

         SELECT TOP 1 
                  @c_tableId     = pif.[tableId]
               ,  @n_pageNo      = pif.[pageNo]
               ,  @n_pageSize    = pif.[pageSize]
         FROM OPENJSON(@c_RequestString, '$.pageInfo') 
         WITH (  [tableId]    NVARCHAR(50)   '$.tableId'
               , [pageNo]     INT            '$.pageNo'
               , [pageSize]   INT            '$.pageSize'
               ) AS pif

         SELECT TOP 1 
                  @c_sqlSelect   = [sql].[sqlSelect]   
               ,  @c_sqlFrom     = [sql].[sqlFrom]     
               ,  @c_sqlWhere    = [sql].[sqlWhere]    
               ,  @c_SQLGroupBy  = [sql].[SQLGroupBy]    
               ,  @c_sqlHaving   = [sql].[sqlHaving]   
               ,  @c_sqlOrderBy  = [sql].[sqlOrderBy]  
         FROM OPENJSON(@c_RequestString, '$.sql') 
         WITH (  [sqlSelect]  NVARCHAR(4000) '$.sqlSelect'
               , [sqlFrom]    NVARCHAR(4000) '$.sqlFrom'
               , [sqlWhere]   NVARCHAR(4000) '$.sqlWhere'
               , [sqlGroupBy] NVARCHAR(4000) '$.sqlGroupBy' 
               , [sqlHaving]  NVARCHAR(4000) '$.sqlHaving' 
               , [sqlOrderBy] NVARCHAR(4000) '$.sqlOrderBy' 
               ) AS [sql]
         
         SELECT @c_SQLCondition = CONVERT(nvarchar(MAX),
                                  STRING_AGG( ISNULL(SC.logicalOperation,'') + ' '
                                + SCC.[column] + ' ' + SCC.[operation] + ' '
                                + CASE WHEN col.DATA_TYPE IN ('char','nchar', 'varchar', 'nvarchar')
                                       THEN '''' + IIF(SCC.[value] IN ('6','7'), '5',SCC.[value]) + ''''
                                       WHEN col.Data_Type IN ('date', 'datetime')
                                       THEN 'CONVERT(datetime,' +   SCC.[value] + ')'
                                       ELSE SCC.[value] 
                                       END + ' '
                                + ISNULL(SCC.logicalOperation,''), '')
                                  )
         FROM OPENJSON(@c_RequestString, '$.searchCriteria.conditions')   
         WITH ( clauses   NVARCHAR(MAX) AS JSON
               , logicalOperation NVARCHAR(10) '$.logicalOperation'
               ) AS SC
         CROSS APPLY OPENJSON( SC.clauses )
         WITH (  [column]     NVARCHAR(50)  '$.column'
               , [operation]  NVARCHAR(10)  '$.operation'
               , [value]      NVARCHAR(MAX) '$.value'
               , [logicalOperation] NVARCHAR(10)  '$.logicalOperation'
               ) AS SCC
         JOIN INFORMATION_SCHEMA.COLUMNS col WITH (NOLOCK)  
                ON  col.TABLE_NAME  = LEFT(SCC.[column], CHARINDEX('.',SCC.[column])-1)
                AND col.COLUMN_NAME = RIGHT(SCC.[column],LEN(SCC.[column])- CHARINDEX('.',SCC.[column]))

         IF @c_TableID IN ( 'sotd', 'picksearchtd')
         BEGIN
            SET @c_SQL = 'SELECT ORDERS.Orderkey, Orderlinenumber ='''', Pickdetailkey=''''' 
         END
         ELSE IF @c_TableID = 'sodetailtd' 
         BEGIN
            SET @c_SQL = 'SELECT ORDERDETAIL.Orderkey, ORDERDETAIL.Orderlinenumber, Pickdetailkey=''''' 
         END
         ELSE IF @c_TableID = 'picktd' 
         BEGIN
            SET @c_SQL = 'SELECT PICKDETAIL.Orderkey, Orderlinenumber ='''', PICKDETAIL.Pickdetailkey' 
         END
 
         IF @c_SQL > ''
         BEGIN
            SET @c_SQL = @c_SQL
                       + ' ' + @c_SQLFrom 
                       + ' ' + @c_SQLWhere  
                       + ' ' + @c_SQLCondition 
                       + ' ' + @c_SQLGroupBy
                       + ' ' + @c_SQLHaving
         END

         INSERT INTO #TMP_ExtSource (Orderkey, OrderLineNumber, Pickdetailkey)
         EXEC sp_ExecuteSQL @c_SQL

         SET @n_TotalRecords = @@ROWCOUNT
   
         INSERT INTO #TMP_ORD  (Orderkey, OrderLineNumber, Pickdetailkey
                               ,Order_Status, OrderLine_Status, Pickdetail_Status)
         SELECT o.Orderkey
               ,OrderLineNumber = ISNULL(od.OrderLineNumber,'')
               ,Pickdetailkey = ISNULL(pd.Pickdetailkey,'')
               ,o.[Status]
               ,OrderLine_Status = ISNULL(od.[Status],'')
               ,Pickdetail_Status = ISNULL(pd.[Status],'')
         FROM #TMP_ExtSource es  
         JOIN ORDERS o (NOLOCK) ON  o.orderkey = es.Orderkey
         LEFT OUTER JOIN ORDERDETAIL od (NOLOCK) ON  od.orderkey = o.Orderkey
         LEFT OUTER JOIN PICKDETAIL  pd (NOLOCK) ON  pd.OrderKey = od.OrderKey
                                                 AND pd.OrderLineNumber = od.OrderLineNumber
         WHERE es.Orderkey > ''  -- Mandatory to have orderkey value

         IF @b_debug = 2
         BEGIN
            select 1,* from #TMP_ORD 
         END

         UPDATE ord
            SET Order_Status     = CASE WHEN ord.Order_Status = '5' AND ISNULL(o.STTCnt,0) = 1 
                                        THEN '7'
                                        WHEN ord.Order_Status = '5' AND ISNULL(o.MLCnt,0) = 1 
                                        THEN '6'
                                        ELSE ord.Order_Status
                                        END
              , OrderLine_Status = CASE WHEN ord.OrderLine_Status = '5' AND ISNULL(od.STTCnt,0) = 1 
                                        THEN '7'
                                        WHEN ord.OrderLine_Status = '5' AND ISNULL(od.MLCnt,0) = 1 
                                        THEN '6'
                                        ELSE ord.OrderLine_Status
                                        END
              , PickDetail_Status= CASE WHEN ord.PickDetail_Status = '5' AND ISNULL(p.STTCnt,0) = 1 
                                        THEN '7'
                                        WHEN ord.PickDetail_Status = '5' AND ISNULL(p.MLCnt,0) = 1 
                                        THEN '6'
                                        ELSE ord.PickDetail_Status
                                        END
         FROM #TMP_ORD ord
         OUTER APPLY ( SELECT  TOP 1 WITH TIES
                               STTCnt = CASE WHEN stt.RowRef IS NULL THEN 0 ELSE 1 END
                              ,MLCnt  = CASE WHEN cl.Code IS NULL THEN 0 ELSE 1 END 
                        FROM PICKDETAIL pd (NOLOCK)
                        LEFT OUTER JOIN rdt.rdtScanToTruck stt (NOLOCK) ON  stt.Orderkey = pd.Orderkey
                                                            AND stt.URNNo    = pd.DropID
                                                            AND stt.[Status] = '9'
                        LEFT OUTER JOIN CODELKUP cl (NOLOCK) ON  cl.ListName = 'JCBCOMPML'
                                                    AND cl.Storerkey = pd.Storerkey
                                                    AND cl.Short = pd.Loc
                        WHERE pd.OrderKey = ord.OrderKey
                        ORDER BY CASE WHEN stt.RowRef IS NULL THEN 0 ELSE 1 END
                              ,  CASE WHEN cl.Code IS NULL THEN 0 ELSE 1 END 
                     ) o 
         OUTER APPLY (  SELECT  TOP 1 WITH TIES
                               STTCnt = CASE WHEN stt.RowRef IS NULL THEN 0 ELSE 1 END
                              ,MLCnt  = CASE WHEN cl.Code IS NULL THEN 0 ELSE 1 END 
                        FROM PICKDETAIL pd (NOLOCK)
                        LEFT OUTER JOIN rdt.rdtScanToTruck stt (NOLOCK) ON  stt.Orderkey = pd.Orderkey
                                                            AND stt.URNNo    = pd.DropID
                                                            AND stt.[Status] = '9'
                        LEFT OUTER JOIN CODELKUP cl (NOLOCK) ON  cl.ListName = 'JCBCOMPML'
                                                    AND cl.Storerkey = pd.Storerkey
                                                    AND cl.Short = pd.Loc
                        WHERE pd.OrderKey = ord.OrderKey
                        AND   pd.OrderLineNumber = ord.OrderLineNumber
                        ORDER BY CASE WHEN stt.RowRef IS NULL THEN 0 ELSE 1 END
                              ,  CASE WHEN cl.Code IS NULL THEN 0 ELSE 1 END 
                     ) od
         OUTER APPLY (  SELECT TOP 1 WITH TIES
                               STTCnt = CASE WHEN stt.RowRef IS NULL THEN 0 ELSE 1 END
                              ,MLCnt  = CASE WHEN cl.Code IS NULL THEN 0 ELSE 1 END 
                        FROM PICKDETAIL pd (NOLOCK)
                        LEFT OUTER JOIN rdt.rdtScanToTruck stt (NOLOCK) ON  stt.Orderkey = pd.Orderkey
                                                                        AND stt.URNNo    = pd.DropID
                                                                        AND stt.[Status] = '9'
                        LEFT OUTER JOIN CODELKUP cl (NOLOCK) ON  cl.ListName = 'JCBCOMPML'
                                                    AND cl.Storerkey = pd.Storerkey
                                                    AND cl.Short = pd.Loc
                        WHERE pd.PickDetailKey = ord.PickdetailKey
                        ORDER BY CASE WHEN stt.RowRef IS NULL THEN 0 ELSE 1 END
                              ,  CASE WHEN cl.Code IS NULL THEN 0 ELSE 1 END 
                     ) p

         IF @b_debug = 1
         BEGIN
            SELECT TOP 1 
                  @c_OrderlineNumber = es.OrderlineNumber
               ,  @c_PickdetailKey   = es.PickdetailKey
            FROM #TMP_ExtSource es  
            ORDER BY es.Orderkey

            PRINT ' @c_OrderlineNumber: ' + @c_OrderlineNumber  
                 +',@c_PickdetailKey : '  + @c_PickdetailKey
         END
         
         SET @c_ResponseString = (  SELECT totalRecords = @n_TotalRecords
                                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                                 )

         IF @b_debug = 1
         BEGIN  
            PRINT  ' @c_Orderlinenumber: ' + @c_Orderlinenumber
                 + ',@c_pickdetailkey: '   + @c_pickdetailkey
                 + ',@c_ResponseString:'   +  @c_ResponseString 
         END



         SET @c_SQLSelect = CASE WHEN @c_TableID IN ( 'sotd', 'picksearchtd')
                                 THEN REPLACE(@c_SQLSelect, 'ORDERS.Status', 'o.Order_Status AS Status') 
                                 WHEN @c_TableID = 'sodetailtd' 
                                 THEN REPLACE(@c_SQLSelect, 'ORDERDETAIL.Status', 'o.OrderLine_Status AS Status') 
                                 WHEN @c_TableID = 'picktd' 
                                 THEN REPLACE(@c_SQLSelect, 'PICKDETAIL.Status', 'o.Pickdetail_Status AS Status') 
                                 END

         SET @c_SQL = @c_SQLSelect
                     + ' ' + @c_SQLFrom 
                     + ' ' + CASE WHEN @c_TableID IN ( 'sotd', 'picksearchtd')
                                 THEN 'JOIN #TMP_ORD o ON o.Orderkey = ORDERS.Orderkey'
                                 WHEN @c_TableID = 'sodetailtd' 
                                 THEN 'JOIN #TMP_ORD o ON o.Orderkey = ORDERS.Orderkey  
                                       AND o.OrderlineNumber = ORDERDETAIL.OrderlineNumber'
                                 WHEN @c_TableID = 'picktd' 
                                 THEN 'JOIN #TMP_ORD o ON o.PickdetailKey = o.PickdetailKey'
                                 END
                     + ' ' + @c_SQLWhere  
                     + ' ' + @c_SQLCondition 
                     + ' ' + @c_SQLGroupBy
                     + ' ' + @c_SQLHaving
                     + ' ' + @c_sqlOrderBy;

         SET @c_SQL = @c_SQL
                    + ' OffSet ((@n_PageNo - 1) * @n_PageSize) ROWS FETCH NEXT @n_PageSize ROWS ONLY'
         EXEC sp_ExecuteSQL @c_SQL
                           ,N'@n_PageNo INT, @n_PageSize INT'
                           , @n_PageNo
                           , @n_PageSize
      END
   END TRY
   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE() + '. msp_GetAddOrderStatus01'
   END CATCH

   QUIT_SP:
   IF (XACT_STATE()) = -1                                                           
   BEGIN
      ROLLBACK TRAN
   END    
   
   IF OBJECT_ID('tempdb..#TMP_ExtSource') IS NOT NULL                                     
   BEGIN
      DROP TABLE #TMP_ExtSource
   END

   IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL                                     
   BEGIN
      DROP TABLE #TMP_ORD
   END

   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_Success = 0  
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
      ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > @n_StartTCnt  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
      EXECUTE nsp_LogError @n_Err, @c_ErrMsg, 'msp_GetAddOrderStatus01'  
   END  
   ELSE  
   BEGIN  
      SET @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
   END  
   RETURN  
END -- procedure  
GO

GRANT EXECUTE ON [dbo].[msp_GetAddOrderStatus01] TO nSQL
GO