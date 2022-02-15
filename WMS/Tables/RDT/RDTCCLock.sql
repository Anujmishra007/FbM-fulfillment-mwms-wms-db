CREATE TABLE [RDT].[RDTCCLock]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[CCKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CCDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_CCDetailKey] DEFAULT (' '),
[SheetNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_SheetNo] DEFAULT (' '),
[CountNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_CountNo] DEFAULT (' '),
[Zone1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Zone1] DEFAULT (' '),
[Zone2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Zone2] DEFAULT (' '),
[Zone3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Zone3] DEFAULT (' '),
[Zone4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Zone4] DEFAULT (' '),
[Zone5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Zone5] DEFAULT (' '),
[Aisle] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Aisle] DEFAULT (' '),
[Level] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Level] DEFAULT (' '),
[Storerkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Loc] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Id] DEFAULT (' '),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[SystemQty] [int] NOT NULL CONSTRAINT [DF_RDTCCLock_SystemQty] DEFAULT ((0)),
[CountedQty] [int] NOT NULL CONSTRAINT [DF_RDTCCLock_CountedQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_Status] DEFAULT ('0'),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_RefNo] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTCCLock_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCCLock_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDTCCLock_EditDate] DEFAULT (getdate()),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTCCLock_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTCCLock] ADD CONSTRAINT [PK_RDTCCLock] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTCCLock] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTCCLock] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTCCLock] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTCCLock] TO [NSQL]
GO
