CREATE TABLE [dbo].[REPLENISHSTRATEGY]
(
[ReplenishStrategykey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_ReplenishStrategykey] DEFAULT (''),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_Descr] DEFAULT (''),
[Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_Type] DEFAULT (''),
[Remarks] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_Remarks] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGY_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[REPLENISHSTRATEGY] ADD CONSTRAINT [PK_REPLENISHSTRATEGY] PRIMARY KEY CLUSTERED ([ReplenishStrategykey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[REPLENISHSTRATEGY] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[REPLENISHSTRATEGY] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[REPLENISHSTRATEGY] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[REPLENISHSTRATEGY] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Strategy table', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archiving purpose. When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'ReplenishStrategykey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Type; StoredProc or Rules', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGY', 'COLUMN', N'Type'
GO
