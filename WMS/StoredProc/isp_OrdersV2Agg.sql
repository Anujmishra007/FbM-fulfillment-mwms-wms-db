IF OBJECT_ID('dbo.isp_OrdersV2Agg','P') IS NOT NULL
   DROP PROC  dbo.isp_OrdersV2Agg
GO
SET ANSI_NULLS ON       ;   SET QUOTED_IDENTIFIER OFF;
GO
-- 2018-10-08 created ===============================================
-- Author   : KHLim
-- Date       Author   Ver Purpose
-- 20181016   KYan     v2  Add PromoType and EditDate
-- ==================================================================
CREATE  PROC  dbo.isp_OrdersV2Agg 
   @d_StartDate datetime, @d_EndDate datetime, @c_Storerkey nvarchar(15)
  ,@d_Date  datetime, @c_PromoType nvarchar(30) --KYan
  ,@PreSale char(1)
  ,@cArchiveDB nvarchar(128), @c_IncludeArchive BIT
  ,@cOutstanding CHAR(1) = '0'
  ,@nDaysAgo smallint    = 14
  ,@cDTSITF nvarchar(128) = ''
AS    
BEGIN    
   SET NOCOUNT ON       ;   SET ANSI_DEFAULTS OFF  ;   SET QUOTED_IDENTIFIER OFF;   SET CONCAT_NULL_YIELDS_NULL OFF;
   DECLARE @DB NVARCHAR(128), @Schema NVARCHAR(128), @Proc  NVARCHAR(128)
         , @c_Stmt  NVARCHAR(max), @c_StmtMid  NVARCHAR(max)
         , @c_Parm NVARCHAR(4000), @dStart datetime, @nDuration int, @SQLId INT, @RowCnt INT = 0
         , @n_err INT
         , @c_errmsg NVARCHAR(255)
         , @Id INT = ISNULL(TRY_CAST(SUBSTRING(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR,@d_Date,126),'-',''),'T',''),':',''),3,10) AS INT),0)

   SELECT  @DB=DB_NAME()    , @Schema=OBJECT_SCHEMA_NAME(@@PROCID), @Proc=ISNULL(OBJECT_NAME(@@PROCID),'')

   IF @cDTSITF   ='' SET @cDTSITF   = LEFT(DB_NAME(),2)+'DTSITF'
   IF @cArchiveDB='' SET @cArchiveDB= LEFT(DB_NAME(),2)+'ARCHIVE'

      SET @c_StmtMid = '
   LEFT JOIN STORER S WITH (NOLOCK) ON O.ShipperKey = S.StorerKey'+
CASE
WHEN @cOutstanding = '1' THEN
' WHERE O.AddDate >= dateadd(day,-'+CAST(@nDaysAgo AS varchar(5))+',getdate())
   AND O.Status IN (''0'',''1'',''2'',''3'',''5'')
   AND O.AddDate  <  '''+CONVERT(NVARCHAR(23),@d_EndDate  ,121)+'''
   '+CASE WHEN @c_Storerkey='' THEN '' ELSE ' AND O.StorerKey = '''+@c_Storerkey+''' ' END   
WHEN @c_PromoType='Daily' THEN
' WHERE O.AddDate >= dateadd(day,-'+CAST(@nDaysAgo AS varchar(5))+',getdate())
   AND O.EditDate >= '''+CONVERT(NVARCHAR(23),@d_StartDate,121)+'''
   AND ((O.Status = ''9'' AND O.MBOLKey <> '''')
    OR  O.Status = ''CANC'')
   AND O.AddDate  <  '''+CONVERT(NVARCHAR(23),@d_EndDate  ,121)+'''
   '+CASE WHEN @c_Storerkey='' THEN '' ELSE ' AND O.StorerKey = '''+@c_Storerkey+''' ' END   
--+' AND NOT EXISTS (SELECT 1 FROM '+@cDTSITF+'.dbo.eCom_Stats_Config C WITH (NOLOCK) WHERE C.StorerKey = O.StorerKey) '
ELSE
' JOIN '+@cDTSITF+'.dbo.eCom_Stats_Config C WITH (NOLOCK) ON C.StorerKey = O.StorerKey AND C.Facility = O.Facility
 WHERE O.AddDate >= dateadd(day,-'+CAST(@nDaysAgo AS varchar(5))+',getdate())
   AND O.AddDate >= C.'+CASE WHEN @PreSale='1' 
   THEN 'PresaleStart' ELSE 'PromoStart'     END+'
     AND O.AddDAte <  C.'+CASE WHEN @PreSale='1' 
   THEN 'PromoStart'   ELSE 'CompletionDate' END+'
   '+CASE WHEN @c_Storerkey='' THEN '' ELSE ' AND O.StorerKey = '''+@c_Storerkey+''' ' END+'
   '+CASE WHEN @PreSale='1' THEN ' AND ISNULL(O.ECOM_PRESALE_FLAG,'''')<>'''' ' ELSE '' END+'
   AND O.DocType= ''E'' ' END;

--         O.AddDate >= '''+CONVERT(NVARCHAR(23),@d_StartDate,121)+'''
--     AND O.AddDate <  '''+CONVERT(NVARCHAR(23),@d_EndDate  ,121)+'''
--     AND 


   SET @c_Stmt = 'SELECT O.OrderKey, O.StorerKey, O.Type, O.MBOLKey
,O.AddDate
,O.EditDate
,O.Facility
,ECOM_SINGLE_Flag  = ISNULL(O.ECOM_SINGLE_Flag ,'''')
,ECOM_PRESALE_FLAG = ISNULL(O.ECOM_PRESALE_FLAG,'''')
,TTL_Lines     = COUNT(1)
,TTL_OpenQty   = SUM(O.OpenQty)
,TTL_QtyAPS    = SUM(O.QtyAllocated + O.QtyPicked + O.ShippedQty)
,TTL_EnteredQTY= SUM(O.EnteredQTY)
,O.Status 
,SUSR1 = ISNULL(RTRIM(O.SUSR1),'''')
,C_State=ISNULL(O.C_State,'''') 
,@d_Date, @PreSale, @cOutstanding
FROM
(SELECT O.OrderKey, O.StorerKey, O.Type, O.MBOLKey, O.AddDate, O.EditDate, O.Facility, O.ECOM_SINGLE_Flag, O.ECOM_PRESALE_FLAG
, OD.OpenQty, OD.QtyAllocated, OD.QtyPicked, OD.ShippedQty, OD.EnteredQTY, O.Status, S.SUSR1, O.C_State
   FROM dbo.Orders O WITH (NOLOCK)
   JOIN dbo.OrderDetail OD WITH (NOLOCK) ON O.OrderKey = OD.OrderKey
   '+@c_StmtMid+' '+CASE WHEN @c_IncludeArchive=1 THEN '
UNION ALL
 SELECT O.OrderKey, O.StorerKey, O.Type, O.MBOLKey, O.AddDate, O.EditDate, O.Facility, O.ECOM_SINGLE_Flag, O.ECOM_PRESALE_FLAG
, OD.OpenQty, OD.QtyAllocated, OD.QtyPicked, OD.ShippedQty, OD.EnteredQTY, O.Status, S.SUSR1, O.C_State
   FROM '+@cArchiveDB+'.dbo.Orders O WITH (NOLOCK)
   JOIN '+@cArchiveDB+'.dbo.OrderDetail OD WITH (NOLOCK) ON O.OrderKey = OD.OrderKey
   '+@c_StmtMid+' ' ELSE '' END+') AS O
GROUP BY O.OrderKey, o.StorerKey, O.Type, O.MBOLKey, O.Facility, ISNULL(O.ECOM_SINGLE_Flag ,''''), ISNULL(O.ECOM_PRESALE_FLAG,'''')
   ,O.AddDate, O.EditDate
,O.Status ,ISNULL(RTRIM(O.SUSR1),'''') ,ISNULL(O.C_State,'''')
'  --+CASE WHEN @c_Storerkey='' AND @PreSale='1' THEN 'HAVING MAX(PresaleStart) IS NULL' ELSE '' END;

   --SET @c_Parm = N'@d_StartDate datetime, @d_EndDate datetime, @c_Storerkey nvarchar(15) '

	SET @c_Parm = N'@d_Date datetime, @PreSale CHAR(1), @cOutstanding CHAR(1)'
   BEGIN TRY
      SET @dStart = GETDATE()
      INSERT OrdersV2Raw ([OrderKey]
      ,[StorerKey]
      ,[Type]
      ,[MBOLKey]
      ,[AddDate]
      ,[EditDate]
      ,[Facility]
      ,[ECOM_SINGLE_Flag]
      ,[ECOM_PRESALE_FLAG]
      ,[TTL_Lines]
      ,[TTL_OpenQty]
      ,[TTL_QtyAPS]
      ,[TTL_EnteredQTY]
      ,[Status]
      ,[SUSR1]
      ,[C_State]
      ,[DATETIME], Presale, Outstanding)
      EXEC sp_ExecuteSql @c_Stmt, @c_Parm, @d_Date, @PreSale, @cOutstanding
      SET @RowCnt = @@ROWCOUNT
   END TRY
   BEGIN CATCH
      PRINT @c_Stmt
      EXEC ispLogError  @DB, @Schema, @Proc, @Id, @c_ErrMsg OUTPUT, @n_Err OUTPUT, '',0,0,'OrdersV2Raw'
   END CATCH
   SET @nDuration = DATEDIFF(s,@dStart,GETDATE())
   EXEC dbo.ispLogQuery @DB, @Schema, @Proc, @Id, @c_Stmt, @nDuration, @RowCnt, 'OrdersV2Raw', @SQLId OUTPUT

   SET @c_Stmt = 'INSERT INTO dbo.OrdersV2Status 
(OrderKey, [Status], [DATETIME], StatusDate, ShipDate, PEditDate, PAddDate)
SELECT
 R.OrderKey, R.[Status], @d_Date  , CASE
 WHEN R.Status BETWEEN ''1'' AND  ''3'' THEN CASE WHEN MIN(P.AddDate ) IS NOT NULL THEN MIN(P.AddDate ) ELSE R.EditDate END
 WHEN R.Status BETWEEN ''4'' AND  ''5'' THEN CASE WHEN MIN(P.EditDate) IS NOT NULL THEN MIN(P.EditDate) ELSE R.EditDate END
 WHEN R.Status = ''9'' '+             ' THEN CASE WHEN MIN(M.ShipDate) IS NOT NULL THEN MIN(M.ShipDate) ELSE R.EditDate END
 WHEN R.Status=''CANC'' THEN R.EditDate END, MIN(M.ShipDate), MIN(P.EditDate), MIN(P.AddDate)
FROM OrdersV2Raw R
LEFT JOIN dbo.PICKDETAIL P WITH (NOLOCK) ON P.OrderKey = R.OrderKey
LEFT JOIN dbo.MBOL M (NOLOCK) ON M.MBOLKey = R.MBOLKey
WHERE PreSale=@PreSale AND Outstanding=@cOutstanding AND R.Status>''0''
AND NOT EXISTS (SELECT 1 FROM dbo.OrdersV2Status WHERE OrderKey=R.OrderKey AND Status=R.Status)
GROUP BY R.OrderKey, R.[Status], R.EditDate'
	SET @c_Parm = N'@d_Date datetime, @PreSale CHAR(1), @cOutstanding CHAR(1)'
   BEGIN TRY
      SET @dStart = GETDATE()
      EXEC sp_ExecuteSql @c_Stmt, @c_Parm, @d_Date, @PreSale, @cOutstanding
      SET @RowCnt = @@ROWCOUNT
   END TRY
   BEGIN CATCH
      PRINT @c_Stmt
      EXEC dbo.ispLogError @DB, @Schema, @Proc, @@SPID, @c_ErrMsg OUTPUT, @n_Err OUTPUT, '',0,0,'OrdersV2Status'
   END CATCH
   SET @nDuration = DATEDIFF(s,@dStart,GETDATE())
   EXEC dbo.ispLogQuery @DB, @Schema, @Proc, @Id, @c_Stmt, @nDuration, @RowCnt, 'OrdersV2Status', @SQLId OUTPUT

   IF @c_PromoType='Daily' AND @cOutstanding = '0'
   BEGIN
      DELETE R FROM OrdersV2Raw R
      WHERE EXISTS (SELECT 1 FROM OrdersV2Status S 
      WHERE S.Status = '9' AND S.StatusDate < GETDATE() - 1 AND S.OrderKey=R.OrderKey AND S.Status=R.Status )

      DELETE S FROM OrdersV2Status S
      WHERE S.Status = '9' AND S.StatusDate < GETDATE() - 1
   END

   SET @c_Stmt = 'INSERT INTO dbo.OrdersV2Agg 
(StorerKey, AddDate, Facility, ECOM_SINGLE_Flag, ECOM_PRESALE_FLAG, TTL_Orders, TTL_Lines, TTL_OpenQty, TTL_QtyAPS, TTL_EnteredQTY, [Status], SUSR1, C_State, SQLId)
SELECT
 StorerKey, convert(nvarchar(10),AddDate,121), Facility, ECOM_SINGLE_Flag, ECOM_PRESALE_FLAG, COUNT(DISTINCT OrderKey), SUM(TTL_Lines), SUM(TTL_OpenQty), SUM(TTL_QtyAPS), SUM(TTL_EnteredQTY)
                                                                  , [Status], SUSR1, C_State, @Id 
FROM OrdersV2Raw WITH (NOLOCK) WHERE PreSale=@PreSale AND Outstanding=@cOutstanding GROUP BY
 StorerKey, convert(nvarchar(10),AddDate,121), Facility, ECOM_SINGLE_Flag, ECOM_PRESALE_FLAG, [Status], SUSR1, C_State 
ORDER BY convert(nvarchar(10),AddDate,121), StorerKey, Facility'
	SET @c_Parm = N'@Id INT, @PreSale CHAR(1), @cOutstanding CHAR(1)'
   BEGIN TRY
      SET @dStart = GETDATE()
      EXEC sp_ExecuteSql @c_Stmt, @c_Parm, @Id, @PreSale, @cOutstanding
      SET @RowCnt = @@ROWCOUNT
   END TRY
   BEGIN CATCH
      PRINT @c_Stmt
      EXEC dbo.ispLogError @DB, @Schema, @Proc, @@SPID, @c_ErrMsg OUTPUT, @n_Err OUTPUT, '',0,0,'OrdersV2Agg'
   END CATCH
   SET @nDuration = DATEDIFF(s,@dStart,GETDATE())
   EXEC dbo.ispLogQuery @DB, @Schema, @Proc, @Id, @c_Stmt, @nDuration, @RowCnt, 'OrdersV2Agg', @SQLId OUTPUT

END
