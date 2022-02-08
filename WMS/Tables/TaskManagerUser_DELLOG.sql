CREATE TABLE [dbo].[TaskManagerUser_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[UserKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_DELLOG_UserKey] DEFAULT (' '),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerUser_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerUser_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaskManagerUser_DELLOG] ADD CONSTRAINT [PK__TaskManagerUser___4AB81AF0] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TaskManagerUser_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskManagerUser_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskManagerUser_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskManagerUser_DELLOG] TO [NSQL]
GO
