CREATE TABLE [RDT].[rdtTraceSummary]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TransDate] [datetime] NOT NULL,
[Hour24] [tinyint] NOT NULL,
[Usr] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InFunc] [int] NOT NULL,
[InStep] [int] NOT NULL,
[OutStep] [int] NOT NULL,
[AvgTime] [int] NOT NULL,
[TotalTrans] [int] NOT NULL,
[MinTime] [int] NOT NULL,
[MaxTime] [int] NOT NULL,
[MS0_1000] [int] NOT NULL,
[MS1000_2000] [int] NOT NULL,
[MS2000_5000] [int] NOT NULL CONSTRAINT [DF_rdtTraceSummary_MS2000_5000] DEFAULT ((0)),
[MS5000_UP] [int] NOT NULL CONSTRAINT [DF_rdtTraceSummary_MS5000_UP] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtTraceSummary] ADD CONSTRAINT [PKRDTTraceSummary] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtTraceSummary] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtTraceSummary] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtTraceSummary] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtTraceSummary] TO [NSQL]
GO
