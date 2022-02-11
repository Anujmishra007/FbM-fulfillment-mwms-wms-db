CREATE TABLE [dbo].[ORDERS]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_StorerKey] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_ExternOrderKey] DEFAULT (' '),
[OrderDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERS_OrderDate] DEFAULT (getdate()),
[DeliveryDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERS_DeliveryDate] DEFAULT (getdate()),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_Priority] DEFAULT ('5'),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_ConsigneeKey] DEFAULT (' '),
[C_contact1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Contact2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[C_vat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerPO] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_BillToKey] DEFAULT (' '),
[B_contact1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Contact2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Vat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncoTerm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PmtTerm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenQty] [int] NULL CONSTRAINT [DF_ORDERS_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_Status] DEFAULT ('0'),
[DischargePlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryPlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntermodalVehicle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_IntermodalVehicle] DEFAULT (' '),
[CountryOfOrigin] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryDestination] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_UpdateSource] DEFAULT ('0'),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_Type] DEFAULT ('0'),
[OrderGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_OrderGroup] DEFAULT (' '),
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_Door] DEFAULT ('99'),
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_Route] DEFAULT ('99'),
[Stop] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_Stop] DEFAULT ('99'),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERS_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERS_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERS_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerQty] [int] NULL,
[BilledContainerQty] [int] NULL CONSTRAINT [DF_ORDERS_BilledContainerQty] DEFAULT ((0)),
[SOStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_SOStatus] DEFAULT ('0'),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_MBOLKey] DEFAULT (' '),
[InvoiceNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_InvoiceNo] DEFAULT (' '),
[InvoiceAmount] [float] NULL CONSTRAINT [DF_ORDERS_InvoiceAmount] DEFAULT ((0.00)),
[Salesman] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_Salesman] DEFAULT (' '),
[GrossWeight] [float] NULL CONSTRAINT [DF_ORDERS_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_ORDERS_CAPACITY] DEFAULT ((0)),
[PrintFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_PrintFlag] DEFAULT ('N'),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_LoadKey] DEFAULT (' '),
[Rdd] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_Rdd] DEFAULT (' '),
[Notes2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNo] [int] NULL CONSTRAINT [DF_Orders_Sequenceno] DEFAULT ((99999999)),
[Rds] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_Rds] DEFAULT ('N'),
[SectionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrintDocDate] [datetime] NULL,
[LabelPrice] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_POKey] DEFAULT (' '),
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_ExternPOKey] DEFAULT (' '),
[XDockFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Orders_XdockFlag] DEFAULT ('0'),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_UserDefine10] DEFAULT (' '),
[Issued] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryNote] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PODCust] [datetime] NULL,
[PODArrive] [datetime] NULL,
[PODReject] [datetime] NULL,
[PODUser] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_PODUser] DEFAULT (' '),
[xdockpokey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialHandling] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_SpecialHandling] DEFAULT ('N'),
[RoutingTool] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarkforKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_MarkforKey] DEFAULT (' '),
[M_Contact1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Contact2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_City] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_State] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Country] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_ISOCntryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Phone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Phone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Fax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_Fax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[M_vat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipperKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_ShipperKey] DEFAULT (' '),
[DocType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_DocType] DEFAULT ('N'),
[TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_TrackingNo] DEFAULT (''),
[ECOM_PRESALE_FLAG] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_ECOM_PRESALE_FLAG] DEFAULT (''),
[ECOM_SINGLE_Flag] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_ECOM_SINGLE_Flag] DEFAULT (''),
[CurrencyCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_CurrencyCode] DEFAULT (' '),
[RTNTrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_RTNTrackingNo] DEFAULT (''),
[BizUnit] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Orders_BizUnit] DEFAULT (''),
[HashValue] [tinyint] NULL CONSTRAINT [DF_ORDERS_HashValue] DEFAULT ((1)),
[ECOM_OAID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_ECOM_OAID] DEFAULT (''),
[ECOM_Platform] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Orders_ECOM_Platform] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ORDERS] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ORDERS] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERS] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERS] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERS] TO [NSQL]
GO

ALTER TABLE [dbo].[ORDERS] WITH NOCHECK ADD CONSTRAINT [CK_ORDERS_Status] CHECK (([Status]='W' OR [Status]='CANC' OR [Status]='9' OR [Status]='8' OR [Status]='7' OR [Status]='6' OR [Status]='5' OR [Status]='4' OR [Status]='3' OR [Status]='2' OR [Status]='1' OR [Status]='0'))
GO
ALTER TABLE [dbo].[ORDERS] ADD CONSTRAINT [PKOrders] PRIMARY KEY CLUSTERED ([OrderKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Orders_BuyerPO] ON [dbo].[ORDERS] ([BuyerPO]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERS_ExternOrdKey] ON [dbo].[ORDERS] ([ExternOrderKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Orders_Loadkey] ON [dbo].[ORDERS] ([LoadKey], [Type]) INCLUDE ([Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERS_MBOLKEY] ON [dbo].[ORDERS] ([MBOLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_Orders_StorerKey_ConsigneeKey_Status] ON [dbo].[ORDERS] ([StorerKey], [ConsigneeKey]) INCLUDE ([Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ORDERS_Storer_Status] ON [dbo].[ORDERS] ([StorerKey], [SOStatus]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Orders_TrackingNo] ON [dbo].[ORDERS] ([TrackingNo], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Orders_01] ON [dbo].[ORDERS] ([Type], [StorerKey], [ShipperKey], [C_Company], [OrderDate]) INCLUDE ([DocType], [Status], [AddDate], [M_Company]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERS_USD04] ON [dbo].[ORDERS] ([UserDefine04], [StorerKey], [ShipperKey], [Facility], [DocType]) INCLUDE ([Status], [Type], [AddDate], [UserDefine02], [UserDefine03], [SOStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ORDERS_UserDefine09] ON [dbo].[ORDERS] ([UserDefine09], [StorerKey], [Facility], [DocType], [OpenQty], [Status], [UpdateSource], [LoadKey]) INCLUDE ([AddDate], [SOStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ORDERS_ConsigneePackingKey] ON [dbo].[ORDERS] ([xdockpokey], [ConsigneeKey], [Type]) INCLUDE ([Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDERS] WITH NOCHECK ADD CONSTRAINT [FK_ORDERS_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
EXEC sp_addextendedproperty N'MS_Description', 'A Shipment Order is an outbound document in response to a customerÆs request for product from the warehouse. It records the quantity of each commodity ordered, as well as the destination of each shipment. Orders can be created manually or transmitted electronically via IML.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load Date', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s address1', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s address2', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s city', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s company', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s contact name', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s country', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s country code', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s telephone number', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s state', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill To''s zip', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'B_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Billed container quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'BilledContainerQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the party billed for goods shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'BillToKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Buyer''s (customer''s) order reference number', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'BuyerPO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s address1', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s address2', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s address3', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s address4', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s city', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s company', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s contact name', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s country', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer/consignee''s telephone number', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s state', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship To''s zip', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'C_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Capacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer/consignee to whom the order is being shipped to', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of containers required for the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ContainerQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Container types used in the facility', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ContainerType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country where the transported goods will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'CountryDestination'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country from which the transported goods will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'CountryOfOrigin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orders Currency Code', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'CurrencyCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the order is scheduled to be delivered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer order''s delivery note', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'DeliveryNote'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'DeliveryPlace'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be discharged from the vehicle', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'DischargePlace'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Document type', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'DocType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Loading door for the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Door'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ecom Orders Open Address ID ', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ECOM_OAID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ECOM Platform Sub Categories', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ECOM_Platform'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ECOM Pre-sale Flag ', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ECOM_PRESALE_FLAG'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ECOM Multi piece / Single piece orders ', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ECOM_SINGLE_Flag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Effectivedate', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s/storer''s external order number', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer''s Purchase Order number. It is used to link ASN with order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Warehouse for the order to withdraw the stock from', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Grossweight', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Standard international terms of delivery', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'IncoTerm'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carrier transporting the goods from the warehouse to the Consignee. Must be a valid storer', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'IntermodalVehicle'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Invoice Amount', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'InvoiceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order invoice number', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Issued', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Issued'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether additional value added service such as price labeling on the goods are required', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'LabelPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to a Load or when it''s moved to a new Load', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s address1', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s address2', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s address3', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s address4', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s city', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s company', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s contact name', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for Mark For.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s country', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Mark For company. ', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s state', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mark For''s zip', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'M_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Final destination of the order as it''s possible the Ship To, Bill To and end-consignee destination are different', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'MarkforKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to an MBOL or when it''s moved to a new MBOL', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Notes1', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about Orders.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date shipment order was placed', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s order group number', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'OrderGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order number. It''s used to identify a specific shipment order record. Automatically generated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Payment options for delivery', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'PmtTerm'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer PO arrival date', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'PODArrive'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer PO date', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'PODCust'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer PO reject date', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'PODReject'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User PO date', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'PODUser'
GO
EXEC sp_addextendedproperty N'MS_Description', 'WMS Purchase Order number. It is used to process Crossdock orders, linking ASN with the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dispatchdate', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'PrintDocDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This command sets the flag which controls the amount of output.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'PrintFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment''s priority', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'E1 related flag', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Rdd'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method - E1''s original discrete/batch picking flag  N-No  Y-Yes', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Rds'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery route under order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Route'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A flag to indicate whether integration to TMS is required. If yes, a file will be generated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'RoutingTool'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Return Tracking Number', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'RTNTrackingNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The sales person who closes the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Salesman'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'SectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Sequence within the route', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'SequenceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipperkey', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'ShipperKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This refers to Customer Host Order Status', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'SOStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Special handling instruction for the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'SpecialHandling'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status of the shipment i.e. Normal, Partially Allocated, Fully Allocated, In Process, Pick Slip Printed, Picked, Shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery stop where the products will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Stop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer/seller of the products being shipped (Owner of the goods)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracking number
', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'TrackingNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Shipment Order. The default is Standard', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Source update', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UpdateSource'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Used to indicated whether the ASN will be of crossdock nature', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'XDockFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Crossdock PO key', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS', 'COLUMN', N'xdockpokey'
GO
