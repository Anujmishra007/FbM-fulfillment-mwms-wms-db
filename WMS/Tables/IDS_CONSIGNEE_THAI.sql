CREATE TABLE [dbo].[IDS_CONSIGNEE_THAI]
(
[customer_id] [int] NOT NULL,
[customer_number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_name] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address6] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address3] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address4] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IDS_CONSIGNEE_THAI] ADD CONSTRAINT [PK_IDS_CONSIGNEE_THAI] PRIMARY KEY CLUSTERED ([customer_number], [address6]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_CONSIGNEE_THAI] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_CONSIGNEE_THAI] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_CONSIGNEE_THAI] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_CONSIGNEE_THAI] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'address1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'address2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'address3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'address4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Customer.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'customer_id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of the Customer.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'customer_name'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying the Customer.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'customer_number'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Location.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_CONSIGNEE_THAI', 'COLUMN', N'location_number'
GO
