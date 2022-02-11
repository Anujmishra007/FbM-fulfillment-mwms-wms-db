CREATE TABLE [dbo].[OrderScan]
(
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScanDate] [datetime] NOT NULL CONSTRAINT [DF_OrderScan_ScanDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OrderScan] ADD CONSTRAINT [PK_ORDERSCAN] PRIMARY KEY CLUSTERED ([Loadkey], [Orderkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderScan] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderScan] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderScan] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderScan] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'OrderScan', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'OrderScan', 'COLUMN', N'Orderkey'
GO
