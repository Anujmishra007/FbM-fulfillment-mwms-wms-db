CREATE TABLE [dbo].[XDOCKDETAIL]
(
[XDOCKKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[XDOCKLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_XDOCKLineNumber] DEFAULT (' '),
[ReceivedQty] [int] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ReceivedQty] DEFAULT ((1)),
[ReceivedGrossWeight] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ReceivedGrossWeight] DEFAULT ((0)),
[ReceivedNetWeight] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ReceivedNetWeight] DEFAULT ((0)),
[ReceivedCube] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ReceivedCube] DEFAULT ((0)),
[ExpectedQty] [int] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ExpectedQty] DEFAULT ((0)),
[ExpectedGrossWeight] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ExpectedGrossWeight] DEFAULT ((0)),
[ExpectedNetWeight] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ExpectedNetWeight] DEFAULT ((0)),
[ExpectedCube] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ExpectedCube] DEFAULT ((0)),
[ShippedQty] [int] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ShippedQty] DEFAULT ((0)),
[ShippedGrossWeight] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ShippedGrossWeight] DEFAULT ((0)),
[ShippedNetWeight] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ShippedNetWeight] DEFAULT ((0)),
[ShippedCube] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ShippedCube] DEFAULT ((0)),
[UOMWeight] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_UOMWeight] DEFAULT (' '),
[UOMCube] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_UOMCube] DEFAULT (' '),
[RateClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_RateClass] DEFAULT (' '),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Storerkey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Sku] DEFAULT (' '),
[SkuDescription] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_SkuDescription] DEFAULT (' '),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_XDOCKDETAIL_ToId] DEFAULT (' '),
[ConditionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ConditionCode] DEFAULT ('OK'),
[ChargeableWeight] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_ChargeableWeight] DEFAULT ((0)),
[Rate] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Rate] DEFAULT ((0)),
[Extension] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Extension] DEFAULT ((0)),
[UOMVolume] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_UOMVolume] DEFAULT (' '),
[Length] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Length] DEFAULT ((0)),
[Width] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Width] DEFAULT ((0)),
[Height] [float] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_Height] DEFAULT ((0)),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_XDOCKDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDOCKDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDockDetail_Lottable06] DEFAULT (' '),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDockDetail_Lottable07] DEFAULT (' '),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDockDetail_Lottable08] DEFAULT (' '),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDockDetail_Lottable09] DEFAULT (' '),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDockDetail_Lottable10] DEFAULT (' '),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDockDetail_Lottable11] DEFAULT (' '),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_XDockDetail_Lottable12] DEFAULT (' '),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[XDOCKDETAIL] ADD CONSTRAINT [PKXdockDetail] PRIMARY KEY CLUSTERED ([XDOCKKEY], [XDOCKLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XDOCKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_XDOCKDETAIL_SKU_01] FOREIGN KEY ([Storerkey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
ALTER TABLE [dbo].[XDOCKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_XDOCKDETAIL_STORER_01] FOREIGN KEY ([Storerkey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
GRANT DELETE ON  [dbo].[XDOCKDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[XDOCKDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[XDOCKDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[XDOCKDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cube size of the Commodity currently received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ExpectedCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight of the Commodity currently expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ExpectedGrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Net weight of the Commodity currently expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ExpectedNetWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ExpectedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about crossdock detail.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cube size of the product currently received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ReceivedCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight of the product currently received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ReceivedGrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Net weight of the product currently received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ReceivedNetWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product currently received in the location.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ReceivedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cube size of the product beign shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ShippedCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ShippedGrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Net weight of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ShippedNetWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ShippedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Desription of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'SkuDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'New ID or Tag number to be assigned to the Commodity at the location. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'ToId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Crossdock.', 'SCHEMA', N'dbo', 'TABLE', N'XDOCKDETAIL', 'COLUMN', N'XDOCKKEY'
GO
