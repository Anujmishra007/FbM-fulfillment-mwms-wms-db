CREATE TABLE [dbo].[ChannelInvHold]
(
[InvHoldkey] [bigint] NOT NULL IDENTITY(1, 1),
[HoldType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_HoldType] DEFAULT (''),
[Sourcekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_Sourcekey] DEFAULT (''),
[Hold] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_Hold] DEFAULT ('0'),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_Sku] DEFAULT (''),
[Facility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_Facility] DEFAULT (''),
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_Channel] DEFAULT (''),
[C_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_C_Attribute01] DEFAULT (''),
[C_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_C_Attribute02] DEFAULT (''),
[C_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_C_Attribute03] DEFAULT (''),
[C_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_C_Attribute04] DEFAULT (''),
[C_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_C_Attribute05] DEFAULT (''),
[Channel_ID] [bigint] NOT NULL CONSTRAINT [DF_ChannelInvHold_Channel_ID] DEFAULT ((0)),
[Remarks] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_Remarks] DEFAULT (''),
[DateOn] [datetime] NOT NULL CONSTRAINT [DF_ChannelInvHold_DateOn] DEFAULT (getdate()),
[WhoOn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_WhoOn] DEFAULT (suser_sname()),
[DateOff] [datetime] NOT NULL CONSTRAINT [DF_ChannelInvHold_DateOff] DEFAULT (getdate()),
[WhoOff] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHold_WhoOff] DEFAULT (suser_sname()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ChannelInvHold] ADD CONSTRAINT [PK_ChannelInvHold] PRIMARY KEY CLUSTERED ([InvHoldkey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChannelInvHold_2] ON [dbo].[ChannelInvHold] ([Facility], [Channel], [C_Attribute01], [C_Attribute02], [C_Attribute03], [C_Attribute04], [C_Attribute05]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChannelInvHold_1] ON [dbo].[ChannelInvHold] ([HoldType], [Sourcekey], [Hold]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelInvHold] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelInvHold] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelInvHold] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelInvHold] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Inventory Hold Master table', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attritebute 1', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'C_Attribute01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attritebute 2', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'C_Attribute02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attritebute 3', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'C_Attribute03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attritebute 4', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'C_Attribute04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attritebute 5', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'C_Attribute05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Channel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Channel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date to unhold channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'DateOff'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date to hold channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'DateOn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hold/Unhold', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Hold'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document Type {ASN/ADJ/TRF}', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'HoldType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'InvHoldkey', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'InvHoldkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source key', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TrafficCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Who Unhold Channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'WhoOff'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Who Hold Channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHold', 'COLUMN', N'WhoOn'
GO
