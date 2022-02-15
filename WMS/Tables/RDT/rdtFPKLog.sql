CREATE TABLE [RDT].[rdtFPKLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtFPKLog] ADD CONSTRAINT [PK_rdtFPKLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtFPKLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtFPKLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtFPKLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtFPKLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N' Temporary table to keep UCC of a pallet pick', 'SCHEMA', N'RDT', 'TABLE', N'rdtFPKLog', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Temporary table to keep UCC of a pallet pick', 'SCHEMA', N'RDT', 'TABLE', N'rdtFPKLog', 'COLUMN', N'DropID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Temporary table to keep UCC of a pallet pick', 'SCHEMA', N'RDT', 'TABLE', N'rdtFPKLog', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Temporary table to keep UCC of a pallet pick', 'SCHEMA', N'RDT', 'TABLE', N'rdtFPKLog', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Temporary table to keep UCC of a pallet pick', 'SCHEMA', N'RDT', 'TABLE', N'rdtFPKLog', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Temporary table to keep UCC of a pallet pick', 'SCHEMA', N'RDT', 'TABLE', N'rdtFPKLog', 'COLUMN', N'UCCNo'
GO
