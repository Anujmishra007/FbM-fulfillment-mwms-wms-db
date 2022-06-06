CREATE TABLE [RDT].[rdtPTLPieceLog_Log](
	[RowRef] INT IDENTITY (1,1) NOT NULL,
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
 CONSTRAINT [PK_rdtPTLPieceLog_Log] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80 ) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [RDT].[rdtPTLPieceLog_Log] ADD  CONSTRAINT [DF_rdtPTLPieceLog_Log_DelWho]  DEFAULT (suser_sname()) FOR [DelWho]

ALTER TABLE [RDT].[rdtPTLPieceLog_Log] ADD  CONSTRAINT [DF_rdtPTLPieceLog_Log_DelDate]  DEFAULT (getdate()) FOR [DelDate]



