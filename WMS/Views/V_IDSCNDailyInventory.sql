SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_IDSCNDailyInventory] 
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
