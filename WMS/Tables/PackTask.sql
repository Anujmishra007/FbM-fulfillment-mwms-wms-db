CREATE TABLE [dbo].[PackTask]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_Orderkey] DEFAULT (''),
[TaskBatchNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_TaskBatchNo] DEFAULT (''),
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_DevicePosition] DEFAULT (''),
[LogicalName] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_LogicalName] DEFAULT (''),
[OrderMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_OrderMode] DEFAULT (''),
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_UDF05] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackTask_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackTask_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackTask_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenishmentGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKTASK_ReplenishmentGroup] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PackTask] ADD CONSTRAINT [PK__PackTask__50738165219C2D07] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PACKTASK_Orderkey] ON [dbo].[PackTask] ([Orderkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PACKTASK_TASKBATCHNO] ON [dbo].[PackTask] ([TaskBatchNo], [Orderkey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PackTask] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PackTask] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackTask] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackTask] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackTask] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'ECOM outbound', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Assign Picking/Sorting Position to Orders', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'DevicePosition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Assign Picking/Sorting Logical Device Position to Orders', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'LogicalName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Orderkey reference', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order Mode; M-1,M-4,M-5,S-9 (M-Multi, S-Single)', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'OrderMode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Group', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'ReplenishmentGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identity row running no ', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Task Batch No', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'TaskBatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'UDF01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'UDF02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'UDF03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'UDF04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'PackTask', 'COLUMN', N'UDF05'
GO
