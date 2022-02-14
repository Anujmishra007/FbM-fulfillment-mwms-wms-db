CREATE TABLE [dbo].[GUIDetail]
(
[InvoiceNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineNumber] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_GUIDetail_Qty] DEFAULT ((0)),
[UnitPrice] [money] NOT NULL CONSTRAINT [DF_GUIDetail_UnitPrice] DEFAULT ((0)),
[Amount] [money] NOT NULL CONSTRAINT [DF_GUIDetail_Amount] DEFAULT ((0)),
[DiscAmount] [money] NOT NULL CONSTRAINT [DF_GUIDetail_DiscAmount] DEFAULT ((0)),
[SKUDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUIDetail_SKUDesc] DEFAULT (' '),
[UOM] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GUIDetail_UOM] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GUIDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GUIDetail_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remarks] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUIDetail_Remarks] DEFAULT (' '),
[IndicatorFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL CONSTRAINT [DF_GUIDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUIDetail_EditWho] DEFAULT (suser_sname()),
[UserDefine01] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine07] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine08] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GUIDetail] ADD CONSTRAINT [PK_GUIDetail] PRIMARY KEY CLUSTERED ([InvoiceNo], [ExternOrderkey], [Storerkey], [LineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GUIDetail_ExternOrderkey] ON [dbo].[GUIDetail] ([ExternOrderkey], [Storerkey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GUIDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GUIDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GUIDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GUIDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by Storer.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'SKUDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine10'
GO
