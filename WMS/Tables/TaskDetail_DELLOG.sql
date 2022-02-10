CREATE TABLE [dbo].[TaskDetail_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_DELLOG_TaskDetailKey] DEFAULT (' '),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaskDetail_DELLOG] ADD CONSTRAINT [PK__TaskDetail_DELLO__613C58EC] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TaskDetail_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskDetail_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskDetail_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskDetail_DELLOG] TO [NSQL]
GO
