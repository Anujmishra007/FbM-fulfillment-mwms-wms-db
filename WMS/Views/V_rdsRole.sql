SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_rdsRole]
as
SElect
RoleID	,
RoleDesc	,
AddDate	,
AddWho
from rdsRole with (NOLOCK)


GO
GRANT DELETE ON  [dbo].[V_rdsRole] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdsRole] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdsRole] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdsRole] TO [NSQL]
GO
