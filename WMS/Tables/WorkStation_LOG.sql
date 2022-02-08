CREATE TABLE [dbo].[WorkStation_LOG]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_LOG_WorkZone] DEFAULT ('RACK'),
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_LOG_WorkOrderKey] DEFAULT (''),
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_LOG_JobKey] DEFAULT (''),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkMethod] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkStation_LOG_WorkMethod] DEFAULT (''),
[Descr] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOfAssignedWorker] [int] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_LOG_Status] DEFAULT ('0'),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDownTime] [datetime] NULL,
[EndDownTime] [datetime] NULL,
[LogWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkStation_LOG_LogWho] DEFAULT (suser_sname()),
[LogDate] [datetime] NULL CONSTRAINT [DF_WorkStation_LOG_LogDate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkStation_LOG] ADD CONSTRAINT [PK_WorkStation_LOG] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkStation_LOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkStation_LOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkStation_LOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkStation_LOG] TO [NSQL]
GO
