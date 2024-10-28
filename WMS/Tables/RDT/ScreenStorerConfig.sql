CREATE TABLE [RDT].[ScreenStorerConfig]
(
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_ScreenStorerConfig_StorerKey] DEFAULT (' '),
[Scn] [int] NOT NULL CONSTRAINT [DF_ScreenStorerConfig_Screen_ID] DEFAULT ((0)),
[line] [int] NOT NULL CONSTRAINT [DF_ScreenStorerConfig_line] DEFAULT (0),
[Function_ID] [int] NOT NULL CONSTRAINT [DF_ScreenStorerConfig_Function_ID] DEFAULT ((0)),
[Attribute] [nvarchar] (30) NULL CONSTRAINT [DF_ScreenStorerConfig_Attribute] DEFAULT (' '),
[SValue] [nvarchar] (max) NULL CONSTRAINT [DF_ScreenStorerConfig_SValue] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_ScreenStorerConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_ScreenStorerConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_ScreenStorerConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_ScreenStorerConfig_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[ScreenStorerConfig] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[ScreenStorerConfig] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[ScreenStorerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[ScreenStorerConfig] TO [NSQL]
GO
