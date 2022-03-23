SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[v_ItemCost]
AS
Select	storerkey,
	sku = sku,
	cost = cost,
	busr10 = busr10
From	sku (nolock)




GO
GRANT DELETE ON  [dbo].[v_ItemCost] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[v_ItemCost] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[v_ItemCost] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[v_ItemCost] TO [NSQL]
GO
