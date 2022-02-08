CREATE TABLE [dbo].[STORERBILLING]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RSMinimumInvoiceCharge] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_STORERBILLING_RSMinimumInvoiceCharge] DEFAULT ((0.0)),
[RSMinimumInvoiceTaxGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_RSMinimumInvoiceTaxGroup] DEFAULT ('XXXXXXXXXX'),
[RSMinimumInvoiceGLDist] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_RSMinimumInvoiceGLDist] DEFAULT ('XXXXXXXXXX'),
[ISMinimumInvoiceCharge] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_STORERBILLING_ISMinimumInvoiceCharge] DEFAULT ((0.0)),
[ISMinimumInvoiceTaxGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_ISMinimumInvoiceTaxGroup] DEFAULT ('XXXXXXXXXX'),
[ISMinimumInvoiceGLDist] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_ISMinimumInvoiceGLDist] DEFAULT ('XXXXXXXXXX'),
[HIMinimumInvoiceCharge] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_STORERBILLING_HIMinimumInvoiceCharge] DEFAULT ((0.0)),
[HIMinimumInvoiceTaxGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_HIMinimumInvoiceTaxGroup] DEFAULT ('XXXXXXXXXX'),
[HIMinimumInvoiceGLDist] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_HIMinimumInvoiceGLDist] DEFAULT ('XXXXXXXXXX'),
[HOMinimumShipmentCharge] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_STORERBILLING_HOMinimumShipmentCharge] DEFAULT ((0.0)),
[HOMinimumShipmentTaxGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_HOMinimumShipmentTaxGroup] DEFAULT ('XXXXXXXXXX'),
[HOMinimumShipmentGLDist] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_HOMinimumShipmentGLDist] DEFAULT ('XXXXXXXXXX'),
[ISMinimumReceiptCharge] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_STORERBILLING_ISMinimumReceiptCharge] DEFAULT ((0.0)),
[ISMinimumReceiptTaxGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_ISMinimumReceiptTaxGroup] DEFAULT ('XXXXXXXXXX'),
[ISMinimumReceiptGLDist] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_ISMinimumReceiptGLDist] DEFAULT ('XXXXXXXXXX'),
[HIMinimumReceiptCharge] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_STORERBILLING_HIMinimumReceiptCharge] DEFAULT ((0.0)),
[HIMinimumReceiptTaxGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_HIMinimumReceiptTaxGroup] DEFAULT ('XXXXXXXXXX'),
[HIMinimumReceiptGLDist] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_HIMinimumReceiptGLDist] DEFAULT ('XXXXXXXXXX'),
[InvoiceNumberStrategy] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STORERBILLING_InvoiceNumberStrategy] DEFAULT ('0'),
[BillingGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STORERBILLING_BillingGroup] DEFAULT ('1'),
[LockBatch] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerBilling_LockBatch] DEFAULT (' '),
[LockWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StorerBilling_LockWho] DEFAULT (' '),
[AddDate] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STORERBILLING] ADD CONSTRAINT [PKStorerBilling] PRIMARY KEY CLUSTERED ([StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STORERBILLING] WITH NOCHECK ADD CONSTRAINT [FK_STORERBILLING_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
GRANT DELETE ON  [dbo].[STORERBILLING] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[STORERBILLING] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[STORERBILLING] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[STORERBILLING] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'STORERBILLING', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'STORERBILLING', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'STORERBILLING', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'STORERBILLING', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the storer record.', 'SCHEMA', N'dbo', 'TABLE', N'STORERBILLING', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'STORERBILLING', 'COLUMN', N'TrafficCop'
GO
