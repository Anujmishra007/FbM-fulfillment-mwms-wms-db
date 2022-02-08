CREATE TABLE [dbo].[OP_CARTONLINES]
(
[Cartonbatch] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickHeaderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLineNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caseid] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uom] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uomqty] [int] NULL,
[qty] [int] NULL,
[packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cartongroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cartontype] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoReplenish] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenishZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_OP_CARTONLINES_EffectiveDate] DEFAULT (getdate()),
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Channel_ID] [bigint] NULL CONSTRAINT [DF_OP_CARTONLINES_Channel_ID] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OP_CARTONLINES] ADD CONSTRAINT [PKOP_CARTONLINES] PRIMARY KEY NONCLUSTERED ([Cartonbatch], [PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [OP_CARTONLINES4] ON [dbo].[OP_CARTONLINES] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OP_CARTONLINES] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OP_CARTONLINES] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OP_CARTONLINES] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OP_CARTONLINES] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'cartongroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Detail.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Header.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'PickHeaderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the products.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'OP_CARTONLINES', 'COLUMN', N'uom'
GO
