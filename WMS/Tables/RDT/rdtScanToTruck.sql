CREATE TABLE [RDT].[rdtScanToTruck]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtScanToTruck_CartonType] DEFAULT (''),
[RefNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtScanToTruck_RefNo] DEFAULT (''),
[URNNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtScanToTruck_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtScanToTruck_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtScanToTruck_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtScanToTruck_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtScanToTruck_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtScanToTruck_Door] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtScanToTruck_OrderKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtScanToTruck] ADD CONSTRAINT [PKrdtScanToTruck] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RDTScanToTruck_Mbol_Load_URNNo] ON [RDT].[rdtScanToTruck] ([MBOLKey], [LoadKey], [URNNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtScanToTruck_URNNo] ON [RDT].[rdtScanToTruck] ([URNNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [RDT].[rdtScanToTruck] TO [JReportRole]
GO
GRANT DELETE ON  [RDT].[rdtScanToTruck] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtScanToTruck] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtScanToTruck] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtScanToTruck] TO [NSQL]
GO
