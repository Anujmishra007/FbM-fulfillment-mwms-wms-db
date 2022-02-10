CREATE TABLE [dbo].[UPLOADTHPOHEADER]
(
[POkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REMARKS] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadingDate] [datetime] NULL,
[adddate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADTHPOHEADER_POKey] ON [dbo].[UPLOADTHPOHEADER] ([POkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADTHPOHEADER_ExternPOKey] ON [dbo].[UPLOADTHPOHEADER] ([STATUS], [ExternPOKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADTHPOHEADER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADTHPOHEADER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADTHPOHEADER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADTHPOHEADER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPOHEADER', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPOHEADER', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPOHEADER', 'COLUMN', N'POkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPOHEADER', 'COLUMN', N'REMARKS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADTHPOHEADER', 'COLUMN', N'Storerkey'
GO
