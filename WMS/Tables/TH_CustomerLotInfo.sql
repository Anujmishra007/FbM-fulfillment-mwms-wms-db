CREATE TABLE [dbo].[TH_CustomerLotInfo]
(
[CustomerLotInfoKey] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_StorerKey] DEFAULT (' '),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_SKU] DEFAULT (' '),
[CustomerLot] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_CustomerLot] DEFAULT (' '),
[LineNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_LineNumber] DEFAULT (' '),
[Description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_Description] DEFAULT (' '),
[AreaUses] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_AreaUses] DEFAULT (' '),
[Directions] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_Directions] DEFAULT (' '),
[Warning] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_Warning] DEFAULT (' '),
[Qty] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_Qty] DEFAULT (''),
[ManufacturingDate] [datetime] NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_ManufacturingDate] DEFAULT (' '),
[ExpiryDate] [datetime] NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_ExpiryDate] DEFAULT (' '),
[ProductDetail] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_ProductDetail] DEFAULT (' '),
[FDACode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_FDACode] DEFAULT (' '),
[FDAExpiryDate] [datetime] NULL CONSTRAINT [DF_TH_CustomerLotInfo_FDAExpiryDate] DEFAULT (' '),
[StickerSize] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_StickerSize] DEFAULT (' '),
[VendorName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_VendorName] DEFAULT (' '),
[VendorAddress] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_VendorAddress] DEFAULT (' '),
[VendorCountry] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_VendorCountry] DEFAULT (' '),
[LocationName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_LocationName] DEFAULT (' '),
[LocationAddress] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_LocationAddress] DEFAULT (' '),
[LocationAddress2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_LocationAddress2] DEFAULT (' '),
[LocationAddress3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TH_CustomerLotInfo_LocationAddress3] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TH_CustomerLotInfo_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TH_CustomerLotInfo] ADD CONSTRAINT [PKTH_CustomerLotInfo] PRIMARY KEY CLUSTERED ([CustomerLotInfoKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TH_CustomerLotInfo_CustomerLot] ON [dbo].[TH_CustomerLotInfo] ([StorerKey], [SKU], [CustomerLot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TH_CustomerLotInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TH_CustomerLotInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TH_CustomerLotInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TH_CustomerLotInfo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'CustomerLotInfo is to store Food and Drug Administration information of Customer''s Lot in Exceed WMS to help the users to manage the flow of goods in the warehouse or facility. The Customer Lot Info is used to verify goods receiving into warehouse through the receiving module.', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Area uses of the customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'AreaUses'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Customer Lot Number', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'CustomerLot'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific CustomerLotInfo', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'CustomerLotInfoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directions of the customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'Directions'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Expiry Date of the customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'ExpiryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Food and Drug Administration Code', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'FDACode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Food and Drug Administration Expiry Date', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'FDAExpiryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Line Number of the customer Product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'LineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location Address of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'LocationAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location Address 2 of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'LocationAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location Address 3 of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'LocationAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location Name of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'LocationName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Manufacturing Date of the customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'ManufacturingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product Detail of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'ProductDetail'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item Code of the customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sticker Size of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'StickerSize'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer to whom the ownership of Lot is', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor Address of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'VendorAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor Country of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'VendorCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor Name of customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'VendorName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Warning of the customer product''s Lot', 'SCHEMA', N'dbo', 'TABLE', N'TH_CustomerLotInfo', 'COLUMN', N'Warning'
GO
