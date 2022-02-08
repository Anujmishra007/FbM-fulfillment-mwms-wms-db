CREATE TABLE [RDT].[rdtPreReceiveSort2Log]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Facility] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPreReceiveSort2Log_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPreReceiveSort2Log_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPreReceiveSort2Log_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPreReceiveSort2Log_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPreReceiveSort2Log_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPreReceiveSort2Log] ADD CONSTRAINT [PKPreReceiveSortLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtPreReceiveSort2Log_UCCNo_StorerKey] ON [RDT].[rdtPreReceiveSort2Log] ([UCCNo], [StorerKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPreReceiveSort2Log] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPreReceiveSort2Log] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPreReceiveSort2Log] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPreReceiveSort2Log] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date added the record', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User name who added the record', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date edited the record', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User name who edited the record', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet ID sort to', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'LOC/Position sort to', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'LOC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Qty in carton/UCC', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ReceiptKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique key within table.', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SKU code', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of the record', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UCC No', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'UCCNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 01', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 02', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 03', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 04', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 05', 'SCHEMA', N'RDT', 'TABLE', N'rdtPreReceiveSort2Log', 'COLUMN', N'UDF05'
GO
