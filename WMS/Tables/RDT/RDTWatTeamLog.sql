CREATE TABLE [RDT].[RDTWatTeamLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TeamUser] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberUser] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtWATTeamLog_StorerKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtWATTeamLog_Facility] DEFAULT (''),
[Editdate] [datetime] NOT NULL CONSTRAINT [DF_rdtWATTeamLog_EditDate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtWATTeamLog_EditWho] DEFAULT (suser_sname()),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtWatTeamLog_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtWatTeamLog_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtWatTeamLog_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtWatTeamLog_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtWatTeamLog_UDF05] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTWatTeamLog] ADD CONSTRAINT [PKrdtWATTeamLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTWatTeamLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTWatTeamLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTWatTeamLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTWatTeamLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'RDT', 'TABLE', N'RDTWatTeamLog', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer', 'SCHEMA', N'RDT', 'TABLE', N'RDTWatTeamLog', 'COLUMN', N'Storerkey'
GO
