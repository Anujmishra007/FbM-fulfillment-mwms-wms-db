CREATE TABLE [dbo].[TaskDetail]
(
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_TaskDetailKey] DEFAULT (' '),
[TaskType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_TaskType] DEFAULT (' '),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Storerkey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Lot] DEFAULT (' '),
[UOM] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_TaskDetail_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_TaskDetail_Qty] DEFAULT ((0)),
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_FromLoc] DEFAULT (' '),
[LogicalFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_LogicalFromLoc] DEFAULT (' '),
[FromID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_FromID] DEFAULT (' '),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_ToLoc] DEFAULT (' '),
[LogicalToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_LogicalToLoc] DEFAULT (' '),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_ToID] DEFAULT (' '),
[Caseid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Caseid] DEFAULT (' '),
[PickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_PickMethod] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Status] DEFAULT ('0'),
[StatusMsg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_StatusMsg] DEFAULT (' '),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Priority] DEFAULT (' '),
[SourcePriority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_SourcePriority] DEFAULT (' '),
[Holdkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Holdkey] DEFAULT (' '),
[UserKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_UserKey] DEFAULT (' '),
[UserPosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_UserPosition] DEFAULT ('1'),
[UserKeyOverRide] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_UserKeyOverRide] DEFAULT (' '),
[StartTime] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_StartTime] DEFAULT (getdate()),
[EndTime] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_EndTime] DEFAULT (getdate()),
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_SourceType] DEFAULT (' '),
[SourceKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_SourceKey] DEFAULT (' '),
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_PickDetailKey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_OrderKey] DEFAULT (' '),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_OrderLineNumber] DEFAULT (' '),
[ListKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_ListKey] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_WaveKey] DEFAULT (' '),
[ReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_ReasonKey] DEFAULT (' '),
[Message01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Message01] DEFAULT (' '),
[Message02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Message02] DEFAULT (' '),
[Message03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_Message03] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_TaskDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemQty] [int] NULL CONSTRAINT [DF_TaskDetail_SystemQty] DEFAULT ((0)),
[RefTaskKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_RefTaskKey] DEFAULT (' '),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_LoadKey] DEFAULT (' '),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_AreaKey] DEFAULT (' '),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_DropID] DEFAULT (''),
[TransitCount] [int] NOT NULL CONSTRAINT [DF_TaskDetail_TransitCount] DEFAULT ((0)),
[TransitLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_TransitLOC] DEFAULT (''),
[FinalLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_FinalLOC] DEFAULT (''),
[FinalID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TaskDetail_FinalID] DEFAULT (''),
[Groupkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskDetail_GroupKey] DEFAULT (''),
[PendingMoveIn] [int] NULL CONSTRAINT [DF_TaskDetail_PendingMoveIn] DEFAULT ((0)),
[QtyReplen] [int] NULL CONSTRAINT [DF_TaskDetail_QtyReplen] DEFAULT ((0)),
[DeviceID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskDetail_DeviceID] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TaskDetail] ADD CONSTRAINT [PKTaskDetail] PRIMARY KEY CLUSTERED ([TaskDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TASKDETAIL_CASEID] ON [dbo].[TaskDetail] ([Caseid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TASKDETAIL_DROPID] ON [dbo].[TaskDetail] ([DropID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_taskdetail_dropid] ON [dbo].[TaskDetail] ([DropID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TASKDETAIL_FROMID] ON [dbo].[TaskDetail] ([FromID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TASKDETAIL_ORDERKEY] ON [dbo].[TaskDetail] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Taskdetail_PickDetailKey] ON [dbo].[TaskDetail] ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TASKDETAIL_STATUS] ON [dbo].[TaskDetail] ([Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TASKDETAIL_TASKTYPE] ON [dbo].[TaskDetail] ([TaskType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TASKDETAIL_WAVEKEY] ON [dbo].[TaskDetail] ([WaveKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TaskDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[TaskDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TaskDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TaskDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TaskDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'System generate all tasks to the Task Detail table, these tasks are then released to the authorized workers through RDT terminals according to the task priority, location & task type.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'Caseid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store Device ID Value', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'DeviceID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet ID when reach destination', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'FinalID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ID or Tag number assigned to the Commodity to be moved. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'FromID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Hold.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'Holdkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying List.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'ListKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric value associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Detail.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Reason.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'ReasonKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Source.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'SourceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Task Detail.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'TaskDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'New ID or Tag number to be assigned to the Commodity at the location. (If applicable)', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'ToID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Users.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'UserKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'TaskDetail', 'COLUMN', N'WaveKey'
GO
