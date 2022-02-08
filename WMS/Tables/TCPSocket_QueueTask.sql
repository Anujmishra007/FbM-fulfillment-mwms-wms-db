CREATE TABLE [dbo].[TCPSocket_QueueTask]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[CmdType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_CmdType] DEFAULT (''),
[Cmd] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Cmd] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_StorerKey] DEFAULT (''),
[ThreadPerAcct] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_ThreadPerAcct] DEFAULT ((0)),
[ThreadPerStream] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_ThreadPerStream] DEFAULT ((0)),
[MilisecondDelay] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_MilisecondDelay] DEFAULT ((0)),
[DataStream] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_DataStream] DEFAULT (''),
[TransmitLogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_TransmitLogKey] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Status] DEFAULT ('0'),
[ThreadId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_ThreadId] DEFAULT (''),
[ThreadStartTime] [datetime] NULL,
[ThreadEndTime] [datetime] NULL,
[ErrMsg] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_ErrMsg] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_TCPSocket_QueueTask_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_TCPSocket_QueueTask_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Try] [tinyint] NULL,
[SEQ] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_SEQ] DEFAULT ((1)),
[Port] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Port] DEFAULT (''),
[TargetDB] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_TargetDB] DEFAULT (''),
[IP] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_IP] DEFAULT (''),
[MsgRecvDate] [datetime] NULL,
[Priority] [int] NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_Priority] DEFAULT ('0'),
[HashValue] [tinyint] NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_HashValue] DEFAULT (abs(checksum(newid())%(256)))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD CONSTRAINT [PK_TCPSocket_QueueTask] PRIMARY KEY NONCLUSTERED ([ID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_02] ON [dbo].[TCPSocket_QueueTask] ([DataStream], [TransmitLogKey], [Port], [SEQ]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_TCPSocket_QueueTask_HASHVALUE] ON [dbo].[TCPSocket_QueueTask] ([HashValue], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_01] ON [dbo].[TCPSocket_QueueTask] ([Port], [DataStream], [Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_03] ON [dbo].[TCPSocket_QueueTask] ([Port], [StorerKey], [Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_TransmitlogKey] ON [dbo].[TCPSocket_QueueTask] ([TransmitLogKey], [StorerKey], [Status]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Port', 'SCHEMA', N'dbo', 'TABLE', N'TCPSocket_QueueTask', 'COLUMN', N'Port'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Process Sequence', 'SCHEMA', N'dbo', 'TABLE', N'TCPSocket_QueueTask', 'COLUMN', N'SEQ'
GO
