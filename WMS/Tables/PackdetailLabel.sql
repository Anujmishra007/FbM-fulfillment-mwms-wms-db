CREATE TABLE [dbo].[PackdetailLabel]
(
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) NOT NULL CONSTRAINT [DF_PackdetailLabel_PickSlipNo] DEFAULT (''),
[LabelNo] [nvarchar] (20) NOT NULL CONSTRAINT [DF_PackdetailLabel_LabelNo] DEFAULT (''),
[CartonNo] [int] NOT NULL CONSTRAINT [DF_PackdetailLabel_CartonNo] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_PackdetailLabel_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_PackdetailLabel_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PackdetailLabel_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_PackdetailLabel_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PackdetailLabel] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackdetailLabel] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackdetailLabel] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackdetailLabel] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Create Indentity For Label to generate Carton #', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddDate', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddWho', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton #', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditDate', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditWho', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Label #', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'LabelNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick Slip #', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'RowID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TrafficCop', 'SCHEMA', N'dbo', 'TABLE', N'PackdetailLabel', 'COLUMN', N'TrafficCop'
GO
