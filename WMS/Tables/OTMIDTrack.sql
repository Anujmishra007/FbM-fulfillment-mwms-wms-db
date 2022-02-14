CREATE TABLE [dbo].[OTMIDTrack]
(
[MUID] [int] NOT NULL IDENTITY(1, 1),
[TrackingNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Principal] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MUStatus] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipmentID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NULL,
[Width] [float] NULL,
[Height] [float] NULL,
[GrossWeight] [float] NULL,
[GrossVolume] [float] NULL,
[TruckID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MUType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OTMIDTrack_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OTMIDTrack_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_OTMIDTrack_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OTMIDTrack_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonGID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OTMIDTrack_CartonGID] DEFAULT (''),
[CartonQty] [float] NULL CONSTRAINT [DF_OTMIDTrack_CartonQty] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OTMIDTrack] ADD CONSTRAINT [PK_OTMIDTrack_MUID] PRIMARY KEY CLUSTERED ([MUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OTMIDTrack_MUID_OrderID] ON [dbo].[OTMIDTrack] ([MUID], [OrderID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM Carton GID', 'SCHEMA', N'dbo', 'TABLE', N'OTMIDTrack', 'COLUMN', N'CartonGID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM Carton Qty', 'SCHEMA', N'dbo', 'TABLE', N'OTMIDTrack', 'COLUMN', N'CartonQty'
GO
