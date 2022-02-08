CREATE TABLE [dbo].[ids_lp_nested_orderkey]
(
[orderkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ids_lp_nested_orderkey] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ids_lp_nested_orderkey] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ids_lp_nested_orderkey] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ids_lp_nested_orderkey] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'ids_lp_nested_orderkey', 'COLUMN', N'orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'ids_lp_nested_orderkey', 'COLUMN', N'storerkey'
GO
