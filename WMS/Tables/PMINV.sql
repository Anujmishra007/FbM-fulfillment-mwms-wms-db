CREATE TABLE [dbo].[PMINV]
(
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMINV_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMINV_Storerkey] DEFAULT (''),
[AccountNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMINV_AccountNo] DEFAULT (''),
[PalletType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMINV_PalletType] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_PMINV_Qty] DEFAULT ((0)),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PMINV_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_PMINV_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PMINV_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_PMINV_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PMINV] ADD CONSTRAINT [CK_PMINV_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[PMINV] ADD CONSTRAINT [PK_PMINV] PRIMARY KEY CLUSTERED ([Facility], [Storerkey], [AccountNo], [PalletType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PMINV] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PMINV] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PMINV] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PMINV] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Management Inventory', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Owner Account No', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'AccountNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edited on', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edited by', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Type', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'PalletType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Qty', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Active Pallet Management Storer', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'PMINV', 'COLUMN', N'Trafficcop'
GO
