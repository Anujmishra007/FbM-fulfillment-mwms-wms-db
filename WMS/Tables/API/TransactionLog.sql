CREATE TABLE [API].[TransactionLog]
(
[RowRefNo] [bigint] NOT NULL IDENTITY(1, 1),
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TransactionLog_UserName] DEFAULT (''),
[Module] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TransactionLog_Module] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_TransactionLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [API].[TransactionLog] ADD CONSTRAINT [PK_API.TransactionLog] PRIMARY KEY CLUSTERED ([RowRefNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [API].[TransactionLog] TO [NSQL]
GO
GRANT INSERT ON  [API].[TransactionLog] TO [NSQL]
GO
GRANT SELECT ON  [API].[TransactionLog] TO [NSQL]
GO
GRANT UPDATE ON  [API].[TransactionLog] TO [NSQL]
GO
