CREATE TABLE [dbo].[WorkOrder_Palletize]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_SKU] DEFAULT (''),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_PackKey] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_UOM] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_Qty] DEFAULT ((0)),
[QtyCompleted] [int] NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_QtyCompleted] DEFAULT ((0)),
[QtyRemaining] [int] NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_QtyRemaining] DEFAULT ((0)),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_ID] DEFAULT (''),
[SSCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_SSCC] DEFAULT (''),
[InLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_InLOC] DEFAULT (''),
[OutLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_OutLoc] DEFAULT (''),
[Lottable01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_Status] DEFAULT ('0'),
[StartDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_Palletize_EndDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_Palletize_EditDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Palletize_AddWho] DEFAULT (suser_sname()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Palletize_EditWho] DEFAULT (suser_sname()),
[LabelPrinted] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo] [int] NOT NULL CONSTRAINT [DF_WorkOrder_Palletize_RefNo] DEFAULT ((0)),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrder_Palletize] ADD CONSTRAINT [PK_WorkOrder_Palletize] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrder_Palletize] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrder_Palletize] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrder_Palletize] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrder_Palletize] TO [NSQL]
GO
