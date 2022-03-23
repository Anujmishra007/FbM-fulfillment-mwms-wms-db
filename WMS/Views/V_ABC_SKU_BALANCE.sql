SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_ABC_SKU_BALANCE]
AS
SELECT     dbo.LOC.Facility
         , dbo.SKUxLOC.Storerkey
         , dbo.SKUxLOC.Sku
         , Qty = SUM(dbo.SKUxLOC.Qty)
         , QtyAllocated = SUM(dbo.SKUxLOC.QtyAllocated)
         , QtyPicked    = SUM(dbo.SKUxLOC.QtyPicked)
FROM  dbo.SKUxLOC WITH (NOLOCK)
JOIN  dbo.LOC     WITH (NOLOCK) ON (dbo.SKUxLOC.Loc = dbo.LOC.Loc)
GROUP BY dbo.LOC.Facility
      ,  dbo.SKUxLOC.Storerkey
      ,  dbo.SKUxLOC.Sku

GO
GRANT DELETE ON  [dbo].[V_ABC_SKU_BALANCE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ABC_SKU_BALANCE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ABC_SKU_BALANCE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ABC_SKU_BALANCE] TO [NSQL]
GO
