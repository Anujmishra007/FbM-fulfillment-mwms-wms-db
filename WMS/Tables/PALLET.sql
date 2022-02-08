CREATE TABLE [dbo].[PALLET]
(
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLET_StorerKey] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLET_Status] DEFAULT ('0'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PALLET_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PALLET_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLET_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PALLET_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLET_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NOT NULL CONSTRAINT [DF_PALLET_Length] DEFAULT ((0)),
[Width] [float] NOT NULL CONSTRAINT [DF_PALLET_Width] DEFAULT ((0)),
[Height] [float] NOT NULL CONSTRAINT [DF_PALLET_Height] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_PALLET_GrossWgt] DEFAULT ((0)),
[PalletType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLET_PalletType] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PALLET] WITH NOCHECK ADD CONSTRAINT [CK_PALLET_Status] CHECK (([Status]='9' OR [Status]='0' OR [Status]='5' OR [Status]='3'))
GO
ALTER TABLE [dbo].[PALLET] ADD CONSTRAINT [PKPALLET] PRIMARY KEY CLUSTERED ([PalletKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PALLET] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PALLET] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PALLET] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PALLET] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PALLET] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'PalletKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PALLET', 'COLUMN', N'TrafficCop'
GO
