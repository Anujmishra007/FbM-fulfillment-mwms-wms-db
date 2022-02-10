CREATE TABLE [dbo].[BATCHPICK]
(
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTYAllocated] [int] NULL CONSTRAINT [DF_BATCHPICK_QTYAllocated] DEFAULT ((0)),
[QtyScanned] [int] NULL CONSTRAINT [DF_BATCHPICK_QtyScanned] DEFAULT ((0))
) ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [IX_BATCHPICK_Loadkey] ON [dbo].[BATCHPICK] ([Loadkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BATCHPICK] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BATCHPICK] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BATCHPICK] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BATCHPICK] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'BATCHPICK', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently allocated in the location.', 'SCHEMA', N'dbo', 'TABLE', N'BATCHPICK', 'COLUMN', N'QTYAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity currently scanned in the location.', 'SCHEMA', N'dbo', 'TABLE', N'BATCHPICK', 'COLUMN', N'QtyScanned'
GO
