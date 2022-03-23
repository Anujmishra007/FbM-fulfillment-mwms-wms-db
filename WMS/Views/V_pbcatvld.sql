SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_pbcatvld]
AS
SELECT [pbv_name]
, [pbv_vald]
, [pbv_type]
, [pbv_cntr]
, [pbv_msg]
FROM [pbcatvld] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_pbcatvld] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_pbcatvld] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_pbcatvld] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_pbcatvld] TO [NSQL]
GO
