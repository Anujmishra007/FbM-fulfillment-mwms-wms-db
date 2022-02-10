CREATE TABLE [dbo].[pbsrpt_category]
(
[category_id] [int] NOT NULL,
[category] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pbsrpt_category] ADD CONSTRAINT [category_id_ndx] PRIMARY KEY CLUSTERED ([category_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbsrpt_category] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbsrpt_category] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbsrpt_category] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbsrpt_category] TO [NSQL]
GO
