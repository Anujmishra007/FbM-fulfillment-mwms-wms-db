CREATE TABLE [RDT].[rdtPickLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActQty] [int] NULL CONSTRAINT [DF_rdtPickLog_ActQty] DEFAULT ((0)),
[PickLockQty] [int] NULL CONSTRAINT [DF_rdtPickLog_PickLockQty] DEFAULT ((0)),
[PickQty] [int] NULL CONSTRAINT [DF_rdtPickLog_PickQty] DEFAULT ((0)),
[TotalPickQty] [int] NULL CONSTRAINT [DF_rdtPickLog_TotalPickQty] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMQty] [int] NULL CONSTRAINT [DF_rdtPickLog_UOMQty] DEFAULT ((0)),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogicalLocation] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtPickLog_AddDate] DEFAULT (getdate()),
[DropID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mobile] [int] NULL,
[Remarks] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLog_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPickLog] ADD CONSTRAINT [PKrdtPickLog] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPickLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPickLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPickLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPickLog] TO [NSQL]
GO
