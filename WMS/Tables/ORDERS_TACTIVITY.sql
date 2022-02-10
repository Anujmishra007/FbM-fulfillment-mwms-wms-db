CREATE TABLE [dbo].[ORDERS_TACTIVITY]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_TACTIVITY_Storerkey] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_TACTIVITY_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_TACTIVITY_Status] DEFAULT (' '),
[OrderCnt] [int] NOT NULL,
[Event_Hour] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Transmitflag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_TACTIVITY_Transmitflag] DEFAULT ('0')
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ORDERS_TACTIVITY] ON [dbo].[ORDERS_TACTIVITY] ([Storerkey], [Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ORDERS_TACTIVITY] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERS_TACTIVITY] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERS_TACTIVITY] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERS_TACTIVITY] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_TACTIVITY', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_TACTIVITY', 'COLUMN', N'Storerkey'
GO
