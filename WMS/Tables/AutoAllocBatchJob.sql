CREATE TABLE [dbo].[AutoAllocBatchJob]
(
[RowID] [bigint] NOT NULL IDENTITY(1, 1),
[AllocBatchNo] [bigint] NOT NULL,
[Priority] [int] NOT NULL CONSTRAINT [DF_AutoAllocBatchJob_Priority] DEFAULT ((9)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StrategyKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatchJob_Status] DEFAULT ('0'),
[TotalOrders] [int] NOT NULL CONSTRAINT [DF_AutoAllocBatchJob_TotalOrders] DEFAULT ((0)),
[TotalQty] [int] NOT NULL CONSTRAINT [DF_AutoAllocBatchJob_TotalQty] DEFAULT ((0)),
[TaskSeqNo] [int] NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_AutoAllocBatchJob_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_AutoAllocBatchJob_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutoAllocBatchJob] ADD CONSTRAINT [PK_AutoAllocBatchJob] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AutoAllocBatchJob] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AutoAllocBatchJob] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AutoAllocBatchJob] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AutoAllocBatchJob] TO [NSQL]
GO
