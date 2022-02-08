CREATE TABLE [dbo].[stocktakeparm2]
(
[StockTakeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Label01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Label01] DEFAULT (' '),
[Value01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Value01] DEFAULT (' '),
[Label02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Label02] DEFAULT (' '),
[Value02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Value02] DEFAULT (' '),
[Label03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Label03] DEFAULT (' '),
[Value03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Value03] DEFAULT (' '),
[Label04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Label04] DEFAULT (' '),
[Value04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Value04] DEFAULT (' '),
[Label05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Label05] DEFAULT (' '),
[Value05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeParm2_Value05] DEFAULT (' '),
[Rowref] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stocktakeparm2] ADD CONSTRAINT [PK_stocktakeparm2] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_stocktakeparm2_StockTakeKey] ON [dbo].[stocktakeparm2] ([StockTakeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_StockTakeParm2_01] ON [dbo].[stocktakeparm2] ([StockTakeKey], [Storerkey], [Tablename], [Value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stocktakeparm2] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[stocktakeparm2] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[stocktakeparm2] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[stocktakeparm2] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label Name 01 - Field Name', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Label01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label Name 02 - Field Name', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Label02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label Name 03 - Field Name', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Label03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label Name 04 - Field Name', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Label04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label Name 05 - Field Name', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Label05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Rowref'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value for Label Name 01', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Value01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value for Label Name 02', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Value02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value for Label Name 03', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Value03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value for Label Name 04', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Value04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value for Label Name 05', 'SCHEMA', N'dbo', 'TABLE', N'stocktakeparm2', 'COLUMN', N'Value05'
GO
