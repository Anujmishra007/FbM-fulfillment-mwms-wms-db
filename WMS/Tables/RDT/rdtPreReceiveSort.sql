CREATE TABLE [RDT].[rdtPreReceiveSort](
	[Rowref] [int] IDENTITY(1,1) NOT NULL,
	[Mobile] [int] NOT NULL,
	[Func] [int] NOT NULL,
	[Facility] [nvarchar](5) NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[ReceiptKey] [nvarchar](10) NOT NULL,
	[UCCNo] [nvarchar](20) NULL,
	[SKU] [nvarchar](20) NULL,
	[Qty] [int] NULL,
	[Loc] [nvarchar](10) NULL,
	[ID] [nvarchar](18) NULL,
	[Status] [nvarchar](10) NULL,
	[Position] [nvarchar](10) NULL,
	[Lottable01] [nvarchar](18) NULL,
	[Lottable02] [nvarchar](18) NULL,
	[Lottable03] [nvarchar](18) NULL,
	[Lottable04] [datetime] NULL,
	[Lottable05] [datetime] NULL,
	[Lottable06] [nvarchar](30) NULL,
	[Lottable07] [nvarchar](30) NULL,
	[Lottable08] [nvarchar](30) NULL,
	[Lottable09] [nvarchar](30) NULL,
	[Lottable10] [nvarchar](30) NULL,
	[Lottable11] [nvarchar](30) NULL,
	[Lottable12] [nvarchar](30) NULL,
	[Lottable13] [datetime] NULL,
	[Lottable14] [datetime] NULL,
	[Lottable15] [datetime] NULL,
	[SourceType] [nvarchar](30) NULL,
	[UDF01] [nvarchar](30) NULL,
	[UDF02] [nvarchar](30) NULL,
	[UDF03] [nvarchar](30) NULL,
	[UDF04] [nvarchar](30) NULL,
	[UDF05] [nvarchar](30) NULL,
	[AddDate] [datetime] NULL,
	[AddWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NULL,
	[EditWho] [nvarchar](128) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
 CONSTRAINT [PK_rdtPreReceiveSort] PRIMARY KEY CLUSTERED 
(
	[Rowref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort] ADD  CONSTRAINT [DF_rdtPreReceiveSort_Qty]  DEFAULT ((0)) FOR [Qty]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort] ADD  CONSTRAINT [DF_rdtPreReceiveSort_Status]  DEFAULT (suser_sname()) FOR [Status]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort] ADD  CONSTRAINT [DF_rdtPreReceiveSort_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort] ADD  CONSTRAINT [DF_rdtPreReceiveSort_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort] ADD  CONSTRAINT [DF_rdtPreReceiveSort_EditDate]  DEFAULT (getdate()) FOR [EditDate]
GO

ALTER TABLE [RDT].[rdtPreReceiveSort] ADD  CONSTRAINT [DF_rdtPreReceiveSort_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
GO


CREATE NONCLUSTERED INDEX [IX_rdtPreReceiveSort_ReceiptKey_Loc_Status] ON [RDT].[rdtPreReceiveSort] ([ReceiptKey], [Loc], [Status]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtPreReceiveSort_ReceiptKey_Ucc_Status] ON [RDT].[rdtPreReceiveSort] ([ReceiptKey], [UCCNo], [Status]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
