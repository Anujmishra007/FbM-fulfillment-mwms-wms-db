IF NOT EXISTS (SELECT 1
FROM sys.tables
WHERE name = 'rdtMsgQueue' AND type = 'U')
BEGIN
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
   [DisplayMsg] INT NULL DEFAULT (1),
   [AddDate] [datetime] NULL CONSTRAINT [DF_rdtMsgQueue_AddDate] DEFAULT (getdate())
   ) ON [PRIMARY]

   ALTER TABLE [RDT].[rdtMsgQueue] ADD CONSTRAINT [PK_rdtMsgQueue] PRIMARY KEY CLUSTERED ([MsgQueueNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
END
ELSE
BEGIN
   IF NOT EXISTS (SELECT 1
   FROM sys.columns
   WHERE Name = 'DisplayMsg' AND Object_ID = Object_ID('RDT.rdtMsgQueue'))
   BEGIN
      ALTER TABLE RDT.rdtMsgQueue ADD DisplayMsg INT NULL;
      EXEC sp_addextendedproperty N'MS_Description', N'Display the message if it is 1.', 'SCHEMA', N'rdt', 'TABLE', N'rdtMsgQueue', 'COLUMN', N'DisplayMsg'
   END
END
GO
GRANT DELETE ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtMsgQueue] TO [NSQL]
GO
