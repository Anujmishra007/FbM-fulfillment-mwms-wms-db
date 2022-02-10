CREATE TABLE [dbo].[ORDERS_TADDED]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ORDERS_TADDED_Storerkey] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_TADDED_Facility] DEFAULT (' '),
[Adddate] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderCnt] [int] NOT NULL,
[Transmitflag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERS_TADDED_Transmitflag] DEFAULT ('0')
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ORDERS_TADDED] ON [dbo].[ORDERS_TADDED] ([Storerkey], [Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ORDERS_TADDED] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ORDERS_TADDED] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ORDERS_TADDED] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ORDERS_TADDED] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_TADDED', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_TADDED', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'ORDERS_TADDED', 'COLUMN', N'Storerkey'
GO
