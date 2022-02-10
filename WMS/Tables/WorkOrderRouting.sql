CREATE TABLE [dbo].[WorkOrderRouting]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_Storerkey] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_MasterWorkOrder] DEFAULT (''),
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_WorkOrderName] DEFAULT (''),
[Descr] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_Descr] DEFAULT (''),
[WorkOrderType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_WorkOrderType] DEFAULT (''),
[WorkOrderRelease] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_WorkOrderRelease] DEFAULT (''),
[WOReference] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_WOReference] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_Facility] DEFAULT (''),
[QAType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_QAType] DEFAULT (''),
[QAValue] [int] NOT NULL CONSTRAINT [DF_WorkOrderRouting_QAValue] DEFAULT ((0)),
[QALocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRouting_QALocation] DEFAULT (''),
[UDF1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_UDF1] DEFAULT (''),
[UDF2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_UDF2] DEFAULT (''),
[UDF3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_UDF3] DEFAULT (''),
[UDF4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_UDF4] DEFAULT (''),
[UDF5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderRouting_UDF5] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRouting_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRouting_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_WorkOrderRouting_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRouting_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderRouting] ADD CONSTRAINT [PK_WorkOrderRouting] PRIMARY KEY CLUSTERED ([WorkOrderName], [MasterWorkOrder]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderRouting] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderRouting] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderRouting] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderRouting] TO [NSQL]
GO
