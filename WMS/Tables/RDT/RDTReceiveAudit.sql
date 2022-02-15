CREATE TABLE [RDT].[RDTReceiveAudit]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTReceiveAudit_UCCNo] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PQty] [int] NULL,
[CQty] [int] NULL,
[Position] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoofCheck] [int] NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTReceiveAudit_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTReceiveAudit_AddWho] DEFAULT (getdate()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDTReceiveAudit_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTReceiveAudit_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTReceiveAudit] ADD CONSTRAINT [PK_RDTReceiveAudit] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTReceiveAudit] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTReceiveAudit] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTReceiveAudit] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTReceiveAudit] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Add Date', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Add Who', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'CQty', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'CQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Descr', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Edit Date', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Edit Who', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'No of Check', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'NoofCheck'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Position', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'Position'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PQty', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'PQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Receipt Key', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row Ref', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer Key', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UCC No', 'SCHEMA', N'RDT', 'TABLE', N'RDTReceiveAudit', 'COLUMN', N'UCCNo'
GO
