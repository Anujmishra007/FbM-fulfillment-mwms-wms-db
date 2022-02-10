CREATE TABLE [dbo].[SQLObjectRights]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[DBRole] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SQLObjectRights_DBRole] DEFAULT (''),
[Schema] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SQLObjectRights_Schema] DEFAULT ('dbo'),
[OjbName] [sys].[sysname] NOT NULL,
[RightFlag] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SQLObjectRights_RightFlag] DEFAULT ('1000')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SQLObjectRights] ADD CONSTRAINT [PK__SQLObjec__78C977976FFEEEDA] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SQLObjectRights] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SQLObjectRights] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SQLObjectRights] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SQLObjectRights] TO [NSQL]
GO
