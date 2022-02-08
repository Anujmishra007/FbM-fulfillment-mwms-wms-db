CREATE TABLE [dbo].[pbsrpt_set_reports]
(
[rpt_set_id] [tinyint] NOT NULL,
[rpt_seq] [tinyint] NOT NULL,
[rpt_id] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pbsrpt_set_reports] ADD CONSTRAINT [rpt_set_reports_ndx] PRIMARY KEY CLUSTERED ([rpt_set_id], [rpt_seq]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbsrpt_set_reports] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbsrpt_set_reports] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbsrpt_set_reports] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbsrpt_set_reports] TO [NSQL]
GO
