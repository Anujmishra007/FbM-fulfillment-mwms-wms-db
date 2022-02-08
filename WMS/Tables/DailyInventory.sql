CREATE TABLE [dbo].[DailyInventory]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventory_Id] DEFAULT (' '),
[Qty] [int] NOT NULL,
[InventoryDate] [datetime] NOT NULL,
[Adddate] [datetime] NULL CONSTRAINT [DF_DailyInventory_Adddate] DEFAULT (getdate()),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_DailyInventory_Editdate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Editwho] DEFAULT (suser_sname()),
[InventoryCBM] [float] NULL CONSTRAINT [DF_DailyInventory_InventoryCBM] DEFAULT ((0)),
[InventoryPallet] [float] NULL CONSTRAINT [DF_DailyInventory_InventoryPallet] DEFAULT ((0)),
[CommingleSku] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_CommingleSku] DEFAULT ('0'),
[SkuInventoryPallet] [float] NULL CONSTRAINT [DF_DailyInventory_SkuInventoryPallet] DEFAULT ((0)),
[SkuChargingPallet] [float] NULL CONSTRAINT [DF_DailyInventory_SkuChargingPallet] DEFAULT ((0)),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_DailyInventory_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_DailyInventory_QtyPicked] DEFAULT ((0)),
[Pallet] [float] NOT NULL CONSTRAINT [DF_DailyInventory_Pallet] DEFAULT ((0)),
[StdCube] [float] NOT NULL CONSTRAINT [DF_DailyInventory_StdCube] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventory_Facility] DEFAULT (' '),
[HostWhCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventory_LocationFlag] DEFAULT (' '),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventory_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventory_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventory_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[QtyOnhold] [int] NOT NULL CONSTRAINT [DF_DailyInventory_QtyOnhold] DEFAULT ((0)),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DailyInventory_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DailyInventory] ADD CONSTRAINT [PKDailyInventory] PRIMARY KEY CLUSTERED ([InventoryDate], [Storerkey], [Sku], [Lot], [Loc], [Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DailyInventory_ArchiveCop] ON [dbo].[DailyInventory] ([ArchiveCop]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DailyInventory_InventoryDate] ON [dbo].[DailyInventory] ([InventoryDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DailyInventory_Loc] ON [dbo].[DailyInventory] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DailyInventory_InventoryDate2] ON [dbo].[DailyInventory] ([Storerkey], [InventoryDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[DailyInventory] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[DailyInventory] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DailyInventory] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DailyInventory] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DailyInventory] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether more than one Commodity can be stored at the Location. Options are Y (Yes) an N (No).', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'CommingleSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Host Warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'HostWhCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or pallet jack to lift, move and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated to the daily inventory.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently allocated in the location.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently picked in the location.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the default cube per unit in tems of eaches. (Master Unit)', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'StdCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'DailyInventory', 'COLUMN', N'Storerkey'
GO
