CREATE TABLE [dbo].[TraceInfo]
(
[TraceName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeIn] [datetime] NULL,
[TimeOut] [datetime] NULL,
[TotalTime] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Step5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Col1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Col2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Col3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Col4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Col5] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TraceInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TraceInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TraceInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TraceInfo] TO [NSQL]
GO
