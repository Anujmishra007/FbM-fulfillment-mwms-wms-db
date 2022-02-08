CREATE TABLE [dbo].[TPPRINTJOB]
(
[JobNo] [bigint] NOT NULL IDENTITY(1, 1),
[Module] [nvarchar] (20) NULL,
[ReportType] [nvarchar] (10) NULL,
[Storerkey] [nvarchar] (15) NULL,
[PrinterID] [nvarchar] (10) NULL,
[Printer] [nvarchar] (128) NULL,
[Shipperkey] [nvarchar] (15) NULL,
[Status] [nvarchar] (10) NULL CONSTRAINT [DF__TPPRINTJO__Statu__62A47D21] DEFAULT ('0'),
[Message] [nvarchar] (2000) NULL,
[KeyFieldName] [nvarchar] (30) NULL,
[Parm01] [nvarchar] (30) NULL,
[Parm02] [nvarchar] (30) NULL,
[Parm03] [nvarchar] (30) NULL,
[Parm04] [nvarchar] (30) NULL,
[Parm05] [nvarchar] (30) NULL,
[Parm06] [nvarchar] (30) NULL,
[Parm07] [nvarchar] (30) NULL,
[Parm08] [nvarchar] (30) NULL,
[Parm09] [nvarchar] (500) NULL,
[Parm10] [nvarchar] (4000) NULL,
[UDF01] [nvarchar] (200) NULL,
[UDF02] [nvarchar] (200) NULL,
[UDF03] [nvarchar] (200) NULL,
[UDF04] [nvarchar] (500) NULL,
[UDF05] [nvarchar] (4000) NULL,
[SourceType] [nvarchar] (30) NULL,
[Platform] [nvarchar] (30) NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF__TPPRINTJO__AddDa__6398A15A] DEFAULT (getdate()),
[AddWho] [nvarchar] (18) NULL CONSTRAINT [DF__TPPRINTJO__AddWh__648CC593] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF__TPPRINTJO__EditD__6580E9CC] DEFAULT (getdate()),
[EditWho] [nvarchar] (18) NULL CONSTRAINT [DF__TPPRINTJO__EditW__66750E05] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPPRINTJOB] ADD CONSTRAINT [PK_TPPRINTJOB] PRIMARY KEY CLUSTERED ([JobNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPPRINTJOB] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TPPRINTJOB] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TPPRINTJOB] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TPPRINTJOB] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Trade Partner Printing Job', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Added By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User Date', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edited By User ID', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Print Job Number', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'JobNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Key field Name for Parm01', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'KeyFieldName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Printing Message', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Message'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Application Module', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Module'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 01', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 02', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 03', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 04', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 05', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 06', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 07', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 08', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 09', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Parameter 10', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Parm10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Printing Platform', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Platform'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Report Type', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'ReportType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipper', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Shipperkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Source Type', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 01', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 02', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 03', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 04', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 05', 'SCHEMA', N'dbo', 'TABLE', N'TPPRINTJOB', 'COLUMN', N'UDF05'
GO
