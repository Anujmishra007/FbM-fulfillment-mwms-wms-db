CREATE TABLE [dbo].[WMSORM]
(
[ORDERKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[STORERKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EXTERNORDERKEY] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ORDERDATE] [decimal] (8, 0) NOT NULL,
[DELIVERYDATE] [decimal] (8, 0) NOT NULL,
[PRIORITY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CONSIGNEEKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_CONTACT1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_CONTACT2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_COMPANY] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_ADDRESS1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_ADDRESS2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_ADDRESS3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_ADDRESS4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_CITY] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_STATE] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_ZIP] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_COUNTRY] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_ISOCNTRYCODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_PHONE1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_PHONE2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_FAX1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_FAX2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_VAT] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BUYERPO] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BILLTOKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_CONTACT1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_CONTACT2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_COMPANY] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_ADDRESS1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_ADDRESS2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_ADDRESS3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_ADDRESS4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_CITY] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_STATE] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_ZIP] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_COUNTRY] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_ISOCNTRYCODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_PHONE1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_PHONE2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_FAX1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_FAX2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[B_VAT] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INCOTERM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PMTTERM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPENQTY] [decimal] (7, 0) NOT NULL,
[STATUS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DISCHARGEPLACE] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DELIVERYPLACE] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INTERMODALVEHICLE] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[COUNTRYOFORIGIN] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[COUNTRYDESTINATION] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UPDATESOURCE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TYPE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ORDERGROUP] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DOOR] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ROUTE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[STOP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NOTES] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EFFECTIVEDATE] [decimal] (8, 0) NOT NULL,
[ADDDATE] [decimal] (8, 0) NOT NULL,
[ADDWHO] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EDITDATE] [decimal] (8, 0) NOT NULL,
[EDITWHO] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TRAFFICCOP] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ARCHIVECOP] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CONTAINERTYPE] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CONTAINERQTY] [decimal] (7, 0) NOT NULL,
[BILLEDCONTAINERQTY] [decimal] (7, 0) NOT NULL,
[SOSTATUS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MBOLKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INVOICENO] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INVOICEAMOUNT] [decimal] (11, 4) NOT NULL,
[SALESMAN] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GROSSWEIGHT] [decimal] (11, 4) NOT NULL,
[CAPACITY] [decimal] (11, 4) NOT NULL,
[PRINTFLAG] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOADKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RDD] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NOTES2] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SEQUENCENO] [decimal] (7, 0) NOT NULL,
[RDS] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SECTIONKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WMS_FLAG] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FACILITY] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDateSys] [datetime] NOT NULL CONSTRAINT [DF_WMSORM_AddDateSys] DEFAULT (getdate()),
[RoutingTool] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WMSORM] ADD CONSTRAINT [PK_WMSORM] PRIMARY KEY CLUSTERED ([EXTERNORDERKEY]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WMSORM_WMSFLAG] ON [dbo].[WMSORM] ([WMS_FLAG]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMSORM] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMSORM] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMSORM] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMSORM] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'ADDDATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'ADDWHO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_ADDRESS1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_ADDRESS2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_ADDRESS3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_ADDRESS4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_CITY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_COMPANY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_CONTACT1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_CONTACT2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_COUNTRY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_FAX1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_FAX2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_ISOCNTRYCODE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_PHONE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_PHONE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_STATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_VAT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Bill To company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'B_ZIP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Bill To.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'BILLTOKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_ADDRESS1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_ADDRESS2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_ADDRESS3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_ADDRESS4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_CITY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_COMPANY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_CONTACT1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_CONTACT2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_COUNTRY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_FAX1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Fax number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_FAX2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country code for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_ISOCNTRYCODE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_PHONE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_PHONE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_STATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Value added tax for the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_VAT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'C_ZIP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'CONSIGNEEKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'EDITDATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'EDITWHO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'EXTERNORDERKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'FACILITY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'INVOICENO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'LOADKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'MBOLKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'NOTES2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'ORDERKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'PRIORITY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'SECTIONKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'STORERKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WMSORM', 'COLUMN', N'TRAFFICCOP'
GO
