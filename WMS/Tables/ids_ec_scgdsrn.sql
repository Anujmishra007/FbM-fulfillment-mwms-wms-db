CREATE TABLE [dbo].[ids_ec_scgdsrn]
(
[externreceiptkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pokey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[goodqty] [int] NULL CONSTRAINT [DF_ids_ec_scgdsrn_goodqty] DEFAULT ((0)),
[badqty] [int] NULL CONSTRAINT [DF_ids_ec_scgdsrn_badqty] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ids_ec_scgdsrn] ON [dbo].[ids_ec_scgdsrn] ([externreceiptkey], [pokey], [sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ids_ec_scgdsrn] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ids_ec_scgdsrn] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ids_ec_scgdsrn] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ids_ec_scgdsrn] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Receipt used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'ids_ec_scgdsrn', 'COLUMN', N'externreceiptkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Order.', 'SCHEMA', N'dbo', 'TABLE', N'ids_ec_scgdsrn', 'COLUMN', N'pokey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'ids_ec_scgdsrn', 'COLUMN', N'sku'
GO
