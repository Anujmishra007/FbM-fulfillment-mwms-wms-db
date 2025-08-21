SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TempStkVar]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[TempStkVar](
	[STORERKEY] [nvarchar](15) NOT NULL,
	[CCKey] [nvarchar](10) NOT NULL,
	[Sku] [nvarchar](20) NOT NULL,
	[Descr] [nvarchar](60) NULL,
	[TagNo] [nvarchar](10) NULL,
	[CCSheetNo] [nvarchar](10) NULL,
	[SUSR3] [nvarchar](18) NULL,
	[Cost] [money] NULL,
	[Facility] [nvarchar](5) NULL,
	[Lot] [nvarchar](10) NULL,
	[Id] [nvarchar](18) NULL,
	[Loc] [nvarchar](10) NULL,
	[Lottable02] [nvarchar](18) NULL,
	[Lottable02_Cnt2] [nvarchar](18) NULL,
	[Lottable02_Cnt3] [nvarchar](18) NULL,
	[Lottable04] [datetime] NULL,
	[Lottable04_Cnt2] [datetime] NULL,
	[Lottable04_Cnt3] [datetime] NULL,
	[Qty] [int] NOT NULL,
	[Qty_Cnt2] [int] NOT NULL,
	[Qty_Cnt3] [int] NOT NULL,
	[PackUOM3] [nvarchar](10) NULL,
	[PackQty] [float] NOT NULL,
	[LotXLocXId_Qty] [int] NOT NULL,
	[VarQty_cal] [int] NOT NULL,
	[VarHKD_cal] [float] NULL,
	[SkuGroup] [nvarchar](10) NULL,
	[ItemClass] [nvarchar](10) NULL,
	[CompanyName] [nvarchar](45) NULL,
	[Currency] [nvarchar](45) NULL,
	[Lottable05] [datetime] NULL,
	[Lottable05_Cnt2] [datetime] NULL,
	[Lottable05_Cnt3] [datetime] NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'STORERKEY'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique key to the Storer records.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'STORERKEY'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'CCKey'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying Cycle Count.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'CCKey'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'Sku'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying the product.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'Sku'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'CCSheetNo'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique number identifying Cycle Count Sheet.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'CCSheetNo'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'Cost'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The total spent for goods or services including money and time and labor.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'Cost'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'Facility'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A building or place that provide services for effective warehouse management. Identified by unique code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'Facility'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'Lot'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique pre-populated numeric values associated with a specific product. A unique combination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'Lot'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'Id'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'Id'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'Loc'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique code identifying a physical Location in the facility.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'Loc'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'Qty'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Quantity of the product associated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'Qty'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'SkuGroup'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Can be used to put Commodities in logical groups. For example, in a facility that handles computer components, Commodity Groups could describe types of peripherals such as monitors, hard drives, cables and printers.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'SkuGroup'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'TempStkVar', N'COLUMN',N'CompanyName'))
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Full name of the company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TempStkVar', @level2type=N'COLUMN',@level2name=N'CompanyName'
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TempStkVar]') AND type in (N'U'))
   GRANT SELECT, INSERT, DELETE, UPDATE ON [dbo].[TempStkVar] TO [NSQL]
GO
IF EXISTS(SELECT TOP 1 1 FROM sys.columns where object_id=OBJECT_ID(N'[dbo].[TempStkVar]') AND name='Storerkey' AND TYPE_NAME(system_type_id)='nvarchar' AND max_length < 30)
   ALTER TABLE [dbo].[TempStkVar] ALTER COLUMN [Storerkey] [nvarchar](15) NOT NULL
GO
