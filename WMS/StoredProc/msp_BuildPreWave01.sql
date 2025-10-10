SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: msp_BuildPreWave01                                  */
/* Creation Date: 10-Oct-2025                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-7724 USA - Maersk WMS v2 - Levis - Prewave               */
/*                                                                       */
/* Called By: WM.lsp_BuildPreWave                                        */
/*                                                                       */
/* GitHub Version: 1.0                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author  Ver.  Purposes                                   */
/* 10-Oct-2025  WLChooi 1.0   Initial Version                            */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[msp_BuildPreWave01]
   @c_BuildParmKey         NVARCHAR(10)
 , @c_Facility             NVARCHAR(5)
 , @c_Storerkey            NVARCHAR(15)
 , @c_SQLBuildWaveWhere    NVARCHAR(MAX)
 , @c_FieldLabel01         NVARCHAR(50)   OUTPUT
 , @c_FieldLabel02         NVARCHAR(50)   OUTPUT
 , @c_FieldLabel03         NVARCHAR(50)   OUTPUT
 , @c_FieldLabel04         NVARCHAR(50)   OUTPUT
 , @c_FieldLabel05         NVARCHAR(50)   OUTPUT
 , @b_Success              INT            OUTPUT
 , @n_Err                  INT            OUTPUT
 , @c_Errmsg               NVARCHAR(225)  OUTPUT
 , @b_Debug                INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue  INT
         , @n_starttcnt INT

   DECLARE @c_Orderkey                 NVARCHAR(10) = ''
         , @n_MPOCReqFlag              INT = 0
         , @n_LoopCount                INT = 0
         , @c_PreWaveNo                NVARCHAR(10) = ''
         , @n_MPOCFlag                 INT = 0
         , @CUR_MPOC                   CURSOR
         , @n_NoOfChute                INT = 0
         , @n_NoOfPutwall              INT = 0
         , @n_PutwallMinQty            INT = 0
         , @n_PutwallMaxQty            INT = 0
         , @n_NoOfChuteMin             INT = 0
         , @n_NoOfChuteMax             INT = 0
         , @n_NoOfPutwallMin           INT = 0
         , @n_NoOfPutwallMax           INT = 0
         , @n_PutwallCount             INT = 0
         , @n_ChuteCount               INT = 0
         , @n_MaxOpenQty               INT = 0
         , @c_SQL                      NVARCHAR(MAX)
         , @c_SQLParms                 NVARCHAR(MAX)
         , @c_CartonGroup              NVARCHAR(10)
         , @n_CartonMaxCube            DECIMAL(15,7)
         , @c_WCSPack                  NVARCHAR(10)

   DECLARE @n_BuildGroupCnt            INT            = 0
         , @n_BuildGroupCntRev         INT            = 5
         , @c_ParmBuildType            NVARCHAR(10)   = ''
         , @c_FieldName                NVARCHAR(100)  = ''
         , @c_FieldLabel               NVARCHAR(50)   = ''
         , @c_Operator                 NVARCHAR(60)   = ''
         , @c_TableName                NVARCHAR(30)   = ''
         , @c_ColName                  NVARCHAR(100)  = ''
         , @c_ColType                  NVARCHAR(128)  = ''
         , @c_Field01                  NVARCHAR(60)   = ''
         , @c_Field02                  NVARCHAR(60)   = ''
         , @c_Field03                  NVARCHAR(60)   = ''
         , @c_Field04                  NVARCHAR(60)   = ''
         , @c_Field05                  NVARCHAR(60)   = ''
         , @c_Field06                  NVARCHAR(60)   = ''
         , @c_Field07                  NVARCHAR(60)   = ''
         , @c_Field08                  NVARCHAR(60)   = ''
         , @c_Field09                  NVARCHAR(60)   = ''
         , @c_Field10                  NVARCHAR(60)   = ''
         , @c_FieldLabel06             NVARCHAR(50)   = ''
         , @c_FieldLabel07             NVARCHAR(50)   = ''
         , @c_FieldLabel08             NVARCHAR(50)   = ''
         , @c_FieldLabel09             NVARCHAR(50)   = ''
         , @c_FieldLabel10             NVARCHAR(50)   = ''
         , @c_OriSQLField              NVARCHAR(2000) = ''
         , @c_SQLField                 NVARCHAR(2000) = ''
         , @c_SQLFieldGroupBy          NVARCHAR(2000) = ''
         , @c_SQLBuildByGroup          NVARCHAR(4000) = ''
         , @c_SQLBuildByGroupWhere     NVARCHAR(4000) = ''
         , @CUR_BUILD_GROUP            CURSOR

   SET @b_debug = ISNULL(@b_Debug, 0)
   --@b_debug = 1 - Show debug message and do not update Notes2
   --@b_debug = 2 - Show debug message and update Notes2

   SELECT @n_Continue = 1
        , @b_Success = 1
        , @n_starttcnt = @@TRANCOUNT
        , @c_Errmsg = ''
        , @n_Err = 0

   --Initialize Data & Validation
   IF @n_Continue IN (1,2)
   BEGIN
      SET @n_NoOfChute = 0
      SET @n_NoOfPutwall = 0
      SET @n_MaxOpenQty = 0
      SET @c_CartonGroup = ''
      SET @n_CartonMaxCube = 0.00

      IF NOT EXISTS ( SELECT 1
                      FROM dbo.BUILDPARM BP WITH (NOLOCK)
                      WHERE BP.BuildParmKey = @c_BuildParmKey )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64000
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': BuildParmKey#: ' + @c_BuildParmKey + 'is invalid. (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END

      SELECT @c_CartonGroup = CartonGroup
      FROM dbo.STORER (NOLOCK)
      WHERE Storerkey = @c_Storerkey

      SELECT TOP 1 @n_CartonMaxCube = CASE WHEN ISNULL(CZ.[Cube], 0) = 0 
                                           THEN ISNULL(CZ.CartonLength, 0) * ISNULL(CZ.CartonWidth, 0) * ISNULL(CZ.CartonHeight, 0)
                                           ELSE CZ.Cube END
      FROM dbo.CARTONIZATION CZ (NOLOCK)
      WHERE CartonizationGroup = @c_CartonGroup 
      AND CartonType <> '9999'
      ORDER BY CASE WHEN ISNULL(CZ.[Cube], 0) = 0 
                    THEN ISNULL(CZ.CartonLength, 0) * ISNULL(CZ.CartonWidth, 0) * ISNULL(CZ.CartonHeight, 0)
                    ELSE CZ.Cube END DESC

      IF ISNULL(@n_CartonMaxCube, 0.00) = 0.00
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64001
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Unable to get Carton info for CartonizationGroup: ' 
                          + @c_CartonGroup + ' (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END

      ;WITH CTEBuildParm AS (
          SELECT BuildParmKey = BP.BuildParmKey
               , Restriction = TRIM(v.Restriction)
               , RestrictionBuildValue = v.RestrictionBuildValue
          FROM BUILDPARM BP WITH (NOLOCK)
          CROSS APPLY (VALUES
              (BP.Restriction01, BP.RestrictionBuildValue01),
              (BP.Restriction02, BP.RestrictionBuildValue02),
              (BP.Restriction03, BP.RestrictionBuildValue03),
              (BP.Restriction04, BP.RestrictionBuildValue04),
              (BP.Restriction05, BP.RestrictionBuildValue05)
          ) v(Restriction, RestrictionBuildValue)
          WHERE BP.BuildParmKey = @c_BuildParmKey
      )
      SELECT @n_NoOfChute   = MAX(CASE WHEN Restriction LIKE '%NoOfChute%' THEN RestrictionBuildValue ELSE 0 END)
           , @n_NoOfPutwall = MAX(CASE WHEN Restriction LIKE '%NoOfPutwall%' THEN RestrictionBuildValue ELSE 0 END)
           , @n_MaxOpenQty  = MAX(CASE WHEN Restriction = '2_MaxQtyPerBuild' THEN RestrictionBuildValue ELSE 0 END)
      FROM CTEBuildParm

      IF ISNULL(@n_NoOfChute, 0) = 0
         SET @n_NoOfChute = 99999

      IF ISNULL(@n_NoOfPutwall, 0) = 0
         SET @n_NoOfPutwall = 99999
   END
   
   IF @n_Continue IN (1,2)
   BEGIN
      SELECT @n_NoOfChuteMin     = ISNULL(MAX(CASE WHEN CL.Code = 'Chute' THEN ISNULL(TRY_CAST(CL.Short AS INT), 0) ELSE 0 END), 0)
           , @n_NoOfChuteMax     = ISNULL(MAX(CASE WHEN CL.Code = 'Chute' THEN ISNULL(TRY_CAST(CL.Long AS INT), 0) ELSE 0 END), 0)
           , @n_NoOfPutwallMin   = ISNULL(MAX(CASE WHEN CL.Code = 'Putwall' THEN ISNULL(TRY_CAST(CL.Short AS INT), 0) ELSE 0 END), 0) 
           , @n_NoOfPutwallMax   = ISNULL(MAX(CASE WHEN CL.Code = 'Putwall' THEN ISNULL(TRY_CAST(CL.Long AS INT), 0) ELSE 0 END), 0)
           , @n_PutwallMinQty    = ISNULL(MAX(CASE WHEN CL.Code = 'Putwall' THEN ISNULL(TRY_CAST(CL.UDF01 AS INT), 0) ELSE 0 END), 0) 
           , @n_PutwallMaxQty    = ISNULL(MAX(CASE WHEN CL.Code = 'Putwall' THEN ISNULL(TRY_CAST(CL.UDF02 AS INT), 0) ELSE 0 END), 0) 
      FROM CODELKUP CL WITH (NOLOCK)
      WHERE CL.LISTNAME = 'PWAVRESVAL'
      AND CL.Code IN ('Chute', 'Putwall')
      AND CL.Storerkey = @c_Storerkey

      IF NOT (@n_NoOfChute BETWEEN @n_NoOfChuteMin AND @n_NoOfChuteMax)
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64002
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': No of Chutes must be between ' + CAST(@n_NoOfChuteMin AS NVARCHAR) 
                          + N' AND ' + CAST(@n_NoOfChuteMax AS NVARCHAR) + '.'
                          + N' Current: ' + CAST(@n_NoOfChute AS NVARCHAR)
                          + N' - Codelkup.Listname = PWAVRESVAL. (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END
   
      IF NOT (@n_NoOfPutwall BETWEEN @n_NoOfPutwallMin AND @n_NoOfPutwallMax)
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64003
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': No of Putwalls must be between ' + CAST(@n_NoOfPutwallMin AS NVARCHAR) 
                          + N' AND ' + CAST(@n_NoOfPutwallMax AS NVARCHAR) + '.'
                          + N' Current: ' + CAST(@n_NoOfPutwall AS NVARCHAR)
                          + N' - Codelkup.Listname = PWAVRESVAL. (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END
   END

   IF @n_Continue IN (1,2)
   BEGIN
      CREATE TABLE #T_ORDERPOOL ( Orderkey  NVARCHAR(10) PRIMARY KEY )

      CREATE TABLE #T_ORDERS ( Orderkey     NVARCHAR(10) PRIMARY KEY
                             , Consigneekey NVARCHAR(15)
                             , BuyerPO      NVARCHAR(20) NULL
                             , SKUCount     INT NULL
                             , UDF01        NVARCHAR(1) DEFAULT 'N'
                             , MPOC         NVARCHAR(1) DEFAULT 'N'
                             , VCCount      INT DEFAULT 1
                             , VCCountCS    INT DEFAULT 1 
                             , PreWaveNo    NVARCHAR(10) NULL
                             , RNo          INT DEFAULT 0
                             , PutwallUsage INT DEFAULT 0
                             , ChuteUsage   INT DEFAULT 0
                             )
      
      CREATE TABLE #T_ORDERDET  ( Orderkey         NVARCHAR(10)
                                , OrderLineNumber  NVARCHAR(5)
                                , Storerkey        NVARCHAR(15)
                                , SKU              NVARCHAR(20)
                                , Qty              INT
                                , StdCube          DECIMAL(15, 7)
                                , WCS              INT DEFAULT(0)
                                , CartonNumber     INT DEFAULT(0)
                                , PRIMARY KEY (Orderkey, OrderLineNumber)
                                )

      CREATE TABLE #T_ORDERSUMQTY ( Orderkey       NVARCHAR(10) PRIMARY KEY
                                  , TotalQty       INT
                                  )

      DECLARE @T_WCSPackReq AS TABLE ( WODType     NVARCHAR(50)
                                     , SKUPerVC    INT
                                     , ActiveFlag  NVARCHAR(10) DEFAULT 'N' 
                                     )

      DECLARE @T_MPOCPERMIT AS TABLE ( Code        NVARCHAR(50)
                                     , UDF01       NVARCHAR(10) 
                                     )

      CREATE TABLE #T_PREWAVE ( PreWaveNo      NVARCHAR(10)
                              , Orderkey       NVARCHAR(10)
                              , Notes2         NVARCHAR(MAX)
                              , RowID          INT IDENTITY(1,1) PRIMARY KEY
                              )
      CREATE INDEX IDX_T_PREWAVE_Order ON #T_PREWAVE (Orderkey)

      CREATE TABLE #ORDER_OPTIMIZATION_INPUT
      (
         RowID    INT IDENTITY(1, 1) PRIMARY KEY
       , Orderkey NVARCHAR(10)
      )
      CREATE TABLE #ORDER_OPTIMIZATION_OUTPUT
      (
         RowID    INT IDENTITY(1, 1) PRIMARY KEY
       , Orderkey NVARCHAR(10)
       , Rating   DECIMAL(20, 2)
      )
   END

   WHILE @@TRANCOUNT > 0
      COMMIT TRAN

   IF @n_Continue IN (1,2)
   BEGIN
      --Build SELECT statement to insert Order pool
      SET @c_SQL = N' SELECT ORDERS.Orderkey ' + @c_SQLBuildWaveWhere + N' GROUP BY ORDERS.Orderkey '
                 + N' OPTION (RECOMPILE)'
      SET @c_SQLParms = N'  @c_BuildParmKey NVARCHAR(10), @c_StorerKey NVARCHAR(15) '
                      + N', @c_Facility NVARCHAR(5), @n_MaxOpenQty INT'
      BEGIN TRY
         INSERT INTO #T_ORDERPOOL (Orderkey)
         EXEC SP_EXECUTESQL @c_SQL 
                          , @c_SQLParms
                          , @c_BuildParmKey
                          , @c_StorerKey
                          , @c_Facility                                                                                          
                          , @n_MaxOpenQty
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3    
         SET @c_ErrMsg = ERROR_MESSAGE()
         GOTO QUIT_SP  
      END CATCH

      --Validate MPOC - START
      --UDF01 = N, MPOCFlag > 0 (MPOC for manual only)
      --UDF01 = N, MPOCFlag = 0 (Non MPOC)
      --UDF01 = Y, MPOCFlag > 0 (MPOC for Automation and manual)
      --UDF01 = Y, MPOCFlag = 0 (Non MPOC)

      INSERT @T_MPOCPERMIT (Code, UDF01)
      SELECT DISTINCT CL.Code, CL.UDF01
      FROM CODELKUP CL WITH (NOLOCK)
      WHERE CL.LISTNAME = 'MPOCPERMIT'
      AND CL.Storerkey = @c_Storerkey

      INSERT INTO #T_ORDERS ( Orderkey, Consigneekey, BuyerPO, UDF01, MPOC         
                            , VCCount, VCCountCS
                            )
      SELECT DISTINCT OH.Orderkey
                    , OH.Consigneekey
                    , ISNULL(TRIM(OH.BuyerPO), '')
                    , CASE WHEN ISNULL(CL1.Code, '') <> '' THEN IIF(CL1.UDF01 = 'Y', 'Y', 'N')   --BillToKey
                           WHEN ISNULL(CL2.Code, '') <> '' THEN IIF(CL2.UDF01 = 'Y', 'Y', 'N')   --ConsigneeKey
                           ELSE 'N' END   --Not set up
                    , MPOC = 'N'
                    , 1   --1 Order 1 Virtual Carton, except some cases which will be catered below
                    , 1
      FROM #T_ORDERPOOL OP WITH (NOLOCK)
      JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey = OP.Orderkey
      LEFT JOIN @T_MPOCPERMIT CL1 ON CL1.Code = OH.BillToKey
      LEFT JOIN @T_MPOCPERMIT CL2 ON CL2.Code = OH.ConsigneeKey
      
      INSERT INTO #T_ORDERDET (Orderkey, OrderLineNumber, Storerkey, SKU, Qty, StdCube)
      SELECT DISTINCT OD.Orderkey
                    , OD.OrderLineNumber
                    , OD.StorerKey
                    , OD.SKU
                    , OD.OriginalQty
                    , OD.OriginalQty * CASE WHEN ISNULL(S.STDCUBE, 0) > 0 
                                            THEN S.STDCUBE 
                                            ELSE (S.[Length] * S.Width * S.Height) END
      FROM #T_ORDERS T WITH (NOLOCK)
      JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = T.Orderkey
      JOIN SKU S (NOLOCK) ON S.StorerKey = OD.StorerKey AND S.Sku = OD.Sku

      INSERT INTO #ORDER_OPTIMIZATION_INPUT (Orderkey)
      SELECT Orderkey
      FROM #T_ORDERS WITH (NOLOCK)

      SET @CUR_MPOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT Orderkey
      FROM #T_ORDERS WITH (NOLOCK)
      ORDER BY Orderkey

      OPEN @CUR_MPOC

      FETCH NEXT FROM @CUR_MPOC INTO @c_Orderkey

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue IN (1,2)
      BEGIN
         SET @n_MPOCFlag = 0
         SET @b_Success = 1
         EXEC dbo.msp_GetMPOCRequired @c_OrderKey = @c_Orderkey -- nvarchar(10)
                                    , @n_MPOCFlag = @n_MPOCFlag OUTPUT -- int
                                    , @b_Success = @b_Success OUTPUT -- int
                                    , @n_Err = @n_Err OUTPUT -- int
                                    , @c_ErrMsg = @c_ErrMsg OUTPUT -- nvarchar(255)
                                    , @b_debug = @b_debug -- int
         
         IF @n_MPOCFlag > 0
         BEGIN
            UPDATE #T_ORDERS
            SET MPOC = 'Y'
            WHERE Orderkey = @c_OrderKey
         END

         FETCH NEXT FROM @CUR_MPOC INTO @c_Orderkey
      END
      CLOSE @CUR_MPOC
      DEALLOCATE @CUR_MPOC

      --Reset OrderInfo.Notes2
      IF @b_Debug <> 1
      BEGIN
         BEGIN TRAN

         BEGIN TRY
            UPDATE OI
            SET Notes2 = ''
              , TrafficCop = NULL
            FROM ORDERINFO OI WITH (NOLOCK)
            JOIN #T_ORDERS T WITH (NOLOCK) ON T.Orderkey = OI.OrderKey
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3
            SET @c_Errmsg = ERROR_MESSAGE()
            GOTO QUIT_SP
         END CATCH

         WHILE @@TRANCOUNT > 0
            COMMIT TRAN
      END
   END

   --Validate MPOC
   IF @n_Continue IN (1,2)
   BEGIN
      --Check if mixed MPOC & non MPOC Orders in a same Prewave
      IF EXISTS ( SELECT 1
                  FROM #T_ORDERS WITH (NOLOCK)
                  HAVING COUNT(DISTINCT MPOC) > 1 )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64004
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Not allow to mix MPOC & non MPOC Orders in a same Prewave. (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END

      --Check MPOC Orders if UDF01 <> Y
      IF EXISTS ( SELECT 1
                  FROM #T_ORDERS WITH (NOLOCK)
                  WHERE UDF01 <> 'Y'
                  AND MPOC = 'Y' )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64005
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': MPOC orders found in wave. Please remove the MPOC orders. (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END

      --If MPOC then set BuyerPO to blank
      IF EXISTS ( SELECT 1
                  FROM #T_ORDERS WITH (NOLOCK)
                  WHERE MPOC = 'Y' )
      BEGIN
         SET @n_MPOCReqFlag = 1

         UPDATE #T_ORDERS
         SET BuyerPO = ''   --MPOC - BuyerPO not needed for grouping/sorting
         WHERE MPOC = 'Y'
      END
   END

   --Check SKUs sortable & conveyable
   IF @n_Continue IN (1,2)
   BEGIN
      SET @c_WCSPack = ''

      SELECT @c_WCSPack = ISNULL(cl.Short,'') 
      FROM CODELKUP cl (NOLOCK)
      WHERE cl.ListName = 'WCSCTNIZE'

      IF @c_WCSPack IN ( '', 'Y' ) -- Full WCS Cartonizartion: Not Setup OR Setup with 'Y'
      BEGIN
         UPDATE #T_ORDERDET
            SET WCS = 1
         FROM #T_ORDERDET os WITH (NOLOCK)
         JOIN SKUInfo si (NOLOCK) ON  si.Storerkey = os.Storerkey
                                  AND si.Sku = os.Sku 
         WHERE si.ExtendedField06 = 'sortable' 
         AND   si.ExtendedField07 = 'conveyable'
      END
      ELSE IF @c_WCSPack = 'N'
      BEGIN
         UPDATE #T_ORDERDET
            SET WCS = 1
         FROM #T_ORDERDET os WITH (NOLOCK)
         JOIN SKUInfo si (NOLOCK) ON  si.Storerkey = os.Storerkey
                                  AND si.Sku = os.Sku 
         WHERE si.ExtendedField06 = 'sortable' 
         AND   si.ExtendedField07 = 'conveyable'
         AND   NOT EXISTS (   SELECT 1 FROM dbo.WorkOrderDetail wod (NOLOCK)
                              WHERE wod.ExternWorkOrderKey = os.Orderkey
                              AND wod.Qty > 0
                           )

         -- WCSPACKREQ type need WCS but with 'WCSCTNIZE' = 'N', this type unable to do
         -- WCS correctly. WCS cartonizaton if all workorder types are not found in 'WCSPACKREQ'
         UPDATE #T_ORDERDET
            SET WCS = 1
         FROM #T_ORDERDET os WITH (NOLOCK)
         JOIN SKUInfo si (NOLOCK) ON  si.Storerkey = os.Storerkey
                                  AND si.Sku = os.Sku 
         WHERE si.ExtendedField06 = 'sortable' 
         AND   si.ExtendedField07 = 'conveyable'
         AND   NOT EXISTS (SELECT 1 FROM dbo.WorkOrderDetail wod (NOLOCK) 
                           JOIN CODELKUP cl (NOLOCK) ON cl.ListName = 'WCSPACKREQ'
                                                    AND cl.Short = wod.[Type]
                           WHERE wod.ExternWorkOrderKey = os.Orderkey
                           AND wod.Qty > 0 ) 
      END
      
      --Prewave not allow non-con, non-sort
      IF EXISTS ( SELECT 1
                  FROM #T_ORDERDET WITH (NOLOCK)
                  WHERE WCS = 0 )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64006
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Prewave cannot be generated for Non-Con/Non-Sort SKUs. (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END
   END

   IF @n_Continue IN (1,2)
   BEGIN
      INSERT @T_WCSPackReq (WODType, SKUPerVC, ActiveFlag)
      SELECT DISTINCT CL.Code, IIF(ISNUMERIC(CL.UDF01) = 1, CL.UDF01, 0), CL.UDF05
      FROM CODELKUP CL WITH (NOLOCK)
      WHERE CL.LISTNAME = 'WCSPackReq'
      AND CL.Storerkey = @c_Storerkey
   END

   --Calculate Virtual Cartons START
   --1 Order 1 Virtual Carton by default
   IF @n_Continue IN (1,2)
   BEGIN
      --Applicable for MPOC orders only
      IF @n_MPOCReqFlag = 1
      BEGIN
         --Calculate MPOC VC Estimation (Existing automation carton estimation logic)
         ;WITH CTE AS ( SELECT T2.Orderkey, TotalCube = SUM(T2.StdCube)
                        FROM #T_ORDERS T1 WITH (NOLOCK)
                        JOIN #T_ORDERDET T2 WITH (NOLOCK) ON T2.Orderkey = T1.Orderkey
                        WHERE T1.MPOC = 'Y'
                        GROUP BY T2.Orderkey )
         UPDATE T3
         SET T3.VCCount = CEILING(CTE.TotalCube / @n_CartonMaxCube)
         FROM #T_ORDERS T3 WITH (NOLOCK)
         JOIN CTE ON CTE.Orderkey = T3.Orderkey

         --Assign MPOC VC based on Qty vs StdCube per CartonMaxCube
         ;WITH OrderedLines AS
         (
            SELECT Orderkey
                 , OrderLineNumber
                 , SKU
                 , Qty
                 , StdCube
                 , ROW_NUMBER() OVER (PARTITION BY Orderkey
                                      ORDER BY OrderLineNumber) AS rn
            FROM #T_ORDERDET WITH (NOLOCK)
         ), CartonAssign AS
         (
            SELECT *
                 -- Running cube up to this line in the order
                 , SUM(StdCube) OVER (PARTITION BY Orderkey
                                      ORDER BY rn
                                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningCube --Cumulative sum
            FROM OrderedLines
         )
         UPDATE T4
         SET T4.CartonNumber = FLOOR((RunningCube - 1) / @n_CartonMaxCube) + 1
         FROM #T_ORDERDET T4 WITH (NOLOCK)
         JOIN CartonAssign C ON C.Orderkey = T4.Orderkey 
                            AND C.OrderLineNumber = T4.OrderLineNumber
      END

      --VAS will overwrite MPOC VC Estimation
      --Calculate Carton for S02, S06, J05 - START
      ;WITH VASCartonNum AS ( SELECT T5.OrderKey
                                   , T5.OrderLineNumber
                                   , Qty = T5.Qty
                                   , VC_RowRef = (ROW_NUMBER() OVER (PARTITION BY T5.OrderKey
                                                                     ORDER BY T5.OrderLineNumber ASC) - 1) / CAST(WODT.SKUPerVC AS INT) + 1
                              FROM #T_ORDERDET T5 WITH (NOLOCK)
                              CROSS APPLY ( SELECT TOP 1 WOD.[Type]
                                                       , W.SKUPerVC
                                            FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
                                            JOIN @T_WCSPackReq W ON W.WODType = WOD.[Type]
                                            WHERE WOD.ExternWorkOrderKey = T5.Orderkey 
                                            AND W.ActiveFlag = 'Y'
                                            ORDER BY WOD.[Type] ) AS WODT )
      UPDATE T6
      SET T6.CartonNumber = C.VC_RowRef
      FROM #T_ORDERDET T6 WITH (NOLOCK)
      JOIN VASCartonNum C ON C.Orderkey = T6.Orderkey 
                         AND C.OrderLineNumber = T6.OrderLineNumber
      
      --Calculate Putwall & Chute Usage
      --If Putwall fully utilized the rest will goes to Chute
      ;WITH CTE2 AS (
         SELECT T7.OrderKey
              , T7.CartonNumber
              , Qty = SUM(T7.Qty)
              , Putwall = IIF(SUM(T7.Qty) BETWEEN @n_PutwallMinQty AND @n_PutwallMaxQty, 1, 0)
              , Chute   = IIF(SUM(T7.Qty) BETWEEN @n_PutwallMinQty AND @n_PutwallMaxQty, 0, 1)
         FROM #T_ORDERDET T7 WITH (NOLOCK)
         GROUP BY T7.OrderKey
                , T7.CartonNumber
      ), CTE3 AS (
         SELECT CTE2.OrderKey
              , VCCount = COUNT(CTE2.CartonNumber)
              , PutwallUsage = CASE WHEN SUM(CTE2.Putwall) > @n_NoOfPutwall
                                    THEN @n_NoOfPutwall
                                    ELSE SUM(CTE2.Putwall) END
              , ChuteUsage = SUM(CTE2.Chute)
                             + CASE WHEN SUM(CTE2.Putwall) > @n_NoOfPutwall 
                                    THEN SUM(CTE2.Putwall) - @n_NoOfPutwall
                                    ELSE 0 END
         FROM CTE2
         GROUP BY OrderKey
      )
      UPDATE T8
      SET T8.VCCount = CTE3.VCCount
        , T8.PutwallUsage = CTE3.PutwallUsage
        , T8.ChuteUsage = CTE3.ChuteUsage
      FROM #T_ORDERS T8 WITH (NOLOCK)
      JOIN CTE3 ON CTE3.Orderkey = T8.Orderkey
      --Calculate Carton for S02, S06, J05 - END

      --Update VCCount by Consigneekey
      ;WITH CS AS ( SELECT Orderkey, VCCount = SUM(VCCount) OVER (PARTITION BY Consigneekey)
                    FROM #T_ORDERS )
      UPDATE T
      SET T.VCCountCS = CS.VCCount
      FROM #T_ORDERS T
      JOIN CS ON CS.Orderkey = T.Orderkey

      --Calculate SKU Density
      INSERT INTO #ORDER_OPTIMIZATION_OUTPUT
      EXEC isp_OrderSimilarify_Optimization

      --Update RNo = Sorting sequence
      UPDATE T                                                                     
         SET T.RNo = o.RNo
      FROM #T_ORDERS T WITH (NOLOCK)
      JOIN  (SELECT toh.Orderkey 
                  , RNo = ROW_NUMBER() OVER 
                           (ORDER BY toh.VCCountCS DESC, toh.Consigneekey, toh.BuyerPO, OOO.RowID, toh.Orderkey)
             FROM #T_ORDERS toh WITH (NOLOCK)
             JOIN #ORDER_OPTIMIZATION_OUTPUT OOO WITH (NOLOCK) ON OOO.Orderkey = toh.Orderkey
                  ) o ON o.Orderkey = t.Orderkey
   END
   --Calculate Virtual Cartons END

   --Main process - START
   IF @n_Continue IN (1,2)
   BEGIN
      --Split Orderkeys into multiple groups by VCCount & Chute/Putwall slots
      SET @n_LoopCount = 0

      --Keep LoopCount = Total Records from #T_ORDERS to prevent infinite loop
      SELECT @n_LoopCount = COUNT(1)
      FROM #T_ORDERS WITH (NOLOCK)
      WHERE PreWaveNo IS NULL

      WHILE EXISTS ( SELECT 1
                     FROM #T_ORDERS WITH (NOLOCK)
                     WHERE PreWaveNo IS NULL ) AND @n_LoopCount > 0
      BEGIN
         SET @c_Orderkey = ''
         SET @c_PreWaveNo = ''

         ;WITH CTE AS ( SELECT Orderkey, VCCount, DENSE_RANK() OVER 
                              (ORDER BY RNo) AS DRank
                            , PutwallUsage
                            , ChuteUsage
                        FROM #T_ORDERS WITH (NOLOCK)
                        WHERE PreWaveNo IS NULL
                      )
         SELECT TOP 1 @c_Orderkey = CTE.Orderkey
                    , @n_PutwallCount = CTE.PutwallUsage
                    , @n_ChuteCount = CTE.ChuteUsage
         FROM CTE
         ORDER BY CTE.DRank, CTE.Orderkey

         --Check if can fulfill existing PreWaveNo
         SELECT @c_PreWaveNo = PreWaveNo
         FROM #T_ORDERS WITH (NOLOCK)
         WHERE (PreWaveNo IS NOT NULL AND PreWaveNo <> '')
         GROUP BY PreWaveNo
         HAVING SUM(PutwallUsage) + @n_PutwallCount <= @n_NoOfPutwall
         AND SUM(ChuteUsage) + @n_ChuteCount <= @n_NoOfChute

         --If existing group cannot fulfill, create a new group (Wave)
         IF ISNULL(@c_PreWaveNo, '') = ''
         BEGIN
            BEGIN TRY
               EXEC dbo.nspg_GetKey @KeyName = N'LVSPreWave'
                                  , @fieldlength = 8
                                  , @keystring = @c_PreWaveNo OUTPUT
                                  , @b_Success = @b_Success OUTPUT
                                  , @n_err = @n_err OUTPUT
                                  , @c_errmsg = @c_errmsg OUTPUT
            END TRY
            BEGIN CATCH
               SET @n_Continue = 3    
               SET @c_ErrMsg = ERROR_MESSAGE()
               GOTO QUIT_SP  
            END CATCH
         END

         --Update the PreWaveNo to #T_ORDERS
         UPDATE #T_ORDERS
         SET PreWaveNo = @c_PreWaveNo
         WHERE Orderkey = @c_Orderkey

         SET @n_LoopCount = @n_LoopCount - 1
      END
      
      --If an order contain Virtual Carton > @n_NoOfPutwall OR @n_NoOfChute
      SET @c_Orderkey = ''
      SELECT TOP 1 @c_Orderkey = T.Orderkey
      FROM #T_ORDERS T WITH (NOLOCK)
      GROUP BY T.Orderkey
      HAVING (SUM(PutwallUsage) > @n_NoOfPutwall) OR (SUM(ChuteUsage) > @n_NoOfChute)

      IF ISNULL(@c_Orderkey, '') <> ''
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64007
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Order# ' + @c_Orderkey + ' has virtual cartons greater than'
                          + N' the configured number of Chutes/Putwalls. (msp_BuildPreWave01)'
         GOTO QUIT_SP
      END

      --Initialize #T_ORDERSUMQTY
      INSERT INTO #T_ORDERSUMQTY (Orderkey, TotalQty)
      SELECT Orderkey, SUM(Qty)
      FROM #T_ORDERDET
      GROUP BY Orderkey

      --Get Notes2 Value BY PreWaveNo
      ;WITH PreWaveCTE AS
      (
         SELECT PreWaveNo
              , Notes2 = T1.PreWaveNo + '*' 
                       + CAST(SUM(T2.TotalQty) AS NVARCHAR) + '*' 
                       + CAST(SUM(T1.ChuteUsage) AS NVARCHAR) + '*' 
                       + CAST(SUM(T1.PutwallUsage) AS NVARCHAR)
         FROM #T_ORDERS T1 WITH (NOLOCK)
         JOIN #T_ORDERSUMQTY T2 WITH (NOLOCK) ON T2.Orderkey = T1.Orderkey
         WHERE T1.PreWaveNo IS NOT NULL
         GROUP BY T1.PreWaveNo
      )
      INSERT INTO #T_PREWAVE (PreWaveNo, Orderkey, Notes2)
      SELECT T1.PreWaveNo
           , T1.Orderkey
           , C.Notes2
      FROM #T_ORDERS T1
      JOIN PreWaveCTE C ON T1.PreWaveNo = C.PreWaveNo;

      --Update Orderinfo.Notes2
      --Also insert Orderinfo with Orderkey, Notes2 if not exists
      IF @b_Debug <> 1
      BEGIN
         BEGIN TRAN

         BEGIN TRY
            MERGE dbo.OrderInfo AS TGT
            USING (  SELECT OrderKey
                          , Notes2
                     FROM #T_PREWAVE ) AS SRC
            ON TGT.OrderKey = SRC.OrderKey
            WHEN MATCHED THEN 
            UPDATE SET TGT.Notes2 = SRC.Notes2
                     , TGT.TrafficCop = NULL
            WHEN NOT MATCHED BY TARGET THEN 
            INSERT (OrderKey, Notes2)
            VALUES (SRC.OrderKey, SRC.Notes2);
         END TRY
         BEGIN CATCH
            SET @n_Continue = 3    
            SET @c_ErrMsg = ERROR_MESSAGE()
            GOTO QUIT_SP  
         END CATCH

         WHILE @@TRANCOUNT > 0
            COMMIT TRAN
      END
   END
   --Main process - END

   IF @b_debug IN (1,2)
   BEGIN
      SELECT Orderkey, VCCount, ChuteUsage, PutwallUsage
      FROM #T_ORDERS WITH (NOLOCK)

      SELECT Orderkey
           , OrderLineNumber
           , Storerkey
           , SKU
           , Qty
           , StdCube
           , WCS
           , CartonNumber 
      FROM #T_ORDERDET WITH (NOLOCK)

      SELECT T2.Orderkey
           , T2.BuyerPO
           , SKUCount = ( SELECT COUNT(DISTINCT T.SKU) 
                          FROM #T_ORDERDET T WITH (NOLOCK) 
                          WHERE T.Orderkey = T2.Orderkey )
           , T2.UDF01
           , T2.MPOC
           , T2.VCCount
           , T2.PreWaveNo
           , T2.Consigneekey
           , T2.VCCountCS
      FROM #T_PREWAVE T1 WITH (NOLOCK)
      JOIN #T_ORDERS T2 WITH (NOLOCK) ON T2.Orderkey = T1.Orderkey
      ORDER BY T1.RowID
   END

   IF @n_Continue IN (1,2)
   BEGIN
      BEGIN TRY
         --------------------------------------------------
         -- Get Pre Wave Grouping Condition
         --------------------------------------------------
         SET @n_BuildGroupCnt = 0
         SET @c_SQLBuildByGroupWhere = ''
         SET @CUR_BUILD_GROUP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT TOP 1   --Only support 1 Column for this process
               b.FieldName
            ,  b.FieldLabel
            ,  b.Operator
            ,  b.[Type]
         FROM  dbo.BUILDPARMPREWAVE AS b WITH (NOLOCK)
         WHERE b.BuildParmKey = @c_BuildParmKey
         AND   b.[Type] IN ('GROUP')
         ORDER BY b.BuildParmPreWaveLineNo
                                                                                                                                                               
         OPEN @CUR_BUILD_GROUP
                                                                                                                                                               
         FETCH NEXT FROM @CUR_BUILD_GROUP INTO @c_FieldName
                                             , @c_FieldLabel
                                             , @c_Operator
                                             , @c_ParmBuildType
         WHILE @@FETCH_STATUS <> -1
         BEGIN
            SET @c_TableName = LEFT(@c_FieldName, CHARINDEX('.', @c_FieldName) - 1)
            SET @c_ColName   = SUBSTRING(@c_FieldName,
                                 CHARINDEX('.', @c_FieldName) + 1, LEN(@c_FieldName) - CHARINDEX('.', @c_FieldName))
                                                                                                                                                               
            SET @c_ColType = ''
            SELECT @c_ColType = DATA_TYPE
            FROM   INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK)
            WHERE  TABLE_NAME = @c_TableName
            AND    COLUMN_NAME = @c_ColName
      
            IF ISNULL(RTRIM(@c_ColType), '') = ''
            BEGIN
               SET @n_Continue = 3
               SET @n_Err     = 64008
               SET @c_ErrMsg  = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                              + ': Invalid Group Column Name: ' + @c_FieldName
                              + ' (msp_BuildPreWave01)'
                              + '|' + @c_FieldName
               GOTO QUIT_SP
            END
      
            IF @c_ParmBuildType = 'GROUP'
            BEGIN
               SET @n_BuildGroupCnt = @n_BuildGroupCnt + 1                      --Fixed counter increase for 'GROUP' only
               IF ISNULL(RTRIM(@c_TableName), '') NOT IN('ORDERS', 'OrderInfo')
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err    = 64009
                  SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                                + ': Grouping Only Allow Refer To Orders/OrderInfo Table''s Fields. Invalid Table: ' + RTRIM(@c_FieldName)
                                + '. (msp_BuildPreWave01)'
                                + '|' + RTRIM(@c_FieldName)
                  GOTO QUIT_SP
               END
      
               IF @c_ColType IN ('float', 'money', 'int', 'decimal', 'numeric', 'tinyint', 'real', 'bigint','text')
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err    = 64010
                  SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(6), @n_Err)
                                + ': Numeric/Text Column Type Is Not Allowed For PreWave Grouping: ' + RTRIM(@c_FieldName)
                                + '. (msp_BuildPreWave01)'
                                + '|' + RTRIM(@c_FieldName)
                  GOTO QUIT_SP
               END
      
               IF @c_ColType IN ('char', 'nvarchar', 'varchar', 'nchar', 'datetime')
               BEGIN
                  IF @c_ColType = 'datetime'
                  BEGIN
                     SET @c_SQLField = @c_SQLField + CHAR(13) +  ', CONVERT(NVARCHAR(10),' + RTRIM(@c_FieldName) + ',112)'
                  END
                  ELSE
                  BEGIN
                     SET @c_SQLField = @c_SQLField + CHAR(13) + ',' + RTRIM(@c_FieldName) 
                  END
      
                  SET @c_SQLBuildByGroupWhere = @c_SQLBuildByGroupWhere 
                                       + CHAR(13) + CASE WHEN @c_ColType = 'datetime'
                                                         THEN ' AND CONVERT(NVARCHAR(10),' + RTRIM(@c_FieldName) + ',112)='   
                                                         ELSE ' AND ' + RTRIM(@c_FieldName) + '='  
                                                         END
                                       + CASE WHEN @n_BuildGroupCnt = 1  THEN '@c_Field01'
                                              WHEN @n_BuildGroupCnt = 2  THEN '@c_Field02'
                                              WHEN @n_BuildGroupCnt = 3  THEN '@c_Field03'
                                              WHEN @n_BuildGroupCnt = 4  THEN '@c_Field04'
                                              WHEN @n_BuildGroupCnt = 5  THEN '@c_Field05'
                                              WHEN @n_BuildGroupCnt = 6  THEN '@c_Field06'
                                              WHEN @n_BuildGroupCnt = 7  THEN '@c_Field07'
                                              WHEN @n_BuildGroupCnt = 8  THEN '@c_Field08'
                                              WHEN @n_BuildGroupCnt = 9  THEN '@c_Field09'
                                              WHEN @n_BuildGroupCnt = 10 THEN '@c_Field10'
                                              END 
                                              
                  IF @n_BuildGroupCnt = 1  SET @c_FieldLabel01 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 2  SET @c_FieldLabel02 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 3  SET @c_FieldLabel03 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 4  SET @c_FieldLabel04 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 5  SET @c_FieldLabel05 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 6  SET @c_FieldLabel06 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 7  SET @c_FieldLabel07 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 8  SET @c_FieldLabel08 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 9  SET @c_FieldLabel09 = @c_FieldLabel
                  IF @n_BuildGroupCnt = 10 SET @c_FieldLabel10 = @c_FieldLabel
      
               END
            END
      
            NEXT_GROUP:
            FETCH NEXT FROM @CUR_BUILD_GROUP INTO @c_FieldName
                                                , @c_FieldLabel
                                                , @c_Operator
                                                , @c_ParmBuildType
         END
         CLOSE @CUR_BUILD_GROUP
         DEALLOCATE @CUR_BUILD_GROUP

         BUILD_WAVE_SQL:
         
         IF @n_BuildGroupCnt > 0
         BEGIN
            SET @c_SQLFieldGroupBy = @c_SQLField
            SET @c_OriSQLField = REPLACE(@c_SQLField, ',', '')

            WHILE @n_BuildGroupCnt < 5
            BEGIN
               SET @n_BuildGroupCntRev = @n_BuildGroupCntRev - 1
               --Split Col1 value to Col2-5
               SET @c_SQLField = @c_SQLField
                               + CHAR(13) 
                               + ', PARSENAME(REPLACE(' + @c_OriSQLField + ', ''*'', ''.''), ' + CAST(@n_BuildGroupCntRev AS NVARCHAR) + ') '
      
               SET @n_BuildGroupCnt = @n_BuildGroupCnt + 1
            END
            
            SET @c_SQLBuildByGroup  = N' SELECT @c_BuildParmKey'
                                    +', COUNT(DISTINCT ORDERS.Orderkey)'
                                    + @c_SQLField
                                    + @c_SQLBuildWaveWhere
                                    + CHAR(13) + ' GROUP BY ORDERS.Storerkey ' + @c_SQLFieldGroupBy
                                    + CHAR(13) + ' ORDER BY ORDERS.Storerkey ' + @c_SQLFieldGroupBy
                                    
            INSERT INTO dbo.BuildPreWave ( BuildParmKey, NoOfOrders
                                          ,Column01, Column02, Column03, Column04, Column05
                                         )
            EXEC SP_EXECUTESQL @c_SQLBuildByGroup 
                  , N'@c_BuildParmKey NVARCHAR(10), @c_StorerKey NVARCHAR(15), @c_Facility NVARCHAR(5) 
                     ,@n_MaxOpenQty INT'
                  , @c_BuildParmKey
                  , @c_StorerKey
                  , @c_Facility
                  , @n_MaxOpenQty 
         END
      END TRY
      BEGIN CATCH
      SELECT @c_SQLField
         SET @n_Continue = 3
         SET @c_Errmsg = ERROR_MESSAGE()
         GOTO QUIT_SP
      END CATCH
   END

   QUIT_SP:

   IF OBJECT_ID('tempdb..#T_ORDERS ','u') IS NOT NULL 
      DROP TABLE #T_ORDERS

   IF OBJECT_ID('tempdb..#T_ORDERDET ','u') IS NOT NULL 
      DROP TABLE #T_ORDERDET

   IF OBJECT_ID('tempdb..#T_ORDERSUMQTY ','u') IS NOT NULL 
      DROP TABLE #T_ORDERSUMQTY

   IF OBJECT_ID('tempdb..#T_PREWAVE ','u') IS NOT NULL 
      DROP TABLE #T_PREWAVE
      
   IF OBJECT_ID('tempdb..#ORDER_OPTIMIZATION_INPUT ','u') IS NOT NULL 
      DROP TABLE #ORDER_OPTIMIZATION_INPUT

   IF OBJECT_ID('tempdb..#ORDER_OPTIMIZATION_INPUT ','u') IS NOT NULL 
      DROP TABLE #ORDER_OPTIMIZATION_INPUT
      
   IF OBJECT_ID('tempdb..#ORDER_OPTIMIZATION_OUTPUT ','u') IS NOT NULL 
      DROP TABLE #ORDER_OPTIMIZATION_OUTPUT

   IF @n_Continue = 3 -- Error Occured - Process And Return      
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'msp_BuildPreWave01'
      RAISERROR(@c_Errmsg, 16, 1) WITH SETERROR -- SQL2012      
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END -- End PROC  
GO