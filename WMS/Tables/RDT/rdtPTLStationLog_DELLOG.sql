CREATE TABLE [RDT].[rdtPTLStationLog_DELLOG]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Station] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_LOC] DEFAULT (''),
[Method] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_Method] DEFAULT (''),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_CartonID] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_OrderKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_LoadKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_WaveKey] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_PickSlipNo] DEFAULT (''),
[BatchKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_BatchKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_ConsigneeKey] DEFAULT (''),
[ShipTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_ShipTo] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_StorerKey] DEFAULT (''),
[MaxTask] [int] NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_MaxTask] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_UserDefine03] DEFAULT (''),
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_SourceKey] DEFAULT (''),
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_SourceType] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_EditDate] DEFAULT (getdate()),
[CreatedPTLTran] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLStationLog_DELLOG_CreatedPTLTran] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPTLStationLog_DELLOG] ADD CONSTRAINT [PK_rdtPTLStationLog_DELLOG] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPTLStationLog_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPTLStationLog_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPTLStationLog_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPTLStationLog_DELLOG] TO [NSQL]
GO
