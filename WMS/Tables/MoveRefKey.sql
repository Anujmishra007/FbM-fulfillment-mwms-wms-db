CREATE TABLE [dbo].[MoveRefKey]
(
[MoveRefKey] [bigint] NOT NULL IDENTITY(1, 1),
[AddDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MoveRefKey] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MoveRefKey] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MoveRefKey] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MoveRefKey] TO [NSQL]
GO
