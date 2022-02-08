CREATE TABLE [dbo].[TaskManagerUser]
(
[UserKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_UserKey] DEFAULT (' '),
[PriorityTaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_PriorityTaskType] DEFAULT ('1'),
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_StrategyKey] DEFAULT (' '),
[EquipmentProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_EquipmentProfileKey] DEFAULT (' '),
[LastCaseIdPicked] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_LastCaseIdPicked] DEFAULT (' '),
[Lastwavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_Lastwavekey] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerUser_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerUser_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastDropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskManagerUser_LastDropID] DEFAULT (''),
[LastLoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskManagerUser_LastLoadKey] DEFAULT (''),
[LastLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskManagerUser_LastLoc] DEFAULT (''),
[LastPermissionProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskManagerUser_LastPermissionProfileKey] DEFAULT (' '),
[LastOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TaskManagerUser] ADD CONSTRAINT [PKTaskManagerUser] PRIMARY KEY CLUSTERED ([UserKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TaskManagerUser] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TaskManagerUser] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskManagerUser] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskManagerUser] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskManagerUser] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A user profile is a master-detail screen that controls the tasks that each user can be assigned. This header table stores general information about the user that applies to all tasks, including the User ID, the
strategy assigned to the user, and the equipment profile assigned to the user.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the new equipment profile.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'EquipmentProfileKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Last Wave.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'Lastwavekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Key', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUser', 'COLUMN', N'UserKey'
GO
