CREATE TABLE [RDT].[rdtSerialNoLog]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_StorerKey] DEFAULT (''),
[Status] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSerialNoLog_Status] DEFAULT ('0'),
[SerialType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSerialNoLog_SerialType] DEFAULT ('0'),
[FromSerialNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_FromSerialNo] DEFAULT (''),
[ToSerialNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_ToSerialNo] DEFAULT (''),
[ParentSerialNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_ParentSerialNo] DEFAULT (''),
[FromSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_FromSKU] DEFAULT (''),
[ToSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_ToSKU] DEFAULT (''),
[SourceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_SourceKey] DEFAULT (''),
[SourceType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_SourceType] DEFAULT (''),
[BatchKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_BatchKey] DEFAULT (''),
[BatchKey2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_BatchKey2] DEFAULT (''),
[Remarks] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_Remarks] DEFAULT (''),
[Func] [int] NULL CONSTRAINT [DF_rdtSerialNoLog_Func] DEFAULT ((0)),
[Func2] [int] NULL CONSTRAINT [DF_rdtSerialNoLog_Func2] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtSerialNoLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_rdtSerialNoLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtSerialNoLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtSerialNoLog] ADD CONSTRAINT [PK_rdtSerialNoLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSerialNoLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSerialNoLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSerialNoLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSerialNoLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddDate', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddWho', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BatchKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'BatchKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BatchKey2', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'BatchKey2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditDate', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditWho', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'FromSerialNo', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'FromSerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'FromSKU', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'FromSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Func', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'Func'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Func2', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'Func2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ParentSerialNo', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'ParentSerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Remarks', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RowRef', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SerialType', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'SerialType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SourceKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SourceType', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ToSerialNo', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'ToSerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ToSKU', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'ToSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TrafficCop', 'SCHEMA', N'RDT', 'TABLE', N'rdtSerialNoLog', 'COLUMN', N'TrafficCop'
GO
