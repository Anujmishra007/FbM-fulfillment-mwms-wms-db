CREATE TABLE [dbo].[PreAllocatePickDetail]
(
[PreAllocatePickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PreAllocatePickDetailKey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_OrderKey] DEFAULT (' '),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_OrderLineNumber] DEFAULT (' '),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Storerkey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Lot] DEFAULT (' '),
[UOM] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Qty] DEFAULT ((0)),
[Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Packkey] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_WaveKey] DEFAULT (' '),
[PreAllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PreAllocateStrategyKey] DEFAULT (' '),
[PreAllocatePickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PreAllocatePickCode] DEFAULT (' '),
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_DoCartonize] DEFAULT ('N'),
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PickMethod] DEFAULT (' '),
[RunKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_RunKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PreAllocatePickDetail] WITH NOCHECK ADD CONSTRAINT [CK_PAPD_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[PreAllocatePickDetail] ADD CONSTRAINT [PKPreAllocatePickDetail] PRIMARY KEY CLUSTERED ([PreAllocatePickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PAPD_ORDERKEY] ON [dbo].[PreAllocatePickDetail] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying pre-allocated pick.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'PreAllocatePickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pre-allocate picking detail.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'PreAllocatePickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying pre-allocated strategy.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'PreAllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying running.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'RunKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'WaveKey'
GO
