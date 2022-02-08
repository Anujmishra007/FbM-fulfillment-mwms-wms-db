CREATE TABLE [dbo].[UPLOADC4ORDERDETAIL]
(
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Orderlinenumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Openqty] [int] NULL,
[Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADC4ORDERDETAIL_UOM] DEFAULT ('PIECE'),
[ExternLineno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendedPrice] [float] NULL,
[UnitPrice] [float] NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADC4ORDERDETAIL_status] DEFAULT ('0'),
[remarks] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adddate] [datetime] NULL CONSTRAINT [DF_UPLOADC4ORDERDETAIL_adddate] DEFAULT (getdate()),
[RFF] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_UPLOADC4ORDERDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UPLOADC4ORDERDETAIL_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UPLOADC4ORDERDETAIL] ADD CONSTRAINT [PK_UPLOADC4ORDERDETAIL] PRIMARY KEY CLUSTERED ([Orderkey], [Orderlinenumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADC4ORDERDETAIL_ExtOrderKey] ON [dbo].[UPLOADC4ORDERDETAIL] ([ExternOrderkey], [ExternLineno]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADC4ORDERDETAIL_SKU] ON [dbo].[UPLOADC4ORDERDETAIL] ([Storerkey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADC4ORDERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADC4ORDERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADC4ORDERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADC4ORDERDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'Packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4ORDERDETAIL', 'COLUMN', N'UOM'
GO
