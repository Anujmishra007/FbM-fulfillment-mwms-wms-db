CREATE TABLE [dbo].[UCCCounter]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UCCCounter_StorerKey] DEFAULT (''),
[KeyCount] [int] NOT NULL CONSTRAINT [DF_UCCCounter_KeyCount] DEFAULT ((0)),
[STARTUCC] [nvarchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCCCounter_STARTUCC] DEFAULT (''),
[ENDUCC] [nvarchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCCCounter_ENDUCC] DEFAULT (''),
[STARTUSEDATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UCCCounter] ADD CONSTRAINT [PK_UCCCounter] PRIMARY KEY CLUSTERED ([StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UCCCounter] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UCCCounter] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UCCCounter] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UCCCounter] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UCCCounter', 'COLUMN', N'StorerKey'
GO
