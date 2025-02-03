
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PackInfo]') AND type in (N'U'))
BEGIN
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


ALTER TABLE [dbo].[PackInfo] ADD CONSTRAINT [PK_PackInfo] PRIMARY KEY CLUSTERED ([PickSlipNo], [CartonNo]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_PackInfo_UCCNo] ON [dbo].[PackInfo] ([UCCNo]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_PackInfo_RefNo] ON [dbo].[PackInfo] ( RefNo )  include ( CartonStatus )

CREATE NONCLUSTERED INDEX [IDX_PackInfo_TrackingNo] ON [dbo].[PackInfo]	(	[TrackingNo] ASC 	) ON [PRIMARY]


EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Carton.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'CartonNo'

EXEC sp_addextendedproperty N'MS_Description', 'Carton Status', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'CartonStatus'

EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'Cube'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pick Slip.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'PickSlipNo'

EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'Qty'

EXEC sp_addextendedproperty N'MS_Description', N'Store Tracking No', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'TrackingNo'

EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'TrafficCop'

EXEC sp_addextendedproperty N'MS_Description', N'UCC No', 'SCHEMA', N'dbo', 'TABLE', N'PackInfo', 'COLUMN', N'UCCNo'

END
ELSE
BEGIn
	

	IF NOT EXISTS ( Select 1 from sys.indexes where name = 'IX_PackInfo_RefNo'  )
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_PackInfo_RefNo] ON [dbo].[PackInfo] ( RefNo )  include ( CartonStatus )

	END

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[PackInfo]') AND name = N'IDX_PackInfo_TrackingNo')
	CREATE NONCLUSTERED INDEX [IDX_PackInfo_TrackingNo] ON [dbo].[PackInfo]
	(
		[TrackingNo] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

	
END
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

