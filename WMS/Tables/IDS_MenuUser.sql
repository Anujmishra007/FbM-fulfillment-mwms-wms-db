CREATE TABLE [dbo].[IDS_MenuUser]
(
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_MenuUser_UserID] DEFAULT (''),
[Groupkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserGroup] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserRole] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDS_MenuUser] ADD CONSTRAINT [PK_IDS_MenuUser] PRIMARY KEY CLUSTERED ([UserID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_MenuUser] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_MenuUser] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_MenuUser] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_MenuUser] TO [NSQL]
GO
