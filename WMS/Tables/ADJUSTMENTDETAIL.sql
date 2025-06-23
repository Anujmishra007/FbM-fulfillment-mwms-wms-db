IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'ADJUSTMENTDETAIL' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[ADJUSTMENTDETAIL]
(
[AdjustmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdjustmentLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Loc] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lot] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Id] DEFAULT (' '),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_ReasonCode] DEFAULT ('0'),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UOM] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_PackKey] DEFAULT ('STD'),
[Qty] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Qty] DEFAULT ((0)),
[CaseCnt] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_CaseCnt] DEFAULT ((0)),
[InnerPack] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_InnerPack] DEFAULT ((0)),
[Pallet] [int] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Pallet] DEFAULT ((0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Cube] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_GrossWgt] DEFAULT ((0)),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_NetWgt] DEFAULT ((0)),
[OtherUnit1] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_OtherUnit1] DEFAULT ((0)),
[OtherUnit2] [float] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_OtherUnit2] DEFAULT ((0)),
[ItrnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_ItrnKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [timestamp] NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UserDefine10] DEFAULT (' '),
[FinalizedFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_FinalizedFlag] DEFAULT ('N'),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_UCCNo] DEFAULT (''),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ADJUSTMENTDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AdjustmentDetail_Channel] DEFAULT (''),
[Channel_ID] [bigint] NULL CONSTRAINT [DF_AdjustmentDetail_Channel_ID] DEFAULT ((0)),
[SerialNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AdjustmentDetail_Serial_No] DEFAULT (''),
[PalletType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_AdjustmentDetail_PalletType] DEFAULT ('')

) ON [PRIMARY]

GRANT SELECT ON  [dbo].[ADJUSTMENTDETAIL] TO [JReportRole]

GRANT DELETE ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]

GRANT INSERT ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]

GRANT SELECT ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]

GRANT UPDATE ON  [dbo].[ADJUSTMENTDETAIL] TO [NSQL]

ALTER TABLE [dbo].[ADJUSTMENTDETAIL] ADD CONSTRAINT [PKAdjustmentDetail] PRIMARY KEY CLUSTERED ([AdjustmentKey], [AdjustmentLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]

ALTER TABLE [dbo].[ADJUSTMENTDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_ADJUSTMENTDETAIL_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Adjustment.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AdjustmentKey'

EXEC sp_addextendedproperty N'MS_Description', 'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'AdjustmentLineNumber'

EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'ArchiveCop'

EXEC sp_addextendedproperty N'MS_Description', 'total case count', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'CaseCnt'

EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Cube'

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'EffectiveDate'

EXEC sp_addextendedproperty N'MS_Description', 'confirm the adjustment by detail line', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'FinalizedFlag'

EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'GrossWgt'

EXEC sp_addextendedproperty N'MS_Description', 'pallet id of the goods to be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Id'

EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'InnerPack'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Inventory Transaction.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'ItrnKey'

EXEC sp_addextendedproperty N'MS_Description', 'physical location of the goods to be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Loc'

EXEC sp_addextendedproperty N'MS_Description', 'lot number associated with the product being adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lot'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable01 - depends on Commodity lottable label01 set-up', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable01'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable02 - depends on Commodity lottable label02 set-up', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable02'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable03 - depends on Commodity lottable label03 set-up', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable03'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable04 - manufacturing date/expiry date', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable04'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable05 - receipt date', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable05'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable06'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable07'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable08'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable09'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable10'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable11'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable12'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable13'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable14'

EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Lottable15'

EXEC sp_addextendedproperty N'MS_Description', 'Net weight', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'NetWgt'

EXEC sp_addextendedproperty N'MS_Description', 'Total quantity not found in the actual receiving 1', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'OtherUnit1'

EXEC sp_addextendedproperty N'MS_Description', 'Total quantity not found in the actual receiving 2', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'OtherUnit2'

EXEC sp_addextendedproperty N'MS_Description', 'Pack key of the SKU', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'PackKey'

EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or pallet jack to lift, move, and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Pallet'

EXEC sp_addextendedproperty N'MS_Description', 'unit of quantity to be adjusted for the sku', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Qty'

EXEC sp_addextendedproperty N'MS_Description', 'reason code to be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'ReasonCode'

EXEC sp_addextendedproperty N'MS_Description', 'SKU being adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'Sku'

EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the storer record.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'StorerKey'

EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'TimeStamp'

EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'TrafficCop'

EXEC sp_addextendedproperty N'MS_Description', 'A unique number to identify the carton or pallet which is standard and will be used from suppliers to customers', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UCCNo'

EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be adjusted', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UOM'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine01'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine02'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine03'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine04'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine05'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine06 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine06'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine07 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine07'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine08'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine09'

EXEC sp_addextendedproperty N'MS_Description', 'adjusment detail Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'UserDefine10'

EXEC sp_addextendedproperty N'MS_Description', 'adjustment detail SerialNo', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'SerialNo'

EXEC sp_addextendedproperty N'MS_Description', 'adjustment detail Pallet Type' , 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN',N'PalletType'
END
ELSE 
BEGIN
IF NOT EXISTS (SELECT 1
		               FROM sys.columns
		               WHERE Name = 'SerialNo' AND Object_ID = Object_ID('ADJUSTMENTDETAIL'))
				BEGIN
					ALTER TABLE ADJUSTMENTDETAIL ADD SerialNo [nvarchar] (50) NOT NULL CONSTRAINT [DF_AdjustmentDetail_Serial_No] DEFAULT ('');
					EXEC sp_addextendedproperty N'MS_Description', 'adjustment detail SerialNo', 'SCHEMA', N'dbo', 'TABLE', N'ADJUSTMENTDETAIL', 'COLUMN', N'SerialNo'
				END
 IF NOT EXISTS (SELECT *
                       FROM sys.columns
                       WHERE Name = 'PalletType'
                         AND Object_ID = Object_ID('ADJUSTMENTDETAIL'))
            BEGIN
                ALTER TABLE ADJUSTMENTDETAIL
                    ADD PalletType NVARCHAR(10) NOT NULL CONSTRAINT [DF_AdjustmentDetail_PalletType] DEFAULT ('');
                EXEC sp_addextendedproperty N'MS_Description', 'adjustment detail Pallet Type', 'SCHEMA', N'dbo', 'TABLE',
                     N'ADJUSTMENTDETAIL', 'COLUMN', N'PalletType'
            END
END
