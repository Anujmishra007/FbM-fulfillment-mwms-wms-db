CREATE TABLE [dbo].[BILL_ACCUMULATEDCHARGES]
(
[Ident] [int] NOT NULL IDENTITY(0, 1),
[AccumulatedChargesKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descrip] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrintCount] [int] NULL,
[ServiceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TariffDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate] [decimal] (22, 6) NULL,
[Base] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MasterUnits] [decimal] (12, 6) NULL,
[SystemGeneratedCharge] [decimal] (28, 6) NULL,
[Debit] [decimal] (28, 6) NULL,
[Credit] [decimal] (28, 6) NULL,
[BilledUnits] [decimal] (21, 7) NULL,
[ChargeType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillFromDate] [datetime] NULL,
[BillThruDate] [datetime] NULL,
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccessorialDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceBatch] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostRate] [decimal] (22, 6) NULL,
[CostBase] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostMasterUnits] [decimal] (12, 6) NULL,
[CostUOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostSystemGeneratedCharge] [decimal] (28, 6) NULL,
[Cost] [decimal] (28, 6) NULL,
[CostUnits] [decimal] (21, 6) NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ITRNSourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BILL_ACCUMULATEDCHARGES_ITRNSourceKey] DEFAULT (' '),
[ITRNSourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BILL_ACCUMULATEDCHARGES_ITRNSourceType] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BILL_ACCUMULATEDCHARGES_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BILL_ACCUMULATEDCHARGES] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial Detail.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'AccessorialDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accumulated Charges.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'AccumulatedChargesKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The total spent for goods or services including money and time and labor.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'Cost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Bill Accumulated Charges.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key identifying invoice.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'InvoiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying inventory transaction source.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'ITRNSourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying reference.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'ReferenceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying services.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'ServiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the source.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying tarff detail.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'TariffDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of Tariff assigned to the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'TariffKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'TaxGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BILL_ACCUMULATEDCHARGES', 'COLUMN', N'TrafficCop'
GO
