CREATE TABLE [dbo].[DEL_REPLENISHMENT]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[ReplenishmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReplenishmentGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[QtyMoved] [int] NULL CONSTRAINT [DF_DEL_REPLENISHMENT_QtyMoved] DEFAULT ((0)),
[QtyInPickLoc] [int] NULL CONSTRAINT [DF_DEL_REPLENISHMENT_QtyInPickLoc] DEFAULT ((0)),
[Priority] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_Priority] DEFAULT ('99999'),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Confirmed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_ReplenNo] DEFAULT (' '),
[Remark] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_REPLENISHMENT_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_REPLENISHMENT_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_REPLENISHMENT_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_REPLENISHMENT_EditWho] DEFAULT (suser_sname()),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_RefNo] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_Status] DEFAULT ('0'),
[DropID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_DropID] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_LoadKey] DEFAULT (''),
[Wavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_Wavekey] DEFAULT (''),
[OriginalFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_OriginalFromLoc] DEFAULT (''),
[OriginalQty] [int] NULL CONSTRAINT [DF_DEL_REPLENISHMENT_OriginalQty] DEFAULT ((0)),
[DeleteWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DEL_REPLENISHMENT_DeleteWho] DEFAULT (suser_sname()),
[DeleteDate] [datetime] NOT NULL CONSTRAINT [DF_DEL_REPLENISHMENT_DeleteDate] DEFAULT (getdate()),
[SourceType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MoveRefKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Del_Replenishment_MoveRefKey] DEFAULT (''),
[PendingMoveIn] [int] NULL CONSTRAINT [DF_DEL_REPLENISHMENT_PendingMoveIn] DEFAULT ((0)),
[QtyReplen] [int] NULL CONSTRAINT [DF_DEL_REPLENISHMENT_QtyReplen] DEFAULT ((0)),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DEL_REPLENISHMENT_ToID] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEL_REPLENISHMENT] ADD CONSTRAINT [PK_DEL_REPLENISHMENT] PRIMARY KEY NONCLUSTERED ([ReplenishmentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DEL_REPLENISHMENT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DEL_REPLENISHMENT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DEL_REPLENISHMENT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DEL_REPLENISHMENT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Move Reference Key', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'MoveRefKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PendingMoveIn Quantity', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'PendingMoveIn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product currently in the Pick Location.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'QtyInPickLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Quantity', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'QtyReplen'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying replenishment.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'ReplenishmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying replenishment.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'ReplenNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To ID', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'ToID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'DEL_REPLENISHMENT', 'COLUMN', N'UOM'
GO
