SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_pbsrpt_category] 
AS 
SELECT [category_id]
, [category]
FROM [pbsrpt_category] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_pbsrpt_category] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_pbsrpt_category] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_pbsrpt_category] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_pbsrpt_category] TO [NSQL]
GO
