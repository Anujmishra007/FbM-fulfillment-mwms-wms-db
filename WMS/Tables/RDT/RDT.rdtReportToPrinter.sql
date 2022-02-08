CREATE TABLE [RDT].[rdtReportToPrinter]
(
[Function_ID] [int] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrinterGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrinterID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtReportToPrinter_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReportToPrinter_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtReportToPrinter_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReportToPrinter_EditWho] DEFAULT (suser_sname()),
[ReportLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReportToPrinter_ReportLineNo] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtReportToPrinter] ADD CONSTRAINT [PK_rdtReportToPRinter] PRIMARY KEY CLUSTERED ([Function_ID], [StorerKey], [ReportType], [PrinterGroup], [ReportLineNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtReportToPrinter] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtReportToPrinter] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtReportToPrinter] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtReportToPrinter] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Print specific report to specific print in a printer group', 'SCHEMA', N'RDT', 'TABLE', N'rdtReportToPrinter', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'WM WMReportDetail Report line #', 'SCHEMA', N'RDT', 'TABLE', N'rdtReportToPrinter', 'COLUMN', N'ReportLineNo'
GO
