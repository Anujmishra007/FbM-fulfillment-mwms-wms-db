CREATE TABLE [dbo].[TPB_Config]
(
[TPB_Key] [int] NOT NULL,
[TPB_code] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TPB_Config_TPB_code] DEFAULT (''),
[TPB_def_schedule] [int] NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TPB_Config_Category] DEFAULT (''),
[Description] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enabled] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TPB_Config_Enabled] DEFAULT ('Y'),
[SQL] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLArgument] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLCondition] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastRundate] [datetime] NULL CONSTRAINT [DF_TPB_Config_LastRundate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TPB_Config_AddWho] DEFAULT (suser_sname()),
[ADDDate] [datetime] NULL CONSTRAINT [DF_TPB_Config_ADDDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TPB_Config_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_TPB_Config_EditDate] DEFAULT (getdate()),
[DataDuration] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPB_Config] ADD CONSTRAINT [PK__TPB_Conf__225BBFC30D1497D9] PRIMARY KEY CLUSTERED ([TPB_Key]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPB_Config] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TPB_Config] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TPB_Config] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TPB_Config] TO [NSQL]
GO
