CREATE TABLE [dbo].[WorkOrder]
(
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_WorkOrderKey] DEFAULT (' '),
[ExternWorkOrderKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_ExternWorkOrderKey] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_StorerKey] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Facility] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Status] DEFAULT ('0'),
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_ExternStatus] DEFAULT ('0'),
[Type] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Type] DEFAULT (' '),
[Reason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_Reason] DEFAULT (' '),
[TotalPrice] [money] NULL CONSTRAINT [DF_WorkOrder_TotalPrice] DEFAULT ((0)),
[GenerateCharges] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_GenerateCharges] DEFAULT ('No'),
[Remarks] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Remarks] DEFAULT (' '),
[Notes1] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Notes1] DEFAULT (' '),
[Notes2] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_Notes2] DEFAULT (' '),
[WkOrdUdef1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef1] DEFAULT (' '),
[WkOrdUdef2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef2] DEFAULT (' '),
[WkOrdUdef3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef3] DEFAULT (' '),
[WkOrdUdef4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef4] DEFAULT (' '),
[WkOrdUdef5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef5] DEFAULT (' '),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkOrder_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WkOrdUdef6] [datetime] NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef6] DEFAULT (' '),
[WkOrdUdef7] [datetime] NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef7] DEFAULT (' '),
[WkOrdUdef8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef8] DEFAULT (' '),
[WkOrdUdef9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef9] DEFAULT (' '),
[WkOrdUdef10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrder_WkOrdUdef10] DEFAULT (' ')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrder] ADD CONSTRAINT [PK_WorkOrder] PRIMARY KEY CLUSTERED ([WorkOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WORKORDER_ExternWorkOrdKey] ON [dbo].[WorkOrder] ([ExternWorkOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrder] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrder] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrder] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrder] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the external workorder status', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'ExternStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'this field stores the external Workorder reference number (if any)', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'ExternWorkOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'key in the facility from which the goods are residing', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'indicate whether charges are to be generated', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'GenerateCharges'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about workorder.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Notes1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'instructions on the Workorder are to be recorded here', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Notes2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the reason of the Workorder activities', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Reason'
GO
EXEC sp_addextendedproperty N'MS_Description', 'any remarks or notes', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'type the name of the storer whom the goods belong to', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'the total price of the transactions which is computed based on the detail lines', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'TotalPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'key in the Workorder type', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 10', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 6', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 7', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 8', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work Order Userdefine 9', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WkOrdUdef9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'use the default', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrder', 'COLUMN', N'WorkOrderKey'
GO
