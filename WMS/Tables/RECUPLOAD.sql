CREATE TABLE [dbo].[RECUPLOAD]
(
[STORERKEY] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Flag] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECUPLOAD_Flag] DEFAULT ('N'),
[Message] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECUPLOAD_Message] DEFAULT (' ')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RECUPLOAD] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RECUPLOAD] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RECUPLOAD] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RECUPLOAD] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'RECUPLOAD', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'RECUPLOAD', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'RECUPLOAD', 'COLUMN', N'STORERKEY'
GO
