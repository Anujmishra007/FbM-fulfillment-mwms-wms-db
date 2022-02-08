CREATE TABLE [dbo].[REPLENISHSTRATEGYDETAIL]
(
[ReplenishStrategykey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_ReplenishStrategykey] DEFAULT (''),
[ReplenishStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_ReplenishStrategyLineNumber] DEFAULT (''),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_Descr] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_UOM] DEFAULT (''),
[ReplenCode] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_ReplenCode] DEFAULT (''),
[StrategyType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_StrategyType] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHSTRATEGYDETAIL_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[REPLENISHSTRATEGYDETAIL] ADD CONSTRAINT [PK_REPLENISHSTRATEGYDETAIL] PRIMARY KEY CLUSTERED ([ReplenishStrategykey], [ReplenishStrategyLineNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[REPLENISHSTRATEGYDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Strategy Detail table', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archiving purpose. When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When Type = ''StoredProc'', Replenish Strategy custom SP is used', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ReplenCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ReplenishStrategykey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish Strategy Line #', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'ReplenishStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When Type = ''Rule'', Replenish Strategy Type is used', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'StrategyType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenish UOM', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHSTRATEGYDETAIL', 'COLUMN', N'UOM'
GO
