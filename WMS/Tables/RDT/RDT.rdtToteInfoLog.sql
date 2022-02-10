CREATE TABLE [RDT].[rdtToteInfoLog]
(
[PIKNo] [int] NOT NULL,
[Store] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtToteInfoLog_Store] DEFAULT (''),
[ToteNo] [int] NOT NULL CONSTRAINT [DF_rdtToteInfoLog_ToteNo] DEFAULT ((0)),
[StoreName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToteDate] [datetime] NULL,
[Who] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtToteInfoLog_Status] DEFAULT ('0'),
[Trailer] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ManifestNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MarshalDate] [datetime] NULL,
[MarshalWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtToteInfoLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtToteInfoLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_rdtToteInfoLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtToteInfoLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtToteInfoLog] ADD CONSTRAINT [PKrdtToteInfoLog] PRIMARY KEY CLUSTERED ([PIKNo], [Store], [ToteNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtToteInfoLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtToteInfoLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtToteInfoLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtToteInfoLog] TO [NSQL]
GO
