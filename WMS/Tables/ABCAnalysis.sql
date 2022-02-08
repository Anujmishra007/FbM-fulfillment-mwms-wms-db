CREATE TABLE [dbo].[ABCAnalysis]
(
[SerialKey] [bigint] NOT NULL IDENTITY(1, 1),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ABCAnalysis_Facility] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ABCAnalysis_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ABCAnalysis_Sku] DEFAULT (' '),
[Description] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUCost] [money] NULL,
[SKUCube] [numeric] (18, 3) NULL,
[BUSR1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR4] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUChangeFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUABCStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCAnalysis_SKUABCStatus] DEFAULT ('0'),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCAnalysis_PackKey] DEFAULT (''),
[CaseCnt] [numeric] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_CaseCnt] DEFAULT ((0.00)),
[Pallet] [numeric] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_Pallet] DEFAULT ((0.00)),
[CubeUOM3] [numeric] (18, 5) NULL,
[Qty] [int] NULL CONSTRAINT [DF_ABCAnalysis_Qty] DEFAULT ((0)),
[PickFaceSizeMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkuRank] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_SKURank] DEFAULT ((0.00)),
[NoOfPick] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_NoOfPick] DEFAULT ((0.00)),
[PercentageOfPick] [numeric] (18, 3) NULL CONSTRAINT [DF_ABCAnalysis_PercentageOfPick] DEFAULT ((0.00)),
[AvgDailyPick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_AvgDailyPick] DEFAULT ((0.00)),
[ActivePickDays] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_ActivePickDays] DEFAULT ((0.00)),
[DaysOfActivity] [int] NULL CONSTRAINT [DF_ABCAnalysis_DaysOfActivity] DEFAULT ((0)),
[TotalPickedQty] [int] NULL CONSTRAINT [DF_ABCAnalysis_TotalPickedQty] DEFAULT ((0)),
[ABCEA] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcPieceABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewPieceABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PieceRank] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_PieceRank] DEFAULT ((0.00)),
[NoOfPiecePick] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_NoOfPiecePick] DEFAULT ((0.00)),
[AvgDailyPiecePick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_AvgDailyPiecePick] DEFAULT ((0.00)),
[PiecePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_PiecePickQty] DEFAULT ((0.00)),
[AvgDailyPiecePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_AvgDailyPiecePickQty] DEFAULT ((0.00)),
[NoOfPieceLoc] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_NoOfPieceLoc] DEFAULT ((0.00)),
[PieceStdev] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_PieceStdev] DEFAULT ((0.00)),
[PieceQtyLocMin] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_PieceQtyLocMin] DEFAULT ((0.00)),
[PieceQtyLocMinInCS] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_PieceQtyLocMinInCS] DEFAULT ((0.00)),
[AvgPieceQtyLocLimit] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_AvgPieceQtyLocLimit] DEFAULT ((0.00)),
[ABCCS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcCaseABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewCaseABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseRank] [decimal] (18, 0) NULL,
[NoOfCasePick] [numeric] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_NoOfCasePick] DEFAULT ((0.00)),
[AvgDailyCasePick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_AvgDailyCasePick] DEFAULT ((0.00)),
[CasePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_CasePickQty] DEFAULT ((0.00)),
[AvgDailyCasePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_AvgDailyCasePickQty] DEFAULT ((0.00)),
[NoOfCaseLoc] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_NoOfCaseLoc] DEFAULT ((0.00)),
[CaseStdev] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_CaseStdev] DEFAULT ((0.00)),
[CaseQtyLocMin] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_CaseQtyLocMin] DEFAULT ((0.00)),
[CaseQtyLocMininCS] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_CaseQtyLocMininCS] DEFAULT ((0.00)),
[AvgCaseQtyLocLimit] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_AvgCaseQtyLocLimit] DEFAULT ((0.00)),
[ABCPL] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcBulkABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewBulkABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BulkRank] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_BulkRank] DEFAULT ((0.00)),
[NoOfBulkPick] [numeric] (18, 0) NULL,
[AvgDailyBulkPick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCAnalysis_AvgDailyBulkPick] DEFAULT ((0.00)),
[NoOfBulkLoc] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCAnalysis_NoOfBulkLoc] DEFAULT ((0.00)),
[FinalizedFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCAnalysis_FinalizedFlag] DEFAULT ('N'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCAnalysis_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ABCAnalysis_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCAnalysis_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ABCAnalysis_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BulkPickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCANALYSIS_BULKPickQty] DEFAULT ('0'),
[AvgDailyBulkPickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCANALYSIS_AvgDailyBulkPickQty] DEFAULT ('0.00'),
[PickPct] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCANALYSIS_PickPct] DEFAULT ('0.00'),
[PiecePickPct] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCANALYSIS_PiecePickPct] DEFAULT ('0.00'),
[CasePickPct] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCANALYSIS_CasePickPct] DEFAULT ('0.00'),
[BulkPickPct] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCANALYSIS_BulkPickPct] DEFAULT ('0.00')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ABCAnalysis] ADD CONSTRAINT [PK_ABCAnalysis] PRIMARY KEY CLUSTERED ([SerialKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ABCAnalysis] ON [dbo].[ABCAnalysis] ([Facility], [StorerKey], [Sku]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ABCAnalysis] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ABCAnalysis] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ABCAnalysis] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ABCAnalysis] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Average Qty Picked per day', 'SCHEMA', N'dbo', 'TABLE', N'ABCAnalysis', 'COLUMN', N'AvgDailyBulkPickQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Bulk Picks', 'SCHEMA', N'dbo', 'TABLE', N'ABCAnalysis', 'COLUMN', N'BulkPickPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Qty Picked In Bulk Location', 'SCHEMA', N'dbo', 'TABLE', N'ABCAnalysis', 'COLUMN', N'BulkPickQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Case Picks', 'SCHEMA', N'dbo', 'TABLE', N'ABCAnalysis', 'COLUMN', N'CasePickPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Picks', 'SCHEMA', N'dbo', 'TABLE', N'ABCAnalysis', 'COLUMN', N'PickPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'% Piece Picks', 'SCHEMA', N'dbo', 'TABLE', N'ABCAnalysis', 'COLUMN', N'PiecePickPct'
GO
