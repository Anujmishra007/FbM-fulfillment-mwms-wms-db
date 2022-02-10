CREATE TABLE [dbo].[nCounterTrigantic]
(
[keyname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[keycount] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nCounterTrigantic] ADD CONSTRAINT [PKnCounterTrigantic] PRIMARY KEY CLUSTERED ([keyname]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nCounterTrigantic] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[nCounterTrigantic] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[nCounterTrigantic] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[nCounterTrigantic] TO [NSQL]
GO
