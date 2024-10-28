SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* SP: isp_RPT_MB_VICSBOL_001_Detail_Qty                                */
/* Creation Date: 18-Jun-2024                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: UWP-20706 - Granite | MWMS | BOL Report                     */
/*        :                                                             */
/* Called By: RPT_MB_VICSBOL_001_Detail_Qty                             */
/*          :                                                           */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 18-Jun-2024 WLChooi  1.0   DevOps Combine Script                     */
/* 04-oCT-2024 CalvinK  1.1   Sum Qty and remove Distinct (CLVN01)      */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Qty]
(
   @c_Mbolkey      NVARCHAR(10)
 , @c_Consigneekey NVARCHAR(15)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue  INT = 1
         , @n_StartTCnt INT = @@TRANCOUNT

   --SELECT DISTINCT SKU.BUSR3 --(CLVN01)
   SELECT SKU.BUSR3            --(CLVN01)
                 , CASE WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 1   THEN '49880/1'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 2   THEN '49880/2'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 4   THEN '49880/3'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 6   THEN '49880/4'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 8   THEN '49880/5'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 10  THEN '49880/6'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 12  THEN '49880/7'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) < 15  THEN '49880/8'
                        WHEN ROUND((SUM(SKU.GrossWgt * PD.Qty) / IIF(SUM(SKU.StdCube * PD.Qty) = 0, 1, SUM(SKU.StdCube * PD.Qty))), 0) >= 15 THEN '49880/9'
                   END AS NMFC
                 , SKU.BUSR7
                 , ISNULL(CODELKUP.[Description], SKU.BUSR7) AS [DESCRIPTION]
                 , QTY = PK.TTLCTN
                 , [WEIGHT] = MD.TTLWeight
   INTO #TEMP --(CLVN01)
   FROM MBOLDETAIL WITH (NOLOCK)
   JOIN LoadPlan WITH (NOLOCK) ON (MBOLDETAIL.LoadKey = LoadPlan.LoadKey)
   JOIN ORDERS WITH (NOLOCK) ON (MBOLDETAIL.OrderKey = ORDERS.OrderKey)
   JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERDETAIL.OrderKey = ORDERS.OrderKey)
   JOIN SKU WITH (NOLOCK) ON (SKU.Sku = ORDERDETAIL.Sku AND SKU.StorerKey = ORDERDETAIL.StorerKey)
   LEFT OUTER JOIN CODELKUP WITH (NOLOCK) ON (CODELKUP.LISTNAME = 'NMFC' AND CODELKUP.Code = SKU.BUSR6)
   JOIN (  SELECT MBOLKey AS MBLKey
                , SUM(TTLCTN) AS TTLCTN
                , SUM(TTLWeight) AS TTLWeight
           FROM [dbo].[fnc_GetVicsBOL_CartonInfo](@c_Mbolkey, @c_Consigneekey)
           GROUP BY MBOLKey) AS MD ON (MD.MBLKey = MBOLDETAIL.MbolKey)
   JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey = ORDERDETAIL.OrderKey AND PD.OrderLineNumber = ORDERDETAIL.OrderLineNumber
                              AND PD.Storerkey = SKU.StorerKey AND PD.SKU = SKU.SKU
   CROSS APPLY ( SELECT COUNT(DISTINCT P.LabelNo) AS TTLCTN 
                 FROM PACKDETAIL P (NOLOCK)
                 JOIN PACKHEADER PH (NOLOCK) ON P.Pickslipno = PH.Pickslipno
                 WHERE PH.Orderkey = ORDERS.Orderkey ) AS PK
   WHERE MBOLDETAIL.MbolKey = @c_Mbolkey 
   AND ORDERS.ConsigneeKey = @c_Consigneekey
   GROUP BY SKU.BUSR3
          , SKU.BUSR6
          , SKU.BUSR7
          , CODELKUP.[Description]
          , ORDERS.ExternOrderKey
          , ORDERS.ConsigneeKey
          , PK.TTLCTN
          , MD.TTLWeight
          , ORDERS.Orderkey

   SELECT BUSR3, NMFC, BUSR7, [DESCRIPTION], SUM(QTY) AS QTY, [WEIGHT] --(CLVN01)
   FROM #TEMP                                             --(CLVN01)
   GROUP BY BUSR3, NMFC, BUSR7, [DESCRIPTION], [WEIGHT]               --(CLVN01)
   
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Qty] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Qty] TO [LogiReportRoleWM]
GO