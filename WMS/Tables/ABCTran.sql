CREATE TABLE [dbo].[ABCTran]
(
[ABCTranKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ABCTran_Facility] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ABCTran_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ABCTran_Sku] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCTran_Status] DEFAULT ('0'),
[OldABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkuRank] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_SKURank] DEFAULT ((0.00)),
[NoOfPick] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_NoOfPick] DEFAULT ((0.00)),
[PercentageOfPick] [numeric] (18, 3) NULL CONSTRAINT [DF_ABCTran_PercentageOfPick] DEFAULT ((0.00)),
[AvgDailyPick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_AvgDailyPick] DEFAULT ((0.00)),
[ActivePickDays] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_ActivePickDays] DEFAULT ((0.00)),
[DaysOfActivity] [int] NULL CONSTRAINT [DF_ABCTran_DaysOfActivity] DEFAULT ((0)),
[ABCEA] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewPieceABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcPieceABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PieceRank] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_PieceRank] DEFAULT ((0.00)),
[NoOfPiecePick] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_NoOfPiecePick] DEFAULT ((0.00)),
[AvgDailyPiecePick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_AvgDailyPiecePick] DEFAULT ((0.00)),
[PiecePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_PiecePickQty] DEFAULT ((0.00)),
[AvgDailyPiecePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_AvgDailyPiecePickQty] DEFAULT ((0.00)),
[NoOfPieceLoc] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_NoOfPieceLoc] DEFAULT ((0.00)),
[PieceStdev] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_PieceStdev] DEFAULT ((0.00)),
[PieceQtyLocMin] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_PieceQtyLocMin] DEFAULT ((0.00)),
[PieceQtyLocMinInCS] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_PieceQtyLocMinInCS] DEFAULT ((0.00)),
[AvgPieceQtyLocLimit] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_AvgPieceQtyLocLimit] DEFAULT ((0.00)),
[ABCCS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewCaseABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcCaseABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseRank] [decimal] (18, 0) NULL,
[NoOfCasePick] [numeric] (18, 0) NULL CONSTRAINT [DF_ABCTran_NoOfCasePick] DEFAULT ((0.00)),
[AvgDailyCasePick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_AvgDailyCasePick] DEFAULT ((0.00)),
[CasePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_CasePickQty] DEFAULT ((0.00)),
[AvgDailyCasePickQty] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_AvgDailyCasePickQty] DEFAULT ((0.00)),
[NoOfCaseLoc] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_NoOfCaseLoc] DEFAULT ((0.00)),
[CaseStdev] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_CaseStdev] DEFAULT ((0.00)),
[CaseQtyLocMin] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_CaseQtyLocMin] DEFAULT ((0.00)),
[CaseQtyLocMininCS] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_CaseQtyLocMininCS] DEFAULT ((0.00)),
[AvgCaseQtyLocLimit] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_AvgCaseQtyLocLimit] DEFAULT ((0.00)),
[ABCPL] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewBulkABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalcBulkABC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BulkRank] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_BulkRank] DEFAULT ((0.00)),
[NoOfBulkPick] [numeric] (18, 0) NULL,
[AvgDailyBulkPick] [decimal] (18, 2) NULL CONSTRAINT [DF_ABCTran_AvgDailyBulkPick] DEFAULT ((0.00)),
[NoOfBulkLoc] [decimal] (18, 0) NULL CONSTRAINT [DF_ABCTran_NoOfBulkLoc] DEFAULT ((0.00)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCTran_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ABCTran_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ABCTran_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ABCTran_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ABCTran] ADD CONSTRAINT [PK_ABCTran] PRIMARY KEY CLUSTERED ([ABCTranKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ABCTran] ON [dbo].[ABCTran] ([Facility], [StorerKey], [Sku]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ABCTran] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ABCTran] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ABCTran] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ABCTran] TO [NSQL]
GO
