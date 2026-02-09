SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PackInfo_AuditLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PackInfo_AuditLog](
   [RowRefNo] BIGINT IDENTITY(1,1),
   [ActionType] [nvarchar](10) NOT NULL,
   [PickSlipNo] [nvarchar](10) NOT NULL,
   [CartonNo] [int] NOT NULL,
   [Weight] [float] NULL,
   [Cube] [float] NULL,
   [Qty] [int] NULL,
   [AddDate] [datetime] NULL,
   [AddWho] [nvarchar](128) NULL,
   [EditDate] [datetime] NULL,
   [EditWho] [nvarchar](128) NULL,
   [TrafficCop] [nvarchar](1) NULL,
   [ArchiveCop] [nvarchar](1) NULL,
   [CartonType] [nvarchar](10) NULL,
   [RefNo] [nvarchar](40) NULL,
   [Length] [float] NULL,
   [Width] [float] NULL,
   [Height] [float] NULL,
   [UCCNo] [nvarchar](20) NULL,
   [CartonGID] [nvarchar](50) NULL,
   [CartonStatus] [nvarchar](20) NULL,
   [TrackingNo] [nvarchar](40) NULL,
 CONSTRAINT [PK_PackInfo_AuditLog] PRIMARY KEY CLUSTERED 
(
	[RowRefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_Weight]  DEFAULT ((0)) FOR [Weight]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_Cube]  DEFAULT ((0)) FOR [Cube]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_Qty]  DEFAULT ((0)) FOR [Qty]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_AddDate]  DEFAULT (getdate()) FOR [AddDate]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_EditDate]  DEFAULT (getdate()) FOR [EditDate]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_CartonType]  DEFAULT (' ') FOR [CartonType]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_Length]  DEFAULT ((0.00)) FOR [Length]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_Width]  DEFAULT ((0.00)) FOR [Width]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_Height]  DEFAULT ((0.00)) FOR [Height]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_UCCNo]  DEFAULT ('') FOR [UCCNo]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_CartonGID]  DEFAULT ('') FOR [CartonGID]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_CartonStatus]  DEFAULT ('') FOR [CartonStatus]

ALTER TABLE [dbo].[PackInfo_AuditLog] ADD  CONSTRAINT [DF_PackInfo_AuditLog_TrackingNo]  DEFAULT ('') FOR [TrackingNo]

END
