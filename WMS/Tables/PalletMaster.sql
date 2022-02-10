CREATE TABLE [dbo].[PalletMaster]
(
[Pallet_type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Maxcube] [float] NULL,
[Maxwgt] [float] NULL,
[Maxunit] [int] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletMaster_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PalletMaster_Adddate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PalletMaster_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PalletMaster_Editdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PalletMaster] ADD CONSTRAINT [PKPALLETMASTER] PRIMARY KEY NONCLUSTERED ([Pallet_type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PalletMaster] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PalletMaster] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PalletMaster] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PalletMaster] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PalletMaster', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PalletMaster', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Pallet Master.', 'SCHEMA', N'dbo', 'TABLE', N'PalletMaster', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PalletMaster', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PalletMaster', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The maximum gross weight the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'PalletMaster', 'COLUMN', N'Maxwgt'
GO
