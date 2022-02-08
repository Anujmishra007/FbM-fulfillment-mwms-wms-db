CREATE TABLE [dbo].[WMSEXPMBOLBK]
(
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Consigneekey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginalQty] [int] NOT NULL,
[ShippedQty] [int] NOT NULL,
[Shortqty] [int] NULL,
[TRANSFLAG] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMSEXPMBOLBK] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMSEXPMBOLBK] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMSEXPMBOLBK] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMSEXPMBOLBK] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOLBK', 'COLUMN', N'Consigneekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOLBK', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOLBK', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOLBK', 'COLUMN', N'SKU'
GO
