CREATE TABLE [dbo].[WorkOrderPackets]
(
[WkOrdPacketsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderPackets_WkOrdPacketsKey] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderPackets_MasterWorkOrder] DEFAULT (''),
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderPackets_WorkOrderName] DEFAULT (''),
[FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderPackets_FileName] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderPackets_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderPackets_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderPackets_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderPackets_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderPackets] ADD CONSTRAINT [PK_WorkOrderPackets] PRIMARY KEY CLUSTERED ([WkOrdPacketsKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WorkOrderPackets] ON [dbo].[WorkOrderPackets] ([MasterWorkOrder], [WorkOrderName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderPackets] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderPackets] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderPackets] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderPackets] TO [NSQL]
GO
