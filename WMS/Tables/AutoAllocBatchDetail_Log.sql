CREATE TABLE [dbo].[AutoAllocBatchDetail_Log]
(
[RowRef] [bigint] NOT NULL,
[AllocBatchNo] [bigint] NOT NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_AllocBatchNo] DEFAULT ((0)),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_OrderKey] DEFAULT (''),
[Status] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_Status] DEFAULT ('0'),
[TotalSKU] [int] NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_TotalSKU] DEFAULT ((0)),
[SKUAllocated] [int] NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_SKUAllocated] DEFAULT ((0)),
[NoStockFound] [bit] NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_NoStockFound] DEFAULT ((0)),
[AllocErrorFound] [bit] NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_AllocErrorFound] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_AutoAllocBatchDetail_Log_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutoAllocBatchDetail_Log] ADD CONSTRAINT [PK_AutoAllocBatchDetail_Log] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AutoAllocBatchDetail_Log] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AutoAllocBatchDetail_Log] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AutoAllocBatchDetail_Log] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AutoAllocBatchDetail_Log] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatchDetail_Log', 'COLUMN', N'AllocBatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order #', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatchDetail_Log', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identity row running no ', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatchDetail_Log', 'COLUMN', N'RowRef'
GO
