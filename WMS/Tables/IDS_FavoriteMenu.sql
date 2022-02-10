CREATE TABLE [dbo].[IDS_FavoriteMenu]
(
[UserId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MenuItemObjName] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MenuItemText] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDS_FavoriteMenu] ADD CONSTRAINT [PK_IDS_FavoriteMenu] PRIMARY KEY CLUSTERED ([UserId], [MenuItemObjName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_FavoriteMenu] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_FavoriteMenu] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_FavoriteMenu] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_FavoriteMenu] TO [NSQL]
GO
