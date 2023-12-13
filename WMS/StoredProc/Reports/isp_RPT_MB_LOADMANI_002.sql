SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: isp_RPT_MB_LOADMANI_002                             */
/* Creation Date: 25-Jan-2023                                            */
/* Copyright: LFL                                                        */
/* Written by: Adarsh                                                    */
/*                                                                       */
/* Purpose: WMS-21519 & WMS-23938                                        */
/*                                                                       */
/* Called By: RPT_MB_LOADMANI_002                                        */
/*                                                                       */
/* GitHub Version: 1.1                                                   */
/*                                                                       */
/* Version: 5.4                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author  Ver   Purposes                                   */
/* 23-Oct-2023  WLChooi  1.0  DevOps Combine Script                      */
/* 13-Dec-2023  WLChooi  1.1  WMS-23938 - Bug Fix (WL01)                 */
/*************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_RPT_MB_LOADMANI_002]
(@c_Mbolkey NVARCHAR(10))
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue       INT
         , @c_errmsg         NVARCHAR(255)
         , @b_success        INT
         , @n_err            INT
         , @n_StartTCnt      INT
         , @c_SQL            NVARCHAR(MAX)
         , @c_Storerkey      NVARCHAR(15)
         , @c_Facility       NVARCHAR(5)
         , @c_VoyageNumber   NVARCHAR(30)
         , @dt_adddate       DATETIME
         , @c_Remarks        NVARCHAR(40)
         , @c_Loadkey        NVARCHAR(10)
         , @c_ExternOrderkey NVARCHAR(50)
         , @c_Consigneekey   NVARCHAR(15)
         , @c_SHOWFIELD      NVARCHAR(5)
         , @dt_DeliveryDate  DATETIME
         , @dt_ArrivalDateFD DATETIME
         , @c_ST_Company     NVARCHAR(45)
         , @c_ST_Address1    NVARCHAR(45)
         , @c_ST_Address2    NVARCHAR(45)
         , @c_ST_Address3    NVARCHAR(45)
         , @c_c_Address4     NVARCHAR(45)
         , @c_c_Zip          NVARCHAR(18)
         , @c_c_City         NVARCHAR(45)
         , @c_Route          NVARCHAR(10)
         , @c_BuyerPO        NVARCHAR(20)
         , @c_invoiceno      NVARCHAR(20)
         , @n_NoOfCartons    INT
         , @c_ExternSO       NVARCHAR(250)
         , @c_MultiExternSO  NVARCHAR(1000)
         , @n_ShowAddresses  INT
         , @n_ShowBuyerPO    INT
         , @n_ShowMultiExtSO INT
         , @c_CarrierKey     NVARCHAR(10)
         , @c_OrderKey       NVARCHAR(10)
         , @c_Departuredate  NVARCHAR(30)
         , @c_transmethod    NVARCHAR(30)
         , @c_UserDefine03   NVARCHAR(20)
         , @c_TPT            NVARCHAR(250)
         , @c_Delivery_Zone  NVARCHAR(10)
         , @c_RDD            NVARCHAR(30)
         , @n_m3             DECIMAL(10, 5)
         , @n_TTLCNTS        INT
         , @n_totalwgt       DECIMAL(10, 5)
         , @c_LM_SG          NVARCHAR(1)
         , @n_totcs          INT
         , @n_pqty           INT
         , @c_mboldesc       NVARCHAR(30)
         , @c_Sorting        NVARCHAR(500)
         , @c_Vessel         NVARCHAR(30)
         , @dt_Userdefine06  DATETIME

   SET @n_StartTCnt = @@TRANCOUNT

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END

   CREATE TABLE #TMP_LOAD
   (
      mbolkey        NVARCHAR(10)
    , VoyageNumber   NVARCHAR(30)
    , carrierkey     NVARCHAR(10)
    , loadkey        NVARCHAR(10)
    , orderkey       NVARCHAR(10)
    , ST_Company     NVARCHAR(45)
    , Departuredate  NVARCHAR(30)
    , totalwgt       DECIMAL(10, 5)
    , transmethod    NVARCHAR(30)
    , [Route]        NVARCHAR(10)
    , m3             DECIMAL(10, 5)
    , Storerkey      NVARCHAR(15)
    , deliverydate   DATETIME
    , Facility       NVARCHAR(5)
    , Userdefine03   NVARCHAR(20)
    , ST_Address1    NVARCHAR(45)
    , ST_Address2    NVARCHAR(45)
    , ST_Address3    NVARCHAR(45)
    , TTLCNTS        INT
    , TPT            NVARCHAR(250)
    , Delivery_Zone  NVARCHAR(10)
    , Externorderkey NVARCHAR(50)
    , RDD            NVARCHAR(20)
    , Consigneekey   NVARCHAR(15)
    , SHOWFIELD      NVARCHAR(5)
    , ArrivalDateFD  DATETIME
    , LM_SG          NVARCHAR(1)
    , pqty           INT
    , buyerpo        NVARCHAR(20)
    , totcs          INT
    , mboldesc       NVARCHAR(30)
    , invoiceno      NVARCHAR(20)
    , Sorting        NVARCHAR(500)
    , Vessel         NVARCHAR(30)
    , Userdefine06   DATETIME NULL
   )

   BEGIN TRAN
   DECLARE CUR_LOAD CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT MH.MbolKey
                 , MH.VoyageNumber
                 , MH.CarrierKey
                 , CASE WHEN OH.StorerKey NOT LIKE '%NIKE%' AND ISNULL(SC.SValue, '') <> '1' THEN
                           ISNULL(RTRIM(OH.LoadKey), '')
                        WHEN OH.StorerKey LIKE '%NIKE%' AND ISNULL(SC2.SValue, '') <> '1' THEN
                           ISNULL(RTRIM(OH.LoadKey), '')
                        ELSE '' END
                 , CONVERT(VARCHAR, MH.DepartureDate, 105)
                 , MH.TransMethod
                 , OH.StorerKey
                 , OH.DeliveryDate
                 , OH.Facility
                 , OH.UserDefine03
                 , ISNULL(CL1.Description, '')
                 , MH.Delivery_Zone
                 , CASE WHEN OH.StorerKey NOT LIKE '%NIKE%' AND ISNULL(SC.SValue, '') <> '1' THEN
                           ISNULL(RTRIM(OH.ExternOrderKey), '')
                        WHEN OH.StorerKey LIKE '%NIKE%' AND ISNULL(SC2.SValue, '') = '1' THEN
                           ISNULL(RTRIM(OH.ExternOrderKey), '')
                        ELSE '' END
                 , CASE WHEN OH.StorerKey = 'ADIDAS' THEN CONVERT(VARCHAR, (CONVERT(DATETIME, OH.UserDefine03)), 103)
                        ELSE CONVERT(VARCHAR, OH.DeliveryDate, 103)END
                 , ISNULL(RTRIM(OH.ConsigneeKey), '')
                 , ISNULL(CL2.Short, '') AS SHOWFIELD
                 , MH.ArrivalDateFinalDestination
                 , OH.[Route]
                 , SUM(ISNULL(PH.TTLCNTS, '0'))
                 , MD.Description
                 , ISNULL(MH.Vessel,'')
                 , CASE WHEN ISNULL(CL3.Short,'N') = 'Y' THEN OH.UserDefine06 ELSE NULL END
   FROM MBOL MH WITH (NOLOCK)
   JOIN MBOLDETAIL MD WITH (NOLOCK) ON (MH.MbolKey = MD.MbolKey)
   JOIN ORDERS OH WITH (NOLOCK) ON (MD.OrderKey = OH.OrderKey)
   JOIN PackHeader PH WITH (NOLOCK) ON PH.OrderKey = OH.OrderKey
   LEFT OUTER JOIN CODELKUP CL1 WITH (NOLOCK) ON CL1.LISTNAME = 'TRANSMETH' AND CL1.Code = MH.TransMethod
   LEFT OUTER JOIN StorerConfig SC WITH (NOLOCK) ON (   OH.StorerKey = SC.StorerKey
                                                    AND OH.Facility = SC.Facility
                                                    AND SC.ConfigKey = 'LoadManiMBOL_MY'
                                                    AND SC.SValue = '1')
   LEFT OUTER JOIN StorerConfig SC2 WITH (NOLOCK) ON (   OH.StorerKey = SC2.StorerKey
                                                     AND OH.Facility = SC2.Facility
                                                     AND SC2.ConfigKey = 'CustomLoadMani'
                                                     AND SC2.SValue = '1')
   LEFT OUTER JOIN CODELKUP CL2 WITH (NOLOCK) ON  CL2.LISTNAME = 'REPORTCFG'
                                              AND CL2.Code = 'SHOWFIELD'
                                              AND CL2.Storerkey = OH.StorerKey
                                              AND CL2.Long = 'RPT_MB_LOADMANI_002'
   LEFT OUTER JOIN CODELKUP CL3 WITH (NOLOCK) ON  CL3.LISTNAME = 'REPORTCFG'
                                              AND CL3.Code = 'SHOWDATE'
                                              AND CL3.Storerkey = OH.StorerKey
                                              AND CL3.Long = 'RPT_MB_LOADMANI_002'
   WHERE (MH.MbolKey = @c_Mbolkey)
   GROUP BY MH.MbolKey
          , MH.VoyageNumber
          , MH.CarrierKey
          , CASE WHEN OH.StorerKey NOT LIKE '%NIKE%' AND ISNULL(SC.SValue, '') <> '1' THEN
                    ISNULL(RTRIM(OH.LoadKey), '')
                 WHEN OH.StorerKey LIKE '%NIKE%' AND ISNULL(SC2.SValue, '') <> '1' THEN ISNULL(RTRIM(OH.LoadKey), '')
                 ELSE '' END
          , CONVERT(VARCHAR, MH.DepartureDate, 105)
          , MH.TransMethod
          , OH.StorerKey
          , OH.DeliveryDate
          , OH.Facility
          , OH.UserDefine03
          , ISNULL(CL1.Description, '')
          , MH.Delivery_Zone
          , CASE WHEN OH.StorerKey NOT LIKE '%NIKE%' AND ISNULL(SC.SValue, '') <> '1' THEN
                    ISNULL(RTRIM(OH.ExternOrderKey), '')
                 WHEN OH.StorerKey LIKE '%NIKE%' AND ISNULL(SC2.SValue, '') = '1' THEN
                    ISNULL(RTRIM(OH.ExternOrderKey), '')
                 ELSE '' END
          , CASE WHEN OH.StorerKey = 'ADIDAS' THEN CONVERT(VARCHAR, (CONVERT(DATETIME, OH.UserDefine03)), 103)
                 ELSE CONVERT(VARCHAR, OH.DeliveryDate, 103)END
          , ISNULL(RTRIM(OH.ConsigneeKey), '')
          , ISNULL(CL2.Short, '')
          , MH.ArrivalDateFinalDestination
          , OH.[Route]
          , MD.Description
          , ISNULL(MH.Vessel,'')
          , CASE WHEN ISNULL(CL3.Short,'N') = 'Y' THEN OH.UserDefine06 ELSE NULL END

   OPEN CUR_LOAD

   FETCH NEXT FROM CUR_LOAD
   INTO @c_Mbolkey
      , @c_VoyageNumber
      , @c_CarrierKey
      , @c_Loadkey
      , @c_Departuredate
      , @c_transmethod
      , @c_Storerkey
      , @dt_DeliveryDate
      , @c_Facility
      , @c_UserDefine03
      , @c_TPT
      , @c_Delivery_Zone
      , @c_ExternOrderkey
      , @c_RDD
      , @c_Consigneekey
      , @c_SHOWFIELD
      , @dt_ArrivalDateFD
      , @c_Route
      , @n_totcs
      , @c_mboldesc
      , @c_Vessel
      , @dt_Userdefine06

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @c_ST_Company = N''
      SET @c_ST_Address1 = N''
      SET @c_ST_Address2 = N''
      SET @c_ST_Address3 = N''
      SET @c_c_Zip = N''
      SET @c_c_City = N''

      SET @c_BuyerPO = N''

      SET @c_ExternSO = N''
      SET @c_MultiExternSO = N''

      SET @n_ShowAddresses = 0
      SET @n_ShowBuyerPO = 0
      SET @n_ShowMultiExtSO = 0

      SELECT TOP 1 @c_ST_Company = CASE WHEN OH.StorerKey IN ( 'JDSPORTSMY', 'NIKEMY', 'NIKESG', 'SPZ' ) THEN
                                           ISNULL(OH.C_Company, '')
                                        ELSE ISNULL(ST.Company, '') END
                 , @c_ST_Address1 = CASE WHEN OH.StorerKey NOT IN ( 'JDSPORTSMY', 'NIKEMY', 'NIKESG', 'SPZ' ) THEN
                                            ISNULL(ST.Address1, '')
                                         ELSE '' END
                 , @c_ST_Address2 = CASE WHEN OH.StorerKey NOT IN ( 'JDSPORTSMY', 'NIKEMY', 'NIKESG', 'SPZ' ) THEN
                                            ISNULL(ST.Address2, '')
                                         ELSE '' END
                 , @c_ST_Address3 = CASE WHEN OH.StorerKey NOT IN ( 'JDSPORTSMY', 'NIKEMY', 'NIKESG', 'SPZ' ) THEN
                                            ISNULL(ST.Address3, '')
                                         ELSE '' END
                 , @c_BuyerPO = CASE WHEN OH.StorerKey = 'LVS' THEN ISNULL(OH.BuyerPO, '')
                                     ELSE '' END
                 , @c_OrderKey = OH.OrderKey
                 , @c_invoiceno = OH.InvoiceNo
                 , @c_Sorting = ISNULL(TRIM(ST.Company), '') + ISNULL(TRIM(OH.C_Company), '')
                                + ISNULL(TRIM(OH.ExternOrderKey), '')
      FROM ORDERS OH WITH (NOLOCK)
      LEFT OUTER JOIN STORER ST (NOLOCK) ON OH.ConsigneeKey = ST.StorerKey
      WHERE OH.LoadKey = CASE WHEN @c_Loadkey = '' THEN OH.LoadKey
                              ELSE @c_Loadkey END
      AND   OH.ExternOrderKey = CASE WHEN @c_ExternOrderkey = '' THEN OH.ExternOrderKey
                                     ELSE @c_ExternOrderkey END
      AND   OH.ConsigneeKey = @c_Consigneekey
      AND   OH.DeliveryDate = @dt_DeliveryDate


      SET @n_TTLCNTS = 0
      SELECT @n_TTLCNTS = COUNT(DISTINCT CASE WHEN @c_ExternOrderkey = '' THEN PD.DropID
                                              ELSE OD.UserDefine01 + OD.UserDefine02 END)
      FROM ORDERS OH WITH (NOLOCK)
      JOIN ORDERDETAIL OD WITH (NOLOCK) ON (OH.OrderKey = OD.OrderKey)
      LEFT JOIN PackHeader PH WITH (NOLOCK) ON (OH.OrderKey = PH.OrderKey)
      LEFT JOIN PackDetail PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)
      WHERE OH.LoadKey = CASE WHEN @c_Loadkey = '' THEN OH.LoadKey
                              ELSE @c_Loadkey END
      AND   OH.ExternOrderKey = CASE WHEN @c_ExternOrderkey = '' THEN OH.ExternOrderKey
                                     ELSE @c_ExternOrderkey END
      AND   OH.ConsigneeKey = @c_Consigneekey
      AND   OH.DeliveryDate = @dt_DeliveryDate

      INSERT INTO #TMP_LOAD (mbolkey, VoyageNumber, carrierkey, loadkey, orderkey, ST_Company, Departuredate, totalwgt
                           , transmethod, [Route], m3, Storerkey, deliverydate, Facility, Userdefine03, ST_Address1
                           , ST_Address2, ST_Address3, TTLCNTS, TPT, Delivery_Zone, Externorderkey, RDD, Consigneekey
                           , SHOWFIELD, ArrivalDateFD, LM_SG, pqty, buyerpo, totcs, mboldesc, invoiceno, Sorting
                           , Vessel, Userdefine06 )
      VALUES (@c_Mbolkey, @c_VoyageNumber, @c_CarrierKey, @c_Loadkey, @c_OrderKey, @c_ST_Company, @c_Departuredate
            , @n_totalwgt, @c_transmethod, @c_Route, @n_m3, @c_Storerkey, @dt_DeliveryDate, @c_Facility
            , @c_UserDefine03, @c_ST_Address1, @c_ST_Address2, @c_ST_Address3, @n_TTLCNTS, @c_TPT, @c_Delivery_Zone
            , @c_ExternOrderkey, @c_RDD, @c_Consigneekey, @c_SHOWFIELD, @dt_ArrivalDateFD
            , CASE WHEN @c_Loadkey = '' THEN '1'
                   ELSE '0' END, @n_pqty, @c_BuyerPO, @n_totcs, @c_mboldesc, @c_invoiceno, @c_Sorting
            , @c_Vessel, @dt_Userdefine06 )

      FETCH NEXT FROM CUR_LOAD
      INTO @c_Mbolkey
         , @c_VoyageNumber
         , @c_CarrierKey
         , @c_Loadkey
         --,@c_OrderKey    
         , @c_Departuredate
         , @c_transmethod
         , @c_Storerkey
         , @dt_DeliveryDate
         , @c_Facility
         , @c_UserDefine03
         , @c_TPT
         , @c_Delivery_Zone
         , @c_ExternOrderkey
         , @c_RDD
         , @c_Consigneekey
         , @c_SHOWFIELD
         , @dt_ArrivalDateFD
         , @c_Route
         , @n_totcs
         , @c_mboldesc
         , @c_Vessel
         , @dt_Userdefine06
   END
   CLOSE CUR_LOAD
   DEALLOCATE CUR_LOAD

   DECLARE cur_1 CURSOR FAST_FORWARD READ_ONLY FOR
   SELECT orderkey
   FROM #TMP_LOAD
   OPEN cur_1
   FETCH NEXT FROM cur_1
   INTO @c_OrderKey
   WHILE (@@FETCH_STATUS <> -1)
   BEGIN
      SELECT @n_pqty = ISNULL(SUM(Qty), 0)
      FROM PICKDETAIL (NOLOCK)
      WHERE OrderKey = @c_OrderKey
      UPDATE #TMP_LOAD
      SET pqty = @n_pqty
      WHERE mbolkey = @c_Mbolkey AND orderkey = @c_OrderKey
      FETCH NEXT FROM cur_1
      INTO @c_OrderKey
   END
   CLOSE cur_1
   DEALLOCATE cur_1

   SELECT ORDERS.MBOLKey
        , ORDERS.OrderKey
        , totwgt = ISNULL(SUM(PICKDETAIL.Qty), 0) * SKU.STDGROSSWGT
        , n_m3 = CASE WHEN PACK.CaseCnt > 0 THEN (SKU.[Cube] * ISNULL(SUM(PICKDETAIL.Qty), 0)) / (PACK.CaseCnt)
                      ELSE 0 END
   INTO #TEMPCALC
   FROM PICKDETAIL (NOLOCK)
      , SKU (NOLOCK)
      , PACK (NOLOCK)
      , ORDERS (NOLOCK)
   WHERE PICKDETAIL.Sku = SKU.Sku
   AND   PICKDETAIL.Storerkey = SKU.StorerKey
   AND   SKU.PACKKey = PACK.PackKey
   AND   PICKDETAIL.OrderKey = ORDERS.OrderKey
   AND   ORDERS.MBOLKey = @c_Mbolkey
   GROUP BY ORDERS.MBOLKey
          , ORDERS.OrderKey
          , PACK.CaseCnt
          , SKU.STDGROSSWGT
          , SKU.[Cube]

   SELECT MBOLKey
        , OrderKey
        , totwgt = SUM(totwgt)
        , n_m3 = SUM(n_m3)
   INTO #TEMPTOTAL
   FROM #TEMPCALC
   GROUP BY MBOLKey
          , OrderKey

   UPDATE #TMP_LOAD
   SET totalwgt = t.totwgt
     , m3 = t.n_m3
   FROM #TEMPTOTAL t
   WHERE #TMP_LOAD.mbolkey = t.MBOLKey AND #TMP_LOAD.orderkey = t.OrderKey

   QUIT_SP:
   SELECT mbolkey
        , VoyageNumber
        , carrierkey
        , loadkey
        , orderkey
        , ST_Company = IIF(Storerkey = 'LVS', UPPER(Consigneekey), ST_Company)
        , Departuredate
        , totalwgt = CAST(totalwgt AS NVARCHAR)
        , transmethod
        , [Route]
        , m3
        , Storerkey
        , deliverydate
        , Facility
        , Userdefine03
        , ST_Address1 = IIF(Storerkey = 'LVS', UPPER(ST_Company), ST_Address1)
        , ST_Address2
        , ST_Address3
        , TTLCNTS = 0
        , TPT = UPPER(TPT)
        , Delivery_Zone
        , Externorderkey
        , RDD
        , Consigneekey
        , SHOWFIELD
        , ArrivalDateFD
        , LM_SG
        , pqty = IIF(Storerkey IN ( 'JDSPORTSMY', 'SPZ', 'SKECHERS' ), '(' + CAST(pqty AS NVARCHAR) + ')', '')
        , buyerpo
        , totcs = IIF(Storerkey LIKE '%NIKE%', TTLCNTS, totcs)
        , mboldesc
        , invoiceno
        , TotalM3 = CAST(CONVERT(DECIMAL(10, 5)
                               , (  SELECT SUM(m3)
                                    FROM #TMP_LOAD)) AS NVARCHAR)
        , SumPQty = IIF(Storerkey IN ( 'JDSPORTSMY', 'SPZ', 'SKECHERS' )
                        , '(' + (SELECT CAST(SUM(pqty) AS NVARCHAR) FROM #TMP_LOAD) + ')'   --WL01
                        , '')
        , CountMBOL = (  SELECT COUNT(DISTINCT mboldesc)
                         FROM #TMP_LOAD)
        , Totaltotcs = IIF(Storerkey LIKE '%NIKE%'
                           , (SELECT SUM(TTLCNTS)FROM #TMP_LOAD)
                           , (SELECT SUM(totcs)FROM #TMP_LOAD))
        , Vessel
        , Userdefine06
   FROM #TMP_LOAD
   ORDER BY Sorting

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END

   IF @n_continue = 3
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_RPT_MB_LOADMANI_002'

      RAISERROR(@c_errmsg, 16, 1) WITH SETERROR
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_LOADMANI_002] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_LOADMANI_002] TO [LogiReportRoleWM]
GO