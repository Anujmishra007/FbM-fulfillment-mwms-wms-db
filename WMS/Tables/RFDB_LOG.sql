CREATE TABLE [dbo].[RFDB_LOG]
(
[adddate] [datetime] NOT NULL CONSTRAINT [DF_RFDB_LOG_adddate] DEFAULT (getdate()),
[user_id] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFDB_LOG_user_id] DEFAULT (suser_sname()),
[message] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RFDB_LOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RFDB_LOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RFDB_LOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RFDB_LOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RFDB_LOG', 'COLUMN', N'adddate'
GO
