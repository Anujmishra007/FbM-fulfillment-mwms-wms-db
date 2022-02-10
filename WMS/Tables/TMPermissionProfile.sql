CREATE TABLE [dbo].[TMPermissionProfile]
(
[ProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfile_ProfileKey] DEFAULT (' '),
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfile_StrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TMPermissionProfile_Descr] DEFAULT (' '),
[EquipmentProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfile_EquipmentProfileKey] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TMPermissionProfile_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfile_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TMPermissionProfile_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMPermissionProfile_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMPermissionProfile] ADD CONSTRAINT [PKTaskManagerProfilKey] PRIMARY KEY CLUSTERED ([ProfileKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMPermissionProfile] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMPermissionProfile] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMPermissionProfile] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMPermissionProfile] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfile', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfile', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfile', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfile', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TMPermissionProfile', 'COLUMN', N'TrafficCop'
GO
