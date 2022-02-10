CREATE TABLE [dbo].[BartenderCmdConfig]
(
[LabelType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelDesc] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQL_Select] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BartenderCmdConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderCmdConfig_AddWho] DEFAULT (suser_sname()),
[Type01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderCmdConfig_Type01] DEFAULT (''),
[Type02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderCmdConfig_Type02] DEFAULT (''),
[Type03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BartenderCmdConfig_Type03] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BartenderCmdConfig] ADD CONSTRAINT [PK_BartenderCmdConfig] PRIMARY KEY CLUSTERED ([LabelType], [Type01], [Type02], [Type03]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BartenderCmdConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BartenderCmdConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BartenderCmdConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BartenderCmdConfig] TO [NSQL]
GO
