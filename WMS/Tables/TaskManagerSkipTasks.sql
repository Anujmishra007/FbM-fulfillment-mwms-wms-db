CREATE TABLE [dbo].[TaskManagerSkipTasks]
(
[USERID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Caseid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[adddate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerSkipTasks_adddate] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TASKMANAGERSKIPTASKS_adddate] ON [dbo].[TaskManagerSkipTasks] ([adddate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TMSKIPTASKS_TASKDETAILKEY] ON [dbo].[TaskManagerSkipTasks] ([TaskDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IDX_TMSKIPTASKS_USERID] ON [dbo].[TaskManagerSkipTasks] ([USERID], [TaskDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TaskManagerSkipTasks] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskManagerSkipTasks] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskManagerSkipTasks] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskManagerSkipTasks] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'Caseid'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ID or Tag number assigned to the Commodity to be moved. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'FromId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Task Detail.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'New ID or Tag number to be assigned to the Commodity at the location. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'ToId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Users.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerSkipTasks', 'COLUMN', N'USERID'
GO
