CREATE TABLE [dbo].[BarcodeConfigDetail]
(
[DecodeCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DecodeLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_Description] DEFAULT (''),
[FieldIdentifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_FieldIdentifier] DEFAULT (''),
[LengthType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_LengthType] DEFAULT (''),
[MaxLength] [int] NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_MaxLength] DEFAULT ((0)),
[TerminateChar] [tinyint] NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_TerminateChar] DEFAULT ((0)),
[DataType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_DataType] DEFAULT (''),
[MapTo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_MapTo] DEFAULT (''),
[FormatSP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_FormatSP] DEFAULT (''),
[ProcessSP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_ProcessSP] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BarcodeConfigDetail_EditDate] DEFAULT (getdate()),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BarcodeConfigdetail_Type] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BarcodeConfigDetail] WITH NOCHECK ADD CONSTRAINT [CK_BarcodeConfigDetail_DataType] CHECK (([DataType]='DECIMAL' OR [DataType]='INTEGER' OR [DataType]='DATE' OR [DataType]='STRING'))
GO
ALTER TABLE [dbo].[BarcodeConfigDetail] ADD CONSTRAINT [CK_BarcodeConfigDetail_LengthType] CHECK (([LengthType]='VARIABLE' OR [LengthType]='FIXED'))
GO
ALTER TABLE [dbo].[BarcodeConfigDetail] ADD CONSTRAINT [CK_BarcodeConfigDetail_MaxLength] CHECK (([MaxLength]>(0)))
GO
ALTER TABLE [dbo].[BarcodeConfigDetail] ADD CONSTRAINT [PK_BarcodeConfigDetail] PRIMARY KEY CLUSTERED ([DecodeCode], [DecodeLineNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BarcodeConfigDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BarcodeConfigDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BarcodeConfigDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BarcodeConfigDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Data type of the abstracted data', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'DataType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Link to BarcodeConfig.DecodeCode', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'DecodeCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Decode sequence of each field in a barcode', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'DecodeLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the field', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Character(s) indicate the starting of a field. It is usually the chars within a bracket in a barcode. For e.g. (01)12345678901234. 01 is the field indicator', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'FieldIdentifier'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stored procedure to format the abstracted data', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'FormatSP'
GO
EXEC sp_addextendedproperty N'MS_Description', N'FIXED=field is fix length VARIABLE=field is variable length', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'LengthType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Abstracted data that map to RDT field', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'MapTo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Max length of the field, in number of chars', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'MaxLength'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stored procedure to process the abstracted data', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'ProcessSP'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ASCII value of the terminate char. It is require for variable length field, to indicate the end of the field', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'TerminateChar'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type to decode', 'SCHEMA', N'dbo', 'TABLE', N'BarcodeConfigDetail', 'COLUMN', N'Type'
GO
