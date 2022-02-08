CREATE TABLE [dbo].[PMTRN]
(
[PMTranKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_PMTranKey] DEFAULT (''),
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_TranType] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_Facility] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_Storerkey] DEFAULT (''),
[AccountNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_AccountNo] DEFAULT (''),
[PalletType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_PalletType] DEFAULT (''),
[Sourcekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_Sourcekey] DEFAULT (''),
[Sourcetype] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PMTRN_Sourcetype] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_PMTRN_Qty] DEFAULT ((0)),
[EffectiveDate] [datetime] NULL CONSTRAINT [DF_PMTRN_EffectiveDate] DEFAULT (getdate()),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PMTRN_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_PMTRN_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PMTRN_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_PMTRN_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PMTRN] ADD CONSTRAINT [PK_PMTRN] PRIMARY KEY CLUSTERED ([PMTranKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PMTRN] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PMTRN] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PMTRN] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PMTRN] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Management Transaction', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Owner Account No', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'AccountNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edited on', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edited by', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Effective Date', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Type', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'PalletType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Transaction Key', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'PMTranKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Qty', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source key', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source type; ASN,SO,MBOL,LOADPLAN', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Sourcetype'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Active Pallet Management Storer', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'Trafficcop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Transaction Type', 'SCHEMA', N'dbo', 'TABLE', N'PMTRN', 'COLUMN', N'TranType'
GO
