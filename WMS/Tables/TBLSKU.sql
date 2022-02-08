CREATE TABLE [dbo].[TBLSKU]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DESCR] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_SUSR3] DEFAULT (' '),
[SUSR4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MANUFACTURERSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RETAILSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALTSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_Packkey] DEFAULT ('STD'),
[STDGROSSWGT] [float] NOT NULL CONSTRAINT [DF_TBLSKU_StdGrossWgt] DEFAULT ((0)),
[STDNETWGT] [float] NOT NULL CONSTRAINT [DF_TBLSKU_StdNetWgt] DEFAULT ((0)),
[STDCUBE] [float] NOT NULL CONSTRAINT [DF_TBLSKU_StdCube] DEFAULT ((0)),
[TARE] [float] NOT NULL CONSTRAINT [DF_TBLSKU_Tare] DEFAULT ((0)),
[CLASS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_Class] DEFAULT ('STD'),
[ACTIVE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_ACTIVE] DEFAULT ('1'),
[SKUGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_SKUGROUP] DEFAULT ('STD'),
[Tariffkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_Tariffkey] DEFAULT ('XXXXXXXXXX'),
[BUSR1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOTTABLE01LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_LOTTABLE01LABEL] DEFAULT (' '),
[LOTTABLE02LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_LOTTABLE02LABEL] DEFAULT (' '),
[LOTTABLE03LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_LOTTABLE03LABEL] DEFAULT (' '),
[LOTTABLE04LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_LOTTABLE04LABEL] DEFAULT (' '),
[LOTTABLE05LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_LOTTABLE05LABEL] DEFAULT (' '),
[NOTES1] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTES2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_PickCode] DEFAULT ('NSPFIFO'),
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_StrategyKey] DEFAULT ('STD'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_CartonGroup] DEFAULT ('STD'),
[PutCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_PutCode] DEFAULT ('NSPPASTD'),
[PutawayLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_PutawayLoc] DEFAULT ('UNKNOWN'),
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_Putawayzone] DEFAULT ('BULK'),
[InnerPack] [int] NOT NULL CONSTRAINT [DF_TBLSKU_InnerPack] DEFAULT ((0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_TBLSKU_Cube] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_TBLSKU_GrossWgt] DEFAULT ((0)),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_TBLSKU_NetWgt] DEFAULT ((0)),
[ABC] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CycleCountFrequency] [int] NULL,
[LastCycleCount] [datetime] NULL,
[ReorderPoint] [int] NULL,
[ReorderQty] [int] NULL,
[StdOrderCost] [float] NULL,
[CarryCost] [float] NULL,
[Price] [money] NULL,
[Cost] [money] NULL,
[ReceiptHoldCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_ReceiptHoldCode] DEFAULT (' '),
[ReceiptInspectionLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_ReceiptInspectionLoc] DEFAULT ('QC'),
[OnReceiptCopyPackkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_OnReceiptCopyPackkey] DEFAULT ('0'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IOFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TareWeight] [float] NULL CONSTRAINT [DF_TBLSKU_TareWeight] DEFAULT ((0)),
[LotxIdDetailOtherlabel1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_LotxIdDetailOtherlabel1] DEFAULT ('Ser#'),
[LotxIdDetailOtherlabel2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_LotxIdDetailOtherlabel2] DEFAULT ('CSID'),
[LotxIdDetailOtherlabel3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_LotxIdDetailOtherlabel3] DEFAULT ('Other'),
[AvgCaseWeight] [float] NULL CONSTRAINT [DF_TBLSKU_AvgCaseWeight] DEFAULT ((0)),
[TolerancePct] [float] NULL CONSTRAINT [DF_TBLSKU_TolerancePct] DEFAULT ((0)),
[SkuStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_SkuStatus] DEFAULT ('ACTIVE'),
[Length] [float] NULL CONSTRAINT [DF_TBLSKU_Length] DEFAULT ((0.00)),
[Width] [float] NULL CONSTRAINT [DF_TBLSKU_Width] DEFAULT ((0.00)),
[Height] [float] NULL CONSTRAINT [DF_TBLSKU_Height] DEFAULT ((0.00)),
[weight] [real] NULL,
[itemclass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_itemclass] DEFAULT (' '),
[ShelfLife] [int] NULL CONSTRAINT [DF_TBLSKU_ShelfLife] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_BUSR6] DEFAULT (' '),
[BUSR7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_BUSR7] DEFAULT (' '),
[BUSR8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_BUSR8] DEFAULT (' '),
[BUSR9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_BUSR9] DEFAULT (' '),
[BUSR10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_BUSR10] DEFAULT (' '),
[ReturnLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TBLSKU_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_AddWho] DEFAULT (user_name()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TBLSKU_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TBLSKU_EditWho] DEFAULT (user_name()),
[archiveqty] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_ArchiveQty] DEFAULT ((0)),
[XDockReceiptLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrePackIndicator] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_PrePackIndicator] DEFAULT (' '),
[PackQtyIndicator] [int] NULL CONSTRAINT [DF_TBLSKU_PackQtyIndicator] DEFAULT ((0)),
[StackFactor] [int] NULL CONSTRAINT [DF_TBLSKU_StackFactor] DEFAULT ((0)),
[IVAS] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OVAS] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColorDescr] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_ColorDescr] DEFAULT (''),
[ProductName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_ProductName] DEFAULT (''),
[UpperMaterial] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_UpperMaterial] DEFAULT (''),
[OutsoleMaterial] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_OutsoleMaterial] DEFAULT (''),
[ITCNST] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_ITCNST] DEFAULT (''),
[ITEXP5] [float] NULL CONSTRAINT [DF_TBLSKU_ITEXP5] DEFAULT ((0)),
[ITEXP6] [float] NULL CONSTRAINT [DF_TBLSKU_ITEXP6] DEFAULT ((0)),
[ITEXP7] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_ITEXP7] DEFAULT (''),
[ITEXP8] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TBLSKU_ITEXP8] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TBLSKU] ADD CONSTRAINT [PKTBLSKU] PRIMARY KEY CLUSTERED ([Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TBLSKU] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TBLSKU] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TBLSKU] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TBLSKU] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Notational only. A- Fast Mover, B- Average Mover, C- Slow Mover.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'ABC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Alternate Commodity ID to be linked to the Master Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'ALTSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional information for barcodes.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'BUSR9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies a classification for the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'CLASS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The total spent for goods or services including money and time and labor.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'Cost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of ', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'DESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'LOTTABLE01LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'LOTTABLE02LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'LOTTABLE03LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'LOTTABLE04LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'LOTTABLE05LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information ', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'NOTES1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'NOTES2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying on receipt copy pack.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'OnReceiptCopyPackkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Pack code.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'PACKKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identified the preferred putaway zone for this Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'PutawayLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway location for the Commodity in the facility. Can be used by the putaway strategy as a putaway location.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Put.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'PutCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'ShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Can be used to put Commodities in logical groups. For example, in a facility that handles computer components, Commodity Groups could describe types of peripherals, such as monitors, hard drives, cables and printers.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'SKUGROUP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the default cube per unit in term of eaches. (Master Unit)', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'STDCUBE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight per unit in term of eaches.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'STDGROSSWGT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the net weight per unit in term of eaches. (Master Unit)', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'STDNETWGT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Strategy.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional static information about the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'SUSR1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional static information about the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'SUSR2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional static information about the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'SUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional static information about the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'SUSR4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tracks additional static information about the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'SUSR5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Tariff assigned to the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'Tariffkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the allowable deviation of weight (postive or negative) based on the average weight entered. Tolerance (%) cannot be negative.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'TolerancePct'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TBLSKU', 'COLUMN', N'TrafficCop'
GO
