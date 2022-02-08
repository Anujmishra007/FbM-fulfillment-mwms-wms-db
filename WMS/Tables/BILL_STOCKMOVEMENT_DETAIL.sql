CREATE TABLE [dbo].[BILL_STOCKMOVEMENT_DETAIL]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Company] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[EffectiveDate] [datetime] NOT NULL,
[Flag] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RunningTotal] [int] NULL,
[record_number] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BILL_STOCKMOVEMENT_DETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BILL_STOCKMOVEMENT_DETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BILL_STOCKMOVEMENT_DETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BILL_STOCKMOVEMENT_DETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the company.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT_DETAIL', 'COLUMN', N'Company'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Stock Movement Detail.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT_DETAIL', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT_DETAIL', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated to the stock movement.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT_DETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT_DETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT_DETAIL', 'COLUMN', N'StorerKey'
GO
