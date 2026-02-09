USE [GTOps]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EcomPackCCTVApiLog](
	[SeqNo] [int] IDENTITY(1,1) NOT NULL,
	[DataStream] [nvarchar](10) NOT NULL,
	[Direction] [nvarchar](1) NOT NULL,
	[APIName] [nvarchar](50) NOT NULL,
	[PackStation] [nvarchar](50) NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[Facility] [nvarchar](5) NOT NULL,
	[Operator] [nvarchar](20) NULL,
	[Status] [nvarchar](10) NOT NULL,
	[RequestBody] [nvarchar](500) NULL,
	[ResponseBody] [nvarchar](1000) NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[UserRef01] [nvarchar](500) NULL,
	[UserRef02] [nvarchar](500) NULL,
	[UserRef03] [nvarchar](500) NULL,
	[TaskBatchNo] [nvarchar](10) NULL,
	[TrackingNo] [nvarchar](40) NULL,
	[OrderKey] [nvarchar](10) NULL,
	[OrderNo] [nvarchar](100) NULL,
 CONSTRAINT [PK_EcomPackCCTVApiLog] PRIMARY KEY CLUSTERED 
(
	[SeqNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EcomPackCCTVApiLog] ADD  CONSTRAINT [DF_EcomPackCCTVApiLog_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [dbo].[EcomPackCCTVApiLog] ADD  CONSTRAINT [DF_EcomPackCCTVApiLog_AddWho]  DEFAULT (suser_name()) FOR [AddWho]
GO

ALTER TABLE [dbo].[EcomPackCCTVApiLog] ADD  CONSTRAINT [DF_EcomPackCCTVApiLog_EditDate]  DEFAULT (getdate()) FOR [EditDate]
GO

ALTER TABLE [dbo].[EcomPackCCTVApiLog] ADD  CONSTRAINT [DF_EcomPackCCTVApiLog_EditWho]  DEFAULT (suser_name()) FOR [EditWho]
GO


