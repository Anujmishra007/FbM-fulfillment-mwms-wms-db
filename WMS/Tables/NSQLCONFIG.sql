CREATE TABLE [dbo].[NSQLCONFIG]
(
[ConfigKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NSQLValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_NSQLValue] DEFAULT (' '),
[NSQLDefault] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_NSQLDEFAULT] DEFAULT (' '),
[NSQLDescrip] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLCONFIG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLCONFIG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLCONFIG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[NSQLCONFIG] ADD CONSTRAINT [PKNSQLConfig] PRIMARY KEY CLUSTERED ([ConfigKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[NSQLCONFIG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'ConfigKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'NSQLCONFIG', 'COLUMN', N'TrafficCop'
GO
