CREATE TABLE [dbo].[pbcatfmt]
(
[pbf_name] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbf_frmt] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbf_type] [smallint] NOT NULL,
[pbf_cntr] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pbcatfmt_idx] ON [dbo].[pbcatfmt] ([pbf_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcatfmt] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbcatfmt] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbcatfmt] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbcatfmt] TO [NSQL]
GO
