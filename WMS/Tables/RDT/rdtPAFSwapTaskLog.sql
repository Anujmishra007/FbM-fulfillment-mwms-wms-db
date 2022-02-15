CREATE TABLE [RDT].[rdtPAFSwapTaskLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[FromTaskKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewTaskKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewFromLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewFromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPAFSwapTaskLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPAFSwapTaskLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPAFSwapTaskLog] ADD CONSTRAINT [PK_rdtPAFSwapTaskLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPAFSwapTaskLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPAFSwapTaskLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPAFSwapTaskLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPAFSwapTaskLog] TO [NSQL]
GO
