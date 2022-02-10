CREATE TABLE [RDT].[rdtTMLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_UserName] DEFAULT (''),
[TaskUserName] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_TaskUserName] DEFAULT (''),
[MobileNo] [int] NULL CONSTRAINT [DF_rdtTMLog_MobileNo] DEFAULT ((0)),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_AreaKey] DEFAULT (''),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_TaskType] DEFAULT (''),
[PrevTaskdetailkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_PrevTaskdetailkey] DEFAULT (''),
[Taskdetailkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_Taskdetailkey] DEFAULT (''),
[PrevStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_PrevStatus] DEFAULT (''),
[CurrStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtTMLog_CurrStatus] DEFAULT (''),
[Func] [int] NULL CONSTRAINT [DF_rdtTMLog_Func] DEFAULT ((0)),
[Scn] [int] NULL CONSTRAINT [DF_rdtTMLog_Scn] DEFAULT ((0)),
[Step] [int] NULL CONSTRAINT [DF_rdtTMLog_Step] DEFAULT ((0)),
[DateTime] [datetime] NULL CONSTRAINT [DF_rdtTMLog_DateTime] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtTMLog] ADD CONSTRAINT [PK_rdtTMLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtTMLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtTMLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtTMLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtTMLog] TO [NSQL]
GO
