IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'ORDERDETAIL_CANCLOG'
                 AND type = 'U')
    BEGIN

      CREATE TABLE [dbo].[ORDERDETAIL_CANCLOG]
         (
			   [LogId] [int] IDENTITY(1,1) NOT NULL,
         [OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
         [OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
         [OrderDetailSysId] [int] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_OrderDetailSysId] DEFAULT (rand()*(2147483647)),
         [ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ExternOrderKey] DEFAULT (' '),
         [ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ExternLineNo] DEFAULT (' '),
         [Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Sku] DEFAULT (' '),
         [StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_StorerKey] DEFAULT (' '),
         [ManufacturerSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ManufacturerSku] DEFAULT (' '),
         [RetailSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_RetailSku] DEFAULT (' '),
         [AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_AltSku] DEFAULT (' '),
         [OriginalQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_OriginalQty] DEFAULT ((0)),
         [OpenQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_OpenQty] DEFAULT ((0)),
         [ShippedQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ShippedQty] DEFAULT ((0)),
         [AdjustedQty] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_AdjustedQty] DEFAULT ((0)),
         [QtyPreAllocated] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_QtyPreAllocated] DEFAULT ((0)),
         [QtyAllocated] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_QtyAllocated] DEFAULT ((0)),
         [QtyPicked] [int] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_QtyPicked] DEFAULT ((0)),
         [UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_UOM] DEFAULT (' '),
         [PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_PackKey] DEFAULT ('STD'),
         [PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_PickCode] DEFAULT (' '),
         [CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_CartonGroup] DEFAULT (' '),
         [Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_LOT] DEFAULT (' '),
         [ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ID] DEFAULT (' '),
         [Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Facility] DEFAULT (' '),
         [Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Status] DEFAULT ('0'),
         [UnitPrice] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_UnitPrice] DEFAULT ((0)),
         [Tax01] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Tax01] DEFAULT ((0)),
         [Tax02] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Tax02] DEFAULT ((0)),
         [ExtendedPrice] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ExtendedPrice] DEFAULT ((0)),
         [UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_UpdateSource] DEFAULT ('0'),
         [Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_LOTTABLE01] DEFAULT (' '),
         [Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_LOTTABLE02] DEFAULT (' '),
         [Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_LOTTABLE03] DEFAULT (' '),
         [Lottable04] [datetime] NULL,
         [Lottable05] [datetime] NULL,
         [EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_EffectiveDate] DEFAULT (getdate()),
         [AddDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_AddDate] DEFAULT (getdate()),
         [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_AddWho] DEFAULT (suser_sname()),
         [EditDate] [datetime] NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_EditDate] DEFAULT (getdate()),
         [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_EditWho] DEFAULT (suser_sname()),
         [TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [FreeGoodQty] [int] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_FreeGoodQty] DEFAULT ((0)),
         [GrossWeight] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_GROSSWEIGHT] DEFAULT ((0)),
         [Capacity] [float] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_CAPACITY] DEFAULT ((0)),
         [LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [QtyToProcess] [int] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_QtyToProcess] DEFAULT ((0)),
         [MinShelfLife] [int] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_MinShelfLife] DEFAULT ((0)),
         [UserDefine01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine04] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine05] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine06] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine07] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine08] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine09] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [POkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [UserDefine10] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [EnteredQTY] [int] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_EnteredQTY] DEFAULT ((0)),
         [ConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
         [ExternConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ExternConsoOrderKey] DEFAULT (' '),
         [ConsoOrderLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_ConsoOrderLineNo] DEFAULT (''),
         [Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Lottable06] DEFAULT (''),
         [Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Lottable07] DEFAULT (''),
         [Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Lottable08] DEFAULT (''),
         [Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Lottable09] DEFAULT (''),
         [Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Lottable10] DEFAULT (''),
         [Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Lottable11] DEFAULT (''),
         [Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Lottable12] DEFAULT (''),
         [Lottable13] [datetime] NULL,
         [Lottable14] [datetime] NULL,
         [Lottable15] [datetime] NULL,
         [Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Notes] DEFAULT (''),
         [Notes2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Notes2] DEFAULT (''),
         [Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_Channel] DEFAULT (''),
         [HashValue] [tinyint] NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_HashValue] DEFAULT ((1)),
         [SalesChannel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERDETAIL_CANCLOG_SalesChannel] DEFAULT (''),
         [CancelReasonCode] [nvarchar](60) NULL
         ) ON [PRIMARY]

         ALTER TABLE [dbo].[ORDERDETAIL_CANCLOG] ADD CONSTRAINT [PKORDERDETAIL_CANCLOG] PRIMARY KEY CLUSTERED ([LogId]) WITH (FILLFACTOR=90) ON [PRIMARY]

         CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_CANCLOG_ConsoOrderKey] ON [dbo].[ORDERDETAIL_CANCLOG] ([ConsoOrderKey], [ConsoOrderLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]

         CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_CANCLOG_ExtOrdKey] ON [dbo].[ORDERDETAIL_CANCLOG] ([ExternOrderKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]

         CREATE NONCLUSTERED INDEX [ORDERDETAIL_CANCLOG6] ON [dbo].[ORDERDETAIL_CANCLOG] ([LoadKey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]

         CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_CANCLOG_MbolKey] ON [dbo].[ORDERDETAIL_CANCLOG] ([MBOLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

         CREATE NONCLUSTERED INDEX [IX_ORDERDETAIL_CANCLOG_SKU] ON [dbo].[ORDERDETAIL_CANCLOG] ([StorerKey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]

         EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'AddDate'

         EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'AddWho'

         EXEC sp_addextendedproperty N'MS_Description', 'Adjustedqty', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'AdjustedQty'

         EXEC sp_addextendedproperty N'MS_Description', 'Altsku', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'AltSku'

         EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ArchiveCop'

         EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Capacity'

         EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'CartonGroup'

         EXEC sp_addextendedproperty N'MS_Description', 'Consolidated order key', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ConsoOrderKey'

         EXEC sp_addextendedproperty N'MS_Description', 'Consolidated order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ConsoOrderLineNo'

         EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'EditDate'

         EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'EditWho'

         EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'EffectiveDate'

         EXEC sp_addextendedproperty N'MS_Description', 'Entered quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'EnteredQTY'

         EXEC sp_addextendedproperty N'MS_Description', 'Extended price', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ExtendedPrice'

         EXEC sp_addextendedproperty N'MS_Description', 'External consolidated order key', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ExternConsoOrderKey'

         EXEC sp_addextendedproperty N'MS_Description', 'External order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ExternLineNo'

         EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ExternOrderKey'

         EXEC sp_addextendedproperty N'MS_Description', 'Customer''s Purchase Order number. It is used to link ASN with order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ExternPOKey'

         EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Facility'

         EXEC sp_addextendedproperty N'MS_Description', 'FOC quantity attached to the line item', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'FreeGoodQty'

         EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'GrossWeight'

         EXEC sp_addextendedproperty N'MS_Description', 'ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ID'

         EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to a Load or when it''s moved to a new Load', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'LoadKey'

         EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lot'

         EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 01. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable01'

         EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 02. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable02'

         EXEC sp_addextendedproperty N'MS_Description', 'Storer defined lottable 03. Use for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable03'

         EXEC sp_addextendedproperty N'MS_Description', 'Product expiry date which will be used as one of the criterias for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable04'

         EXEC sp_addextendedproperty N'MS_Description', 'Product receipt date which will be used as one of the criterias for allocation', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable05'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable06'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable07'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable08'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable09'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable10'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable11'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable12'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable13'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable14'

         EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Lottable15'

         EXEC sp_addextendedproperty N'MS_Description', 'Manufacturer SKU', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ManufacturerSku'

         EXEC sp_addextendedproperty N'MS_Description', 'Updated when the Shipment Order is attached to an MBOL or when it''s moved to a new MBOL', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'MBOLKey'

         EXEC sp_addextendedproperty N'MS_Description', 'Minimum number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'MinShelfLife'

         EXEC sp_addextendedproperty N'MS_Description', 'Additional information', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Notes'

         EXEC sp_addextendedproperty N'MS_Description', 'Additional information', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Notes2'

         EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'OpenQty'

         EXEC sp_addextendedproperty N'MS_Description', 'Order detail system ID', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'OrderDetailSysId'

         EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'OrderKey'

         EXEC sp_addextendedproperty N'MS_Description', 'Order detail line number. System generated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'OrderLineNumber'

         EXEC sp_addextendedproperty N'MS_Description', 'Original quantity', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'OriginalQty'

         EXEC sp_addextendedproperty N'MS_Description', 'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen. Changeable', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'PackKey'

         EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'PickCode'

         EXEC sp_addextendedproperty N'MS_Description', 'WMS Purchase Order number. It is used to process Crossdock orders, linking ASN with the order', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'POkey'

         EXEC sp_addextendedproperty N'MS_Description', 'Quantity allocated', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'QtyAllocated'

         EXEC sp_addextendedproperty N'MS_Description', 'Quantity picked', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'QtyPicked'

         EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product that has been pre-allocated from the lot associated to the product.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'QtyPreAllocated'

         EXEC sp_addextendedproperty N'MS_Description', 'Qty To Process', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'QtyToProcess'

         EXEC sp_addextendedproperty N'MS_Description', 'Retail SKU', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'RetailSku'

         EXEC sp_addextendedproperty N'MS_Description', N'Distribution channels like wholesalers, retailers, distributors along with Orders', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'SalesChannel'

         EXEC sp_addextendedproperty N'MS_Description', 'Quantity shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'ShippedQty'

         EXEC sp_addextendedproperty N'MS_Description', 'The SKU being ordered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Sku'

         EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Status'

         EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'StorerKey'

         EXEC sp_addextendedproperty N'MS_Description', 'The pricing model assigned to the SKU that defines the rates and method of billing for storage and associated charges', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'TariffKey'

         EXEC sp_addextendedproperty N'MS_Description', 'Tax ID 01', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Tax01'

         EXEC sp_addextendedproperty N'MS_Description', 'Tax ID 02', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'Tax02'

         EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'TrafficCop'

         EXEC sp_addextendedproperty N'MS_Description', 'Price per unit of the product ordered', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UnitPrice'

         EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UOM'

         EXEC sp_addextendedproperty N'MS_Description', 'Source update', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UpdateSource'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine01'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine02'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine03'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine04'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine05'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine06', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine06'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine07', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine07'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine08'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine09'

         EXEC sp_addextendedproperty N'MS_Description', 'ORDERDETAIL_CANCLOG Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'UserDefine10'

         EXEC sp_addextendedproperty N'MS_Description', 'The reason why an order detail is cancelled', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'CancelReasonCode'

			EXEC sp_addextendedproperty N'MS_Description', 'Unique integer identifying Logs.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERDETAIL_CANCLOG', 'COLUMN', N'LogID'

END
   GRANT SELECT ON  [dbo].[ORDERDETAIL_CANCLOG] TO [JReportRole]

   GRANT DELETE ON  [dbo].[ORDERDETAIL_CANCLOG] TO [NSQL]

   GRANT INSERT ON  [dbo].[ORDERDETAIL_CANCLOG] TO [NSQL]

   GRANT SELECT ON  [dbo].[ORDERDETAIL_CANCLOG] TO [NSQL]

   GRANT UPDATE ON  [dbo].[ORDERDETAIL_CANCLOG] TO [NSQL]
