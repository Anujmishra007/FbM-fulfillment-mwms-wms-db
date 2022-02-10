CREATE TABLE [dbo].[ORDERS_ALERT]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_ALERT_Storerkey] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_ALERT_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_ALERT_Status] DEFAULT (' '),
[OrderCnt] [int] NOT NULL,
[Aging_Hours] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Transmitflag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_ALERT_Transmitflag] DEFAULT ('0')
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ORDERS_ALERT] ON [dbo].[ORDERS_ALERT] ([Storerkey], [Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ORDERS_ALERT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERS_ALERT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERS_ALERT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERS_ALERT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_ALERT', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_ALERT', 'COLUMN', N'Storerkey'
GO
