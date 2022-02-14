CREATE TABLE [dbo].[idsPallet]
(
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[uom] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[batchno] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[productiondate] [datetime] NOT NULL,
[clearingdate] [datetime] NULL,
[printed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsPallet_printed] DEFAULT ('N'),
[addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsPallet_addwho] DEFAULT (suser_sname()),
[adddate] [datetime] NOT NULL CONSTRAINT [DF_idsPallet_adddate] DEFAULT (getdate()),
[editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsPallet_editwho] DEFAULT (suser_sname()),
[editdate] [datetime] NOT NULL CONSTRAINT [DF_idsPallet_editdate] DEFAULT (getdate()),
[SYSID] [int] NULL,
[lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_idsPallet_lottable01] DEFAULT (' '),
[lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_idsPallet_lottable03] DEFAULT (' ')
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_idsPallet_sku] ON [dbo].[idsPallet] ([SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[idsPallet] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[idsPallet] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[idsPallet] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[idsPallet] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'ID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of production.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'productiondate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying system. ', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'SYSID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'idsPallet', 'COLUMN', N'uom'
GO
