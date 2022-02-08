CREATE TABLE [dbo].[IDS_MenuLink]
(
[Parent_ObjCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_MenuLink_Parent_ObjCode] DEFAULT (''),
[Child_ObjCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_MenuLink_Child_ObjCode] DEFAULT (''),
[Sequence] [int] NULL,
[Groupkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_MenuLink_Groupkey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDS_MenuLink] ADD CONSTRAINT [PK_LF_MenuLink] PRIMARY KEY CLUSTERED ([Parent_ObjCode], [Child_ObjCode], [Groupkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_MenuLink] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_MenuLink] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_MenuLink] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_MenuLink] TO [NSQL]
GO
