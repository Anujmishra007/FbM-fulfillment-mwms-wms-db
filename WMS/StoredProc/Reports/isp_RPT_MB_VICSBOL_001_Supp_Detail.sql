SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/********************************************************************************/
/* SP: isp_RPT_MB_VICSBOL_001_Supp_Detail                                       */
/* Creation Date: 18-Jun-2024                                                   */
/* Copyright: Maersk                                                            */
/* Written by: WLChooi                                                          */
/*                                                                              */
/* Purpose: UWP-20706 - Granite | MWMS | BOL Report                             */
/*        :                                                                     */
/* Called By: RPT_MB_VICSBOL_001_Supp_Detail                                    */
/*          :                                                                   */
/* Github Version: 1.0                                                          */
/*                                                                              */
/* Version: 7.0                                                                 */
/*                                                                              */
/* Data Modifications:                                                          */
/*                                                                              */
/* Updates:                                                                     */
/* Date        Author   Ver   Purposes                                          */
/* 18-Jun-2024 WLChooi  1.0   DevOps Combine Script                             */
/* 08-Oct-2024 CalvinK  1.1   FCR-956 Change Externorderkey to BuyerPO (CLVN01) */
/********************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_RPT_MB_VICSBOL_001_Supp_Detail]
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
         , @c_Vics_MBOL NVARCHAR(50) = ''

   EXEC [dbo].[isp_GetVicsMbol] @c_Mbolkey = @c_Mbolkey
                              , @c_Vics_MBOL = @c_Vics_MBOL OUTPUT

   IF ISNULL(@c_Vics_MBOL, '') <> ''
   BEGIN
      UPDATE MBOL WITH (ROWLOCK)
      SET ExternMBOLKey = IIF(ExternMBOLKey = @c_Vics_MBOL, ExternMBOLKey, @c_Vics_MBOL)
        , TrafficCop = NULL
      WHERE MBOLkey = @c_Mbolkey
   END

   IF EXISTS (  SELECT 1
                FROM ORDERS O (NOLOCK)
                JOIN ORDERDETAIL OD (NOLOCK) ON O.OrderKey = OD.OrderKey
                WHERE ISNULL(OD.ConsoOrderKey, '') <> ''
                AND   O.MBOLKey = @c_Mbolkey
                AND   O.ConsigneeKey = @c_Consigneekey )
   BEGIN
      SELECT DISTINCT ORDERDETAIL.ExternConsoOrderKey
      INTO #CONSOORD
      FROM MBOLDETAIL WITH (NOLOCK)
      JOIN ORDERS WITH (NOLOCK) ON (MBOLDETAIL.OrderKey = ORDERS.OrderKey)
      JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERS.OrderKey = ORDERDETAIL.OrderKey)
      WHERE MBOLDETAIL.MbolKey = @c_Mbolkey 
      AND ORDERS.ConsigneeKey = @c_Consigneekey

      SELECT ExternConsoOrderkey
           , TTLCTN
           , TTLWeight
      INTO #SUMM
      FROM [dbo].[fnc_GetVicsBOL_CartonInfo](@c_Mbolkey, @c_Consigneekey)

      ;WITH CTE (ExternOrderKey, userDefine03, PKG, [WEIGHT], PALLETS) AS (
         SELECT ORD.ExternConsoOrderKey
              , 'Dept: ' AS userDefine03
              , SM.TTLCTN AS PKG
              , SM.TTLWeight AS [WEIGHT]
              , 'Y / N  ' AS PALLETS
         FROM #CONSOORD AS ORD
         JOIN #SUMM AS SM ON SM.ExternConsoOrderkey = ORD.ExternConsoOrderKey
      )
      SELECT ExternOrderKey
           , UserDefine03
           , PKG
           , [WEIGHT]
           , PALLETS
           , SumPKG    = (SELECT SUM(PKG) FROM CTE)
           , SumWeight = (SELECT SUM([WEIGHT]) FROM CTE)
           , TotalRow  = (SELECT COUNT(1) FROM CTE)
           , ExternMbolkey = @c_Vics_MBOL
      FROM CTE
   END
   ELSE
   BEGIN
      ;WITH CTE (ExternOrderKey, userDefine03, PKG, [WEIGHT], PALLETS) AS (
         SELECT --ORDERS.ExternOrderKey --(CLVN01)
              ORDERS.BUYERPO          --(CLVN01)
              , 'Dept: ' + ISNULL(TRIM(ORDERS.UserDefine03), '') AS UserDefine03
              , PKG = SUM(CONVERT(INT, MBOLDETAIL.TotalCartons))
              , [WEIGHT] = SUM(MBOLDETAIL.[Weight])
              , 'Y / N  ' PALLETS
         FROM MBOLDETAIL WITH (NOLOCK)
         JOIN ORDERS WITH (NOLOCK) ON (MBOLDETAIL.OrderKey = ORDERS.OrderKey)
         WHERE (MBOLDETAIL.MbolKey = @c_Mbolkey) AND (ORDERS.ConsigneeKey = @c_Consigneekey)
         GROUP BY --ORDERS.ExternOrderKey --(CLVN01)
                ORDERS.BUYERPO        --(CLVN01)
                , ISNULL(TRIM(ORDERS.UserDefine03), '') 
      )
      SELECT ExternOrderKey
           , UserDefine03
           , PKG
           , [WEIGHT]
           , PALLETS
           , SumPKG    = (SELECT SUM(PKG) FROM CTE)
           , SumWeight = (SELECT SUM([WEIGHT]) FROM CTE)
           , TotalRow  = (SELECT COUNT(1) FROM CTE)
           , ExternMbolkey = @c_Vics_MBOL
      FROM CTE
   END

   IF OBJECT_ID('tempdb..#SUMM') IS NOT NULL
      DROP TABLE #SUMM
      
   IF OBJECT_ID('tempdb..#CONSOORD') IS NOT NULL
      DROP TABLE #CONSOORD  
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Supp_Detail] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Supp_Detail] TO [LogiReportRoleWM]
GO