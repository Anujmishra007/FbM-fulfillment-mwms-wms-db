SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* SP: isp_RPT_CB_VICSCBOL_001_Detail_Info                              */
/* Creation Date: 06-Sep-2024                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: UWP-24135 & FCR-798 - NAM|Maersk Logi Report|LVSUSA| Migrate*/
/*          VICS CBOL report to Maersk WMS V2 for Granite Project       */
/*        :                                                             */
/* Called By: RPT_CB_VICSCBOL_001_Detail_Info                           */
/*          :                                                           */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 06-Sep-2024 WLChooi  1.0   DevOps Combine Script                     */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_RPT_CB_VICSCBOL_001_Detail_Info]
(
   @n_Cbolkey  BIGINT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   CREATE TABLE #T_INFO (
         RowID             INT NOT NULL IDENTITY(1,1)
       , ExternOrderKey    NVARCHAR(50)
       , userDefine03      NVARCHAR(50)
       , PKG               INT
       , [WEIGHT]          FLOAT
       , PALLETS           NVARCHAR(10)
       , CBOLReference     NVARCHAR(30)
   )

   IF EXISTS ( SELECT 1 FROM ORDERS O (NOLOCK) 
               JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey
               JOIN MBOL MB (NOLOCK) ON O.Mbolkey = MB.Mbolkey
               WHERE ISNULL(OD.Consoorderkey,'') <> ''
               AND MB.Cbolkey = @n_Cbolkey 
               AND ISNULL(MB.Cbolkey,0) <> 0 )
   BEGIN
      SELECT DISTINCT ORDERDETAIL.ExternConsoOrderKey, CBOL.CBOLReference
      INTO #CONSOORD
      FROM MBOL WITH (NOLOCK)
      JOIN MBOLDETAIL WITH (NOLOCK) ON ( MBOL.Mbolkey = MBOLDETAIL.Mbolkey )       
      JOIN ORDERS WITH (NOLOCK) ON ( MBOLDETAIL.OrderKey = ORDERS.OrderKey ) 
      JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERS.Orderkey = ORDERDETAIL.Orderkey)
      JOIN CBOL WITH (NOLOCK) ON (MBOL.Cbolkey = CBOL.Cbolkey)
      WHERE MBOL.Cbolkey = @n_Cbolkey 
      AND ISNULL(MBOL.Cbolkey, 0) <> 0
      
      SELECT EXTERNCONSOORDERKEY, TTLCTN, TTLWeight  
      INTO #SUMM
      FROM [dbo].[fnc_GetVicsCBOL_CartonInfo](@n_Cbolkey)
      
      INSERT INTO #T_INFO (ExternOrderKey, userDefine03, PKG, [WEIGHT], PALLETS, CBOLReference)
      SELECT ORD.ExternConsoOrderKey,
            'Dept: ' AS userDefine03,
            SM.TTLCTN AS PKG,          
            SM.TTLWeight AS [WEIGHT],        
            'Y / N  ' AS PALLETS,
            ORD.CBOLReference 
      FROM #CONSOORD AS ORD
      JOIN #SUMM AS SM ON SM.ExternConsoOrderkey = ORD.ExternConsoOrderkey
   END
   ELSE
   BEGIN
      INSERT INTO #T_INFO (ExternOrderKey, userDefine03, PKG, [WEIGHT], PALLETS, CBOLReference)
      SELECT ORDERS.ExternOrderKey,
             'Dept: ' + TRIM(ORDERS.userDefine03),
             PKG = SUM(CONVERT(INT, PK.TTLCTN)),          
             [WEIGHT] = SUM(MBOLDETAIL.[Weight]),        
             'Y / N  ' PALLETS,
             CBOL.CBOLReference 
       FROM MBOL WITH (NOLOCK)
       JOIN MBOLDETAIL WITH (NOLOCK) ON ( MBOL.Mbolkey = MBOLDETAIL.Mbolkey )
       JOIN ORDERS WITH (NOLOCK) ON ( MBOLDETAIL.OrderKey = ORDERS.OrderKey ) 
       JOIN CBOL WITH (NOLOCK) ON (MBOL.Cbolkey = CBOL.Cbolkey)
       CROSS APPLY ( SELECT COUNT(DISTINCT P.LabelNo) AS TTLCTN 
                     FROM PACKDETAIL P (NOLOCK)
                     JOIN PACKHEADER PH (NOLOCK) ON P.Pickslipno = PH.Pickslipno
                     WHERE PH.Orderkey = ORDERS.Orderkey ) AS PK
       WHERE ( MBOL.Cbolkey = @n_Cbolkey   ) 
       AND ( ISNULL(MBOL.Cbolkey, 0) <> 0 )
       GROUP BY ORDERS.ExternOrderKey, 
                ORDERS.userDefine03,
                CBOL.CBOLReference   
   END

   SELECT ExternOrderKey
        , userDefine03
        , PKG
        , [WEIGHT]
        , PALLETS
        , SumPKG    = (SELECT SUM(PKG) FROM #T_INFO)
        , SumWeight = (SELECT SUM([WEIGHT]) FROM #T_INFO)
        , TotalRow  = (SELECT COUNT(1) FROM #T_INFO)
        , CBOLReference
   FROM #T_INFO
   ORDER BY RowID
   
   IF OBJECT_ID('tempdb..#SUMM') IS NOT NULL
      DROP TABLE #SUMM
      
   IF OBJECT_ID('tempdb..#CONSOORD') IS NOT NULL
      DROP TABLE #CONSOORD

   IF OBJECT_ID('tempdb..#T_INFO') IS NOT NULL
      DROP TABLE #T_INFO
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RPT_CB_VICSCBOL_001_Detail_Info] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_CB_VICSCBOL_001_Detail_Info] TO [LogiReportRoleWM]
GO