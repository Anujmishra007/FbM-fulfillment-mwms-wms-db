CREATE TABLE [RDT].[rdtUCCReceive2Log]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyExpected] [int] NOT NULL,
[QtyReceived] [int] NOT NULL,
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConditionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NOT NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtUCCReceive2Log] ADD CONSTRAINT [PK_rdtUCCReceive2Log] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtUCCReceive2Log_RptKey_Line_Stor_SKU] ON [RDT].[rdtUCCReceive2Log] ([ReceiptKey], [ReceiptLineNumber], [StorerKey], [SKU]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtUCCReceive2Log] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtUCCReceive2Log] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtUCCReceive2Log] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtUCCReceive2Log] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date added the receipt detail line', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User name who added the receipt detail line', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The inventory condition upon arrival at the warehouse', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'ConditionCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date edited the receipt detail line', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User name who edited the receipt detail line', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable01 - depends on Commodity lottable label01 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable02 - depends on Commodity lottable label02 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable03 - depends on Commodity lottable label03 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable04 - manufacturing date/expiry date', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable05 - receipt date', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable06 - depends on Commodity lottable label06 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable07 - depends on Commodity lottable label07 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable08 - depends on Commodity lottable label08 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable09 - depends on Commodity lottable label09 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable10 - depends on Commodity lottable label10 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable11 - depends on Commodity lottable label11 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable12 - depends on Commodity lottable label12 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable13 - depends on Commodity lottable label13 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable14 - depends on Commodity lottable label14 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined lottable15 - depends on Commodity lottable label15 set-up', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen. Changeable', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PO #', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity of the Commodity currently expected in the location.', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'QtyExpected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity of the Commodity received in the location.', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'QtyReceived'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying receipt.', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ASN detail line number. System generated', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'ReceiptLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique key within table.', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SKU being received', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of the receipt detail line', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique key to the Storer record.', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet ID in which the SKU will be placed on', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'ToID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location of the goods after putaway. If your facility is using RDT putaway, enter the default receiving location', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'ToLOC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The UCC being received', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'UCCNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit of measurement in which the SKU will be received', 'SCHEMA', N'RDT', 'TABLE', N'rdtUCCReceive2Log', 'COLUMN', N'UOM'
GO
