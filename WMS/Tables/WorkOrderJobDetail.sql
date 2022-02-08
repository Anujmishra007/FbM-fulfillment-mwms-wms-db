CREATE TABLE [dbo].[WorkOrderJobDetail]
(
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_JobKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_Storerkey] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_MasterWorkOrder] DEFAULT (''),
[JobStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_JobStatus] DEFAULT ('0'),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_Priority] DEFAULT ('9'),
[EstJobStartTime] [datetime] NULL CONSTRAINT [DF_WorkOrderJobDetail_EstJobStartTime] DEFAULT (getdate()),
[EstJobDuration] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_EstJobDuration] DEFAULT ((0)),
[EstCompletionTime] [datetime] NULL,
[ActualJobStartTime] [datetime] NULL,
[ActualJobDuration] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_ActualJobDuration] DEFAULT ((0)),
[ActualCompletionTime] [datetime] NULL,
[RemainingDuration] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_RemainingDuration] DEFAULT ((0)),
[QAType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QAValue] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QAValue] DEFAULT ((0)),
[QALocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TempStaging] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WORelease] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOfWorkStation] [int] NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_NoOfWorkStation] DEFAULT ((0)),
[NoOfAssignedWorker] [int] NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_NoOfAssignedWorker] DEFAULT ((0)),
[EstUnitPerHour] [int] NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_EstUnitPerHour] DEFAULT ((0)),
[ActualUnitPerHour] [int] NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_ActualUnitPerHour] DEFAULT ((0)),
[AvgUnitPerWorker] [float] NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_AvgUnitPerWorker] DEFAULT ((0.00)),
[QtyJob] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyJob] DEFAULT ((0)),
[QtyReleased] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyReleased] DEFAULT ((0)),
[QtyRemaining] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyRemaining] DEFAULT ((0)),
[QtyCompleted] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyCompleted] DEFAULT ((0)),
[QtyItemsOrd] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyItemsOrd] DEFAULT ((0)),
[QtyItemsRes] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyItemsRes] DEFAULT ((0)),
[QtyItemsNeed] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyItemsNeed] DEFAULT ((0)),
[QtyNonInvOrd] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyNonInvOrd] DEFAULT ((0)),
[QtyNonInvRes] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyNonInvRes] DEFAULT ((0)),
[QtyNonInvNeed] [int] NULL CONSTRAINT [DF_WorkOrderJobDetail_QtyNonInvNeed] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJobDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderJobDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMQtyJob] [int] NULL CONSTRAINT [DF_WORKORDERJOBDETAIL_UOMQtyJob] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderJobDetail] ADD CONSTRAINT [PK_WorkOrderJobDetail] PRIMARY KEY CLUSTERED ([JobKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderJobDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderJobDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderJobDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderJobDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM Qty for QtyJob', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJobDetail', 'COLUMN', N'UOMQtyJob'
GO
