SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/***************************************************************************/
/* Called By: Logi Report or used by Kafka Connect to ADLS Gen2            */
/* Updates:                                                                */
/* Date         Author      Ver.  Purposes                                 */
/* 12-Sep-2023  KHLim  1.0  https://maersk-tools.atlassian.net/browse/SPP-29547 */
/***************************************************************************/

CREATE OR ALTER VIEW [BI].[V_Outbound_Std]
AS
SELECT
 WAREHOUSE                  = F.DESCR
,WH_ID                      = F.Facility
,COMPANY                    = T.Company
,ORDER_TYPE                 = O.DocType
,ERP_ORDER                  = O.ExternOrderKey
,SHIPMENT_ID                = O.OrderKey
,[STATUS]                   = O.[Status]
,ORDRSTATUS                 = CL.[Description]
,SHIP_TO                    = O.C_City
,SHIP_TO_COUNTRY            = O.C_Country
,CARRIER                    = M.CarrierKey
,PLANNED_SHIP_DATE          = O.DeliveryDate
,ACTUAL_DELIVERY_DATE_TIME  = POD.ActualDeliveryDate
,PLANNED_DELIVERY_DATE_TIME = O.DeliveryDate
,CUSTOMER_PO                = M.BookingReference
,INVOICE                    = O.InvoiceNo
,ERP_ORDER_LINE_NUM         = OD.OrderLineNumber --OD.ExternLineNo
,ITEM                       = OD.Sku
,ITEM_CATEGORY              = S.SKUGROUP
,ITEM_DESCRIPTION           = S.DESCR
,ITEM_LIST_PRICE            = OD.UnitPrice --S.Price
,ORDERQTY                   = OD.EnteredQTY
,QUANTITY_UM                = OD.UOM
,PLANNEDQTY                 = OD.QtyPreAllocated
,ALLOCATED_QTY              = OD.QtyAllocated
,STOP_SEQUENCE              = NULL
,PICKEDQTY                  = ISNULL(PD.Qty, 0) --OD.QtyPicked
,PACKEDQTY                  = ISNULL(PA.Qty, 0) --OD.QtyToProcess
,LOADEDQTY                  = OD.ShippedQty
,SHIPPEDQTY                 = OD.ShippedQty
,TOTAL_VOLUME               = CASE WHEN ISNULL(PH.TotCtnCube, 0) > 0 THEN PH.TotCtnCube/COUNT(1) OVER (PARTITION BY O.OrderKey) WHEN OD.Capacity > 0 THEN OD.Capacity*PD.Qty WHEN O.Capacity > 0 THEN O.Capacity/COUNT(1) OVER (PARTITION BY O.OrderKey) ELSE S.STDCUBE*PD.Qty END
,TOTAL_WEIGHT               = PD.Qty * (CASE WHEN OD.GrossWeight > 0 THEN OD.GrossWeight WHEN S.GrossWgt > 0 THEN S.GrossWgt ELSE S.STDGROSSWGT END) 
,PACK_WEIGHT                = P.NetWgt
,PARENT_CONTAINER_ID        = M.ContainerNo
,PICKSTARTDATE              = PD.AddDate
,PICKENDDATE                = PD.EndDate
,SHIPPED_END_DATE           = M.ShipDate
,LCTIME                     = ''
,SEAL_ID                    = M.SealNo
,VESSEL                     = M.Vessel
,VOYAGE                     = M.VoyageNumber
,PACKSTARTDATE              = PH.AddDate
,PACKENDDATE                = PH.EditDate
,LOADSTARTDATE              = MD.AddDate
,LOADENDDATE                = MD.EditDate
,GATEINTIME                 = NULL
,GATEOUTTIME                = NULL
,CUTOFFDATE                 = O.AddDate
,CONV_FACTOR               = 
   CASE WHEN OD.UOM=P.PackUOM1 AND P.CaseCnt>0 THEN P.CaseCnt
        WHEN OD.UOM=P.PackUOM2 AND P.InnerPack>0 THEN P.InnerPack
        WHEN OD.UOM=P.PackUOM3 AND P.Qty>0 THEN P.Qty
        WHEN OD.UOM=P.PackUOM4 AND P.Pallet>0 THEN P.Pallet
        WHEN OD.UOM=P.PackUOM5 AND P.[Cube]>0 THEN P.[Cube]
        WHEN OD.UOM=P.PackUOM6 AND P.GrossWgt>0 THEN P.GrossWgt
        WHEN OD.UOM=P.PackUOM7 AND P.NetWgt>0 THEN P.NetWgt
        WHEN OD.UOM=P.PackUOM8 AND P.OtherUnit1>0 THEN P.OtherUnit1
        WHEN OD.UOM=P.PackUOM9 AND P.OtherUnit2>0 THEN P.OtherUnit2 ELSE 1 END
, O.StorerKey, F.SiteId, O.OrderKey, OD.OrderLineNumber, PA.PickSlipNo, MD.MbolLineNumber, MD.MbolKey --, PD.PickDetailKey, LD.LoadLineNumber, L.LoadKey
FROM dbo.ORDERS AS O WITH (NOLOCK)
JOIN dbo.ORDERDETAIL AS OD WITH (NOLOCK) ON OD.OrderKey = O.OrderKey
JOIN dbo.SKU AS S WITH (NOLOCK) ON S.Sku = OD.Sku AND S.StorerKey = OD.StorerKey
JOIN dbo.PACK AS P WITH (NOLOCK) ON P.PackKey = S.PACKKey
JOIN dbo.STORER AS T WITH (NOLOCK) ON O.StorerKey = T.StorerKey AND T.[type] = '1' AND ISNULL(TRIM(T.[Status]),'') NOT IN ('INACTIVE','0')
JOIN dbo.FACILITY AS F WITH (NOLOCK) ON O.Facility = F.Facility
   AND F.[Type] NOT IN ('Obsolete') AND F.SiteID NOT IN ('NA','')
LEFT JOIN dbo.CODELKUP AS CL WITH (NOLOCK) ON CL.LISTNAME = 'ORDRSTATUS' AND O.[Status] = CL.Code AND CL.code2 = '' AND CL.StorerKey = ''
LEFT JOIN dbo.PACKHEADER AS PH WITH (NOLOCK) ON PH.OrderKey = O.OrderKey
LEFT JOIN dbo.PACKDETAIL AS PA WITH (NOLOCK) ON PA.PickSlipNo = PH.PickSlipNo AND PA.StorerKey = OD.StorerKey AND PA.Sku = OD.Sku
LEFT JOIN dbo.MBOLDETAIL AS MD WITH (NOLOCK) ON MD.OrderKey = O.OrderKey
LEFT JOIN dbo.MBOL AS M WITH (NOLOCK) ON M.MbolKey = MD.MbolKey
LEFT JOIN dbo.POD WITH (NOLOCK) ON POD.Mbolkey = MD.MbolKey AND POD.Mbollinenumber = MD.MbolLineNumber --POD.OrderKey = O.OrderKey
OUTER APPLY (
   SELECT Qty = SUM(Qty), AddDate = MIN(AddDate), EndDate = MAX(AddDate)--EffectiveDate
   , OrderKey, OrderLineNumber
   FROM dbo.PICKDETAIL AS PD WITH (NOLOCK)
   WHERE PD.OrderKey = OD.OrderKey AND PD.OrderLineNumber = OD.OrderLineNumber AND PD.Status = OD.Status
   GROUP BY OrderKey, OrderLineNumber
) AS PD
WHERE EXISTS (SELECT 1 FROM dbo.SKUxLOC X WITH (NOLOCK) WHERE X.StorerKey = O.Storerkey AND X.Qty > 0)
GO
GRANT SELECT ON  [BI].[V_Outbound_Std] TO [JReportRole]
GO
/*
SELECT 
 [WAREHOUSE]
,[WH_ID] --10. No. of SITE_ID and WH_IDs mapped. (Every site should be mapped to a particular SITE_ID)
,[SiteId] --10. No. of SITE_ID and WH_IDs mapped. (Every site should be mapped to a particular SITE_ID)
,[COMPANY]
,[ORDER_TYPE]
,[ERP_ORDER]
,[SHIPMENT_ID] --9.Shipment_ID and erp_order_line_number not null. 
,[ERP_ORDER_LINE_NUM] --9.Shipment_ID and erp_order_line_number not null. 
,[STATUS]
,[ORDRSTATUS]
,[SHIP_TO]
,[SHIP_TO_COUNTRY]
,[CARRIER]
,[PLANNED_SHIP_DATE] --5. Planned shipped date, missing-> Fulfilment sites. 
,[PLANNED_DELIVERY_DATE_TIME]
,[ACTUAL_DELIVERY_DATE_TIME]
,[CUSTOMER_PO]
,[INVOICE]
,[ITEM]
,[ITEM_CATEGORY]
,[ITEM_DESCRIPTION]
,[ITEM_LIST_PRICE]
,[ORDERQTY]
,[QUANTITY_UM]  --2. UOM -> Unit_of_Measured_quantity missing. 
,[PLANNEDQTY]
,[ALLOCATED_QTY]
,[STOP_SEQUENCE]
,[PICKEDQTY]
,[PICKSTARTDATE]
,[PICKENDDATE] --3. Pick end date missing, but picked qty available
,[PACKEDQTY]
,[PACKSTARTDATE]
,[PACKENDDATE] --4.Pack end date missing, but packed qty available. 
,[LOADEDQTY]
,[SHIPPEDQTY] --8.Anamolies of Data like high shipped quantity needs to be checked. 
,[SHIPPED_END_DATE] --1. Shipped end date missing, but shipped quantity available
,[TOTAL_VOLUME]
,[TOTAL_WEIGHT]
,[PACK_WEIGHT]
,[PARENT_CONTAINER_ID] --13.Parent_container_id should not be nulls, part of PK. 
,[LCTIME]
,[SEAL_ID]
,[VESSEL]
,[VOYAGE]
,[LOADSTARTDATE]
,[LOADENDDATE]
,[GATEINTIME]
,[GATEOUTTIME]
,[CUTOFFDATE]
,[CONV_FACTOR]
,[StorerKey]

,[OrderKey]
,[OrderLineNumber]
,[PickSlipNo]
,[MbolLineNumber]
,[MbolKey]
FROM BI.V_Outbound_Std
--WHERE StorerKey = ''

SELECT DISTINCT WH_ID, COMPANY
FROM BI.V_Outbound_Std
ORDER BY 1, 2

6.Work status missing. 
7.% of picks, pack, shipped qty missing from the total date. 
11.Customer information for each site, should not be any nulls. 
12. CBM should not be null for Consolidation sites. 
*/
