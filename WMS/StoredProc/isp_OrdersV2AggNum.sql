IF OBJECT_ID('dbo.isp_OrdersV2AggNum','P') IS NOT NULL
   DROP PROC  dbo.isp_OrdersV2AggNum
GO
SET ANSI_NULLS ON       ;   SET QUOTED_IDENTIFIER OFF;
GO
-- 2018-10-10 created ===============================================
-- Author   : KHLim
-- Date       Author   Ver Purpose
-- 20181016   KYan     v2 Add @c_PromoType and EditDate
-- ==================================================================
CREATE  PROC  dbo.isp_OrdersV2AggNum 
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
         , @cPK NVARCHAR(4000) =   ' O.StorerKey ,convert(nvarchar(10),O.AddDate,121), O.Facility, ISNULL(O.ECOM_SINGLE_Flag,''''), ISNULL(O.ECOM_PRESALE_FLAG,'''') '
--+CASE WHEN #TempTable IN ('OverRun') THEN ' '''','''' ' ELSE ' ,O.ECOM_SINGLE_Flag ,ECOM_PRESALE_FLAG = ISNULL(O.ECOM_PRESALE_FLAG,'''')' END
         , @cMainSQL  NVARCHAR(MAX), @cStorerSQL NVARCHAR(4000)
         , @cStdClause NVARCHAR(4000)

   SELECT  @DB=DB_NAME()    , @Schema=OBJECT_SCHEMA_NAME(@@PROCID), @Proc=ISNULL(OBJECT_NAME(@@PROCID),'')

   IF @cDTSITF='' SET @cDTSITF = LEFT(DB_NAME(),2)+'DTSITF'
   IF @cARC   ='' SET @cARC    = LEFT(DB_NAME(),2)+'ARCHIVE'

   IF ISNULL(OBJECT_ID('tempdb..#OrdersV2AggNum'), '') <> ''
   BEGIN
      DROP TABLE #OrdersV2AggNum
   END

   Create TABLE  #OrdersV2AggNum
   (  StorerKey      nvarchar(15),
      AddDate        date,
      Facility       nvarchar(10),
      ECOM_SINGLE_Flag  nvarchar(5),
      ECOM_PRESALE_FLAG nvarchar(5) NULL,
      num_Orders     BIGINT default 0,
      num_Lines      BIGINT default 0,
      num_Units      BIGINT default 0,
      TempTable      nvarchar(20) NOT NULL
   )

   SET @cStorerSQL = CASE WHEN @c_PromoType='Daily' THEN '' ELSE '
JOIN '+@cDTSITF+'.dbo.eCom_Stats_Config C WITH (NOLOCK) ON C.StorerKey = O.StorerKey AND C.Facility = O.Facility ' END;

   IF      @TempTable = 'OverRun'
   BEGIN
      SET @cMainSQL = '
,COUNT(DISTINCT O.Orderkey )
,0
,0
,'''+@TempTable+'''
FROM dbo.Orders O (NOLOCK) '+@cStorerSQL+'
JOIN dbo.Pickdetail PD (NOLOCK) ON PD.orderkey = O.OrderKey 
LEFT JOIN '+@cDTSITF+'.dbo.eCom_Stats_Config EC WITH (NOLOCK) ON EC.StorerKey = O.StorerKey AND EC.Facility = O.Facility
WHERE ( PD.ShipFlag <> ''Y''OR PD.Status <> ''9'' )
AND DATEDIFF(HOUR, PD.adddate, GETDATE()) >= ISNULL(EC.HoursOverrun,8)'
   END

   ELSE IF @TempTable = 'PickLine'
   BEGIN
      SET @cMainSQL = '
,0
,COUNT(1)
,0
,'''+@TempTable+'''
FROM dbo.Orders O WITH (NOLOCK) '+@cStorerSQL+'
JOIN dbo.PICKDETAIL P (NOLOCK) ON P.OrderKey = O.OrderKey
WHERE O.AddDate >= '''+CONVERT(NVARCHAR(23),@d_PrevDate ,121)+'''
 AND O.Status <> ''CANC'''
   END

   ELSE IF @TempTable = 'NewPickDet'
   BEGIN
      SET @cMainSQL = '
,0
,COUNT(1)
,0
,'''+@TempTable+'''
FROM dbo.Orders O WITH (NOLOCK) '+@cStorerSQL+'
JOIN dbo.PICKDETAIL P (NOLOCK) ON P.OrderKey = O.OrderKey
WHERE P.EditDate >= '''+CONVERT(NVARCHAR(23),@d_PrevDate ,121)+'''
 AND  P.EditDate <  '''+CONVERT(NVARCHAR(23),@d_Date     ,121)+'''
 AND O.Status <> ''CANC'''
   END


   ELSE IF @TempTable = 'Orders_PendBuildLoad'
   BEGIN
      SET @cMainSQL = '
,0
,COUNT(1)
,0
,'''+@TempTable+'''
FROM dbo.Orders O WITH (NOLOCK) '+@cStorerSQL+'
WHERE NOT EXISTS ( SELECT 1 FROM dbo.LOADPLAN LPD WITH (NOLOCK) WHERE LPD.LoadKey = O.LoadKey ) 
AND O.status < ''5'''
   END

   ELSE IF @TempTable = 'MBOL_NotValid'
   BEGIN
      SET @cMainSQL = '
,COUNT(DISTINCT M.MbolKey)
,0
,0
,'''+@TempTable+'''
FROM dbo.Mbol M WITH (NOLOCK)  
JOIN dbo.MBOLDETAIL MD WITH (NOLOCK) ON MD.MbolKey = M.MbolKey
JOIN dbo.Orders O WITH (NOLOCK) ON O.OrderKey = MD.OrderKey '+@cStorerSQL+'
WHERE M.status = ''5'' AND M.ValidatedFlag = ''E'''
   END
   --ELSE IF @TempTable = 'WSFiles'
   --BEGIN
   --   SET @cMainSQL = ''
   --END

   SET @c_Stmt = 
'SELECT '  +@cPK+'
'+@cMainSQL+'
'+CASE WHEN @c_Storerkey='' THEN '' ELSE ' AND O.StorerKey = '''+@c_Storerkey+''' ' END+CASE WHEN @c_PromoType='Daily' THEN '' ELSE '
 AND O.AddDate >= '''+CONVERT(NVARCHAR(23),@d_StartDate,121)+''' ' END+'
 AND O.AddDate <  '''+CONVERT(NVARCHAR(23),@d_EndDate  ,121)+'''
'       +CASE WHEN @c_PromoType='Daily' THEN '' ELSE '
 AND O.AddDate >= C.'+CASE WHEN @PreSale='1' 
THEN 'PresaleStart' ELSE 'PromoStart'     END+'
 AND O.AddDAte <  C.'+CASE WHEN @PreSale='1' 
THEN 'PromoStart'   ELSE 'CompletionDate' END  END+'
'       +CASE WHEN @c_PromoType='Daily' THEN '' ELSE ' AND O.DocType= ''E'' ' END+'
'+CASE WHEN @PreSale IN ('1','2') THEN ' AND ISNULL(ECOM_PRESALE_FLAG,'''')<>'''' ' ELSE '' END+'
 GROUP BY '+@cPK

   BEGIN TRY
      SET @dStart = GETDATE()
      INSERT #OrdersV2AggNum
      EXEC sp_ExecuteSql @c_Stmt
      SET @RowCnt = @@ROWCOUNT
   END TRY
   BEGIN CATCH
      PRINT @c_Stmt
      EXEC ispLogError  @DB, @Schema, @Proc, @Id, @c_ErrMsg OUTPUT, @n_Err OUTPUT, '',0,0,@TempTable
   END CATCH
   SET @nDuration = DATEDIFF(s,@dStart,GETDATE())
   EXEC dbo.ispLogQuery @DB, @Schema, @Proc, @Id, @c_Stmt, @nDuration, @RowCnt, @TempTable, @SQLId OUTPUT

   BEGIN TRY
      INSERT INTO   OrdersV2AggNum (StorerKey, AddDate, Facility, ECOM_SINGLE_Flag, ECOM_PRESALE_FLAG
         , num_Orders, num_Lines, num_Units, TempTable, SQLId)
      SELECT *, @SQLId FROM #OrdersV2AggNum ORDER BY StorerKey, Facility
   END TRY
   BEGIN CATCH
      EXEC ispLogError @DB, @Schema, @Proc, @@SPID, @c_ErrMsg OUTPUT, @n_Err OUTPUT, '',0,0,@TempTable
   END CATCH


END
