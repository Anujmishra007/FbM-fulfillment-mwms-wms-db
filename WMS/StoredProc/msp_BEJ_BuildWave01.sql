SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_BEJ_BuildWave01                                     */
/* Creation Date: 2024-10-17                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Ugam                                                     */
/*                                                                      */
/* Purpose: UWP-32706 [FCR-3956] [JCB] Auto Waving Process              */
/*        :                                                             */
/* Called By: Call by SQL Scheduler Job                                 */
/*          :                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author       Ver       Purposes                          */
/* 2025-04-21  USH022       1.0       Created.                          */
/************************************************************************/

CREATE OR ALTER  PROC [dbo].[msp_BEJ_BuildWave01]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt          INT            = @@TRANCOUNT
         , @n_Continue           INT            = 1
         , @b_Success            INT            = 1
         , @n_Err                INT            = 0
         , @c_ErrMsg             NVARCHAR(255)  = ''

         , @n_FromPos            INT            = 0
         , @n_ToPos              INT            = 0
         , @n_MaxOpenQty         INT            = 0

         , @n_MaxOpenQty01       INT            = 0
         , @n_MaxOpenQty02       INT            = 0
         , @n_MaxOpenQty03       INT            = 0
         , @n_MaxOpenQty04       INT            = 0
         , @n_MaxOpenQty05       INT            = 0
         , @n_MaxOrdPerBld       INT            = 0
         , @n_MaxOrdPerBld01     INT            = 0
         , @n_MaxOrdPerBld02     INT            = 0
         , @n_MaxOrdPerBld03     INT            = 0
         , @n_MaxOrdPerBld04     INT            = 0
         , @n_MaxOrdPerBld05     INT            = 0

         , @c_BuildParmKey       NVARCHAR(10)   = ''
         , @c_BuildParmLineNo    NVARCHAR(10)   = ''

         , @c_GenByBuildValue    NCHAR(1)       = 'N'
         , @c_SQLBuildWave       NVARCHAR(MAX)  = ''
         , @c_UserName           NVARCHAR(128)  = SUSER_SNAME()
         , @dt_Date_Fr           DATETIME       = NULL
         , @dt_Date_To           DATETIME       = NULL

         , @c_OrderKey           NVARCHAR(10)   = ''
         , @c_OrderKeyPrev       NVARCHAR(10)   = ''
         , @c_WaveKey            NVARCHAR(10)   = ''
         , @c_WaveKeyPrev        NVARCHAR(10)   = ''
         , @d_DeliveryDate       DATETIME       = ''
         , @d_DeliveryDatePrev   DATETIME       = ''
         , @n_OpenQty            INT            = 0
         , @c_SQL                NVARCHAR(MAX)  = ''
         , @c_SQLParms           NVARCHAR(500)  = ''
         , @c_SQLMaxOrd          NVARCHAR(500)  = ''
         , @c_SQLCondAddToWave   NVARCHAR(MAX)  = ''
         , @b_Debug              INT            = 0
         , @CUR_ORD              CURSOR
         , @c_code               NVARCHAR(30) = ''
         , @c_Lottable03         NVARCHAR(100)= ''
         , @c_Lottable03Prev     NVARCHAR(100)= ''
         , @c_C_Zip              NVARCHAR(36) = ''
         , @c_C_ZipPrev          NVARCHAR(36) = ''
         , @c_Type               NVARCHAR(20) = ''
         , @c_OrderGroup         NVARCHAR(100) = ''
         , @c_C_Company          NVARCHAR(100) = ''
         , @c_TypePrev           NVARCHAR(20) = ''
         , @n_WaveOrderCnt       INT          = 0
         , @c_LoadKey            NVARCHAR(30) = ''
         , @c_LoadKeyPrev        NVARCHAR(30) = ''
         , @b_PopupWindow        INT   = 0
         , @n_NoOfOrderNoLoad    INT   = 0
         , @n_debug              INT    = 0

   IF RIGHT(ISNULL(TRIM(@c_OtherConfig),''),2) = '##'
      BEGIN
         SET @b_Debug = 1
         SET @c_OtherConfig = SUBSTRING(@c_OtherConfig, 1, LEN(@c_OtherConfig)-2)
      END

      SELECT @c_BuildParmKey = dbO.fnc_GetParamValueFromString ('@c_BuildParmKey',@c_OtherConfig, @c_BuildParmKey)

      SELECT @c_Facility = dbo.fnc_GetParamValueFromString('@c_Facility', @c_OtherConfig, @c_Facility)

      IF @b_Debug = 1
      BEGIN
         PRINT '@c_BuildParmKey: ' + @c_BuildParmKey
             + ', Now = ' + CONVERT(NVARCHAR(25), GETDATE(),121)
             + ', @c_OtherConfig: ' + @c_OtherConfig
      END

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
         , StorerKey      NVARCHAR(15)   NOT NULL DEFAULT('')
         , Sku            NVARCHAR(20)   NOT NULL DEFAULT('')
         , Qty            INT            NOT NULL DEFAULT(0)

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
      , WaveKey         NVARCHAR(10)   NOT NULL DEFAULT ('')
      , Lottable03      NVARCHAR(100)  NULL DEFAULT ('')
      , C_Zip           NVARCHAR(36)   NULL DEFAULT ('')
      , [TYPE]          NVARCHAR(20)   NULL DEFAULT ('')
      , OrderGroup      NVARCHAR(100)  NULL DEFAULT ('')
      , C_Company       NVARCHAR(100)  NULL DEFAULT ('')
      , DeliveryDate    DATETIME       NULL
      )

      IF OBJECT_ID('tempdb..#TMP_CODELKUP','u') IS NOT NULL
      BEGIN
         DROP TABLE #TMP_CODELKUP;
      END

      CREATE TABLE #TMP_CODELKUP
      ( ListName    NVARCHAR(10)   NOT NULL    DEFAULT ('')
      , Code        NVARCHAR(30)   NOT NULL    DEFAULT ('')
      , Short       NVARCHAR(10)   NOT NULL    DEFAULT ('')
      , UDF01       NVARCHAR(60)   NOT NULL    DEFAULT ('')
      , UDF02       NVARCHAR(60)   NOT NULL    DEFAULT ('')
      , UDF03       NVARCHAR(60)   NOT NULL    DEFAULT ('')
      , UDF04       NVARCHAR(60)   NOT NULL    DEFAULT ('')
      , UDF05       NVARCHAR(60)   NOT NULL    DEFAULT ('')
      , StorerKey   NVARCHAR(15)   NOT NULL    DEFAULT ('')
      , Code2       NVARCHAR(30)   NOT NULL    DEFAULT ('')
      )

      SELECT  @n_MaxOrdPerBld01= CASE WHEN BP.Restriction01 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue01  ELSE 0 END
            , @n_MaxOrdPerBld02= CASE WHEN BP.Restriction02 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue02  ELSE 0 END
            , @n_MaxOrdPerBld03= CASE WHEN BP.Restriction03 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue03  ELSE 0 END
            , @n_MaxOrdPerBld04= CASE WHEN BP.Restriction04 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue04  ELSE 0 END
            , @n_MaxOrdPerBld05= CASE WHEN BP.Restriction05 = '1_MaxOrderPerBuild' THEN BP.RestrictionValue05  ELSE 0 END
            , @n_MaxOpenQty01  = CASE WHEN BP.Restriction01 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue01  ELSE 0 END
            , @n_MaxOpenQty02  = CASE WHEN BP.Restriction02 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue02  ELSE 0 END
            , @n_MaxOpenQty03  = CASE WHEN BP.Restriction03 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue03  ELSE 0 END
            , @n_MaxOpenQty04  = CASE WHEN BP.Restriction04 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue04  ELSE 0 END
            , @n_MaxOpenQty05  = CASE WHEN BP.Restriction05 = '2_MaxQtyPerBuild'   THEN BP.RestrictionValue05  ELSE 0 END
      FROM BUILDPARM BP WITH (NOLOCK)
      WHERE BP.BuildParmKey = @c_BuildParmKey

      SET @n_MaxOrdPerBld= @n_MaxOrdPerBld01

      IF @n_MaxOrdPerBld > 0
      BEGIN
         SET @c_SQLMaxOrd = N',RestrictionBuildValue01=@n_MaxOrdPerBld'
      END
      IF @n_MaxOrdPerBld = 0
      BEGIN
         SET @n_MaxOrdPerBld = @n_MaxOrdPerBld02
         SET @c_SQLMaxOrd = N',RestrictionBuildValue02=@n_MaxOrdPerBld'
      END
      IF @n_MaxOrdPerBld = 0
      BEGIN
         SET @n_MaxOrdPerBld = @n_MaxOrdPerBld03
         SET @c_SQLMaxOrd = N',RestrictionBuildValue03=@n_MaxOrdPerBld'
      END
      IF @n_MaxOrdPerBld = 0
      BEGIN
         SET @n_MaxOrdPerBld = @n_MaxOrdPerBld04
         SET @c_SQLMaxOrd = N',RestrictionBuildValue04=@n_MaxOrdPerBld'
      END
      IF @n_MaxOrdPerBld = 0
      BEGIN
         SET @n_MaxOrdPerBld = @n_MaxOrdPerBld05
         SET @c_SQLMaxOrd = N',RestrictionBuildValue05=@n_MaxOrdPerBld'
      END

      SET @n_MaxOpenQty= @n_MaxOpenQty01
      IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty02
      IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty03
      IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty04
      IF @n_MaxOpenQty = 0   SET @n_MaxOpenQty = @n_MaxOpenQty05

      EXEC [WM].[lsp_Build_Wave]
           @c_BuildParmKey   = @c_BuildParmKey
         , @c_Facility       = @c_Facility
         , @c_StorerKey      = @c_StorerKey
         , @c_BuildWaveType  = 'ANALYSIS'
         , @c_GenByBuildValue= @c_GenByBuildValue
         , @c_SQLBuildWave   = @c_SQLBuildWave OUTPUT
         , @n_BatchNo        = 0
         , @b_Success        = @b_Success      OUTPUT
         , @n_err            = @n_err          OUTPUT
         , @c_ErrMsg         = @c_ErrMsg       OUTPUT
         , @c_UserName       = @c_UserName
         , @dt_Date_Fr       = @dt_Date_Fr
         , @dt_Date_To       = @dt_Date_To

      IF @b_Debug = 2
      BEGIN
         PRINT ''
         PRINT 'BuildWaveType:   ' + 'ANALYSIS'                          + CHAR(13)
             + 'BuildParmKey:    ' + ISNULL(TRIM(@c_BuildParmKey),'')    + CHAR(13)
             + 'GenByBuildValue: ' + ISNULL(TRIM(@c_GenByBuildValue),'') + CHAR(13)
             + 'SQLBuildWave:    ' + ISNULL(TRIM(@c_SQLBuildWave),'')    + CHAR(13)
             + 'ErrMsg:          ' + CAST(@b_Success AS CHAR(5))
                                   + ISNULL(TRIM(@c_ErrMsg),'')          + CHAR(13)
      END

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END

      IF @n_Continue = 1
      BEGIN
         SET @n_FromPos = CHARINDEX('FROM ', @c_SQLBuildWave , 1)
         SET @n_ToPos   = LEN(@c_SQLBuildWave) - @n_FromPos + 1

         SET @c_SQL  = N'SELECT ORDERS.OrderKey'
                     + ' ' + CHAR(13) + SUBSTRING(@c_SQLBuildWave, @n_FromPos, @n_ToPos)

         SET @c_SQLParms = N'@c_Facility     NVARCHAR(5)'
                         + ',@c_StorerKey    NVARCHAR(15)'
                         + ',@n_MaxOpenQty   INT'

         INSERT INTO #TMP_ORD (OrderKey)

         EXEC SP_EXECUTESQL
               @c_SQL
            ,  @c_SQLParms
            ,  @c_Facility
            ,  @c_StorerKey
            ,  @n_MaxOpenQty

		 -- PPA374 updating ORDERS table for orders in temp table (JCB)
		 IF EXISTS (
		    SELECT 1 
			FROM dbo.StorerConfig WITH(NOLOCK)
			WHERE StorerKey = @c_StorerKey
			   AND Facility = @c_Facility
			   AND SValue = '1'
			   AND ConfigKey = 'BillToKeyASDDHour'
		 )
		 BEGIN
		    UPDATE ORDERS
		    SET BillToKey = DATEPART(HOUR, DeliveryDate)
		    WHERE OrderKey IN (SELECT OrderKey FROM #TMP_ORD)
		 END
		 --
           
         ;WITH ord AS
               (  SELECT o.Orderkey
               , MAX(o.C_Zip)        AS C_Zip
               , MAX(o.[TYPE])       AS [TYPE]
               , MAX(o.OrderGroup)   AS OrderGroup
               , MAX(o.C_Company)    AS C_Company
               , MAX(o.DeliveryDate) AS DeliveryDate
               , MAX(od.Lottable03)  AS Lottable03
               FROM #TMP_ORD t
               JOIN ORDERS o (NOLOCK) ON o.Orderkey  = t.Orderkey
               JOIN ORDERDETAIL od (NOLOCK) ON od.OrderKey = o.Orderkey
                     GROUP BY o.Orderkey
               )
         UPDATE t
               SET c_Zip        = o.C_Zip
               ,  type         = o.[TYPE]
               ,  OrderGroup   = o.OrderGroup
               ,  C_Company    = o.C_Company
               ,  DeliveryDate = o.DeliveryDate
               ,  Lottable03   = o.Lottable03
               FROM ord o
               JOIN #TMP_ORD t ON o.orderkey = t.orderkey
      END

      DECLARE @n_Cnt INT = 1;
      DECLARE @c_Priority NVARCHAR(1);

      SET @c_WaveKey = ''
      SET @c_Priority = ''

      SELECT @c_Priority = dbO.fnc_GetParamValueFromString ('@c_Priority',@c_OtherConfig, @c_Priority)

      IF (@c_Priority <> 1 AND 1 = 2 ) AND @n_Continue = 1
      BEGIN
         WHILE @n_Continue = 1
         BEGIN
            SELECT TOP 1
                    @c_Lottable03 = T.Lottable03
                  , @c_Type       = T.[Type]
                  , @d_DeliveryDate = T.DeliveryDate
                  , @c_OrderGroup   = T.OrderGroup
                  , @c_C_Company    = T.C_Company
            FROM #TMP_ORD T
            WHERE WaveKey = ''
            ORDER BY
                  T.Lottable03,
                  T.[TYPE],
                  T.DeliveryDate,
                  T.OrderGroup,
                  T.C_Company

            SET @n_Cnt = @@ROWCOUNT

            IF @n_Cnt = 0
            BEGIN
               BREAK
            END

               SET @c_SQLCondAddToWave = N''

               SET @c_SQLCondAddToWave += N' AND ORDERDETAIL.Lottable03 = ''' + @c_Lottable03 + ''''

               SET @c_SQLCondAddToWave += N' AND ORDERS.C_Company = ''' + @c_C_Company + ''''

               SET @c_SQLCondAddToWave += N' AND ORDERS.Type = ''' + @c_Type + ''''

               SET @c_SQLCondAddToWave += N' AND ORDERS.OrderGroup = ''' + @c_OrderGroup + ''''

               SET @c_SQLCondAddToWave += N' AND CAST(ORDERS.DeliveryDate AS DATE) = CAST('''
                              + CONVERT(NVARCHAR(10), @d_DeliveryDate, 121) + ''' AS DATE)'

            IF @n_Continue = 1
            BEGIN
               SET @c_GenByBuildValue = 'Y'
               EXEC [WM].[lsp_Build_Wave]
                 @c_BuildParmKey   = @c_BuildParmKey
               , @c_Facility       = @c_Facility
               , @c_StorerKey      = @c_StorerKey
               , @c_BuildWaveType  = 'BuildWave'
               , @c_GenByBuildValue= @c_GenByBuildValue
               , @c_SQLBuildWave   = @c_SQLBuildWave OUTPUT
               , @n_BatchNo        = 0
               , @b_Success        = @b_Success      OUTPUT
               , @n_err            = @n_err          OUTPUT
               , @c_ErrMsg         = @c_ErrMsg       OUTPUT
               , @c_UserName       = @c_UserName
               , @dt_Date_Fr       = @dt_Date_Fr
               , @dt_Date_To       = @dt_Date_To
               , @c_WaveKey        = @c_WaveKey
               , @c_SQLAddToWaveCond = @c_SQLCondAddToWave

               IF @b_Success = 0
               BEGIN
                  SET @n_Continue = 3
               END
            END

            SET @c_WaveKey = ''
            SELECT TOP 1 @c_WaveKey = WD.WaveKey
            FROM WaveDetail WD
            JOIN Orders O (NOLOCK) ON WD.OrderKey = O.OrderKey
            JOIN OrderDetail OD (NOLOCK) ON O.OrderKey = OD.OrderKey
            LEFT JOIN LoadPlanDetail LPD (NOLOCK) ON WD.OrderKey = LPD.OrderKey
            WHERE O.Storerkey = @c_StorerKey
            AND O.Facility = @c_Facility
            AND OD.Lottable03 = @c_Lottable03
            AND O.C_Company = @c_C_Company
            AND O.Type = @c_Type
            AND O.OrderGroup = @c_OrderGroup
            AND CAST(O.DeliveryDate AS DATE) = CAST(@d_DeliveryDate AS DATE)
            AND ISNULL(O.ECOM_Platform, '') <> ''
            AND LPD.LoadKey IS NULL
            GROUP BY WD.WaveKey
            HAVING COUNT(1) = SUM(CASE WHEN
                                       OD.Lottable03 = @c_Lottable03
                                       AND O.C_Company = @c_C_Company
                                       AND O.Type = @c_Type
                                       AND O.OrderGroup = @c_OrderGroup
                                       AND CAST(O.DeliveryDate AS DATE)
                                         = CAST(@d_DeliveryDate AS DATE)
                                       AND ISNULL(O.ECOM_Platform, '') <> ''
                                       AND LPD.LoadKey IS NULL
                                       THEN 1 ELSE 0 END)
            AND COUNT(1) <= @n_MaxOrdPerBld
            ORDER BY WD.WaveKey;

            IF @n_Continue = 1
            BEGIN
               UPDATE #TMP_ORD
                  SET WaveKey = WD.WaveKey
               FROM #TMP_ORD T
               JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.Orderkey = T.Orderkey
            END

            IF EXISTS(SELECT 1
                        FROM WAVEDETAIL WD (NOLOCK)
                        JOIN ORDERS O (NOLOCK) ON O.OrderKey = WD.OrderKey
                        WHERE O.UserDefine09 = @c_WaveKey
                        HAVING (COUNT(1) >= @n_MaxOrdPerBld) AND @n_debug = 1)
            BEGIN
               PRINT 'Condition is true Load can be generated for the Wave : ' +@c_WaveKey;
            END ELSE PRINT 'Condition false unable to generate load for the wave : ' + @c_WaveKey

            IF @n_Continue = 1 AND
               EXISTS ( SELECT 1
                        FROM WAVEDETAIL WD (NOLOCK)
                        JOIN ORDERS O (NOLOCK) ON O.OrderKey = WD.OrderKey
                        WHERE O.UserDefine09 = @c_WaveKey
                        HAVING (COUNT(1) <= @n_MaxOrdPerBld)
                      )
            BEGIN
               EXEC [WM].[lsp_WaveGenLoadPlan]
                     @c_WaveKey         = @c_WaveKey
                  ,  @b_Success         = @b_Success  OUTPUT
                  ,  @n_err             = @n_err      OUTPUT
                  ,  @c_ErrMsg          = @c_ErrMsg   OUTPUT
                  ,  @c_UserName        = @c_UserName
                  ,  @b_PopupWindow     = @b_PopupWindow     OUTPUT
                  ,  @n_NoOfOrderNoLoad = @n_NoOfOrderNoLoad OUTPUT
                  ,  @c_BuildParmKeys   = 'DEVEM_LP'

               IF @b_Success = 0
               BEGIN
                  SET @n_Continue = 3
               END

               IF @n_Continue = 1
               BEGIN
                  EXEC [WM].[lsp_WaveGenMBOL]
                     @c_WaveKey  = @c_WaveKey
                  ,  @b_Success  = @b_Success  OUTPUT
                  ,  @n_err      = @n_err      OUTPUT
                  ,  @c_ErrMsg   = @c_ErrMsg   OUTPUT
                  ,  @c_UserName = @c_UserName

                  IF @b_Success = 0
                  BEGIN
                     SET @n_Continue = 3
                  END
               END

               IF @n_Continue = 1
               BEGIN
                  UPDATE MBOL WITH (ROWLOCK)
                  SET MBOL.ExternMbolKey = @c_WaveKey,
                      MBOL.TrafficCop = NULL
                  FROM MBOL
                  INNER JOIN MBOLDETAIL ON MBOL.MBOLKey = MBOLDETAIL.MBOLKey
                  INNER JOIN WaveDetail ON WaveDetail.OrderKey = MBOLDETAIL.OrderKey
                  WHERE WaveDetail.WaveKey = @c_WaveKey

                  IF @@ERROR <> 0
                  BEGIN
                     SET @n_Continue = 3
                     SET @c_ErrMsg  = ERROR_MESSAGE()
                  END
               END
            END
         END
      END
      ELSE IF @n_Continue = 1
      BEGIN
         SET @c_WaveKey = ''
         SET @c_GenByBuildValue = 'Y'
         EXEC [WM].[lsp_Build_Wave]
           @c_BuildParmKey   = @c_BuildParmKey
         , @c_Facility       = @c_Facility
         , @c_StorerKey      = @c_StorerKey
         , @c_BuildWaveType  = 'BuildWave'
         , @c_GenByBuildValue= @c_GenByBuildValue
         , @c_SQLBuildWave   = @c_SQLBuildWave OUTPUT
         , @n_BatchNo        = 0
         , @b_Success        = @b_Success      OUTPUT
         , @n_err            = @n_err          OUTPUT
         , @c_ErrMsg         = @c_ErrMsg       OUTPUT
         , @c_UserName       = @c_UserName
         , @dt_Date_Fr       = @dt_Date_Fr
         , @dt_Date_To       = @dt_Date_To
         , @c_WaveKey        = @c_WaveKey

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
         END


         IF @n_Continue = 1
         BEGIN
            UPDATE #TMP_ORD
               SET WaveKey = WD.WaveKey
            FROM #TMP_ORD T
            JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.Orderkey = T.Orderkey
         END

         SET @c_Wavekey = ''
         WHILE @n_Continue = 1
         BEGIN
            SELECT TOP 1
                  @c_Wavekey = T.Wavekey
            FROM #TMP_ORD T
            WHERE T.WaveKey > @c_Wavekey
            ORDER BY T.Wavekey

            SET @n_Cnt = @@ROWCOUNT

            IF @n_Cnt = 0
            BEGIN
               BREAK
            END

            EXEC [WM].[lsp_WaveGenLoadPlan]
                  @c_WaveKey           = @c_WaveKey
               ,  @b_Success           = @b_Success  OUTPUT
               ,  @n_err               = @n_err      OUTPUT
               ,  @c_ErrMsg            = @c_ErrMsg   OUTPUT
               ,  @c_UserName          = @c_UserName
               ,  @b_PopupWindow       = @b_PopupWindow     OUTPUT
               ,  @n_NoOfOrderNoLoad   = @n_NoOfOrderNoLoad OUTPUT
               ,  @c_BuildParmKeys     = 'DEVEM_LP'

            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3
            END

            IF @n_Continue = 1
            BEGIN
               EXEC [WM].[lsp_WaveGenMBOL]
                  @c_WaveKey  = @c_WaveKey
               ,  @b_Success  = @b_Success  OUTPUT
               ,  @n_err      = @n_err      OUTPUT
               ,  @c_ErrMsg   = @c_ErrMsg   OUTPUT
               ,  @c_UserName = @c_UserName

               IF @b_Success = 0
               BEGIN
                  SET @n_Continue = 3
               END
            END

            IF @n_Continue = 1
            BEGIN
               UPDATE MBOL WITH (ROWLOCK)
               SET MBOL.ExternMbolKey = @c_WaveKey,
                   MBOL.TrafficCop = NULL
               FROM MBOL
               INNER JOIN MBOLDETAIL ON MBOL.MBOLKey = MBOLDETAIL.MBOLKey
               INNER JOIN WaveDetail ON WaveDetail.OrderKey = MBOLDETAIL.OrderKey
               WHERE WaveDetail.WaveKey = @c_WaveKey

               IF @@ERROR <> 0
               BEGIN
                  SET @n_Continue = 3
                  SET @c_ErrMsg  = ERROR_MESSAGE()
               END
            END
         END
      END
   QUIT_SP:
      IF @n_continue = 3
      BEGIN
         SET @b_Success = 0
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
         RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
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
