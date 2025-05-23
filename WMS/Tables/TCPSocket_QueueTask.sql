IF NOT EXISTS ( SELECT * FROM sys.objects where object_id = OBJECT_ID (N'[dbo].[TCPSocket_QueueTask]') AND TYPE IN ('N','U'))
BEGIN
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
[HashValue] [tinyint] NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_HashValue] DEFAULT (abs(checksum(newid())%(256))),
[refkey1] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_refkey1] DEFAULT (''),
[refkey2] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_refkey2] DEFAULT (''),
[refkey3] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_refkey3] DEFAULT (''),
) ON [PRIMARY]

ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD CONSTRAINT [PK_TCPSocket_QueueTask] PRIMARY KEY NONCLUSTERED ([ID]) WITH (FILLFACTOR=80) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_02] ON [dbo].[TCPSocket_QueueTask] ([DataStream], [TransmitLogKey], [Port], [SEQ]) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [IX_TCPSocket_QueueTask_HASHVALUE] ON [dbo].[TCPSocket_QueueTask] ([HashValue], [ID]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_01] ON [dbo].[TCPSocket_QueueTask] ([Port], [DataStream], [Status]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_03] ON [dbo].[TCPSocket_QueueTask] ([Port], [StorerKey], [Status]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_TransmitlogKey] ON [dbo].[TCPSocket_QueueTask] ([TransmitLogKey], [StorerKey], [Status]) ON [PRIMARY]

GRANT DELETE ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]

GRANT INSERT ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]

GRANT SELECT ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]

GRANT UPDATE ON  [dbo].[TCPSocket_QueueTask] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Port', 'SCHEMA', N'dbo', 'TABLE', N'TCPSocket_QueueTask', 'COLUMN', N'Port'

EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Process Sequence', 'SCHEMA', N'dbo', 'TABLE', N'TCPSocket_QueueTask', 'COLUMN', N'SEQ'

END 

ELSE 
BEGIN 


 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'refkey1' AND Object_ID = Object_ID('[dbo].[TCPSocket_QueueTask]'))
			BEGIN

				ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD refkey1 [nvarchar](30) NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_refkey1]  DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'refkey1', 'SCHEMA', N'DBO', 'TABLE', N'TCPSocket_QueueTask', 'COLUMN', N'refkey1'
				
			END



 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'refkey2' AND Object_ID = Object_ID('[dbo].[TCPSocket_QueueTask]'))
			BEGIN

				ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD refkey2 [nvarchar](30) NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_refkey2]  DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'refkey2', 'SCHEMA', N'DBO', 'TABLE', N'TCPSocket_QueueTask', 'COLUMN', N'refkey2'
				
			END


 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'refkey3' AND Object_ID = Object_ID('[dbo].[TCPSocket_QueueTask]'))
			BEGIN

				ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD refkey3 [nvarchar](30) NOT NULL CONSTRAINT [DF_TCPSocket_QueueTask_refkey3]  DEFAULT ('');
				EXEC sp_addextendedproperty N'MS_Description', 'refkey3', 'SCHEMA', N'DBO', 'TABLE', N'TCPSocket_QueueTask', 'COLUMN', N'refkey3'
				
			END


END 

