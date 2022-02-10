CREATE TABLE [dbo].[GS1BatchNo]
(
[BatchNo] [int] NOT NULL IDENTITY(1, 1),
[AddDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GS1BatchNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GS1BatchNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GS1BatchNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GS1BatchNo] TO [NSQL]
GO
