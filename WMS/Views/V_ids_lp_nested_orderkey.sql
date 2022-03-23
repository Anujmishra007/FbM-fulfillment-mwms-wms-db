SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_ids_lp_nested_orderkey]
AS
SELECT [orderkey]
, [storerkey]
FROM [ids_lp_nested_orderkey] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ids_lp_nested_orderkey] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ids_lp_nested_orderkey] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ids_lp_nested_orderkey] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ids_lp_nested_orderkey] TO [NSQL]
GO
