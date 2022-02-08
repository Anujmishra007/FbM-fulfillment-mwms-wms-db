CREATE TABLE [dbo].[BUILDPARMGROUPCFG]
(
[ParmGroupCfgID] [bigint] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_Description] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_Storerkey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_Facility] DEFAULT (''),
[Type] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_Type] DEFAULT (''),
[ParmGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_ParmGroup] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDPARMGROUPCFG_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUILDPARMGROUPCFG] ADD CONSTRAINT [PK_BUILDPARMGROUPCFG] PRIMARY KEY CLUSTERED ([ParmGroupCfgID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_BUILDPARMGROUPCFG_UNIQ] ON [dbo].[BUILDPARMGROUPCFG] ([ParmGroup], [Storerkey], [Facility]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BUILDPARMGROUPCFG] ON [dbo].[BUILDPARMGROUPCFG] ([Storerkey], [Facility], [Type], [ParmGroup]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BUILDPARMGROUPCFG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BUILDPARMGROUPCFG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BUILDPARMGROUPCFG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BUILDPARMGROUPCFG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Group Configuration', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Group Description', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter Group', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'ParmGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Group Config ID', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'ParmGroupCfgID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARMGROUPCFG', 'COLUMN', N'Type'
GO
