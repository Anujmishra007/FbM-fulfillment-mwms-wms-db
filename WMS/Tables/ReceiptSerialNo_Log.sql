IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReceiptSerialNo_Log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ReceiptSerialNo_Log](
[RowRef] INT IDENTITY (1,1) NOT NULL,
[ReceiptSerialNoKey] [bigint] NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[UCCNo] [nvarchar](20) NULL,
CONSTRAINT [PK_ReceiptSerialNo_Log] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ReceiptSerialNo_Log_ReceiptKey_ReceiptLineNumber] ON [dbo].[ReceiptSerialNo_Log] ([ReceiptKey], [ReceiptLineNumber]) ON [PRIMARY]


GRANT DELETE ON  [dbo].[ReceiptSerialNo_Log] TO [NSQL]
GRANT INSERT ON  [dbo].[ReceiptSerialNo_Log] TO [NSQL]
GRANT SELECT ON  [dbo].[ReceiptSerialNo_Log] TO [NSQL]
GRANT UPDATE ON  [dbo].[ReceiptSerialNo_Log] TO [NSQL]



EXEC sp_addextendedproperty N'MS_Description', 'Serial no of a receipt detail line', 'SCHEMA', N'dbo', 'TABLE', N'ReceiptSerialNo_Log', NULL, NULL

EXEC sp_addextendedproperty N'MS_Description', 'QTY this serial no represent (could be more than 1)', 'SCHEMA', N'dbo', 'TABLE', N'ReceiptSerialNo_Log', 'COLUMN', N'QTY'

EXEC sp_addextendedproperty N'MS_Description', 'Store UCC No', 'SCHEMA', N'dbo', 'TABLE', N'ReceiptSerialNo_Log', 'COLUMN', N'UCCNo'

END



