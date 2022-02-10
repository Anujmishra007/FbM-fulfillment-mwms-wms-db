CREATE TABLE [dbo].[BrokerageDetail]
(
[BrokerageDetailKey] [bigint] NOT NULL IDENTITY(1, 1),
[BrokerageKey] [bigint] NOT NULL,
[BrokerageLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BrokerageDetail_BrokerageLineNumber] DEFAULT (' '),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BrokerageExternKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BrokerageDetail_BrokerageExternKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BrokerageDetail_ExternLineNo] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Sku] DEFAULT (NULL),
[SkuDescription] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_SkuDescription] DEFAULT (' '),
[Qty] [int] NULL CONSTRAINT [DF_BrokerageDetail_Qty] DEFAULT ('0'),
[UnitPrice] [float] NULL CONSTRAINT [DF_BrokerageDetail_UnitPrice] DEFAULT ('0'),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_UOM] DEFAULT (' '),
[HTSCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_HTSCode] DEFAULT (' '),
[CountryOfOrigin] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_CountryOfOrigin] DEFAULT (' '),
[Notes] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Notes] DEFAULT (' '),
[Userdefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine01] DEFAULT (' '),
[Userdefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine02] DEFAULT (' '),
[Userdefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine03] DEFAULT (' '),
[Userdefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine04] DEFAULT (' '),
[Userdefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine05] DEFAULT (' '),
[Userdefine06] [datetime] NULL,
[Userdefine07] [datetime] NULL,
[Userdefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine08] DEFAULT (' '),
[Userdefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine09] DEFAULT (' '),
[Userdefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_Userdefine10] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_BrokerageDetail_AddDate] DEFAULT (getdate()),
[AddWho] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_BrokerageDetail_EditDate] DEFAULT (getdate()),
[EditWho] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BrokerageDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BrokerageDetail] ADD CONSTRAINT [PK_BrokerageDetail] PRIMARY KEY CLUSTERED ([BrokerageDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BD_ExternBrokerage] ON [dbo].[BrokerageDetail] ([BrokerageExternKey], [ExternLineNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BD_Brokerage] ON [dbo].[BrokerageDetail] ([Storerkey], [BrokerageKey], [BrokerageLineNumber]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BrokerageDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BrokerageDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BrokerageDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BrokerageDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'A BrokerageDetail is to record the products and quantity of each commodity ordered.', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, record will be verified and archive process to perform data archiving to the table in Archive DB.', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific Brokerage Detail record. Automatically generated', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'BrokerageDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'External Brokerage key', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'BrokerageExternKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific Brokerage record. Key captures based on the Brokerage header table.', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'BrokerageKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique Brokerage Detail Line Number for each BrokerageKey.', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'BrokerageLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Country where the goods are originated from', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'CountryOfOrigin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'External Brokerage line number', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Harmonized Traffic Schedule Code', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'HTSCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity of item', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item / Product Code', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item / Product''s description', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'SkuDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WMS Storer', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit price of item', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit of measurement of item', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine1', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine2', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine3', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine4', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine5', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine6 - datetime field', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine7 - datetime field', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine8', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine9', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BrokerageDetail Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'BrokerageDetail', 'COLUMN', N'Userdefine10'
GO
