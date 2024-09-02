SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* SP: isp_RPT_MB_VICSBOL_001_Detail_Info                               */
/* Creation Date: 18-Jun-2024                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: UWP-20706 - Granite | MWMS | BOL Report                     */
/*        :                                                             */
/* Called By: RPT_MB_VICSBOL_001_Detail_Info                            */
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
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Info]
(
   @c_Mbolkey      NVARCHAR(10)
 , @c_Consigneekey NVARCHAR(15)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue   INT = 1
         , @n_StartTCnt  INT = @@TRANCOUNT
         , @n_TotalRow   INT = 0
         , @n_CurrentCnt INT = 1
         , @n_MaxRow     INT = 4

   CREATE TABLE #T_INFO (
         RowID             INT NOT NULL IDENTITY(1,1)
       , ExternOrderKey    NVARCHAR(50)
       , userDefine03      NVARCHAR(50)
       , PKG               INT
       , [WEIGHT]          FLOAT
       , PALLETS           NVARCHAR(10)
       , DummyRec          NVARCHAR(1) DEFAULT 'N'
   )

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

      INSERT INTO #T_INFO (ExternOrderKey, userDefine03, PKG, [WEIGHT], PALLETS)
      SELECT ORD.ExternConsoOrderKey
           , 'Dept: ' AS userDefine03
           , SM.TTLCTN AS PKG
           , SM.TTLWeight AS [WEIGHT]
           , 'Y / N  ' AS PALLETS
      FROM #CONSOORD AS ORD
      JOIN #SUMM AS SM ON SM.ExternConsoOrderkey = ORD.ExternConsoOrderKey
      
   END
   ELSE
   BEGIN
      INSERT INTO #T_INFO (ExternOrderKey, userDefine03, PKG, [WEIGHT], PALLETS)
      SELECT ORDERS.ExternOrderKey
           , 'Dept: ' + ISNULL(TRIM(ORDERS.UserDefine03), '') AS UserDefine03
           , PKG = SUM(CONVERT(INT, PK.TTLCTN))
           , [WEIGHT] = SUM(MBOLDETAIL.[Weight])
           , 'Y / N  ' PALLETS
      FROM MBOLDETAIL WITH (NOLOCK)
      JOIN ORDERS WITH (NOLOCK) ON (MBOLDETAIL.OrderKey = ORDERS.OrderKey)
      CROSS APPLY ( SELECT COUNT(DISTINCT P.LabelNo) AS TTLCTN 
                    FROM PACKDETAIL P (NOLOCK)
                    JOIN PACKHEADER PH (NOLOCK) ON P.Pickslipno = PH.Pickslipno
                    WHERE PH.Orderkey = ORDERS.Orderkey ) AS PK
      WHERE (MBOLDETAIL.MbolKey = @c_Mbolkey) AND (ORDERS.ConsigneeKey = @c_Consigneekey)
      GROUP BY ORDERS.ExternOrderKey
             , ISNULL(TRIM(ORDERS.UserDefine03), '') 
   END

   SELECT @n_TotalRow = COUNT(1)
   FROM #T_INFO
   
   SET @n_TotalRow = @n_MaxRow - @n_TotalRow

   --Insert dummy row to push the Grand total to bottom
   WHILE (@n_CurrentCnt <= @n_TotalRow)
   BEGIN
      INSERT INTO #T_INFO (ExternOrderKey, userDefine03, PKG, [WEIGHT], PALLETS, DummyRec)
      VALUES (NULL
            , NULL
            , 0
            , 0.00
            , NULL
            , 'Y'
         )
      SET @n_CurrentCnt = @n_CurrentCnt + 1
   END

   --If RowCount > 4, need to show 'See supplementary page', need show only 4 rows to push the Grand total to bottom
   IF @n_TotalRow < 0
   BEGIN
      SELECT TOP (@n_MaxRow)
             ExternOrderKey
           , userDefine03
           , PKG
           , [WEIGHT]
           , PALLETS
           , SumPKG    = (SELECT SUM(PKG) FROM #T_INFO)
           , SumWeight = (SELECT SUM([WEIGHT]) FROM #T_INFO)
           , TotalRow  = (SELECT COUNT(1) FROM #T_INFO WHERE DummyRec = 'N')
           , DummyRec
      FROM #T_INFO
      ORDER BY RowID
   END
   ELSE
   BEGIN
      SELECT ExternOrderKey
           , userDefine03
           , PKG
           , [WEIGHT]
           , PALLETS
           , SumPKG    = (SELECT SUM(PKG) FROM #T_INFO)
           , SumWeight = (SELECT SUM([WEIGHT]) FROM #T_INFO)
           , TotalRow  = (SELECT COUNT(1) FROM #T_INFO WHERE DummyRec = 'N')
           , DummyRec
      FROM #T_INFO
      ORDER BY RowID
   END
   
   IF OBJECT_ID('tempdb..#SUMM') IS NOT NULL
      DROP TABLE #SUMM
      
   IF OBJECT_ID('tempdb..#CONSOORD') IS NOT NULL
      DROP TABLE #CONSOORD  

   IF OBJECT_ID('tempdb..#T_INFO') IS NOT NULL
      DROP TABLE #T_INFO
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Info] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Info] TO [LogiReportRoleWM]
GO