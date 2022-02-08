CREATE TABLE [dbo].[pbsrpt_sets]
(
[rpt_set_id] [tinyint] NOT NULL,
[name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pbsrpt_sets] ADD CONSTRAINT [rpt_set_id_ndx] PRIMARY KEY CLUSTERED ([rpt_set_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbsrpt_sets] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbsrpt_sets] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbsrpt_sets] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbsrpt_sets] TO [NSQL]
GO
