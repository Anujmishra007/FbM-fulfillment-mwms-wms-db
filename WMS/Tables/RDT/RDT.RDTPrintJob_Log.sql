CREATE TABLE [RDT].[RDTPrintJob_Log]
(
[JobId] [bigint] NOT NULL,
[JobName] [nvarchar] (50) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_JobName] DEFAULT (''),
[ReportID] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_ReportID] DEFAULT (''),
[JobStatus] [nvarchar] (1) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_JobStatus] DEFAULT ('0'),
[JobErrMsg] [nvarchar] (1000) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_JobErrMsg] DEFAULT (''),
[NextRun] [datetime] NULL,
[LastRun] [datetime] NULL,
[Datawindow] [nvarchar] (50) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_Datawindow] DEFAULT (''),
[NoOfParms] [int] NOT NULL CONSTRAINT [DF_RDTPrintJob_log_NoOfParms] DEFAULT ((0)),
[Parm1] [nvarchar] (30) NULL,
[Parm2] [nvarchar] (30) NULL,
[Parm3] [nvarchar] (30) NULL,
[Parm4] [nvarchar] (30) NULL,
[Parm5] [nvarchar] (30) NULL,
[Parm6] [nvarchar] (30) NULL,
[Parm7] [nvarchar] (30) NULL,
[Parm8] [nvarchar] (30) NULL,
[Parm9] [nvarchar] (30) NULL,
[Parm10] [nvarchar] (30) NULL,
[Printer] [nvarchar] (50) NULL,
[NoOfCopy] [int] NULL,
[Mobile] [int] NULL,
[TargetDB] [nvarchar] (20) NULL,
[PrintCount] [int] NOT NULL CONSTRAINT [DF_RDTPrintJob_log_PrintCount] DEFAULT ((0)),
[PrintData] [nvarchar] (max) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_PrintData] DEFAULT (''),
[JobType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_JobType] DEFAULT ('DATAWINDOW'),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_StorerKey] DEFAULT (''),
[ExportFileName] [nvarchar] (50) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_ExportFileName] DEFAULT (''),
[Parm11] [nvarchar] (30) NULL,
[Parm12] [nvarchar] (30) NULL,
[Parm13] [nvarchar] (30) NULL,
[Parm14] [nvarchar] (30) NULL,
[Parm15] [nvarchar] (30) NULL,
[Parm16] [nvarchar] (30) NULL,
[Parm17] [nvarchar] (30) NULL,
[Parm18] [nvarchar] (30) NULL,
[Parm19] [nvarchar] (30) NULL,
[Parm20] [nvarchar] (30) NULL,
[Function_ID] [int] NOT NULL CONSTRAINT [DF_RDTPrintJob_log_Function_ID] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTPrintJob_log_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDTPrintJob_log_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_RDTPrintJob_log_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nchar] (1) NULL,
[ArchiveCop] [nchar] (1) NULL,
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[ReportLineNo] [nvarchar] (5) NULL,
[PDFPreview] [char] (1) NOT NULL CONSTRAINT [DF_RDTPrintJob_Log_PDFPreview] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTPrintJob_Log] ADD CONSTRAINT [PK_RDTPrintJob_Log] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RDTPrintJob_Log_JobID] ON [RDT].[RDTPrintJob_Log] ([JobId]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'RDT.RDTPRintJob Log', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Create Date', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Create By', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Datawindow Name', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Datawindow'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edit Date', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edit By', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'File name for print to file', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'ExportFileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store Function ID', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Function_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job ID #', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'JobId'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job Name', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'JobName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job Status', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'JobStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job Type: Datawindow/QCommander', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'JobType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'LastRun', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'LastRun'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RDT Mobile Identity #', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Mobile'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NextRun', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'NextRun'
GO
EXEC sp_addextendedproperty N'MS_Description', N'No Of Print Copy', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'NoOfCopy'
GO
EXEC sp_addextendedproperty N'MS_Description', N'No Of Retrieve Parms', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'NoOfParms'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 1', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 10', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 11', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 12', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 13', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 14', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 15', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 16', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm16'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 17', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm17'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 18', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm18'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 19', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm19'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 2', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 20', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm20'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 3', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 4', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm4'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 5', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 6', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 7', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 8', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 9', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Parm9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Print Count', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'PrintCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Printing Data', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'PrintData'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Printer ID', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'Printer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Report Type/Report ID', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'ReportID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SCE Report Line #', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'ReportLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TargetDB', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'TargetDB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob_Log', 'COLUMN', N'TrafficCop'
GO
GRANT DELETE ON  [RDT].[RDTPrintJob_Log] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTPrintJob_Log] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTPrintJob_Log] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTPrintJob_Log] TO [NSQL]
GO
