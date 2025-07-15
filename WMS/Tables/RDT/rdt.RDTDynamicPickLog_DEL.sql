SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[RDTDynamicPickLog_DEL]') AND type in (N'U'))
BEGIN
CREATE TABLE [RDT].[RDTDynamicPickLog_DEL](
	[RowRef] [int] IDENTITY(1,1) NOT NULL,
	[Zone] [nvarchar](10) NULL,
	[Loc] [nvarchar](10) NULL,
	[PickSlipNo] [nvarchar](10) NULL,
	[CartonNo] [int] NULL,
	[LabelNo] [nvarchar](20) NULL,
	[AddDate] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[DelDate] [datetime] NULL,
	[DelWho] [nvarchar](128) NULL,
 CONSTRAINT [PK_RDTDynamicPickLog_DEL] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_RDTDynamicPickLog_DEL_DelDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[RDTDynamicPickLog_DEL] ADD  CONSTRAINT [DF_RDTDynamicPickLog_DEL_DelDate]  DEFAULT (getdate()) FOR [DelDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[DF_RDTDynamicPickLog_DEL_DelDate]') AND type = 'D')
BEGIN
ALTER TABLE [RDT].[RDTDynamicPickLog_DEL] ADD  CONSTRAINT [DF_RDTDynamicPickLog_DEL_DelWho]  DEFAULT (suser_sname()) FOR [DelWho]
END
GO


