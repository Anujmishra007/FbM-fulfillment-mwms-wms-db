CREATE TABLE [RDT].[StorerConfig]
(
[Function_ID] [int] NOT NULL CONSTRAINT [DF_StorerConfig_Function_ID] DEFAULT ((0)),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_StorerConfig_StorerKey] DEFAULT (' '),
[ConfigKey] [nvarchar] (30) NOT NULL,
[ConfigDesc] [nvarchar] (120) NULL CONSTRAINT [DF_StorerConfig_ConfigDesc] DEFAULT (' '),
[SValue] [nvarchar] (30) NULL CONSTRAINT [DF_StorerConfig_SValue] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_StorerConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_StorerConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_StorerConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_StorerConfig_EditWho] DEFAULT (suser_sname()),
[Facility] [nvarchar] (5) NOT NULL CONSTRAINT [DF_StorerConfig_Facility] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[StorerConfig] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[StorerConfig] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[StorerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[StorerConfig] TO [NSQL]
GO
