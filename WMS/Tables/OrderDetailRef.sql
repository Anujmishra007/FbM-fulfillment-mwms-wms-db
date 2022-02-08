CREATE TABLE [dbo].[OrderDetailRef]
(
[RowREF ] [int] NOT NULL IDENTITY(1, 1),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderDetailRef_StorerKey] DEFAULT (' '),
[ParentSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderDetailRef_ParentSKU] DEFAULT (' '),
[ComponentSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderDetailRef_ComponentSKU] DEFAULT (' '),
[RetailSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderDetailRef_RetailSKU] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OrderDetailRef_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OrderDetailRef_AddWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Note1] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BOMQty] [int] NOT NULL CONSTRAINT [DF_OrderDetailRef_BOMQty] DEFAULT ((0)),
[RefType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAILREF_RefType] DEFAULT (''),
[PackCnt] [int] NULL CONSTRAINT [DF_ORDERDETAILREF_PackCnt] DEFAULT ((0)),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAILREF_EditWho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_ORDERDETAILREF_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderDetailRef] ADD CONSTRAINT [PKOrderDetailRef] PRIMARY KEY CLUSTERED ([RowREF ]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailRef_OrderLine] ON [dbo].[OrderDetailRef] ([Orderkey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailRef_SKU] ON [dbo].[OrderDetailRef] ([StorerKey], [ParentSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailRef_BOM] ON [dbo].[OrderDetailRef] ([StorerKey], [ParentSKU], [ComponentSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[OrderDetailRef] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[OrderDetailRef] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderDetailRef] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderDetailRef] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderDetailRef] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Packing activity count. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'PackCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Reference Type', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'RefType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'OrderDetailRef', 'COLUMN', N'TrafficCop'
GO
