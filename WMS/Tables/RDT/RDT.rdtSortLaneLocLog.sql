CREATE TABLE [RDT].[rdtSortLaneLocLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Lane] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_Lane] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_LOC] DEFAULT (''),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_ID] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_OrderKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_ConsigneeKey] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortLaneLocLog_EditDate] DEFAULT (getdate()),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSortLaneLocLog_LoadKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSortLaneLocLog] ADD CONSTRAINT [PK_rdtSortLaneLocLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_rdtSortLaneLocLog_Lane_LOC] ON [RDT].[rdtSortLaneLocLog] ([Lane], [LOC]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSortLaneLocLog] TO [NSQL]
GO
