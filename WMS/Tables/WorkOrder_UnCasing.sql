CREATE TABLE [dbo].[WorkOrder_UnCasing]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_SKU] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_Qty] DEFAULT ((0)),
[QtyCompleted] [int] NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_QtyCompleted] DEFAULT ((0)),
[QtyRemaining] [int] NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_QtyRemaining] DEFAULT ((0)),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_ID] DEFAULT (''),
[SSCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_SSCC] DEFAULT (''),
[InLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_InLOC] DEFAULT (''),
[OutLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_OutLoc] DEFAULT (''),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_Lot] DEFAULT (''),
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
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_Status] DEFAULT ('0'),
[StartDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_UnCasing_EndDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_UnCasing_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_UnCasing_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_UnCasing_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemQty] [int] NOT NULL CONSTRAINT [DF_WorkOrder_UnCasing_SystemQty] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrder_UnCasing] ADD CONSTRAINT [PK_WorkOrder_UnCasing] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrder_UnCasing] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrder_UnCasing] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrder_UnCasing] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrder_UnCasing] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Qty by the time it first uncased (Reconciliation).', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder_UnCasing', 'COLUMN', N'SystemQty'
GO
