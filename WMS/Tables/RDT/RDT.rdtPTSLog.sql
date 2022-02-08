CREATE TABLE [RDT].[rdtPTSLog]
(
[PTSLogKey] [bigint] NOT NULL IDENTITY(1, 1),
[PTSPosition] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_PTSPosition] DEFAULT (''),
[Status] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPTSLog_Status] DEFAULT ('0'),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_DropID] DEFAULT (''),
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_LabelNo] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_StorerKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_ConsigneeKey] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_OrderKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_SKU] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_LOC] DEFAULT (''),
[LOT] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_LOT] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_UOM] DEFAULT (''),
[ExpectedQty] [int] NULL CONSTRAINT [DF_rdtPTSLog_ExpectedQty] DEFAULT (''),
[Qty] [int] NULL CONSTRAINT [DF_rdtPTSLog_Qty] DEFAULT (''),
[Remarks] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_Remarks] DEFAULT (''),
[Func] [int] NULL CONSTRAINT [DF_rdtPTSLog_Func] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtPTSLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_rdtPTSLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPTSLog_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPTSLog] ADD CONSTRAINT [PK_rdtPTSLog] PRIMARY KEY CLUSTERED ([PTSLogKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPTSLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPTSLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPTSLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPTSLog] TO [NSQL]
GO
