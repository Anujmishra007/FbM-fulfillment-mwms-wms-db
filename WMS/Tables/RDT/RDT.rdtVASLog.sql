CREATE TABLE [RDT].[rdtVASLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REF1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY] [int] NOT NULL,
[StartDate] [datetime] NOT NULL CONSTRAINT [DF_rdtVASLog_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtVASLog_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtVASLog_AddDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtVASLog] ADD CONSTRAINT [PKrdtVASLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtVASLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtVASLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtVASLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtVASLog] TO [NSQL]
GO
