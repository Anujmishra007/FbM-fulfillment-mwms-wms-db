SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Stored Proc: msp_BEJ_BuildWave                                       */
/* Creation Date: 2024-10-17                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: UWP-24682 [FCR-764] [HUSQ] Outbound Wave update             */
/*        :                                                             */
/* Called By: Call by SQL Scheduler Job                                 */
/*          :                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2024-10-17  Wan      1.0   Created.                                  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_BEJ_BuildWave]
   @c_Storerkey   NVARCHAR(15)   = ''
,  @c_Facility    NVARCHAR(5)    = ''
,  @c_OtherConfig NVARCHAR(4000) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt       INT            = @@TRANCOUNT
         , @n_Continue        INT            = 1
         , @b_Success         INT            = 1
         , @n_Err             INT            = 0
         , @c_ErrMsg          NVARCHAR(255)  = ''

         , @n_FromPos         INT            = 0
         , @n_ToPos           INT            = 0
         , @n_MaxOpenQty      INT            = 0

         , @n_MaxOpenQty01    INT            = 0
         , @n_MaxOpenQty02    INT            = 0
         , @n_MaxOpenQty03    INT            = 0
         , @n_MaxOpenQty04    INT            = 0
         , @n_MaxOpenQty05    INT            = 0
         , @n_MaxOrdPerBld    INT            = 0
         , @n_MaxOrdPerBld01  INT            = 0
         , @n_MaxOrdPerBld02  INT            = 0
         , @n_MaxOrdPerBld03  INT            = 0
         , @n_MaxOrdPerBld04  INT            = 0
         , @n_MaxOrdPerBld05  INT            = 0

         , @c_BuildParmKey    NVARCHAR(10)   = ''
         , @c_BuildParmLineNo NVARCHAR(10)   = ''
         , @c_GenByBuildValue NCHAR(1)       = 'N'
         , @c_SQLBuildWave    NVARCHAR(MAX)  = ''
         , @c_UserName        NVARCHAR(128)  = SUSER_SNAME()
         , @dt_Date_Fr        DATETIME       = NULL
         , @dt_Date_To        DATETIME       = NULL

         , @c_Orderkey        NVARCHAR(10)   = ''
         , @c_Wavekey         NVARCHAR(10)   = ''
         , @c_Shipperkey      NVARCHAR(15)   = ''
         , @c_ParcelType      NVARCHAR(10)   = ''
         , @c_ParcelTypes     NVARCHAR(500)  = ''
         , @c_ParcelCategory  NVARCHAR(30)   = ''
         , @d_DeliveryDate    DATETIME       = ''

         , @n_Cube_Retail     FLOAT          = 0.00
         , @n_Cube_Box5       FLOAT          = 0.00
         , @n_Cube_Ord        FLOAT          = 0.00
         , @n_OpenQty         INT            = 0

         , @c_SQL             NVARCHAR(MAX)  = ''
         , @c_SQLParms        NVARCHAR(500)  = ''

         , @CUR_ORD           CURSOR

   SELECT @c_BuildParmKey = dbo.fnc_GetParamValueFromString ('@c_BuildParmKey',@c_OtherConfig, @c_BuildParmKey)
   PRINT '@c_BuildParmKey: ' + @c_BuildParmKey
    + ',Now = ' + CONVERT(NVARCHAR(25), GETDATE(),121)
    + ',@c_OtherConfig: ' + @c_OtherConfig

   IF @c_BuildParmKey = ''
   BEGIN
      GOTO QUIT_SP
   END

   BEGIN TRAN
   --Tables use in WM.lsp_Build_Wave
   IF OBJECT_ID('tempdb..#TMP_ORDERS','u') IS NULL
   BEGIN
      CREATE TABLE #TMP_ORDERS
      (
         OrderKey NVARCHAR(10)   NULL
      )
   END
   ELSE
   BEGIN
      TRUNCATE TABLE #TMP_ORDERS;
   END

   IF OBJECT_ID('tempdb..#TMP_SKUTOTQTY','u') IS NULL     --(Wan10)
   BEGIN
      CREATE TABLE #TMP_SKUTOTQTY
      (
         RowID          INT            NOT NULL DEFAULT(0)
      ,  Storerkey      NVARCHAR(15)   NOT NULL DEFAULT('')
      ,  Sku            NVARCHAR(20)   NOT NULL DEFAULT('')
      ,  Qty            INT            NOT NULL DEFAULT(0)
      )
   END
   ELSE
   BEGIN
      TRUNCATE TABLE #TMP_SKUTOTQTY;
   END

   --Table uses in current SP
   IF OBJECT_ID('tempdb..#TMP_ORD','u') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_ORD;
   END

   CREATE TABLE #TMP_ORD
   (
      OrderKey        NVARCHAR(10)   NOT NULL DEFAULT ('')   PRIMARY KEY
   ,  Wavekey         NVARCHAR(10)   NOT NULL DEFAULT ('')
   ,  ParcelType      NVARCHAR(10)   NOT NULL DEFAULT ('')
   ,  ParcelCategory  NVARCHAR(60)   NOT NULL DEFAULT ('')
   )

   IF OBJECT_ID('tempdb..#TMP_CODELKUP','u') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_CODELKUP;
   END

   CREATE TABLE #TMP_CODELKUP
   (  ListName    NVARCHAR(10)   NOT NULL    DEFAULT ('')
   ,  Code        NVARCHAR(30)   NOT NULL    DEFAULT ('')
   ,  Short       NVARCHAR(10)   NOT NULL    DEFAULT ('')
   ,  UDF01       NVARCHAR(60)   NOT NULL    DEFAULT ('')
   ,  UDF02       NVARCHAR(60)   NOT NULL    DEFAULT ('')
   ,  UDF03       NVARCHAR(60)   NOT NULL    DEFAULT ('')
   ,  UDF04       NVARCHAR(60)   NOT NULL    DEFAULT ('')
   ,  UDF05       NVARCHAR(60)   NOT NULL    DEFAULT ('')
   ,  Storerkey   NVARCHAR(15)   NOT NULL    DEFAULT ('')
   ,  Code2       NVARCHAR(30)   NOT NULL    DEFAULT ('')
   )

   SELECT @n_MaxOrdPerBld01= CASE WHEN BP.Restriction01 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue01  ELSE 0 END
         ,@n_MaxOrdPerBld02= CASE WHEN BP.Restriction02 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue02  ELSE 0 END
         ,@n_MaxOrdPerBld03= CASE WHEN BP.Restriction03 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue03  ELSE 0 END
         ,@n_MaxOrdPerBld04= CASE WHEN BP.Restriction04 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue04  ELSE 0 END
         ,@n_MaxOrdPerBld05= CASE WHEN BP.Restriction05 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue05  ELSE 0 END
         ,@n_MaxOpenQty01  = CASE WHEN BP.Restriction01 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue01  ELSE 0 END
         ,@n_MaxOpenQty02  = CASE WHEN BP.Restriction02 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue02  ELSE 0 END
         ,@n_MaxOpenQty03  = CASE WHEN BP.Restriction03 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue03  ELSE 0 END
         ,@n_MaxOpenQty04  = CASE WHEN BP.Restriction04 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue04  ELSE 0 END
         ,@n_MaxOpenQty05  = CASE WHEN BP.Restriction05 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue05  ELSE 0 END
   FROM BUILDPARM BP WITH (NOLOCK)
   WHERE BP.BuildParmKey = @c_BuildParmKey

   SET @n_MaxOrdPerBld= @n_MaxOrdPerBld01
   IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld02
   IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld03
   IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld04
   IF @n_MaxOrdPerBld = 0 SET @n_MaxOrdPerBld = @n_MaxOrdPerBld05

   SET @n_MaxOpenQty= @n_MaxOpenQty01
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty02
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty03
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty04
   IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty05

   EXEC [WM].[lsp_Build_Wave]
         @c_BuildParmKey   = @c_BuildParmKey
      ,  @c_Facility       = @c_Facility
      ,  @c_StorerKey      = @c_StorerKey
      ,  @c_BuildWaveType  = 'ANALYSIS'
      ,  @c_GenByBuildValue= @c_GenByBuildValue
      ,  @c_SQLBuildWave   = @c_SQLBuildWave OUTPUT
      ,  @n_BatchNo        = 0
      ,  @b_Success        = @b_Success      OUTPUT
      ,  @n_err            = @n_err          OUTPUT
      ,  @c_ErrMsg         = @c_ErrMsg       OUTPUT
      ,  @c_UserName       = @c_UserName
      ,  @dt_Date_Fr       = @dt_Date_Fr
      ,  @dt_Date_To       = @dt_Date_To

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3
   END

   IF @n_Continue = 1
   BEGIN
      SET @n_FromPos   = CHARINDEX('FROM ', @c_SQLBuildWave , 1)
      SET @n_ToPos = LEN(@c_SQLBuildWave) - @n_FromPos + 1

      SET @c_SQL  = N'SELECT ORDERS.Orderkey'
                  + ' ' + CHAR(13) + SUBSTRING(@c_SQLBuildWave, @n_FromPos, @n_ToPos)

      SET @c_SQLParms = N'@c_Facility     NVARCHAR(5)'
                      + ',@c_Storerkey    NVARCHAR(15)'
                      + ',@n_MaxOpenQty   INT'

      INSERT INTO #TMP_ORD (Orderkey)
      EXEC SP_EXECUTESQL
            @c_SQL
         ,  @c_SQLParms
         ,  @c_Facility
         ,  @c_Storerkey
         ,  @n_MaxOpenQty

      INSERT INTO #TMP_CODELKUP
         (ListName, Code, Short, UDF01, UDF02, UDF03, UDF04, UDF05, Storerkey,Code2)
      SELECT ListName, Code
           , Short = ISNULL(Short,'')
           , UDF01, UDF02
           , IIF(ISNUMERIC(UDF03)= 1, UDF03,'0.00')
           , IIF(ISNUMERIC(UDF04)= 1, UDF04,'0.00')
           , UDF05
           , Storerkey,Code2
      FROM CODELKUP (NOLOCK)
      WHERE ListName  = 'HUSQPKTYPE'
      AND   Storerkey = @c_Storerkey

      INSERT INTO #TMP_CODELKUP (ListName, Code,  Short, UDF01)
      VALUES ('HUSQPKTYPE', '999', 'UNKNOWN',  'UNKNOWN')

      INSERT INTO #TMP_CODELKUP
         (ListName, Code, Short, UDF01, UDF02, UDF03, UDF04, UDF05, Storerkey,Code2)
      SELECT ListName, Code
           , Short = ISNULL(Short,'')
           , UDF01, UDF02, UDF03, UDF04, UDF05
           , Storerkey,Code2
      FROM CODELKUP (NOLOCK)
      WHERE ListName  = 'WSCourier'
      AND   Storerkey = @c_Storerkey

      SELECT TOP 1 @n_Cube_Retail = t.UDF04
      FROM #TMP_CODELKUP t
      WHERE t.UDF01 = 'PARCEL'
      ORDER BY TRY_CONVERT (float, t.UDF04) DESC

      SELECT TOP 1 @n_Cube_Box5 = t.UDF04
      FROM #TMP_CODELKUP t
      WHERE t.UDF01 = 'PARCEL'
      AND   t.Code2 = 'Undersized'
      ORDER BY TRY_CONVERT (float, t.UDF04) DESC

      SET @CUR_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT t.Orderkey
      FROM #TMP_ORD t
      ORDER BY t.Orderkey

      OPEN @CUR_ORD

      FETCH NEXT FROM @CUR_ORD INTO @c_Orderkey

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         -- Get Total Cube
         SET @n_Cube_Ord= 0.00
         SET @n_OpenQty = 0
         SELECT @n_Cube_Ord= SUM(p.WidthUOM3 * p.LengthUOM3 * p.HeightUOM3 * od.OpenQty)
               ,@n_OpenQty = SUM(od.OpenQty)
         FROM ORDERDETAIL od (NOLOCK)
         JOIN SKU s (NOLOCK) ON  s.Storerkey = od.Storerkey
                             AND s.Sku  = od.Sku
         JOIN PACK p (NOLOCK) ON p.Packkey = s.Packkey
         WHERE od.OrderKey = @c_Orderkey

         SELECT TOP 1 @c_ParcelType = t.Short
         FROM #TMP_CODELKUP t
         WHERE t.Storerkey = @c_Storerkey
         AND t.UDF01 = 'PARCEL'
         AND @n_Cube_Ord BETWEEN CONVERT(FLOAT, t.UDF03) AND CONVERT(FLOAT, t.UDF04)


         SET @c_ShipperKey = ''
         IF @n_OpenQty = 1
         BEGIN
            SELECT TOP 1 @c_ShipperKey = t.Short
            FROM #TMP_CODELKUP t
            WHERE t.Storerkey = @c_Storerkey
            AND t.ListName = 'WSCourier'
            AND t.Code  = 'FML-1'
         END

         IF @n_Cube_Ord > @n_Cube_Retail
         BEGIN
            SET @c_ParcelType = 'Non-Parcel'
         END
         ELSE IF @n_Cube_Ord > @n_Cube_Box5 AND @n_Cube_Ord <= @n_Cube_Retail
         BEGIN
            IF @n_OpenQty > 1
            BEGIN
               SET @c_ParcelType = 'Non-Parcel'
            END
         END

         IF @c_ParcelType = ''
         BEGIN
            SET @c_ParcelType = 'UNKNOWN'
         END

         UPDATE ORDERS WITH (ROWLOCK)
         SET UserDefine10 = @c_ParcelType
            ,Shipperkey   = CASE WHEN @c_Shipperkey = ''
                                 THEN Shipperkey
                                 ELSE @c_Shipperkey
                                 END
            ,EditWho = SUSER_SNAME()
            ,EditDate = GETDATE()
            ,TrafficCop = NULL
         WHERE Orderkey = @c_Orderkey

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_ErrMsg   = ERROR_MESSAGE()
         END

         SELECT @c_ParcelCategory = cl.UDF01
         FROM  #TMP_CODELKUP cl
         WHERE cl.ListName  = 'HUSQPKTYPE'
         AND   cl.Storerkey = @c_Storerkey
         AND   cl.Short     = @c_ParcelType

         UPDATE #TMP_ORD SET ParcelType = @c_ParcelType, ParcelCategory = @c_ParcelCategory
         WHERE Orderkey = @c_Orderkey

         FETCH NEXT FROM @CUR_ORD INTO @c_Orderkey
      END
      CLOSE @CUR_ORD
      DEALLOCATE @CUR_ORD
   END

   IF @n_Continue = 1
   BEGIN
      SELECT @c_BuildParmLineNo = bpd.BuildParmLineNo
      FROM BUILDPARMDETAIL bpd (NOLOCK)
      WHERE bpd.BuildParmKey = @c_BuildParmKey
      AND   bpd.[Type] = 'CONDITION'
      AND   bpd.FieldName = 'ORDERS.UserDefine10'

      SET @CUR_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT t.ParcelCategory
      FROM #TMP_ORD t
      WHERE t.ParcelCategory  <> 'Non-Parcel'
      GROUP BY  t.ParcelCategory
      ORDER BY  t.ParcelCategory

      OPEN @CUR_ORD

      FETCH NEXT FROM @CUR_ORD INTO @c_ParcelCategory

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         SET @c_Wavekey = ''
         SELECT TOP 1 @c_Wavekey = wd.Wavekey
         FROM ORDERS o (NOLOCK)
         JOIN WAVEDETAIL wd (NOLOCK) ON wd.Orderkey = o.Orderkey
         JOIN #TMP_CODELKUP cl ON  cl.ListName = 'HUSQPKTYPE'
                               AND cl.Storerkey= o.Storerkey
                               AND cl.Short    = o.Userdefine10
         WHERE o.Storerkey = @c_Storerkey
         AND   cl.Udf01    = @c_ParcelCategory
         GROUP BY wd.Wavekey
         HAVING MIN(o.Status) = '0'
         AND COUNT(1) < @n_MaxOrdPerBld
         ORDER BY wd.WaveKey

         SET @c_ParcelTypes = ''
         SELECT @c_ParcelTypes = STRING_AGG ('''' + t.ParcelType + '''', ',')
           WITHIN GROUP (ORDER BY t.ParcelType ASC)
         FROM #TMP_ORD t
         WHERE t.ParcelCategory = @c_ParcelCategory
         GROUP BY t.ParcelType

         UPDATE BUILDPARMDETAIL WITH (ROWLOCK)
            SET BuildValue = @c_ParcelTypes        -- Use Operator = 'IN'
               ,TrafficCop = NULL
         WHERE BuildParmKey = @c_BuildParmKey
         AND BuildParmLineNo= @c_BuildParmLineNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_ErrMsg   = ERROR_MESSAGE()
         END

         IF @n_Continue = 1
         BEGIN
            SET @c_GenByBuildValue = 'Y'
            EXEC [WM].[lsp_Build_Wave]
               @c_BuildParmKey   = @c_BuildParmKey
            ,  @c_Facility       = @c_Facility
            ,  @c_StorerKey      = @c_StorerKey
            ,  @c_BuildWaveType  = ''
            ,  @c_GenByBuildValue= @c_GenByBuildValue
            ,  @c_SQLBuildWave   = @c_SQLBuildWave OUTPUT
            ,  @n_BatchNo        = 0
            ,  @b_Success        = @b_Success      OUTPUT
            ,  @n_err            = @n_err          OUTPUT
            ,  @c_ErrMsg         = @c_ErrMsg       OUTPUT
            ,  @c_UserName       = @c_UserName
            ,  @dt_Date_Fr       = @dt_Date_Fr
            ,  @dt_Date_To       = @dt_Date_To
            ,  @c_Wavekey        = @c_Wavekey

            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3
            END
         END

         IF @n_Continue = 1
         BEGIN
            UPDATE #TMP_ORD
               SET Wavekey = wd.Wavekey
            FROM #TMP_ORD t
            JOIN WAVEDETAIL wd (NOLOCK) ON wd.Orderkey = t.Orderkey
            WHERE ParcelCategory = @c_ParcelCategory

            IF EXISTS (SELECT 1
                       FROM #TMP_ORD t
                       JOIN ORDERS o (NOLOCK) ON o.Orderkey = t.Orderkey
                       WHERE t.ParcelCategory = @c_ParcelCategory
                       AND   o.UserDefine10 = ''
                      )
            BEGIN
               CONTINUE
            END
         END
         FETCH NEXT FROM @CUR_ORD INTO @c_ParcelCategory
      END
      CLOSE @CUR_ORD
      DEALLOCATE @CUR_ORD
   END

   IF @n_Continue = 1
   BEGIN
      SET @CUR_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT t.Wavekey, t.ParcelCategory
      FROM #TMP_ORD t
      WHERE t.Wavekey <> ''
      GROUP BY t.Wavekey, t.ParcelCategory
      ORDER BY t.Wavekey

      OPEN @CUR_ORD

      FETCH NEXT FROM @CUR_ORD INTO @c_Wavekey, @c_ParcelCategory

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         SELECT TOP 1 @d_DeliveryDate = o.DeliveryDate
         FROM WAVEDETAIL wd (NOLOCK)
         JOIN ORDERS o (NOLOCK) ON o.Orderkey = wd.Orderkey
         WHERE wd.WaveKey = @c_Wavekey
         ORDER BY wd.WaveDetailKey DESC

         UPDATE WAVE WITH (ROWLOCK)
            SET UserDefine01 = CONVERT(NVARCHAR(21), @d_DeliveryDate, 120)
               ,UserDefine02 = @c_ParcelCategory
               ,EditWho = SUSER_SNAME()
               ,EditDate = GETDATE()
               ,TrafficCop = NULL
         WHERE Wavekey = @c_Wavekey

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_ErrMsg   = ERROR_MESSAGE()
         END

         FETCH NEXT FROM @CUR_ORD INTO @c_Wavekey, @c_ParcelCategory
      END
      CLOSE @CUR_ORD
      DEALLOCATE @CUR_ORD
   END
QUIT_SP:
   IF @n_continue=3
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
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON msp_BEJ_BuildWave TO nSQL
GO 