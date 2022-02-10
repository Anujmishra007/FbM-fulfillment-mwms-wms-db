CREATE TABLE [dbo].[RECEIPTDETAIL_WIP]
(
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[SessionID] [bigint] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_SessionID] DEFAULT ((0)),
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_ReceiptKey] DEFAULT (''),
[POKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_POKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_StorerKey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Sku] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Qty] DEFAULT ((0)),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_ToLoc] DEFAULT (''),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_ToID] DEFAULT (''),
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UCCNo] DEFAULT (''),
[RFIDNo1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_RFIDNo1] DEFAULT (''),
[RFIDNo2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_RFIDNo2] DEFAULT (''),
[TIDNo1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_TIDNo1] DEFAULT (''),
[TIDNo2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_TIDNo2] DEFAULT (''),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable01] DEFAULT (''),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable02] DEFAULT (''),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable03] DEFAULT (''),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_UserDefine10] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LockDocKey] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_WIP_LockDocKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RECEIPTDETAIL_WIP] ADD CONSTRAINT [PKRECEIPTDETAIL_WIP] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BTB_RECEIPTDETAIL_WIP_SessionID] ON [dbo].[RECEIPTDETAIL_WIP] ([SessionID], [ReceiptKey], [POKey], [ToID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BTB_RECEIPTDETAIL_WIP_SkuLA] ON [dbo].[RECEIPTDETAIL_WIP] ([SessionID], [Storerkey], [Sku], [ToLoc], [ToID], [UCCNo], [Lottable01], [Lottable02], [Lottable03], [Lottable06], [Lottable07], [Lottable08], [Lottable09], [Lottable10], [Lottable11], [Lottable12]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RECEIPTDETAIL_WIP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RECEIPTDETAIL_WIP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RECEIPTDETAIL_WIP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RECEIPTDETAIL_WIP] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'System generate all tasks to the Task Detail table, these tasks are then released to the authorized workers through RDT terminals according to the task priority, location & task type.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Locking Receiptkey', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'LockDocKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable01', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable02', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable03', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable04', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable05', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable06', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable07', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable08', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable09', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable11', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable12', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable13', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable14', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lottable15', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PO #', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Receipt #', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RFID #1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'RFIDNo1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RFID #2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'RFIDNo2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Taskdetail WIP Row ID', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'RowID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Session ID', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'SessionID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tid #1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'TIDNo1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tid #2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'TIDNo2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ToID', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'ToID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Receive to Loc', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UCC #', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UCCNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine01', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine02', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine03', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine04', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine05', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine06', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine07', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine08', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine09', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL_WIP', 'COLUMN', N'UserDefine10'
GO
