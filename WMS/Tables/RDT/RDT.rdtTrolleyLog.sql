CREATE TABLE [RDT].[rdtTrolleyLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TrolleyNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_TrolleyNo] DEFAULT (''),
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_Position] DEFAULT (''),
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_UCCNo] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_LOC] DEFAULT (''),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_ID] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_Status] DEFAULT ('0'),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_TaskDetailKey] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtTrolleyLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtTrolleyLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtTrolleyLog] ADD CONSTRAINT [PK_rdtTrolleyLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtTrolleyLog_TrolleyNo_UCCNo] ON [RDT].[rdtTrolleyLog] ([TrolleyNo], [UCCNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtTrolleyLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtTrolleyLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtTrolleyLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtTrolleyLog] TO [NSQL]
GO
