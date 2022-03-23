SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_pbsrpt_sets]
AS
SELECT [rpt_set_id]
, [name]
FROM [pbsrpt_sets] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_pbsrpt_sets] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_pbsrpt_sets] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_pbsrpt_sets] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_pbsrpt_sets] TO [NSQL]
GO
