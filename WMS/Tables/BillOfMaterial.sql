CREATE TABLE [dbo].[BillOfMaterial]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Storerkey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Sku] DEFAULT (' '),
[ComponentSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_ComponentSku] DEFAULT (' '),
[Sequence] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Sequence] DEFAULT (' '),
[BomOnly] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_BomOnly] DEFAULT (' '),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Notes] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_BillOfMaterial_Qty] DEFAULT ((1)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterial_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterial_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentQty] [int] NOT NULL CONSTRAINT [DF_BillOfMaterial_ParentQty] DEFAULT ((1)),
[UDF01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BillOfMaterial_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BillOfMaterial] ADD CONSTRAINT [PKBillOfMaterial] PRIMARY KEY CLUSTERED ([Storerkey], [Sku], [ComponentSku]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BillOfMaterial_01] ON [dbo].[BillOfMaterial] ([Storerkey], [ComponentSku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BillofMaterial_UDF01] ON [dbo].[BillOfMaterial] ([UDF01], [Storerkey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BillOfMaterial] WITH NOCHECK ADD CONSTRAINT [FK_BillOfMaterial_SKU_01] FOREIGN KEY ([Storerkey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
GRANT SELECT ON  [dbo].[BillOfMaterial] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill of Material (BOM). The WMS allows user to kit a Commodity by creating a BOM that identifies the primary SKU and each of the component SKU(s)', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether this component must be kitted before shipping. Normally, standard will put ''Y'' use for commodity kitting.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'BomOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity code for the component being kitted', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'ComponentSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional comment on kitting or assembly', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of this component that is required in each kit', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order in which component should be assembled into the kit. For example: if this component should be the third component placed in this package, enter 3 in the field', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code identifying the master commodity record under which all components are kitted', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The owner of the product', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'TrafficCop'
GO
