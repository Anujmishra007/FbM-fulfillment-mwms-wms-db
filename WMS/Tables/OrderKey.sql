CREATE TABLE [dbo].[OrderKey]
(
[OrderKey] [bigint] NOT NULL IDENTITY(1, 1),
[AddDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderKey] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderKey] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderKey] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderKey] TO [NSQL]
GO
