CREATE TABLE [dbo].[TRANSFERDETAIL]
(
[TransferKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransferLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromStorerKey] DEFAULT (' '),
[FromSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromSku] DEFAULT (' '),
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromLoc] DEFAULT (' '),
[FromLot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromLot] DEFAULT (' '),
[FromId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromId] DEFAULT (' '),
[FromQty] [int] NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromQty] DEFAULT ((0)),
[FromPackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromPackKey] DEFAULT ('STD'),
[FromUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_FromUOM] DEFAULT (' '),
[LOTTABLE01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_LOTTABLE01] DEFAULT (' '),
[LOTTABLE02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_LOTTABLE02] DEFAULT (' '),
[LOTTABLE03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_LOTTABLE03] DEFAULT (' '),
[LOTTABLE04] [datetime] NULL,
[LOTTABLE05] [datetime] NULL,
[ToStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToStorerKey] DEFAULT (' '),
[ToSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToSku] DEFAULT (' '),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLoc] DEFAULT (' '),
[ToLot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLot] DEFAULT (' '),
[ToId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToId] DEFAULT (' '),
[ToQty] [int] NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToQty] DEFAULT ((0)),
[ToPackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToPackKey] DEFAULT ('STD'),
[ToUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_ToUOM] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Status] DEFAULT ('0'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[tolottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_tolottable01] DEFAULT (' '),
[tolottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_tolottable02] DEFAULT (' '),
[tolottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_tolottable03] DEFAULT (' '),
[tolottable04] [datetime] NULL,
[tolottable05] [datetime] NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_UserDefine10] DEFAULT (' '),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TRANSFERDETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[ToLottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLottable06] DEFAULT (''),
[ToLottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLottable07] DEFAULT (''),
[ToLottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLottable08] DEFAULT (''),
[ToLottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLottable09] DEFAULT (''),
[ToLottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLottable10] DEFAULT (''),
[ToLottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLottable11] DEFAULT (''),
[ToLottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToLottable12] DEFAULT (''),
[ToLottable13] [datetime] NULL,
[ToLottable14] [datetime] NULL,
[ToLottable15] [datetime] NULL,
[FromChannel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_FromChannel] DEFAULT (''),
[ToChannel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TRANSFERDETAIL_ToChannel] DEFAULT (''),
[FromChannel_ID] [bigint] NULL CONSTRAINT [DF_TRANSFERDETAIL_FromChannel_ID] DEFAULT ((0)),
[ToChannel_ID] [bigint] NULL CONSTRAINT [DF_TRANSFERDETAIL_ToChannel_ID] DEFAULT ((0))
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TRANSFERDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TRANSFERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TRANSFERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TRANSFERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TRANSFERDETAIL] TO [NSQL]
GO

ALTER TABLE [dbo].[TRANSFERDETAIL] ADD CONSTRAINT [CK_TRFDET_Status] CHECK ((rtrim([Status]) like '[0-9]' OR rtrim([Status])='CANC'))
GO
ALTER TABLE [dbo].[TRANSFERDETAIL] ADD CONSTRAINT [PKTRANSFERDETAIL] PRIMARY KEY CLUSTERED ([TransferKey], [TransferLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TRANSFERDETAIL] ADD CONSTRAINT [FK_TRFDET_LOC_01] FOREIGN KEY ([FromLoc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[TRANSFERDETAIL] ADD CONSTRAINT [FK_TRFDET_LOC_02] FOREIGN KEY ([ToLoc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[TRANSFERDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_TRFDET_SKU_01] FOREIGN KEY ([FromStorerKey], [FromSku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
ALTER TABLE [dbo].[TRANSFERDETAIL] WITH NOCHECK ADD CONSTRAINT [FK_TRFDET_SKU_02] FOREIGN KEY ([ToStorerKey], [ToSku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'pallet id or case id', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Physical location of the product in the facility', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot number assigned by the system to the Commodity being transferred', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromLot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack key that are available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromPackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product to be transferred in the Master UOM', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity being transferred', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer from whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'FromUOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable01 - depends on Commodity lottable label01 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'LOTTABLE01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable02 - depends on Commodity lottable label02 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'LOTTABLE02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable03 - depends on Commodity lottable label03 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'LOTTABLE03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable04 - manufacturing date/expiry date', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'LOTTABLE04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable05 - receipt date', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'LOTTABLE05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'Timestamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet id/case id where the Commodity will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location where the Commodity will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot number assigned by the system to the Commodity will be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable01 - depends on Commodity lottable label01 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'tolottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable02 - depends on Commodity lottable label02 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'tolottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable03 - depends on Commodity lottable label03 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'tolottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable04 - manufacturing date/expiry date', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'tolottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable05 - receipt date', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'tolottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label06 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label07 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label08 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label09 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label10 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label11 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label12 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label13 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label14 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06 - depends on Commodity lottable label15 set-up', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToLottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack codes that are available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToPackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Final quantity value of the transferred commodity', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity to be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer to whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'ToUOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Transfer.', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'TransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'TransferLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'License plate that identify the specific information about the cartons or pallets', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'License plate that identify the specific information about the cartons or pallets', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine06 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine07(datetime)', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TFDL_Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'TRANSFERDETAIL', 'COLUMN', N'UserDefine10'
GO
