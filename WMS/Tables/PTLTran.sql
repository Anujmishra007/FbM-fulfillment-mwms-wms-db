CREATE TABLE [dbo].[PTLTran]
(
[PTLKey] [bigint] NOT NULL IDENTITY(1, 1),
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_IPAddress] DEFAULT (''),
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_DeviceID] DEFAULT (''),
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_DevicePosition] DEFAULT (''),
[Status] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_Status] DEFAULT ('0'),
[PTL_Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_OrderKey] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_Storerkey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_SKU] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LOC] DEFAULT (''),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectedQty] [int] NULL CONSTRAINT [DF_PTLTran_ExpectedQty] DEFAULT ((0)),
[Qty] [int] NULL CONSTRAINT [DF_PTLTran_Qty] DEFAULT ((0)),
[Remarks] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_Remarks] DEFAULT (''),
[MessageNum] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_MessageNum] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_PTLTran_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PTLTran_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_EditWho] DEFAULT (suser_sname()),
[DeviceProfileLogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_SourceKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_ConsigneeKey] DEFAULT (''),
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_CaseID] DEFAULT (''),
[LightUp] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LightUp] DEFAULT ((0)),
[LightMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LightMode] DEFAULT (''),
[LightSequence] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LightSequence] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_UOM] DEFAULT (''),
[RefPTLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_RefPTLKey] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PTLTran] ADD CONSTRAINT [PK_PTLTran] PRIMARY KEY CLUSTERED ([PTLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PTLTRAN_DeviceID] ON [dbo].[PTLTran] ([DeviceID]) INCLUDE ([LightUp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PTLTRAN_01] ON [dbo].[PTLTran] ([DeviceProfileLogKey], [DevicePosition]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PTLTran_Key1] ON [dbo].[PTLTran] ([IPAddress], [DevicePosition], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PTLTran] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PTLTran] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PTLTran] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PTLTran] TO [NSQL]
GO
