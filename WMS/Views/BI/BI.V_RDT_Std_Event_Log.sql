SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/***************************************************************************/
/* Called By: Logi Report or used by Kafka Connect to ADLS Gen2            */
/* Updates:                                                                */
/* Date         Author      Ver.  Purposes                                 */
/* 12-Dec-2023  KHLim  1.0  https://maersk-tools.atlassian.net/browse/SPP-31320 */
/***************************************************************************/

CREATE OR ALTER VIEW BI.V_RDT_Std_Event_Log
AS
SELECT L.EventNum
, L.EventType
, EventName = CASE L.EventType
   WHEN 0 THEN ''
   WHEN 1 THEN 'Receiving'
   WHEN 2 THEN 'Return'
   WHEN 3 THEN 'Picking'
   WHEN 4 THEN 'Move'
   WHEN 5 THEN 'Replenishment'
   WHEN 6 THEN 'XDock'
   WHEN 7 THEN 'Putaway'
   WHEN 8 THEN 'Cycle Count'
   WHEN 9 THEN 'Activity Tracking'
  END
, L.ActionType
, ActionName = ISNULL(C.[Description], '')
, L.EventDateTime
, L.UserID
, U.FullName
, L.MobileNo
, L.FunctionID
, FunctionName = M.Message_Text
, L.Facility
, F.SiteID
, L.StorerKey
, R.Company
, R.CustomerGroupCode
, L.[Location]
, L.SKU
, S.DESCR
, L.UOM
, L.QTY
, L.ReceiptKey
, L.POKey
, L.LoadKey
, L.OrderKey
, L.PickSlipNo
, L.DropID
, L.TaskDetailKey
, ITEM        = L.Sku
, WH_ID       = L.Facility
, SHIPMENT_ID = L.OrderKey
, RECEIPT_ID  = L.ReceiptKey
, L.ToLocation
, L.PutawayZone
, L.PickZone
, L.ID
, L.ToID
, L.ComponentSKU
, L.Lot
, L.ToLot
, L.Lottable01
, L.Lottable02
, L.Lottable03
, L.Lottable04
, L.Lottable05
, L.RefNo1
, L.RefNo2
, L.RefNo3
, L.RefNo4
, L.RefNo5
, L.ArchiveCop
, L.RowRef
, L.Lottable06
, L.Lottable07
, L.Lottable08
, L.Lottable09
, L.Lottable10
, L.Lottable11
, L.Lottable12
, L.Lottable13
, L.Lottable14
, L.Lottable15
, L.WaveKey
, L.TrackingNo
, L.AreaKey
, L.TTMStrategyKey
, L.ListKey
, L.UCC
, L.ReplenishmentKey
, L.DeviceID
, L.DevicePosition
, L.ToUCC
, L.SourceKey
, L.LabelNo
, L.CCKey
, L.SuggestedLOC
, L.CaseID
, L.ReasonKey
, L.TaskType
, L.ExpectedQty
, L.SerialNo
, L.PickMethod
, L.Step
, L.[Status]
, L.RDTOption
, L.PUOM_Desc
, L.MUOM_Desc
, L.PQTY
, L.ConsigneeKey
, L.CCSheetNo
, L.SealNo
, L.MBOLKey
, L.ContainerNo
, L.LicenseNo
, L.TruckID
, L.Remark
, L.ToLabelNo
, L.ExternKitKey
, L.ChildID
, L.Lane
, L.SSCC
, L.SerialNoKey
, L.Scn
, L.CartonType
, L.[Weight]
, L.ReplenishmentGroup
, L.[Length]
, L.Width
, L.Height
, L.OptionDefinition
, L.TransType
, L.CountNo
, L.CartonID
, L.Barcode
, L.ContainerKey
, L.CartonNo
, L.[Cube]
FROM RDT.rdtSTDEventLog L WITH (NOLOCK)
LEFT JOIN RDT.RDTUser U WITH (NOLOCK) ON L.UserID = U.UserName
LEFT JOIN dbo.SKU S WITH (NOLOCK) ON S.StorerKey = L.StorerKey and S.Sku = L.Sku
LEFT JOIN dbo.PACK P WITH (NOLOCK) ON S.PackKey = P.PackKey
LEFT JOIN dbo.STORER R WITH (NOLOCK) ON R.StorerKey = L.StorerKey
LEFT JOIN dbo.FACILITY F WITH (NOLOCK) ON F.Facility = L.Facility
LEFT JOIN RDT.RDTMsg M WITH (NOLOCK) ON L.FunctionID = M.Message_ID AND M.Lang_Code = 'ENG' AND M.Message_Type = 'FNC'
LEFT JOIN dbo.CODELKUP C WITH (NOLOCK) ON L.ActionType = C.Code and C.ListName = 'RDTACTTYPE' AND C.StorerKey = '' AND C.code2 = ''

GO
GRANT SELECT ON BI.V_RDT_Std_Event_Log TO JReportRole
GO
/*
SELECT *
FROM BI.V_RDT_Std_Event_Log
--WHERE StorerKey = ''

*/
