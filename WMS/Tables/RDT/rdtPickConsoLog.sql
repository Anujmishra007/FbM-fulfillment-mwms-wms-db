CREATE TABLE [RDT].[rdtPickConsoLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelPrinted] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPickConsoLog_LabelPrinted] DEFAULT ('0'),
[ReportPrinted] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPickConsoLog_ReportPrinted] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPickConsoLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPickConsoLog_AddDate] DEFAULT (getdate()),
[Mobile] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPickConsoLog] ADD CONSTRAINT [PKPickConsoLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtPickConsoLog_04] ON [RDT].[rdtPickConsoLog] ([LOC], [Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtPickConsoLog_03] ON [RDT].[rdtPickConsoLog] ([Orderkey], [LOC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtPickConsoLog_01] ON [RDT].[rdtPickConsoLog] ([Orderkey], [PickZone]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtPickConsoLog_02] ON [RDT].[rdtPickConsoLog] ([Orderkey], [SKU]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPickConsoLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPickConsoLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPickConsoLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPickConsoLog] TO [NSQL]
GO
