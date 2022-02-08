CREATE TABLE [dbo].[AutoAllocBatchDetail]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[AllocBatchNo] [bigint] NOT NULL CONSTRAINT [DF_AutoAllocBatchDetail_AllocBatchNo] DEFAULT ((0)),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AutoAllocBatchDetail_OrderKey] DEFAULT (''),
[Status] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AutoAllocBatchDetail_Status] DEFAULT ('0'),
[TotalSKU] [int] NULL CONSTRAINT [DF_AutoAllocBatchDetail_TotalSKU] DEFAULT ((0)),
[SKUAllocated] [int] NULL CONSTRAINT [DF_AutoAllocBatchDetail_SKUAllocated] DEFAULT ((0)),
[NoStockFound] [bit] NULL CONSTRAINT [DF_AutoAllocBatchDetail_NoStockFound] DEFAULT ((0)),
[AllocErrorFound] [bit] NULL CONSTRAINT [DF_AutoAllocBatchDetail_AllocErrorFound] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_AutoAllocBatchDetail_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_AutoAllocBatchDetail_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutoAllocBatchDetail] ADD CONSTRAINT [PK_AutoAllocBatchDetail] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AutoAllocBatchDetail_BatchNo] ON [dbo].[AutoAllocBatchDetail] ([AllocBatchNo], [TotalSKU]) INCLUDE ([Status], [OrderKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AutoAllocBatchDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AutoAllocBatchDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AutoAllocBatchDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AutoAllocBatchDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Batch No', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatchDetail', 'COLUMN', N'AllocBatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order #', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatchDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identity row running no ', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatchDetail', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'AutoAllocBatchDetail', 'COLUMN', N'Status'
GO
