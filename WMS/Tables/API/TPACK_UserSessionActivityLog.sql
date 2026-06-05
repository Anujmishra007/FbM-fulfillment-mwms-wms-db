SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[API].[TPACK_UserSessionActivityLog]') AND type in (N'U'))
BEGIN

CREATE TABLE [API].[TPACK_UserSessionActivityLog](
   [RowRefNo] BIGINT IDENTITY(1,1),
   [PickSlipNo] [nvarchar](10) NOT NULL,
   [CartonNo] [int] NULL,
   [LabelNo] [nvarchar](20) NULL,
   [OrderKey] [nvarchar](10) NULL,
   [LoadKey] [nvarchar](10) NULL,
   [DropID] [nvarchar](20) NULL,
   [StorerKey] [nvarchar](15) NOT NULL,
   [Facility] [nvarchar](5) NOT NULL,
   [Workstation] [nvarchar](30) NOT NULL,
   [LabelPrinter] [nvarchar](20) NOT NULL,
   [PaperPrinter] [nvarchar](20) NOT NULL,
   [AddDate] [datetime] NULL,
   [AddWho] [nvarchar](128) NULL,
   [EditDate] [datetime] NULL,
   [EditWho] [nvarchar](128) NULL,
 CONSTRAINT [PK_TPACK_UserSessionActivityLog] PRIMARY KEY CLUSTERED 
(
	[RowRefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_CartonNo]  DEFAULT ((0)) FOR [CartonNo]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_LabelNo]  DEFAULT ('') FOR [LabelNo]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_OrderKey]  DEFAULT ('') FOR [OrderKey]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_LoadKey]  DEFAULT ('') FOR [LoadKey]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_DropID]  DEFAULT ('') FOR [DropID]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_AddDate]  DEFAULT (getdate()) FOR [AddDate]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_EditDate]  DEFAULT (getdate()) FOR [EditDate]

ALTER TABLE [API].[TPACK_UserSessionActivityLog] ADD  CONSTRAINT [DF_TPACK_UserSessionActivityLog_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO