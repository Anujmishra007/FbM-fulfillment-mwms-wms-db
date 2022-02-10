CREATE TABLE [dbo].[DailyInventoryChannel_DELLOG]
(
[ROWRef] [bigint] NOT NULL IDENTITY(1, 1),
[RowRefSource] [int] NOT NULL,
[Channel_ID] [bigint] NOT NULL,
[InventoryDate] [datetime] NOT NULL,
[StorerKey] [nvarchar] (15) NOT NULL,
[SKU] [nvarchar] (20) NOT NULL,
[Facility] [nvarchar] (5) NOT NULL,
[Channel] [nvarchar] (20) NOT NULL,
[C_Attribute01] [nvarchar] (30) NOT NULL,
[C_Attribute02] [nvarchar] (30) NOT NULL,
[C_Attribute03] [nvarchar] (30) NOT NULL,
[C_Attribute04] [nvarchar] (30) NOT NULL,
[C_Attribute05] [nvarchar] (30) NOT NULL,
[Qty] [int] NOT NULL,
[QtyAllocated] [int] NOT NULL,
[QtyOnHold] [int] NOT NULL,
[ArchiveCop] [char] (1) NULL,
[Status] [nchar] (1) NOT NULL CONSTRAINT [DF_DailyInventoryChannel_DELLOG_Status] DEFAULT ('0'),
[Adddate] [datetime] NULL CONSTRAINT [DF_DailyInventoryChannel_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_DailyInventoryChannel_DELLOG_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DailyInventoryChannel_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DailyInventoryChannel_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DailyInventoryChannel_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DailyInventoryChannel_DELLOG] TO [NSQL]
GO
