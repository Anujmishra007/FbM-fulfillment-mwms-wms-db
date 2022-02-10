CREATE TABLE [dbo].[PhotoRepo_Account]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Account] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PhotoRepo_Account_Account] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PhotoRepo_Account_StorerKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PhotoRepo_Account] ADD CONSTRAINT [PK_PhotoRepo_Account] PRIMARY KEY CLUSTERED ([ID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PhotoRepo_Account_UNIQ] ON [dbo].[PhotoRepo_Account] ([Account], [StorerKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PhotoRepo_Account] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PhotoRepo_Account] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PhotoRepo_Account] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PhotoRepo_Account] TO [NSQL]
GO
