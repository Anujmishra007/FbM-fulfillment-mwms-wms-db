CREATE TABLE [dbo].[pbsrpt_reports]
(
[rpt_id] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_datawindow] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_library] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_title] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_purpose] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_descr] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_header] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_active] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_type] [int] NULL,
[rpt_where] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_filter] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_sort] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enable_filter] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enable_sort] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[autoretrieve] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category_id] [int] NULL,
[show_criteria] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[query_mode] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shared_rpt_id] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HeaderFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_pbsrpt_reports_HeaderFlag] DEFAULT ('N'),
[FooterFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_pbsrpt_reports_FooterFlag] DEFAULT ('N'),
[SCEPrintType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PBSRPT_REPORTS_SCEPrintType] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pbsrpt_reports] ADD CONSTRAINT [rpt_id_ndx] PRIMARY KEY CLUSTERED ([rpt_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbsrpt_reports] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbsrpt_reports] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbsrpt_reports] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbsrpt_reports] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Title', 'SCHEMA', N'dbo', 'TABLE', N'pbsrpt_reports', 'COLUMN', N'rpt_title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SCE Send to Print Process Type', 'SCHEMA', N'dbo', 'TABLE', N'pbsrpt_reports', 'COLUMN', N'SCEPrintType'
GO
