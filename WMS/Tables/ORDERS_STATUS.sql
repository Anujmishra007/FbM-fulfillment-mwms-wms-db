CREATE TABLE [dbo].[ORDERS_STATUS]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_STATUS_Storerkey] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_STATUS_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_STATUS_Status] DEFAULT (' '),
[OrderCnt] [int] NOT NULL,
[Delivery_Flag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Full_Fill] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalQty] [bigint] NOT NULL,
[ShippedQty] [bigint] NOT NULL,
[EarlierDelivery] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Transmitflag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_STATUS_Transmitflag] DEFAULT ('0')
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ORDERS_STATUS] ON [dbo].[ORDERS_STATUS] ([Storerkey], [Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ORDERS_STATUS] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERS_STATUS] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERS_STATUS] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERS_STATUS] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_STATUS', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_STATUS', 'COLUMN', N'Storerkey'
GO
