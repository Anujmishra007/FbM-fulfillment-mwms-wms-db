CREATE TABLE [dbo].[FxRATE]
(
[CurrencyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FxRATE_CurrencyKey] DEFAULT (' '),
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FxRATE_Descrip] DEFAULT (' '),
[BaseCurrency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FxRATE_BaseCurrency] DEFAULT ('USD'),
[TargetCurrency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FxRATE_TargetCurrency] DEFAULT ('USD'),
[ConversionRate] [decimal] (8, 4) NOT NULL CONSTRAINT [DF_FxRATE_ConversionRate] DEFAULT ((1.0)),
[FxDate] [datetime] NOT NULL CONSTRAINT [DF_FxRATE_FxDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_FxRATE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FxRATE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_FxRATE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FxRATE_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FxRATE] ADD CONSTRAINT [PKFxRATE] PRIMARY KEY CLUSTERED ([CurrencyKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FxRATE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[FxRATE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[FxRATE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[FxRATE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FxRATE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'FxRATE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Rate of converting different currencies. ', 'SCHEMA', N'dbo', 'TABLE', N'FxRATE', 'COLUMN', N'ConversionRate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying different types of Currency.', 'SCHEMA', N'dbo', 'TABLE', N'FxRATE', 'COLUMN', N'CurrencyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Brief description about the Currency. ', 'SCHEMA', N'dbo', 'TABLE', N'FxRATE', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'FxRATE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'FxRATE', 'COLUMN', N'EditWho'
GO
