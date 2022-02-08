CREATE TABLE [dbo].[InvHoldSkuLog]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreHoldQty] [int] NULL,
[OnHoldQty] [int] NULL,
[TranStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvHoldSkuLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_InvHoldSkuLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvHoldSkuLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_InvHoldSkuLog_EditDate] DEFAULT (getdate()),
[Msgtext] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_INVHOLDSKULOG_Lottable02] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvHoldSkuLog] ADD CONSTRAINT [PK_InvHoldSkuLog] PRIMARY KEY CLUSTERED ([StorerKey], [Sku], [Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvHoldSkuLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[InvHoldSkuLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[InvHoldSkuLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[InvHoldSkuLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldSkuLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldSkuLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldSkuLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldSkuLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldSkuLog', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldSkuLog', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'InvHoldSkuLog', 'COLUMN', N'StorerKey'
GO
