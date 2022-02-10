CREATE TABLE [dbo].[WorkOrderOutputs]
(
[WkOrdOutputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WORKORDEROUTPUTS_WkOrdOutputsKey] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StepNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL CONSTRAINT [DF_WORKORDEROUTPUTS_Qty] DEFAULT ((0)),
[InventoryStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WORKORDEROUTPUTS_InventoryStatus] DEFAULT ('0'),
[NonInvSKU] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingUOMQty] [int] NULL CONSTRAINT [DF_WORKORDEROUTPUTS_BillingUOMQty] DEFAULT ((0)),
[BillingUOM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingRate] [money] NULL CONSTRAINT [DF_WORKORDEROUTPUTS_BillingRate] DEFAULT ((0.00)),
[PrimaryStorer] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimarySKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable01Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable05Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WORKORDEROUTPUTS_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_WORKORDEROUTPUTS_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WORKORDEROUTPUTS_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WORKORDEROUTPUTS_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable07Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable08Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable09Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable10Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable11Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable12Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable13Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable14Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable15Rules] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderOutputs] ADD CONSTRAINT [PK_WORKORDEROUTPUTS] PRIMARY KEY CLUSTERED ([WkOrdOutputsKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderOutputs] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderOutputs] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderOutputs] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderOutputs] TO [NSQL]
GO
