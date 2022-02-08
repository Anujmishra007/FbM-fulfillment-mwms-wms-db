CREATE TABLE [dbo].[TaskDetail_WIP]
(
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[TaskWIPBatchNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_TaskWIPBatchNo] DEFAULT (''),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_TaskDetailKey] DEFAULT (' '),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_TaskType] DEFAULT (' '),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Lot] DEFAULT (' '),
[UOM] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_UomQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Qty] DEFAULT ((0)),
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_FromLoc] DEFAULT (' '),
[LogicalFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_LogicalFromLoc] DEFAULT (' '),
[FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_FromID] DEFAULT (' '),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_ToLoc] DEFAULT (' '),
[LogicalToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_LogicalToLoc] DEFAULT (' '),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_ToID] DEFAULT (' '),
[Caseid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Caseid] DEFAULT (' '),
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_PickMethod] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Status] DEFAULT ('0'),
[StatusMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Statusmsg] DEFAULT (' '),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Priority] DEFAULT (' '),
[SourcePriority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_SourcePriority] DEFAULT (' '),
[Holdkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_HOLDKEY] DEFAULT (' '),
[UserKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_UserKey] DEFAULT (' '),
[UserPosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_UserPosition] DEFAULT ('1'),
[UserKeyOverRide] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_UserKeyOverRide] DEFAULT (' '),
[StartTime] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_StartTime] DEFAULT (getdate()),
[EndTime] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_EndTime] DEFAULT (getdate()),
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_SourceType] DEFAULT (' '),
[SourceKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_SourceKey] DEFAULT (' '),
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_PickDetailkey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Orderkey] DEFAULT (' '),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_OrderLineNumber] DEFAULT (' '),
[ListKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_ListKey] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_WaveKey] DEFAULT (' '),
[ReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Reasonkey] DEFAULT (' '),
[Message01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Message01] DEFAULT (' '),
[Message02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Message02] DEFAULT (' '),
[Message03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_Message03] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemQty] [int] NOT NULL CONSTRAINT [DF_TASKDETAIL_WIP_SystemQty] DEFAULT ((0)),
[RefTaskKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_RefTaskKey] DEFAULT (' '),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_LoadKey] DEFAULT (' '),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_AreaKey] DEFAULT (' '),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_DropID] DEFAULT (''),
[TransitCount] [int] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_TransitCount] DEFAULT ((0)),
[TransitLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_TransitLOC] DEFAULT (''),
[FinalLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_FinalLOC] DEFAULT (''),
[FinalID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_FinalID] DEFAULT (''),
[Groupkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WIP_GroupKey] DEFAULT (''),
[PendingMoveIn] [int] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_PendingMoveIn] DEFAULT ((0)),
[QtyReplen] [int] NOT NULL CONSTRAINT [DF_TaskDetail_WIP_QtyReplen] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TaskDetail_WIP] ADD CONSTRAINT [PKTaskDetail_WIP] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BTB_TaskDetail_WIP_BatchNo] ON [dbo].[TaskDetail_WIP] ([TaskWIPBatchNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TaskDetail_WIP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskDetail_WIP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskDetail_WIP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskDetail_WIP] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'System generate all tasks to the Task Detail table, these tasks are then released to the authorized workers through RDT terminals according to the task priority, location & task type.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'Caseid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ID or Tag number assigned to the Commodity to be moved. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'FromID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Hold.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'Holdkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying List.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'ListKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pending Move In Qty', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'PendingMoveIn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Pick Detail.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity to be replenished', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'QtyReplen'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Reason.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'ReasonKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Taskdetail WIP Row ID.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'RowID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Source.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Task Detail.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Taskdetail WIP BatchNo.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'TaskWIPBatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'New ID or Tag number to be assigned to the Commodity at the location. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'ToID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Users.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'UserKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail_WIP', 'COLUMN', N'WaveKey'
GO
