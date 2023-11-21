SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_Packing_List_142_1_rdt                              */
/* Creation Date: 06-Sep-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose:WMS-23247 [TW] ADS PB Report Packing List_NEW                */
/*        :                                                             */
/* Called By: r_dw_packing_list_142_1_rdt (ECOM)                        */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 06-Sep-2023  WLChooi   1.0 DevOps Combine Script                     */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Packing_List_142_1_rdt] @c_Pickslipno NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt     INT
         , @n_Continue      INT
         , @b_Success       INT
         , @n_Err           INT
         , @c_Errmsg        NVARCHAR(255)
         , @n_NoOfReqPSlip  INT
         , @c_Orderkey      NVARCHAR(10)
         , @c_PickHeaderKey NVARCHAR(10)
         , @c_Storerkey     NVARCHAR(15)
         , @c_AutoScanIn    NVARCHAR(10)
         , @c_Facility      NVARCHAR(5)
         , @c_Logo          NVARCHAR(50)
         , @n_MaxLine       INT
         , @n_CntRec        INT
         , @c_MaxPSlipno    NVARCHAR(10)
         , @n_LastPage      INT
         , @n_ReqLine       INT
         , @c_RPLogo        NVARCHAR(255)
         , @c_RNotes        NVARCHAR(255)
         , @c_PSNo          NVARCHAR(20)
         , @c_loc           NVARCHAR(50)
         , @c_sku           NVARCHAR(50)
         , @n_rowid         INT
         , @c_QR1           NVARCHAR(150)
         , @c_QR2           NVARCHAR(150)
         , @n_MaxRec        INT
         , @n_CurrentRec    INT
         , @n_MaxLineno     INT
         , @c_Notice        NVARCHAR(500)
         , @c_Reminder      NVARCHAR(500)
         , @c_Platform      NVARCHAR(50)
         , @c_QR1_DESCR     NVARCHAR(100)
         , @c_QR2_DESCR     NVARCHAR(100)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_Errmsg = N''
   SET @c_Logo = N''
   SET @n_MaxLine = 8
   SET @n_CntRec = 1
   SET @n_LastPage = 0
   SET @n_ReqLine = 1

   CREATE TABLE #TMP_PCK88TW
   (
      rowid       INT           NOT NULL IDENTITY(1, 1) PRIMARY KEY
    , PickSlipNo  NVARCHAR(10)  NOT NULL
    , Contact1    NVARCHAR(45)  NULL
    , Style       NVARCHAR(80)  NULL
    , Loadkey     NVARCHAR(10)  NOT NULL
    , Orderkey    NVARCHAR(10)  NOT NULL
    , OrdDate     DATETIME
    , EditDate    DATETIME
    , EcomOrderId NVARCHAR(50)  NULL
    , ODNotes     NVARCHAR(255) NULL
    , Loc         NVARCHAR(20)  NULL
    , Storerkey   NVARCHAR(15)  NOT NULL
    , SKU         NVARCHAR(20)  NULL
    , PFUDF01     NVARCHAR(255) NULL
    , EMUDF01     NVARCHAR(255) NULL
    , Qty         INT
    , RPLogo      NVARCHAR(255) NULL
    , Pageno      INT
    , RowNo       NVARCHAR(40)
    , QR1         NVARCHAR(500) NULL
    , QR2         NVARCHAR(500) NULL
    , QR1_DESCR   NVARCHAR(100) NULL
    , QR2_DESCR   NVARCHAR(100) NULL
    , Notice      NVARCHAR(500) NULL
    , Reminder    NVARCHAR(500) NULL
    , [Size]      NVARCHAR(50) NULL
   )

   CREATE TABLE #TMP_PCK88TW_Final
   (
      rowid       INT           NOT NULL IDENTITY(1, 1) PRIMARY KEY
    , PickSlipNo  NVARCHAR(10)  NOT NULL
    , Contact1    NVARCHAR(45)  NULL
    , Style       NVARCHAR(80)  NULL
    , Loadkey     NVARCHAR(10)  NOT NULL
    , Orderkey    NVARCHAR(10)  NOT NULL
    , OrdDate     DATETIME
    , EditDate    DATETIME
    , EcomOrderId NVARCHAR(50)  NULL
    , ODNotes     NVARCHAR(255) NULL
    , Loc         NVARCHAR(20)  NULL
    , Storerkey   NVARCHAR(15)  NOT NULL
    , SKU         NVARCHAR(20)  NULL
    , PFUDF01     NVARCHAR(255) NULL
    , EMUDF01     NVARCHAR(255) NULL
    , Qty         INT
    , RPLogo      NVARCHAR(255) NULL
    , Pageno      INT
    , RowNo       NVARCHAR(40)
    , QR1         NVARCHAR(500) NULL
    , QR2         NVARCHAR(500) NULL
    , QR1_DESCR   NVARCHAR(100) NULL
    , QR2_DESCR   NVARCHAR(100) NULL
    , Notice      NVARCHAR(500) NULL
    , Reminder    NVARCHAR(500) NULL
    , [Size]      NVARCHAR(50) NULL
   )

   CREATE TABLE #UniquePSNO
   (
      rowid      INT          NOT NULL IDENTITY(1, 1) PRIMARY KEY
    , PickslipNo NVARCHAR(10) NOT NULL
   )

   SELECT TOP 1 @c_Storerkey = ORDERS.StorerKey
              , @c_Orderkey = ORDERS.OrderKey
              , @c_Facility = ORDERS.Facility
              , @c_Platform = ISNULL(OIF.[Platform],'')
   FROM PackHeader (NOLOCK)
   JOIN ORDERS (NOLOCK) ON ORDERS.OrderKey = PackHeader.OrderKey
   LEFT JOIN ORDERINFO OIF (NOLOCK) ON ORDERS.OrderKey = OIF.OrderKey
   WHERE PackHeader.PickSlipNo = @c_Pickslipno

   SET @c_RPLogo = N''
   SET @c_QR1 = N''
   SET @c_QR2 = N''
   SET @c_Notice = N''
   SET @c_Reminder = N''
   SET @c_QR1_DESCR = N''
   SET @c_QR2_DESCR = N''
   
   SELECT @c_RPLogo = ISNULL(C3.Long, '')
        , @c_QR1 = ISNULL(C3.UDF01, '')
        , @c_QR2 = ISNULL(C3.UDF02, '')
        , @c_QR1_DESCR = ISNULL(C3.UDF03, '')
        , @c_QR2_DESCR = ISNULL(C3.UDF04, '')
   FROM CODELKUP C3 WITH (NOLOCK)
   WHERE C3.LISTNAME = 'RPTLogo' 
   AND C3.Storerkey = @c_Storerkey 
   AND C3.Code = @c_Platform
   
   SELECT @c_Notice =  COALESCE(@c_Notice + CHAR(13) + Notes, Notes)
   FROM CODELKUP (NOLOCK)
   WHERE LISTNAME = 'REPORTCFG'
   AND Storerkey = @c_Storerkey
   AND Code = @c_Platform
   AND Short = 'NOTICE'
   ORDER BY Code2

   SELECT @c_Reminder = COALESCE(@c_Reminder + CHAR(13) + Notes, Notes)
   FROM CODELKUP (NOLOCK)
   WHERE LISTNAME = 'REPORTCFG'
   AND Storerkey = @c_Storerkey
   AND Code = @c_Platform
   AND Short = 'REMINDER'
   ORDER BY Code2
   
   SET @c_Notice = IIF(ISNULL(@c_Notice,'') = '', '', SUBSTRING(@c_Notice, 2, LEN(@c_Notice) - 2))
   SET @c_Reminder = IIF(ISNULL(@c_Reminder,'') = '', '', SUBSTRING(@c_Reminder, 2, LEN(@c_Reminder) - 2))

   QUIT_SP:

   IF CURSOR_STATUS('LOCAL', 'CUR_PSLIP') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_PSLIP
      DEALLOCATE CUR_PSLIP
   END

   IF @n_Continue = 3
   BEGIN
      IF @@TRANCOUNT > 0
      BEGIN
         ROLLBACK TRAN
      END
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END

   INSERT INTO #TMP_PCK88TW (PickSlipNo, Contact1, Style, Loadkey, Orderkey, OrdDate, EditDate, EcomOrderId, ODNotes, Loc
                           , Storerkey, SKU, PFUDF01, EMUDF01, Qty, RPLogo, Pageno, RowNo, QR1, QR2, QR1_DESCR, QR2_DESCR
                           , Notice, Reminder, [Size])
   SELECT PickSlipNo = @c_Pickslipno
        , Contact1 = ISNULL(TRIM(ORDERS.C_contact1), '')
        , Style = ISNULL(SKU.Style, '')
        , Loadkey = ''
        , Orderkey = @c_Orderkey
        , OrdDate = ORDERS.OrderDate
        , EditDate = ORDERS.EditDate
        , EcomOrderId = ISNULL(TRIM(OI.EcomOrderId), '')
        , ODNotes = ISNULL(TRIM(OD.Notes), '')
        , PICKDETAIL.Loc
        , PICKDETAIL.Storerkey
        , SKU = SKU.ALTSKU
        , PFUDF01 = ISNULL(C1.UDF01, '')
        , EMUDF01 = ISNULL(C2.UDF01, '')
        , Qty = ISNULL(SUM(PICKDETAIL.Qty), 0)
        , RPLogo = @c_RPLogo
        , pageno = (ROW_NUMBER() OVER (PARTITION BY @c_Pickslipno
                                       ORDER BY @c_Pickslipno
                                              , ORDERS.Orderkey
                                              , PICKDETAIL.Sku ASC)) / @n_MaxLine
        , ROW_NUMBER() OVER (PARTITION BY @c_Pickslipno
                             ORDER BY PICKDETAIL.Loc
                                    , PICKDETAIL.Sku) AS RowNo
        , ISNULL(@c_QR1,'')
        , ISNULL(@c_QR2,'')
        , ISNULL(@c_QR1_DESCR,'')
        , ISNULL(@c_QR2_DESCR,'')
        , ISNULL(@c_Notice,'')
        , ISNULL(@c_Reminder,'')
        , ISNULL(TRIM(SKU.[Size]),'')
   FROM ORDERS WITH (NOLOCK)
   JOIN STORER WITH (NOLOCK) ON (ORDERS.Storerkey = STORER.StorerKey)
   JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = ORDERS.OrderKey
   JOIN PICKDETAIL WITH (NOLOCK) ON (   OD.OrderKey = PICKDETAIL.OrderKey
                                    AND PICKDETAIL.OrderLineNumber = OD.OrderLineNumber)
   JOIN SKU WITH (NOLOCK) ON (PICKDETAIL.Storerkey = SKU.StorerKey) AND (PICKDETAIL.Sku = SKU.Sku)
   LEFT JOIN OrderInfo OI WITH (NOLOCK) ON OI.OrderKey = ORDERS.OrderKey
   LEFT JOIN CODELKUP C1 WITH (NOLOCK) ON  C1.LISTNAME = 'PLATFORM'
                                       AND C1.Storerkey = ORDERS.StorerKey
                                       AND C1.Code = OI.[Platform]
   LEFT JOIN CODELKUP C2 WITH (NOLOCK) ON  C2.LISTNAME = 'ECDLMODE'
                                       AND C2.Storerkey = ORDERS.StorerKey
                                       AND C2.Code = ORDERS.ShipperKey
   WHERE ORDERS.OrderKey = @c_Orderkey
   AND ORDERS.[Status] >= '5'
   GROUP BY ISNULL(TRIM(ORDERS.C_contact1), '')
          , ISNULL(SKU.Style, '')
          , SKU.ALTSKU
          , ORDERS.OrderDate
          , ORDERS.EditDate
          , ISNULL(TRIM(OI.EcomOrderId), '')
          , ISNULL(TRIM(OD.Notes), '')
          , PICKDETAIL.Loc
          , PICKDETAIL.Storerkey
          , PICKDETAIL.Sku
          , ISNULL(C1.UDF01, '')
          , ISNULL(C2.UDF01, '')
          , ORDERS.OrderKey
          , ISNULL(TRIM(SKU.[Size]),'')
   ORDER BY PICKDETAIL.Sku

   SELECT @c_MaxPSlipno = MAX(PickSlipNo)
        , @n_CntRec = COUNT(1)
        , @n_LastPage = MAX(tp.Pageno)
   FROM #TMP_PCK88TW AS tp
   GROUP BY tp.PickSlipNo

   --Get unique psno order by loc,sku  
   DECLARE CUR_sort CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PickSlipNo
        , Loc
        , SKU
   FROM #TMP_PCK88TW
   WHERE RowNo = 1
   ORDER BY Loc
          , PickSlipNo
          , SKU DESC
   OPEN CUR_sort

   FETCH NEXT FROM CUR_sort
   INTO @c_PSNo
      , @c_loc
      , @c_sku
   WHILE @@FETCH_STATUS <> -1
   BEGIN

      INSERT INTO #UniquePSNO (PickslipNo)
      SELECT @c_PSNo

      FETCH NEXT FROM CUR_sort
      INTO @c_PSNo
         , @c_loc
         , @c_sku
   END
   CLOSE CUR_sort
   DEALLOCATE CUR_sort

   --Group same orderkey together  
   DECLARE CUR_PSNO CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT rowid
                 , PickslipNo
   FROM #UniquePSNO
   ORDER BY rowid
   OPEN CUR_PSNO

   FETCH NEXT FROM CUR_PSNO
   INTO @n_rowid
      , @c_PSNo
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      INSERT INTO #TMP_PCK88TW_Final (PickSlipNo, Contact1, Style, Loadkey, Orderkey, OrdDate, EditDate, EcomOrderId
                                    , ODNotes, Loc, Storerkey, SKU, PFUDF01, EMUDF01, Qty, RPLogo, Pageno
                                    , RowNo, QR1, QR2, QR1_DESCR, QR2_DESCR, Notice, Reminder, [Size])
      SELECT PickSlipNo
           , Contact1
           , Style
           , Loadkey
           , Orderkey
           , OrdDate
           , EditDate
           , EcomOrderId
           , ODNotes
           , Loc
           , Storerkey
           , SKU
           , PFUDF01
           , EMUDF01
           , Qty
           , RPLogo
           , Pageno
           , RowNo
           , QR1
           , QR2
           , QR1_DESCR
           , QR2_DESCR
           , Notice
           , Reminder
           , [Size]
      FROM #TMP_PCK88TW
      WHERE PickSlipNo NOT IN (  SELECT DISTINCT PickSlipNo
                                 FROM #TMP_PCK88TW_Final ) AND PickSlipNo = @c_PSNo
      ORDER BY Loc
             , SKU

      FETCH NEXT FROM CUR_PSNO
      INTO @n_rowid
         , @c_PSNo
   END
   CLOSE CUR_PSNO
   DEALLOCATE CUR_PSNO

   IF @n_CntRec > @n_MaxLine
   BEGIN
      SET @n_ReqLine = @n_MaxLine - (@n_CntRec - @n_MaxLine) - 1
   END
   ELSE
   BEGIN
      SET @n_ReqLine = @n_MaxLine - @n_CntRec - 1
   END

   WHILE @n_ReqLine >= 1
   BEGIN

      INSERT INTO #TMP_PCK88TW_Final (PickSlipNo, Contact1, Style, Loadkey, Orderkey, OrdDate, EditDate, EcomOrderId
                                    , ODNotes, Loc, Storerkey, SKU, PFUDF01, EMUDF01, Qty, RPLogo, Pageno
                                    , RowNo, QR1, QR2, QR1_DESCR, QR2_DESCR, Notice, Reminder, [Size])
      SELECT TOP 1 @c_PSNo
                 , ''
                 , ''
                 , Loadkey
                 , Orderkey
                 , ''
                 , ''
                 , ''
                 , ''
                 , ''
                 , Storerkey
                 , ''
                 , ''
                 , ''
                 , 0
                 , ''
                 , @n_LastPage
                 , ''
                 , QR1
                 , QR2
                 , QR1_DESCR
                 , QR2_DESCR
                 , Notice
                 , Reminder
                 , ''
      FROM #TMP_PCK88TW_Final
      WHERE #TMP_PCK88TW_Final.PickSlipNo = @c_PSNo AND #TMP_PCK88TW_Final.Pageno = @n_LastPage

      SET @n_ReqLine = @n_ReqLine - 1
   END

   SELECT *
   FROM #TMP_PCK88TW_Final AS tp
   ORDER BY PickSlipNo
          , CASE WHEN SKU = '' THEN 2
                 ELSE 1 END
          , tp.Pageno

END -- procedure  
GO
GRANT EXECUTE ON [dbo].[isp_Packing_List_142_1_rdt] TO NSQL
GO