SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_pbcatfmt]
AS
SELECT [pbf_name]
, [pbf_frmt]
, [pbf_type]
, [pbf_cntr]
FROM [pbcatfmt] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_pbcatfmt] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_pbcatfmt] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_pbcatfmt] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_pbcatfmt] TO [NSQL]
GO
