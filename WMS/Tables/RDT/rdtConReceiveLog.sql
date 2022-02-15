CREATE TABLE [RDT].[rdtConReceiveLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtConReceiveLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtConReceiveLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtConReceiveLog] ADD CONSTRAINT [PK_rdtConReceiveLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_rdtConReceiveLog_ReceiptKey_Mobile] ON [RDT].[rdtConReceiveLog] ([ReceiptKey], [Mobile]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtConReceiveLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtConReceiveLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtConReceiveLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtConReceiveLog] TO [NSQL]
GO
