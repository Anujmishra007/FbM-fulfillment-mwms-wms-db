CREATE TABLE [dbo].[ExternOrdersDetail]
(
[ExternOrderDetailKey] [bigint] NOT NULL IDENTITY(1, 1),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternOrdersDetail_Orderkey] DEFAULT (''),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QRCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RFIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrdersDetail_RFIDNo] DEFAULT (''),
[TIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrdersDetail_TIDNo] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternOrdersDetail_Status] DEFAULT ('0'),
[Userdefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine06] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine07] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine08] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine09] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine10] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrdersDetail_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NOT NULL CONSTRAINT [DF_ExternOrdersDetail_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrdersDetail_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NOT NULL CONSTRAINT [DF_ExternOrdersDetail_Editdate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExternOrdersDetail] ADD CONSTRAINT [PKExternOrdersDetail] PRIMARY KEY CLUSTERED ([ExternOrderDetailKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternOrdersDetail_ExternOrderKey] ON [dbo].[ExternOrdersDetail] ([ExternOrderKey], [ExternLineNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternOrdersDetail_OrderKey] ON [dbo].[ExternOrdersDetail] ([OrderKey], [OrderLineNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternOrdersDetail_QRCode] ON [dbo].[ExternOrdersDetail] ([QRCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternOrdersDetail_RFIDNo] ON [dbo].[ExternOrdersDetail] ([RFIDNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternOrdersDetail_SKU] ON [dbo].[ExternOrdersDetail] ([Storerkey], [SKU]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ExternOrdersDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ExternOrdersDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ExternOrdersDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ExternOrdersDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added Date', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added By Person', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated Date', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated By Person', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'External order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Table Auto Running number', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'ExternOrderDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Seller''s/storer''s external order number', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extra Notes description', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Order number. It''s used to identify a specific shipment order record.', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order detail line number. ', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'OrderLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'QR Code', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'QRCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RF ID Number', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'RFIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SKU being ordered', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Processing Status', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RF ID TID Number', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'TIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrdersDetail', 'COLUMN', N'Userdefine10'
GO
