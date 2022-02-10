CREATE TABLE [dbo].[AllocateStrategyDetail]
(
[AllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AllocateStrategyKey] DEFAULT (' '),
[AllocateStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AllocateStrategyLineNumber] DEFAULT (' '),
[DESCR] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_DESCR] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_UOM] DEFAULT (' '),
[PickCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_PickCode] DEFAULT (' '),
[LocationTypeOverride] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_LocationTypeOverride] DEFAULT (' '),
[LocationTypeOverRideStripe] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_LocationTypeOverRideStripe] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AllocateStrategyDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AllocateStrategyDetail] ADD CONSTRAINT [PKAllocateStrategyDetail] PRIMARY KEY CLUSTERED ([AllocateStrategyKey], [AllocateStrategyLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AllocateStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code of Allocate Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the order in which step should be processed during allocation process. System assigned; display only', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'AllocateStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter a description of the step', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'DESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'If this field is filled in, then the system will only pull product from locations of this type that has been setup in the commodity screen.   The value are usually CASE - Case Pick Locations and PICK - Piece Pick Locations', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'LocationTypeOverride'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When AllowOverAllocation flag is switched on and multiple pick locations are assigned to a SKU, the Location Override Stripe (set to 1) allows user to distribute Overallocations across multiple pick locations', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'LocationTypeOverRideStripe'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick code to use when picking goods allocated by this step', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure of the commodity to be allocated by this step', 'SCHEMA', N'dbo', 'TABLE', N'AllocateStrategyDetail', 'COLUMN', N'UOM'
GO
