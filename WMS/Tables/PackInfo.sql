CREATE TABLE [dbo].[PackInfo]
(
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[Weight] [float] NULL CONSTRAINT [DF_PackInfo_Weight] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_PackInfo_Cube] DEFAULT ((0)),
[Qty] [int] NULL CONSTRAINT [DF_PackInfo_Qty] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_PackInfo_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackInfo_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PackInfo_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackInfo_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackInfo_CartonType] DEFAULT (' '),
[RefNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NULL CONSTRAINT [DF_Packinfo_Length] DEFAULT ((0.00)),
[Width] [float] NULL CONSTRAINT [DF_Packinfo_Width] DEFAULT ((0.00)),
[Height] [float] NULL CONSTRAINT [DF_Packinfo_Height] DEFAULT ((0.00)),
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackInfo_UCCNo] DEFAULT (''),
[CartonGID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackInfo_CartonGID] DEFAULT (''),
[CartonStatus] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackInfo_CartonStatus] DEFAULT (''),
[TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackInfo_TrackingNo] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PackInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PackInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackInfo] TO [NSQL]
GO

ALTER TABLE [dbo].[PackInfo] ADD CONSTRAINT [PK_PackInfo] PRIMARY KEY CLUSTERED ([PickSlipNo], [CartonNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackInfo_UCCNo] ON [dbo].[PackInfo] ([UCCNo]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Carton.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Status', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'CartonStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pick Slip.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store Tracking No', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'TrackingNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UCC No', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'UCCNo'
GO
