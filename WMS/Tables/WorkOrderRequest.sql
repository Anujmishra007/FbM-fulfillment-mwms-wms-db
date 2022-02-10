CREATE TABLE [dbo].[WorkOrderRequest]
(
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_WorkOrderKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_Storerkey] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_MasterWorkOrder] DEFAULT (''),
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_WorkOrderName] DEFAULT (''),
[StartDate] [datetime] NULL CONSTRAINT [DF_WorkOrderRequest_StartDate] DEFAULT (getdate()),
[DueDate] [datetime] NULL CONSTRAINT [DF_WorkOrderRequest_DueDate] DEFAULT (getdate()),
[ExternalReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_ExternalReference] DEFAULT (''),
[Qty] [int] NULL CONSTRAINT [DF_WorkOrderRequest_Qty] DEFAULT ((0)),
[QtyJob] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyJob] DEFAULT ((0)),
[QtyReleased] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyReleased] DEFAULT ((0)),
[QtyCompleted] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyCompleted] DEFAULT ((0)),
[QtyRemaining] [int] NULL CONSTRAINT [DF_WorkOrderRequest_QtyRemaining] DEFAULT ((0)),
[WOStatus] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_WOStatus] DEFAULT ('0'),
[Priority] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_Priority] DEFAULT ('9'),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_WorkStation] DEFAULT (''),
[Notes] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_Notes] DEFAULT (''),
[UDF1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF1] DEFAULT (''),
[UDF2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF2] DEFAULT (''),
[UDF3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF3] DEFAULT (''),
[UDF4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF4] DEFAULT (''),
[UDF5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRequest_UDF5] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequest_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRequest_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRequest_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMQty] [int] NULL CONSTRAINT [DF_WORKORDERREQUEST_UOMQty] DEFAULT ((0)),
[UOMQtyRemaining] [int] NULL CONSTRAINT [DF_WORKORDERREQUEST_UOMQtyRemaining] DEFAULT ((0)),
[PackQty] [int] NULL CONSTRAINT [DF_WORKORDERREQUEST_PackQty] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderRequest] ADD CONSTRAINT [PK_WorkOrderRequest] PRIMARY KEY CLUSTERED ([WorkOrderKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderRequest] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Packing Qty', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderRequest', 'COLUMN', N'PackQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM Qty for Qty', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderRequest', 'COLUMN', N'UOMQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM Qty for Qty Remaining', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderRequest', 'COLUMN', N'UOMQtyRemaining'
GO
