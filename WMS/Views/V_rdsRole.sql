SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create view [dbo].[V_rdsRole]
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
