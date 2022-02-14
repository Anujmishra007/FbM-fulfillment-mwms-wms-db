CREATE TABLE [dbo].[ITRN]
(
[ItrnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItrnSysId] [int] NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOTTABLE01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Itrn_LOTTABLE01] DEFAULT (' '),
[LOTTABLE02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Itrn_LOTTABLE02] DEFAULT (' '),
[LOTTABLE03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Itrn_LOTTABLE03] DEFAULT (' '),
[LOTTABLE04] [datetime] NULL,
[LOTTABLE05] [datetime] NULL,
[CaseCnt] [int] NOT NULL CONSTRAINT [DF_Itrn_CaseCnt] DEFAULT ((0)),
[InnerPack] [int] NOT NULL CONSTRAINT [DF_Itrn_Innerpack] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_Itrn_QTY] DEFAULT ((0)),
[Pallet] [int] NOT NULL CONSTRAINT [DF_Itrn_Pallet] DEFAULT ((0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_Itrn_Cube] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_Itrn_GrossWgt] DEFAULT ((0)),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_Itrn_NetWgt] DEFAULT ((0)),
[OtherUnit1] [float] NOT NULL CONSTRAINT [DF_Itrn_OtherUnit1] DEFAULT ((0)),
[OtherUnit2] [float] NOT NULL CONSTRAINT [DF_Itrn_OtherUnit2] DEFAULT ((0)),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMCalc] [int] NULL,
[UOMQty] [int] NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ITRN_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ITRN_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ITRN_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_Lottable06] DEFAULT (' '),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_Lottable07] DEFAULT (' '),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_Lottable08] DEFAULT (' '),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_Lottable09] DEFAULT (' '),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_Lottable10] DEFAULT (' '),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_Lottable11] DEFAULT (' '),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITRN_Lottable12] DEFAULT (' '),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[MoveRefKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Itrn_MoveRefKey] DEFAULT (''),
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ITRN_Channel] DEFAULT (''),
[Channel_ID] [bigint] NULL CONSTRAINT [DF_ITRN_Channel_ID] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ITRN] ADD CONSTRAINT [PKItrn] PRIMARY KEY CLUSTERED ([ItrnKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ITRN_SourceKey] ON [dbo].[ITRN] ([SourceKey], [SourceType]) INCLUDE ([TranType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ITRN_EffectiveDate] ON [dbo].[ITRN] ([TranType], [EffectiveDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ITRN] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ITRN] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ITRN] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ITRN] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ITRN] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'An inventory transaction is any deposit (increase), withdrawal (decrease), adjustment, or move of inventory. Each transaction is individually recorded to provide an accurate audit trail. This includes stock count results that will be posted and recorded. These records are often related to as æITRANÆ records.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ID or Tag number assigned to the Commodity to be moved. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'FromID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Inventory Transaction.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'ItrnKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pcak code.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow forklift or pallet jack to lift, move and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the source.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'New ID or Tag number to be assigned to the Commodity at the location. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'ToID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product sorted by Unit of Measure.', 'SCHEMA', N'dbo', 'TABLE', N'ITRN', 'COLUMN', N'UOMQty'
GO
