SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PODETAIL]') AND type in (N'U'))
BEGIN
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
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Channel] DEFAULT (''),
[Hierarchy] NVARCHAR (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Hierarchy] DEFAULT (''),
[GrossWgt] [float] NULL,
[Cube] [float] NULL,
[Length] [float] NULL,
[Width] [float] NULL,
[Height] [float] NULL
) ON [PRIMARY]

GRANT SELECT ON  [dbo].[PODETAIL] TO [JReportRole]

GRANT DELETE ON  [dbo].[PODETAIL] TO [NSQL]

GRANT INSERT ON  [dbo].[PODETAIL] TO [NSQL]

GRANT SELECT ON  [dbo].[PODETAIL] TO [NSQL]

GRANT UPDATE ON  [dbo].[PODETAIL] TO [NSQL]


ALTER TABLE [dbo].[PODETAIL] ADD CONSTRAINT [PKPODETAIL] PRIMARY KEY CLUSTERED ([POKey], [POLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ExternPODETAIL] ON [dbo].[PODETAIL] ([ExternPOKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [AK_PODETAIL_01] ON [dbo].[PODETAIL] ([StorerKey], [Sku], [POKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

ALTER TABLE [dbo].[PODETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PODETAIL_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'Alternate Commodity ID to be linked to the Master Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AltSku'

EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ArchiveCop'

EXEC sp_addextendedproperty N'MS_Description', 'Best before date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Best_bf_Date'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EffectiveDate'

EXEC sp_addextendedproperty N'MS_Description', 'External purchase order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ExternLineNo'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ExternPOKey'

EXEC sp_addextendedproperty N'MS_Description', 'The warehouse in which the SKU will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Facility'

EXEC sp_addextendedproperty N'MS_Description', 'Lottable01', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable01'

EXEC sp_addextendedproperty N'MS_Description', 'Lottable02 - Batch No', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable02'

EXEC sp_addextendedproperty N'MS_Description', 'Lottable03', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable03'

EXEC sp_addextendedproperty N'MS_Description', 'Product expiry date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable04'

EXEC sp_addextendedproperty N'MS_Description', 'Product receipt date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable05'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable06'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable07'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable08'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable09'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable10'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable11'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable12'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable13'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable14'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable15'

EXEC sp_addextendedproperty N'MS_Description', 'Manufacturer SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ManufacturerSku'

EXEC sp_addextendedproperty N'MS_Description', 'Marks container', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'MarksContainer'

EXEC sp_addextendedproperty N'MS_Description', 'Additional information about Purchase Orders detail.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Notes'

EXEC sp_addextendedproperty N'MS_Description', 'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'PackKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders detail.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'PODetailKey'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POKey'

EXEC sp_addextendedproperty N'MS_Description', 'Podetail line number', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POLineNumber'

EXEC sp_addextendedproperty N'MS_Description', 'PO line status', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POLineStatus'

EXEC sp_addextendedproperty N'MS_Description', 'Quantity adjusted', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyAdjusted'

EXEC sp_addextendedproperty N'MS_Description', 'Quantity ordered', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyOrdered'

EXEC sp_addextendedproperty N'MS_Description', 'Quantity received', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyReceived'

EXEC sp_addextendedproperty N'MS_Description', 'Retail SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'RetailSku'

EXEC sp_addextendedproperty N'MS_Description', 'Shortcode', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'shortcode'

EXEC sp_addextendedproperty N'MS_Description', 'The SKU being ordered', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Sku'

EXEC sp_addextendedproperty N'MS_Description', 'Description of the SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'SKUDescription'

EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'StorerKey'

EXEC sp_addextendedproperty N'MS_Description', 'Movable Unit', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ToId'

EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'TrafficCop'

EXEC sp_addextendedproperty N'MS_Description', 'Unit price', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UnitPrice'

EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UOM'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine01'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine02'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine03'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine04'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine05'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine06'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine07'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine08'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine09'

EXEC sp_addextendedproperty N'MS_Description', 'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine10'

END 
GO



--FCR-15713
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'PODETAIL' AND COLUMN_NAME = 'Hierarchy')
BEGIN
ALTER TABLE dbo.PODETAIL 
ADD Hierarchy NVARCHAR (10) NULL CONSTRAINT [DF_PODETAIL_Hierarchy]  DEFAULT (' ');
EXEC sp_addextendedproperty N'MS_Description', 'Hierarchy', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Hierarchy'
END



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'PODETAIL' AND COLUMN_NAME = 'GrossWgt')
BEGIN
ALTER TABLE dbo.PODETAIL 
ADD GrossWgt [float] NULL;
EXEC sp_addextendedproperty N'MS_Description', 'GrossWwight', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'GrossWgt'
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'PODETAIL' AND COLUMN_NAME = 'Cube')
BEGIN
ALTER TABLE dbo.PODETAIL 
ADD Cube [float] NULL; 
EXEC sp_addextendedproperty N'MS_Description', 'Cube', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Cube'
END


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'PODETAIL' AND COLUMN_NAME = 'Length')
BEGIN
ALTER TABLE dbo.PODETAIL 
ADD Length [float] NULL; 
EXEC sp_addextendedproperty N'MS_Description', 'Length', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Length'
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'PODETAIL' AND COLUMN_NAME = 'Width')
BEGIN
ALTER TABLE dbo.PODETAIL 
ADD Width [float] NULL; 
EXEC sp_addextendedproperty N'MS_Description', 'Width', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Width'
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'DBO' AND TABLE_NAME = 'PODETAIL' AND COLUMN_NAME = 'Height')
BEGIN
ALTER TABLE dbo.PODETAIL 
ADD Height [float] NULL; 
EXEC sp_addextendedproperty N'MS_Description', 'Height', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Height'
END
