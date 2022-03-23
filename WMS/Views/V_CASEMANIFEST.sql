SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_CASEMANIFEST]
AS
SELECT [CaseId]
, [StorerKey]
, [Sku]
, [Loc]
, [Status]
, [ExpectedReceiptKey]
, [ExpectedPOKey]
, [ReceivedReceiptKey]
, [ReceivedPOKey]
, [ReceiptDate]
, [ExpectedClpOrderKey]
, [ShippedClpOrderKey]
, [Qty]
, [ShipStatus]
, [Shipdate]
, [OSDCode]
, [OSDQTY]
, [ID]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [TimeStamp]
FROM [CASEMANIFEST] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_CASEMANIFEST] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_CASEMANIFEST] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_CASEMANIFEST] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_CASEMANIFEST] TO [NSQL]
GO
