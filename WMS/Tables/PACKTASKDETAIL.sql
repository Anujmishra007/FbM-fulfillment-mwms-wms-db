CREATE TABLE [dbo].[PACKTASKDETAIL]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[TaskBatchNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_TaskBatchNo] DEFAULT (''),
[LogicalName] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_LogicalName] DEFAULT (''),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_Orderkey] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_Sku] DEFAULT (''),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_QtyAllocated] DEFAULT ((0)),
[QtyPacked] [int] NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_QtyPacked] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_Status] DEFAULT ('0'),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKTASKDETAIL_PickSlipNo] DEFAULT (''),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKTASKDETAIL_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_PACKTASKDETAIL_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKTASKDETAIL_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_PACKTASKDETAIL_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PACKTASKDETAIL] ADD CONSTRAINT [PK__PACKTASK__50738165D551AFB8] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PACKTASKDETAIL_Orderkey] ON [dbo].[PACKTASKDETAIL] ([Orderkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PACKTASKDETAIL] ON [dbo].[PACKTASKDETAIL] ([TaskBatchNo], [Orderkey], [Storerkey], [Sku]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PACKTASKDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PACKTASKDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PACKTASKDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PACKTASKDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'PACKTASK DETAIL', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits on', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits by', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Device Logical Position Name ', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'LogicalName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Order #', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pick Slip #', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total QtyAllocated + QtyPicked + ShippedQty per Shipment Orderkey and Sku', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Qty Packed', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'QtyPacked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row Reference', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Task Batch #', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'TaskBatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'PACKTASKDETAIL', 'COLUMN', N'Trafficcop'
GO
