CREATE TABLE [dbo].[GENREPLENISHMENTLOG]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_Storerkey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_Facility] DEFAULT (''),
[ReplenishStrategykey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_ReplenishStrategykey] DEFAULT (''),
[GenParmString] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_GenParmString] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_GENREPLENISHMENTLOG_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GENREPLENISHMENTLOG] ADD CONSTRAINT [PK_GENREPLENISHMENTLOG] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_GENREPLENISHMENTLOG_Storerkey] ON [dbo].[GENREPLENISHMENTLOG] ([Storerkey], [Facility]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GENREPLENISHMENTLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GENREPLENISHMENTLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GENREPLENISHMENTLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GENREPLENISHMENTLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Replenishment Log table', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archiving purpose. When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Replenishment Parameters String', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'GenParmString'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'ReplenishStrategykey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RowRef', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Replenishment Status', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'GENREPLENISHMENTLOG', 'COLUMN', N'TrafficCop'
GO
