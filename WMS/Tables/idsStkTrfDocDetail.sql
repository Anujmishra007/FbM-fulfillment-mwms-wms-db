CREATE TABLE [dbo].[idsStkTrfDocDetail]
(
[STDNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[STDLineNO] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchNo] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductionDate] [datetime] NOT NULL,
[Weight] [float] NOT NULL,
[Printed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsStkTrfDocDetail_Printed] DEFAULT ('N'),
[OriginCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Exportstatus] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsStkTrfDocDetail_Exportstatus] DEFAULT ('0'),
[PrintDate] [datetime] NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_idsStkTrfDocDetail_Lottable01] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_idsStkTrfDocDetail_Lottable03] DEFAULT (' ')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[idsStkTrfDocDetail] ADD CONSTRAINT [PK_idsStkTrfDocDetail] PRIMARY KEY CLUSTERED ([STDNo], [STDLineNO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_idsStkTrfDocDetail_ID] ON [dbo].[idsStkTrfDocDetail] ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[idsStkTrfDocDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[idsStkTrfDocDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[idsStkTrfDocDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[idsStkTrfDocDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDocDetail', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDocDetail', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of production.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDocDetail', 'COLUMN', N'ProductionDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDocDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDocDetail', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDocDetail', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDocDetail', 'COLUMN', N'ToLoc'
GO
