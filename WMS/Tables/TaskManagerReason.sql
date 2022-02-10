CREATE TABLE [dbo].[TaskManagerReason]
(
[TaskManagerReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_TaskManagerReasonKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_Descr] DEFAULT (' '),
[TOLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_TOLOC] DEFAULT (' '),
[ValidInFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_ValidInFromLoc] DEFAULT ('1'),
[ValidInToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_ValidInToLoc] DEFAULT ('1'),
[LOCHoldKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_LOCHoldKey] DEFAULT (' '),
[IDHoldKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_IDHoldKey] DEFAULT (' '),
[RemoveTaskFromUserQueue] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_RemoveTaskFromUserQueue] DEFAULT ('0'),
[DoCycleCount] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_DoCycleCount] DEFAULT ('0'),
[TaskStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_TaskStatus] DEFAULT (' '),
[ContinueProcessing] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_ContinueProcessing] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerReason_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerReason_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GenerateAlert] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskManagerReason_GenerateAlert] DEFAULT ('1')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TaskManagerReason] ADD CONSTRAINT [PKTaskManagerReason] PRIMARY KEY CLUSTERED ([TaskManagerReasonKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TaskManagerReason] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TaskManagerReason] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskManagerReason] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskManagerReason] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskManagerReason] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Whenever a user rejects a task completely or shorts a pick task, that user must enter a reason code to indicate why. Each reason code''s setup includes information on what action EXceed will take each time the reason code is selected.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Task Manager Reason.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying ID Hold.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'IDHoldKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Location Hold.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'LOCHoldKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying task manager reason.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'TaskManagerReasonKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'TOLOC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerReason', 'COLUMN', N'TrafficCop'
GO
