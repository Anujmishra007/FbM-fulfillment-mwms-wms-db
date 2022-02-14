CREATE TABLE [dbo].[OrderInfo]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderInfo01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo01] DEFAULT (' '),
[OrderInfo02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo02] DEFAULT (' '),
[OrderInfo03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo03] DEFAULT (' '),
[OrderInfo04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo04] DEFAULT (' '),
[OrderInfo05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo05] DEFAULT (' '),
[OrderInfo06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo06] DEFAULT (' '),
[OrderInfo07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo07] DEFAULT (' '),
[OrderInfo08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo08] DEFAULT (' '),
[OrderInfo09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo09] DEFAULT (' '),
[OrderInfo10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo10] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_OrderInfo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_OrderInfo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EcomOrderId] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_EcomOrderId] DEFAULT (''),
[ReferenceId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_ReferenceId] DEFAULT (''),
[StoreName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_StoreName] DEFAULT (''),
[Platform] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_Platform] DEFAULT (''),
[InvoiceType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_InvoiceType] DEFAULT (''),
[PmtDate] [datetime] NULL,
[InsuredAmount] [float] NULL CONSTRAINT [DF_OrderInfo_InsuredAmount] DEFAULT ((0)),
[CarrierCharges] [float] NULL CONSTRAINT [DF_OrderInfo_CarrierCharges] DEFAULT ((0)),
[OtherCharges] [float] NULL CONSTRAINT [DF_OrderInfo_OtherCharges] DEFAULT ((0)),
[PayableAmount] [float] NULL CONSTRAINT [DF_OrderInfo_PayableAmount] DEFAULT ((0)),
[DeliveryMode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_DeliveryMode] DEFAULT ('LTL'),
[CarrierName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_CarrierName] DEFAULT (''),
[DeliveryCategory] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_DeliveryCategory] DEFAULT ('NORMAL'),
[Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_Notes] DEFAULT (''),
[Notes2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_Notes2] DEFAULT (''),
[OTM_OrderOwner] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERINFO_OTM_OrderOwner] DEFAULT (''),
[OTM_BillTo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERINFO_OTM_BillTo] DEFAULT (''),
[OTM_NotifyParty] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERINFO_OTM_NotifyParty] DEFAULT (''),
[CourierTimeStamp] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_CourierTimeStamp] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OrderInfo] ADD CONSTRAINT [PK_OrderInfo] PRIMARY KEY CLUSTERED ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[OrderInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[OrderInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderInfo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'OrderKey'
GO
