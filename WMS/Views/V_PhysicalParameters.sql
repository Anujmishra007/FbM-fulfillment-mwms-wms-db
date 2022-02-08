SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_PhysicalParameters] 
AS 
SELECT [PhysicalParmKey]
, [StorerKeyMin]
, [StorerKeyMax]
, [SkuMin]
, [SkuMax]
FROM [PhysicalParameters] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_PhysicalParameters] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PhysicalParameters] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PhysicalParameters] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PhysicalParameters] TO [NSQL]
GO
