CREATE TABLE [RDT].[rdtMsgQueue]
(
[MsgQueueNo] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtMsgQueue_Status] DEFAULT ('0'),
[Line01] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line02] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line03] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line04] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line05] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line06] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line07] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line08] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line09] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line10] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line11] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line12] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line13] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line14] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line15] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtMsgQueue_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtMsgQueue] ADD CONSTRAINT [PK_rdtMsgQueue] PRIMARY KEY CLUSTERED ([MsgQueueNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
