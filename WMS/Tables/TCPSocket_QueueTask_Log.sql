CREATE TABLE [dbo].[TCPSocket_QueueTask_Log]
(
[ID] [bigint] NOT NULL,
[CmdType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_CmdType] DEFAULT (''),
[Cmd] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_Cmd] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_StorerKey] DEFAULT (''),
[ThreadPerAcct] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_ThreadPerAcct] DEFAULT ((0)),
[ThreadPerStream] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_ThreadPerStream] DEFAULT ((0)),
[MilisecondDelay] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_MilisecondDelay] DEFAULT ((0)),
[DataStream] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_DataStream] DEFAULT (''),
[TransmitLogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_TransmitLogKey] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_Status] DEFAULT ('0'),
[ThreadId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_ThreadId] DEFAULT (''),
[ThreadStartTime] [datetime] NULL,
[ThreadEndTime] [datetime] NULL,
[ErrMsg] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_ErrMsg] DEFAULT (''),
[Try] [tinyint] NULL,
[SEQ] [int] NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_SEQ] DEFAULT ((1)),
[Port] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_Port] DEFAULT (''),
[TargetDB] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_TargetDB] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IP] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_IP] DEFAULT (''),
[MsgRecvDate] [datetime] NULL,
[Priority] [int] NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_Log_Priority] DEFAULT ('0'),
[HashValue] [tinyint] NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_LOG_HashValue] DEFAULT (abs(checksum(newid())%(256)))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TCPSocket_QueueTask_Log] ADD CONSTRAINT [PK_TCPSocket_QueueTask_LOG] PRIMARY KEY NONCLUSTERED ([ID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TcpSocket_QueueTask_Log_01] ON [dbo].[TCPSocket_QueueTask_Log] ([DataStream], [StorerKey], [CmdType]) INCLUDE ([TransmitLogKey], [ThreadStartTime], [ThreadEndTime], [Port], [ErrMsg], [AddDate], [AddWho], [EditDate], [EditWho]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_TransmitlogKey_Log] ON [dbo].[TCPSocket_QueueTask_Log] ([DataStream], [TransmitLogKey], [StorerKey], [Status]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_TCPSocket_QueueTask_LOG_HASHVALUE] ON [dbo].[TCPSocket_QueueTask_Log] ([HashValue], [ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TCPSocket_QueueTask_Log] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TCPSocket_QueueTask_Log] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TCPSocket_QueueTask_Log] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TCPSocket_QueueTask_Log] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Port', 'SCHEMA', N'dbo', 'TABLE', N'TCPSocket_QueueTask_Log', 'COLUMN', N'Port'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Process Sequence', 'SCHEMA', N'dbo', 'TABLE', N'TCPSocket_QueueTask_Log', 'COLUMN', N'SEQ'
GO
