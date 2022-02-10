SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_PHYSICAL] 
AS 
SELECT [Team]
, [StorerKey]
, [Sku]
, [Loc]
, [Lot]
, [Id]
, [InventoryTag]
, [Qty]
, [PackKey]
, [UOM]
, [TrafficCop]
, [Timestamp]
, [SheetNoKey]
FROM [PHYSICAL] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_PHYSICAL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PHYSICAL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PHYSICAL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PHYSICAL] TO [NSQL]
GO
