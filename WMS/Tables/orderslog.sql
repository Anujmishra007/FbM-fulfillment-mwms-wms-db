CREATE TABLE [dbo].[orderslog]
(
[OrderKey] [nvarchar] (10) NOT NULL,
[StorerKey] [nvarchar] (15) NOT NULL,
[ExternOrderKey] [nvarchar] (50) NOT NULL,
[OrderDate] [datetime] NOT NULL,
[DeliveryDate] [datetime] NOT NULL,
[Priority] [nvarchar] (10) NOT NULL,
[ConsigneeKey] [nvarchar] (15) NOT NULL,
[C_contact1] [nvarchar] (100) NULL,
[C_Contact2] [nvarchar] (100) NULL,
[C_Company] [nvarchar] (100) NULL,
[C_Address1] [nvarchar] (45) NULL,
[C_Address2] [nvarchar] (45) NULL,
[C_Address3] [nvarchar] (45) NULL,
[C_Address4] [nvarchar] (45) NULL,
[C_City] [nvarchar] (45) NULL,
[C_State] [nvarchar] (45) NULL,
[C_Zip] [nvarchar] (18) NULL,
[C_Country] [nvarchar] (30) NULL,
[C_ISOCntryCode] [nvarchar] (10) NULL,
[C_Phone1] [nvarchar] (18) NULL,
[C_Phone2] [nvarchar] (18) NULL,
[C_Fax1] [nvarchar] (18) NULL,
[C_Fax2] [nvarchar] (18) NULL,
[C_vat] [nvarchar] (18) NULL,
[BuyerPO] [nvarchar] (20) NULL,
[BillToKey] [nvarchar] (15) NOT NULL,
[B_contact1] [nvarchar] (100) NULL,
[B_Contact2] [nvarchar] (100) NULL,
[B_Company] [nvarchar] (100) NULL,
[B_Address1] [nvarchar] (45) NULL,
[B_Address2] [nvarchar] (45) NULL,
[B_Address3] [nvarchar] (45) NULL,
[B_Address4] [nvarchar] (45) NULL,
[B_City] [nvarchar] (45) NULL,
[B_State] [nvarchar] (45) NULL,
[B_Zip] [nvarchar] (18) NULL,
[B_Country] [nvarchar] (30) NULL,
[B_ISOCntryCode] [nvarchar] (10) NULL,
[B_Phone1] [nvarchar] (18) NULL,
[B_Phone2] [nvarchar] (18) NULL,
[B_Fax1] [nvarchar] (18) NULL,
[B_Fax2] [nvarchar] (18) NULL,
[B_Vat] [nvarchar] (18) NULL,
[IncoTerm] [nvarchar] (10) NULL,
[PmtTerm] [nvarchar] (10) NULL,
[OpenQty] [int] NULL,
[Status] [nvarchar] (10) NOT NULL,
[DischargePlace] [nvarchar] (30) NULL,
[DeliveryPlace] [nvarchar] (30) NULL,
[IntermodalVehicle] [nvarchar] (30) NOT NULL,
[CountryOfOrigin] [nvarchar] (30) NULL,
[CountryDestination] [nvarchar] (30) NULL,
[UpdateSource] [nvarchar] (10) NOT NULL,
[Type] [nvarchar] (10) NOT NULL,
[OrderGroup] [nvarchar] (20) NOT NULL,
[Door] [nvarchar] (10) NOT NULL,
[Route] [nvarchar] (10) NOT NULL,
[Stop] [nvarchar] (10) NOT NULL,
[Notes] [nvarchar] (4000) NULL,
[EffectiveDate] [datetime] NOT NULL,
[AddDate] [datetime] NOT NULL,
[AddWho] [nvarchar] (128) NOT NULL,
[EditDate] [datetime] NOT NULL,
[EditWho] [nvarchar] (128) NOT NULL,
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL,
[ContainerType] [nvarchar] (20) NULL,
[ContainerQty] [int] NULL,
[BilledContainerQty] [int] NULL,
[SOStatus] [nvarchar] (10) NULL,
[MBOLKey] [nvarchar] (10) NULL,
[InvoiceNo] [nvarchar] (20) NULL,
[InvoiceAmount] [float] NULL,
[Salesman] [nvarchar] (30) NULL,
[GrossWeight] [float] NULL,
[Capacity] [float] NULL,
[PrintFlag] [nvarchar] (1) NULL,
[LoadKey] [nvarchar] (10) NULL,
[Rdd] [nvarchar] (30) NULL,
[Notes2] [nvarchar] (4000) NULL,
[SequenceNo] [int] NULL,
[Rds] [nvarchar] (1) NULL,
[SectionKey] [nvarchar] (10) NULL,
[Facility] [nvarchar] (5) NULL,
[PrintDocDate] [datetime] NULL,
[LabelPrice] [nvarchar] (20) NULL,
[POKey] [nvarchar] (10) NULL,
[ExternPOKey] [nvarchar] (20) NULL,
[XDockFlag] [nvarchar] (1) NOT NULL,
[UserDefine01] [nvarchar] (20) NULL,
[UserDefine02] [nvarchar] (20) NULL,
[UserDefine03] [nvarchar] (20) NULL,
[UserDefine04] [nvarchar] (20) NULL,
[UserDefine05] [nvarchar] (20) NULL,
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) NULL,
[UserDefine09] [nvarchar] (10) NULL,
[UserDefine10] [nvarchar] (10) NULL,
[Issued] [nvarchar] (1) NULL,
[DeliveryNote] [nvarchar] (10) NULL,
[PODCust] [datetime] NULL,
[PODArrive] [datetime] NULL,
[PODReject] [datetime] NULL,
[PODUser] [nvarchar] (18) NULL,
[xdockpokey] [nvarchar] (20) NULL,
[delDate] [datetime] NOT NULL CONSTRAINT [DF_orderslog_delDate] DEFAULT (getdate()),
[delWho] [nvarchar] (128) NOT NULL,
[SpecialHandling] [nvarchar] (1) NULL,
[RoutingTool] [nvarchar] (30) NULL,
[MarkforKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_ORDERSLOG_MarkforKey] DEFAULT (' '),
[M_Contact1] [nvarchar] (100) NULL,
[M_Contact2] [nvarchar] (100) NULL,
[M_Company] [nvarchar] (100) NULL,
[M_Address1] [nvarchar] (45) NULL,
[M_Address2] [nvarchar] (45) NULL,
[M_Address3] [nvarchar] (45) NULL,
[M_Address4] [nvarchar] (45) NULL,
[M_City] [nvarchar] (45) NULL,
[M_State] [nvarchar] (45) NULL,
[M_Zip] [nvarchar] (18) NULL,
[M_Country] [nvarchar] (30) NULL,
[M_ISOCntryCode] [nvarchar] (10) NULL,
[M_Phone1] [nvarchar] (18) NULL,
[M_Phone2] [nvarchar] (18) NULL,
[M_Fax1] [nvarchar] (18) NULL,
[M_Fax2] [nvarchar] (18) NULL,
[M_vat] [nvarchar] (18) NULL,
[ShipperKey] [nvarchar] (15) NULL CONSTRAINT [DF_orderslog_ShipperKey] DEFAULT (' '),
[DocType] [nvarchar] (1) NULL,
[TrackingNo] [nvarchar] (40) NULL,
[ECOM_PRESALE_FLAG] [nvarchar] (2) NULL,
[ECOM_SINGLE_Flag] [nvarchar] (1) NULL,
[CurrencyCode] [nvarchar] (20) NULL,
[RTNTrackingNo] [nvarchar] (40) NULL,
[BizUnit] [nvarchar] (50) NULL,
[ECOM_OAID] [nvarchar] (128) NULL CONSTRAINT [DF_ORDERSLOG_ECOM_OAID] DEFAULT (''),
[ECOM_Platform] [nvarchar] (30) NULL CONSTRAINT [DF_ORDERSLOG_ECOM_Platform] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[orderslog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[orderslog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[orderslog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[orderslog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Bill To.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'BillToKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_City'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Fax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Fax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_ISOCntryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Phone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Phone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_State'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_vat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of delivery to be made.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'delDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of orders to be delivered.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ecom Orders Open Address ID ', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ECOM_OAID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ECOM Platform Sub Categories', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ECOM_Platform'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Order used by Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about orders log.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about orders log.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of orders made. ', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Order.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'SectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cross Dock Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'xdockpokey'
GO
