CREATE TABLE [dbo].[SKUxLOC]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUxLOC_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUxLOC_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUxLOC_Loc] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_QtyPicked] DEFAULT ((0)),
[QtyExpected] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_QtyExpected] DEFAULT ((0)),
[QtyLocationLimit] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_QtyLocationLimit] DEFAULT ((0)),
[QtyLocationMinimum] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_QtyLocationMinimum] DEFAULT ((0)),
[QtyPickInProcess] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_QtyPickInProcess] DEFAULT ((0)),
[QtyReplenishmentOverride] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_QtyReplenishmentOverride] DEFAULT ((0)),
[ReplenishmentPriority] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUxLOC_ReplenishmentPriority] DEFAULT ('9'),
[ReplenishmentSeverity] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_ReplenishmentSeverity] DEFAULT ((0)),
[ReplenishmentCasecnt] [int] NOT NULL CONSTRAINT [DF_SKUxLOC_ReplenishmentCasecnt] DEFAULT ((0)),
[LocationType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUxLOC_LocationType] DEFAULT (' '),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUxLOC_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_SKUxLOC_EditDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKUxLOC_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_SKUxLOC_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[SKUxLOC] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[SKUxLOC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SKUxLOC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SKUxLOC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SKUxLOC] TO [NSQL]
GO

ALTER TABLE [dbo].[SKUxLOC] WITH NOCHECK ADD CONSTRAINT [CK_SKUxLOC_01] CHECK (([Qty]+[QtyExpected]>=([QtyAllocated]+[QtyPicked])))
GO
ALTER TABLE [dbo].[SKUxLOC] WITH NOCHECK ADD CONSTRAINT [CK_SKUxLOC_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[SKUxLOC] WITH NOCHECK ADD CONSTRAINT [CK_SKUxLOC_QtyAllocated] CHECK (([QtyAllocated]>=(0)))
GO
ALTER TABLE [dbo].[SKUxLOC] WITH NOCHECK ADD CONSTRAINT [CK_SKUxLOC_QtyPicked] CHECK (([QtyPicked]>=(0)))
GO
ALTER TABLE [dbo].[SKUxLOC] ADD CONSTRAINT [PKSKUxLOC] PRIMARY KEY CLUSTERED ([StorerKey], [Sku], [Loc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SKUxLOC_LOC] ON [dbo].[SKUxLOC] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SKUxLOC_LOCTYPE] ON [dbo].[SKUxLOC] ([LocationType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SKUxLOC_REPSEV] ON [dbo].[SKUxLOC] ([ReplenishmentSeverity]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SKUxLOC2] ON [dbo].[SKUxLOC] ([StorerKey], [Loc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SKUxLOC1] ON [dbo].[SKUxLOC] ([StorerKey], [Sku], [Loc], [LocationType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SKUxLOC] WITH NOCHECK ADD CONSTRAINT [FK_SKUxLOC_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[SKUxLOC] WITH NOCHECK ADD CONSTRAINT [FK_SKUxLOC_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setup the pick locations for a Commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently allocated in the location.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'QtyExpected'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently picked in the location.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently in the location which picking is in progress.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'QtyPickInProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'SKUxLOC', 'COLUMN', N'TrafficCop'
GO
