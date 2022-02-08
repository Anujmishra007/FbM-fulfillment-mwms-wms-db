CREATE TABLE [dbo].[EC_OrderDet]
(
[EC_OrderDetNo] [bigint] NOT NULL IDENTITY(1, 1),
[EC_OrderNo] [bigint] NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_OrderKey] DEFAULT (' '),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_OrderLineNumber] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_ExternOrderKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_ExternLineNo] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EC_OrderDet_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EC_OrderDet_Sku] DEFAULT (' '),
[ManufacturerSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_ManufacturerSku] DEFAULT (' '),
[RetailSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_RetailSku] DEFAULT (' '),
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_AltSku] DEFAULT (' '),
[OriginalQty] [int] NULL CONSTRAINT [DF_EC_OrderDet_OriginalQty] DEFAULT ((0)),
[OpenQty] [int] NULL CONSTRAINT [DF_EC_OrderDet_OpenQty] DEFAULT ((0)),
[ShippedQty] [int] NULL CONSTRAINT [DF_EC_OrderDet_ShippedQty] DEFAULT ((0)),
[AdjustedQty] [int] NULL CONSTRAINT [DF_EC_OrderDet_AdjustedQty] DEFAULT ((0)),
[QtyPreAllocated] [int] NULL CONSTRAINT [DF_EC_OrderDet_QtyPreAllocated] DEFAULT ((0)),
[QtyAllocated] [int] NULL CONSTRAINT [DF_EC_OrderDet_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NULL CONSTRAINT [DF_EC_OrderDet_QtyPicked] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_UOM] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_PackKey] DEFAULT ('STD'),
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_PickCode] DEFAULT (' '),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_CartonGroup] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Status] DEFAULT ('0'),
[UnitPrice] [float] NULL CONSTRAINT [DF_EC_OrderDet_UnitPrice] DEFAULT ((0)),
[ExtendedPrice] [float] NULL CONSTRAINT [DF_EC_OrderDet_ExtendedPrice] DEFAULT ((0)),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_LOTTABLE01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EC_OrderDet_LOTTABLE02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EC_OrderDet_LOTTABLE03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[UserDefine01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_EC_OrderDet_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_EC_OrderDet_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EC_OrderDet_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EC_OrderDet] ADD CONSTRAINT [PK_EC_OrderDet] PRIMARY KEY CLUSTERED ([EC_OrderDetNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EC_OrderDet_OrderNo] ON [dbo].[EC_OrderDet] ([EC_OrderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EC_OrderDet_ExtOrdKey] ON [dbo].[EC_OrderDet] ([ExternOrderKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EC_OrderDet_OrderKey] ON [dbo].[EC_OrderDet] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EC_OrderDet] WITH NOCHECK ADD CONSTRAINT [FK_EC_OrderDet_EC_OrderDet_SKU] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
ALTER TABLE [dbo].[EC_OrderDet] WITH NOCHECK ADD CONSTRAINT [FK_EC_OrderDet_EC_Orders] FOREIGN KEY ([EC_OrderNo]) REFERENCES [dbo].[EC_Orders] ([EC_OrderNo])
GO
GRANT DELETE ON  [dbo].[EC_OrderDet] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[EC_OrderDet] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[EC_OrderDet] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[EC_OrderDet] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EC_OrderDet', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'EC_OrderDet', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EC_OrderDet', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'EC_OrderDet', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'EC_OrderDet', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'EC_OrderDet', 'COLUMN', N'TrafficCop'
GO
