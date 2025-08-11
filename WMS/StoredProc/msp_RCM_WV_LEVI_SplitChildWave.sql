SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: msp_RCM_WV_LEVI_SplitChildWave                      */
/* Creation Date: 24-Mar-2025                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-3450/UWP-31640 LVSUSA-AutomationChildWaves               */
/*                                                                       */
/* Called By: Dynamic RCM                                                */
/*                                                                       */
/* GitHub Version: 1.5                                                   */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author  Ver.  Purposes                                   */
/* 24-Mar-2025  WLChooi 1.0   DevOps Combine Script                      */
/* 01-May-2025  WLChooi 1.1   UWP-31640 Get TOP 1 Workorderdetail Type to*/
/*                            calculate VCCount (WL01)                   */
/* 05-May-2025  SWT01   1.2   Change UDF01 = "Y" instead of "1" FOR      */
/*                            MPOCPERMIT                                 */
/* 04-Jul-2025  WLChooi 1.3   UWP-37271 Performance Tuning (WL02)        */
/* 23-Jul-2025  Wan01   1.4   FCR-4602 - Levi Split wave logic must be   */
/*                            Shipto & buyerpo                           */
/* 25-Jul-2025  WLChooi 1.5   FCR-4602 - Revise the logic of identifying */
/*                            MPOC Orders (WL03)                         */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[msp_RCM_WV_LEVI_SplitChildWave]
   @c_Wavekey NVARCHAR(10)
 , @b_Success INT           OUTPUT
 , @n_Err     INT           OUTPUT
 , @c_Errmsg  NVARCHAR(225) OUTPUT
 , @c_code    NVARCHAR(30) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue  INT
         , @n_starttcnt INT

   DECLARE @c_Storerkey             NVARCHAR(15) = ''
         , @c_WaveUDF09             NVARCHAR(1)  = ''
         , @c_GetWavekey            NVARCHAR(10) = ''
         , @c_Orderkey              NVARCHAR(10) = ''
         , @c_Wavedetailkey         NVARCHAR(10) = ''
         , @c_OrderkeyList          NVARCHAR(MAX)= ''
         , @n_VCCount               INT = 0
         , @n_WCSConfigWaveSize     INT = 0
         , @n_MPOCReqFlag           INT = 0
         , @n_Count                 INT = 1
         , @n_OrdCount              INT = 1
         , @n_TotalCnt              INT = 0
         , @b_debug                 INT = 0
         , @n_GroupCount            INT = 0
         , @n_LoopCount             INT = 0
         , @n_GroupNumber           BIGINT = 0
         , @n_PrevGroupNumber       BIGINT = 0
         , @n_MPOCFlag              INT = 0   --WL03
         , @CUR_MPOC                CURSOR    --WL03

   SET @b_debug = @n_Err
   --@b_debug = 1 - Show debug message and do not split Wave
   --@b_debug = 2 - Show debug message and split into new Wave

   SELECT @n_Continue = 1
        , @b_Success = 1
        , @n_starttcnt = @@TRANCOUNT
        , @c_Errmsg = ''
        , @n_Err = 0

   IF @n_Continue IN (1,2)
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM WAVE WITH (NOLOCK)
                      WHERE Wavekey = @c_Wavekey )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64000
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Wavekey# ' + @c_Wavekey + ' is invalid. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END

      --WL03 S
      --Check if Wave has been split before (UserDefine08 = master Wavekey)
      IF EXISTS ( SELECT 1
                  FROM WAVE WITH (NOLOCK)
                  WHERE Wavekey = @c_Wavekey
                  AND (UserDefine08 IS NOT NULL AND UserDefine08 <> '')
                )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64013
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Wavekey# ' + @c_Wavekey + ' is a child Wave. Not allow to split further. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END
      --WL03 E
   END

   IF @n_Continue IN (1,2)
   BEGIN
      DECLARE @T_ORDERS AS TABLE ( Wavekey      NVARCHAR(10)
                                 , Orderkey     NVARCHAR(10)
                                 , Consigneekey NVARCHAR(15)                        --(Wan01)
                                 , BuyerPO      NVARCHAR(20) NULL
                                 , SKUCount     INT
                                 , UDF01        NVARCHAR(1) DEFAULT 'N'             --WL03
                                 , MPOC         NVARCHAR(1) DEFAULT 'N'
                                 , VCCount      INT DEFAULT 1
                                 , VCCountCS    INT DEFAULT 1                       --(Wan01)
                                 , GroupNumber  INT DEFAULT 0
                                 , RNo          INT DEFAULT 0                       --(Wan01)                                 
                                 )
      
      DECLARE @T_ORDERDET AS TABLE ( Orderkey         NVARCHAR(10)
                                   , OrderLineNumber  NVARCHAR(5)
                                   , SKU              NVARCHAR(20) 
                                   )

      DECLARE @T_WCSPackReq AS TABLE ( WODType     NVARCHAR(50)
                                     , SKUPerVC    INT
                                     , ActiveFlag  NVARCHAR(10) DEFAULT 'N' 
                                     )

      DECLARE @T_MPOCPERMIT AS TABLE ( Code        NVARCHAR(50)
                                     , UDF01       NVARCHAR(10) 
                                     )

      DECLARE @T_WAVEDETAIL AS TABLE ( Wavekey     NVARCHAR(10)
                                     , Orderkey    NVARCHAR(10)
                                     , BuyerPO     NVARCHAR(20)
                                     , VCCount     INT 
                                     )
   END

   IF @n_Continue IN (1,2)
   BEGIN
      SELECT @c_Storerkey = OH.Storerkey
           , @c_WaveUDF09 = W.UserDefine09
      FROM WAVE W WITH (NOLOCK)
      JOIN WAVEDETAIL WD WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
      WHERE W.WaveKey = @c_Wavekey
   END

   --WL03 S
   IF  @n_Continue IN (1,2)
   AND ((ISNULL(@c_WaveUDF09, '') <> 'Y' AND @b_debug IN (1,2)) OR ISNULL(@c_WaveUDF09, '') = 'Y')
   BEGIN
      INSERT @T_MPOCPERMIT (Code, UDF01)
      SELECT DISTINCT CL.Code, CL.UDF01
      FROM CODELKUP CL WITH (NOLOCK)
      WHERE CL.LISTNAME = 'MPOCPERMIT'
      AND CL.Storerkey = @c_Storerkey

      --Validate MPOC - START
      --UDF01 = N, MPOCFlag > 0 (MPOC for manual only)
      --UDF01 = N, MPOCFlag = 0 (Non MPOC)
      --UDF01 = Y, MPOCFlag > 0 (MPOC for Automation and manual)
      --UDF01 = Y, MPOCFlag = 0 (Non MPOC)

      INSERT INTO @T_ORDERS ( Wavekey, Orderkey, Consigneekey, BuyerPO, UDF01, MPOC --(Wan01)                    
                            , VCCount, VCCountCS                                    --(Wan01)  
                            )
      SELECT DISTINCT WD.WaveKey
                    , WD.Orderkey
                    , OH.Consigneekey                                               --(Wan01)
                    , ISNULL(TRIM(OH.BuyerPO), '')
                    --WL03 S
                    , CASE WHEN ISNULL(CL1.Code, '') <> '' THEN IIF(CL1.UDF01 = 'Y', 'Y', 'N')   --BillToKey (SWT01)
                           WHEN ISNULL(CL2.Code, '') <> '' THEN IIF(CL2.UDF01 = 'Y', 'Y', 'N')   --ConsigneeKey (SWT01)
                           ELSE 'N' END   --Not set up
                    , MPOC = 'N'
                    --, CASE WHEN ISNULL(CL1.Code, '') <> '' AND 1 = IIF(CL1.UDF01 = 'Y', 1, 0) THEN 'Y' --BillToKey    --WL01 (SWT01)
                    --       WHEN ISNULL(CL2.Code, '') <> '' AND 1 = IIF(CL2.UDF01 = 'Y', 1, 0) THEN 'Y' --ConsigneeKey --WL01 (SWT01)
                    --       ELSE 'N' END   --Not set up
                    --WL03 E
                    , 1   --1 Order 1 Virtual Carton, except some cases which will be catered below
                    , 1                                                             --(Wan01)
      FROM WAVEDETAIL WD WITH (NOLOCK)
      JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
      LEFT JOIN @T_MPOCPERMIT CL1 ON CL1.Code = OH.BillToKey
      LEFT JOIN @T_MPOCPERMIT CL2 ON CL2.Code = OH.ConsigneeKey
      WHERE WD.WaveKey = @c_Wavekey
      
      INSERT INTO @T_ORDERDET (Orderkey, OrderLineNumber, SKU)
      SELECT DISTINCT OD.Orderkey
                    , OD.OrderLineNumber
                    , OD.SKU
      FROM @T_ORDERS T
      JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = T.Orderkey
      WHERE T.Wavekey = @c_Wavekey

      --WL03 S
      SET @CUR_MPOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT Orderkey
      FROM @T_ORDERS
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
            UPDATE @T_ORDERS
            SET MPOC = 'Y'
            WHERE Orderkey = @c_OrderKey
         END

         FETCH NEXT FROM @CUR_MPOC INTO @c_Orderkey
      END
      CLOSE @CUR_MPOC
      DEALLOCATE @CUR_MPOC
      --WL03 E
   END
   --WL03 E

   --Manual Wave - split all orders to a new Wave
   IF @n_Continue IN (1,2) AND ISNULL(@c_WaveUDF09, '') <> 'Y'
   BEGIN
      --Generate Wavekey
      SELECT @b_Success = 0  
      SET @c_GetWavekey = ''

      --WL03 S
      IF @b_debug IN (1,2)
      BEGIN
         SET @c_GetWavekey = RIGHT(REPLICATE('0', 10) + CAST(@n_Count AS NVARCHAR), 10)
      END
      ELSE
      BEGIN
         EXECUTE nspg_GetKey  
                  'Wavekey',  
                  10,  
                  @c_GetWavekey  OUTPUT,  
                  @b_Success     OUTPUT,  
                  @n_Err         OUTPUT,  
                  @c_Errmsg      OUTPUT  
      END
      --WL03 E

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64001
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Failed to execute nspg_GetKey - Wavekey. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END
      ELSE
      BEGIN
         INSERT INTO @T_WAVEDETAIL (Wavekey, Orderkey, BuyerPO, VCCount)
         SELECT DISTINCT @c_GetWavekey, Orderkey, '', 1
         FROM WAVEDETAIL WITH (NOLOCK)
         WHERE WaveKey = @c_Wavekey
      END

      GOTO WAVE_INSERT
   END

   --Automation Wave - split child Wave
   IF @n_Continue IN (1,2) AND @c_WaveUDF09 = 'Y'
   BEGIN
      INSERT @T_WCSPackReq (WODType, SKUPerVC, ActiveFlag)
      SELECT DISTINCT CL.Code, IIF(ISNUMERIC(CL.UDF01) = 1, CL.UDF01, 0), CL.UDF05
      FROM CODELKUP CL WITH (NOLOCK)
      WHERE CL.LISTNAME = 'WCSPackReq'
      AND CL.Storerkey = @c_Storerkey

      SELECT @n_WCSConfigWaveSize = IIF(ISNUMERIC(CL.Long) = 1, CL.Long, 0)
      FROM CODELKUP CL WITH (NOLOCK)
      WHERE CL.LISTNAME = 'WCSConfigs'
      AND CL.Short = 'WaveSize'
      AND CL.Storerkey = @c_Storerkey
      
      IF ISNULL(@n_WCSConfigWaveSize, 0) = 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64002
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': WCSConfigWaveSize is invalid - Codelkup.Listname = WCSConfigs. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END

      --Check if mixed MPOC & non MPOC Orders in a same master Wave
      IF EXISTS ( SELECT 1
                  FROM @T_ORDERS
                  HAVING COUNT(DISTINCT MPOC) > 1 )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64003
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Not allow to mix MPOC & non MPOC Orders in a same Wave. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END

      --Check MPOC Orders if UDF01 <> Y
      IF EXISTS ( SELECT 1
                  FROM @T_ORDERS
                  WHERE UDF01 <> 'Y'   --WL03
                  AND MPOC = 'Y' )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64004
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': MPOC orders found in wave. Please remove the MPOC orders. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END

      --If MPOC then set BuyerPO to blank
      IF EXISTS ( SELECT 1
                  FROM @T_ORDERS
                  WHERE MPOC = 'Y' )
      BEGIN
         SET @n_MPOCReqFlag = 1

         UPDATE @T_ORDERS
         SET BuyerPO = ''   --MPOC - BuyerPO not needed for grouping/sorting
         WHERE MPOC = 'Y'
      END
      --Validate MPOC - END

      --Validate if master Wave > WCSConfigWaveSize for MPOC - START
      IF (( SELECT COUNT(1) FROM @T_ORDERS ) > @n_WCSConfigWaveSize) AND @n_MPOCReqFlag = 1
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64005
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Virtual Carton count too large. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END
      --Validate if master Wave > WCSConfigWaveSize for MPOC - END
   END

   --Calculate Virtual Cartons for those WCSPackReq - S02, S06, J05 - START
   --1 Order 1 Virtual Carton by default
   IF @n_Continue IN (1,2)
   BEGIN
      --Calculate Carton for S02, S06, J05 - START
      --WL01 S
      ;WITH CTE_VC (Orderkey, VCCount) AS ( SELECT T3.Orderkey, CEILING(COUNT(T3.OrderLineNumber) / CAST(MAX(WODT.SKUPerVC) AS FLOAT))
                                            FROM @T_ORDERS T2
                                            JOIN @T_ORDERDET T3 ON T2.Orderkey = T3.Orderkey
                                            OUTER APPLY (  SELECT TOP 1 WOD.Type
                                                                      , T1.SKUPerVC
                                                           FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
                                                           JOIN @T_WCSPackReq T1 ON T1.WODType = WOD.[Type]
                                                           WHERE WOD.ExternWorkOrderKey = T3.Orderkey 
                                                           AND T1.ActiveFlag = 'Y' ) AS WODT
                                            GROUP BY T3.Orderkey )
      UPDATE @T_ORDERS
      SET T.VCCount = IIF(ISNULL(C.VCCount, 0) = 0, 1, C.VCCount)
      FROM @T_ORDERS T
      JOIN CTE_VC C ON C.Orderkey = T.Orderkey
      --WL01 E
      --Calculate Carton for S02, S06, J05 - END

      UPDATE T                                                                      --(Wan01) - START
         SET T.VCCountCS = cs.VCCount
      FROM @T_ORDERS T
      OUTER APPLY (SELECT VCCount = SUM(toh.VCCount)
                   FROM @T_ORDERS toh
                   WHERE toh.Consigneekey = T.Consigneekey
                  ) cs  
                                                                              
      UPDATE T                                                                     
         SET T.RNo = o.RNo
      FROM @T_ORDERS T  
      JOIN  (SELECT toh.Orderkey 
                  , RNo = ROW_NUMBER() OVER 
                           (ORDER BY toh.VCCountCS DESC, toh.Consigneekey, toh.BuyerPO, toh.Orderkey)
             FROM @T_ORDERS toh
                  ) o ON o.Orderkey = t.Orderkey                                    --(Wan01) - END                  

   END
   --Calculate Virtual Cartons for those WCSPackReq - S02, S06, J05 - END
   
   --Main process - START
   IF @n_Continue IN (1,2)
   BEGIN
      --Split Orderkeys into multiple groups by VCCount & WCSConfigWaveSize
      SET @n_OrdCount = 1
      SET @n_TotalCnt = 0
      SET @n_LoopCount = 0

      --Keep LoopCount = Total Records from @T_ORDERS to prevent infinite loop
      SELECT @n_LoopCount = COUNT(1)
      FROM @T_ORDERS
      WHERE GroupNumber = 0

      WHILE EXISTS ( SELECT 1
                     FROM @T_ORDERS
                     WHERE GroupNumber = 0 ) AND @n_LoopCount > 0
      BEGIN
         SET @c_Orderkey = ''
         SET @n_GroupCount = 0
         SET @n_GroupNumber = 0
         SET @n_VCCount = 0;

         WITH CTE AS ( SELECT Orderkey, VCCount, DENSE_RANK() OVER 
                              (ORDER BY VCCountCS DESC, Consigneekey, BuyerPO) AS DRank  --(Wan01)     
                        FROM @T_ORDERS
                        WHERE GroupNumber = 0
                        )
         SELECT TOP 1 @c_Orderkey = Orderkey
                    , @n_VCCount = CTE.VCCount
         FROM CTE
         ORDER BY CTE.DRank, CTE.Orderkey

         --Check existing group if able to fulfill the Virtual Carton
         SELECT @n_GroupCount = SUM(VCCount)
              , @n_GroupNumber = GroupNumber
         FROM @T_ORDERS
         WHERE GroupNumber > 0
         GROUP BY GroupNumber
         HAVING SUM(VCCount) + @n_VCCount <= @n_WCSConfigWaveSize

         IF ISNULL(@n_GroupCount, 0) = 0
            SET @n_GroupCount = 0

         --If existing group cannot fulfill, create a new group (Wave)
         IF ISNULL(@n_GroupNumber, 0) = 0
         BEGIN
            SELECT @n_GroupNumber = MAX(GroupNumber) + 1
            FROM @T_ORDERS
         END

         --Update the groupNumber to @T_ORDERS
         UPDATE @T_ORDERS
         SET GroupNumber = @n_GroupNumber
         WHERE Orderkey = @c_Orderkey

         SET @n_LoopCount = @n_LoopCount - 1
      END

      --If an order contain Virtual Carton > WCSConfigWaveSize
      IF EXISTS ( SELECT 1
                  FROM @T_ORDERS T
                  GROUP BY T.Orderkey
                  HAVING SUM(VCCount) > @n_WCSConfigWaveSize )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 64006
         SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                          + N': Wave contains an order greater than the configured WCS Wave Size. (msp_RCM_WV_LEVI_SplitChildWave)'
         GOTO EXIT_SP
      END

      IF @b_debug IN (1,2)
      BEGIN
         SELECT GroupNumber
              , VCCount = SUM(VCCount)
         FROM @T_ORDERS
         GROUP BY GroupNumber
      END
      
      DECLARE CUR_MAIN CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT STRING_AGG(CAST(Orderkey AS NVARCHAR(MAX)), ',')
           , SUM(VCCount)
      FROM @T_ORDERS
      GROUP BY GroupNumber          --, BuyerPO                                     --(Wan01)
      ORDER BY GroupNumber, MIN(RNo)--, BuyerPO, 1                                  --(Wan01)

      OPEN CUR_MAIN

      FETCH NEXT FROM CUR_MAIN INTO @c_OrderkeyList, @n_VCCount

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @c_GetWavekey = ''
         
         SELECT TOP 1 @c_GetWavekey = T.Wavekey 
         FROM @T_WAVEDETAIL T
         GROUP BY T.Wavekey
         HAVING SUM(VCCount) + @n_VCCount <= @n_WCSConfigWaveSize
         ORDER BY T.Wavekey
         
         --If cannot get existing Wavekey, split to new Wave
         --Generate Wavekey
         IF ISNULL(@c_GetWavekey, '') = ''
         BEGIN
            IF @b_debug = 1
            BEGIN
               SET @c_GetWavekey = RIGHT(REPLICATE('0', 10) + CAST(@n_Count AS NVARCHAR), 10)
               SET @n_Count = @n_Count + 1
            END
            ELSE
            BEGIN
               SELECT @b_Success = 0  
               SET @c_GetWavekey = ''
               EXECUTE nspg_GetKey  
                        'Wavekey',  
                        10,  
                        @c_GetWavekey  OUTPUT,  
                        @b_Success     OUTPUT,  
                        @n_Err         OUTPUT,  
                        @c_Errmsg      OUTPUT  
         
               IF @n_Err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 64007
                  SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                                   + N': Failed to exec nspg_GetKey - Wavekey. (msp_RCM_WV_LEVI_SplitChildWave)'
                  GOTO EXIT_SP
               END
            END
         END
         
         INSERT INTO @T_WAVEDETAIL (Wavekey, Orderkey, BuyerPO, VCCount)
         SELECT @c_GetWavekey, Orderkey, BuyerPO, VCCount
         FROM @T_ORDERS
         WHERE Orderkey IN ( SELECT TRIM([Value]) 
                             FROM STRING_SPLIT(@c_OrderkeyList, ',') )

         FETCH NEXT FROM CUR_MAIN INTO @c_OrderkeyList, @n_VCCount
      END
      CLOSE CUR_MAIN
      DEALLOCATE CUR_MAIN
   END
   --Main process - END

   WAVE_INSERT:   --WL03
   IF @b_debug IN (1,2)
   BEGIN
      SELECT T1.Wavekey
           , T2.Orderkey
           , T2.BuyerPO
           , SKUCount = ( SELECT COUNT(DISTINCT T.SKU) 
                          FROM @T_ORDERDET T 
                          WHERE T.Orderkey = T2.Orderkey )
           , T2.UDF01
           , T2.MPOC
           , T2.VCCount
           , T2.GroupNumber
           , T2.Consigneekey   --WL03
           , T2.VCCountCS      --WL03
           , Automation = IIF(@c_WaveUDF09 = 'Y', 'Y', 'N')   --WL03
      FROM @T_WAVEDETAIL T1
      JOIN @T_ORDERS T2 ON T2.Orderkey = T1.Orderkey
      ORDER BY T1.Wavekey
   END

   IF @n_Continue IN (1,2) AND @b_debug <> 1
   BEGIN
      DECLARE CUR_WAVEINSERT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT Wavekey, Orderkey
      FROM @T_WAVEDETAIL
      ORDER BY Wavekey, Orderkey

      OPEN CUR_WAVEINSERT

      FETCH NEXT FROM CUR_WAVEINSERT INTO @c_GetWavekey, @c_Orderkey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         --Insert Wave header
         IF NOT EXISTS ( SELECT 1
                         FROM WAVE WITH (NOLOCK)
                         WHERE WaveKey = @c_GetWavekey )
         BEGIN
            BEGIN TRAN   --WL02

            INSERT INTO dbo.WAVE (WaveKey, WaveType, Descr, DispatchPalletPickMethod, DispatchCasePickMethod
                                , DispatchPiecePickMethod, [Status], WaveGenloadflag, GenDynamicPickSlipCode, Strategykey
                                , UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, UserDefine06, UserDefine07
                                , UserDefine08, UserDefine09, UserDefine10, LoadplanGroup, MBOLGroupMethod, BatchNo, TMSStatus
                                , DoorBookStatus, ReplenishStatus, TMReleaseFlag
                                )
            SELECT @c_GetWavekey, WaveType, Descr, DispatchPalletPickMethod, DispatchCasePickMethod
                 , DispatchPiecePickMethod, [Status], WaveGenloadflag, GenDynamicPickSlipCode, Strategykey
                 , UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, UserDefine06, UserDefine07
                 , WaveKey, UserDefine09, UserDefine10, LoadplanGroup, MBOLGroupMethod, BatchNo, TMSStatus
                 , DoorBookStatus, ReplenishStatus, TMReleaseFlag
            FROM WAVE WITH (NOLOCK)
            WHERE WaveKey = @c_Wavekey

            SET @n_Err = @@ERROR
            IF @n_Err <> 0
            BEGIN
               SELECT @n_Continue = 3
               SELECT @n_Err = 64008
               SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                                + N': Failed to Insert Wave. (msp_RCM_WV_LEVI_SplitChildWave)'
               GOTO EXIT_SP
            END

            --WL02 S
            WHILE @@TRANCOUNT > 0
            BEGIN
               COMMIT TRAN
            END
            --WL02 E
         END

         --Populate Wavedetail to the new Wave
         IF EXISTS ( SELECT 1
                     FROM WAVE WITH (NOLOCK)
                     WHERE WaveKey = @c_GetWavekey )
         BEGIN
            BEGIN TRAN   --WL02

            --Delete from existing Wave (Master Wave)
            DELETE FROM WAVEDETAIL WHERE OrderKey = @c_Orderkey

            SET @n_Err = @@ERROR
            IF @n_Err <> 0
            BEGIN  
               SELECT @n_Continue = 3
               SELECT @n_Err = 64009
               SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                                + N': Failed to remove order from master Wave. (msp_RCM_WV_LEVI_SplitChildWave)'
               GOTO EXIT_SP
            END

            --WL02 S
            WHILE @@TRANCOUNT > 0
            BEGIN
               COMMIT TRAN
            END

            BEGIN TRAN
            --WL02 E

            SELECT @b_Success = 0  
            SELECT @c_Wavedetailkey = ''
            EXECUTE nspg_GetKey  
               'WavedetailKey',  
               10,  
               @c_WaveDetailKey  OUTPUT,  
               @b_Success        OUTPUT,  
               @n_Err            OUTPUT,  
               @c_Errmsg         OUTPUT  
                 
            IF @n_Err <> 0
            BEGIN  
               SELECT @n_Continue = 3
               SELECT @n_Err = 64010
               SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                                + N': Failed to exec nspg_GetKey - WavedetailKey. (msp_RCM_WV_LEVI_SplitChildWave)'
               GOTO EXIT_SP
            END
            ELSE
            BEGIN
               INSERT INTO WAVEDETAIL ( Wavedetailkey, Wavekey, Orderkey )  
               VALUES ( @c_Wavedetailkey, @c_GetWavekey, @c_Orderkey)

               SET @n_Err = @@ERROR
               IF @n_Err <> 0
               BEGIN  
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 64011
                  SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                                   + N': Failed to insert WAVEDETAIL. (msp_RCM_WV_LEVI_SplitChildWave)'
                  GOTO EXIT_SP
               END
            END

            --WL02 S
            WHILE @@TRANCOUNT > 0
            BEGIN
               COMMIT TRAN
            END
            --WL02 E
         END

         FETCH NEXT FROM CUR_WAVEINSERT INTO @c_GetWavekey, @c_Orderkey
      END
      CLOSE CUR_WAVEINSERT
      DEALLOCATE CUR_WAVEINSERT
   END

   --Delete the master Wave
   IF @n_Continue IN (1,2)
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM WAVEDETAIL WITH (NOLOCK)
                      WHERE Wavekey = @c_Wavekey )
      BEGIN
         BEGIN TRAN   --WL02

         DELETE FROM dbo.WAVE
         WHERE WaveKey = @c_Wavekey

         SET @n_Err = @@ERROR
         IF @n_Err <> 0
         BEGIN  
            SELECT @n_Continue = 3
            SELECT @n_Err = 64012
            SELECT @c_Errmsg = N'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                             + N': Failed to delete the master Wave. (msp_RCM_WV_LEVI_SplitChildWave)'
            GOTO EXIT_SP
         END

         --WL02 S
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
         --WL02 E
      END
   END

   EXIT_SP:

   IF CURSOR_STATUS('LOCAL', 'CUR_MAIN') IN (0 , 1)
   BEGIN
      CLOSE CUR_MAIN
      DEALLOCATE CUR_MAIN   
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_WAVEINSERT') IN (0 , 1)
   BEGIN
      CLOSE CUR_WAVEINSERT
      DEALLOCATE CUR_WAVEINSERT   
   END

   --WL02 S
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
   --WL02 E

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
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'msp_RCM_WV_LEVI_SplitChildWave'
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
END -- End PROC  
GO
