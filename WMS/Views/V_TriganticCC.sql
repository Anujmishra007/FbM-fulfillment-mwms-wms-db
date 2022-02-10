SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_TriganticCC] 
AS 
SELECT [CCKey]
, [Facility]
, [StorerKey]
, [SKU]
, [Qty_Before]
, [Qty_After]
, [Adddate]
, [AdjCode]
, [AdjCodeDesc]
, [AdjType]
FROM [TriganticCC] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_TriganticCC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TriganticCC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TriganticCC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TriganticCC] TO [NSQL]
GO
