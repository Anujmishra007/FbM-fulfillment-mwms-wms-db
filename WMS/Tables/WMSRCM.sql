CREATE TABLE [dbo].[WMSRCM]
(
[RECEIPTKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EXTERNRECEIPTKEY] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RECEIPTGROUP] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[STORERKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RECEIPTDATE] [decimal] (8, 0) NOT NULL,
[POKEY] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERNAME] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERADDRESS1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERADDRESS2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERCITY] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERSTATE] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERZIP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARRIERREFERENCE] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WAREHOUSEREFERENCE] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ORIGINCOUNTRY] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DESTINATIONCOUNTRY] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VEHICLENUMBER] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VEHICLEDATE] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PLACEOFLOADING] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PLACEOFDISCHARGE] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PLACEOFDELIVERY] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INCOTERMS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TERMSNOTE] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CONTAINERKEY] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SIGNATORY] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PLACEOFISSUE] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPENQTY] [numeric] (18, 0) NOT NULL,
[STATUS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NOTES] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EFFECTIVEDATE] [decimal] (8, 0) NOT NULL,
[ADDDATE] [decimal] (8, 0) NOT NULL,
[ADDWHO] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EDITDATE] [decimal] (8, 0) NOT NULL,
[EDITWHO] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TRAFFICCOP] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ARCHIVECOP] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CONTAINERTYPE] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CONTAINERQTY] [numeric] (18, 0) NOT NULL,
[BILLEDCONTAINERQTY] [decimal] (4, 0) NOT NULL,
[RECTYPE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASNSTATUS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASNREASON] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WMS_FLAG] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMSRCM] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMSRCM] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMSRCM] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMSRCM] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'ADDDATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'ADDWHO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Carrier company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CARRIERADDRESS1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Carrier company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CARRIERADDRESS2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Carrier company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CARRIERCITY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Carrier.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CARRIERKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Carrier.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CARRIERNAME'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Carrier company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CARRIERSTATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Carrier company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CARRIERZIP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Container.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'CONTAINERKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'EDITDATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'EDITWHO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Receipt used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'EXTERNRECEIPTKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'POKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Receipt.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'RECEIPTKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'STORERKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WMSRCM', 'COLUMN', N'TRAFFICCOP'
GO
