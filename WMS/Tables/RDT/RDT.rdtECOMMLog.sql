CREATE TABLE [RDT].[rdtECOMMLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NULL,
[ToteNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DropIDType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExpectedQty] [int] NOT NULL CONSTRAINT [DF_rdtECOMMLog_ExpectedQty] DEFAULT ((0)),
[ScannedQty] [int] NOT NULL CONSTRAINT [DF_rdtECOMMLog_ScannedQty] DEFAULT ((0)),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtECOMMLog_Status] DEFAULT ('0'),
[ErrMsg] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtECOMMLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtECOMMLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtECOMMLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtECOMMLog_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtECOMMLog_BatchKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtECOMMLog] ADD CONSTRAINT [PK_rdtECOMMLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtECOMMLog_SKU] ON [RDT].[rdtECOMMLog] ([Status], [SKU], [Mobile]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtECOMMLog_ToteNo] ON [RDT].[rdtECOMMLog] ([ToteNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtECOMMLog_ToteNo04] ON [RDT].[rdtECOMMLog] ([ToteNo], [Mobile]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtECOMMLog_ToteNo02] ON [RDT].[rdtECOMMLog] ([ToteNo], [Orderkey], [AddWho]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtECOMMLog_ToteNo01] ON [RDT].[rdtECOMMLog] ([ToteNo], [Orderkey], [SKU]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtECOMMLog_ToteNo03] ON [RDT].[rdtECOMMLog] ([ToteNo], [SKU], [AddWho]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtECOMMLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtECOMMLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtECOMMLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtECOMMLog] TO [NSQL]
GO
