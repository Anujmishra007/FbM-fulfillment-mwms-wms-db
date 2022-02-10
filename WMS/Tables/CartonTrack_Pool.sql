CREATE TABLE [dbo].[CartonTrack_Pool]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_Pool_CarrierName] DEFAULT (' '),
[KeyName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_Pool_KeyName] DEFAULT (' '),
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_Pool_LabelNo] DEFAULT (' '),
[CarrierRef1] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_Pool_CarrierRef1] DEFAULT (' '),
[CarrierRef2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_Pool_CarrierRef2] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_Pool_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_CartonTrack_Pool_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_Pool_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_CartonTrack_Pool_EditDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CartonTrack_Pool] ADD CONSTRAINT [PK_CartonTrack_Pool] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_cartontrack_pool_03] ON [dbo].[CartonTrack_Pool] ([CarrierName], [KeyName], [CarrierRef2], [LabelNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CartonTrack_pool_KeyName] ON [dbo].[CartonTrack_Pool] ([KeyName], [CarrierName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_Cartontrack_pool_TrackingNo] ON [dbo].[CartonTrack_Pool] ([TrackingNo], [CarrierName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CartonTrack_Pool] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CartonTrack_Pool] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CartonTrack_Pool] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CartonTrack_Pool] TO [NSQL]
GO
