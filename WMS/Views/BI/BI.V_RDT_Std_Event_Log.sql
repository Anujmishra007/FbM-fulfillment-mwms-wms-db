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
--, DefaultUOM = CASE ISNULL(NULLIF(L.UOM,''),U.DefaultUOM) WHEN '2' THEN 'Case' -- link sku & pack to get PackUOM?
--         WHEN '3' THEN 'Inner pack'
--         WHEN '6' THEN 'EA'
--         WHEN '1' THEN 'Pallet'
--         WHEN '4' THEN 'Other unit 1'
--         WHEN '5' THEN 'Other unit 2'
--         END
--, QTYUOM = CASE 
--      WHEN L.UOM IN (3,    P.PACKUOM2) THEN P.InnerPack
--      WHEN L.UOM IN (6,    P.PACKUOM3) THEN P.QTY
--      WHEN L.UOM IN (1, 2, P.PACKUOM4) THEN P.Pallet
--      WHEN L.UOM IN (4,    P.PACKUOM8) THEN P.OtherUnit1
--      WHEN L.UOM IN (      P.PACKUOM9) THEN P.OtherUnit2
--  END
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
