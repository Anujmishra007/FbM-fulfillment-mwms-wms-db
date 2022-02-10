CREATE TABLE [dbo].[PickDetail_WIP]
(
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_CaseID] DEFAULT (' '),
[PickHeaderKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_AltSku] DEFAULT (' '),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_PickDetail_WIP_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_PickDetail_WIP_Qty] DEFAULT ((0)),
[QtyMoved] [int] NOT NULL CONSTRAINT [DF_PickDetail_WIP_QtyMoved] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_DropID] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_Loc] DEFAULT ('UNKNOWN'),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_ID] DEFAULT (' '),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_PackKey] DEFAULT (' '),
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_UpdateSource] DEFAULT ('0'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_ToLoc] DEFAULT (' '),
[DoReplenish] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_DoReplenish] DEFAULT ('N'),
[ReplenishZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_ReplenishZone] DEFAULT (' '),
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_DoCartonize] DEFAULT ('N'),
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_PickMethod] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_WaveKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PickDetail_WIP_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PickDetail_WIP_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PickDetail_WIP_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_WIP_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptimizeCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_ShipFlag] DEFAULT ('0'),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskManagerReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MoveRefKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_MoveRefKey] DEFAULT (''),
[WIP_Refno] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickDetail_WIP_WIP_Refno] DEFAULT (''),
[Channel_ID] [bigint] NULL CONSTRAINT [DF_PickDetail_WIP_Channel_ID] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PickDetail_WIP] ADD CONSTRAINT [PKPickDetail_WIP] PRIMARY KEY CLUSTERED ([PickDetailKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PickDetail_WIP_OrdKey] ON [dbo].[PickDetail_WIP] ([OrderKey], [OrderLineNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PickDetail_WIP_WIP_RefNo] ON [dbo].[PickDetail_WIP] ([WIP_Refno], [OrderKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PickDetail_WIP] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PickDetail_WIP] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PickDetail_WIP] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PickDetail_WIP] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pickdetail work in progress by Precatonization', 'SCHEMA', N'dbo', 'TABLE', N'PickDetail_WIP', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'PickDetail_WIP', 'COLUMN', N'Channel_ID'
GO
