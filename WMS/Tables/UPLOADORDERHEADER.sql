CREATE TABLE [dbo].[UPLOADORDERHEADER]
(
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[externorderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderdate] [datetime] NULL CONSTRAINT [DF_UPLOADORDERHEADER_Orderdate] DEFAULT (getdate()),
[Deliverydate] [datetime] NULL CONSTRAINT [DF_UPLOADORDERHEADER_Deliverydate] DEFAULT (getdate()),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERHEADER_Priority] DEFAULT ('5'),
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
[ROUTE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERHEADER_ROUTE] DEFAULT ('99'),
[Mode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERHEADER_status] DEFAULT ('0'),
[remarks] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_UPLOADORDERHEADER_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_externorderkey] ON [dbo].[UPLOADORDERHEADER] ([externorderkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_orderkey] ON [dbo].[UPLOADORDERHEADER] ([Orderkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_status] ON [dbo].[UPLOADORDERHEADER] ([status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADORDERHEADER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADORDERHEADER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADORDERHEADER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADORDERHEADER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_city'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_contact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name/Phone/Fax/Email for the accounts payable contacts for the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_contact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'State or province of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_state'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of the Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'c_zip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'externorderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'invoiceno'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about Upload Order Header.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about Upload Order Header.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERHEADER', 'COLUMN', N'Storerkey'
GO
