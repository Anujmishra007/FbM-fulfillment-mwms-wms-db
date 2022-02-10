CREATE TABLE [dbo].[TaxRate]
(
[TaxRateKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaxAuthority] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxRate_TaxAuthority] DEFAULT (' '),
[SupportFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxRate_SupportFlag] DEFAULT ('A'),
[Rate] [decimal] (8, 7) NOT NULL CONSTRAINT [DF_TaxRate_Rate] DEFAULT ((0.0)),
[ExternTaxRateKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxRate_ExternTaxRateKey] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaxRate_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxRate_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaxRate_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxRate_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaxRate] WITH NOCHECK ADD CONSTRAINT [CK_TaxRate_SupportFlag] CHECK (([SupportFLag]='D' OR [SupportFLag]='I' OR [SupportFLag]='A'))
GO
ALTER TABLE [dbo].[TaxRate] ADD CONSTRAINT [PKTAXRATE] PRIMARY KEY CLUSTERED ([TaxRateKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TaxRate] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaxRate] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaxRate] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaxRate] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaxRate', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaxRate', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaxRate', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaxRate', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Rate used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'TaxRate', 'COLUMN', N'ExternTaxRateKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'TaxRate', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Rate.', 'SCHEMA', N'dbo', 'TABLE', N'TaxRate', 'COLUMN', N'TaxRateKey'
GO
