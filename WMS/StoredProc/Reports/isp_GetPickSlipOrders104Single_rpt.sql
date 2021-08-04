IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPickSlipOrders104Single_rpt]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetPickSlipOrders104Single_rpt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: isp_GetPickSlipOrders104Single_rpt                          */
/* Creation Date: 26-Dec-2019                                           */
/* Copyright: LF Logistics                                              */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  WMS-11495 - IKEA Pick Slip Single Order                    */
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
/* 21/07/2021   Mingle    1.1   WMS-17541 Add codelkup.long(ML01)       */
/************************************************************************/

CREATE PROC isp_GetPickSlipOrders104Single_rpt 
            @c_loadkey     NVARCHAR(10),
            @c_Batchkey    NVARCHAR(10) = ''

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
         , Count(Distinct(PD.SKU)) AS TotalSKU
         , SUM(PD.Qty) AS TotalUnit
         , #Temp_Zone.Descr AS AllZones
         , Loc.PickZone AS PickZone
         , ISNULL(CL.long,'') AS Title --ML01
   FROM ORDERS OH (NOLOCK)
   JOIN PICKDETAIL PD (NOLOCK) ON PD.ORDERKEY = OH.ORDERKEY
   JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.ORDERKEY = OH.ORDERKEY
   --JOIN PICKHEADER PH (NOLOCK) ON PH.ORDERKEY = OH.ORDERKEY
   JOIN LOC (NOLOCK) ON LOC.LOC = PD.LOC
   LEFT JOIN #Temp_Zone ON #Temp_Zone.BatchKey = PD.Pickslipno
   LEFT JOIN CODELKUP CL (NOLOCK) ON CL.Listname = 'IKEATITLE' AND CL.Storerkey = oh.StorerKey AND CL.Code = oh.ShipperKey --ML01
   WHERE LPD.Loadkey = @c_loadkey
     AND OH.ECOM_Single_Flag = 'S'
     AND PD.Pickslipno = CASE WHEN @c_batchkey = '' THEN PD.Pickslipno ELSE @c_batchkey END
   GROUP BY OH.Loadkey
          , PD.Pickslipno 
          , #Temp_Zone.Descr 
          , Loc.PickZone
          , ISNULL(CL.long,'') --ML01


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
GRANT EXECUTE ON [dbo].[isp_GetPickSlipOrders104Single_rpt] TO nSQL 
GO