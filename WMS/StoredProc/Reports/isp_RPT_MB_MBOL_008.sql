SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_MB_MBOL_008                                   */
/* Creation Date:  11-OCT-2023                                             */
/* Copyright: MAERSK                                                       */
/* Written by: Aftab                                                       */
/*                                                                         */
/* Purpose: WMS-23862 - Migrate WMS report to Logi Report                  */
/*                                                                         */
/* Called By:RPT_MB_MBOL_008                                               */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 12-Oct-2023  WLChooi 1.0   DevOps Combine Script                        */
/* 21-Feb-2024  SeanDeng 1.1  UWP-15533 - Global Timezone (SD01)           */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_MB_MBOL_008]
(@c_Mbolkey NVARCHAR(10))
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue       INT
         , @c_errmsg         NVARCHAR(255)
         , @b_success        INT
         , @n_err            INT
         , @n_cnt            INT
         , @c_OtherReference NVARCHAR(30)
         , @c_facility       NVARCHAR(5)
         , @c_keyname        NVARCHAR(30)
         , @c_printflag      NVARCHAR(1)

   SELECT @n_continue = 1
        , @n_err = 0
        , @c_errmsg = N''
        , @b_success = 1
        , @n_cnt = 0
        , @c_printflag = N'Y'

   SELECT @c_OtherReference = MBOL.OtherReference
        , @c_facility = MBOL.Facility
   FROM MBOL (NOLOCK)
   WHERE MbolKey = @c_Mbolkey

   SELECT @n_cnt = @@ROWCOUNT

   IF ISNULL(RTRIM(@c_OtherReference), '') = '' AND @n_cnt > 0
   BEGIN
      SELECT @c_printflag = N'N'

      SELECT @c_keyname = Code
      FROM CODELKUP (NOLOCK)
      WHERE LISTNAME = 'GP_NCOUNT' AND Short = @c_facility

      IF ISNULL(RTRIM(@c_keyname), '') = ''
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250), @n_err)
              , @n_err = 62313
         SELECT @c_errmsg = N'NSQL' + CONVERT(CHAR(5), @n_err)
                            + N': CODELKUP LISTNAME GP_NCOUNT Retrieving Failed For Facility ' + RTRIM(@c_facility)
                            + N' (isp_RPT_MB_MBOL_008)' + N' ( ' + N' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '')
                            + N' ) '
      END

      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         EXECUTE nspg_GetKey @c_keyname
                           , 10
                           , @c_OtherReference OUTPUT
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
         END
         ELSE
         BEGIN
            UPDATE MBOL WITH (ROWLOCK)
            SET OtherReference = @c_OtherReference
              , EditDate = GETDATE()
              , TrafficCop = NULL
            WHERE MbolKey = @c_Mbolkey

            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250), @n_err)
                    , @n_err = 62314
               SELECT @c_errmsg = N'NSQL' + CONVERT(CHAR(5), @n_err) + N': Update MBOL Failed. (isp_RPT_MB_MBOL_008)'
                                  + N' ( ' + N' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + N' ) '
            END
         END
      END
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT MBOL.MbolKey
           , MBOL.Facility
           , FACILITY.Descr
           , MBOL.Carrieragent
           , HAULER.Company
           , MBOL.VesselQualifier AS trucktype
           , MBOL.Vessel AS truckno
           , MBOL.DRIVERName
           , [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, MBOL.DepartureDate) AS DepartureDate --SD01
           , ORDERS.ConsigneeKey
           , ORDERS.C_Company
           , ORDERS.Route
           , RouteMaster.Descr
           , @c_OtherReference AS OtherReference
           , MBOL.UserDefine04
           , MBOL.SealNo
           , MBOL.ContainerNo
           , MBOLDETAIL.InvoiceNo
           , ORDERS.ExternOrderKey
           , MBOL.EditWho
           , ROUND(SUM(CASE WHEN PACK.CaseCnt > 0 THEN PICKDETAIL.Qty / PACK.CaseCnt
                            ELSE 0 END)
                 , 2) AS totalcase
           , ROUND(
                SUM(
                   CASE WHEN PACK.CaseCnt > 0 THEN
                           ROUND(SKU.STDGROSSWGT * PACK.CaseCnt, 3) * (PICKDETAIL.Qty / PACK.CaseCnt)
                        ELSE 0 END)
              , 2) AS grossweight
           , @c_printflag AS PrintFlag
           , ROUND(SUM(PICKDETAIL.Qty * SKU.STDCUBE), 4) AS CBM
           , ORDERS.LoadKey
           , LEFT(ISNULL(MBOL.Remarks, ''), 250) AS Remark1
           , SUBSTRING(ISNULL(MBOL.Remarks, ''), 251, 250) AS Remark2
           , LoadPlan.ExternLoadKey AS LEXTLoadKey
           , CASE WHEN ISNULL(CLR.Code, '') <> '' THEN 'Y'
                  ELSE 'N' END AS HideExternLoadkey
           , SUM(PICKDETAIL.Qty) AS totalEaches
           , COUNT(DISTINCT LOTT.Lottable10) AS TTLCTN
           , [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, GETDATE()) AS CurrentDateTime --SD01
      FROM PICKDETAIL (NOLOCK)
      INNER JOIN ORDERDETAIL (NOLOCK) ON (   PICKDETAIL.OrderKey = ORDERDETAIL.OrderKey
                                         AND PICKDETAIL.OrderLineNumber = ORDERDETAIL.OrderLineNumber)
      INNER JOIN ORDERS (NOLOCK) ON (PICKDETAIL.OrderKey = ORDERS.OrderKey)
      INNER JOIN SKU (NOLOCK) ON (PICKDETAIL.Storerkey = SKU.StorerKey AND PICKDETAIL.Sku = SKU.Sku)
      INNER JOIN PACK (NOLOCK) ON (PICKDETAIL.PackKey = PACK.PackKey)
      INNER JOIN MBOLDETAIL (NOLOCK) ON (   ORDERDETAIL.MBOLKey = MBOLDETAIL.MbolKey
                                        AND ORDERDETAIL.LoadKey = MBOLDETAIL.LoadKey
                                        AND ORDERDETAIL.OrderKey = MBOLDETAIL.OrderKey)
      INNER JOIN MBOL (NOLOCK) ON (MBOLDETAIL.MbolKey = MBOL.MbolKey)
      INNER JOIN RouteMaster (NOLOCK) ON (ORDERS.Route = RouteMaster.Route)
      LEFT OUTER JOIN STORER HAULER (NOLOCK) ON (MBOL.CarrierKey = HAULER.StorerKey AND LEFT(HAULER.type, 1) = '3')
      LEFT OUTER JOIN CODELKUP CLR (NOLOCK) ON (   ORDERS.StorerKey = CLR.Storerkey
                                               AND CLR.Code = 'HIDEEXTERNLOADKEY'
                                               AND CLR.LISTNAME = 'REPORTCFG'
                                               AND CLR.Long = 'RPT_MB_MBOL_008'
                                               AND ISNULL(CLR.Short, '') <> 'N')
      INNER JOIN FACILITY (NOLOCK) ON (MBOL.Facility = FACILITY.Facility)
      JOIN LoadPlan WITH (NOLOCK) ON LoadPlan.LoadKey = ORDERDETAIL.LoadKey
      JOIN LOTATTRIBUTE LOTT WITH (NOLOCK) ON  LOTT.Lot = PICKDETAIL.Lot
                                           AND LOTT.Sku = PICKDETAIL.Sku
                                           AND LOTT.StorerKey = PICKDETAIL.Storerkey
      WHERE ORDERDETAIL.MBOLKey = @c_Mbolkey AND MBOL.Status = '9'
      GROUP BY MBOL.MbolKey
             , MBOL.Facility
             , FACILITY.Descr
             , MBOL.Carrieragent
             , HAULER.Company
             , MBOL.VesselQualifier
             , MBOL.Vessel
             , MBOL.DRIVERName
             , DepartureDate --SD01
             , ORDERS.StorerKey --SD01
             , ORDERS.Facility --SD01
             , ORDERS.ConsigneeKey
             , ORDERS.C_Company
             , ORDERS.Route
             , RouteMaster.Descr
             , MBOL.UserDefine04
             , MBOL.SealNo
             , MBOL.ContainerNo
             , MBOLDETAIL.InvoiceNo
             , ORDERS.ExternOrderKey
             , MBOL.EditWho
             , ORDERS.LoadKey
             , LEFT(ISNULL(MBOL.Remarks, ''), 250)
             , SUBSTRING(ISNULL(MBOL.Remarks, ''), 251, 250)
             , LoadPlan.ExternLoadKey
             , CASE WHEN ISNULL(CLR.Code, '') <> '' THEN 'Y'
                    ELSE 'N' END
   END

   IF @n_continue = 3
   BEGIN
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_RPT_MB_MBOL_008'
      RAISERROR(@c_errmsg, 16, 1) WITH SETERROR
      RETURN
   END
END
