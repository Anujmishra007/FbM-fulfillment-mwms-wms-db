CREATE TABLE [dbo].[nCounterNSC]
(
[keyname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[keycount] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nCounterNSC] ADD CONSTRAINT [PK_nCounterNSC] PRIMARY KEY CLUSTERED ([keyname]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nCounterNSC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[nCounterNSC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[nCounterNSC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[nCounterNSC] TO [NSQL]
GO
