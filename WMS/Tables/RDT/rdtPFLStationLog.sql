CREATE TABLE [RDT].[rdtPFLStationLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Station] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Method] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_OrderKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_LoadKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_WaveKey] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_PickSlipNo] DEFAULT (''),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_DropID] DEFAULT (''),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_CartonID] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPFLStationLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPFLStationLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPFLStationLog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPFLStationLog] ADD CONSTRAINT [PK_rdtPFLStationLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_rdtPFLStationLog_Station] ON [RDT].[rdtPFLStationLog] ([Station]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPFLStationLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPFLStationLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPFLStationLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPFLStationLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick from light station, criteria operator currently work on.', 'SCHEMA', N'RDT', 'TABLE', N'rdtPFLStationLog', NULL, NULL
GO
