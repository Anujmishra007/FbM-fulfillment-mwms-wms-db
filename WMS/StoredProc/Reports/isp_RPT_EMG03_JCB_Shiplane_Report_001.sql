SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_Shiplane_Report_001                 */
/* Creation Date: 10-02-2025										       */
/* Copyright: Maersk CE EUR                                                */
/* Written by: VMA237                                                      */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Called By: isp_RPT_EMG03_JCB_Shiplane_Report_001		                   */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 10-02-2025   VMA237  1.0   Initial Version (WCEET-2813)                 */
/* 02-02-2026   AGM046	2.0	  Added status Marshalled					   */
/*                                                                         */
/***************************************************************************/

CREATE OR ALTER PROC [BI].[isp_RPT_EMG03_JCB_Shiplane_Report_001]
     @Facility						NVARCHAR (30) 
	 ,@StorerKey					NVARCHAR (30) 
	 ,@BusinessUnit					NVARCHAR (30)	= ''
	 ,@Location						NVARCHAR (30)	= ''

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

/* testing data */
--declare 
-- @Facility			NVARCHAR (30)	= 'EMG03'
--,@StorerKey			NVARCHAR (30)	= 'JCB'
--,@BusinessUnit		NVARCHAR (30)	= ''
--,@Location			NVARCHAR (30)	= ''

 SELECT
   	pcd.Loc AS 'Location'
	  ,CASE            
	  WHEN ps.PickStatusInt IS NULL AND ISNULL(pcd.[Status],'') <> '' THEN CONCAT('Other: ', pcd.[Status])
	  WHEN ps.PickStatusInt < 5 THEN 'In Process'
	  WHEN ps.PickStatusInt = 9 THEN 'Shipped'
	  -- LOADED 
	  WHEN os.OrderStatusInt = 5
	  AND ps.PickStatusInt <> 9
	  AND stt.OrderKey IS NOT NULL
	  THEN 'Loaded'
	  -- MARSHALLED 
	  WHEN ck.Short IS NOT NULL
	  AND (ps.PickStatusInt IS NULL or ps.PickStatusInt <> 9)
	  THEN 'Marshalled'
	  WHEN ps.PickStatusInt >= 5 THEN 'Picked'
	  END AS 'Pick Status'
	  --
	  ,CASE WHEN ISNULL(pcd.DropID, '') <> '' THEN pcd.DropID else pcd.ID END AS 'LPN'
	  ,lot.Lottable03 AS 'Owner'
	  ,pcd.Sku AS 'SKU'
	  ,sku.DESCR AS 'Description'
	  ,pcd.Qty AS 'Quantity'
	  ,orm.OrderKey AS 'Order ID'
	  ,orm.ExternOrderKey AS 'Order Name'
	  ,orm.UserDefine09 AS 'Wave no'
	  ,orm.DeliveryDate AS 'Order delivery date'
	  ,itrn.AddWho AS 'Picker ID'
	  ,itrn.AddDate AS 'Pick Time'
	  ,CASE
	  WHEN os.OrderStatusInt = 5
	  AND ps.PickStatusInt <> 9
	  AND stt.OrderKey IS NOT NULL
	  THEN orm.IntermodalVehicle
	  END AS 'IS loaded' 
		   --
	FROM dbo.V_ORDERS orm WITH(NOLOCK)
	INNER JOIN dbo.V_PICKDETAIL pcd WITH(NOLOCK)
		      ON pcd.Storerkey = orm.StorerKey
		     AND pcd.OrderKey  = orm.OrderKey
	-- (avoud error with 'CANC', etc.)
	CROSS apply (SELECT TRY_CONVERT(int, orm.[Status]) AS OrderStatusInt) os
	CROSS apply (SELECT TRY_CONVERT(int, pcd.[Status]) AS PickStatusInt) ps
	LEFT JOIN dbo.V_LOTATTRIBUTE lot WITH(NOLOCK)
		     ON lot.StorerKey = pcd.Storerkey
		    AND lot.Lot       = pcd.Lot
		    AND lot.Sku       = pcd.Sku
	       --
	LEFT JOIN dbo.V_SKU sku WITH(NOLOCK)
		     ON sku.Facility  = orm.Facility
		    AND sku.StorerKey = pcd.Storerkey
		    AND sku.Sku       = pcd.Sku
	       --
	LEFT JOIN dbo.V_ITRN itrn WITH(NOLOCK)
		     ON itrn.StorerKey  = pcd.Storerkey
		    AND itrn.FROMID     = pcd.ID
		    AND itrn.Lot        = pcd.Lot
		    AND itrn.Sku        = pcd.Sku
		    AND itrn.SourceType = 'rdt_PickPallet_CONfirm'
	-- Marshalled by LPN
	LEFT JOIN dbo.CODELKUP ck WITH(NOLOCK)
		     ON ck.LIStName  = 'JCBCOMPML'
		    AND ck.Storerkey = orm.StorerKey
		    AND ck.Short     = pcd.Loc
	-- Loaded by LPN (ScanToTruck status 9)
	LEFT JOIN rdt.rdtScanToTruck stt WITH(NOLOCK)
		     ON stt.Orderkey = pcd.OrderKey
		    AND stt.URNNo    = pcd.DropID
		    AND stt.Status   = '9'
      WHERE orm.Facility = @Facility
        AND orm.StorerKey = @StorerKey
	      AND ((ISNULL(lot.Lottable03, '') = ISNULL(@BusinessUnit, '')) or ISNULL(@BusinessUnit, '') = '')
        AND ((ISNULL(pcd.Loc, '') = ISNULL(@LocatiON, '')) or ISNULL(@LocatiON, '') = '');
	
END
GO
