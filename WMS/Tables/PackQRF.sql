CREATE TABLE [dbo].[PackQRF]
(
[PackQRFKey] [bigint] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_PickSlipNo] DEFAULT (''),
[CartonNo] [int] NOT NULL CONSTRAINT [DF_PackQRF_CartonNo] DEFAULT ((0)),
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_LabelLine] DEFAULT (''),
[QRCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_QRCode] DEFAULT (''),
[RFIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_RFIDNo] DEFAULT (''),
[TIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_TIDNo] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_PackQRF_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackQRF_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PackQRF_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackQRF_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QRFGroupKey] [int] NOT NULL CONSTRAINT [DF_PackQRF_QRFGroupKey] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PackQRF] ADD CONSTRAINT [PK_PackQRF] PRIMARY KEY CLUSTERED ([PackQRFKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_PackCartonLine] ON [dbo].[PackQRF] ([PickSlipNo], [CartonNo], [LabelLine]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_QRFGroupKey] ON [dbo].[PackQRF] ([PickSlipNo], [CartonNo], [LabelLine], [QRFGroupKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_QRCode] ON [dbo].[PackQRF] ([QRCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_RFIDNo_TIDNo] ON [dbo].[PackQRF] ([RFIDNo], [TIDNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PackQRF] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackQRF] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackQRF] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackQRF] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Keep Packing QRCOde/RFIDNo/TIDNo', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddDate', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddWho', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton #', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditDate', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditWho', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Label Line #', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'LabelLine'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'PackQRFKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick Slip #', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QR Code', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'QRCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QRF Group Key', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'QRFGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'RFID No', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'RFIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TID No', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'TIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TrafficCop', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'TrafficCop'
GO
