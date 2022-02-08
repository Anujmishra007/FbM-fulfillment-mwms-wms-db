CREATE TABLE [dbo].[PTRACEHEAD]
(
[PTRACETYPE] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PTRACEHEADKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Userid] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[PA_MultiProduct] [int] NULL,
[PA_MultiLot] [int] NULL,
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[PA_LocsReviewed] [int] NULL,
[PA_LocFound] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PTRACEHEAD] ADD CONSTRAINT [PKPTRACEHEAD] PRIMARY KEY CLUSTERED ([PTRACEHEADKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PTRACEHEAD] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PTRACEHEAD] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PTRACEHEAD] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PTRACEHEAD] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEHEAD', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEHEAD', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEHEAD', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEHEAD', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEHEAD', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEHEAD', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying User.', 'SCHEMA', N'dbo', 'TABLE', N'PTRACEHEAD', 'COLUMN', N'Userid'
GO
