CREATE TABLE [SSRS].[AutoAllocStatus]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Company] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Batched] [int] NULL CONSTRAINT [DF_AutoAllocStatus_Batched] DEFAULT ((0)),
[NotSubmit] [int] NULL CONSTRAINT [DF_AutoAllocStatus_NotSubmit] DEFAULT ((0)),
[Allocated] [int] NULL CONSTRAINT [DF_AutoAllocStatus_Allocated] DEFAULT ((0)),
[PartialAlloc] [int] NULL CONSTRAINT [DF_AutoAllocStatus_PartialAlloc] DEFAULT ((0)),
[NoStock] [int] NULL CONSTRAINT [DF_AutoAllocStatus_NoStock] DEFAULT ((0)),
[TotalOrders] [int] NULL CONSTRAINT [DF_AutoAllocStatus_TotalOrders] DEFAULT ((0)),
[TotalQTask] [int] NULL CONSTRAINT [DF_AutoAllocStatus_TotalQTask] DEFAULT ((0)),
[QTaskWIP] [int] NULL CONSTRAINT [DF_AutoAllocStatus_QTaskWIP] DEFAULT ((0)),
[QTaskError] [int] NULL CONSTRAINT [DF_AutoAllocStatus_QTaskError] DEFAULT ((0)),
[SafetyAllocOrders] [int] NULL CONSTRAINT [DF_AutoAllocStatus_SafetyAllocOrders] DEFAULT ((0)),
[SafetyAllocPerctg] [int] NULL CONSTRAINT [DF_AutoAllocStatus_SafetyAllocPerctg] DEFAULT ((0)),
[AllocPerctg] [int] NULL CONSTRAINT [DF_AutoAllocStatus_AllocPerctg] DEFAULT ((0)),
[AllocPriority] [int] NULL CONSTRAINT [DF_AutoAllocStatus_AllocPriority] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_AutoAllocStatus_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_AutoAllocStatus_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [SSRS].[AutoAllocStatus] ADD CONSTRAINT [PK_AutoAllocStatus] PRIMARY KEY CLUSTERED ([Storerkey], [Facility]) ON [PRIMARY]
GO
GRANT DELETE ON  [SSRS].[AutoAllocStatus] TO [NSQL]
GO
GRANT INSERT ON  [SSRS].[AutoAllocStatus] TO [NSQL]
GO
GRANT SELECT ON  [SSRS].[AutoAllocStatus] TO [NSQL]
GO
GRANT UPDATE ON  [SSRS].[AutoAllocStatus] TO [NSQL]
GO
