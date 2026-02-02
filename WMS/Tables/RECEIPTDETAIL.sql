IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'RECEIPTDETAIL'
                 AND type = 'U')
 BEGIN
        CREATE TABLE [dbo].[RECEIPTDETAIL]
            (
            [ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
            [ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
            [ExternReceiptKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_ExternReceiptKey] DEFAULT (' '),
            [ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_ExternLineNo] DEFAULT (' '),
            [StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_StorerKey] DEFAULT (' '),
            [POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_POKey] DEFAULT (' '),
            [Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Sku] DEFAULT (' '),
            [AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_AltSku] DEFAULT (' '),
            [Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Id] DEFAULT (' '),
            [Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Status] DEFAULT ('0'),
            [DateReceived] [datetime] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_DateReceived] DEFAULT (getdate()),
            [QtyExpected] [int] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_QtyExpected] DEFAULT ((0)),
            [QtyAdjusted] [int] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_QtyAdjusted] DEFAULT ((0)),
            [QtyReceived] [int] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_QtyReceived] DEFAULT ((0)),
            [UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_UOM] DEFAULT (' '),
            [PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_PackKey] DEFAULT ('STD'),
            [VesselKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_VesselKey] DEFAULT (' '),
            [VoyageKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_VoyageKey] DEFAULT (' '),
            [XdockKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_XdockKey] DEFAULT (' '),
            [ContainerKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_ContainerKey] DEFAULT (' '),
            [ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
            [ToLot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [ToId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_ToId] DEFAULT (' '),
            [ConditionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_ConditionCode] DEFAULT ('OK'),
            [Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_LOTTABLE01] DEFAULT (' '),
            [Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_LOTTABLE02] DEFAULT (' '),
            [Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_LOTTABLE03] DEFAULT (' '),
            [Lottable04] [datetime] NULL,
            [Lottable05] [datetime] NULL,
            [CaseCnt] [int] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_CaseCnt] DEFAULT ((0)),
            [InnerPack] [int] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Innerpack] DEFAULT ((0)),
            [Pallet] [int] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Pallet] DEFAULT ((0)),
            [Cube] [float] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Cube] DEFAULT ((0)),
            [GrossWgt] [float] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_GrossWgt] DEFAULT ((0)),
            [NetWgt] [float] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_NetWgt] DEFAULT ((0)),
            [OtherUnit1] [float] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_OtherUnit1] DEFAULT ((0)),
            [OtherUnit2] [float] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_OtherUnit2] DEFAULT ((0)),
            [UnitPrice] [float] NULL CONSTRAINT [DF_RECEIPTDETAIL_UnitPrice] DEFAULT ((0)),
            [ExtendedPrice] [float] NULL CONSTRAINT [DF_RECEIPTDETAIL_ExtendedPrice] DEFAULT ((0)),
            [EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_EffectiveDate] DEFAULT (getdate()),
            [AddDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_AddDate] DEFAULT (getdate()),
            [AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_AddWho] DEFAULT (suser_sname()),
            [EditDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_EditDate] DEFAULT (getdate()),
            [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_EditWho] DEFAULT (suser_sname()),
            [TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [FreeGoodQtyExpected] [int] NULL CONSTRAINT [DF_RECEIPTDETAIL_FreeGoodQtyExpected] DEFAULT ((0)),
            [FreeGoodQtyReceived] [int] NULL CONSTRAINT [DF_RECEIPTDETAIL_FreeGoodQtyReceived] DEFAULT ((0)),
            [SubReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_SubReasonCode] DEFAULT (' '),
            [FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_FinalizeFlag] DEFAULT ('N'),
            [DuplicateFrom] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [BeforeReceivedQty] [int] NULL CONSTRAINT [DF_RECEIPTDETAIL_BeforeReceivedQty] DEFAULT ((0)),
            [PutawayLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_PutawayLoc] DEFAULT (' '),
            [ExportStatus] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_ExportStatus] DEFAULT ('0'),
            [SplitPalletFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_SplitPalletFlag] DEFAULT ('N'),
            [POLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_POLineNumber] DEFAULT (' '),
            [LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
            [ExternPoKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_ExternPoKey] DEFAULT (''),
            [UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine01] DEFAULT (' '),
            [UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine02] DEFAULT (' '),
            [UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine03] DEFAULT (' '),
            [UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine04] DEFAULT (' '),
            [UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine05] DEFAULT (' '),
            [UserDefine06] [datetime] NULL,
            [UserDefine07] [datetime] NULL,
            [UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine08] DEFAULT (' '),
            [UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine09] DEFAULT (' '),
            [UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ReceiptDetail_UserDefine10] DEFAULT (' '),
            [Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Lottable06] DEFAULT (' '),
            [Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Lottable07] DEFAULT (' '),
            [Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Lottable08] DEFAULT (' '),
            [Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Lottable09] DEFAULT (' '),
            [Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Lottable10] DEFAULT (' '),
            [Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Lottable11] DEFAULT (' '),
            [Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_Lottable12] DEFAULT (' '),
            [Lottable13] [datetime] NULL,
            [Lottable14] [datetime] NULL,
            [Lottable15] [datetime] NULL,
            [Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPTDETAIL_Channel] DEFAULT (''),
            [Channel_ID] [bigint] NULL CONSTRAINT [DF_RECEIPTDETAIL_Channel_ID] DEFAULT ((0)),
            [RowVer] [timestamp] NOT NULL,
            [PalletType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_PalletType] DEFAULT (''),
            [Notes] [nvarchar] (500) NULL CONSTRAINT DF_RECEIPTDETAIL_Notes DEFAULT (''),
            [Notes2] [nvarchar] (500) NULL CONSTRAINT DF_RECEIPTDETAIL_Notes2 DEFAULT (''),

            ) ON [PRIMARY]

            ALTER TABLE [dbo].[RECEIPTDETAIL] ADD CONSTRAINT [PKReceiptDetail] PRIMARY KEY CLUSTERED ([ReceiptKey], [ReceiptLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]

            CREATE NONCLUSTERED INDEX [IX_RECEIPTDETAIL_ExternReceiptKey] ON [dbo].[RECEIPTDETAIL] ([ExternReceiptKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

            CREATE NONCLUSTERED INDEX [IX_RECEIPTDETAIL_PO] ON [dbo].[RECEIPTDETAIL] ([POKey], [POLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]

            CREATE NONCLUSTERED INDEX [RECEIPTDETAIL3] ON [dbo].[RECEIPTDETAIL] ([ReceiptKey], [ReceiptLineNumber], [QtyReceived], [BeforeReceivedQty]) WITH (FILLFACTOR=90) ON [PRIMARY]

            CREATE NONCLUSTERED INDEX [IX_RECEIPTDETAIL_STSKLot02XRecKey] ON [dbo].[RECEIPTDETAIL] ([StorerKey], [Sku], [Lottable02], [ExternPoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]

            CREATE NONCLUSTERED INDEX [IDX_RECEIPTDETAIL_UsrDef08_UsrDef09] ON [dbo].[RECEIPTDETAIL] ([UserDefine08], [UserDefine09], [StorerKey]) ON [PRIMARY]

            ALTER TABLE [dbo].[RECEIPTDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_RECEIPTDETAIL_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])

            EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'AddDate'

            EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'AddWho'

            EXEC sp_addextendedproperty N'MS_Description', 'Alternate SKU which refers to the same SKU having more than one SKU code', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'AltSku'

            EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ArchiveCop'

            EXEC sp_addextendedproperty N'MS_Description', 'Quantity before received', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'BeforeReceivedQty'

            EXEC sp_addextendedproperty N'MS_Description', 'total case count', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'CaseCnt'

            EXEC sp_addextendedproperty N'MS_Description', N'Channel of Invenotry', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Channel'

            EXEC sp_addextendedproperty N'MS_Description', N'Channel ID Running Number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Channel_ID'

            EXEC sp_addextendedproperty N'MS_Description', 'The inventory condition upon arrival at the warehouse', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ConditionCode'

            EXEC sp_addextendedproperty N'MS_Description', 'Item account number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ContainerKey'

            EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Cube'

            EXEC sp_addextendedproperty N'MS_Description', 'Date that the line item was received. If you receive part of the order at a later date, this date does not change.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'DateReceived'

            EXEC sp_addextendedproperty N'MS_Description', 'Duplicate from', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'DuplicateFrom'

            EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'EditDate'

            EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'EditWho'

            EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'EffectiveDate'

            EXEC sp_addextendedproperty N'MS_Description', 'Export status', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ExportStatus'

            EXEC sp_addextendedproperty N'MS_Description', 'Extended price', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ExtendedPrice'

            EXEC sp_addextendedproperty N'MS_Description', 'Customer ASN detail line number that will be imported into WMS', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ExternLineNo'

            EXEC sp_addextendedproperty N'MS_Description', 'Externpokey', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ExternPoKey'

            EXEC sp_addextendedproperty N'MS_Description', 'Customer Receipt No that will be imported into WMS', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ExternReceiptKey'

            EXEC sp_addextendedproperty N'MS_Description', 'Finalize flag', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'FinalizeFlag'

            EXEC sp_addextendedproperty N'MS_Description', 'Indicate the expected quantity of free goods (on top of expected inventory) to be received', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'FreeGoodQtyExpected'

            EXEC sp_addextendedproperty N'MS_Description', 'The actual free goods quantity received', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'FreeGoodQtyReceived'

            EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'GrossWgt'

            EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Id'

            EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'InnerPack'

            EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'LoadKey'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable01 - depends on Commodity lottable label01 set-up', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable01'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable02 - depends on Commodity lottable label02 set-up', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable02'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable03 - depends on Commodity lottable label03 set-up', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable03'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable04 - manufacturing date/expiry date', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable04'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable05 - receipt date', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable05'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable06'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable07'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable08'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable09'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable10'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable11'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable12'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable13'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable14'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Lottable15'

            EXEC sp_addextendedproperty N'MS_Description', 'Net weight', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'NetWgt'

            EXEC sp_addextendedproperty N'MS_Description', 'Total quantity not found in the actual receiving', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'OtherUnit1'

            EXEC sp_addextendedproperty N'MS_Description', 'Total quantity not found in the actual receiving 2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'OtherUnit2'

            EXEC sp_addextendedproperty N'MS_Description', 'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen. Changeable', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'PackKey'

            EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or a pallet jack to lift, move and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Pallet'

            EXEC sp_addextendedproperty N'MS_Description', 'PO #', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'POKey'

            EXEC sp_addextendedproperty N'MS_Description', 'Detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'POLineNumber'

            EXEC sp_addextendedproperty N'MS_Description', 'The final putaway location for the inventory received', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'PutawayLoc'

            EXEC sp_addextendedproperty N'MS_Description', 'Quantity adjusted', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'QtyAdjusted'

            EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently expected in the location.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'QtyExpected'

            EXEC sp_addextendedproperty N'MS_Description', 'Quantity received', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'QtyReceived'

            EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying receipt.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ReceiptKey'

            EXEC sp_addextendedproperty N'MS_Description', 'ASN detail line number. System generated', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ReceiptLineNumber'

            EXEC sp_addextendedproperty N'MS_Description', N'TIMESTAMP column as automatic initialization and updating in record row', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'RowVer'

            EXEC sp_addextendedproperty N'MS_Description', 'The SKU being received', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Sku'

            EXEC sp_addextendedproperty N'MS_Description', 'Split pallet flag', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'SplitPalletFlag'

            EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'Status'

            EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'StorerKey'

            EXEC sp_addextendedproperty N'MS_Description', 'SubReasonCode', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'SubReasonCode'

            EXEC sp_addextendedproperty N'MS_Description', 'Billing tariff for the SKU', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'TariffKey'

            EXEC sp_addextendedproperty N'MS_Description', 'Pallet ID in which the SKU will be placed on', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ToId'

            EXEC sp_addextendedproperty N'MS_Description', 'Location of the goods after putaway. If your facility is using RDT putaway, enter the default receiving location', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ToLoc'

            EXEC sp_addextendedproperty N'MS_Description', 'Lot number assigned by the system to the Commodity will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'ToLot'

            EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'TrafficCop'

            EXEC sp_addextendedproperty N'MS_Description', 'Unit price', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UnitPrice'

            EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be received', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UOM'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine01'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine02'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #3', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine03'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #4', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine04'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #5', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine05'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #6', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine06'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #7', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine07'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #8', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine08'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #9', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine09'

            EXEC sp_addextendedproperty N'MS_Description', 'User defined field #10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'UserDefine10'

            EXEC sp_addextendedproperty N'MS_Description', 'To indicate which warehouse the goods are from.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'VesselKey'

            EXEC sp_addextendedproperty N'MS_Description', 'To indicate which location the goods are coming from', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'VoyageKey'

            EXEC sp_addextendedproperty N'MS_Description', 'Customer invoice number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'XdockKey'

            EXEC sp_addextendedproperty N'MS_Description', 'Pallet Type' , 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN',N'PalletType'

            EXEC sp_addextendedproperty N'MS_Description', 'Additional information' , 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN',N'Notes'

            EXEC sp_addextendedproperty N'MS_Description', 'Additional information' , 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN',N'Notes2'

END
ELSE
BEGIN
        IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'PalletType' AND Object_ID = Object_ID('RECEIPTDETAIL'))
        BEGIN
            ALTER TABLE RECEIPTDETAIL ADD PalletType NVARCHAR(10) NOT NULL CONSTRAINT [DF_RECEIPTDETAIL_PalletType] DEFAULT ('');
            EXEC sp_addextendedproperty N'MS_Description', 'Pallet Type', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN', N'PalletType'
        END

       IF NOT EXISTS ( SELECT * FROM sys.columns WHERE Name = 'Notes' AND Object_ID = Object_ID('RECEIPTDETAIL'))
       BEGIN
            ALTER TABLE RECEIPTDETAIL ADD Notes NVARCHAR(500) NULL CONSTRAINT [DF_RECEIPTDETAIL_Notes] DEFAULT ('');
            EXEC sp_addextendedproperty N'MS_Description', 'Additional information' , 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN',N'Notes'
       END

       IF NOT EXISTS ( SELECT * FROM sys.columns WHERE Name = 'Notes2' AND Object_ID = Object_ID('RECEIPTDETAIL'))
       BEGIN
            ALTER TABLE RECEIPTDETAIL ADD Notes2 NVARCHAR(500) NULL CONSTRAINT [DF_RECEIPTDETAIL_Notes2] DEFAULT ('');
            EXEC sp_addextendedproperty N'MS_Description', 'Additional information' , 'SCHEMA', N'dbo', 'TABLE', N'RECEIPTDETAIL', 'COLUMN',N'Notes2'
       END
END


GRANT INSERT ON  [dbo].[RECEIPTDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RECEIPTDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RECEIPTDETAIL] TO [NSQL]
GO
