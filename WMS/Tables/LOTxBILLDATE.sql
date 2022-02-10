CREATE TABLE [dbo].[LOTxBILLDATE]
(
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TariffKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LotBillThruDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_LotBillThruDate] DEFAULT (getdate()),
[LastActivity] [datetime] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_LastActivity] DEFAULT (getdate()),
[QtyBilledBalance] [int] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_QtyBilledBalance] DEFAULT ((0)),
[QtyBilledGrossWeight] [float] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_QtyBilledGrossWeight] DEFAULT ((0)),
[QtyBilledNetWeight] [float] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_QtyBilledNetWeight] DEFAULT ((0)),
[QtyBilledCube] [float] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_QtyBilledCube] DEFAULT ((0)),
[AnniversaryStartDate] [datetime] NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxBILLDATE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxBILLDATE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxBILLDATE_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOTxBILLDATE] ADD CONSTRAINT [PKLOTxBILLDATE] PRIMARY KEY CLUSTERED ([Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOTxBILLDATE] WITH NOCHECK ADD CONSTRAINT [FK_LotXBillDate_LOT_01] FOREIGN KEY ([Lot]) REFERENCES [dbo].[LOT] ([Lot])
GO
ALTER TABLE [dbo].[LOTxBILLDATE] WITH NOCHECK ADD CONSTRAINT [FK_LotXBillDate_TariffKey_01] FOREIGN KEY ([TariffKey]) REFERENCES [dbo].[Tariff] ([TariffKey])
GO
GRANT DELETE ON  [dbo].[LOTxBILLDATE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOTxBILLDATE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOTxBILLDATE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOTxBILLDATE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTxBILLDATE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxBILLDATE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTxBILLDATE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxBILLDATE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxBILLDATE', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of tariff assigned.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxBILLDATE', 'COLUMN', N'TariffKey'
GO
