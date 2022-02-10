CREATE TABLE [dbo].[TrackingID]
(
[TrackingIDKey] [bigint] NOT NULL IDENTITY(1, 1),
[TrackingID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_SKU] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL CONSTRAINT [DF_TrackingID_QTY] DEFAULT ((1)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_DropID] DEFAULT (''),
[ParentTrackingID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_ParentTrackingID] DEFAULT (''),
[UserDefine01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_UserDefine05] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TrackingID_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TrackingID_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_ReceiptKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TrackingID_Facility] DEFAULT (''),
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TrackingID_PickMethod] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TrackingID] ADD CONSTRAINT [PK_TrackingID] PRIMARY KEY CLUSTERED ([TrackingIDKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrackingID_ParentTrackingID_StorerKey] ON [dbo].[TrackingID] ([ParentTrackingID], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrackingID_TrackingID_StorerKey] ON [dbo].[TrackingID] ([TrackingID], [StorerKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrackingID] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TrackingID] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TrackingID] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TrackingID] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique ID for each/inner/carton/pallet that not kept after ship out', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddDate', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AddWho', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet ID/carton ID/UCC no/Drop ID', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'DropID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditDate', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'EditWho', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store Facility Value', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parent tracking ID', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'ParentTrackingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Picking Method', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'PickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', N'QTY (optional)', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store ASN Value', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SKU (optional)', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Child tracking ID', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'TrackingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'TrackingIDKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TrafficCop', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM of inner/carton/pallet', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define', 'SCHEMA', N'dbo', 'TABLE', N'TrackingID', 'COLUMN', N'UserDefine05'
GO
