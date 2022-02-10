CREATE TABLE [RDT].[RDTTempUCC]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_PickSlipNo] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOT] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable01] DEFAULT (''),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable02] DEFAULT (''),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable03] DEFAULT (''),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTTempUCC_AddDate] DEFAULT (getdate()),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTTempUCC_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[RDTTempUCC] ADD CONSTRAINT [PKRDTTempUCC] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RDTTempUCC_TaskType_StorerKey_SKU_LOC] ON [RDT].[RDTTempUCC] ([TaskType], [StorerKey], [SKU], [LOC]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RDTTempUCC_UCCNo] ON [RDT].[RDTTempUCC] ([UCCNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[RDTTempUCC] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTTempUCC] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTTempUCC] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTTempUCC] TO [NSQL]
GO
