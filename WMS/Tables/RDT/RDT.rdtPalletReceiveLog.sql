CREATE TABLE [RDT].[rdtPalletReceiveLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPalletReceiveLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPalletReceiveLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPalletReceiveLog] ADD CONSTRAINT [PK_rdtPalletReceiveLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_rdtPalletReceiveLog_ReceiptKey_Mobile] ON [RDT].[rdtPalletReceiveLog] ([ReceiptKey], [Mobile]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPalletReceiveLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPalletReceiveLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPalletReceiveLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPalletReceiveLog] TO [NSQL]
GO
