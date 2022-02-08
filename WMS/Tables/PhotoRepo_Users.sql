CREATE TABLE [dbo].[PhotoRepo_Users]
(
[UserID] [bigint] NOT NULL IDENTITY(1, 1),
[UserName] [nvarchar] (128) NOT NULL CONSTRAINT [DF_PhotoRepo_Users_UserName] DEFAULT (''),
[Password] [nvarchar] (100) NOT NULL CONSTRAINT [DF_PhotoRepo_Users_Password] DEFAULT (''),
[IsAdmin] [bit] NULL CONSTRAINT [DF_PhotoRepo_Users_IsAdmin] DEFAULT ((0)),
[Account] [nvarchar] (15) NOT NULL CONSTRAINT [DF_PhotoRepo_Users_Account] DEFAULT (''),
[Modules] [nvarchar] (500) NULL CONSTRAINT [DF_PhotoRepo_Users_Modules] DEFAULT (''),
[IsSuperUser] [bit] NULL CONSTRAINT [DF_PhotoRepo_Users_IsSuperUser] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PhotoRepo_Users] ADD CONSTRAINT [PK_PhotoRepo_Users] PRIMARY KEY CLUSTERED ([UserID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PhotoRepo_Users_UNIQ] ON [dbo].[PhotoRepo_Users] ([UserName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PhotoRepo_Users] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PhotoRepo_Users] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PhotoRepo_Users] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PhotoRepo_Users] TO [NSQL]
GO
