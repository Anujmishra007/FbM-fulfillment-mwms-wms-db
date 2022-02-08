CREATE TABLE [dbo].[PreAllocateStrategyDetail]
(
[PreAllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_PreAllocateStrategyKey] DEFAULT (' '),
[PreAllocateStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_PreAllocateStrategyLineNumber] DEFAULT (' '),
[DESCR] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_DESCR] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_UOM] DEFAULT (' '),
[PreAllocatePickCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_PreAllocatePickCode] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocateStrategyDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PreAllocateStrategyDetail] ADD CONSTRAINT [PKPreAllocateStrategyDetail] PRIMARY KEY CLUSTERED ([PreAllocateStrategyKey], [PreAllocateStrategyLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PreAllocateStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a description of the step', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'DESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a pick code to use when picking this UOM', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'PreAllocatePickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pre-allocate strategy.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'PreAllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates order in which step should be processed during allocation process. System assigned, overwrite this number by typing over it', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'PreAllocateStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Select the first unit of measure that the system checks for pre-allocation', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocateStrategyDetail', 'COLUMN', N'UOM'
GO
