CREATE TABLE [RDT].[rdtPTLCartLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[CartID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToteID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeviceProfileLogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Method] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_PickZone] DEFAULT (''),
[PickSeq] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_PickSeq] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_OrderKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_LoadKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_WaveKey] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_PickSlipNo] DEFAULT (''),
[BatchKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_BatchKey] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_SKU] DEFAULT (''),
[MaxTask] [int] NOT NULL CONSTRAINT [DF_rdtPTLCartLog_MaxTask] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLCartLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLCartLog_EditDate] DEFAULT (getdate()),
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_CaseID] DEFAULT (''),
[ItemClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_ItemClass] DEFAULT (''),
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLCartLog_Route] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPTLCartLog] ADD CONSTRAINT [PK_rdtPTLCartLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_rdtPTLCartLog_CartID_ToteID_Position] ON [RDT].[rdtPTLCartLog] ([CartID], [ToteID], [Position]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPTLCartLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPTLCartLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPTLCartLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPTLCartLog] TO [NSQL]
GO
