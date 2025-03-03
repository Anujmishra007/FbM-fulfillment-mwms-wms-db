SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[rdtPTLStationLog_DEL]') AND type in (N'U'))
BEGIN

CREATE TABLE [RDT].[rdtPTLStationLog_DEL](
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
	[CreatedPTLTran] [nvarchar](1) NOT NULL,
	[SKU] [nvarchar](20) NOT NULL,
	[ItemClass] [nvarchar](10) NOT NULL,
	[DelWho] [nvarchar](128) NULL,
	[DelDate] [datetime] NULL,
 CONSTRAINT [PK_rdtPTLStationLog_DEL] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_LOC]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_LOC]  DEFAULT ('') FOR [LOC]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_Method]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_Method]  DEFAULT ('') FOR [Method]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_CartonID]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_CartonID]  DEFAULT ('') FOR [CartonID]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_OrderKey]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_OrderKey]  DEFAULT ('') FOR [OrderKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_LoadKey]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_LoadKey]  DEFAULT ('') FOR [LoadKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_WaveKey]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_WaveKey]  DEFAULT ('') FOR [WaveKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_PickSlipNo]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_PickSlipNo]  DEFAULT ('') FOR [PickSlipNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_BatchKey]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_BatchKey]  DEFAULT ('') FOR [BatchKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_ConsigneeKey]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_ConsigneeKey]  DEFAULT ('') FOR [ConsigneeKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_ShipTo]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_ShipTo]  DEFAULT ('') FOR [ShipTo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_StorerKey]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_StorerKey]  DEFAULT ('') FOR [StorerKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_MaxTask]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_MaxTask]  DEFAULT ((0)) FOR [MaxTask]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_UserDefine01]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_UserDefine01]  DEFAULT ('') FOR [UserDefine01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_UserDefine02]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_UserDefine02]  DEFAULT ('') FOR [UserDefine02]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_UserDefine03]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_UserDefine03]  DEFAULT ('') FOR [UserDefine03]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_SourceKey]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_SourceKey]  DEFAULT ('') FOR [SourceKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_SourceType]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_SourceType]  DEFAULT ('') FOR [SourceType]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_CreatedPTLTran]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_CreatedPTLTran]  DEFAULT ('') FOR [CreatedPTLTran]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_SKU]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_SKU]  DEFAULT ('') FOR [SKU]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_ItemClass]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_ItemClass]  DEFAULT ('') FOR [ItemClass]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_DelWho]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_DelWho]  DEFAULT (suser_name()) FOR [DelWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_rdtPTLStationLog_DEL_DelDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtPTLStationLog_DEL] ADD  CONSTRAINT [DF_rdtPTLStationLog_DEL_DelDate]  DEFAULT (getdate()) FOR [DelDate]
END
GO


