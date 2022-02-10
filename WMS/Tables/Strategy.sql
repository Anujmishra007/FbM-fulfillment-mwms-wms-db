CREATE TABLE [dbo].[Strategy]
(
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_StrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STRATEGY_Descr] DEFAULT (' '),
[PreAllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_PreAllocateStrategyKey] DEFAULT (' '),
[AllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_AllocateStrategyKey] DEFAULT (' '),
[ReplenishmentStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_ReplenishmentStrategyKey] DEFAULT (' '),
[PutawayStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_PutawayStrategyKey] DEFAULT (' '),
[PickStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_PickStrategyKey] DEFAULT (' '),
[TTMStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_TTMStrategyKey] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_STRATEGY_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STRATEGY_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_STRATEGY_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STRATEGY_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VASStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_VASStrategyKey] DEFAULT (' '),
[ABCPAStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransferStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Strategy_TransferStrategyKey] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Strategy] ADD CONSTRAINT [PKStrategy] PRIMARY KEY CLUSTERED ([StrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[Strategy] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[Strategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Strategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Strategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Strategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'WMS Exceed requires the configuration of a set of strategies for the system to work. These strategies include pre-allocation, allocation, putaway and crossdock', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'AllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the master strategy in detail', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'PickStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the pre-allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'PreAllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the putaway sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'PutawayStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Replenishment Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'ReplenishmentStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Master strategy key that you will call upon and attach to the SKU master', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transfer Strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'TransferStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique code identifying the task manager sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'Strategy', 'COLUMN', N'TTMStrategyKey'
GO
