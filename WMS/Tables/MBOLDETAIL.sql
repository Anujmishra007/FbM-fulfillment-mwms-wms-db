CREATE TABLE [dbo].[MBOLDETAIL]
(
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MbolLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContainerKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_ContainerKey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_OrderKey] DEFAULT (' '),
[PalletKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_PalletKey] DEFAULT (' '),
[Description] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_Description] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_MBOLDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_MBOLDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrossWeight] [float] NULL CONSTRAINT [DF_MBOLDETAIL_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_MBOLDETAIL_CAPACITY] DEFAULT ((0)),
[InvoiceNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPSINum] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCMNum] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternReason] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [float] NULL CONSTRAINT [DF_MBOLDETAIL_INVOICEAMOUNT] DEFAULT ((0)),
[DeliveryTime] [datetime] NULL,
[OfficialReceipt] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ITS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL CONSTRAINT [DF_MBOLDETAIL_Weight] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_MBOLDETAIL_Cube] DEFAULT ((0)),
[OrderDate] [datetime] NULL,
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryDate] [datetime] NULL,
[DeliveryStatus] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_DeliveryStatus] DEFAULT ('0'),
[TotalCartons] [float] NULL CONSTRAINT [DF_MBOLDETAIL_TotalCartons] DEFAULT ((0)),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine10] DEFAULT (' '),
[CtnCnt1] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt1] DEFAULT ((0)),
[CtnCnt2] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt2] DEFAULT ((0)),
[CtnCnt3] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt3] DEFAULT ((0)),
[CtnCnt4] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt4] DEFAULT ((0)),
[CtnCnt5] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt5] DEFAULT ((0)),
[TotCtnCube] [float] NULL CONSTRAINT [DF_MBOLDetail_TotCtnCube] DEFAULT ((0)),
[TotCtnWeight] [float] NULL CONSTRAINT [DF_MBOLDetail_TotCtnWeight] DEFAULT ((0)),
[DriverName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_DriverName] DEFAULT (''),
[VehicleNo] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_VehicleNo] DEFAULT (''),
[TruckType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_TruckType] DEFAULT (''),
[ServiceProvider] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_ServiceProvider] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MBOLDETAIL] ADD CONSTRAINT [PKMBOLDETAIL] PRIMARY KEY CLUSTERED ([MbolKey], [MbolLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [MBOLDETAIL5] ON [dbo].[MBOLDETAIL] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[MBOLDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Capacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Item account number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of delivery made.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery status', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DeliveryStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery time', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DeliveryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Master Bill of Lading Details.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM DriverName', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DriverName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s/storer''s external order number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External reason', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ExternReason'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Invoice amount', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'InvoiceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order invoice number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Invoice status', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'InvoiceStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'IT Support', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ITS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'MbolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'MbolLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Official receipt', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'OfficialReceipt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of order made.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'shipment order number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Key', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'PalletKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PCM number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'PCMNum'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Service Provider', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ServiceProvider'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TimeStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cartons being delivered.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TotalCartons'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total carton cube', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TotCtnCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total carton weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TotCtnWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Truck Type', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TruckType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'UPS invoice number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UPSINum'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 01', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 02', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 03', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 04', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 05', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 06', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 07', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 08', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 09', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM VehicleNo', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'VehicleNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Weight'
GO
