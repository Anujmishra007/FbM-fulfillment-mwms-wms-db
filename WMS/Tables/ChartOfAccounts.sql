CREATE TABLE [dbo].[ChartOfAccounts]
(
[ChartofAccountsKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChartOfAccounts_Descrip] DEFAULT (' '),
[SupportFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChartOfAccounts_SupportFlag] DEFAULT ('A'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ChartOfAccounts_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChartOfAccounts_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ChartOfAccounts_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChartOfAccounts_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartOfAccounts] WITH NOCHECK ADD CONSTRAINT [CK_ChartOfAccts_SupportFlag] CHECK (([SupportFLag]='D' OR [SupportFLag]='I' OR [SupportFLag]='A'))
GO
ALTER TABLE [dbo].[ChartOfAccounts] ADD CONSTRAINT [PKChartOfAccounts] PRIMARY KEY CLUSTERED ([ChartofAccountsKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChartOfAccounts] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChartOfAccounts] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChartOfAccounts] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChartOfAccounts] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChartOfAccounts', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChartOfAccounts', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Chart of Accounts.', 'SCHEMA', N'dbo', 'TABLE', N'ChartOfAccounts', 'COLUMN', N'ChartofAccountsKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Chart of Accounts.', 'SCHEMA', N'dbo', 'TABLE', N'ChartOfAccounts', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChartOfAccounts', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChartOfAccounts', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChartOfAccounts', 'COLUMN', N'TrafficCop'
GO
