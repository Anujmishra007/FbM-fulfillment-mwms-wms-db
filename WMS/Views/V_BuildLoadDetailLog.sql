SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_BuildLoadDetailLog]
AS
SELECT *
FROM   [dbo].[BuildLoadDetailLog]  WITH (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_BuildLoadDetailLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_BuildLoadDetailLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_BuildLoadDetailLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_BuildLoadDetailLog] TO [NSQL]
GO
