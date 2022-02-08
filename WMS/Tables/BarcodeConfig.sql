CREATE TABLE [dbo].[BarcodeConfig]
(
[DecodeCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Function_ID] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[Description] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfig_Description] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfig_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BarcodeConfig_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfig_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BarcodeConfig_EditDate] DEFAULT (getdate()),
[AllowGap] [int] NOT NULL CONSTRAINT [DF_BarcodeConfig_AllowGap] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BarcodeConfig] ADD CONSTRAINT [CK_BarcodeConfig_DecodeCode] CHECK (([DecodeCode]<>''))
GO
ALTER TABLE [dbo].[BarcodeConfig] ADD CONSTRAINT [CK_BarcodeConfig_StorerKey] CHECK (([StorerKey]<>''))
GO
ALTER TABLE [dbo].[BarcodeConfig] ADD CONSTRAINT [PK_BarcodeConfig] PRIMARY KEY CLUSTERED ([DecodeCode]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_BarcodeConfig_StorerKey_Function_ID_Sequence] ON [dbo].[BarcodeConfig] ([StorerKey], [Function_ID], [Sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BarcodeConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BarcodeConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BarcodeConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BarcodeConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allow Gap in barcode', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfig', 'COLUMN', N'AllowGap'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An unique code indicate a barcode pattern', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfig', 'COLUMN', N'DecodeCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the barcode', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfig', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RDT function ID or
0 = all RDT modules / Exceed', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfig', 'COLUMN', N'Function_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Decode sequence of the barcode', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfig', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer.StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfig', 'COLUMN', N'StorerKey'
GO
