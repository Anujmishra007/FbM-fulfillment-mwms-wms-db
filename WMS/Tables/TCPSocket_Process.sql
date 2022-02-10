CREATE TABLE [dbo].[TCPSocket_Process]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SprocName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESCR] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient1] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient2] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient3] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient4] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recipient5] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_Process_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_Process_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TCPSocket_Process_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_Process_EditWho] DEFAULT (suser_sname()),
[MessageGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TCPSocket_Process_MessageGroup] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TCPSocket_Process] ADD CONSTRAINT [PK_TCPSocket_Process] PRIMARY KEY CLUSTERED ([MessageName], [MessageGroup], [StorerKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TCPSocket_Process] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TCPSocket_Process] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TCPSocket_Process] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TCPSocket_Process] TO [NSQL]
GO
