CREATE TABLE [RDT].[rdtPickLock]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOT] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickQty] [int] NOT NULL CONSTRAINT [DF_rdtPickLock_PickQty] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMQty] [int] NOT NULL CONSTRAINT [DF_rdtPickLock_UOMQty] DEFAULT ((0)),
[Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogicalLocation] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPickLock_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPickLock_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPickLock_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPickLock_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPickLock_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mobile] [int] NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[BatchKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPickLock_BatchKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPickLock] ADD CONSTRAINT [PKrdtPickLock] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RDTPickLock_Mobile] ON [RDT].[rdtPickLock] ([Mobile]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RDTPickLock_Order_sku] ON [RDT].[rdtPickLock] ([Orderkey], [SKU], [LOC], [DropID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RDTPickLock_Storer_AddWho] ON [RDT].[rdtPickLock] ([Storerkey], [AddWho], [Orderkey], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPickLock] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPickLock] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPickLock] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPickLock] TO [NSQL]
GO
