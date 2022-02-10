CREATE TABLE [dbo].[CartonTrack]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_CarrierName] DEFAULT (' '),
[KeyName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_KeyName] DEFAULT (' '),
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_LabelNo] DEFAULT (' '),
[CarrierRef1] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_CarrierRef1] DEFAULT (' '),
[CarrierRef2] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_CarrierRef2] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_CartonTrack_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_CartonTrack_EditDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvDespatchDate] [datetime] NULL,
[ActualDeliveryDate] [datetime] NULL,
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_UDF03] DEFAULT (''),
[PrintData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CartonTrack_PrintData] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CartonTrack] ADD CONSTRAINT [PK_CartonTrack] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CARTONTRACK_03] ON [dbo].[CartonTrack] ([CarrierName], [KeyName], [CarrierRef2], [LabelNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_cartontrack_LabelNo] ON [dbo].[CartonTrack] ([LabelNo]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_cartontrack_TrackingNo] ON [dbo].[CartonTrack] ([TrackingNo], [CarrierName]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CartonTrack] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CartonTrack] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CartonTrack] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CartonTrack] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CartonTrack] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Actual Delivery Date.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'ActualDeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Inventory Despatch Date.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'InvDespatchDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ZPL Template for Direct Printing', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'PrintData'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define field 1.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define field 2.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User define field 3.', 'SCHEMA', N'dbo', 'TABLE', N'CartonTrack', 'COLUMN', N'UDF03'
GO
