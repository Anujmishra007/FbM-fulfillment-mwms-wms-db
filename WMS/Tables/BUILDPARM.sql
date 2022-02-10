CREATE TABLE [dbo].[BUILDPARM]
(
[ParmGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARM_ParmGroup] DEFAULT (''),
[BuildParmKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARM_BuildParmKey] DEFAULT (''),
[Description] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARM_Description] DEFAULT (''),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_Priority] DEFAULT (''),
[Strategy] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_Strategy] DEFAULT (''),
[BatchSize] [int] NULL CONSTRAINT [DF_BUILDPARM_BatchSize] DEFAULT ((0)),
[Active] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_Active] DEFAULT (''),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BUILDPARM_UDF05] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARM_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDPARM_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BUILDPARM_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BUILDPARM_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Restriction01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Restriction02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Restriction03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Restriction04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Restriction05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionValue01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionValue02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionValue03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionValue04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionValue05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionBuildValue01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionBuildValue02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionBuildValue03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionBuildValue04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestrictionBuildValue05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUILDPARM] ADD CONSTRAINT [PK_BUILDPARM] PRIMARY KEY CLUSTERED ([BuildParmKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BUILDPARM] ON [dbo].[BUILDPARM] ([ParmGroup], [BuildParmKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BUILDPARM] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BUILDPARM] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BUILDPARM] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BUILDPARM] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Header', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Active Flag', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build batch Size', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'BatchSize'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Key', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'BuildParmKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Description', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Build Parameter Group', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'ParmGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Priority', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction01', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Restriction01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction02', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Restriction02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction03', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Restriction03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction04', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Restriction04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction05', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Restriction05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction01 Build Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionBuildValue01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction02 Build Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionBuildValue02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction03 Build Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionBuildValue03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction04 Build Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionBuildValue04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction05 Build Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionBuildValue05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction01 Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionValue01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction02 Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionValue02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction03 Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionValue03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction04 Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionValue04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Restriction05 Value', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'RestrictionValue05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Strategy', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'Strategy'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 1', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 2', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 3', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 4', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define Field 5', 'SCHEMA', N'dbo', 'TABLE', N'BUILDPARM', 'COLUMN', N'UDF05'
GO
