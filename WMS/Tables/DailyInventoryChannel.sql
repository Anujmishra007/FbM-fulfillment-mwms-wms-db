CREATE TABLE [dbo].[DailyInventoryChannel]
(
[ROWRef] [bigint] NOT NULL IDENTITY(1, 1),
[Channel_ID] [bigint] NOT NULL,
[InventoryDate] [datetime] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_Channel] DEFAULT (''),
[C_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute02] DEFAULT (''),
[C_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute03] DEFAULT (''),
[C_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute04] DEFAULT (''),
[C_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute05] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_DailyInventoryChannel_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_DailyInventoryChannel_QtyAllocated] DEFAULT ((0)),
[QtyOnHold] [int] NOT NULL CONSTRAINT [DF_DailyInventoryChannel_QtyOnHold] DEFAULT ((0)),
[ArchiveCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adddate] [datetime] NULL CONSTRAINT [DF_DailyInventoryChannel_Adddate] DEFAULT (getdate())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DailyInventoryChannel] ADD CONSTRAINT [PK_DailyInventoryChannel] PRIMARY KEY CLUSTERED ([ROWRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DailyInvChannel] ON [dbo].[DailyInventoryChannel] ([InventoryDate], [Channel_ID], [StorerKey], [SKU], [Channel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DailyInvChannel_SKU] ON [dbo].[DailyInventoryChannel] ([SKU], [StorerKey], [Channel], [Facility]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
