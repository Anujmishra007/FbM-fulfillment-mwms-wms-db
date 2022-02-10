CREATE TABLE [dbo].[GWPTrack]
(
[GiftCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_GiftCode] DEFAULT (''),
[RefNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_RefNo] DEFAULT (''),
[GiftFlag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_GiftFlag] DEFAULT (''),
[Status] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Status] DEFAULT ('0'),
[Sku] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Sku] DEFAULT (''),
[UPC] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_UPC] DEFAULT (''),
[GiftDetail] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_GiftDetail] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_GWPTrack_Qty] DEFAULT ('0'),
[ReceivedQty] [int] NOT NULL CONSTRAINT [DF_GWPTrack_ReceivedQty] DEFAULT ('0'),
[Price] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Price] DEFAULT (''),
[Source] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Source] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GWPTrack_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_GWPTrack_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GWPTrack] ADD CONSTRAINT [PK_GWPTrack] PRIMARY KEY CLUSTERED ([GiftCode], [RefNo], [GiftFlag]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GWPTrack_RefNo] ON [dbo].[GWPTrack] ([RefNo]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Load Date', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gift Code', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'GiftCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gift Detail', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'GiftDetail'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gift Flag', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'GiftFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retail price per master unit of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Received Quantity', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'ReceivedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference Number', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'RefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Source'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of good and gift', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A unique number or barcode that identifies an individual product by UOM', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'UPC'
GO
