CREATE TABLE [dbo].[JReportFolder]
(
[SecondLvl] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_SecondLvl] DEFAULT ('WMS'),
[FolderPath] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Remark] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_Remark] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_JReportFolder_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_JReportFolder_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_JReportFolder_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[JReportFolder] ADD CONSTRAINT [PKJReportFolder] PRIMARY KEY CLUSTERED ([SecondLvl], [StorerKey]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[JReportFolder] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[JReportFolder] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[JReportFolder] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[JReportFolder] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[JReportFolder] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport Folder - StorerKey Mapping in JReport Server Console Public Reports', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Folder path of third level folder or including subfolders if applicable', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'FolderPath'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Internal remark for reference', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'Remark'
GO
EXEC sp_addextendedproperty N'MS_Description', N'JReport 2nd level folder name (usually application name, i.e. WMS, OMS, TMS, LMS, TPB, etc.', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'SecondLvl'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique customer key from STORER table Type=''1''', 'SCHEMA', N'dbo', 'TABLE', N'JReportFolder', 'COLUMN', N'StorerKey'
GO
