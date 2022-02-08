CREATE TABLE [dbo].[BILL_STOCKMOVEMENT]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[EffectiveDate] [datetime] NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BILL_STOCKMOVEMENT_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BILL_STOCKMOVEMENT] ADD CONSTRAINT [PK_BillStockMovement] PRIMARY KEY CLUSTERED ([Lot], [EffectiveDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BILL_STOCKMOVEMENT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BILL_STOCKMOVEMENT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BILL_STOCKMOVEMENT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BILL_STOCKMOVEMENT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated to the stock movement.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_STOCKMOVEMENT', 'COLUMN', N'StorerKey'
GO
