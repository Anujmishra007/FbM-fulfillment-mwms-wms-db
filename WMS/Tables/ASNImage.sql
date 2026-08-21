SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASNImage]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ASNImage](
	[ASNImageKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Storerkey] [nvarchar](20) NOT NULL,
	[Receiptkey]  [nvarchar] (10) NULL,
	[POKey] [nvarchar](18) NULL,
	[ContainerKey] [nvarchar](18) NULL,
	[ImageFolder] [nvarchar] (200) NOT NULL,
	[ImageFile] [nvarchar](50) NOT NULL,
	[AddDate] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
 CONSTRAINT [PK_ASNImage] PRIMARY KEY CLUSTERED 
(
	[ASNImageKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ASNImage]') AND name = N'IDX_ASNImage_ImageFile')
CREATE NONCLUSTERED INDEX [IDX_ASNImage_ImageFile] ON [dbo].[ASNImage]
(
	[Storerkey] ASC,
	[Receiptkey] ASC,
	[ImageFile] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_Storerkey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_Storerkey]  DEFAULT ('') FOR [Storerkey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_Receiptkey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_Receiptkey]  DEFAULT ('') FOR [Receiptkey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_POKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_POKey]  DEFAULT ('') FOR [POKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_ContainerKey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_ContainerKey]  DEFAULT ('') FOR [ContainerKey]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_ImageFolder]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_ImageFolder]  DEFAULT ('') FOR [ImageFolder]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_ImageFile]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_ImageFile]  DEFAULT ('') FOR [ImageFile]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_AddWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_EditDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_EditDate]  DEFAULT (getdate()) FOR [EditDate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_ASNImage_EditWho]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ASNImage] ADD  CONSTRAINT [DF_ASNImage_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'ASNImageKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'ASNImageKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'Storerkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Storerkey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'Storerkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'Receiptkey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Receiptkey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'Receiptkey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'POKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POKey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'POKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'ContainerKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ContainerKey' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'ContainerKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'ImageFolder'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Image Folder' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'ImageFolder'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'ImageFile'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Image File' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'ImageFile'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'AddDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'AddDate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'AddDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'AddWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'AddWho' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'AddWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'EditDate'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'EditDate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'EditDate'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'EditWho'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'EditWho' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'EditWho'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'TrafficCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TrafficCop' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'TrafficCop'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', N'COLUMN',N'ArchiveCop'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ArchiveCop' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage', @level2type=N'COLUMN',@level2name=N'ArchiveCop'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'ASNImage', NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Keep ASN Image Files Folder' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ASNImage'
GO
