CREATE TABLE [dbo].[WorkOrderJobOperation]
(
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_JobKey] DEFAULT (''),
[JobLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_JobLine] DEFAULT (''),
[MinStep] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_MinStep] DEFAULT (''),
[WOOperation] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_WOOperation] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_Storerkey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_Sku] DEFAULT (''),
[NonInvSku] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_NonInvSku] DEFAULT (''),
[NonInvLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_NonInvLocation] DEFAULT (''),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_PackKey] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_UOM] DEFAULT (''),
[StepQty] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_StepQty] DEFAULT ((0)),
[QtyReserved] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_QtyReserved] DEFAULT ((0)),
[QtyToProcess] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_QtyToProcess] DEFAULT ((0)),
[QtyInProcess] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_QtyInProcess] DEFAULT ((0)),
[QtyCompleted] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_QtyCompleted] DEFAULT ((0)),
[PendingTasks] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_PendingTasks] DEFAULT ((0)),
[InProcessTasks] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_InProcessTasks] DEFAULT ((0)),
[CompletedTasks] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_CompletedTasks] DEFAULT ((0)),
[CurrentLPN] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Instructions] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_Instructions] DEFAULT (''),
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_FromLoc] DEFAULT (''),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_ToLoc] DEFAULT (''),
[CopyInputFromStep] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_JobStatus] DEFAULT ('0'),
[PullType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_PullType] DEFAULT (''),
[MinQty] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_MinQty] DEFAULT ((0)),
[MinUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_MinUOM] DEFAULT (''),
[PullQty] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_PullQty] DEFAULT ((0)),
[PullUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_PullUOM] DEFAULT (''),
[InLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_InLocation] DEFAULT (''),
[Rotation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_Rotation] DEFAULT (''),
[MinShelf] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_MinShelf] DEFAULT ((0)),
[Lottable01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[STDTime] [decimal] (18, 6) NULL CONSTRAINT [DF_WorkOrderJobOperation_STDTime] DEFAULT ((0.000000)),
[EstimatedDuration] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_EstimatedDuration] DEFAULT ((0)),
[ActualDuration] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_ActualDuration] DEFAULT ((0)),
[RemainingDuration] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_RemainingDuration] DEFAULT ((0)),
[ActualJobStartTime] [datetime] NULL,
[ActualJobDuration] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_ActualJobDuration] DEFAULT ((0)),
[ActualCompletionTime] [datetime] NULL,
[BillingUOMQty] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_BillingUOMQty] DEFAULT ((0)),
[BillingUOM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_BillingUOM] DEFAULT (''),
[BillingRate] [money] NULL CONSTRAINT [DF_WorkOrderJobOperation_BillingRate] DEFAULT ((0.00)),
[ExtendedBillingQty] [int] NULL CONSTRAINT [DF_WorkOrderJobOperation_ExtendedBillingQty] DEFAULT ((0)),
[TotalBillingAmount] [money] NULL CONSTRAINT [DF_WorkOrderJobOperation_TotalBillingAmount] DEFAULT ((0.00)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobOperation_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderJobOperation_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderJobOperation] ADD CONSTRAINT [PK_WorkOrderJobOperation] PRIMARY KEY CLUSTERED ([JobKey], [JobLine]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderJobOperation] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderJobOperation] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderJobOperation] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderJobOperation] TO [NSQL]
GO
