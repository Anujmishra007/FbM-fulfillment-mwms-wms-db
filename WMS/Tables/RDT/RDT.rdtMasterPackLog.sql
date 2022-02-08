CREATE TABLE [RDT].[rdtMasterPackLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMasterPackLog_StorerKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMasterPackLog_Facility] DEFAULT (''),
[ToteNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMasterPackLog_ToteNo] DEFAULT (''),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMasterPackLog_DropID] DEFAULT (''),
[Status] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMasterPackLog_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtMasterPackLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMasterPackLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtMasterPackLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtMasterPackLog_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtMasterPackLog] ADD CONSTRAINT [PKMasterPackLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtMasterPackLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtMasterPackLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtMasterPackLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtMasterPackLog] TO [NSQL]
GO
