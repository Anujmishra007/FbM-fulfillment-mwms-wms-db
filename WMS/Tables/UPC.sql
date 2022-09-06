CREATE TABLE [dbo].[UPC]
(
[UPC] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPC_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_UPC_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPC_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_UPC_EditDate] DEFAULT (getdate()),
QTY         INT NULL CONSTRAINT DF_UPC_QTY DEFAULT 0
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[UPC] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[UPC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPC] TO [NSQL]
GO

ALTER TABLE [dbo].[UPC] ADD CONSTRAINT [PK_UPC] PRIMARY KEY CLUSTERED ([StorerKey], [SKU], [UPC]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [UPC_sku_idx] ON [dbo].[UPC] ([StorerKey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UPC01] ON [dbo].[UPC] ([StorerKey], [UPC]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UPC] WITH NOCHECK ADD CONSTRAINT [FK_UPC_SKU_01] FOREIGN KEY ([StorerKey], [SKU]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Universal Product Code (UPC) / SKU Alias. Commodities in a warehouse can be identified with a variety of labels, each referring to the product by a different name or item number.', 'SCHEMA', N'dbo', 'TABLE', N'UPC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack key of the SKU', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SKU Unit of measurement e.g. case, each, inners', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique number or barcode that identifies an individual product by UOM', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'UPC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quatity', 'SCHEMA', N'dbo', 'TABLE', N'UPC', 'COLUMN', N'Qty'
GO

/*

--  JR WMS-20664 [CN] CN_Yonex_ADD UPC.QTY

ALTER TABLE dbo.UPC
ADD QTY  INT NULL CONSTRAINT DF_UPC_QTY DEFAULT 0
GO
 
 

*/