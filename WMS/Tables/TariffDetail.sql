CREATE TABLE [dbo].[TariffDetail]
(
[TariffDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChargeType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_Descrip] DEFAULT (' '),
[Rate] [decimal] (22, 6) NOT NULL,
[Base] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_Base] DEFAULT ('Q'),
[MasterUnits] [decimal] (12, 6) NOT NULL CONSTRAINT [DF_TariffDetail_MasterUnits] DEFAULT ((1.0)),
[RoundMasterUnits] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_RoundMasterUnits] DEFAULT ('0'),
[UOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_UOMShow] DEFAULT (' '),
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_TaxGroupKey] DEFAULT ('XXXXXXXXXX'),
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_GLDistributionKey] DEFAULT ('XXXXXXXXXX'),
[MinimumCharge] [decimal] (22, 6) NOT NULL CONSTRAINT [DF_TariffDetail_MinimumCharge] DEFAULT ((0.0)),
[MinimumGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_MinimumGroup] DEFAULT ('LOT'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TariffDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TariffDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TariffDetail_EditWho] DEFAULT (suser_sname()),
[CostRate] [decimal] (22, 6) NULL CONSTRAINT [DF_TariffDetail_CostRate] DEFAULT ((0.0)),
[CostBase] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TariffDetail_CostBase] DEFAULT ('Q'),
[CostMasterUnits] [decimal] (12, 6) NULL CONSTRAINT [DF_TariffDetail_CostMasterUnits] DEFAULT ((1.0)),
[CostUOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TariffDetail_CostUOMShow] DEFAULT (' '),
[UOM1Mult] [decimal] (12, 6) NULL CONSTRAINT [DF_TariffDetail_UOM1Mult] DEFAULT ((1.0)),
[UOM2Mult] [decimal] (12, 6) NULL CONSTRAINT [DF_TariffDetail_UOM2Mult] DEFAULT ((1.0)),
[UOM3Mult] [decimal] (12, 6) NULL CONSTRAINT [DF_TariffDetail_UOM3Mult] DEFAULT ((1.0)),
[UOM4Mult] [decimal] (12, 6) NULL CONSTRAINT [DF_TariffDetail_UOM4Mult] DEFAULT ((1.0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [CK_TariffDetailChargeType] CHECK (([ChargeType]='MR' OR [ChargeType]='DO' OR [ChargeType]='DI' OR [ChargeType]='SP' OR [ChargeType]='AC' OR [ChargeType]='MI' OR [ChargeType]='HO' OR [ChargeType]='HI' OR [ChargeType]='RS' OR [ChargeType]='IS'))
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [CK_TariffDetail_Base] CHECK (([Base]='R' OR [Base]='P' OR [Base]='F' OR [Base]='C' OR [Base]='G' OR [Base]='Q'))
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [CK_TariffDetail_CostBase] CHECK (([CostBase]='R' OR [CostBase]='P' OR [CostBase]='F' OR [CostBase]='C' OR [CostBase]='G' OR [CostBase]='Q'))
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [CK_TariffDetail_CostMU] CHECK (([CostMasterUnits]>(0.0)))
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [CK_TariffDetail_M_U] CHECK (([MasterUnits]>(0.0)))
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [CK_TariffDetail_MinimumGroup01] CHECK (([MinimumGroup]='LOTTABLE06' OR [MinimumGroup]='LOTTABLE07' OR [MinimumGroup]='LOTTABLE08' OR [MinimumGroup]='LOTTABLE09' OR [MinimumGroup]='LOTTABLE10' OR [MinimumGroup]='LOTTABLE11' OR [MinimumGroup]='LOTTABLE12' OR [MinimumGroup]='LOTTABLE03' OR [MinimumGroup]='LOTTABLE02' OR [MinimumGroup]='LOTTABLE01' OR [MinimumGroup]='LOT'))
GO
ALTER TABLE [dbo].[TariffDetail] ADD CONSTRAINT [PKTariffDetail] PRIMARY KEY CLUSTERED ([TariffDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [FK_TariffDetail_GLDist_01] FOREIGN KEY ([GLDistributionKey]) REFERENCES [dbo].[GLDistribution] ([GLDistributionKey])
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [FK_TariffDetail_TaxGroupKey_01] FOREIGN KEY ([TaxGroupKey]) REFERENCES [dbo].[TaxGroup] ([TaxGroupKey])
GO
ALTER TABLE [dbo].[TariffDetail] WITH NOCHECK ADD CONSTRAINT [FKTariffDetail] FOREIGN KEY ([TariffKey]) REFERENCES [dbo].[Tariff] ([TariffKey])
GO
GRANT DELETE ON  [dbo].[TariffDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TariffDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TariffDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TariffDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Tariff Detail.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tariff Detail.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'TariffDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of tariff assigned to the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'TariffKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'TariffDetail', 'COLUMN', N'TaxGroupKey'
GO
