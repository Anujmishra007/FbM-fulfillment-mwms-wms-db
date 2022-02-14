CREATE TABLE [dbo].[LoadPlanDetail]
(
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanDetail_OrderKey] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderDate] [datetime] NULL,
[DeliveryDate] [datetime] NULL,
[DeliveryPlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stop] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL CONSTRAINT [DF_LoadPlanDetail_Weight] DEFAULT ((0)),
[Cube] [float] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_Status] DEFAULT ('0'),
[CaseCnt] [int] NULL CONSTRAINT [DF_LoadPlanDetail_CaseCnt] DEFAULT ((0)),
[NoOfOrdLines] [int] NULL CONSTRAINT [DF_LoadPlanDetail_NoOfOrdLines] DEFAULT ((0)),
[Rdd] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_LoadPlanDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_LoadPlanDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine10] DEFAULT (' '),
[ExternLoadKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_ExternLoadKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_ExternLineNo] DEFAULT (' ')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[LoadPlanDetail] ADD CONSTRAINT [PK_LoadPlanDetail] PRIMARY KEY CLUSTERED ([LoadKey], [LoadLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_loadplandetail_Orderkey] ON [dbo].[LoadPlanDetail] ([OrderKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoadPlanDetail] WITH NOCHECK ADD CONSTRAINT [FK_LoadPlanDetail_LoadPlan] FOREIGN KEY ([LoadKey]) REFERENCES [dbo].[LoadPlan] ([LoadKey])
GO
GRANT SELECT ON  [dbo].[LoadPlanDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load Plan Detail consists of all the orders in a load that will be delivered together in one truck to specific drops (stops)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total case count for the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consignee in which the order will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total order cubic', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer company name', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'CustomerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cancel Date', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship to address - province', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'DeliveryPlace'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Loading door for the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Door'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Load used by the Storer. ', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'ExternLoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller/storer external order number', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load plan other reference number - if any', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load detail line number', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'LoadLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total line numbers for the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'NoOfOrdLines'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date in which the orders were allocated', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order number. It''s used to identify a specific shipment order record', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority:', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery route under the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Route'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load plan status', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The sequence in which the order will be dropped off during the delivery round', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Stop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of customer order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total order weight', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Weight'
GO
