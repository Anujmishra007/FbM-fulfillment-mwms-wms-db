CREATE TABLE [dbo].[ContainerBilling]
(
[ContainerBillingKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_DocType] DEFAULT ('ASN'),
[ContainerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_ContainerType] DEFAULT (' '),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_Descr] DEFAULT (' '),
[Rate] [decimal] (12, 6) NOT NULL,
[Base] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_Base] DEFAULT ('Q'),
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_TaxGroupKey] DEFAULT ('XXXXXXXXXX'),
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_GLDistributionKey] DEFAULT ('XXXXXXXXXX'),
[CostRate] [decimal] (12, 6) NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ContainerBilling_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ContainerBilling_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerBilling_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ContainerBilling] WITH NOCHECK ADD CONSTRAINT [CK_ContBill_Base] CHECK (([Base]='R' OR [Base]='P' OR [Base]='F' OR [Base]='C' OR [Base]='G' OR [Base]='Q'))
GO
ALTER TABLE [dbo].[ContainerBilling] WITH NOCHECK ADD CONSTRAINT [CK_ContBill_DocType] CHECK (([DocType]='CNT' OR [DocType]='SO' OR [DocType]='ASN'))
GO
ALTER TABLE [dbo].[ContainerBilling] ADD CONSTRAINT [PKContainerBilling] PRIMARY KEY CLUSTERED ([ContainerBillingKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ContainerBilling] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ContainerBilling] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ContainerBilling] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ContainerBilling] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Container Billing.', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'ContainerBillingKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Container Billing.', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'ContainerBilling', 'COLUMN', N'TaxGroupKey'
GO
