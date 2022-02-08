CREATE TABLE [dbo].[REPLENISHMENT]
(
[ReplenishmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReplenishmentGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[QtyMoved] [int] NULL CONSTRAINT [DF_REPLENISHMENT_QtyMoved] DEFAULT ((0)),
[QtyInPickLoc] [int] NULL CONSTRAINT [DF_REPLENISHMENT_QtyInPickLoc] DEFAULT ((0)),
[Priority] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_Priority] DEFAULT ('99999'),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Confirmed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_ReplenNo] DEFAULT (' '),
[Remark] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHMENT_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENT_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHMENT_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENT_EditWho] DEFAULT (suser_sname()),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_RefNo] DEFAULT (' '),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_DropID] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_LoadKey] DEFAULT (' '),
[Wavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_Wavekey] DEFAULT (''),
[OriginalFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_OriginalFromLoc] DEFAULT (''),
[OriginalQty] [int] NULL CONSTRAINT [DF_REPLENISHMENT_OriginalQty] DEFAULT ((0)),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_ToID] DEFAULT (''),
[MoveRefKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Replenishment_MoveRefKey] DEFAULT (''),
[PendingMoveIn] [int] NULL CONSTRAINT [DF_REPLENISHMENT_PendingMoveIn] DEFAULT ((0)),
[QtyReplen] [int] NULL CONSTRAINT [DF_REPLENISHMENT_QtyReplen] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REPLENISHMENT] ADD CONSTRAINT [PK_REPLENISHMENT] PRIMARY KEY CLUSTERED ([ReplenishmentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_REPLENISHMENT_RefNo] ON [dbo].[REPLENISHMENT] ([RefNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_REPLENISHMENT_Group] ON [dbo].[REPLENISHMENT] ([ReplenishmentGroup], [Storerkey]) INCLUDE ([Confirmed]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[REPLENISHMENT] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Replenishment is the function in which fixed pick locations are refilled to capacity with reserve stock from bulk locations. If pick locations are used in the warehouse, the locations must be refilled regularly based upon the total capacity of the pick location and the quantity of the Commodity picked from location.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Move Reference Key', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'MoveRefKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PendingMoveIn Quantity', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'PendingMoveIn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product currently in the Pick Location.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'QtyInPickLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Quantity', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'QtyReplen'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying replenishment.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'ReplenishmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying replenishment.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'ReplenNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'UOM'
GO
