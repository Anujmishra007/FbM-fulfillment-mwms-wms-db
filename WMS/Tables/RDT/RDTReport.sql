CREATE TABLE [RDT].[RDTReport]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataWindow] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TargetDB] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTReport_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTReport_AddWho] DEFAULT (suser_sname()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTReport_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_RDTReport_EditDate] DEFAULT (getdate()),
[parm1_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm2_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm3_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm4_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm5_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm6_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm7_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm8_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm9_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm10_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrintTemplate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTReport_PrintTemplate] DEFAULT (''),
[PrintTemplateSP] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTReport_PrintTemplateSP] DEFAULT (''),
[Function_ID] [int] NOT NULL CONSTRAINT [DF_RDTReport_Function_ID] DEFAULT ('0'),
[ProcessType] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReport_ProcessType] DEFAULT (''),
[ProcessSP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReport_ProcessSP] DEFAULT (''),
[PaperType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReport_PaperType] DEFAULT (''),
[NoOfCopy] [int] NOT NULL CONSTRAINT [DF_rdtReport_NoOfCopy] DEFAULT ((1)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTReport_Facility] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTReport] ADD CONSTRAINT [PK_RDTReport] PRIMARY KEY CLUSTERED ([StorerKey], [ReportType], [Function_ID], [Facility]) ON [PRIMARY]
GO
GRANT SELECT ON  [RDT].[RDTReport] TO [JReportRole]
GO
GRANT DELETE ON  [RDT].[RDTReport] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTReport] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTReport] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTReport] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Print out no of copy same label / report. Default=1', 'SCHEMA', N'RDT', 'TABLE', N'RDTReport', 'COLUMN', N'NoOfCopy'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PaperType=LABEL or blank (report)', 'SCHEMA', N'RDT', 'TABLE', N'RDTReport', 'COLUMN', N'PaperType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mainly for customize report parameter mapping', 'SCHEMA', N'RDT', 'TABLE', N'RDTReport', 'COLUMN', N'ProcessSP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Different printing method (QCOMMANDER, DATAWINDOW, BARTENDER)', 'SCHEMA', N'RDT', 'TABLE', N'RDTReport', 'COLUMN', N'ProcessType'
GO
