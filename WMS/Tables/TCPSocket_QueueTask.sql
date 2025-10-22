SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TCPSocket_QueueTask]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TCPSocket_QueueTask](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CmdType] [nvarchar](10) NULL,
	[Cmd] [nvarchar](1024) NULL,
	[StorerKey] [nvarchar](15) NULL,
	[ThreadPerAcct] [int] NULL,
	[ThreadPerStream] [int] NULL,
	[MilisecondDelay] [int] NULL,
	[DataStream] [nvarchar](10) NULL,
	[TransmitLogKey] [nvarchar](10) NULL,
	[Status] [nvarchar](1) NULL,
	[ThreadId] [nvarchar](20) NULL,
	[ThreadStartTime] [datetime] NULL,
	[ThreadEndTime] [datetime] NULL,
	[ErrMsg] [nvarchar](1000) NULL,
	[AddDate] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[Try] [tinyint] NULL,
	[SEQ] [int] NULL,
	[Port] [nvarchar](5) NULL,
	[TargetDB] [nvarchar](30) NULL,
	[IP] [nvarchar](30) NULL,
	[MsgRecvDate] [datetime] NULL,
	[Priority] [int] NOT NULL,
	[HashValue] [tinyint] NOT NULL,
	[refkey1] [nvarchar](30) NOT NULL,
	[refkey2] [nvarchar](30) NOT NULL,
	[refkey3] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_TCPSocket_QueueTask] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TCPSocket_QueueTask]') AND name = N'IX_TCPSocket_QueueTask_HASHVALUE')
CREATE UNIQUE CLUSTERED INDEX [IX_TCPSocket_QueueTask_HASHVALUE] ON [dbo].[TCPSocket_QueueTask]
(
	[HashValue] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TCPSocket_QueueTask]') AND name = N'IDX_TCPSocket_QueueTask_01')
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_01] ON [dbo].[TCPSocket_QueueTask]
(
	[Port] ASC,
	[DataStream] ASC,
	[Status] ASC
)
INCLUDE([ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TCPSocket_QueueTask]') AND name = N'IDX_TCPSocket_QueueTask_02')
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_02] ON [dbo].[TCPSocket_QueueTask]
(
	[DataStream] ASC,
	[TransmitLogKey] ASC,
	[Port] ASC,
	[SEQ] ASC
)
INCLUDE([StorerKey],[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

 
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TCPSocket_QueueTask]') AND name = N'IDX_TCPSocket_QueueTask_TransmitlogKey')
CREATE NONCLUSTERED INDEX [IDX_TCPSocket_QueueTask_TransmitlogKey] ON [dbo].[TCPSocket_QueueTask]
(
	[TransmitLogKey] ASC,
	[StorerKey] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_CmdType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_CmdType]  DEFAULT ('') FOR [CmdType]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_Cmd]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_Cmd]  DEFAULT ('') FOR [Cmd]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_StorerKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_StorerKey]  DEFAULT ('') FOR [StorerKey]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_ThreadPerAcct]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_ThreadPerAcct]  DEFAULT ((0)) FOR [ThreadPerAcct]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_ThreadPerStream]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_ThreadPerStream]  DEFAULT ((0)) FOR [ThreadPerStream]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_MilisecondDelay]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_MilisecondDelay]  DEFAULT ((0)) FOR [MilisecondDelay]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_DataStream]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_DataStream]  DEFAULT ('') FOR [DataStream]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_TransmitLogKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_TransmitLogKey]  DEFAULT ('') FOR [TransmitLogKey]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_Status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_Status]  DEFAULT ('0') FOR [Status]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_ThreadId]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_ThreadId]  DEFAULT ('') FOR [ThreadId]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_ErrMsg]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_ErrMsg]  DEFAULT ('') FOR [ErrMsg]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_SEQ]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_SEQ]  DEFAULT ((1)) FOR [SEQ]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_Port]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_Port]  DEFAULT ('') FOR [Port]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_TargetDB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_TargetDB]  DEFAULT ('') FOR [TargetDB]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_IP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_IP]  DEFAULT ('') FOR [IP]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_Priority]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_Priority]  DEFAULT ('0') FOR [Priority]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_HashValue]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD  CONSTRAINT [DF_TCPSocket_QueueTask_HashValue]  DEFAULT (abs(checksum(newid())%(256))) FOR [HashValue]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_refkey1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD CONSTRAINT [DF_TCPSocket_QueueTask_refkey1]  DEFAULT ('') FOR [refkey1]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_refkey2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD CONSTRAINT [DF_TCPSocket_QueueTask_refkey2]  DEFAULT ('') FOR [refkey2]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_TCPSocket_QueueTask_refkey3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[TCPSocket_QueueTask] ADD CONSTRAINT [DF_TCPSocket_QueueTask_refkey3]  DEFAULT ('') FOR [refkey3]
END

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TCPSocket_QueueTask', N'COLUMN',N'SEQ'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Commander Process Sequence' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TCPSocket_QueueTask', @level2type=N'COLUMN',@level2name=N'SEQ'

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TCPSocket_QueueTask', N'COLUMN',N'Port'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Queue Commander Port' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TCPSocket_QueueTask', @level2type=N'COLUMN',@level2name=N'Port'

END
GO 

	IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TCPSocket_QueueTask]') AND name = N'IDX_TCPSocket_QueueTask_02')
   BEGIN
   	DROP INDEX [IDX_TCPSocket_QueueTask_02] ON [dbo].[TCPSocket_QueueTask]
 	  create index IDX_TCPSocket_QueueTask_02 on TCPSocket_QueueTask ( DataStream, TransmitLogKey, Port, SEQ) include ( Storerkey , status )
   END
GO
	IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TCPSocket_QueueTask]') AND name = N'IDX_TCPSocket_QueueTask_03')
   BEGIN
      DROP INDEX [IDX_TCPSocket_QueueTask_03] ON [dbo].[TCPSocket_QueueTask]
   END
GO