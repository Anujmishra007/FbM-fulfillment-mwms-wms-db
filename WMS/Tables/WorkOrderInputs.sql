CREATE TABLE [dbo].[WorkOrderInputs]
(
[WkOrdInputsKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_WkOrdInputsKey] DEFAULT (''),
[MasterWorkOrder] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_WorkOrderName] DEFAULT (''),
[StepNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_StepNumber] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_Storerkey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_SKU] DEFAULT (''),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_PackKey] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_UOM] DEFAULT (''),
[InLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_InLocation] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_WorkOrderInputs_Qty] DEFAULT ((0)),
[Wastage] [decimal] (18, 2) NOT NULL CONSTRAINT [DF_WorkOrderInputs_Wastage] DEFAULT ((0.00)),
[Rotation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_Rotation] DEFAULT (''),
[PullType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_PullType] DEFAULT (''),
[MinQty] [int] NOT NULL CONSTRAINT [DF_WorkOrderInputs_MinQty] DEFAULT ((0)),
[MinUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_MinUOM] DEFAULT (''),
[PullQty] [int] NOT NULL CONSTRAINT [DF_WorkOrderInputs_PullQty] DEFAULT ((0)),
[PullUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_PullUOM] DEFAULT (''),
[NonInvSku] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_NonInvSku] DEFAULT (''),
[NonInvLocation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_NonInvLocation] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderInputs_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WorkOrderInputs_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderInputs_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderInputs] ADD CONSTRAINT [PK_WorkOrderInputs] PRIMARY KEY CLUSTERED ([WkOrdInputsKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WorkOrderInputs] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WorkOrderInputs] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WorkOrderInputs] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WorkOrderInputs] TO [NSQL]
GO
