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
/* Github Version: 1.2                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 18-Jun-2024 WLChooi  1.0   DevOps Combine Script                     */
/* 04-oCT-2024 CalvinK  1.1   Sum Qty and remove Distinct (CLVN01)      */
/* 24-Oct-2024 WLChooi  1.2   FCR-1075 Add Total Pallet & Weight (WL01) */
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

   --WL01 S
   CREATE TABLE #T_DUMMY (
         RowID             INT NOT NULL IDENTITY(1,1)
       , BUSR3             NVARCHAR(50) NULL
       , NMFC              NVARCHAR(50) NULL
       , BUSR7             NVARCHAR(50) NULL
       , [DESCRIPTION]     NVARCHAR(250) NULL
       , QTY               INT NULL
       , [WEIGHT]          FLOAT NULL
       , TTLPLT            INT NULL
       , TTLPLTWGT         FLOAT NULL
       , DummyRec          NVARCHAR(1) DEFAULT 'N'
   )

   DECLARE @c_Userdefine09 NVARCHAR(10) = ''
         , @c_Storerkey    NVARCHAR(15) = ''
         , @n_PalletWgt    FLOAT = 0.00
         , @n_TotalRow     INT = 0
         , @n_CurrentCnt   INT = 0
         , @n_MaxRow       INT = 3

   SELECT @c_Userdefine09 = MBOL.UserDefine09
        , @c_Storerkey = ORDERS.StorerKey
   FROM ORDERS (NOLOCK)
   JOIN MBOL (NOLOCK) ON ORDERS.MBOLKey = MBOL.MbolKey
   WHERE MBOL.MbolKey = @c_Mbolkey

   ;WITH CTE AS ( SELECT TOP 1 CODELKUP.Short, SeqNo = 2
                  FROM CODELKUP (NOLOCK)
                  WHERE CODELKUP.LISTNAME = 'LVSUSPLT' AND CODELKUP.Storerkey = @c_Storerkey AND CODELKUP.Code = '1'
                  UNION ALL
                  SELECT TOP 1 CODELKUP.Short, SeqNo = 1
                  FROM CODELKUP (NOLOCK)
                  WHERE CODELKUP.LISTNAME = 'LVSUSPLT' AND CODELKUP.Storerkey = @c_Storerkey AND CODELKUP.Code = @c_Userdefine09 )
   SELECT TOP 1 @n_PalletWgt = IIF(ISNUMERIC(CTE.Short) = 1, CAST(CTE.Short AS FLOAT), 1.0)
   FROM CTE
   ORDER BY CTE.SeqNo
   --WL01 E

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
        , TTLPLT = MAX(PL.TTLPLT)   --WL01
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
   --WL01 S
   CROSS APPLY ( SELECT COUNT(DISTINCT PLTD.Palletkey) AS TTLPLT
                 FROM ORDERS OH (NOLOCK)
                 JOIN PACKHEADER PH (NOLOCK) ON PH.OrderKey = OH.OrderKey
                 JOIN PACKDETAIL PD (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo
                 JOIN PALLETDETAIL PLTD (NOLOCK) ON PD.LabelNo = PLTD.CaseId AND PD.StorerKey = PLTD.StorerKey
                 WHERE OH.MBOLKey = ORDERS.MBOLKey
                 AND OH.ConsigneeKey = ORDERS.ConsigneeKey ) AS PL
   --WL01 E
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

   --WL01 S
   INSERT INTO #T_DUMMY (BUSR3, NMFC, BUSR7, [DESCRIPTION], QTY, [WEIGHT], TTLPLT, TTLPLTWGT, DummyRec)
   SELECT BUSR3, NMFC, BUSR7, [DESCRIPTION], SUM(QTY) AS QTY, [WEIGHT] --(CLVN01)
         , TTLPLT = MAX(TTLPLT)
         , TTLPLTWGT = (MAX(TTLPLT) * @n_PalletWgt) + [WEIGHT]
         , 'N'
   FROM #TEMP                                             --(CLVN01)
   GROUP BY BUSR3, NMFC, BUSR7, [DESCRIPTION], [WEIGHT]               --(CLVN01)

   SELECT @n_TotalRow = COUNT(1)
   FROM #T_DUMMY
   
   SET @n_TotalRow = @n_MaxRow - @n_TotalRow

   --Insert dummy row to push the Grand total to bottom
   WHILE (@n_CurrentCnt < @n_TotalRow)
   BEGIN
      INSERT INTO #T_DUMMY (BUSR3, NMFC, BUSR7, [DESCRIPTION], QTY, [WEIGHT], TTLPLT, TTLPLTWGT, DummyRec)
      SELECT TOP 1 NULL, NULL, NULL, NULL, NULL, NULL, TTLPLT, TTLPLTWGT, 'Y'
      FROM #T_DUMMY
      WHERE DummyRec = 'N'

      SET @n_CurrentCnt = @n_CurrentCnt + 1
   END

   SELECT BUSR3, NMFC, BUSR7, [DESCRIPTION], QTY, [WEIGHT], TTLPLT, TTLPLTWGT, DummyRec
   FROM #T_DUMMY

   IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
      DROP TABLE #TEMP

   IF OBJECT_ID('tempdb..#T_DUMMY') IS NOT NULL
      DROP TABLE #T_DUMMY
   --WL01 E

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Qty] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_MB_VICSBOL_001_Detail_Qty] TO [LogiReportRoleWM]
GO