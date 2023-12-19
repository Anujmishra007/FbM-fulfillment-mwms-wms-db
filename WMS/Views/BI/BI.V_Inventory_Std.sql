SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/***************************************************************************/
/* Called By: Logi Report or used by Kafka Connect to ADLS Gen2            */
/* Updates:                                                                */
/* Date         Author      Ver.  Purposes                                 */
/* 12-Sep-2023  KHLim  1.0  https://maersk-tools.atlassian.net/browse/SPP-29546 */
/***************************************************************************/

CREATE OR ALTER VIEW [BI].[V_Inventory_Std]
AS
SELECT
 WAREHOUSE          = F.Descr
,WH_ID              = L.Facility
,COMPANY            = T.Company
,[LOCATION]         = X.Loc
,LOCATION_TYPE      = L.LocationType
,LOCATION_STS       = L.LocationFlag
,ITEM               = X.Sku
,ITEM_DESC          = S.DESCR
,LOGISTICS_UNIT     = L.LocationCategory
,LOT                = X.Lot
,ON_HAND_QTY        = X.Qty
,LOCATION_WEIGHT    = L.WeightCapacity
,LOCATION_WEIGHT_UM = ''
,LOCATION_VOLUME    = L.CubicCapacity
,LOCATION_VOLUME_UM = ''
,INVENTORY_STS      = O.[Status]
,MAXIMUM_WEIGHT     = L.WeightCapacity
,RECEIVED_DATE      = X.EditDate
,CONSUMED_VOLUME    = CASE WHEN S.[Cube] > 0 THEN S.[Cube] ELSE S.STDCUBE END
,CONSUMED_VOLUME_UM = ''
,CONSUMED_WEIGHT    = CASE WHEN S.GrossWgt > 0 THEN S.GrossWgt WHEN S.STDGROSSWGT > 0 THEN S.STDGROSSWGT ELSE S.NetWgt END
,CONSUMED_WEIGHT_UM = ''
, X.StorerKey, F.SiteId, X.Id
FROM dbo.LOTxLOCxID AS X WITH (NOLOCK)
JOIN dbo.LOT AS O on O.Lot = X.Lot
JOIN dbo.LOC AS L WITH (NOLOCK) ON X.Loc = L.Loc
JOIN dbo.FACILITY AS F WITH (NOLOCK) ON F.Facility = L.Facility
   AND F.[Type] NOT IN ('Obsolete') AND F.SiteID NOT IN ('NA','')
JOIN dbo.STORER AS T WITH (NOLOCK) ON T.StorerKey = X.StorerKey AND T.[type] = '1' AND ISNULL(TRIM(T.[Status]),'') NOT IN ('INACTIVE','0')
JOIN dbo.SKU AS S WITH (NOLOCK) ON S.Sku = X.Sku AND S.StorerKey = X.StorerKey
WHERE X.Qty > 0 -- active records only
-- AND  EXISTS (SELECT 1 FROM dbo.ORDERS  O WITH (NOLOCK) WHERE O.StorerKey = X.StorerKey)
GO
GRANT SELECT ON  [BI].[V_Inventory_Std] TO [JReportRole]
GO
/*
SELECT 
[WAREHOUSE]
,[WH_ID]
,[COMPANY]
,[LOCATION]
,[LOCATION_TYPE]
,[LOCATION_STS]
,[ITEM]
,[ITEM_DESC]
,[LOGISTICS_UNIT]
,[LOT]
,[ON_HAND_QTY]
,[LOCATION_WEIGHT]
,[LOCATION_WEIGHT_UM]
,[LOCATION_VOLUME]
,[LOCATION_VOLUME_UM]
,[INVENTORY_STS]
,[MAXIMUM_WEIGHT]
,[RECEIVED_DATE]
,[CONSUMED_VOLUME]
,[CONSUMED_VOLUME_UM]
,[CONSUMED_WEIGHT]
,[CONSUMED_WEIGHT_UM]
,[StorerKey]
,[SiteId]
,[Id]
FROM BI.V_Inventory_Std
--WHERE StorerKey = ''

SELECT DISTINCT WH_ID, COMPANY
FROM BI.V_Inventory_Std
ORDER BY 1, 2

1.No missing location values 
2.Duplicate record check 
3.LOCATION_STS null and value check 
4.Customer info check 
*/