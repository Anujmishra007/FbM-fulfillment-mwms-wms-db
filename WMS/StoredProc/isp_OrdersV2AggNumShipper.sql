IF OBJECT_ID('dbo.isp_OrdersV2AggNumShipper','P') IS NOT NULL
   DROP PROC  dbo.isp_OrdersV2AggNumShipper
GO
SET ANSI_NULLS ON       ;   SET QUOTED_IDENTIFIER OFF;
GO
-- 2018-10-08 created ===============================================
-- Author   : KHLim
-- Date       Author   Ver Purpose
-- 20181016   KYan     v2 Add @c_PromoType and EditDate
-- ==================================================================
CREATE  PROC  dbo.isp_OrdersV2AggNumShipper 
   @d_StartDate datetime, @d_EndDate datetime, @c_Storerkey nvarchar(15)
  ,@d_Date  datetime, @c_PromoType nvarchar(30)
  ,@PreSale char(1)
  ,@d_PrevDate datetime --KYan
  ,@TempTable nvarchar(20)
  ,@cDTSITF nvarchar(128) = '', @cARC nvarchar(128) = ''
AS    
BEGIN    
   SET NOCOUNT ON       ;   SET ANSI_DEFAULTS OFF  ;   SET QUOTED_IDENTIFIER OFF;   SET CONCAT_NULL_YIELDS_NULL OFF;
   DECLARE @DB NVARCHAR(128), @Schema NVARCHAR(128), @Proc  NVARCHAR(128)
         , @c_Stmt NVARCHAR(max)
         , @c_Parm NVARCHAR(4000), @dStart datetime, @nDuration int, @SQLId INT, @RowCnt INT = 0
         , @n_err INT
         , @c_errmsg NVARCHAR(255)
         , @Id INT = ISNULL(TRY_CAST(SUBSTRING(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR,@d_Date,126),'-',''),'T',''),':',''),3,10) AS INT),0)
         , @cPK NVARCHAR(4000) =   ' O.StorerKey ,O.AddDate, O.Facility, ISNULL(O.ECOM_SINGLE_Flag,''''), ISNULL(O.ECOM_PRESALE_FLAG,'''')
,O.Status 
,ISNULL(RTRIM(P.SUSR1),'''')
,ISNULL(O.C_State,'''')'
         , @cMainSQL  NVARCHAR(MAX), @cStorerSQL NVARCHAR(4000)
         , @cStdClause NVARCHAR(4000)

   SELECT  @DB=DB_NAME()    , @Schema=OBJECT_SCHEMA_NAME(@@PROCID), @Proc=ISNULL(OBJECT_NAME(@@PROCID),'')

   IF @cDTSITF='' SET @cDTSITF = LEFT(DB_NAME(),2)+'DTSITF'
   IF @cARC   ='' SET @cARC    = LEFT(DB_NAME(),2)+'ARCHIVE'

   IF ISNULL(OBJECT_ID('tempdb..#OrdersV2AggNum'), '') <> ''
   BEGIN
      DROP TABLE #OrdersV2AggNumShipper
   END

   Create TABLE  #OrdersV2AggNumShipper
   (  StorerKey      nvarchar(15),
      AddDate        date,
      Facility       nvarchar(10),
      ECOM_SINGLE_Flag  nvarchar(5),
      ECOM_PRESALE_FLAG nvarchar(5) NULL,
      [Status]       nvarchar(10) NOT NULL,
      [SUSR1]        nvarchar(20) NOT NULL,
      [C_State]      nvarchar(45) NOT NULL,
      num_Orders     BIGINT default 0,
      num_Lines      BIGINT default 0,
      num_Units      BIGINT default 0,
      TempTable      nvarchar(20) NOT NULL
   )

   SET @cStorerSQL = '
JOIN '+@cDTSITF+'.dbo.eCom_Stats_Config C WITH (NOLOCK) ON C.StorerKey = O.StorerKey AND C.Facility = O.Facility '
   IF @TempTable = 'NewShipB'
   BEGIN
      SET @cMainSQL = '
,COUNT(DISTINCT O.Orderkey)
,COUNT(1)
,0
,'''+@TempTable+'''
FROM dbo.Orders O WITH (NOLOCK) '+@cStorerSQL+'
JOIN dbo.MBOLDETAIL MB (NOLOCK) ON O.OrderKey = MB.OrderKey
JOIN dbo.MBOL M (NOLOCK) ON M.MBOLKey = MB.MBOLKey
LEFT JOIN STORER p WITH (NOLOCK) ON O.ShipperKey = p.StorerKey
WHERE '+ CASE WHEN @c_PromoType='Daily' THEN 'O.EditDate ' ELSE 'O.AddDate' END+ 
               ' >= '''+CONVERT(NVARCHAR(23),@d_StartDate,121)+'''
 AND  M.ShipDate >= '''+CONVERT(NVARCHAR(23),@d_PrevDate ,121)+'''
 AND  M.ShipDate <= '''+CONVERT(NVARCHAR(23),@d_Date     ,121)+'''
 AND O.Status = ''9'''
   END

   SET @c_Stmt = 
'SELECT '  +@cPK+'
'+@cMainSQL+'
'+CASE WHEN @c_Storerkey='' THEN '' ELSE ' AND O.StorerKey = '''+@c_Storerkey+''' ' END+'
 AND O.AddDate <= '''+CONVERT(NVARCHAR(23),@d_EndDate,121)+'''
 AND O.AddDate >= C.'+CASE WHEN @PreSale='1' 
THEN 'PresaleStart' ELSE 'PromoStart'     END+'
 AND O.AddDAte <  C.'+CASE WHEN @PreSale='1' 
THEN 'PromoStart'   ELSE 'CompletionDate' END+'
 AND O.DocType= ''E''
'+CASE WHEN @PreSale IN ('1','2') THEN ' AND ISNULL(ECOM_PRESALE_FLAG,'''')<>'''' ' ELSE '' END+'
 GROUP BY '+@cPK

   BEGIN TRY
      SET @dStart = GETDATE()
      INSERT #OrdersV2AggNumShipper
      EXEC sp_ExecuteSql @c_Stmt
      SET @RowCnt = @@ROWCOUNT
   END TRY
   BEGIN CATCH
      EXEC ispLogError  @DB, @Schema, @Proc, @Id, @c_ErrMsg OUTPUT, @n_Err OUTPUT, '',0,0,@TempTable
   END CATCH
   SET @nDuration = DATEDIFF(s,@dStart,GETDATE())
   EXEC dbo.ispLogQuery @DB, @Schema, @Proc, @Id, @c_Stmt, @nDuration, @RowCnt, @TempTable, @SQLId OUTPUT

   BEGIN TRY
      UPDATE OrdersV2Agg SET num_Orders = ISNULL(NS.num_Orders, 0)
      FROM OrdersV2Agg C
      JOIN #OrdersV2AggNumShipper NS 
         ON C.StorerKey = NS.StorerKey AND C.Facility = NS.Facility AND C.AddDate = NS.AddDate AND NS.Status = C.Status AND NS.SUSR1 = C.SUSR1 AND ISNULL(REPLACE( NS.C_State, N'ʡ', ''), '')  = C.C_State
   END TRY
   BEGIN CATCH
      EXEC ispLogError @DB, @Schema, @Proc, @@SPID, @c_ErrMsg OUTPUT, @n_Err OUTPUT, '',0,0,@TempTable
   END CATCH


END
