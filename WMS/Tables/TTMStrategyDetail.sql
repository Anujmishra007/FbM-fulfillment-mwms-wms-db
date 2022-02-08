CREATE TABLE [dbo].[TTMStrategyDetail]
(
[TTMStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMStrategyKey] DEFAULT (' '),
[TTMStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMStrategyLineNumber] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_Descr] DEFAULT (' '),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TaskType] DEFAULT (' '),
[TTMPickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMPickCode] DEFAULT (' '),
[TTMOverride] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_TTMOverride] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TTMStrategyDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TTMStrategyDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TTMStrategyDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TTMStrategyDetail] ADD CONSTRAINT [PKTTMStrategyDetail] PRIMARY KEY NONCLUSTERED ([TTMStrategyKey], [TTMStrategyLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TTMStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a description of the step', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of task to be dispatched in this step. The same task type can be used on more than one row; for example, you may dispatch Pick, then PutAway, then Pick, then PutAway, etc. Options include: CC = Cycle Counts, etc', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TaskType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the stored procedure that creates the set of candidate tasks based on this task type', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TTMPickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Task Detail Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TTMStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates order in which step should be processed during task dispatch process. System-assigned, overwrite this number by typing over it.', 'SCHEMA', N'dbo', 'TABLE', N'TTMStrategyDetail', 'COLUMN', N'TTMStrategyLineNumber'
GO
