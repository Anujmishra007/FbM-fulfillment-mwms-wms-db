CREATE TABLE [dbo].[PODETAIL]
(
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[POLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PODetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_PODetailKey] DEFAULT (' '),
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_ExternPOKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_ExternLineNo] DEFAULT (' '),
[MarksContainer] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_MarksContainer] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Sku] DEFAULT (' '),
[SKUDescription] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_SKUDescription] DEFAULT (' '),
[ManufacturerSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_ManufacturerSku] DEFAULT (' '),
[RetailSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_RetailSku] DEFAULT (' '),
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_AltSku] DEFAULT (' '),
[QtyOrdered] [int] NULL CONSTRAINT [DF_PODETAIL_QtyOrdered] DEFAULT ((0)),
[QtyAdjusted] [int] NULL CONSTRAINT [DF_PODETAIL_QtyAdjusted] DEFAULT ((0)),
[QtyReceived] [int] NULL CONSTRAINT [DF_PODETAIL_QtyReceived] DEFAULT ((0)),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PODETAIL_PackKey] DEFAULT ('STD'),
[UnitPrice] [float] NULL CONSTRAINT [DF_PODETAIL_UnitPrice] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UOM] DEFAULT (' '),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PODETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PODETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PODETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PODETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PODETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POLineStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_POLineStatus] DEFAULT ('OPEN'),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Facility] DEFAULT (' '),
[shortcode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Best_bf_Date] [datetime] NULL CONSTRAINT [DF_PODETAIL_Best_bf_Date] DEFAULT (getdate()),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine10] DEFAULT (' '),
[ToId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODetail_ToId] DEFAULT (' '),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Channel] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PODETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PODETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PODETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PODETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PODETAIL] TO [NSQL]
GO

ALTER TABLE [dbo].[PODETAIL] ADD CONSTRAINT [PKPODETAIL] PRIMARY KEY CLUSTERED ([POKey], [POLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternPODETAIL] ON [dbo].[PODETAIL] ([ExternPOKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AK_PODETAIL_01] ON [dbo].[PODETAIL] ([StorerKey], [Sku], [POKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PODETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PODETAIL_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Alternate Commodity ID to be linked to the Master Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AltSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Best before date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Best_bf_Date'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External purchase order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The warehouse in which the SKU will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lottable01', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lottable02 - Batch No', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lottable03', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product expiry date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product receipt date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Manufacturer SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ManufacturerSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Marks container', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'MarksContainer'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about Purchase Orders detail.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders detail.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'PODetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Podetail line number', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO line status', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POLineStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity adjusted', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyAdjusted'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity ordered', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyOrdered'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity received', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyReceived'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Retail SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'RetailSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shortcode', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'shortcode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The SKU being ordered', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'SKUDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable Unit', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ToId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit price', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine10'
GO
