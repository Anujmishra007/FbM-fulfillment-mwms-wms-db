SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_user_connections]
AS
	SELECT login_name, login_date
   FROM JPTSecure..user_connections (nolock)


GO
GRANT DELETE ON  [dbo].[V_user_connections] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_user_connections] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_user_connections] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_user_connections] TO [NSQL]
GO
