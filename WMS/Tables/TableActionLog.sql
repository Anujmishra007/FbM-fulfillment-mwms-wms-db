CREATE TABLE [dbo].[TableActionLog]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[TableName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_TableActionLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TableActionLog_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TableActionLog] ADD CONSTRAINT [PK_TableActionLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TableActionLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TableActionLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TableActionLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TableActionLog] TO [NSQL]
GO
