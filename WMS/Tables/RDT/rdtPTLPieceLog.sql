IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtPTLPieceLog]') AND type in (N'U'))
BEGIN
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
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_DropID] DEFAULT (''),
[Style] [nvarchar](20) NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_Style]  DEFAULT (''),
) ON [PRIMARY]


ALTER TABLE [RDT].[rdtPTLPieceLog] ADD CONSTRAINT [PK_rdtPTLPieceLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]

GRANT DELETE ON  [RDT].[rdtPTLPieceLog] TO [NSQL]

GRANT INSERT ON  [RDT].[rdtPTLPieceLog] TO [NSQL]

GRANT SELECT ON  [RDT].[rdtPTLPieceLog] TO [NSQL]

GRANT UPDATE ON  [RDT].[rdtPTLPieceLog] TO [NSQL]


END 

ELSE 
BEGIN

			 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'Style' AND Object_ID = Object_ID('RDT.rdtPTLPieceLog'))
			BEGIN

				ALTER TABLE [RDT].[rdtPTLPieceLog] ADD Style [nvarchar](20) NOT NULL CONSTRAINT [DF_rdtPTLPieceLog_Style]  DEFAULT ('') ;
				EXEC sp_addextendedproperty N'MS_Description', 'Style', 'SCHEMA', N'RDT', 'TABLE', N'rdtPTLPieceLog', 'COLUMN', N'Style'
				
			END
END


