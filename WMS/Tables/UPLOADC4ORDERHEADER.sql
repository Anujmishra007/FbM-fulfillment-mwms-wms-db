CREATE TABLE [dbo].[UPLOADC4ORDERHEADER]
(
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[externorderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderdate] [datetime] NULL CONSTRAINT [DF_UPLOADC4ORDERHEADER_Orderdate] DEFAULT (getdate()),
[Deliverydate] [datetime] NULL CONSTRAINT [DF_UPLOADC4ORDERHEADER_Deliverydate] DEFAULT (getdate()),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADC4ORDERHEADER_Priority] DEFAULT ('5'),
[Salesman] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_contact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_contact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_address1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_address2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_address3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_address4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_city] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_state] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[c_zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyerpo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoiceno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes2] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pmtterm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoiceamount] [float] NULL,
[ROUTE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADC4ORDERHEADER_ROUTE] DEFAULT ('99'),
[Mode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADC4ORDERHEADER_status] DEFAULT ('0'),
[remarks] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_UPLOADC4ORDERHEADER_AddDate] DEFAULT (getdate()),
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_UploadC4OrderHeader_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UploadC4OrderHeader_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UPLOADC4ORDERHEADER] ADD CONSTRAINT [PK_UPLOADC4ORDERHEADER] PRIMARY KEY CLUSTERED ([Orderkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADC4ORDERHEADER_ExtOrderKey] ON [dbo].[UPLOADC4ORDERHEADER] ([externorderkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADC4ORDERHEADER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADC4ORDERHEADER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADC4ORDERHEADER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADC4ORDERHEADER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_city'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_state'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'c_zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'externorderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying the Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'invoiceno'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERHEADER', 'COLUMN', N'Storerkey'
GO
