CREATE TABLE [dbo].[ModuleReports]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PB_WindowName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rpt_ID] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MenuTitle] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ModuleReports_MenuTitle] DEFAULT (''),
[MenuSeqNo] [int] NOT NULL CONSTRAINT [DF_ModuleReports_MenuSeqNo] DEFAULT ((99)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ModuleReports_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ModuleReports_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ModuleReports_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ModuleReports_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModuleReports] ADD CONSTRAINT [PK_ModuleReports] PRIMARY KEY CLUSTERED ([RowID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ModuleReports] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ModuleReports] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ModuleReports] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ModuleReports] TO [NSQL]
GO
