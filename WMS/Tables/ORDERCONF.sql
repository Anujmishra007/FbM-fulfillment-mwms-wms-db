CREATE TABLE [dbo].[ORDERCONF]
(
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ORDERCONF] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERCONF] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERCONF] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERCONF] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERCONF', 'COLUMN', N'ExternOrderkey'
GO
