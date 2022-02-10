CREATE TABLE [dbo].[SkuImage]
(
[SkuImageKey] [bigint] NOT NULL IDENTITY(1, 1),
[Storerkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SkuImage_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SkuImage_Sku] DEFAULT (''),
[ImageFolder] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SkuImage_ImageFolder] DEFAULT (''),
[ImageFile] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SkuImage_ImageFile] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_SkuImage_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuImage_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_SkuImage_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SkuImage_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SkuImage] ADD CONSTRAINT [PK_SkuImage] PRIMARY KEY CLUSTERED ([SkuImageKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SkuImage_ImageFile] ON [dbo].[SkuImage] ([Storerkey], [Sku], [ImageFile]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SkuImage] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SkuImage] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SkuImage] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SkuImage] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Keep Sku Image Files Folder', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddDate', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddWho', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditDate', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditWho', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Image File', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'ImageFile'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Image Folder', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'ImageFolder'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'SkuImageKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TrafficCop', 'SCHEMA', N'dbo', 'TABLE', N'SkuImage', 'COLUMN', N'TrafficCop'
GO
