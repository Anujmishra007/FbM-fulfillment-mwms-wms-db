SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UploadASNImageLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UploadASNImageLog](
	[RowRef] [bigint] IDENTITY(1,1) NOT NULL,
	[Storerkey] [nvarchar](15) NOT NULL,
	[Receiptkey]  [nvarchar] (10) NULL,
	[POKey] [nvarchar](18) NULL,
	[ContainerKey] [nvarchar](18) NULL,
	[ImagePath] [nvarchar](250) NOT NULL,
	[ImageFolder] [nvarchar](100) NOT NULL,
	[ImageFile] [nvarchar](100) NOT NULL,
	[MainImageFlag] [nvarchar](5) NULL,
	[LogDate] [datetime] NULL,
 CONSTRAINT [PK_UploadASNImageLog] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_UploadASNImageLog_Receiptkey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[UploadASNImageLog] ADD  CONSTRAINT [DF_UploadASNImageLog_Receiptkey]  DEFAULT ('') FOR [Receiptkey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_UploadASNImageLog_POKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[UploadASNImageLog] ADD  CONSTRAINT [DF_UploadASNImageLog_POKey]  DEFAULT ('') FOR [POKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_UploadASNImageLog_ContainerKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[UploadASNImageLog] ADD  CONSTRAINT [DF_UploadASNImageLog_ContainerKey]  DEFAULT ('') FOR [ContainerKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_UploadASNImageLog_MainImageFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[UploadASNImageLog] ADD  CONSTRAINT [DF_UploadASNImageLog_MainImageFlag]  DEFAULT ('Y') FOR [MainImageFlag]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_UploadASNImageLog_LogDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[UploadASNImageLog] ADD  CONSTRAINT [DF_UploadASNImageLog_LogDate]  DEFAULT (getdate()) FOR [LogDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'Storerkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Storer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'Storerkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'Receiptkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Receiptkey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'Receiptkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'POKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POKey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'POKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'ContainerKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ContainerKey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'ContainerKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'ImagePath'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Image Path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'ImagePath'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'ImageFolder'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Image folder' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'ImageFolder'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'ImageFile'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Image file name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'ImageFile'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'MainImageFlag'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Main Image of the ASN flag' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'MainImageFlag'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', N'COLUMN',N'LogDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Image upload date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog', @level2type=N'COLUMN',@level2name=N'LogDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'UploadASNImageLog', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Upload ASN image log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UploadASNImageLog'
GO
