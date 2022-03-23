SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_LotxIdDetail]
AS
SELECT [LotxIdDetailKey]
, [ReceiptKey]
, [ReceiptLineNumber]
, [PickDetailKey]
, [IOFlag]
, [Lot]
, [ID]
, [Wgt]
, [OrderKey]
, [OrderLineNumber]
, [Other1]
, [Other2]
, [Other3]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [LotxIdDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_LotxIdDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_LotxIdDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_LotxIdDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_LotxIdDetail] TO [NSQL]
GO
