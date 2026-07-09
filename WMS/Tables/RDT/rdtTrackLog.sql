SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtTrackLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [RDT].[rdtTrackLog](
	[RowRef] [int] IDENTITY(1,1) NOT NULL,
	[Mobile] [int] NULL,
	[Username] [nvarchar](128) NOT NULL,
	[Storerkey] [nvarchar](15) NOT NULL,
	[Orderkey] [nvarchar](10) NOT NULL,
	[TrackNo] [nvarchar](40) NOT NULL,
	[SKU] [nvarchar](20) NOT NULL,
	[Qty] [int] NOT NULL,
	[QtyAllocated] [int] NOT NULL,
	[Status] [nvarchar](1) NOT NULL,
	[ErrMsg] [nvarchar](250) NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[PickSlipNo] [nvarchar](10) NULL,
	[CartonNo] [int] NULL,
	[LabelNo] [nvarchar](20) NULL,
 CONSTRAINT [PK_rdtTrackLog] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[RDT].[rdtTrackLog]') AND name = N'IX_rdtTrackLog01')
CREATE NONCLUSTERED INDEX [IX_rdtTrackLog01] ON [RDT].[rdtTrackLog]
(
	[Orderkey] ASC,
	[TrackNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[RDT].[rdtTrackLog]') AND name = N'IX_rdtTrackLog_Addwho')
CREATE NONCLUSTERED INDEX [IX_rdtTrackLog_Addwho] ON [RDT].[rdtTrackLog]
(
	AddWho ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[RDT].[rdtTrackLog]') AND name = N'IX_rdtTrackLog_PickSlipNo')
CREATE NONCLUSTERED INDEX [IX_rdtTrackLog_PickSlipNo] ON [RDT].[rdtTrackLog]
(
	PickSlipNo ASC, CartonNo ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_Qty]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_Qty]  DEFAULT ((0)) FOR [Qty]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_QtyAllocated]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_QtyAllocated]  DEFAULT ((0)) FOR [QtyAllocated]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_Status]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_Status]  DEFAULT ('0') FOR [Status]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_PickSlipNo]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_PickSlipNo]  DEFAULT ('') FOR [PickSlipNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_CartonNo]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_CartonNo]  DEFAULT ((0)) FOR [CartonNo]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[DF_rdtTrackLog_LabelNo]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[rdtTrackLog] ADD  CONSTRAINT [DF_rdtTrackLog_LabelNo]  DEFAULT ('') FOR [LabelNo]
END
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RDTTRACKLOG' AND COLUMN_NAME = 'TrackNo' AND CHARACTER_MAXIMUM_LENGTH = 40)
BEGIN
ALTER TABLE RDT.RDTTRACKLOG ALTER COLUMN TrackNo NVARCHAR(40) NOT NULL 
END
GO