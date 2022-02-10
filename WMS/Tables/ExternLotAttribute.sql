CREATE TABLE [dbo].[ExternLotAttribute]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternLot] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternLotStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternLotAttribute_ExternLotStatus] DEFAULT (' '),
[ExternLottable01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternLotAttribute_ExternLottable01] DEFAULT (' '),
[ExternLottable02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternLotAttribute_ExternLottable02] DEFAULT (' '),
[ExternLottable03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternLotAttribute_ExternLottable03] DEFAULT (' '),
[ExternLottable04] [datetime] NULL CONSTRAINT [DF_ExternLotAttribute_ExternLottable04] DEFAULT (' '),
[ExternLottable05] [datetime] NULL CONSTRAINT [DF_ExternLotAttribute_ExternLottable05] DEFAULT (' '),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_ExternLotAttribute_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternLotAttribute_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_ExternLotAttribute_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ExternLotAttribute_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExternLotAttribute] ADD CONSTRAINT [PK_ExternLotAttribute] PRIMARY KEY CLUSTERED ([StorerKey], [SKU], [ExternLot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternLotAttribute_ExternLOT] ON [dbo].[ExternLotAttribute] ([ExternLot]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ExternLotAttribute] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ExternLotAttribute] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ExternLotAttribute] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ExternLotAttribute] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Add Date of ExternLotAttribute record', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Add Username of ExternLotAttribute record', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Edit Date of the ExternLotAttribute record', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Edit Date of the ExternLotAttribute record', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ExternLot Number', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'ExternLot'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extern Lot Status', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'ExternLotStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extern Lottable01', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'ExternLottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extern Lottable02', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'ExternLottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extern Lottable03', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'ExternLottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extern Lottable04', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'ExternLottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extern Lottable05', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'ExternLottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SKU Code', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'ExternLotAttribute', 'COLUMN', N'StorerKey'
GO
