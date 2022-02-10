CREATE TABLE [dbo].[ids_label_count]
(
[storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[salesord] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipdate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consigneekey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addr1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addr2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addr3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addr4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nocarton] [int] NULL,
[printdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ids_label_count] ADD CONSTRAINT [PK_ids_label_count] PRIMARY KEY CLUSTERED ([storerkey], [salesord], [printdate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ids_label_count] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ids_label_count] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ids_label_count] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ids_label_count] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'addr1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'addr2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'addr3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'addr4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'City of Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'city'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'consigneekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'phone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zip or postal code of Consignee company.', 'SCHEMA', N'dbo', 'TABLE', N'ids_label_count', 'COLUMN', N'zip'
GO
