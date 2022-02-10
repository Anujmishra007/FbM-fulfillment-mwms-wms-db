CREATE TABLE [dbo].[EPACKPFTDATA]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[TaskBatchNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cartonno] [int] NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL,
[PackConfirm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_PackConfirm] DEFAULT ('N'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_Status] DEFAULT ('0'),
[LoginID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_LoginID] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_EPACKPFTDATA_AddDate] DEFAULT (getdate()),
[EditDate] [datetime] NULL CONSTRAINT [DF_EPACKPFTDATA_EditDate] DEFAULT (getdate()),
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EPACKPFTDATA_SerialNo] DEFAULT (''),
[QRCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EPACKPFTDATA_QRCode] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EPACKPFTDATA] ADD CONSTRAINT [PK_EPACKPFTDATA] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EPACKPFTDATA] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[EPACKPFTDATA] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[EPACKPFTDATA] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[EPACKPFTDATA] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ecom Packing Simulation Test Data', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pack Carton #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Cartonno'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carton Type', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'CartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User who login and execute the ECOM Packing simulation test', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'LoginID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Order #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pack Task Order mode; Single/Multi', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'OrderMode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pack confirm instruction to simulator', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'PackConfirm'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carton Tracking #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'RefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Reference No', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Serial #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'SerialNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Simulation Test Status', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pack task Batch #', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'TaskBatchNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carton Weight', 'SCHEMA', N'dbo', 'TABLE', N'EPACKPFTDATA', 'COLUMN', N'Weight'
GO
