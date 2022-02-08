SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_PHY_outofrange_tag_b] 
AS 
SELECT [InventoryTag]
FROM [PHY_outofrange_tag_b] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_PHY_outofrange_tag_b] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PHY_outofrange_tag_b] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PHY_outofrange_tag_b] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PHY_outofrange_tag_b] TO [NSQL]
GO
