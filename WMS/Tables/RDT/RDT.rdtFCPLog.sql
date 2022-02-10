CREATE TABLE [RDT].[rdtFCPLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[DropID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtFCPLog] ADD CONSTRAINT [PK_rdtFCPLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtFCPLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtFCPLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtFCPLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtFCPLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Temporary table use by RDT TM case pick (FN1812)', 'SCHEMA', N'RDT', 'TABLE', N'rdtFCPLog', NULL, NULL
GO
