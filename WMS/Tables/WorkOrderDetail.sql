CREATE TABLE [dbo].[WorkOrderDetail]
(
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_WorkOrderKey] DEFAULT (' '),
[WorkOrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_WorkOrderLineNumber] DEFAULT (' '),
[ExternWorkOrderKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_ExternWorkOrderKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_ExternLineNo] DEFAULT (' '),
[Type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_Type] DEFAULT (' '),
[Reason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_Reason] DEFAULT (' '),
[Unit] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_Unit] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_WorkOrderDetail_Qty] DEFAULT ((0)),
[Price] [money] NOT NULL CONSTRAINT [DF_WorkOrderDetail_Price] DEFAULT ((0)),
[LineValue] [money] NULL CONSTRAINT [DF_WorkOrderDetail_LineValue] DEFAULT ((0)),
[Remarks] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_Remarks] DEFAULT (' '),
[WkOrdUdef1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef1] DEFAULT (' '),
[WkOrdUdef2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef2] DEFAULT (' '),
[WkOrdUdef3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef3] DEFAULT (' '),
[WkOrdUdef4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef4] DEFAULT (' '),
[WkOrdUdef5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef5] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_Sku] DEFAULT (' '),
[WkOrdUdef6] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef6] DEFAULT (' '),
[WkOrdUdef7] [datetime] NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef7] DEFAULT (' '),
[WkOrdUdef8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef8] DEFAULT (' '),
[WkOrdUdef9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef9] DEFAULT (' '),
[WkOrdUdef10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderDetail_WkOrdUdef10] DEFAULT (' ')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderDetail] ADD CONSTRAINT [PK_WorkOrderDetail] PRIMARY KEY CLUSTERED ([WorkOrderKey], [WorkOrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WORKORDERDETAIL_ExtWorkOrderKey] ON [dbo].[WorkOrderDetail] ([ExternWorkOrderKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External Workorder line number', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying workorder used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'ExternWorkOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Computed field where the quantity * price', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'LineValue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the price of the service', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', 'quantity', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'remark per detail line', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'unit of measurement', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'Unit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 10', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line user defined', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef5'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 6', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 7', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 8', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Detail Userdefine 9', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WkOrdUdef9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying workorder.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WorkOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Workorder transaction line number. Use default', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderDetail', 'COLUMN', N'WorkOrderLineNumber'
GO
