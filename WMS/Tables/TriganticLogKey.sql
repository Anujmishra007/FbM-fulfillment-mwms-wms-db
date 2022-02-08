CREATE TABLE [dbo].[TriganticLogKey]
(
[TriganticKey] [bigint] NOT NULL IDENTITY(1, 1),
[AddDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TriganticLogKey] ADD CONSTRAINT [PK_TRIGANTICKEY] PRIMARY KEY CLUSTERED ([TriganticKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TriganticLogKey] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TriganticLogKey] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TriganticLogKey] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TriganticLogKey] TO [NSQL]
GO
