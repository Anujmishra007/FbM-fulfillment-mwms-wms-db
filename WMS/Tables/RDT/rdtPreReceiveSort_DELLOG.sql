CREATE TABLE [RDT].[rdtPreReceiveSort_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[RowRefSource] [int] NOT NULL,
[Mobile] [int] NOT NULL,
[Func] [int] NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPreReceiveSort_DELLOG_Status] DEFAULT ('0'),
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPreReceiveSort_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPreReceiveSort_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPreReceiveSort_DELLOG] ADD CONSTRAINT [PK__rdtPreRe__78C97797943D26CF] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPreReceiveSort_DELLOG] TO [NSQL]
GO
