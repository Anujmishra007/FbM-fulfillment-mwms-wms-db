CREATE TABLE [RDT].[rdtReplenishmentLog]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[ReplenishmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReplenishmentGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[QtyMoved] [int] NULL CONSTRAINT [DF_rdtReplenishmentLog_QtyMoved] DEFAULT ((0)),
[QtyInPickLoc] [int] NULL CONSTRAINT [DF_rdtReplenishmentLog_QtyInPickLoc] DEFAULT ((0)),
[Priority] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_Priority] DEFAULT ('99999'),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Confirmed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_ReplenNo] DEFAULT (' '),
[Remark] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtReplenishmentLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReplenishmentLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtReplenishmentLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtReplenishmentLog_EditWho] DEFAULT (suser_sname()),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_RefNo] DEFAULT (' '),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_DropID] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_LoadKey] DEFAULT (' '),
[Wavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_Wavekey] DEFAULT (''),
[OriginalFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_OriginalFromLoc] DEFAULT (''),
[OriginalQty] [int] NULL CONSTRAINT [DF_rdtReplenishmentLog_OriginalQty] DEFAULT ((0)),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtReplenishmentLog_ToID] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtReplenishmentLog] ADD CONSTRAINT [PK_rdtReplenishmentLog] PRIMARY KEY CLUSTERED ([ReplenishmentKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtReplenishmentLog_02] ON [RDT].[rdtReplenishmentLog] ([FromLoc], [Confirmed], [AddWho], [Wavekey]) INCLUDE ([Storerkey], [Sku], [Id]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtReplenishmentLog_01] ON [RDT].[rdtReplenishmentLog] ([Rowref]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtReplenishmentLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtReplenishmentLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtReplenishmentLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtReplenishmentLog] TO [NSQL]
GO
