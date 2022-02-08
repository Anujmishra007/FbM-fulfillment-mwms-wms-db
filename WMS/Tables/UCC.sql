CREATE TABLE [dbo].[UCC]
(
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qty] [int] NULL,
[Sourcekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sourcetype] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefined01] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined01] DEFAULT (''),
[Userdefined02] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined02] DEFAULT (''),
[Userdefined03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined03] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_UCC_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_UCC_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_EditWho] DEFAULT (suser_sname()),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_LOT] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_LOC] DEFAULT (''),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_ID] DEFAULT (''),
[Receiptkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Receiptkey] DEFAULT (' '),
[ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_ReceiptLineNumber] DEFAULT (' '),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Orderkey] DEFAULT (' '),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_OrderLineNumber] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_WaveKey] DEFAULT (' '),
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_PickDetailKey] DEFAULT (' '),
[Userdefined04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined04] DEFAULT (''),
[Userdefined05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined05] DEFAULT (''),
[Userdefined06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined06] DEFAULT (''),
[Userdefined07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined07] DEFAULT (''),
[Userdefined08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined08] DEFAULT (''),
[Userdefined09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined09] DEFAULT (''),
[Userdefined10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined10] DEFAULT (''),
[UCC_RowRef] [int] NOT NULL IDENTITY(1, 1),
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UCC] ADD CONSTRAINT [PK_UCC] PRIMARY KEY NONCLUSTERED ([UCC_RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_LOC] ON [dbo].[UCC] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_LOTxLOCxID] ON [dbo].[UCC] ([Lot], [Loc], [Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_Pickdetailkey] ON [dbo].[UCC] ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_Receipt] ON [dbo].[UCC] ([Receiptkey], [ReceiptLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_SourceKey] ON [dbo].[UCC] ([Sourcekey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_ExternKey] ON [dbo].[UCC] ([Storerkey], [ExternKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_StorerKey_LOC_ID] ON [dbo].[UCC] ([Storerkey], [Loc], [Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_StorerKey_SKU] ON [dbo].[UCC] ([Storerkey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_SKU_LOT_LOC] ON [dbo].[UCC] ([Storerkey], [SKU], [Lot], [Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_Storerkey_Status_Userdefined05_Userdefined06] ON [dbo].[UCC] ([Storerkey], [Status], [Userdefined05], [Userdefined06]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_StorerKey_Userdefined04] ON [dbo].[UCC] ([Storerkey], [Userdefined04]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IDX_UCC_UCCNo] ON [dbo].[UCC] ([UCCNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[UCC] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[UCC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UCC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UCC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UCC] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Uniform Commercial Code (UCC) provides a global standard in identification of pallets/cartons of products, rolls, drums etc.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External reference number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'ExternKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet id (if any)', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location of the Commodity in the facility', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot number associated to the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment order number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment order line number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'OrderLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Detail.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stock on hand', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ASN/receipt number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Receiptkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ASN/receipt line number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'ReceiptLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique identifier for the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifier associated with the source document creating the transaction, usually a combination of the document number plus the line number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of source document creating the transaction; usually the internal name of the trigger or stored procedure that generated the transaction', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Sourcetype'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status  0 - New  1 - Received  3 - Allocated   4 - Pick in progress  6 - Complete', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Owner of the goods/Commodity', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique number to identify the carton or pallet which is standard and will be used from suppliers to customers', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'UCCNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined01 - can be used to store references', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Userdefined01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined02 - can be used to store references', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Userdefined02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined03 - can be used to store references', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Userdefined03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'WaveKey'
GO
