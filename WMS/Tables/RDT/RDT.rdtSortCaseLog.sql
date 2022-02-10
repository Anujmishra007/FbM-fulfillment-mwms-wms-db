CREATE TABLE [RDT].[rdtSortCaseLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortCaseLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSortCaseLog] ADD CONSTRAINT [PK_rdtSortCaseLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSortCaseLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSortCaseLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSortCaseLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSortCaseLog] TO [NSQL]
GO
