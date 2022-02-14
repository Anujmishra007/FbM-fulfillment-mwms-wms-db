CREATE TABLE [dbo].[ChannelInv]
(
[Channel_ID] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_Channel] DEFAULT (''),
[C_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute02] DEFAULT (''),
[C_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute03] DEFAULT (''),
[C_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute04] DEFAULT (''),
[C_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute05] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_ChannelInv_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_ChannelInv_QtyAllocated] DEFAULT ((0)),
[QtyOnHold] [int] NOT NULL CONSTRAINT [DF_ChannelInv_QtyOnHold] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_ChannelInv_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelInv_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_ChannelInv_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelInv_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_QtyAllocated] CHECK (([QtyAllocated]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_QtyOnHold] CHECK ((([Qty]-[QtyAllocated])-[QtyonHold]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_QtyOnHold2] CHECK (([QtyonHold]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [PK_ChannelInv] PRIMARY KEY CLUSTERED ([Channel_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChannelInv_sku] ON [dbo].[ChannelInv] ([SKU], [Channel]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelInv] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelInv] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelInv] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelInv] TO [NSQL]
GO
