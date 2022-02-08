CREATE TABLE [dbo].[SerialNoKey]
(
[SerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[AddDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SerialNoKey] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SerialNoKey] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SerialNoKey] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SerialNoKey] TO [NSQL]
GO
