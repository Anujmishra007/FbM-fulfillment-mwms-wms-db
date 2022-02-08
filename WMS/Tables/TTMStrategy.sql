CREATE TABLE [dbo].[TTMStrategy]
(
[TTMStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategy_TTMStrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategy_Descr] DEFAULT (' '),
[InterleaveTasks] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategy_InterleaveTasks] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TTMStrategy_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategy_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TTMStrategy_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategy_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TTMStrategy] ADD CONSTRAINT [PKTTMStrategy] PRIMARY KEY NONCLUSTERED ([TTMStrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TTMStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TTMStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TTMStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TTMStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a description of the task dispatch sub strategy. Required field.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether the system will rotate through the task types when assigning tasks to users. For example, if the user previously got a putaway task, the next task may be a pick task. A value of 0 = No and 1 = Yes. Required field.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'InterleaveTasks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a unique code identifying the task dispatch sub strategy. Required field.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategy', 'COLUMN', N'TTMStrategyKey'
GO
