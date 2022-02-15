CREATE TABLE [RDT].[rdtPTLPieceLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Station] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_LOC] DEFAULT (''),
[Method] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_Method] DEFAULT (''),
[CartonID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_CartonID] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_OrderKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_LoadKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_WaveKey] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_PickSlipNo] DEFAULT (''),
[BatchKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_BatchKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_ConsigneeKey] DEFAULT (''),
[ShipTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_ShipTo] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_StorerKey] DEFAULT (''),
[MaxTask] [int] NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_MaxTask] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_UserDefine03] DEFAULT (''),
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_SourceKey] DEFAULT (''),
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_SourceType] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_EditDate] DEFAULT (getdate()),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_SKU] DEFAULT (''),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_DropID] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPTLPieceLog] ADD CONSTRAINT [PK_rdtPTLPieceLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPTLPieceLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPTLPieceLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPTLPieceLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPTLPieceLog] TO [NSQL]
GO
