CREATE TABLE [dbo].[TCPSocket_INLog]
(
[SerialNo] [int] NOT NULL IDENTITY(1, 1),
[Application] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_INLog_Application] DEFAULT (''),
[LocalEndPoint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_INLog_LocalEndPoint] DEFAULT (''),
[RemoteEndPoint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_INLog_RemoteEndPoint] DEFAULT (''),
[MessageType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_INLog_MessageType] DEFAULT (''),
[Data] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_INLog_Data] DEFAULT (''),
[MessageNum] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_INLog_MessageNum] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[ErrMsg] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_INLog_ErrMsg] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_INLog_Status] DEFAULT ('0'),
[NoOfTry] [int] NOT NULL CONSTRAINT [DF_TCPSocket_INLog_NoOfTry] DEFAULT ((0)),
[EmailSent] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_INLog_EmailSent] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_INLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_INLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_INLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_INLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACKData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TCPSocket_INLog_ACKData] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TCPSocket_INLog] ADD CONSTRAINT [PK_TCPSocket_INLog] PRIMARY KEY CLUSTERED ([SerialNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TCPSocket_INLog_MessageNum] ON [dbo].[TCPSocket_INLog] ([MessageNum]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TCPSocket_INLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TCPSocket_INLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TCPSocket_INLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TCPSocket_INLog] TO [NSQL]
GO
