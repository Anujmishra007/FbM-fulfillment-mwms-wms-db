IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[orderslog]') AND type in (N'U'))
BEGIN

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
[ECOM_OAID] [nvarchar] (256) NULL CONSTRAINT [DF_ORDERSLOG_ECOM_OAID] DEFAULT (''),
[ECOM_Platform] [nvarchar] (30) NULL CONSTRAINT [DF_ORDERSLOG_ECOM_Platform] DEFAULT (''),
[CancelReasonCode] [nvarchar](60) NULL
) ON [PRIMARY]


GRANT DELETE ON  [dbo].[orderslog] TO [NSQL]

GRANT INSERT ON  [dbo].[orderslog] TO [NSQL]

GRANT SELECT ON  [dbo].[orderslog] TO [NSQL]

GRANT UPDATE ON  [dbo].[orderslog] TO [NSQL]


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'AddDate'))
	EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'AddDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'AddWho'))
	EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'AddWho'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_City'))
	EXEC sp_addextendedproperty N'MS_Description', 'City of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_City'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Company'))
	EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Company'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_contact1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_contact1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Contact2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Contact2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Country'))
	EXEC sp_addextendedproperty N'MS_Description', 'Country of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Country'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Fax1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Fax1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Fax2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Fax2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_ISOCntryCode'))
	EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_ISOCntryCode'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Phone1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Phone1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Phone2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Phone2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_State'))
	EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_State'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Vat'))
	EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Vat'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'B_Zip'))
	EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'B_Zip'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'BillToKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Bill To.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'BillToKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Address1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Address2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Address3'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address3'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Address4'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Address4'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_City'))
	EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_City'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Company'))
	EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Company'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_contact1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_contact1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Contact2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Contact2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Country'))
	EXEC sp_addextendedproperty N'MS_Description', 'Country of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Country'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Fax1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Fax1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Fax2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Fax2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_ISOCntryCode'))
	EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_ISOCntryCode'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Phone1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Phone1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Phone2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Phone2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_State'))
	EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_State'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_vat'))
	EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_vat'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'C_Zip'))
	EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'C_Zip'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'ConsigneeKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ConsigneeKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'delDate'))
	EXEC sp_addextendedproperty N'MS_Description', 'Date of delivery to be made.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'delDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'DeliveryDate'))
	EXEC sp_addextendedproperty N'MS_Description', 'Date of orders to be delivered.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'DeliveryDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'ECOM_OAID'))
	EXEC sp_addextendedproperty N'MS_Description', N'Ecom Orders Open Address ID ', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ECOM_OAID'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'ECOM_Platform'))
	EXEC sp_addextendedproperty N'MS_Description', N'ECOM Platform Sub Categories', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ECOM_Platform'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'EditDate'))
	EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'EditDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'EditWho'))
	EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'EditWho'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'ExternOrderKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ExternOrderKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'ExternPOKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Order used by Storer.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'ExternPOKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'Facility'))
	EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Facility'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'InvoiceNo'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'InvoiceNo'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'LoadKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'LoadKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'M_Address1'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address1'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'M_Address2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'M_Address3'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address3'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'M_Address4'))
	EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Mark For company.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'M_Address4'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'MBOLKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'MBOLKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'Notes'))
	EXEC sp_addextendedproperty N'MS_Description', 'Additional information about orders log.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Notes'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'Notes2'))
	EXEC sp_addextendedproperty N'MS_Description', 'Additional information about orders log.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Notes2'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'OrderDate'))
	EXEC sp_addextendedproperty N'MS_Description', 'Date of orders made. ', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'OrderDate'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'OrderKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'OrderKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'POKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Order.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'POKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'Priority'))
	EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'Priority'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'SectionKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'SectionKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'StorerKey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'StorerKey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'TrafficCop'))
	EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'TrafficCop'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'xdockpokey'))
	EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cross Dock Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'xdockpokey'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'CancelReasonCode'))
	EXEC sp_addextendedproperty N'MS_Description', 'The reason why an order is cancelled', 'SCHEMA', N'dbo', 'TABLE', N'orderslog', 'COLUMN', N'CancelReasonCode'

END


ELSE
BEGIN

 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'CancelReasonCode' AND Object_ID = Object_ID('dbo.orderslog'))
			BEGIN
				ALTER TABLE dbo.orderslog ADD CancelReasonCode [nvarchar](60) NULL ;
				
			END


IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'orderslog', N'COLUMN',N'CancelReasonCode'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The reason why an order is cancelled' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'orderslog', @level2type=N'COLUMN',@level2name=N'CancelReasonCode'



--ALTER COLUMN 
 IF  EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'delwho' AND Object_ID = Object_ID('dbo.orderslog') and max_length <> 256)
			BEGIN
				ALTER TABLE dbo.orderslog 
				ALTER COLUMN [delWho] [nvarchar] (128) NOT NULL ;
				
			END

 IF  EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ECOM_OAID' AND Object_ID = Object_ID('dbo.orderslog') and max_length <>512)
			BEGIN
				ALTER TABLE dbo.orderslog 
				ALTER COLUMN [ECOM_OAID]  [nvarchar] (256) NULL;

			END

END
