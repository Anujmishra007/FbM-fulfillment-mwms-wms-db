CREATE TABLE [dbo].[CHANNELITRAN]
(
[ChannelTran_ID] [bigint] NOT NULL IDENTITY(1, 1),
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_TranType] DEFAULT (''),
[ChannelTranRefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_ChannelTranRefNo] DEFAULT (''),
[SourceType] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_SourceType] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Channel_ID] [bigint] NULL CONSTRAINT [DF_CHANNELITRAN_Channel_ID] DEFAULT (''),
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_Channel] DEFAULT (''),
[C_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_C_Attribute01] DEFAULT (''),
[C_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_C_Attribute02] DEFAULT (''),
[C_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_C_Attribute03] DEFAULT (''),
[C_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_C_Attribute04] DEFAULT (''),
[C_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CHANNELITRAN_C_Attribute05] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_CHANNELITRAN_Qty] DEFAULT ((0)),
[QtyOnHold] [int] NOT NULL CONSTRAINT [DF_CHANNELITRAN_QtyOnHold] DEFAULT ((0)),
[Reasoncode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CHANNELITRAN_Reasoncode] DEFAULT (''),
[CustomerRef] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CHANNELITRAN_CustomerRef] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_CHANNELITRAN_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CHANNELITRAN_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_CHANNELITRAN_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CHANNELITRAN_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CHANNELITRAN] ADD CONSTRAINT [PK_CHANNELITRAN] PRIMARY KEY CLUSTERED ([ChannelTran_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CHANNELITRAN_SourceType] ON [dbo].[CHANNELITRAN] ([SourceType], [ChannelTranRefNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CHANNELITRAN_TranType] ON [dbo].[CHANNELITRAN] ([TranType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CHANNELITRAN] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CHANNELITRAN] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CHANNELITRAN] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CHANNELITRAN] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Transaction', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attribute 1', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'C_Attribute01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attribute 2', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'C_Attribute02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attribute 3', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'C_Attribute03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attribute 4', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'C_Attribute04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Attribute 5', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'C_Attribute05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel( ECOM, RETAIL )', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'Channel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'Channel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Transaction', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'ChannelTranRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel transaction Customer Ref.', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'CustomerRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel transaction Qty', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel transaction On Hold Qty', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'QtyOnHold'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel transaction Reason Code', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'Reasoncode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source Type', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transaction Type', 'SCHEMA', N'dbo', 'TABLE', N'CHANNELITRAN', 'COLUMN', N'TranType'
GO
