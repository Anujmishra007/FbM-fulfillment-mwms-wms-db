SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_MB_DO_006                                     */
/* Creation Date: 30-Nov-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: UWP-11558 - South Africa - Defy Delivery Note Report           */
/*                                                                         */
/* Called By: RPT_MB_DO_006                                                */
/*                                                                         */
/* Github Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 30-Nov-2023  WLChooi  1.0  DevOps Combine Script                        */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_MB_DO_006] @c_Mbolkey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue  INT = 1
         , @c_errmsg    NVARCHAR(255)
         , @b_success   INT
         , @n_err       INT
         , @n_starttcnt INT

   SELECT @n_starttcnt = @@TRANCOUNT

   SELECT M.DepartureDate AS DeliveryDate
        , ISNULL(TRIM(F.UserDefine12), '') AS HAddress1
        , ISNULL(TRIM(F.UserDefine13), '') AS HAddress2
        , ISNULL(TRIM(F.UserDefine11), '') AS HAddress3
        , ISNULL(TRIM(F.UserDefine18), '') AS HTel
        , ISNULL(TRIM(F.UserDefine19), '') AS HFax
        , O.ConsigneeKey AS ShipToCode
        , ISNULL(TRIM(O.C_contact1), '') AS ShipToName
        , ISNULL(TRIM(O.C_Address3), '') AS [Address]
        , ISNULL(TRIM(O.C_Phone1), '') AS Tel
        , ISNULL(TRIM(O.ExternOrderKey), '') AS SONo
        , O.OrderDate
        , ISNULL(TRIM(W.UserDefine01), '') AS InvoiceNo
        , ISNULL(TRIM(W.UserDefine02), '') AS SealNum
        , ISNULL(TRIM(W.UserDefine03), '') AS TruckNo
        , ISNULL(TRIM(W.UserDefine04), '') AS TruckDriver
        , O.UserDefine09 AS WaveKey
        , O.LoadKey
        , O.Facility
        , ISNULL(TRIM(OD.UserDefine02), '') AS CustomerPo
        , TRIM(OD.Sku) AS Sku
        , ISNULL(TRIM(S.DESCR), '') AS DESCR
        , SUM(OD.ShippedQty) AS Quantity
   FROM MBOL M WITH (NOLOCK)
   INNER JOIN ORDERS O WITH (NOLOCK) ON M.MbolKey = O.MBOLKey
   INNER JOIN ORDERDETAIL OD WITH (NOLOCK) ON O.StorerKey = OD.StorerKey AND O.OrderKey = OD.OrderKey
   INNER JOIN WAVEDETAIL WD WITH (NOLOCK) ON O.OrderKey = WD.OrderKey
   INNER JOIN WAVE W WITH (NOLOCK) ON WD.WaveKey = W.WaveKey
   INNER JOIN SKU S WITH (NOLOCK) ON OD.StorerKey = S.StorerKey AND S.Sku = OD.Sku
   INNER JOIN FACILITY F WITH (NOLOCK) ON O.Facility = F.Facility
   WHERE M.MbolKey = @c_Mbolkey
   GROUP BY M.DepartureDate
        , ISNULL(TRIM(F.UserDefine12), '')
        , ISNULL(TRIM(F.UserDefine13), '')
        , ISNULL(TRIM(F.UserDefine11), '')
        , ISNULL(TRIM(F.UserDefine18), '')
        , ISNULL(TRIM(F.UserDefine19), '')
        , O.ConsigneeKey
        , ISNULL(TRIM(O.C_contact1), '')
        , ISNULL(TRIM(O.C_Address3), '')
        , ISNULL(TRIM(O.C_Phone1), '')
        , ISNULL(TRIM(O.ExternOrderKey), '')
        , O.OrderDate
        , ISNULL(TRIM(W.UserDefine01), '')
        , ISNULL(TRIM(W.UserDefine02), '')
        , ISNULL(TRIM(W.UserDefine03), '')
        , ISNULL(TRIM(W.UserDefine04), '')
        , O.UserDefine09
        , O.LoadKey
        , O.Facility
        , ISNULL(TRIM(OD.UserDefine02), '')
        , TRIM(OD.Sku)
        , ISNULL(TRIM(S.DESCR), '')
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DO_006] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_DO_006] TO [LogiReportRoleWM]
GO