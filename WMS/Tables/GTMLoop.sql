CREATE TABLE [dbo].[GTMLoop]
(
[PalletId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MsgId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Workstation] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EditWho] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GTMLoop] ADD CONSTRAINT [PK_GTMLoop_1] PRIMARY KEY CLUSTERED ([PalletId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_GTMloop_Workstation] ON [dbo].[GTMLoop] ([Workstation], [TaskDetailKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GTMLoop] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GTMLoop] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GTMLoop] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GTMLoop] TO [NSQL]
GO
