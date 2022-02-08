CREATE TABLE [dbo].[GLDistributionDetail]
(
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GLDistributionLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GLDistributionDetail_GLDistributionLineNumber] DEFAULT (' '),
[ChartofAccountsKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GLDistributionDetail_ChartofAccountsKey] DEFAULT ('XXXXXXXXXX'),
[GLDistributionPct] [decimal] (12, 6) NOT NULL CONSTRAINT [DF_GLDistributionDetail_GLDistributionPct] DEFAULT ((0.0)),
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GLDistributionDetail_Descrip] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GLDistributionDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GLDistributionDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_GLDistributionDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GLDistributionDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GLDistributionDetail] ADD CONSTRAINT [PKGLDistributionDetail] PRIMARY KEY CLUSTERED ([GLDistributionKey], [GLDistributionLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GLDistributionDetail] WITH NOCHECK ADD CONSTRAINT [FK_GLDistDet_COAKey_01] FOREIGN KEY ([ChartofAccountsKey]) REFERENCES [dbo].[ChartOfAccounts] ([ChartofAccountsKey])
GO
ALTER TABLE [dbo].[GLDistributionDetail] WITH NOCHECK ADD CONSTRAINT [FKGLDistDet] FOREIGN KEY ([GLDistributionKey]) REFERENCES [dbo].[GLDistribution] ([GLDistributionKey])
GO
GRANT DELETE ON  [dbo].[GLDistributionDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GLDistributionDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GLDistributionDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GLDistributionDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Charts of Accounts.', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'ChartofAccountsKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of GL Distribution detail.', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'GLDistributionDetail', 'COLUMN', N'TrafficCop'
GO
