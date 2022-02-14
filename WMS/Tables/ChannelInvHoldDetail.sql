CREATE TABLE [dbo].[ChannelInvHoldDetail]
(
[RefID] [bigint] NOT NULL IDENTITY(1, 1),
[InvHoldkey] [bigint] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_InvHoldkey] DEFAULT ((0)),
[SourceLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_SourceLineNo] DEFAULT (''),
[Channel_ID] [bigint] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_Channel_ID] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_Qty] DEFAULT ((0)),
[Hold] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_Hold] DEFAULT ('0'),
[DateOn] [datetime] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_DateOn] DEFAULT (getdate()),
[WhoOn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_WhoOn] DEFAULT (suser_sname()),
[DateOff] [datetime] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_DateOff] DEFAULT (getdate()),
[WhoOff] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_WhoOff] DEFAULT (suser_sname()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ChannelInvHoldDetail] ADD CONSTRAINT [PK_ChannelInvHoldDetail] PRIMARY KEY CLUSTERED ([RefID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChannelInvHoldDetail_InvHoldkey] ON [dbo].[ChannelInvHoldDetail] ([InvHoldkey], [SourceLineNo], [Channel_ID], [Hold]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Inventory Hold Detail table', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'Channel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date to unhold channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'DateOff'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date to hold channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'DateOn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hold/Unhold', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'Hold'
GO
EXEC sp_addextendedproperty N'MS_Description', N'InvHoldkey', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'InvHoldkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hold/Unhold Qty', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row Reference ID', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'RefID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SourceLineNo + Source Line #', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'SourceLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TrafficCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Who Unhold Channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'WhoOff'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Who Hold Channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'WhoOn'
GO
