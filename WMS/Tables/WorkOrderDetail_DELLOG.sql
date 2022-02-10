CREATE TABLE [dbo].[WorkOrderDetail_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderDetail_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderDetail_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderDetail_DELLOG] ADD CONSTRAINT [PK__WorkOrderDetail___4DF545A5] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderDetail_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderDetail_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderDetail_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderDetail_DELLOG] TO [NSQL]
GO
