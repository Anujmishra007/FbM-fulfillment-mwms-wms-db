CREATE TABLE [dbo].[ACCUMULATEDCHARGES]
(
[AccumulatedChargesKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descrip] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Descrip] DEFAULT (' '),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Status] DEFAULT ('0'),
[PrintCount] [int] NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_PrintCount] DEFAULT ((0)),
[ServiceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_ServiceKey] DEFAULT ('XXXXXXXXXX'),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Lot] DEFAULT (' '),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_ID] DEFAULT (' '),
[UOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_UOMShow] DEFAULT (' '),
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_TariffKey] DEFAULT ('XXXXXXXXXX'),
[TariffDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_TariffDetailKey] DEFAULT (' '),
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_TaxGroupKey] DEFAULT ('XXXXXXXXXX'),
[Rate] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Rate] DEFAULT ((1.0)),
[Base] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Base] DEFAULT ('Q'),
[MasterUnits] [decimal] (12, 6) NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_MasterUnits] DEFAULT ((1.0)),
[SystemGeneratedCharge] [decimal] (28, 6) NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_SystemGeneratedCharge] DEFAULT ((0.0)),
[Debit] [decimal] (28, 6) NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Debit] DEFAULT ((0.0)),
[Credit] [decimal] (28, 6) NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Credit] DEFAULT ((0.0)),
[BilledUnits] [decimal] (21, 7) NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_BilledUnits] DEFAULT ((0.0)),
[ChargeType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_LineType] DEFAULT ('N'),
[BillFromDate] [datetime] NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_BillFromDate] DEFAULT (getdate()),
[BillThruDate] [datetime] NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_BillThruDate] DEFAULT (getdate()),
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_SourceKey] DEFAULT (' '),
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_SourceType] DEFAULT (' '),
[AccessorialDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_AccessorialDetailKey] DEFAULT ('XXXXXXXXXX'),
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_GLDistributionKey] DEFAULT ('XXXXXXXXXX'),
[InvoiceBatch] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_InvoiceBatch] DEFAULT (' '),
[InvoiceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_InvoiceKey] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_EditWho] DEFAULT (suser_sname()),
[CostRate] [decimal] (22, 6) NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_CostRate] DEFAULT ((1.0)),
[CostBase] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_CostBase] DEFAULT ('Q'),
[CostMasterUnits] [decimal] (12, 6) NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_CostMasterUnits] DEFAULT ((1.0)),
[CostUOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_CostUOMShow] DEFAULT (' '),
[CostSystemGeneratedCharge] [decimal] (28, 6) NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_CostSystemGeneratedCharge] DEFAULT ((0.0)),
[Cost] [decimal] (28, 6) NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_Cost] DEFAULT ((0.0)),
[CostUnits] [decimal] (21, 6) NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_CostUnits] DEFAULT ((0.0)),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ACCUMULATEDCHARGES_ReferenceKey] DEFAULT (' '),
[InvoiceDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_Base] CHECK (([Base]='R' OR [Base]='P' OR [Base]='F' OR [Base]='C' OR [Base]='G' OR [Base]='Q'))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_BilledUnits] CHECK (([BilledUnits]>=(0.0)))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_ChargeType] CHECK (([ChargeType]='SP' OR [ChargeType]='AC' OR [ChargeType]='MT' OR [ChargeType]='DO' OR [ChargeType]='DI' OR [ChargeType]='MR' OR [ChargeType]='MO' OR [ChargeType]='MH' OR [ChargeType]='MI' OR [ChargeType]='RS' OR [ChargeType]='IS' OR [ChargeType]='HO' OR [ChargeType]='HI' OR [ChargeType]='CO' OR [ChargeType]='CI'))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_CostBase] CHECK (([CostBase]='R' OR [CostBase]='P' OR [CostBase]='F' OR [CostBase]='C' OR [CostBase]='G' OR [CostBase]='Q'))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_Credit] CHECK (([Credit]>=(0.0)))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_Debit] CHECK (([Debit]>=(0.0)))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_MasterUnits] CHECK (([MasterUnits]>(0.0)))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [CK_AccChg_SysGenCharge] CHECK (([SystemGeneratedCharge]>=(0.0)))
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] ADD CONSTRAINT [PK_AccumulatedChargesKey] PRIMARY KEY CLUSTERED ([AccumulatedChargesKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [FK_AccChg_AccDet_01] FOREIGN KEY ([AccessorialDetailKey]) REFERENCES [dbo].[AccessorialDetail] ([AccessorialDetailkey])
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [FK_AccChg_GLDist_01] FOREIGN KEY ([GLDistributionKey]) REFERENCES [dbo].[GLDistribution] ([GLDistributionKey])
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [FK_AccChg_SERVICE_01] FOREIGN KEY ([ServiceKey]) REFERENCES [dbo].[Services] ([Servicekey])
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [FK_AccChg_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [FK_AccChg_Tariff_01] FOREIGN KEY ([TariffKey]) REFERENCES [dbo].[Tariff] ([TariffKey])
GO
ALTER TABLE [dbo].[ACCUMULATEDCHARGES] WITH NOCHECK ADD CONSTRAINT [FK_AccChg_TaxGroup_01] FOREIGN KEY ([TaxGroupKey]) REFERENCES [dbo].[TaxGroup] ([TaxGroupKey])
GO
GRANT DELETE ON  [dbo].[ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ACCUMULATEDCHARGES] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ACCUMULATEDCHARGES] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial Detail.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'AccessorialDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accumulated Charges.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'AccumulatedChargesKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The total spent for goods or services including money and time and labor.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'Cost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Accumulated Charges.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of invoice.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'InvoiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying reference.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'ReferenceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Services.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'ServiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Source.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tariff Detail.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'TariffDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tariff.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'TariffKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'TaxGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ACCUMULATEDCHARGES', 'COLUMN', N'TrafficCop'
GO
