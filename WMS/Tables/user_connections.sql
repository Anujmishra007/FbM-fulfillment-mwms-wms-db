CREATE TABLE [dbo].[user_connections]
(
[indkey] [uniqueidentifier] NOT NULL CONSTRAINT [DF_user_connections_indkey] DEFAULT (newid()),
[login_name] [nchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[login_date] [datetime] NULL,
[Application] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_user_connections_Application] DEFAULT (' '),
[Hostname] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_user_connections_Hostname] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_connections] ADD CONSTRAINT [PK_user_connections] PRIMARY KEY CLUSTERED ([indkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[user_connections] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[user_connections] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[user_connections] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[user_connections] TO [NSQL]
GO
