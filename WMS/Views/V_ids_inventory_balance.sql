SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_ids_inventory_balance] 
AS 
SELECT [exportdate]
, [storerkey]
, [sku]
, [lot]
, [id]
, [loc]
, [putawayzone]
, [qty]
, [qtyallocated]
, [qtypicked]
FROM [ids_inventory_balance] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_ids_inventory_balance] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ids_inventory_balance] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ids_inventory_balance] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ids_inventory_balance] TO [NSQL]
GO
