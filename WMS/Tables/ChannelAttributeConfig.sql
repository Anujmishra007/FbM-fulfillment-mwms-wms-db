CREATE TABLE [dbo].[ChannelAttributeConfig]
(
[ChannelConfig_ID] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_AttributeLabel01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelAttributeConfig_C_AttributeLabel01] DEFAULT (''),
[C_AttributeLabel02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelAttributeConfig_C_AttributeLabel02] DEFAULT (''),
[C_AttributeLabel03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelAttributeConfig_C_AttributeLabel03] DEFAULT (''),
[C_AttributeLabel04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelAttributeConfig_C_AttributeLabel04] DEFAULT (''),
[C_AttributeLabel05] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelAttributeConfig_C_AttributeLabel05] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_ChannelAttributeConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelAttributeConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_ChannelAttributeConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelAttributeConfig_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChannelAttributeConfig] ADD CONSTRAINT [PK_ChannelAttributeConfig] PRIMARY KEY CLUSTERED ([ChannelConfig_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelAttributeConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelAttributeConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelAttributeConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelAttributeConfig] TO [NSQL]
GO
