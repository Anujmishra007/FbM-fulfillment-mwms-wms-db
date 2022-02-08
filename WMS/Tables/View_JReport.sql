CREATE TABLE [dbo].[View_JReport]
(
[JReport_ID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JReport_Description] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_View_JReport_JReport_Description] DEFAULT (''),
[JReport_FileName] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JReport_Catalog] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_View_JReport_JReport_Catalog] DEFAULT (''),
[JReport_Category] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_View_JReport_JReport_Category] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_View_JReport_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_View_JReport_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_View_JReport_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_View_JReport_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[View_JReport] ADD CONSTRAINT [JReport_ID_ndx] PRIMARY KEY CLUSTERED ([JReport_ID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[View_JReport] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[View_JReport] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[View_JReport] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[View_JReport] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport Catalog', 'SCHEMA', N'dbo', 'TABLE', N'View_JReport', 'COLUMN', N'JReport_Catalog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport Category', 'SCHEMA', N'dbo', 'TABLE', N'View_JReport', 'COLUMN', N'JReport_Category'
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport Description', 'SCHEMA', N'dbo', 'TABLE', N'View_JReport', 'COLUMN', N'JReport_Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport FileName', 'SCHEMA', N'dbo', 'TABLE', N'View_JReport', 'COLUMN', N'JReport_FileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport ID', 'SCHEMA', N'dbo', 'TABLE', N'View_JReport', 'COLUMN', N'JReport_ID'
GO
