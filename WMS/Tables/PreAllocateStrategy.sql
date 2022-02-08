CREATE TABLE [dbo].[PreAllocateStrategy]
(
[PreAllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategy_PreAllocateStrategyKey] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategy_Descr] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocateStrategy_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategy_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocateStrategy_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategy_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PreAllocateStrategy] ADD CONSTRAINT [PKPreAllocateStrategy] PRIMARY KEY CLUSTERED ([PreAllocateStrategyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PreAllocateStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PreAllocateStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PreAllocateStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PreAllocateStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A pre-allocation sub-strategy controls how the system pre-reserves inventory for an order. The pre-allocation process determines the lot from which to pick the order, as well as the number of pallets, cases and/or inner-packs needed for the order.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a description of the pre-allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type a unique code identifying the pre-allocation sub strategy', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', 'COLUMN', N'PreAllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategy', 'COLUMN', N'TrafficCop'
GO
