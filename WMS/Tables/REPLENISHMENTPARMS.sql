CREATE TABLE [dbo].[REPLENISHMENTPARMS]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Storerkey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Facility] DEFAULT (''),
[ReplenishStrategykey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_ReplenishStrategykey] DEFAULT (''),
[ReplenishmentGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_ReplenishmentGroup] DEFAULT (''),
[Zone02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone02] DEFAULT (''),
[Zone03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone03] DEFAULT (''),
[Zone04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone04] DEFAULT (''),
[Zone05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone05] DEFAULT ((0)),
[Zone06] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone06] DEFAULT (''),
[Zone07] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone07] DEFAULT (''),
[Zone08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone08] DEFAULT (''),
[Zone09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone09] DEFAULT (''),
[Zone10] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone10] DEFAULT (''),
[Zone11] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone11] DEFAULT (''),
[Zone12] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_Zone12] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHMENTPARMS_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REPLENISHMENTPARMS] ADD CONSTRAINT [PK_REPLENISHMENTPARMS] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_REPLENISHMENTPARMS_Storerkey] ON [dbo].[REPLENISHMENTPARMS] ([Storerkey], [Facility]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[REPLENISHMENTPARMS] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[REPLENISHMENTPARMS] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[REPLENISHMENTPARMS] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[REPLENISHMENTPARMS] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Parameters table', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archiving purpose. When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Group', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'ReplenishmentGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'ReplenishStrategykey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RowRef', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 02', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 03', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 04', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 05', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 06', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 07', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 08', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 09', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 10', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 11', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Zone 12', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENTPARMS', 'COLUMN', N'Zone12'
GO
