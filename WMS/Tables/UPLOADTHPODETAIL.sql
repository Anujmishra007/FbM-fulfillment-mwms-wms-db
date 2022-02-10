CREATE TABLE [dbo].[UPLOADTHPODETAIL]
(
[POkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PoLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternLinenumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyOrdered] [int] NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REMARKS] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adddate] [datetime] NULL,
[Best_bf_Date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADTHPODETAIL_ExternPOKeyPOLine] ON [dbo].[UPLOADTHPODETAIL] ([ExternPOkey], [ExternLinenumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADTHPODETAIL_POKeyPOLine] ON [dbo].[UPLOADTHPODETAIL] ([POkey], [PoLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADTHPODETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADTHPODETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADTHPODETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADTHPODETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPODETAIL', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPODETAIL', 'COLUMN', N'ExternPOkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPODETAIL', 'COLUMN', N'POkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPODETAIL', 'COLUMN', N'REMARKS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPODETAIL', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPODETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPODETAIL', 'COLUMN', N'UOM'
GO
