IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPickSlipOrders104Multi_rpt]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetPickSlipOrders104Multi_rpt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: isp_GetPickSlipOrders104Multi_rpt                           */
/* Creation Date: 26-Dec-2019                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose:  WMS-11478 - IKEA Pick Slip Multi Order                     */
/*                                                                      */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver   Purposes                                */
/* 12-Mar-2020  NJOW01    1.0   Fix total qty/sku by batchkey           */
/************************************************************************/

CREATE PROC isp_GetPickSlipOrders104Multi_rpt 
            @c_loadkey     NVARCHAR(10),
            @c_batchkey    NVARCHAR(10) = ''

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT = 1, @c_Zones NVARCHAR(255) = '', @c_GetBatchkey NVARCHAR(10) = ''

   IF @c_batchkey = NULL SET @c_batchkey = ''

   CREATE TABLE #Temp_Zone(
   BatchKey    NVARCHAR(10),
   Descr       NVARCHAR(255)   )

   INSERT INTO #Temp_Zone
   SELECT DISTINCT PD.Pickslipno, ISNULL(LOC.Descr,'')
   FROM LOADPLANDETAIL LPD (NOLOCK)
   JOIN ORDERS OH (NOLOCK) ON OH.Orderkey = LPD.Orderkey
   JOIN PICKDETAIL PD (NOLOCK) ON PD.Orderkey = OH.Orderkey
   JOIN LOC (NOLOCK) ON LOC.LOC = PD.LOC
   WHERE LPD.Loadkey = @c_loadkey
   AND PD.Pickslipno = CASE WHEN @c_batchkey = '' THEN PD.Pickslipno ELSE @c_batchkey END

   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT DISTINCT Batchkey
   FROM #Temp_Zone

   OPEN CUR_LOOP

   FETCH NEXT FROM CUR_LOOP INTO @c_GetBatchkey

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SELECT @c_Zones = STUFF((SELECT ' + ' + RTRIM(Descr) FROM #Temp_Zone WHERE Batchkey = @c_GetBatchkey ORDER BY Descr FOR XML PATH('')),1,1,'' )
      SELECT @c_Zones = SUBSTRING(@c_Zones,3,LEN(@c_Zones))

      DELETE FROM #Temp_Zone
      WHERE BatchKey = @c_GetBatchkey

      INSERT INTO #Temp_Zone
      SELECT @c_GetBatchkey, @c_Zones

      FETCH NEXT FROM CUR_LOOP INTO @c_GetBatchkey
   END

   SELECT  OH.Loadkey
         , PD.Pickslipno AS Batchkey
         --, SUM(PD.Qty) AS TotalQty
         ,(SELECT SUM(P.Qty) FROM PICKDETAIL P (NOLOCK) WHERE P.Pickslipno = PD.Pickslipno) AS TotalQty  --NJOW01
         --, Count(Distinct(PD.SKU)) AS TotalSKU
         ,(SELECT COUNT(DISTINCT P.Sku) FROM PICKDETAIL P (NOLOCK) WHERE P.Pickslipno = PD.Pickslipno) AS TotalSKU   --NJOW01
         , #Temp_Zone.Descr AS AllZones
         , CASE WHEN #Temp_Zone.Descr = 'T1' THEN '2' ELSE '1' END AS [Zone]
         , PH.Pickheaderkey
         , OH.Orderkey
   FROM ORDERS OH (NOLOCK)
   JOIN PICKDETAIL PD (NOLOCK) ON PD.ORDERKEY = OH.ORDERKEY
   JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.ORDERKEY = OH.ORDERKEY
   JOIN PICKHEADER PH (NOLOCK) ON PH.ORDERKEY = OH.ORDERKEY
   LEFT JOIN #Temp_Zone ON #Temp_Zone.BatchKey = PD.Pickslipno
   WHERE LPD.Loadkey = @c_loadkey
     AND OH.ECOM_Single_Flag = 'M'
     AND PD.Pickslipno = CASE WHEN @c_batchkey = '' THEN PD.Pickslipno ELSE @c_batchkey END
   GROUP BY OH.Loadkey
          , PD.Pickslipno
          , #Temp_Zone.Descr
          , CASE WHEN #Temp_Zone.Descr = 'T1' THEN '2' ELSE '1' END 
          , PH.Pickheaderkey
          , OH.Orderkey  


QUIT_SP:
   IF OBJECT_ID('tempdb..#Temp_Zone') IS NOT NULL
      DROP TABLE #Temp_Zone
   
   IF CURSOR_STATUS('LOCAL' , 'CUR_LOOP') in (0 , 1)
   BEGIN
      CLOSE CUR_LOOP
      DEALLOCATE CUR_LOOP   
   END

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetPickSlipOrders104Multi_rpt] TO nSQL 
GO