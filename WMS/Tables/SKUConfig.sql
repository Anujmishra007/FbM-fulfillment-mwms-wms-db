CREATE TABLE [dbo].[SKUConfig]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConfigType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Data] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUConfig_Data] DEFAULT (' '),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUConfig_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_SKUConfig_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUConfig_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_SKUConfig_EditDate] DEFAULT (getdate()),
[userdefine01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine01] DEFAULT (''),
[userdefine02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine02] DEFAULT (''),
[userdefine03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine03] DEFAULT (''),
[userdefine04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine04] DEFAULT (''),
[userdefine05] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine05] DEFAULT (''),
[userdefine06] [datetime] NULL,
[userdefine07] [datetime] NULL,
[userdefine08] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine08] DEFAULT (''),
[userdefine09] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine09] DEFAULT (''),
[userdefine10] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine10] DEFAULT (''),
[userdefine11] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine11] DEFAULT (''),
[userdefine12] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine12] DEFAULT (''),
[userdefine13] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine13] DEFAULT (''),
[userdefine14] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine14] DEFAULT (''),
[userdefine15] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Skuconfig_Userdefine15] DEFAULT (''),
[notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SKUConfig] ADD CONSTRAINT [PK_SKUConfig] PRIMARY KEY CLUSTERED ([StorerKey], [SKU], [ConfigType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[SKUConfig] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[SKUConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SKUConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SKUConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SKUConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKUConfig', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKUConfig', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKUConfig', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKUConfig', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Sku', 'SCHEMA', N'dbo', 'TABLE', N'SKUConfig', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'SKUConfig', 'COLUMN', N'StorerKey'
GO
