SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[rdtPTLPieceLog_DEL]') AND type in (N'U'))
BEGIN

CREATE TABLE [RDT].[rdtPTLPieceLog_DEL](
	[RowRef] [int] IDENTITY(1,1) NOT NULL,
	[Station] [nvarchar](10) NOT NULL,
	[IPAddress] [nvarchar](40) NOT NULL,
	[Position] [nvarchar](10) NOT NULL,
	[LOC] [nvarchar](10) NOT NULL,
	[Method] [nvarchar](1) NOT NULL,
	[CartonID] [nvarchar](20) NOT NULL,
	[OrderKey] [nvarchar](10) NOT NULL,
	[LoadKey] [nvarchar](10) NOT NULL,
	[WaveKey] [nvarchar](10) NOT NULL,
	[PickSlipNo] [nvarchar](10) NOT NULL,
	[BatchKey] [nvarchar](20) NOT NULL,
	[ConsigneeKey] [nvarchar](15) NOT NULL,
	[ShipTo] [nvarchar](15) NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[MaxTask] [int] NOT NULL,
	[UserDefine01] [nvarchar](30) NOT NULL,
	[UserDefine02] [nvarchar](30) NOT NULL,
	[UserDefine03] [nvarchar](30) NOT NULL,
	[SourceKey] [nvarchar](20) NOT NULL,
	[SourceType] [nvarchar](30) NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[SKU] [nvarchar](20) NOT NULL,
	[DropID] [nvarchar](20) NOT NULL,
	[DelWho] [nvarchar](128) NOT NULL,
	[DelDate] [datetime] NOT NULL,
 CONSTRAINT [PK_rdtPTLPieceLog_DEL] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLPieceLog_DEL_DelWho]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLPieceLog_DEL] ADD  CONSTRAINT [DF_rdtPTLPieceLog_DEL_DelWho]  DEFAULT (suser_sname()) FOR [DelWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLPieceLog_DEL_DelDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLPieceLog_DEL] ADD  CONSTRAINT [DF_rdtPTLPieceLog_DEL_DelDate]  DEFAULT (getdate()) FOR [DelDate]
END
GO


