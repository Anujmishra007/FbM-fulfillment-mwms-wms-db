CREATE TABLE [dbo].[TMPermissionProfileDetail]
(
[ProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_ProfileKey] DEFAULT (' '),
[ProfileLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_ProfileLineNumber] DEFAULT (' '),
[PermissionType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_PermissionType] DEFAULT (' '),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_AreaKey] DEFAULT (' '),
[Permission] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_Permission] DEFAULT ('1'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfileDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMPermissionProfileDetail] ADD CONSTRAINT [PK_TaskManagerProfileDetail] PRIMARY KEY CLUSTERED ([ProfileKey], [ProfileLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMPermissionProfileDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMPermissionProfileDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMPermissionProfileDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMPermissionProfileDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfileDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfileDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfileDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfileDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfileDetail', 'COLUMN', N'TrafficCop'
GO
