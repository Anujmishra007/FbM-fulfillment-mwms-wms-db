CREATE TABLE [RDT].[NSQLConfig]
(
[Function_ID] [int] NOT NULL CONSTRAINT [DF_NSQLConfig_Function_ID] DEFAULT ((0)),
[ConfigKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NSQLValue] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_NSQLValue] DEFAULT (' '),
[NSQLDefault] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_NSQLDefault] DEFAULT (' '),
[NSQLDescrip] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_NSQLConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NSQLConfig_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [RDT].[NSQLConfig] ADD CONSTRAINT [PK_NSQLConfig] PRIMARY KEY CLUSTERED ([Function_ID], [ConfigKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[NSQLConfig] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[NSQLConfig] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[NSQLConfig] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[NSQLConfig] TO [NSQL]
GO
