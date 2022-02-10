CREATE TABLE [dbo].[VoiceConfig]
(
[ModuleNo] [int] NOT NULL,
[ProfileNo] [int] NOT NULL,
[ParameterCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParameterLineNo] [int] NOT NULL,
[ParameterDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VoiceConfig_parameterDescr] DEFAULT (''),
[ParameterValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_VoiceConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VoiceConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_VoiceConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VoiceConfig_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VoiceConfig] ADD CONSTRAINT [PK_VoiceConfig] PRIMARY KEY CLUSTERED ([ModuleNo], [ProfileNo], [ParameterCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VoiceConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VoiceConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VoiceConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VoiceConfig] TO [NSQL]
GO
