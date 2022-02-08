CREATE TABLE [dbo].[Indexes]
(
[vcTableName] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nmPriority] [tinyint] NOT NULL,
[dtLastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Indexes] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Indexes] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Indexes] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Indexes] TO [NSQL]
GO
