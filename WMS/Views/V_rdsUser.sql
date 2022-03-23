SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_rdsUser]
as
SElect
UserId	,
Password	,
FirstName	,
LastName	,
DefaultStorer	,
MenuID	,
LastLogin	,
AddDate	,
AddWho	,
EditDate	,
EditWho
FROM rdsUser with (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_rdsUser] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_rdsUser] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_rdsUser] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_rdsUser] TO [NSQL]
GO
