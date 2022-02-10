CREATE TABLE [dbo].[WMS_ConnectionThread]
(
[SEQ] [int] NOT NULL IDENTITY(1, 1),
[datetime] [datetime] NOT NULL CONSTRAINT [DF_WMS_ConnectionThread_datetime] DEFAULT (getdate()),
[instance_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[machine_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Workerthread] [int] NOT NULL CONSTRAINT [DF_WMS_ConnectionThread_Workerthread] DEFAULT ((0)),
[Workerthread_Max] [int] NOT NULL CONSTRAINT [DF_WMS_ConnectionThread_Workerthread_Max] DEFAULT ((0)),
[Threshold_Value] [int] NOT NULL CONSTRAINT [DF_WMS_ConnectionThread_Threshold_Value] DEFAULT ((0)),
[Current_Workerthread] [int] NOT NULL CONSTRAINT [DF_WMS_ConnectionThread_Current_Workerthread] DEFAULT ((0)),
[Work_Queue] [int] NOT NULL CONSTRAINT [DF_WMS_ConnectionThread_Work_Queue] DEFAULT ((0)),
[SP_Connection_Count] [int] NOT NULL CONSTRAINT [DF_WMS_ConnectionThread_SP_Connection_Count] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WMS_ConnectionThread] ADD CONSTRAINT [PK__WMS_Conn__CA1938C063B1C89F] PRIMARY KEY CLUSTERED ([SEQ]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMS_ConnectionThread] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMS_ConnectionThread] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMS_ConnectionThread] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMS_ConnectionThread] TO [NSQL]
GO
