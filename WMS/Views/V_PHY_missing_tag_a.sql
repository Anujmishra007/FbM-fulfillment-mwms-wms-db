SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_PHY_missing_tag_a] 
AS 
SELECT [InventoryTag]
FROM [PHY_missing_tag_a] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_PHY_missing_tag_a] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PHY_missing_tag_a] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PHY_missing_tag_a] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PHY_missing_tag_a] TO [NSQL]
GO
