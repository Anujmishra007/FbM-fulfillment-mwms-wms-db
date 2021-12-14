IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DEL_PODETAIL]') and OBJECTPROPERTY(id, N'IsTable') = 1)
DROP TABLE [dbo].[DEL_PODETAIL]
GO


SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DEL_PODETAIL](
	[POKey] [nvarchar](18) NOT NULL,
	[POLineNumber] [nvarchar](5) NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[PODetailKey] [nvarchar](10) NULL,
	[ExternPOKey] [nvarchar](20) NULL,
	[ExternLineNo] [nvarchar](20) NULL,
	[MarksContainer] [nvarchar](18) NULL,
	[Sku] [nvarchar](20) NULL,
	[SKUDescription] [nvarchar](60) NULL,
	[ManufacturerSku] [nvarchar](20) NULL,
	[RetailSku] [nvarchar](20) NULL,
	[AltSku] [nvarchar](20) NULL,
	[QtyOrdered] [int] NULL,
	[QtyAdjusted] [int] NULL,
	[QtyReceived] [int] NULL,
	[PackKey] [nvarchar](10) NOT NULL,
	[UnitPrice] [float] NULL,
	[UOM] [nvarchar](10) NULL,
	[Notes] [nvarchar](4000) NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[POLineStatus] [nvarchar](10) NULL,
	[Facility] [nvarchar](5) NULL,
	[shortcode] [nvarchar](10) NULL,
	[Best_bf_Date] [datetime] NULL,
	[Lottable01] [nvarchar](18) NULL,
	[Lottable02] [nvarchar](18) NULL,
	[Lottable03] [nvarchar](18) NULL,
	[Lottable04] [datetime] NULL,
	[Lottable05] [datetime] NULL,
	[UserDefine01] [nvarchar](30) NULL,
	[UserDefine02] [nvarchar](30) NULL,
	[UserDefine03] [nvarchar](30) NULL,
	[UserDefine04] [nvarchar](30) NULL,
	[UserDefine05] [nvarchar](30) NULL,
	[UserDefine06] [datetime] NULL,
	[UserDefine07] [datetime] NULL,
	[UserDefine08] [nvarchar](30) NULL,
	[UserDefine09] [nvarchar](30) NULL,
	[UserDefine10] [nvarchar](30) NULL,
	[ToId] [nvarchar](18) NULL,
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
	[Channel] [nvarchar](20) NULL,
 CONSTRAINT [PK_DEL_PODETAIL] PRIMARY KEY CLUSTERED 
(
	[POKey] ASC,
	[POLineNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


