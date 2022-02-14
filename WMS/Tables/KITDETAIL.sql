CREATE TABLE [dbo].[KITDETAIL]
(
[KITKey] [nvarchar] (10) NOT NULL,
[KITLineNumber] [nvarchar] (5) NOT NULL,
[Type] [nvarchar] (5) NOT NULL CONSTRAINT [DF_KITDETAIL_Type] DEFAULT ('F'),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_KITDETAIL_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) NOT NULL CONSTRAINT [DF_KITDETAIL_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_Loc] DEFAULT (' '),
[Id] [nvarchar] (18) NOT NULL CONSTRAINT [DF_KITDETAIL_Id] DEFAULT (' '),
[ExpectedQty] [int] NOT NULL CONSTRAINT [DF_KITDETAIL_ExpectedQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_KITDETAIL_Qty] DEFAULT ((0)),
[PackKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_PackKey] DEFAULT ('STD'),
[UOM] [nvarchar] (10) NOT NULL CONSTRAINT [DF_KITDETAIL_UOM] DEFAULT ('EA'),
[LOTTABLE01] [nvarchar] (18) NULL CONSTRAINT [DF_KITDETAIL_Lottable01] DEFAULT (' '),
[LOTTABLE02] [nvarchar] (18) NULL CONSTRAINT [DF_KITDETAIL_Lottable02] DEFAULT (' '),
[LOTTABLE03] [nvarchar] (18) NULL CONSTRAINT [DF_KITDETAIL_Lottable03] DEFAULT (' '),
[LOTTABLE04] [datetime] NULL,
[LOTTABLE05] [datetime] NULL,
[Status] [nvarchar] (10) NULL CONSTRAINT [DF_KITDETAIL_Status] DEFAULT ('0'),
[EffectiveDate] [datetime] NULL CONSTRAINT [DF_KITDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_KITDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KITDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_KITDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_KITDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL,
[Timestamp] [timestamp] NOT NULL,
[ExternKitKey] [nvarchar] (20) NULL CONSTRAINT [DF_KITDETAIL_ExternKitKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (10) NULL CONSTRAINT [DF_KITDETAIL_ExternLineNo] DEFAULT (' '),
[Lottable06] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) NULL CONSTRAINT [DF_KITDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (20) NOT NULL CONSTRAINT [DF_BTB_KITDETAIL_Channel] DEFAULT (''),
[Channel_ID] [bigint] NOT NULL CONSTRAINT [DF_BTB_KITDETAIL_Channel_ID] DEFAULT ((0)),
[UCCNo] [nvarchar] (20) NULL CONSTRAINT [DF_KITDETAIL_UCCNo] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[KITDETAIL] ADD CONSTRAINT [PK_KITDETAIL] PRIMARY KEY CLUSTERED ([KITKey], [KITLineNumber], [Type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[KITDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[KITDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[KITDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[KITDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[KITDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Channel', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Channel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Channel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ExpectedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ExternKitKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Kitting.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'KITKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Kit line number', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'KITLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical location in a facility.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable01', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable02', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable03', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable04', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable05', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'LOTTABLE05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Timestamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Shipment Order. The default is Standard', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'KITDETAIL', 'COLUMN', N'UOM'
GO
