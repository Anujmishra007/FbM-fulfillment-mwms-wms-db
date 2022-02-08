CREATE TABLE [dbo].[UPLOADORDERDETAIL]
(
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderlinenumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Openqty] [int] NULL,
[Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERDETAIL_UOM] DEFAULT ('PIECE'),
[ExternLineno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendedPrice] [float] NULL,
[UnitPrice] [float] NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERDETAIL_status] DEFAULT ('0'),
[remarks] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adddate] [datetime] NULL CONSTRAINT [DF_UPLOADORDERDETAIL_adddate] DEFAULT (getdate()),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERDETAIL_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERDETAIL_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADORDERDETAIL_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_externorderkey] ON [dbo].[UPLOADORDERDETAIL] ([ExternOrderkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_primary] ON [dbo].[UPLOADORDERDETAIL] ([Orderkey], [Orderlinenumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_storerkey_sku] ON [dbo].[UPLOADORDERDETAIL] ([SKU], [Storerkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_status] ON [dbo].[UPLOADORDERDETAIL] ([status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADORDERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADORDERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADORDERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADORDERDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Pack code.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'Packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADORDERDETAIL', 'COLUMN', N'UOM'
GO
