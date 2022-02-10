CREATE TABLE [dbo].[GUI]
(
[InvoiceNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndicatorFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSalesAmt] [money] NULL CONSTRAINT [DF_GUI_TotalSalesAmt] DEFAULT ((0)),
[TotalTaxAmt] [money] NULL CONSTRAINT [DF_GUI_TotalTaxAmt] DEFAULT ((0)),
[GUICheckNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentDueDate] [datetime] NULL,
[ATMBankCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ATMBankCode] DEFAULT (' '),
[ATMBankAcc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ATMBankAcc] DEFAULT (' '),
[TTBankCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_TTBankCode] DEFAULT (' '),
[TTBankAcc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_TTBankAcc] DEFAULT (' '),
[SalesOrg] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_SalesOrg] DEFAULT (' '),
[Division] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_Division] DEFAULT (' '),
[BillDate] [datetime] NULL CONSTRAINT [DF_GUI_BillDate] DEFAULT (' '),
[PayerCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_PayerCode] DEFAULT (' '),
[TaxID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_TaxID] DEFAULT (' '),
[BillingNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_BillingNo] DEFAULT (' '),
[DivisionName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_DivisionName] DEFAULT (' '),
[BillToKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_BillToKey] DEFAULT (' '),
[BillToName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_BillToName] DEFAULT (' '),
[BillToAddr1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_BillToAddr1] DEFAULT (' '),
[BillToAddr2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_BillToAddr2] DEFAULT (' '),
[BillToTel] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_BillToTel] DEFAULT (' '),
[ShipToKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ShipToKey] DEFAULT (' '),
[ShipToName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ShipToName] DEFAULT (' '),
[ShipToAddr1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ShipToAddr1] DEFAULT (' '),
[ShipToAddr2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ShipToAddr2] DEFAULT (' '),
[ShipToTel] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ShipToTel] DEFAULT (' '),
[PaymentTerm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_PaymentTerm] DEFAULT (' '),
[SalesRep] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_SalesRep] DEFAULT (' '),
[SalesRepName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_SalesRepName] DEFAULT (' '),
[CustServTel] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_CustServTel] DEFAULT (' '),
[CustPONo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_CustPONo] DEFAULT (' '),
[NoofCopy] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_NoofCopy] DEFAULT (' '),
[TotalQty] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_TotalQty] DEFAULT (' '),
[Notes] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_Notes] DEFAULT (' '),
[BillToName2] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_BillToName2] DEFAULT (' '),
[ShipToName2] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_ShipToName2] DEFAULT (' '),
[DONumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_DONumber] DEFAULT (' '),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_Status] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GUI_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GUI_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remarks] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_Remarks] DEFAULT (' '),
[TotDiscAmount] [money] NULL CONSTRAINT [DF_GUI_TotDiscAmount] DEFAULT ((0)),
[UserDefine01] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine03] DEFAULT (' '),
[PrintFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_PrintFlag] DEFAULT ('N'),
[UserDefine04] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_UserDefine10] DEFAULT (' '),
[SalesArea] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_SalesArea] DEFAULT (' '),
[EditDate] [datetime] NULL CONSTRAINT [DF_GUI_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUI_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GUI] ADD CONSTRAINT [PK_GUI_InvoiceNo] PRIMARY KEY CLUSTERED ([Storerkey], [InvoiceNo], [ExternOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GUI_ExternOrderkey] ON [dbo].[GUI] ([ExternOrderKey], [Storerkey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GUI] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GUI] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GUI] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GUI] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'BillToAddr1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Bill To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'BillToAddr2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Bill To details.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'BillToKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Bill To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'BillToName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about name of Bill To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'BillToName2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone numbers of the Bill To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'BillToTel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Purchase Order number assigned by the customer.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'CustPONo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number of the customer service.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'CustServTel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the division.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'DivisionName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Delivery Order.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'DONumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key identifying Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information regarding GUI.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Terms and conditions of payment method.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'PaymentTerm'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of Sales Representative.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'SalesRepName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Ship To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'ShipToAddr1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Ship To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'ShipToAddr2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Ship To details.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'ShipToKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Ship To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'ShipToName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about name of Ship To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'ShipToName2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone numbers of the Ship To Company.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'ShipToTel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total discounted amount given. ', 'SCHEMA', N'dbo', 'TABLE', N'GUI', 'COLUMN', N'TotDiscAmount'
GO
