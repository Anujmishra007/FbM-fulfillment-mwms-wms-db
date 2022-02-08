CREATE TABLE [dbo].[PickingVoice]
(
[PickingVoiceKey] [int] NOT NULL IDENTITY(1, 1),
[Pickslipno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_Pickslipno] DEFAULT (''),
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_Facility] DEFAULT (''),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pickdetailkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL CONSTRAINT [DF_PickingVoice_Qty] DEFAULT ((0)),
[StartTime] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_Starttime] DEFAULT (getdate()),
[EndTime] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_EndTime] DEFAULT (getdate()),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PickingVoice] ADD CONSTRAINT [PK__PickingV__D40815CBD7FBE2F7] PRIMARY KEY CLUSTERED ([PickingVoiceKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PickingVoice_Pickslipno] ON [dbo].[PickingVoice] ([Pickslipno], [UserID], [SKU], [LOC]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date Time User Add the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Add the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Admin flag for Data housekeep ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Last Date Time User Update the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Last User who Update the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Finish Picking time ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Facility code', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SKU Location bin code', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'LOC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order Document Number', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pickdetail table unique key', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Pickdetailkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Table unique running number', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'PickingVoiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PickSlip number', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Pickslipno'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picked quantity', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SKU Stock code', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Start Picking time ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picking task status ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Owner key', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Admin flag for Skip trigger process ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picker user ID', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'UserID'
GO
