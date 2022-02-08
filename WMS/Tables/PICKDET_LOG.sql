CREATE TABLE [dbo].[PICKDET_LOG]
(
[PDetLogNo] [int] NOT NULL IDENTITY(1, 1),
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_PICKDET_LOG_Qty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDET_LOG_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDET_LOG_DropID] DEFAULT (''),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDET_LOG_PackKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDET_LOG_WaveKey] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDET_LOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDET_LOG_AddWho] DEFAULT (suser_sname()),
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_PICKDET_LOG_LogDate] DEFAULT (getdate()),
[LogWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKDET_LOG_LogWho] DEFAULT (suser_sname()),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PickDet_Log_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDet_Log_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PICKDET_LOG] ADD CONSTRAINT [PK_PDetLogNo] PRIMARY KEY CLUSTERED ([PDetLogNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKDET_LOG] ON [dbo].[PICKDET_LOG] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKDET_LOG_OrderKey] ON [dbo].[PICKDET_LOG] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PICKDET_LOG_Pickdetailkey] ON [dbo].[PICKDET_LOG] ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PICKDET_LOG] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PICKDET_LOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PICKDET_LOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PICKDET_LOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PICKDET_LOG] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKDET_LOG', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDET_LOG', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PICKDET_LOG', 'COLUMN', N'Storerkey'
GO
