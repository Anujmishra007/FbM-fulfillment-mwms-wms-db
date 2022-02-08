CREATE TABLE [dbo].[JobTaskLookup]
(
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JobTaskLookup_JobKey] DEFAULT (''),
[JobLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JobTaskLookup_JobLine] DEFAULT (''),
[WOMovekey] [bigint] NOT NULL CONSTRAINT [DF_JobTaskLookup_WOMovekey] DEFAULT ((0)),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JobTaskLookup_TaskDetailKey] DEFAULT (''),
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JobTaskLookup_WorkOrderKey] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_JobTaskLookup_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_JobTaskLookup_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_JobTaskLookup_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_JobTaskLookup_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JobTaskLookup] ADD CONSTRAINT [PK_JobTaskLookup] PRIMARY KEY CLUSTERED ([JobKey], [JobLine], [WOMovekey], [TaskDetailKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_JobTaskLookup_Move] ON [dbo].[JobTaskLookup] ([JobKey], [JobLine], [WOMovekey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_JobTaskLookup_WorkOrder] ON [dbo].[JobTaskLookup] ([JobKey], [JobLine], [WorkOrderKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_JobTaskLookup_Task] ON [dbo].[JobTaskLookup] ([TaskDetailKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[JobTaskLookup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[JobTaskLookup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[JobTaskLookup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[JobTaskLookup] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reference Lookup table for Workorder job operation and taskdetail', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Creation Date', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Creation By Who', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archiving', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Edit Date', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Edit By Who', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job #', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'JobKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job line #', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'JobLine'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference Taskdetailkey', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Skip Table Trigger', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WorkorderJobMove''s WOMoveKey', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'WOMovekey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Workorderkey for Job', 'SCHEMA', N'dbo', 'TABLE', N'JobTaskLookup', 'COLUMN', N'WorkOrderKey'
GO
