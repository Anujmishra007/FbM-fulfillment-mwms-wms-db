CREATE TABLE [dbo].[ERRLOG]
(
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_Errlog_LogDate] DEFAULT (getdate()),
[UserId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Errlog_UserId] DEFAULT (suser_sname()),
[ErrorID] [int] NOT NULL,
[SystemState] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Module] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorText] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GUIDRef] [uniqueidentifier] NOT NULL CONSTRAINT [DF_errlog_GUIDRef] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ERRLOG] ADD CONSTRAINT [PKerrlog] PRIMARY KEY CLUSTERED ([GUIDRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ERRLOG_Module] ON [dbo].[ERRLOG] ([Module], [ErrorID]) INCLUDE ([LogDate], [UserId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ERRLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ERRLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ERRLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ERRLOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Error.', 'SCHEMA', N'dbo', 'TABLE', N'ERRLOG', 'COLUMN', N'ErrorID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ERRLOG', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the User.', 'SCHEMA', N'dbo', 'TABLE', N'ERRLOG', 'COLUMN', N'UserId'
GO
