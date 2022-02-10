CREATE TABLE [dbo].[StorerConfig]
(
[StorerKey] [nvarchar] (15) NOT NULL,
[Facility] [nvarchar] (5) NOT NULL CONSTRAINT [DF_StorerConfig_Facility] DEFAULT (' '),
[ConfigKey] [nvarchar] (30) NOT NULL,
[ConfigDesc] [nvarchar] (120) NULL CONSTRAINT [DF_StorerConfig_ConfigDesc] DEFAULT (' '),
[SValue] [nvarchar] (30) NULL CONSTRAINT [DF_StorerConfig_SValue] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_StorerConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_StorerConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_StorerConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_StorerConfig_EditWho] DEFAULT (suser_sname()),
[OPTION1] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION1] DEFAULT (''),
[OPTION2] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION2] DEFAULT (''),
[OPTION3] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION3] DEFAULT (''),
[OPTION4] [nvarchar] (50) NULL CONSTRAINT [DF_StorerConfig_OPTION4] DEFAULT (''),
[OPTION5] [nvarchar] (4000) NULL CONSTRAINT [DF_StorerConfig_OPTION5] DEFAULT ('')
) ON [PRIMARY]
GO

GRANT SELECT ON  [dbo].[StorerConfig] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[StorerConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StorerConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StorerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StorerConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'ConfigDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Configuration.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'ConfigKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 1', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 2', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 3', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 4', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional Configuration Option 5', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'OPTION5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'StorerConfig', 'COLUMN', N'StorerKey'
GO
