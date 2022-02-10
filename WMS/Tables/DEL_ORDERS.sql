CREATE TABLE [dbo].[DEL_ORDERS]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderDate] [datetime] NOT NULL,
[DeliveryDate] [datetime] NOT NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
[BillToKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
[OpenQty] [int] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DischargePlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryPlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntermodalVehicle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountryOfOrigin] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryDestination] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Stop] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL,
[AddDate] [datetime] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NOT NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerQty] [int] NULL,
[BilledContainerQty] [int] NULL,
[SOStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [float] NULL,
[Salesman] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrossWeight] [float] NULL,
[Capacity] [float] NULL,
[PrintFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rdd] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNo] [int] NULL,
[Rds] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrintDocDate] [datetime] NULL,
[LabelPrice] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XDockFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Issued] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryNote] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PODCust] [datetime] NULL,
[PODArrive] [datetime] NULL,
[PODReject] [datetime] NULL,
[PODUser] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xdockpokey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialHandling] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoutingTool] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarkforKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_ORDERS_MarkforKey] DEFAULT (''),
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
[ShipperKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_ORDERS_ShipperKey] DEFAULT (' '),
[DocType] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_Orders_DocType] DEFAULT (''),
[TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_Orders_TrackingNo] DEFAULT (''),
[ECOM_PRESALE_FLAG] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ECOM_SINGLE_Flag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RTNTrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BizUnit] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ECOM_OAID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_ORDERS_ECOM_OAID] DEFAULT (''),
[ECOM_Platform] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_ORDERS_ECOM_Platform] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEL_ORDERS] ADD CONSTRAINT [PK_DEL_ORDERS] PRIMARY KEY CLUSTERED ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DEL_ORDERS] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DEL_ORDERS] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DEL_ORDERS] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DEL_ORDERS] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'B_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Bill To.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'BillToKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'C_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ecom Orders Open Address ID ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'ECOM_OAID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ECOM Platform Sub Categories', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'ECOM_Platform'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for Mark For.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for Mark For.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Mark For company. ', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'M_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Mark For.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'MarkforKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Aditional information about delivery orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about delivery orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'SectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identying Crossdock Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_ORDERS', 'COLUMN', N'xdockpokey'
GO
