USE [GLO_DATAMART]
GO

/****** Object:  Table [ODS].[rdtDataCapture]    Script Date: 5/9/2025 7:47:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ODS].[rdtDataCapture](
	[ODS_Updated] [datetime] NOT NULL,
	[RowRef] [int] NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[Facility] [nvarchar](5) NOT NULL,
	[V_Zone] [nvarchar](10) NULL,
	[V_Loc] [nvarchar](10) NULL,
	[V_SKU] [nvarchar](20) NULL,
	[V_UOM] [nvarchar](10) NULL,
	[V_ID] [nvarchar](18) NULL,
	[V_ConsigneeKey] [nvarchar](15) NULL,
	[V_CaseID] [nvarchar](15) NULL,
	[V_SKUDescr] [nvarchar](60) NULL,
	[V_QTY] [int] NULL,
	[V_UCC] [nvarchar](20) NULL,
	[V_Lottable01] [nvarchar](18) NULL,
	[V_Lottable02] [nvarchar](18) NULL,
	[V_Lottable03] [nvarchar](18) NULL,
	[V_Lottable04] [datetime] NULL,
	[V_Lottable05] [datetime] NULL,
	[V_String1] [nvarchar](20) NULL,
	[V_String2] [nvarchar](20) NULL,
	[V_String3] [nvarchar](20) NULL,
	[V_String4] [nvarchar](20) NULL,
	[V_String5] [nvarchar](20) NULL,
	[V_String6] [nvarchar](20) NULL,
	[V_String7] [nvarchar](20) NULL,
	[V_String8] [nvarchar](20) NULL,
	[V_String9] [nvarchar](20) NULL,
	[V_String10] [nvarchar](20) NULL,
	[AddWho] [nvarchar](128) NULL,
	[AddDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NULL,
	[EditDate] [datetime] NOT NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[V_Lottable06] [nvarchar](30) NULL,
	[V_Lottable07] [nvarchar](30) NULL,
	[V_Lottable08] [nvarchar](30) NULL,
	[V_Lottable09] [nvarchar](30) NULL,
	[V_Lottable10] [nvarchar](30) NULL,
	[V_Lottable11] [nvarchar](30) NULL,
	[V_Lottable12] [nvarchar](30) NULL,
	[V_Lottable13] [datetime] NULL,
	[V_Lottable14] [datetime] NULL,
	[V_Lottable15] [datetime] NULL,
	[SerialNo] [nvarchar](30) NOT NULL,
 CONSTRAINT [PKrdtDataCapture] PRIMARY KEY CLUSTERED 
(
	[RowRef] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ODS].[rdtDataCapture] ADD  CONSTRAINT [DF_rdtDataCapture_ODS_Updated]  DEFAULT (getdate()) FOR [ODS_Updated]
GO
