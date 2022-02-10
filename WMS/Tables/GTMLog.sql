CREATE TABLE [dbo].[GTMLog]
(
[Logids] [bigint] NOT NULL IDENTITY(1, 1),
[PalletId] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MsgType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromLoc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDate] [datetime] NULL,
[EditBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrMsg] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrCode] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GTMLog] ADD CONSTRAINT [PK_GTM_CallLog] PRIMARY KEY CLUSTERED ([Logids]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GTMLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GTMLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GTMLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GTMLog] TO [NSQL]
GO
