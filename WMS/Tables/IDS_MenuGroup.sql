CREATE TABLE [dbo].[IDS_MenuGroup]
(
[GroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_MenuGroup_GroupKey] DEFAULT (''),
[GroupName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_MenuGroup_FromGroupKey] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IDS_MenuGroup] ADD CONSTRAINT [PK_IDS_MenuGroup] PRIMARY KEY CLUSTERED ([GroupKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_MenuGroup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_MenuGroup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_MenuGroup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_MenuGroup] TO [NSQL]
GO
