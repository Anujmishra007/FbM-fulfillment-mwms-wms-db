CREATE TABLE [dbo].[ShortPickLog]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeleteWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ShortPickLog_DeleteWho] DEFAULT (suser_sname()),
[DeleteDate] [datetime] NOT NULL CONSTRAINT [DF_ShortPickLog_DeleteDate] DEFAULT (getdate()),
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickHeaderKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UOMQty] [int] NULL,
[Qty] [int] NULL,
[QtyMoved] [int] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateSource] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoReplenish] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenishZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NULL,
[AddDate] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptimizeCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskManagerReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ShortPickLog] ADD CONSTRAINT [PK_ShortPickLog] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ShortPickLog] ON [dbo].[ShortPickLog] ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ShortPickLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ShortPickLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ShortPickLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ShortPickLog] TO [NSQL]
GO
