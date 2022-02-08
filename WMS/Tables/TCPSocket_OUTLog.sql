CREATE TABLE [dbo].[TCPSocket_OUTLog]
(
[SerialNo] [int] NOT NULL IDENTITY(1, 1),
[Application] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocalEndPoint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RemoteEndPoint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageNum] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrMsg] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_Status] DEFAULT ('0'),
[NoOfTry] [int] NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_NoOfTry] DEFAULT ((0)),
[EmailSent] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_EmailSent] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACKData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GUIDRef] [uniqueidentifier] NOT NULL CONSTRAINT [DF_TCPSocket_OUTLog_GUIDRef] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TCPSocket_OUTLog] ADD CONSTRAINT [PK_TCPSocket_OUTLog] PRIMARY KEY CLUSTERED ([GUIDRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TCPSocket_OUTLog_MsgNo] ON [dbo].[TCPSocket_OUTLog] ([MessageNum]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TCPSocket_OUTLog_PK] ON [dbo].[TCPSocket_OUTLog] ([SerialNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TCPSocket_OUTLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TCPSocket_OUTLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TCPSocket_OUTLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TCPSocket_OUTLog] TO [NSQL]
GO
