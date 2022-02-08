CREATE TABLE [dbo].[ReceiptKey]
(
[ReceiptKey] [bigint] NOT NULL IDENTITY(1, 1),
[AddDate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ReceiptKey] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ReceiptKey] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ReceiptKey] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ReceiptKey] TO [NSQL]
GO
