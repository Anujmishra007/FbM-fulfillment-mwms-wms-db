CREATE TABLE [dbo].[WorkOrder_DELLOG]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[WorkOrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_DELLOG_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_DELLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrder_DELLOG_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrder_DELLOG] ADD CONSTRAINT [PK__WorkOrder_DELLOG__7A72E661] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrder_DELLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrder_DELLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrder_DELLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrder_DELLOG] TO [NSQL]
GO
