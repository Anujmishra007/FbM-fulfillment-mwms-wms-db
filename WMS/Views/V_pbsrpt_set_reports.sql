SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_pbsrpt_set_reports]
AS
SELECT [rpt_set_id]
, [rpt_seq]
, [rpt_id]
FROM [pbsrpt_set_reports] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_pbsrpt_set_reports] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_pbsrpt_set_reports] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_pbsrpt_set_reports] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_pbsrpt_set_reports] TO [NSQL]
GO
