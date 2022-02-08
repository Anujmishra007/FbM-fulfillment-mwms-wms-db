CREATE TABLE [dbo].[StorerConfig_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConfigKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerConfig_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StorerConfig_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StorerConfig_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StorerConfig_DELLOG] ADD CONSTRAINT [PK__StorerConfig_DEL__11564BB9] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[StorerConfig_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StorerConfig_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StorerConfig_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StorerConfig_DELLOG] TO [NSQL]
GO
