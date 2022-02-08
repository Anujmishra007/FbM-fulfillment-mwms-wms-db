CREATE TABLE [RDT].[RDTPickQCLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickslipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScanQTY] [int] NOT NULL,
[MovedQTY] [int] NOT NULL,
[ReasonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTPickQCLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTPickQCLog_AddWho] DEFAULT (getdate()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDTPickQCLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTPickQCLog_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTPickQCLog] ADD CONSTRAINT [PK_RDTPickQCLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTPickQCLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTPickQCLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTPickQCLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTPickQCLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Add Date', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Add Who', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edit Date', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Edit Who', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Mobile', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'Mobile'
GO
EXEC sp_addextendedproperty N'MS_Description', 'MovedQty', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'MovedQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PickslipNo', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'PickslipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ReasonCode', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Row Ref', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ScanQty', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'ScanQTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SKU', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Key', 'SCHEMA', N'RDT', 'TABLE', N'RDTPickQCLog', 'COLUMN', N'StorerKey'
GO
