CREATE TABLE [dbo].[BILLING_DETAIL_CUT]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[EffectiveDate] [datetime] NOT NULL,
[Flag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RunningTotal] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BILLING_DETAIL_CUT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BILLING_DETAIL_CUT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BILLING_DETAIL_CUT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BILLING_DETAIL_CUT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'BILLING_DETAIL_CUT', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated to the billing detail.', 'SCHEMA', N'dbo', 'TABLE', N'BILLING_DETAIL_CUT', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'BILLING_DETAIL_CUT', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'BILLING_DETAIL_CUT', 'COLUMN', N'StorerKey'
GO
