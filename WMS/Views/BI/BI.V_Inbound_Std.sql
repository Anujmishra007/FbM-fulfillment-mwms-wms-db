SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/***************************************************************************/
/* Called By: Logi Report or used by Kafka Connect to ADLS Gen2            */
/* Updates:                                                                */
/* Date         Author      Ver.  Purposes                                 */
/* 12-Sep-2023  KHLim  1.0  https://maersk-tools.atlassian.net/browse/SPP-29545 */
/***************************************************************************/

CREATE OR ALTER VIEW [BI].[V_Inbound_Std]
AS
SELECT 
 WAREHOUSE                 = F.DESCR
--,R.ReceiptKey, RD.ReceiptLineNumber, i.itrnkey -- check duplicates
,WH_ID                     = F.Facility --F.SiteID
,VENDOR_CODE               = R.CarrierKey
,VENDOR_NAME               = CASE WHEN ISNULL(V.Company,'')<>'' THEN V.Company ELSE R.SellerName END
,CLIENT_NAME               = T.Company
,RETURN_SO_NUMBER          = R.TrackingNo
,TRUCK_NUMBER              = R.VehicleNumber
,CONTAINER_NUMBER          = R.ContainerKey
,VEHICLE_TYPE              = ''
,ORDER_TYPE                = R.RECType
,ORIGIN_COUNTRY            = R.OriginCountry
,ORIGIN_CITY               = CASE WHEN ISNULL(CarrierCity,'')<>'' THEN CarrierCity ELSE F.City END
,[STATUS]                  = R.[Status]
,RECSTATUS                 = CL.[Description]
,PO_BOOKING_RECEIVED_DATE  = R.AddDate
,PO_EXPECTED_RECEIVED_DATE = R.ReceiptDate
,PO_NUMBER                 = R.ExternReceiptKey
,PO_LINE_NUMBER            = RD.ExternLineNo
,SKU                       = RD.Sku
,ITEM_DESCRIPTION          = S.DESCR
,ITEM_CATEGORY             = S.SKUGROUP
,RECEIVING_START_DATE      = R.EffectiveDate
,RECEIVING_END_DATE        = R.FinalizeDate
,PUTAWAY_START_DATE_TIME   = I.AddDate
,PUTAWAY_END_DATE_TIME     = I.EditDate
-- ,R.[Cube] ,RD.[Cube], S.STDCUBE -- check multiplier values
,BOOKED_CBM                = RD.QtyExpected * S.STDCUBE
,RECEIVED_CBM              = RD.QtyReceived * S.STDCUBE
,BOOKING_QTY               = RD.QtyExpected
,SHORTORUNDER_RECEIPTQTY   = RD.QtyExpected - RD.QtyReceived
,RECEIVED_QTY              = CASE WHEN RD.ConditionCode <>'DAMAGE' THEN RD.QtyReceived ELSE 0 END
,DAMAGEQTY                 = CASE WHEN RD.ConditionCode = 'DAMAGE' THEN RD.QtyReceived ELSE 0 END
,WEIGHT_UM                 = R.[WeightUnit]
,DIMENSION_UM              = ''
,HEIGHT                    = S.Height
,WIDTH                     = S.Width
,[LENGTH]                  = S.[Length]
,PUT_AWAY_QTY              = I.Qty
,PUT_AWAY_UOM              = I.UOM
,ITEM_WEIGHT               = CASE WHEN S.GrossWgt > 0 THEN S.GrossWgt ELSE S.STDGROSSWGT END
,NO_OF_PIECE               = RD.CaseCnt
,BOOKED_UOM                = RD.UOM
,RECEIVED_UOM              = RD.UOM
,LICENSE_PLATE_NO          = I.ToID
,CONV_FACTOR               = 
   CASE WHEN RD.UOM=P.PackUOM1 AND P.CaseCnt>0 THEN P.CaseCnt
        WHEN RD.UOM=P.PackUOM2 AND P.InnerPack>0 THEN P.InnerPack
        WHEN RD.UOM=P.PackUOM3 AND P.Qty>0 THEN P.Qty
        WHEN RD.UOM=P.PackUOM4 AND P.Pallet>0 THEN P.Pallet
        WHEN RD.UOM=P.PackUOM5 AND P.[Cube]>0 THEN P.[Cube]
        WHEN RD.UOM=P.PackUOM6 AND P.GrossWgt>0 THEN P.GrossWgt
        WHEN RD.UOM=P.PackUOM7 AND P.NetWgt>0 THEN P.NetWgt
        WHEN RD.UOM=P.PackUOM8 AND P.OtherUnit1>0 THEN P.OtherUnit1
        WHEN RD.UOM=P.PackUOM9 AND P.OtherUnit2>0 THEN P.OtherUnit2 ELSE 1 END
,RECEIPT_ID                = R.ExternReceiptKey
,SO_NUMBER                 = R.POKey
, R.StorerKey, F.SiteId
FROM dbo.RECEIPT AS R WITH (NOLOCK)
JOIN dbo.RECEIPTDETAIL AS RD WITH (NOLOCK) ON R.ReceiptKey = RD.ReceiptKey
JOIN dbo.SKU AS S WITH (NOLOCK) ON S.Sku = RD.Sku AND S.StorerKey = RD.StorerKey
JOIN dbo.PACK AS P WITH (NOLOCK) ON P.PackKey = S.PACKKey
JOIN dbo.FACILITY AS F WITH (NOLOCK) ON R.Facility = F.Facility
   AND F.[Type] NOT IN ('Obsolete') AND F.SiteID NOT IN ('NA','')
JOIN dbo.STORER AS T WITH (NOLOCK) ON R.StorerKey = T.StorerKey AND T.[type] = '1' AND ISNULL(TRIM(T.[Status]),'') NOT IN ('INACTIVE','0')
LEFT JOIN dbo.STORER AS V WITH (NOLOCK) ON R.CarrierKey = V.StorerKey AND V.[type] = '5'
LEFT JOIN dbo.CODELKUP AS CL WITH (NOLOCK) ON CL.LISTNAME = 'RECSTATUS' AND R.[Status] = CL.Code AND CL.code2 = '' AND CL.StorerKey = ''
LEFT JOIN dbo.ITRN AS I WITH (NOLOCK) ON I.SourceType IN ('ntrReceiptDetailUpdate', 'ntrReceiptDetailInsert')
   AND I.SourceKey = RD.ReceiptKey + RD.ReceiptLineNumber AND I.TranType IN ('DP') AND I.StorerKey = RD.StorerKey AND I.Sku = RD.Sku
--LEFT JOIN dbo.ITRN AS PA WITH (NOLOCK) ON PA.SourceType IN ('rdtfnc_Move_UCC', 'rdtfnc_MoveToUCC', 'rdtfnc_Move_SKU', 'rdtfnc_Move_LOC', 'rdtfnc_Move_ID', 'rdt_Putaway', 'WSPUTAWAY', 'rdt_1764ClosePlt01', '')
--   AND PA.SourceKey = '' AND PA.TranType IN ('MV') AND PA.StorerKey = RD.StorerKey AND PA.Sku = RD.Sku
WHERE EXISTS (SELECT 1 FROM dbo.SKUxLOC X WITH (NOLOCK) WHERE X.StorerKey = T.Storerkey AND X.Qty > 0)
GO
GRANT SELECT ON  [BI].[V_Inbound_Std] TO [JReportRole]
GO
/*
SELECT *
FROM BI.V_Inbound_Std
WHERE StorerKey = ''


SELECT DISTINCT WH_ID, CLIENT_NAME
FROM BI.V_Inbound_Std
ORDER BY 1, 2
*/
