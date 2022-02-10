CREATE TABLE [dbo].[PickingInfo]
(
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScanInDate] [datetime] NULL,
[PickerID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScanOutDate] [datetime] NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickingInfo_AddWho] DEFAULT (suser_sname()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickingInfo_EditWho] DEFAULT (suser_sname()),
[WaveKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_pickinginfo_WaveKey] DEFAULT (''),
[CaseID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_pickinginfo_CaseID] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PickingInfo] ADD CONSTRAINT [PK_PickingInfo] PRIMARY KEY CLUSTERED ([PickSlipNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PickingInfo3] ON [dbo].[PickingInfo] ([ScanInDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PickingInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PickingInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PickingInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PickingInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PickingInfo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'CaseID', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'CaseID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the picker.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'PickerID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pickslip.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WaveKey', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'WaveKey'
GO
