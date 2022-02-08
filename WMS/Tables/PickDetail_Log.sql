CREATE TABLE [dbo].[PickDetail_Log]
(
[SeqNo] [int] NOT NULL IDENTITY(1, 1),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[B_Qty] [int] NULL,
[A_SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A_Qty] [int] NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_Log_Status] DEFAULT (''),
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_Log_PickDetailKey] DEFAULT (''),
[TransmitlogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_Log_TransmitlogKey] DEFAULT (''),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PickDetail_Log_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (215) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickDetail_Log_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PickDetail_Log] ADD CONSTRAINT [PK_PickDetail_Log] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PickDetail_Log_WaveKey] ON [dbo].[PickDetail_Log] ([WaveKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PickDetail_Log] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PickDetail_Log] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PickDetail_Log] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PickDetail_Log] TO [NSQL]
GO
