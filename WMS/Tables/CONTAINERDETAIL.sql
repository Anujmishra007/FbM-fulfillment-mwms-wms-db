CREATE TABLE [dbo].[CONTAINERDETAIL]
(
[ContainerKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContainerLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CONTAINERDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ContainerDetail_Status] DEFAULT ('0'),
[Userdefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CONTAINERDETAIL] ADD CONSTRAINT [PKContainerDetail] PRIMARY KEY CLUSTERED ([ContainerKey], [ContainerLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Containerdetail_PalletKey] ON [dbo].[CONTAINERDETAIL] ([PalletKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CONTAINERDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Container ', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A portable platform designed to allow a forklift or pallet jack to lift, move, and store various loads.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'PalletKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status. 0=Default, 5=Verified', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 01', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 02', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 03', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 04', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define field 05', 'SCHEMA', N'dbo', 'TABLE', N'CONTAINERDETAIL', 'COLUMN', N'Userdefine05'
GO
