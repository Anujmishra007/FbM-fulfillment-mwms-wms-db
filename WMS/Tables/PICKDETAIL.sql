CREATE TABLE [dbo].[PICKDETAIL]
(
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_CaseID] DEFAULT (' '),
[PickHeaderKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_AltSku] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_PICKDETAIL_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_PICKDETAIL_Qty] DEFAULT ((0)),
[QtyMoved] [int] NOT NULL CONSTRAINT [DF_PICKDETAIL_QtyMoved] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_DropID] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_Loc] DEFAULT ('UNKNOWN'),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_ID] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_PackKey] DEFAULT (' '),
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_UpdateSource] DEFAULT ('0'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_ToLoc] DEFAULT (' '),
[DoReplenish] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_DoReplenish] DEFAULT ('N'),
[ReplenishZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_ReplenishZone] DEFAULT (' '),
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_DoCartonize] DEFAULT ('N'),
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_PickMethod] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_WaveKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptimizeCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_ShipFlag] DEFAULT ('0'),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskManagerReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MoveRefKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_MoveRefKey] DEFAULT (''),
[Channel_ID] [bigint] NULL CONSTRAINT [DF_PICKDETAIL_Channel_ID] DEFAULT ((0)),
[SourceType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKDETAIL_SourceType] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_PICKDETAIL_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_PICKDETAIL_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[PICKDETAIL] ADD CONSTRAINT [PKPickDetail] PRIMARY KEY CLUSTERED ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_CASEID] ON [dbo].[PICKDETAIL] ([CaseID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_DropID] ON [dbo].[PICKDETAIL] ([DropID], [Storerkey], [Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_ID] ON [dbo].[PICKDETAIL] ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL9] ON [dbo].[PICKDETAIL] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_PICKDETAIL_Lotxlocxid] ON [dbo].[PICKDETAIL] ([Lot], [Loc], [ID]) INCLUDE ([ShipFlag], [Status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKDETAIL_ORDERKEY] ON [dbo].[PICKDETAIL] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL_OrderDetStatus] ON [dbo].[PICKDETAIL] ([OrderKey], [OrderLineNumber], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL12] ON [dbo].[PICKDETAIL] ([OrderKey], [PickHeaderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKDETAIL10] ON [dbo].[PICKDETAIL] ([OrderKey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pickdetail_pickslipno] ON [dbo].[PICKDETAIL] ([PickSlipNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKDETAIL_TaskDetailKey] ON [dbo].[PICKDETAIL] ([TaskDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PICKDETAIL_LOT_01] FOREIGN KEY ([Storerkey], [Sku], [Lot]) REFERENCES [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lot])
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PICKDETAIL_LOTLOCID_01] FOREIGN KEY ([Lot], [Loc], [ID]) REFERENCES [dbo].[LOTxLOCxID] ([Lot], [Loc], [Id])
GO
ALTER TABLE [dbo].[PICKDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PICKDETAIL_SKU_01] FOREIGN KEY ([Storerkey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
GRANT SELECT ON  [dbo].[PICKDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PICKDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodities in the warehouse can be identified with a variety of labels, each referring to the product by a different name or item number', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'AltSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Group', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Type', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'CartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Case id', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'CaseID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Do Cartonization', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'DoCartonize'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Drop Id refers to the pallet in which the items', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'DropID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Effective Date', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable Unit ID for the Commodity being picked', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location Picked', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique re-populated numeric value associated with a specific product.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order number. It''s used to identify a specific shipment order record. Automatically generated', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order detail line number. System generated', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'OrderLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack code associated with the transaction when it was entered', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of pickdetail which is picking and system will auto generated pickdetail number', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick Ticket #', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PickHeaderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pick Slip.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick Qty', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity Moved', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'QtyMoved'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SourceType', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'SourceType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picked Status', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer/seller of the products being shipped (Owner of the goods)', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Task number', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location to which to move the Commodity to', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure associated with the transaction when it was entered', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated with the transaction, calculated in the UOM associated with the transaction', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'UOMQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update Source', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'UpdateSource'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDETAIL', 'COLUMN', N'WaveKey'
GO
