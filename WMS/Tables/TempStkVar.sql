CREATE TABLE [dbo].[TempStkVar]
(
[STORERKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CCKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TagNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCSheetNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cost] [money] NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02_Cnt2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02_Cnt3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable04_Cnt2] [datetime] NULL,
[Lottable04_Cnt3] [datetime] NULL,
[Qty] [int] NOT NULL,
[Qty_Cnt2] [int] NOT NULL,
[Qty_Cnt3] [int] NOT NULL,
[PackUOM3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackQty] [float] NOT NULL,
[LotXLocXId_Qty] [int] NOT NULL,
[VarQty_cal] [int] NOT NULL,
[VarHKD_cal] [float] NULL,
[SkuGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemClass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Currency] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable05] [datetime] NULL,
[Lottable05_Cnt2] [datetime] NULL,
[Lottable05_Cnt3] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TempStkVar] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TempStkVar] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TempStkVar] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TempStkVar] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Cycle Count.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'CCKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Cycle Count Sheet.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'CCSheetNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the company.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'CompanyName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The total spent for goods or services including money and time and labor.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'Cost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying a physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Can be used to put Commodities in logical groups. For example, in a facility that handles computer components, Commodity Groups could describe types of peripherals such as monitors, hard drives, cables and printers.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'SkuGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'TempStkVar', 'COLUMN', N'STORERKEY'
GO
