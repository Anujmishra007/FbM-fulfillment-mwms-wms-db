CREATE TABLE [RDT].[rdtSpoolerLog]
(
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[JobId] [int] NULL,
[Notes] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtSpoolerLog_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSpoolerLog] ADD CONSTRAINT [PK_rdt.rdtSpoolerLog] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSpoolerLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSpoolerLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSpoolerLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSpoolerLog] TO [NSQL]
GO
