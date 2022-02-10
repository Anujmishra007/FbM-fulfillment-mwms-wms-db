CREATE TABLE [dbo].[RunNo]
(
[TodayDate] [datetime] NOT NULL,
[RunNo] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RunNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RunNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RunNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RunNo] TO [NSQL]
GO
