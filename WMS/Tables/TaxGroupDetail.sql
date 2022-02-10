CREATE TABLE [dbo].[TaxGroupDetail]
(
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaxRateKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxGroupDetail_GLDistributionKey] DEFAULT ('XXXXXXXXXX'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaxGroupDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxGroupDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaxGroupDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaxGroupDetail_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaxGroupDetail] ADD CONSTRAINT [PKTaxGroupDetail] PRIMARY KEY CLUSTERED ([TaxGroupKey], [TaxRateKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaxGroupDetail] WITH NOCHECK ADD CONSTRAINT [FK_TaxGroupDetail_GLDist_01] FOREIGN KEY ([GLDistributionKey]) REFERENCES [dbo].[GLDistribution] ([GLDistributionKey])
GO
ALTER TABLE [dbo].[TaxGroupDetail] WITH NOCHECK ADD CONSTRAINT [FKTaxGroupDetail] FOREIGN KEY ([TaxRateKey]) REFERENCES [dbo].[TaxRate] ([TaxRateKey])
GO
ALTER TABLE [dbo].[TaxGroupDetail] WITH NOCHECK ADD CONSTRAINT [FKTaxGroupDetail_TxGrpKey_01] FOREIGN KEY ([TaxGroupKey]) REFERENCES [dbo].[TaxGroup] ([TaxGroupKey])
GO
GRANT DELETE ON  [dbo].[TaxGroupDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaxGroupDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaxGroupDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaxGroupDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroupDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroupDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroupDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroupDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroupDetail', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroupDetail', 'COLUMN', N'TaxGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Rate.', 'SCHEMA', N'dbo', 'TABLE', N'TaxGroupDetail', 'COLUMN', N'TaxRateKey'
GO
