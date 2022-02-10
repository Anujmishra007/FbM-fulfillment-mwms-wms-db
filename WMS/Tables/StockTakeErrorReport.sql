CREATE TABLE [dbo].[StockTakeErrorReport]
(
[SeqNo] [bigint] NOT NULL IDENTITY(1, 1),
[StockTakeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StockTakeErrorReport_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeErrorReport_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StockTakeErrorReport] ADD CONSTRAINT [PK_StockTakeErrorReport] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StockTakeErrorReport] ON [dbo].[StockTakeErrorReport] ([StockTakeKey], [ErrorNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[StockTakeErrorReport] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StockTakeErrorReport] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StockTakeErrorReport] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StockTakeErrorReport] TO [NSQL]
GO
