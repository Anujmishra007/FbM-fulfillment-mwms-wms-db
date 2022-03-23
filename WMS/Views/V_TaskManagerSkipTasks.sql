SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_TaskManagerSkipTasks]
AS
SELECT [USERID]
, [TaskDetailKey]
, [TaskType]
, [Caseid]
, [Lot]
, [FromLoc]
, [ToLoc]
, [FromId]
, [ToId]
, [adddate]
FROM [TaskManagerSkipTasks] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_TaskManagerSkipTasks] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_TaskManagerSkipTasks] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_TaskManagerSkipTasks] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_TaskManagerSkipTasks] TO [NSQL]
GO
