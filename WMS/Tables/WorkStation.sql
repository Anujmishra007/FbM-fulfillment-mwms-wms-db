CREATE TABLE [dbo].[WorkStation]
(
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_WorkZone] DEFAULT ('RACK'),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkMethod] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_WorkMethod] DEFAULT (''),
[Descr] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOfAssignedWorker] [int] NULL CONSTRAINT [DF_WorkStation_NoOfAssignedWorker] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_WorkStation_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_WorkStation_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_Status] DEFAULT ('0'),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDownTime] [datetime] NULL,
[EndDownTime] [datetime] NULL,
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_WorkOrderKey] DEFAULT (''),
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_JobKey] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkStation] ADD CONSTRAINT [PK_WorkStation] PRIMARY KEY CLUSTERED ([WorkStation]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkStation] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkStation] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkStation] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkStation] TO [NSQL]
GO
