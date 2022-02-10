CREATE TABLE [dbo].[TaskManagerReason_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[TaskManagerReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_DELLOG_TaskManagerReasonKey] DEFAULT (' '),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskManagerReason_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskManagerReason_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaskManagerReason_DELLOG] ADD CONSTRAINT [PK__TaskManagerReaso__51BA1E3A] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TaskManagerReason_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskManagerReason_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskManagerReason_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskManagerReason_DELLOG] TO [NSQL]
GO
