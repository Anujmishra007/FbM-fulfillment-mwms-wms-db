CREATE TABLE [dbo].[VASRefKeyLookup]
(
[JobKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_JobKey] DEFAULT (''),
[JobLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_JobLine] DEFAULT (''),
[WorkOrderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_WorkOrderKey] DEFAULT (''),
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_WorkOrderName] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_MasterWorkOrder] DEFAULT (''),
[StepNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_StepNumber] DEFAULT (''),
[WkOrdReqInputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_WkOrdReqInputsKey] DEFAULT (''),
[WkOrdReqOutputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VASRefKeyLookup_WkOrdReqOutputsKey] DEFAULT (''),
[StepQty] [int] NULL CONSTRAINT [DF_VASRefKeyLookup_StepQty] DEFAULT ((0)),
[AddWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VASRefKeyLookup_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_VASRefKeyLookup_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VASRefKeyLookup_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_VASRefKeyLookup_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VASRefKeyLookup] ADD CONSTRAINT [PK_VASRefKeyLookup] PRIMARY KEY CLUSTERED ([JobKey], [JobLine], [WorkOrderkey], [StepNumber], [WkOrdReqInputsKey], [WkOrdReqOutputsKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VASRefKeyLookup_joboperation] ON [dbo].[VASRefKeyLookup] ([JobKey], [JobLine]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VASRefKeyLookup_WorkOrderRequests] ON [dbo].[VASRefKeyLookup] ([WorkOrderkey], [StepNumber], [WkOrdReqInputsKey], [WkOrdReqOutputsKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VASRefKeyLookup_Routing] ON [dbo].[VASRefKeyLookup] ([WorkOrderName], [MasterWorkOrder]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VASRefKeyLookup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VASRefKeyLookup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VASRefKeyLookup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VASRefKeyLookup] TO [NSQL]
GO
