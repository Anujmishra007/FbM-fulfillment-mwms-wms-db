CREATE TABLE [RDT].[rdtPACartLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[CartID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToteID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Col] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Row] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPACartLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPACartLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPACartLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPACartLog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPACartLog] ADD CONSTRAINT [PK_rdtPACartLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_rdtPACartLog_CartID_ToteID_Position] ON [RDT].[rdtPACartLog] ([CartID], [ToteID], [Position]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPACartLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPACartLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPACartLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPACartLog] TO [NSQL]
GO
