CREATE TABLE [dbo].[PackSerialNo]
(
[PackSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_PickDetailKey] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackSerialNo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackSerialNo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PackSerialNo] ADD CONSTRAINT [PK_PackSerialNo] PRIMARY KEY CLUSTERED ([PackSerialNoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PACKSERIALNO_PickDetailkey] ON [dbo].[PackSerialNo] ([PickDetailKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackSerialNo_PickSlipNo_CartonNo_LabelNo_LabelLine] ON [dbo].[PackSerialNo] ([PickSlipNo], [CartonNo], [LabelNo], [LabelLine]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PACKSERIALNO_SERIALNO] ON [dbo].[PackSerialNo] ([SerialNo], [StorerKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PackSerialNo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PackSerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackSerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackSerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackSerialNo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Serial no of a pack detail line', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Optional link to PickDetail, mainly for outbound interface', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QTY this serial no represent (could be more than 1)', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'QTY'
GO
