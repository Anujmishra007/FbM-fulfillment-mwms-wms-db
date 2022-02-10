CREATE TABLE [dbo].[PACKDet]
(
[PackDetKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKDet_PackKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACKDet_SKU] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseQty] [int] NULL CONSTRAINT [DF_PACKDet_CaseQty] DEFAULT ((0)),
[CaseWeight] [float] NULL CONSTRAINT [DF_PACKDet_CaseWeight] DEFAULT ((0)),
[CaseVolume] [float] NULL CONSTRAINT [DF_PACKDet_CaseVolume] DEFAULT ((0)),
[CaseLength] [float] NULL CONSTRAINT [DF_PACKDet_CaseLength] DEFAULT ((0)),
[CaseWidth] [float] NULL CONSTRAINT [DF_PACKDet_CaseWidth] DEFAULT ((0)),
[CaseHeight] [float] NULL CONSTRAINT [DF_PACKDet_CaseHeight] DEFAULT ((0)),
[PalletQty] [int] NULL CONSTRAINT [DF_PACKDet_PalletQty] DEFAULT ((0)),
[PalletWeight] [float] NULL CONSTRAINT [DF_PACKDet_PalletWeight] DEFAULT ((0)),
[PalletVolume] [float] NULL CONSTRAINT [DF_PACKDet_PalletVolume] DEFAULT ((0)),
[PalletLength] [float] NULL CONSTRAINT [DF_PACKDet_PalletLength] DEFAULT ((0)),
[PalletWidth] [float] NULL CONSTRAINT [DF_PACKDet_PalletWidth] DEFAULT ((0)),
[PalletHeight] [float] NULL CONSTRAINT [DF_PACKDet_PalletHeight] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine05] DEFAULT (''),
[UserDefine06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine06] DEFAULT (''),
[UserDefine07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine07] DEFAULT (''),
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_UserDefine10] DEFAULT (''),
[UserDefine11] [datetime] NULL,
[UserDefine12] [datetime] NULL,
[UserDefine13] [datetime] NULL,
[UserDefine14] [datetime] NULL,
[UserDefine15] [datetime] NULL,
[UserDefine16] [datetime] NULL,
[UserDefine17] [datetime] NULL,
[UserDefine18] [datetime] NULL,
[UserDefine19] [datetime] NULL,
[UserDefine20] [datetime] NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_PACKDet_AddDate] DEFAULT (getdate()),
[AddWho] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PACKDet_EditDate] DEFAULT (getdate()),
[EditWho] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACKDet_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PACKDet] ADD CONSTRAINT [PK_PACKDet] PRIMARY KEY CLUSTERED ([PackDetKey], [PackKey], [SKU], [StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackDet_PackKey] ON [dbo].[PACKDet] ([PackKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackDet_SKU] ON [dbo].[PACKDet] ([SKU], [StorerKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PACKDet] TO [iml]
GO
GRANT INSERT ON  [dbo].[PACKDet] TO [iml]
GO
GRANT SELECT ON  [dbo].[PACKDet] TO [iml]
GO
GRANT UPDATE ON  [dbo].[PACKDet] TO [iml]
GO
GRANT DELETE ON  [dbo].[PACKDet] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PACKDet] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PACKDet] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PACKDet] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Add Date of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Add Username of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case Height of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'CaseHeight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case Length of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'CaseLength'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case Quantity of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'CaseQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case Volume of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'CaseVolume'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case Weight of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'CaseWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Case Width of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'CaseWidth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Edit Date of the PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Edit Date of the PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PACKDet Key', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PackDetKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PackKey of PACK', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Height of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PalletHeight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Length of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PalletLength'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Quantity of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PalletQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Volume of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PalletVolume'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Weight of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PalletWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Width of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'PalletWidth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SKU Code', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine01 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine02 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine03 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine04 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine05 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine06 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine07 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine08 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine09 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine10 of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine11 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine12 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine13 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine14 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine15 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine16 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine16'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine17 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine17'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine18 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine18'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine19 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine19'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UserDefine20 datetime of PACKDet record', 'SCHEMA', N'dbo', 'TABLE', N'PACKDet', 'COLUMN', N'UserDefine20'
GO
