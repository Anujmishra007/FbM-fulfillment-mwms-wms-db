CREATE TABLE [dbo].[PackHeader]
(
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_Route] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderRefNo] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_OrderRefNo] DEFAULT (' '),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_LoadKey] DEFAULT (' '),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_ConsigneeKey] DEFAULT (' '),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_Status] DEFAULT ('0'),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackHeader_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackHeader_Adddate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackHeader_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackHeader_Editdate] DEFAULT (getdate()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TTLCNTS] [int] NULL CONSTRAINT [DF_PackHeader_TTLCNTS] DEFAULT ((0)),
[CtnTyp1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_CtnTyp1] DEFAULT (''),
[CtnTyp2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_CtnTyp2] DEFAULT (''),
[CtnTyp3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_CtnTyp3] DEFAULT (''),
[CtnTyp4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_CtnTyp4] DEFAULT (''),
[CtnTyp5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_CtnTyp5] DEFAULT (''),
[CtnCnt1] [int] NULL CONSTRAINT [DF_PackHeader_CtnCnt1] DEFAULT ((0)),
[CtnCnt2] [int] NULL CONSTRAINT [DF_PackHeader_CtnCnt2] DEFAULT ((0)),
[CtnCnt3] [int] NULL CONSTRAINT [DF_PackHeader_CtnCnt3] DEFAULT ((0)),
[CtnCnt4] [int] NULL CONSTRAINT [DF_PackHeader_CtnCnt4] DEFAULT ((0)),
[CtnCnt5] [int] NULL CONSTRAINT [DF_PackHeader_CtnCnt5] DEFAULT ((0)),
[TotCtnWeight] [float] NULL CONSTRAINT [DF_PackHeader_TotCtnWeight] DEFAULT ((0)),
[TotCtnCube] [float] NULL CONSTRAINT [DF_PackHeader_TotCtnCube] DEFAULT ((0)),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_CartonGroup] DEFAULT (''),
[ManifestPrinted] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_ManifestPrinted] DEFAULT ('0'),
[ConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackHeader_ConsoOrderKey] DEFAULT (''),
[TaskBatchNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKHEADER_TaskBatchNo] DEFAULT (''),
[ComputerName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKHEADER_ComputerName] DEFAULT (''),
[PackStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackHeader_PackStatus] DEFAULT ('0'),
[EstimateTotalCtn] [int] NULL CONSTRAINT [DF_PACKHEADER_EstimateTotalCtn] DEFAULT ((0))
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PackHeader] ADD CONSTRAINT [PKPackHeader] PRIMARY KEY CLUSTERED ([PickSlipNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackHeader_ConsoOrderKey] ON [dbo].[PackHeader] ([ConsoOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackHeader_Loadkey] ON [dbo].[PackHeader] ([LoadKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackHeader_orderkey] ON [dbo].[PackHeader] ([OrderKey]) INCLUDE ([StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PACKHEADER_TaskBatchOrder] ON [dbo].[PackHeader] ([TaskBatchNo], [OrderKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PackHeader] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PackHeader] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackHeader] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackHeader] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackHeader] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Computer Name', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'ComputerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Consignee. ', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Estimate Total Carton', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'EstimateTotalCtn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External status (concept similar to Orders.SOStatus)', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'PackStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pick Slip.', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Task Batch No', 'SCHEMA', N'dbo', 'TABLE', N'PackHeader', 'COLUMN', N'TaskBatchNo'
GO
