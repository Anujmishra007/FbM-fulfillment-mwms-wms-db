SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_TaskManagerReason] AS SELECT * FROM TaskManagerReason WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TaskManagerReason] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TaskManagerReason] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TaskManagerReason] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TaskManagerReason] TO [NSQL]
GO
