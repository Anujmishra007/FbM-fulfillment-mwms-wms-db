CREATE TABLE [dbo].[OriginAllocQty]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QtyAllocated] [int] NULL CONSTRAINT [DF_OriginAllocQty_QtyAllocated] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_OriginAllocQty_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OriginAllocQty_AddWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OriginAllocQty] ADD CONSTRAINT [PK_OriginAllocQty] PRIMARY KEY CLUSTERED ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OriginAllocQty] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OriginAllocQty] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OriginAllocQty] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OriginAllocQty] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OriginAllocQty', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'OriginAllocQty', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'OriginAllocQty', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently allocated in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'OriginAllocQty', 'COLUMN', N'QtyAllocated'
GO
