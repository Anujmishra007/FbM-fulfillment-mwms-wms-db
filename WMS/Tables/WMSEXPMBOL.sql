CREATE TABLE [dbo].[WMSEXPMBOL]
(
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Consigneekey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginalQty] [int] NOT NULL,
[ShippedQty] [int] NOT NULL,
[Shortqty] [int] NULL,
[TRANSFLAG] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NULL,
[EditDate] [datetime] NULL,
[TotalCarton] [int] NULL CONSTRAINT [DF_WMSEXPMBOL_TotalCarton] DEFAULT ((0)),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WMSEXPMBOL_StorerKey] DEFAULT (' ')
) ON [PRIMARY]
GO

CREATE UNIQUE CLUSTERED INDEX [WMSEXPMBOL_Index_1] ON [dbo].[WMSEXPMBOL] ([ExternOrderkey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_WMSEXPMBOL_TransFlag] ON [dbo].[WMSEXPMBOL] ([TRANSFLAG]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMSEXPMBOL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'Consigneekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'WMSEXPMBOL', 'COLUMN', N'StorerKey'
GO
