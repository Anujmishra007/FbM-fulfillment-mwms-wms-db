CREATE TABLE [dbo].[TaskManagerUserDetail]
(
[UserKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_UserKey] DEFAULT (' '),
[UserLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_UserLineNumber] DEFAULT (' '),
[PermissionType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_PermissionType] DEFAULT (' '),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_AreaKey] DEFAULT (' '),
[Permission] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_Permission] DEFAULT ('1'),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_Descr] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUserDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TaskManagerUserDetail] ADD CONSTRAINT [PK_TaskManagerUserDetail] PRIMARY KEY CLUSTERED ([UserKey], [UserLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IXTaskManagerUserDetail_Area] ON [dbo].[TaskManagerUserDetail] ([AreaKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TaskManagerUserDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TaskManagerUserDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskManagerUserDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskManagerUserDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskManagerUserDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Record containing one task type per area. To grant a user permission to perform tasks such as Putaway or Picks in a given area, you must create a separate detail record for each task.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Area.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'AreaKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Task Manager User Detail. ', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Users.', 'SCHEMA', N'dbo', 'TABLE', N'TaskManagerUserDetail', 'COLUMN', N'UserKey'
GO
