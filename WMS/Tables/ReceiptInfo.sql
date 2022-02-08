CREATE TABLE [dbo].[ReceiptInfo]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EcomReceiveId] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptInfo_EcomReceiveId] DEFAULT (''),
[EcomOrderId] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptInfo_EcomOrderId] DEFAULT (''),
[ReceiptAmount] [float] NOT NULL CONSTRAINT [DF_ReceiptInfo_ReceiptAmount] DEFAULT ((0)),
[Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptInfo_Notes] DEFAULT (''),
[Notes2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptInfo_Notes2] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptInfo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ReceiptInfo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReceiptInfo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ReceiptInfo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptInfo_TrafficCop] DEFAULT (''),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptInfo_ArchiveCop] DEFAULT (''),
[StoreName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptInfo_StoreName] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiptInfo] ADD CONSTRAINT [PK__ReceiptI__507381656612B859] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_ReceiptInfo_Receiptkey] ON [dbo].[ReceiptInfo] ([ReceiptKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[ReceiptInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[ReceiptInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ReceiptInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ReceiptInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ReceiptInfo] TO [NSQL]
GO
