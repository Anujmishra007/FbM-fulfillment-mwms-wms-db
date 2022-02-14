CREATE TABLE [dbo].[AllocateStrategy]
(
[AllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_AllocateStrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_Descr] DEFAULT (' '),
[RetryIfQtyRemain] [int] NOT NULL CONSTRAINT [DF_AllocateStrategy_RetryIfQtyRemain] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategy_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategy_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategy_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AllocateStrategy] ADD CONSTRAINT [PKAllocateStrategy] PRIMARY KEY CLUSTERED ([AllocateStrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AllocateStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'After product has been pre-allocated, the candidate lots are taken by order allocation and reserved by location, lot and (if necessary) ID.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a unique code identifying the allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'AllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a description of the allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type 0 (for no) or 1 (for yes) to indicate if you want the system to break up larger units that have not been filled', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'RetryIfQtyRemain'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategy', 'COLUMN', N'TrafficCop'
GO
