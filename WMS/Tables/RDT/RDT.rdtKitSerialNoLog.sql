CREATE TABLE [RDT].[rdtKitSerialNoLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[GroupKey] [int] NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_GroupKey] DEFAULT ((0)),
[Mobile] [int] NOT NULL,
[KitKey] [nvarchar] (10) NOT NULL,
[Type] [nvarchar] (5) NOT NULL,
[StorerKey] [nvarchar] (15) NOT NULL,
[SKU] [nvarchar] (20) NOT NULL,
[ExpectedQTY] [int] NOT NULL,
[QTY] [int] NOT NULL,
[SerialNo] [nvarchar] (50) NOT NULL,
[Lottable01] [nvarchar] (18) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable01] DEFAULT (''),
[Lottable02] [nvarchar] (18) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable02] DEFAULT (''),
[Lottable03] [nvarchar] (18) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable03] DEFAULT (''),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Lottable06] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtKitSerialNoLog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtKitSerialNoLog] ADD CONSTRAINT [PK_rdtKitSerialNoLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
