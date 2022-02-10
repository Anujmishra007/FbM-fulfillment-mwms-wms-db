CREATE TABLE [dbo].[WorkOrderSteps]
(
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_MasterWorkOrder] DEFAULT (''),
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_WorkOrderName] DEFAULT (''),
[StepNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_StepNumber] DEFAULT (''),
[HostStepNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_HostStepNumber] DEFAULT (''),
[WorkStation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_WorkStation] DEFAULT (''),
[WOOperation] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_WOOperation] DEFAULT (''),
[STDTime] [decimal] (18, 6) NOT NULL CONSTRAINT [DF_WorkOrderSteps_STDTime] DEFAULT ((0.000000)),
[TimeRate] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_TimeRate] DEFAULT ('Rate Per Worker'),
[CopyInputFromStep] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingUOMQty] [int] NOT NULL CONSTRAINT [DF_WorkOrderSteps_BillingUOMQty] DEFAULT ((0)),
[BillingUOM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_BillingUOM] DEFAULT (''),
[BillingRate] [money] NOT NULL CONSTRAINT [DF_WorkOrderSteps_BillingRate] DEFAULT ((0.00)),
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_FromLoc] DEFAULT (''),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_ToLoc] DEFAULT (''),
[Instructions] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_Instructions] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderSteps_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderSteps_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderSteps_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderSteps] ADD CONSTRAINT [PK_WorkOrderSteps] PRIMARY KEY CLUSTERED ([MasterWorkOrder], [WorkOrderName], [StepNumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderSteps] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderSteps] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderSteps] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderSteps] TO [NSQL]
GO
