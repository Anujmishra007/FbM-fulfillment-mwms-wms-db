SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_IDSCNDailyInventory]
AS
SELECT [Storerkey]
, [Sku]
, [Loc]
, [Lot]
, [Id]
, [Qty]
, [Lottable02]
, [Lottable04]
, [AddDate]
, [Addwho]
, [EditDate]
, [EditWho]
, [InventoryDate]
FROM [IDSCNDailyInventory] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_IDSCNDailyInventory] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_IDSCNDailyInventory] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_IDSCNDailyInventory] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_IDSCNDailyInventory] TO [NSQL]
GO
