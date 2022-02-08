CREATE TABLE [dbo].[WorkOrderJob]
(
[SerialKey] [int] NOT NULL IDENTITY(1, 1),
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJob_JobKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJob_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJob_Storerkey] DEFAULT (''),
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJob_WorkOrderKey] DEFAULT (''),
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJob_WorkOrderName] DEFAULT (''),
[Sequence] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyRemaining] [int] NULL CONSTRAINT [DF_WorkOrderJob_QtyRemaining] DEFAULT ((0)),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeRate] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderJob_TimeRate] DEFAULT (''),
[NoOfAssignedWorker] [int] NOT NULL CONSTRAINT [DF_WorkOrderJob_NoOfAssignedWorker] DEFAULT ((0)),
[STDTime] [float] NOT NULL CONSTRAINT [DF_WorkOrderJob_STDTime] DEFAULT ((0.00)),
[EstMins] [int] NOT NULL CONSTRAINT [DF_WorkOrderJob_EstMins] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJob_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkOrderJob_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderJob_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkOrderJob_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyJob] [int] NULL CONSTRAINT [DF_WORKORDERJOB_QtyJob] DEFAULT ((0)),
[QtyCompleted] [int] NULL CONSTRAINT [DF_WORKORDERJOB_QtyCompleted] DEFAULT ((0)),
[JobStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WORKORDERJOB_JobStatus] DEFAULT ('0'),
[UOMQtyJob] [int] NULL CONSTRAINT [DF_WORKORDERJOB_UOMQtyJob] DEFAULT ((0)),
[QtyReleased] [int] NULL CONSTRAINT [DF_WORKORDERJOB_QtyReleased] DEFAULT ((0)),
[Start_Production] [datetime] NULL,
[End_Production] [datetime] NULL,
[InLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderJob] ADD CONSTRAINT [PK_WorkOrderJob] PRIMARY KEY CLUSTERED ([SerialKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderJob] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderJob] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderJob] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderJob] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Workorder job Released Qty', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJob', 'COLUMN', N'QtyReleased'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM Qty for QtyJob', 'SCHEMA', N'dbo', 'TABLE', N'WorkOrderJob', 'COLUMN', N'UOMQtyJob'
GO
