CREATE TABLE [dbo].[ConsigneeSKU]
(
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConsigneeSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_ConsigneeSKU_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ConsigneeSKU_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_ConsigneeSKU_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ConsigneeSKU_EditWho] DEFAULT (suser_sname()),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ConsigneeSKU_UOM] DEFAULT ('EA'),
[Active] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ConsigneeSKU_ACTIVE] DEFAULT ('Y'),
[CrossSKUQty] [int] NOT NULL CONSTRAINT [DF_ConsigneeSKU_CrossSKUQty] DEFAULT ((0)),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ConsigneeSku_UDF01] DEFAULT (' '),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ConsigneeSku_UDF02] DEFAULT (' '),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ConsigneeSku_UDF03] DEFAULT (' '),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ConsigneeSku_UDF04] DEFAULT (' '),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ConsigneeSku_UDF05] DEFAULT (' '),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConsigneeSKU] ADD CONSTRAINT [PK_ConsigneeSKU] PRIMARY KEY CLUSTERED ([ConsigneeKey], [ConsigneeSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ConsigneeSKU_StorerSKU] ON [dbo].[ConsigneeSKU] ([StorerKey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ConsigneeSKU] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ConsigneeSKU] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ConsigneeSKU] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ConsigneeSKU] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consignee SKU', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'ConsigneeSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'ConsigneeSKU', 'COLUMN', N'StorerKey'
GO
