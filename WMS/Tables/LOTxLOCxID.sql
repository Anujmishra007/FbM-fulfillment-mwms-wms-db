CREATE TABLE [dbo].[LOTxLOCxID]
(
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_Loc] DEFAULT ('UNKNOWN'),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_ID] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_Sku] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyPicked] DEFAULT ((0)),
[QtyExpected] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyExpected] DEFAULT ((0)),
[QtyPickInProcess] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyPickInProcess] DEFAULT ((0)),
[PendingMoveIN] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_PendingMoveIN] DEFAULT ((0)),
[ArchiveQty] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_ArchiveQty] DEFAULT ((0)),
[ArchiveDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxLOCxID_ArchiveDate] DEFAULT ('01/01/1901'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyReplen] [int] NULL CONSTRAINT [DF_lotxlocxid_QtyReplen] DEFAULT ((0)),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxLOCxID_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[LOTxLOCxID] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO

ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_01] CHECK (([Qty]+[QtyExpected]>=([QtyAllocated]+[QtyPicked])))
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_QtyAllocated] CHECK (([QtyAllocated]>=(0)))
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_QtyPicked] CHECK (([QtyPicked]>=(0)))
GO
ALTER TABLE [dbo].[LOTxLOCxID] ADD CONSTRAINT [PKLOTxLOCxID] PRIMARY KEY CLUSTERED ([Lot], [Loc], [Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOTxLOCxID_ID] ON [dbo].[LOTxLOCxID] ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOTxLOCxID_LOC] ON [dbo].[LOTxLOCxID] ([Loc], [Id], [Qty], [QtyPicked]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LOTxLOCxIDQty] ON [dbo].[LOTxLOCxID] ([Lot], [Loc], [Id], [Qty], [QtyAllocated], [QtyPicked]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOTxLOCxID_SKU] ON [dbo].[LOTxLOCxID] ([Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [FK_LOTxLOCxID_ID_01] FOREIGN KEY ([Id]) REFERENCES [dbo].[ID] ([Id])
GO
ALTER TABLE [dbo].[LOTxLOCxID] ADD CONSTRAINT [FK_LOTxLOCxID_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [FK_LOTxLOCxID_LOT_01] FOREIGN KEY ([Lot]) REFERENCES [dbo].[LOT] ([Lot])
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [FK_LOTxLOCxID_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'pallet id of the goods', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'physical location of the goods', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique re-populated numeric value associated with a  specific product.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'unit of quantity', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'allocated quantity', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'expected quantity to be replenish', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyExpected'
GO
EXEC sp_addextendedproperty N'MS_Description', 'picked quantity', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'quantity pick in progress', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyPickInProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity replenished in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyReplen'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Owner of the good.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'TrafficCop'
GO
