CREATE TABLE [dbo].[ExternOrders]
(
[ExternOrdersKey] [bigint] NOT NULL IDENTITY(1, 1),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternOrders_Orderkey] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Source] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrders_Source] DEFAULT (''),
[BindingDate] [datetime] NULL CONSTRAINT [DF_ExternOrders_Bindingdate] DEFAULT (getdate()),
[ShippedDate] [datetime] NULL CONSTRAINT [DF_ExternOrders_ShippedDate] DEFAULT (getdate()),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternOrders_Status] DEFAULT ('0'),
[PlatformName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrders_PlatformName] DEFAULT (''),
[PlatformOrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrders_PlatformOrderNo] DEFAULT (''),
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
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrders_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NOT NULL CONSTRAINT [DF_ExternOrders_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ExternOrders_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NOT NULL CONSTRAINT [DF_ExternOrders_Editdate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExternOrders] ADD CONSTRAINT [PKExternOrders] PRIMARY KEY CLUSTERED ([ExternOrdersKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IXExternOrders_ExternOrderKey] ON [dbo].[ExternOrders] ([ExternOrderKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IXExternOrders_OrderKey] ON [dbo].[ExternOrders] ([OrderKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternOrders_PlatformOrderNo] ON [dbo].[ExternOrders] ([PlatformOrderNo], [Storerkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IXExternOrders_Storerkey] ON [dbo].[ExternOrders] ([Storerkey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ExternOrders] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ExternOrders] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ExternOrders] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ExternOrders] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added Date', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Added By Person', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Binding Date', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'BindingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated Date', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Last Updated By Person', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Seller''s/storer''s external order number', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Table Auto Running number', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'ExternOrdersKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extra Notes description', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Order number. It''s used to identify a specific shipment order record.', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Platform Name', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'PlatformName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Platform Order reference Number', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'PlatformOrderNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipped Date', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'ShippedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders Source Type', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Source'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Status', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer/seller of the products being shipped (Owner of the goods)', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'ExternOrders', 'COLUMN', N'Userdefine10'
GO
