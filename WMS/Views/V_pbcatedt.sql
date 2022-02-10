SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_pbcatedt] 
AS 
SELECT [pbe_name]
, [pbe_edit]
, [pbe_type]
, [pbe_cntr]
, [pbe_seqn]
, [pbe_flag]
, [pbe_work]
FROM [pbcatedt] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_pbcatedt] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_pbcatedt] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_pbcatedt] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_pbcatedt] TO [NSQL]
GO
