CREATE TABLE [dbo].[IDS_MenuItem]
(
[ObjCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_MenuItem_ObjCode] DEFAULT (''),
[ObjDesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjPicture] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDS_MenuItem] ADD CONSTRAINT [PK_LF_MenuItem] PRIMARY KEY CLUSTERED ([ObjCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_MenuItem] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_MenuItem] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_MenuItem] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_MenuItem] TO [NSQL]
GO
