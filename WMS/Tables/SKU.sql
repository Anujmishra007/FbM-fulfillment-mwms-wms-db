CREATE TABLE [dbo].[SKU]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DESCR] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_SUSR3] DEFAULT (' '),
[SUSR4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MANUFACTURERSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_MANUFACTURERSKU] DEFAULT (''),
[RETAILSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_RETAILSKU] DEFAULT (''),
[ALTSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ALTSKU] DEFAULT (''),
[PACKKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Packkey] DEFAULT ('STD'),
[STDGROSSWGT] [float] NOT NULL CONSTRAINT [DF_SKU_StdGrossWgt] DEFAULT ((0)),
[STDNETWGT] [float] NOT NULL CONSTRAINT [DF_SKU_StdNetWgt] DEFAULT ((0)),
[STDCUBE] [float] NOT NULL CONSTRAINT [DF_SKU_StdCube] DEFAULT ((0)),
[TARE] [float] NOT NULL CONSTRAINT [DF_SKU_Tare] DEFAULT ((0)),
[CLASS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Class] DEFAULT ('STD'),
[ACTIVE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_ACTIVE] DEFAULT ('1'),
[SKUGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_SKUGROUP] DEFAULT ('STD'),
[Tariffkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_Tariffkey] DEFAULT ('XXXXXXXXXX'),
[BUSR1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR4] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOTTABLE01LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE01LABEL] DEFAULT (' '),
[LOTTABLE02LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE02LABEL] DEFAULT (' '),
[LOTTABLE03LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE03LABEL] DEFAULT (' '),
[LOTTABLE04LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE04LABEL] DEFAULT (' '),
[LOTTABLE05LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE05LABEL] DEFAULT (' '),
[NOTES1] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTES2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_PickCode] DEFAULT ('NSPRPFIFO'),
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_StrategyKey] DEFAULT ('STD'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_CartonGroup] DEFAULT ('STD'),
[PutCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_PutCode] DEFAULT ('NSPPASTD'),
[PutawayLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_PutawayLoc] DEFAULT ('UNKNOWN'),
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_Putawayzone] DEFAULT ('BULK'),
[InnerPack] [int] NOT NULL CONSTRAINT [DF_SKU_InnerPack] DEFAULT ((0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_SKU_Cube] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_SKU_GrossWgt] DEFAULT ((0)),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_SKU_NetWgt] DEFAULT ((0)),
[ABC] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABC] DEFAULT ('B'),
[CycleCountFrequency] [int] NULL,
[LastCycleCount] [datetime] NULL,
[ReorderPoint] [int] NULL,
[ReorderQty] [int] NULL,
[StdOrderCost] [float] NULL,
[CarryCost] [float] NULL,
[Price] [money] NULL,
[Cost] [money] NULL,
[ReceiptHoldCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_ReceiptHoldCode] DEFAULT (' '),
[ReceiptInspectionLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_ReceiptInspectionLoc] DEFAULT ('QC'),
[OnReceiptCopyPackkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_OnReceiptCopyPackkey] DEFAULT ('0'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IOFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TareWeight] [float] NULL CONSTRAINT [DF_SKU_TareWeight] DEFAULT ((0)),
[LotxIdDetailOtherlabel1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LotxIdDetailOtherlabel1] DEFAULT ('Ser#'),
[LotxIdDetailOtherlabel2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LotxIdDetailOtherlabel2] DEFAULT ('CSID'),
[LotxIdDetailOtherlabel3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LotxIdDetailOtherlabel3] DEFAULT ('Other'),
[AvgCaseWeight] [float] NULL CONSTRAINT [DF_SKU_AvgCaseWeight] DEFAULT ((0)),
[TolerancePct] [float] NULL CONSTRAINT [DF_SKU_TolerancePct] DEFAULT ((0)),
[SkuStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_SkuStatus] DEFAULT ('ACTIVE'),
[Length] [float] NULL CONSTRAINT [DF_SKU_Length] DEFAULT ((0.00)),
[Width] [float] NULL CONSTRAINT [DF_SKU_Width] DEFAULT ((0.00)),
[Height] [float] NULL CONSTRAINT [DF_SKU_Height] DEFAULT ((0.00)),
[weight] [real] NULL,
[itemclass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_itemclass] DEFAULT (' '),
[ShelfLife] [int] NULL CONSTRAINT [DF_Sku_ShelfLife] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR6] DEFAULT (' '),
[BUSR7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR7] DEFAULT (' '),
[BUSR8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR8] DEFAULT (' '),
[BUSR9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR9] DEFAULT (' '),
[BUSR10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR10] DEFAULT (' '),
[ReturnLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_SKU_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_SKU_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_EditWho] DEFAULT (suser_sname()),
[archiveqty] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_archiveqty] DEFAULT ((0)),
[XDockReceiptLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrePackIndicator] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_PrePackIndicator] DEFAULT (' '),
[PackQtyIndicator] [int] NULL CONSTRAINT [DF_SKU_PackQtyIndicator] DEFAULT ((0)),
[StackFactor] [int] NULL CONSTRAINT [DF_SKU_StackFactor] DEFAULT ((0)),
[IVAS] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OVAS] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Style] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Style] DEFAULT (' '),
[Color] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Color] DEFAULT (''),
[Size] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Measurement] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HazardousFlag] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_HazardousFlag] DEFAULT (''),
[TemperatureFlag] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_TemperatureFlag] DEFAULT (''),
[ProductModel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ProductModel] DEFAULT (''),
[CtnPickQty] [int] NOT NULL CONSTRAINT [DF_SKU_CtnPickQty] DEFAULT ((0)),
[CountryOfOrigin] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_CountryOfOrigin] DEFAULT (''),
[IB_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_IB_UOM] DEFAULT (' '),
[IB_RPT_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_IB_RPT_UOM] DEFAULT (' '),
[OB_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_OB_UOM] DEFAULT (' '),
[OB_RPT_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_OB_RPT_UOM] DEFAULT (' '),
[ABCPL] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCPL] DEFAULT ('B'),
[ABCCS] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCCS] DEFAULT ('B'),
[ABCEA] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCEA] DEFAULT ('B'),
[DisableABCCalc] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_DisableABCCalc] DEFAULT ('N'),
[ABCPeriod] [int] NOT NULL CONSTRAINT [DF_SKU_ABCPeriod] DEFAULT ((0)),
[ABCStorerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCStorerkey] DEFAULT (' '),
[ABCSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCSku] DEFAULT (' '),
[OldStorerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_OldStorerkey] DEFAULT (' '),
[OldSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_OldSku] DEFAULT (' '),
[ImageFolder] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOTTABLE06LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE06LABEL] DEFAULT (''),
[LOTTABLE07LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE07LABEL] DEFAULT (''),
[LOTTABLE08LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE08LABEL] DEFAULT (''),
[LOTTABLE09LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE09LABEL] DEFAULT (''),
[LOTTABLE10LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE10LABEL] DEFAULT (''),
[LOTTABLE11LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE11LABEL] DEFAULT (''),
[LOTTABLE12LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE12LABEL] DEFAULT (''),
[LOTTABLE13LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE13LABEL] DEFAULT (''),
[LOTTABLE14LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE14LABEL] DEFAULT (''),
[LOTTABLE15LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE15LABEL] DEFAULT (''),
[LottableCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LottableCode] DEFAULT ('STD'),
[OTM_SKUGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_OTM_SKUGroup] DEFAULT (''),
[Pressure] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_Pressure] DEFAULT ('0'),
[SerialNoCapture] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_SerialNoCapture] DEFAULT (''),
[DataCapture] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_DataCapture] DEFAULT (''),
[EcomCartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_EcomCartonType] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[SKU] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[SKU] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SKU] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SKU] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SKU] TO [NSQL]
GO

ALTER TABLE [dbo].[SKU] ADD CONSTRAINT [PKSKU] PRIMARY KEY CLUSTERED ([StorerKey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_AltSku] ON [dbo].[SKU] ([ALTSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_BUSR5] ON [dbo].[SKU] ([BUSR5], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_BUSR6] ON [dbo].[SKU] ([BUSR6], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_BUSR7] ON [dbo].[SKU] ([BUSR7], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Color] ON [dbo].[SKU] ([Color]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_editdate] ON [dbo].[SKU] ([EditDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_ManufacturerSku] ON [dbo].[SKU] ([MANUFACTURERSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Measurement] ON [dbo].[SKU] ([Measurement]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_OTM_SKUGroup] ON [dbo].[SKU] ([OTM_SKUGroup], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_PackKey] ON [dbo].[SKU] ([PACKKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_PutawayZone] ON [dbo].[SKU] ([PutawayZone]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_RetailSKU] ON [dbo].[SKU] ([RETAILSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Size] ON [dbo].[SKU] ([Size]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SKU_SKU] ON [dbo].[SKU] ([Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SKU_CIdx] ON [dbo].[SKU] ([StorerKey], [BUSR5], [itemclass], [SKUGROUP], [Style], [Color], [Size], [Measurement]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Style] ON [dbo].[SKU] ([Style]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SKU] WITH NOCHECK ADD CONSTRAINT [FK_SKU_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stock Keeping Unit (SKU) is also called as an item number, commodity, or product code.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'ABC designation of the SKU where A - fast mover, B - average mover, C - slow mover. Used during putaway to direct fast moving commodities to the correct locations', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ABC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodities in the warehouse can be identified with a variety of labels, each referring to the product by a different name or item number', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ALTSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Estimated average weight for the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'AvgCaseWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product Group', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product bitmap file path - where the bitmap is kept', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cost the facility incurs to carry the inventory', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CarryCost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization. If this commodity does not use the cartonization function, create a standard cartonization code for commodities of this type', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'testing', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CLASS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity color e.g. red, yellow, white, black, blue etc', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Color'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Purchase prince for a master unit of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Cost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Pick Qty', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CtnPickQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of days between cycle counts for the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CycleCountFrequency'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Data capture upon inbound and/or outbound', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'DataCapture'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'DESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EcomCartonType', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'EcomCartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is the warehouse or DC in which the goods are residing', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Hazardous Code', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'HazardousFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Height'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Communicates to the system the time when weight capture should take place.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'IOFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the commodity class which is normally the department', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'itemclass'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Inbound value added services', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'IVAS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the last cycle count', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LastCycleCount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Length per inner pack', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Length'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE01LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE02LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE03LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE04LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE05LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Information that describes a particular commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LotxIdDetailOtherlabel1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Information that describes a particular commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LotxIdDetailOtherlabel2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Information that describes a particular commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LotxIdDetailOtherlabel3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity code the manufacturer uses to refer to the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'MANUFACTURERSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity measurement', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Measurement'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unlimited text field for entry of additional information about the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'NOTES1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unlimited text field for entry of additional information about the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'NOTES2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether the pack key used for receipt should be copied to the LOTTABLE01 field.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'OnReceiptCopyPackkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Outbound value added services', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'OVAS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'UOM identifying how the commodity is tracked', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PACKKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'It is used to sort the lots during replenishment candidate selection.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Retail price per master unit of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product Model', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ProductModel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway location for the commodity in the facility', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PutawayLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway zone in which the commodity is staged prior to actual putaway.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Algorithm that determines where the commodity is putaway during receiving process. The default is nspPASTd. Putaway strategy: This is setup at Support->Setup->Strategies->Putaway', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PutCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Hold code to use if commodity is placed on hold upon RF receipt.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReceiptHoldCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway algorithm will direct the product to this location for inspection/quality control purposes', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReceiptInspectionLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is the default receipt location which can be used by the system during the ASN Receipt or RDT Receive', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReceiptLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Minimum inventory level of the commodity for the facility. This field is not used for any logic processes in the system.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReorderPoint'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity that must be re-ordered when re-order point is reached', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReorderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity code retailers use to refer to the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'RETAILSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'During the return process, the system will use this location field to receive the stock return', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReturnLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Serial no capture', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SerialNoCapture'
GO
EXEC sp_addextendedproperty N'MS_Description', 'shelflife', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity size e.g. small, medium, large etc.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Size'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the commodity group which is normally the sub department', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SKUGROUP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies whether the commodity is active or inactive', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SkuStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the total number of block stack allowed', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StackFactor'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the default cube per unit in terms of eaches (Master Unit) for this commodity. Cube per unit in terms of eaches (Master Unit)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'STDCUBE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight per unit in terms of eaches', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'STDGROSSWGT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the net weight per unit in terms of eaches (Master Unit)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'STDNETWGT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cost to re-order the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StdOrderCost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the storer associated with the new Commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Master strategy which comprises of putaway, pre-allocation and allocation', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity style e.g. jackets, dress, pants, shorts, tops, blazers etc', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Style'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity shelf life that will be used to check the incoming stock. Number of days permitted before the expiration date or the number of days permitted after the manufacturing date.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer''s principal that manufactures the goods', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tolerance percentage for incoming receipt', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Variance allowed', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Difference between the net weight and the gross weight of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TareWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of tariff assigned to the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Tariffkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Temperature Code', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TemperatureFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Amount of difference allowed between the average case weight and the actual weight', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TolerancePct'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Width of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Width'
GO
EXEC sp_addextendedproperty N'MS_Description', 'During the crossdock process, the system will use this location field to receive the stock', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'XDockReceiptLoc'
GO
