CREATE TABLE [RDT].[rdtPTLStationLogQueue]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Station] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_LOC] DEFAULT (''),
[Method] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_Method] DEFAULT (''),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_CartonID] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_OrderKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_LoadKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_WaveKey] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_PickSlipNo] DEFAULT (''),
[BatchKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_BatchKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_ConsigneeKey] DEFAULT (''),
[ShipTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_ShipTo] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_StorerKey] DEFAULT (''),
[MaxTask] [int] NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_MaxTask] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_UserDefine03] DEFAULT (''),
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_SourceKey] DEFAULT (''),
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_SourceType] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_EditDate] DEFAULT (getdate()),
[CreatedPTLTran] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_CreatedPTLTran] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_SKU] DEFAULT (''),
[ItemClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_ItemClass] DEFAULT (''),
[DataPopulated] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLogQueue_DataPopulated] DEFAULT ('0')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPTLStationLogQueue] ADD CONSTRAINT [PK_rdtPTLStationLogQueue] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtPTLStationLog_Loc] ON [RDT].[rdtPTLStationLogQueue] ([LOC]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPTLStationLogQueue] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPTLStationLogQueue] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPTLStationLogQueue] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPTLStationLogQueue] TO [NSQL]
GO
