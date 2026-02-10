
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_Shiplane_Report_001                 */
/* Creation Date: 10-02-2025										                           */
/* Copyright: Maersk CE EUR                                                */
/* Written by: VMA237                                                      */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Called By: isp_RPT_EMG03_JCB_Shiplane_Report_001		                     */
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
/*																                                         */
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

select pcd.Loc as 'Location'
	   ,case when pcd.[Status] < 5 then 'In Process'
			 when pcd.[Status] = 9 then 'Shipped'
			 when pcd.[Status] >= 5 and left(pcd.Loc, 3) not in ('ESM','ENM') then 'Picked'
			 when pcd.[Status] >= 5 and left(pcd.Loc, 3) in ('ESM','ENM') then 'Loaded' end as 'Pick Status'	   	
	   ,case when isnull(pcd.DropID, '') != '' then pcd.DropID else pcd.ID end as 'LPN'
	   ,lot.Lottable03 as 'Owner'
	   ,pcd.Sku as 'SKU'
	   ,sku.DESCR as 'Description'
	   ,pcd.Qty as 'Quantity'
	   ,orm.OrderKey as 'Order ID'
	   ,orm.ExternOrderKey as 'Order Name'
	   ,orm.UserDefine09 as 'Wave no'
	   ,orm.DeliveryDate as 'Order delivery date'
	   ,itrn.AddWho as 'Picker ID'
	   ,itrn.AddDate  as 'Pick Time'
	   ,case when pcd.[Status] in ('4', '5') and left(pcd.Loc, 3) in ('ESM','ENM') then orm.IntermodalVehicle end as 'Is loaded'
from V_ORDERS  orm (NOLOCK)
	 inner join V_PICKDETAIL pcd (NOLOCK) on pcd.Storerkey = orm.StorerKey and pcd.OrderKey = orm.OrderKey
	 left join V_LOTATTRIBUTE lot (NOLOCK) on lot.StorerKey = pcd.Storerkey and lot.Lot = pcd.Lot and lot.Sku = pcd.Sku
	 left join V_SKU sku (NOLOCK) on sku.Facility = orm.Facility and sku.StorerKey = pcd.Storerkey and sku.Sku = pcd.Sku
	 left join V_ITRN itrn (NOLOCK) on itrn.StorerKey = pcd.Storerkey and itrn.FromID = pcd.ID and itrn.Lot = pcd.Lot and itrn.Sku = pcd.Sku and itrn.SourceType = 'rdt_PickPallet_Confirm'
where orm.Facility = @Facility
	  and orm.StorerKey = @StorerKey
	  and ((isnull(lot.Lottable03, '') = isnull(@BusinessUnit, '')) or isnull(@BusinessUnit, '') = '')
	  and ((isnull(pcd.Loc, '') = isnull(@Location, '')) or isnull(@Location, '') = '')
	
END
GO


