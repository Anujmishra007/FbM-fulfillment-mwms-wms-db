SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_RPT_LP_PLISTN_054_ECOM                              */
/* Creation Date: 01-Aug-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-23223 - [TW] ADS WM Report PLISTN_NEW                   */
/*        :                                                             */
/* Called By: RPT_LP_PLISTN_054_ECOM                                    */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 01-Aug-2023  WLChooi   1.0 DevOps Combine Script                     */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_LP_PLISTN_054_ECOM]
(@c_Loadkey NVARCHAR(10), @c_PreGenRptData NVARCHAR(10) = '')
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_PickheaderKey   NVARCHAR(10)
         , @c_PickSlipNo      NVARCHAR(10)
         , @c_PrintedFlag     NVARCHAR(1)
         , @n_continue        INT
         , @c_errmsg          NVARCHAR(255)
         , @b_success         INT
         , @n_err             INT

         --ORDERS Table  
         , @c_Orderkey        NVARCHAR(10)  = N''
         , @c_Externorderkey  NVARCHAR(30)  = N''
         , @d_DeliveryDate    DATETIME
         , @c_Contact1        NVARCHAR(30)  = N''
         , @c_Storerkey       NVARCHAR(15)  = N''
         , @dt_OrderDate      DATETIME

         --ORDERDETAIL Table
         , @c_Notes           NVARCHAR(60)  = N''

         --OrderInfo Table         
         , @c_Platform        NVARCHAR(20)  = N''

         --Pickdetail Table
         , @c_sku             NVARCHAR(20)  = N''
         , @c_loc             NVARCHAR(10)  = N''
         , @n_qty             INT           = 0

         --Sku Table
         , @c_AltSKU          NVARCHAR(50)  = N''
         , @c_Style           NVARCHAR(50)  = N''
         , @c_Size            NVARCHAR(50) = N''

         --Codelkup
         , @c_UDF01           NVARCHAR(60)  = N''
         , @c_UOM             NVARCHAR(10)  = N''
         , @c_ID              NVARCHAR(18)  = N''
         , @c_Logicalloc      NVARCHAR(18)  = N''
         , @c_firsttime       NVARCHAR(1)   = N''
         , @c_ECOMFlag        NVARCHAR(10)  = N''
         , @n_MaxRec          INT           = 1
         , @n_CurrentRec      INT           = 1
         , @n_MaxLineno       INT           = 10
         , @c_RptLogo         NVARCHAR(255) = N''

         , @c_Notice          NVARCHAR(MAX) = N''
         , @c_Reminder        NVARCHAR(MAX) = N''
         , @c_QR1             NVARCHAR(255) = N''
         , @c_QR2             NVARCHAR(255) = N''
         , @c_QR1_DESCR       NVARCHAR(500) = N''
         , @c_QR2_DESCR       NVARCHAR(500) = N''
         , @n_NoticeArrSize   INT
         , @n_ReminderArrSize INT

   DECLARE @n_PS_required INT
         , @c_NextNo      NVARCHAR(10)

   CREATE TABLE #temp_pick
   (
      rowid           INT          NOT NULL IDENTITY(1, 1) PRIMARY KEY
    , OrderKey        NVARCHAR(10)
    , ExternOrderKey  NVARCHAR(50)
    , PickSlipNo      NVARCHAR(10) NULL
    , [Platform]      NVARCHAR(20)
    , DeliveryDate    DATETIME
    , C_Contact1      NVARCHAR(30)
    , Loc             NVARCHAR(10)
    , Style           NVARCHAR(50)
    , AltSKU          NVARCHAR(50)
    , ODNotes         NVARCHAR(250)
    , Qty             INT
    , UDF01           NVARCHAR(60)
    , PrintedFlag     NVARCHAR(1)
    , Loadkey         NVARCHAR(10)
    , OrderDate       DATETIME
    , Size            NVARCHAR(50)
   )

   SET @n_continue = 1
   SET @c_PreGenRptData = IIF(@c_PreGenRptData = 'Y', 'Y', '')

   SELECT @c_ECOMFlag = TRIM(ISNULL(OH.Type, ''))
        , @c_Storerkey = OH.StorerKey
        , @c_Platform = OIF.[Platform]
   FROM LOADPLANDETAIL LPD (NOLOCK)
   JOIN ORDERS OH (NOLOCK) ON LPD.OrderKey = OH.OrderKey
   LEFT JOIN ORDERINFO OIF (NOLOCK) ON OH.OrderKey = OIF.OrderKey
   WHERE LPD.LoadKey = @c_Loadkey

   SELECT @c_RptLogo = ISNULL(CLR.Long, '')
        , @c_QR1 = ISNULL(CLR.UDF01, '')
        , @c_QR2 = ISNULL(CLR.UDF02, '')
        , @c_QR1_DESCR = ISNULL(CLR.UDF03, '')
        , @c_QR2_DESCR = ISNULL(CLR.UDF04, '')
   FROM CODELKUP CLR WITH (NOLOCK)
   WHERE CLR.LISTNAME = 'RPTLOGO' 
   AND CLR.Storerkey = @c_Storerkey
   AND CLR.Code = @c_Platform

   SELECT @c_Notice =  COALESCE(@c_Notice + '@@@' + Notes, Notes)
   FROM CODELKUP (NOLOCK)
   WHERE LISTNAME = 'REPORTCFG'
   AND Storerkey = @c_Storerkey
   AND Code = @c_Platform
   AND Short = 'NOTICE'
   ORDER BY Code2

   SELECT @n_NoticeArrSize = COUNT(1)
   FROM dbo.fnc_DelimSplit('@@@',@c_Notice) FDS
   WHERE FDS.ColValue <> ''

   SELECT @c_Reminder = COALESCE(@c_Reminder + '@@@' + Notes, Notes)
   FROM CODELKUP (NOLOCK)
   WHERE LISTNAME = 'REPORTCFG'
   AND Storerkey = @c_Storerkey
   AND Code = @c_Platform
   AND Short = 'REMINDER'
   ORDER BY Code2
   
   SELECT @n_ReminderArrSize = COUNT(1)
   FROM dbo.fnc_DelimSplit('@@@',@c_Reminder) FDS
   WHERE FDS.ColValue <> ''

   IF (@c_ECOMFlag <> 'ECOM')
      GOTO QUIT_RESULT

   -- Use Zone as a UOM Picked 1 - Pallet, 2 - Case, 6 - Each, 8 - By Order  
   IF EXISTS (  SELECT 1
                FROM PICKHEADER (NOLOCK)
                WHERE ExternOrderKey = @c_Loadkey AND Zone = '3')
   BEGIN
      SET @c_firsttime = N'N'
      SET @c_PrintedFlag = N'Y'
   END
   ELSE
   BEGIN
      SET @c_firsttime = N'Y'
      SET @c_PrintedFlag = N'N'
   END -- Record Not Exists  

   IF @c_PreGenRptData = 'Y'
   BEGIN
      BEGIN TRAN
      -- Uses PickType as a Printed Flag  
      UPDATE PICKHEADER WITH (ROWLOCK)
      SET PickType = '1'
        , TrafficCop = NULL
      WHERE ExternOrderKey = @c_Loadkey AND Zone = '3' AND PickType = '0'

      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         IF @@TRANCOUNT >= 1
         BEGIN
            ROLLBACK TRAN
            GOTO FAILURE
         END
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END
         ELSE
         BEGIN
            SET @n_continue = 3
            ROLLBACK TRAN
            GOTO FAILURE
         END
      END
   END

   DECLARE CUR_PICK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PICKDETAIL.OrderKey
        , PICKDETAIL.Storerkey
        , PICKDETAIL.Sku
        , PICKDETAIL.Loc
        , PICKDETAIL.UOM
        , PICKDETAIL.ID
        , SUM(PICKDETAIL.Qty)
        , LOC.LogicalLocation
   FROM PICKDETAIL WITH (NOLOCK)
   JOIN LoadPlanDetail WITH (NOLOCK) ON (PICKDETAIL.OrderKey = LoadPlanDetail.OrderKey)
   JOIN LOC WITH (NOLOCK) ON (LOC.Loc = PICKDETAIL.Loc)
   WHERE LoadPlanDetail.LoadKey = @c_Loadkey
   GROUP BY PICKDETAIL.OrderKey
          , PICKDETAIL.Storerkey
          , PICKDETAIL.Sku
          , PICKDETAIL.Loc
          , PICKDETAIL.UOM
          , PICKDETAIL.ID
          , LOC.LogicalLocation
   ORDER BY PICKDETAIL.OrderKey
          , PICKDETAIL.Loc

   OPEN CUR_PICK

   FETCH NEXT FROM CUR_PICK
   INTO @c_Orderkey
      , @c_StorerKey
      , @c_sku
      , @c_loc
      , @c_UOM
      , @c_ID
      , @n_qty
      , @c_Logicalloc

   WHILE (@@FETCH_STATUS <> -1)
   BEGIN
      IF @c_Orderkey = ''
      BEGIN
         SET @c_Externorderkey = N''
         SET @c_Contact1 = N''
         SET @c_Notes = N''
         SET @c_Platform = N''
         SET @c_UDF01 = N''
      END
      ELSE
      BEGIN
         SELECT @c_Externorderkey = OrderInfo.ECOMOrderID
              , @d_DeliveryDate = ORDERS.EditDate
              , @c_Contact1 = ORDERS.C_contact1
              , @c_Platform = ISNULL(CL.UDF01, '')
              , @c_UDF01 = ISNULL(C1.UDF01, '')
              , @dt_OrderDate = ORDERS.OrderDate
         FROM ORDERS WITH (NOLOCK)
         JOIN OrderInfo WITH (NOLOCK) ON OrderInfo.OrderKey = ORDERS.OrderKey
         LEFT JOIN CODELKUP CL WITH (NOLOCK) ON  CL.Storerkey = ORDERS.StorerKey
                                             AND CL.LISTNAME = 'PLATFORM'
                                             AND CL.Code = OrderInfo.[Platform]
         LEFT JOIN CODELKUP C1 WITH (NOLOCK) ON  C1.Storerkey = ORDERS.StorerKey
                                             AND C1.LISTNAME = 'ECDLMODE'
                                             AND C1.Code = ORDERS.ShipperKey
         WHERE ORDERS.OrderKey = @c_Orderkey
      END -- IF @c_Orderkey = ''  

      SELECT @c_AltSKU = TRIM(ISNULL(SKU.AltSKU, ''))
           , @c_sku = SKU.Sku
           , @c_Style = TRIM(ISNULL(SKU.Style, ''))
           , @c_Notes = TRIM(ISNULL(ORDERDETAIL.Notes, ''))
           , @c_Size = TRIM(ISNULL(SKU.Size, ''))
      FROM SKU WITH (NOLOCK)
      JOIN ORDERDETAIL (NOLOCK) ON ORDERDETAIL.Sku = SKU.Sku AND SKU.StorerKey = ORDERDETAIL.StorerKey
      WHERE SKU.StorerKey = @c_StorerKey AND SKU.Sku = @c_sku AND ORDERDETAIL.OrderKey = @c_Orderkey

      IF @c_Externorderkey IS NULL
         SET @c_Externorderkey = N''
      IF @c_Contact1 IS NULL
         SET @c_Contact1 = N''
      IF @c_Notes IS NULL
         SET @c_Notes = N''
      IF @c_Platform IS NULL
         SET @c_Platform = N''
      IF @c_UDF01 IS NULL
         SET @c_UDF01 = N''
      IF @c_AltSKU IS NULL
         SET @c_AltSKU = N''
      IF @c_Style IS NULL
         SET @c_Style = N''
      IF @c_Size IS NULL
         SET @c_Size = N''

      SET @c_PickheaderKey = N''

      SELECT @c_PickheaderKey = ISNULL(PickHeaderKey, '')
      FROM PICKHEADER (NOLOCK)
      WHERE ExternOrderKey = @c_Loadkey AND OrderKey = @c_Orderkey AND Zone = '3'

      INSERT INTO #temp_pick (OrderKey, ExternOrderKey, PickSlipNo, [Platform], DeliveryDate, C_Contact1, Loc, Style
                            , AltSKU, ODNotes, Qty, UDF01, PrintedFlag
                            , Loadkey, OrderDate, Size)
      VALUES (@c_Orderkey, @c_Externorderkey, @c_PickheaderKey, @c_Platform, @d_DeliveryDate, @c_Contact1, @c_loc
            , @c_Style, @c_AltSKU, @c_Notes, @n_qty, @c_UDF01, @c_PrintedFlag
            , @c_Loadkey, @dt_OrderDate, @c_Size)

      FETCH NEXT FROM CUR_PICK
      INTO @c_Orderkey
         , @c_StorerKey
         , @c_sku
         , @c_loc
         , @c_UOM
         , @c_ID
         , @n_qty
         , @c_Logicalloc
   END

   CLOSE CUR_PICK
   DEALLOCATE CUR_PICK

   SELECT @n_PS_required = COUNT(DISTINCT OrderKey)
   FROM #temp_pick
   WHERE PickSlipNo IS NULL OR RTRIM(PickSlipNo) = ''

   IF @n_PS_required > 0 AND @c_PreGenRptData = 'Y'
   BEGIN
      EXECUTE nspg_GetKey 'PICKSLIP'
                        , 9
                        , @c_NextNo OUTPUT
                        , @b_success OUTPUT
                        , @n_err OUTPUT
                        , @c_errmsg OUTPUT
                        , 0
                        , @n_PS_required
      IF @b_success <> 1
         GOTO FAILURE

      SET @c_Orderkey = N''
      DECLARE CUR_PS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OrderKey
      FROM #temp_pick
      WHERE PickSlipNo IS NULL OR RTRIM(PickSlipNo) = ''
      ORDER BY OrderKey

      OPEN CUR_PS

      FETCH NEXT FROM CUR_PS
      INTO @c_Orderkey

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
         IF @c_Orderkey IS NULL OR RTRIM(@c_Orderkey) = ''
         BEGIN
            BREAK
         END

         IF NOT EXISTS (  SELECT 1
                          FROM PICKHEADER (NOLOCK)
                          WHERE OrderKey = @c_Orderkey)
         BEGIN
            SET @c_PickheaderKey = N'P' + @c_NextNo
            SET @c_NextNo = RIGHT('000000000' + CONVERT(NVARCHAR(9), CONVERT(INT, @c_NextNo) + 1), 9)

            BEGIN TRAN
            INSERT INTO PICKHEADER (PickHeaderKey, OrderKey, ExternOrderKey, PickType, Zone, TrafficCop)
            VALUES (@c_PickheaderKey, @c_Orderkey, @c_Loadkey, '0', '3', '')

            SET @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               IF @@TRANCOUNT >= 1
               BEGIN
                  ROLLBACK TRAN
                  GOTO FAILURE
               END
            END
            ELSE
            BEGIN
               IF @@TRANCOUNT > 0
               BEGIN
                  COMMIT TRAN
               END
               ELSE
               BEGIN
                  ROLLBACK TRAN
                  GOTO FAILURE
               END
            END -- @n_err <> 0  
         END -- NOT Exists    

         FETCH NEXT FROM CUR_PS
         INTO @c_Orderkey
      END -- WHILE  
      CLOSE CUR_PS
      DEALLOCATE CUR_PS

      UPDATE #temp_pick
      SET PickSlipNo = PICKHEADER.PickHeaderKey
      FROM PICKHEADER (NOLOCK)
      WHERE PICKHEADER.ExternOrderKey = #temp_pick.Loadkey
      AND   PICKHEADER.OrderKey = #temp_pick.OrderKey
      AND   PICKHEADER.Zone = '3'
      AND   (#temp_pick.PickSlipNo IS NULL OR RTRIM(#temp_pick.PickSlipNo) = '')
   END
   GOTO SUCCESS

   FAILURE:
   DELETE FROM #temp_pick

   SUCCESS:
   IF (  SELECT COUNT(DISTINCT StorerKey)
         FROM ORDERS WITH (NOLOCK)
         JOIN LoadPlanDetail (NOLOCK) ON (LoadPlanDetail.OrderKey = ORDERS.OrderKey)
         WHERE LoadPlanDetail.LoadKey = @c_Loadkey) = 1 AND @c_PreGenRptData = 'Y'
   BEGIN
      -- Only 1 storer found  
      SET @c_StorerKey = N''

      SELECT TOP 1 @c_StorerKey = ORDERS.StorerKey
      FROM ORDERS WITH (NOLOCK)
      JOIN LoadPlanDetail WITH (NOLOCK) ON (LoadPlanDetail.OrderKey = ORDERS.OrderKey)
      WHERE LoadPlanDetail.LoadKey = @c_Loadkey

      IF EXISTS (  SELECT 1
                   FROM StorerConfig WITH (NOLOCK)
                   WHERE ConfigKey = 'AUTOSCANIN' AND SValue = '1' AND StorerKey = @c_StorerKey)
      BEGIN
         -- Configkey is setup  
         DECLARE CUR_PI CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PickSlipNo
         FROM #temp_pick
         WHERE PickSlipNo IS NOT NULL OR RTRIM(PickSlipNo) <> ''
         ORDER BY OrderKey

         OPEN CUR_PI

         FETCH NEXT FROM CUR_PI
         INTO @c_PickSlipNo

         WHILE (@@FETCH_STATUS <> -1)
         BEGIN

            IF NOT EXISTS (  SELECT 1
                             FROM PickingInfo WITH (NOLOCK)
                             WHERE PickSlipNo = @c_PickSlipNo)
            BEGIN
               INSERT INTO PickingInfo (PickSlipNo, ScanInDate, PickerID, ScanOutDate)
               VALUES (@c_PickSlipNo, GETDATE(), SUSER_SNAME(), NULL)
            END
            FETCH NEXT FROM CUR_PI
            INTO @c_PickSlipNo
         END
         CLOSE CUR_PI
         DEALLOCATE CUR_PI
      END -- Configkey is setup  
   END -- Only 1 storer found  

   IF ISNULL(@c_PreGenRptData,'') = ''
   BEGIN
      SELECT OrderKey
           , ExternOrderKey
           , PickSlipNo
           , [Platform]
           , DeliveryDate
           , C_Contact1
           , Loc
           , Style
           , AltSKU
           , ODNotes
           , Qty
           , UDF01
           , RptLogo = @c_RptLogo
           , PrintedFlag
           , Loadkey
           , Notice = ISNULL(@c_Notice,'')
           , Reminder = ISNULL(@c_Reminder,'')
           , QR1 = ISNULL(@c_QR1,'')
           , QR2 = ISNULL(@c_QR2,'')
           , Group1 = TRIM(OrderKey) + TRIM(ExternOrderKey) + TRIM(PickSlipNo) + TRIM([Platform])
                    + CONVERT(NVARCHAR(10), ISNULL(DeliveryDate, '19000101'), 101) + TRIM(ISNULL(C_Contact1,'')) + TRIM(ISNULL(UDF01,''))
           , RecNo = (ROW_NUMBER() OVER (PARTITION BY TRIM(OrderKey) + TRIM(ExternOrderKey) + TRIM(PickSlipNo) + TRIM([Platform])
                                                    + CONVERT(NVARCHAR(10), ISNULL(DeliveryDate, '19000101'), 101) 
                                                    + TRIM(ISNULL(C_Contact1,'')) + TRIM(ISNULL(UDF01,''))
                                         ORDER BY rowid
                                                , OrderKey
                                                , Loc))
           , OrderDate
           , QR1_DESCR = ISNULL(@c_QR1_DESCR,'')
           , QR2_DESCR = ISNULL(@c_QR2_DESCR,'')
           , NoticeArrSize = @n_NoticeArrSize
           , ReminderArrSize = @n_ReminderArrSize
           , Size
      FROM #temp_pick
      ORDER BY rowid
             , OrderKey
             , Loc
   END

   IF OBJECT_ID('tempdb..#temp_pick') IS NOT NULL
      DROP TABLE #temp_pick

   IF CURSOR_STATUS('LOCAL', 'CUR_SCANIN') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_SCANIN
      DEALLOCATE CUR_SCANIN
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_PI') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_PI
      DEALLOCATE CUR_PI
   END

   IF CURSOR_STATUS('LOCAL', 'CUR_PS') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_PS
      DEALLOCATE CUR_PS
   END

   QUIT_RESULT:
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_LP_PLISTN_054_ECOM] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_LP_PLISTN_054_ECOM] TO [LogiReportRoleWM]
GO