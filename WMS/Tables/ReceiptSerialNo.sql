CREATE TABLE [dbo].[ReceiptSerialNo]
(
[ReceiptSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTYExpected] [int] NOT NULL,
[QTY] [int] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptSerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ReceiptSerialNo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptSerialNo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ReceiptSerialNo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiptSerialNo] ADD CONSTRAINT [PK_ReceiptSerialNo] PRIMARY KEY CLUSTERED ([ReceiptSerialNoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReceiptSerialNo_ReceiptKey_ReceiptLineNumber] ON [dbo].[ReceiptSerialNo] ([ReceiptKey], [ReceiptLineNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ReceiptSerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ReceiptSerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ReceiptSerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ReceiptSerialNo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Serial no of a receipt detail line', 'SCHEMA', N'dbo', 'TABLE', N'ReceiptSerialNo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'QTY this serial no represent (could be more than 1)', 'SCHEMA', N'dbo', 'TABLE', N'ReceiptSerialNo', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QTYExpected is interfaced', 'SCHEMA', N'dbo', 'TABLE', N'ReceiptSerialNo', 'COLUMN', N'QTYExpected'
GO
