
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CartonTrack_DELLOG]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CartonTrack_DELLOG](
	[Rowref] [int] IDENTITY(1,1) NOT NULL,
	[RowRefSource] [int] NOT NULL,
	[Status] [nvarchar](1) NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[ArchiveCop] [nvarchar](1) NULL,
 CONSTRAINT [PK_CartonTrack_DELLOG] PRIMARY KEY CLUSTERED 
(
	[Rowref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_DELLOG_Status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack_DELLOG] ADD  CONSTRAINT [DF_CartonTrack_DELLOG_Status]  DEFAULT ('0') FOR [Status]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_DELLOG_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack_DELLOG] ADD  CONSTRAINT [DF_CartonTrack_DELLOG_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_CartonTrack_DELLOG_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CartonTrack_DELLOG] ADD  CONSTRAINT [DF_CartonTrack_DELLOG_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO

