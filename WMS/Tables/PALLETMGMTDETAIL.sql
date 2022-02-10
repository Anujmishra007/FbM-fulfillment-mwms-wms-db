CREATE TABLE [dbo].[PALLETMGMTDETAIL]
(
[PMKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_PMKey] DEFAULT (''),
[PMLinenumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_PMLinenumber] DEFAULT (''),
[Docketno] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromStorerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_FromStorerkey] DEFAULT (''),
[ToStorerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_ToStorerkey] DEFAULT (''),
[PMAccountNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_PMAccountNo] DEFAULT (''),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Type] DEFAULT (''),
[PalletType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_PalletType] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Qty] DEFAULT ((0)),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Orderkey] DEFAULT (''),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine06] [datetime] NULL,
[userdefine07] [datetime] NULL,
[userdefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userdefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Status] DEFAULT (''),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_PALLETMGMTDETAIL_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PALLETMGMTDETAIL] ADD CONSTRAINT [CK_PALLETMGMTDETAIL_Type] CHECK (([Type]='TRF' OR [Type]='WD' OR [Type]='DP' OR [Type]=''))
GO
ALTER TABLE [dbo].[PALLETMGMTDETAIL] ADD CONSTRAINT [PK_PALLETMGMTDETAIL] PRIMARY KEY CLUSTERED ([PMKey], [PMLinenumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PALLETMGMTDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PALLETMGMTDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PALLETMGMTDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PALLETMGMTDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Management Detail', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Docket #: Free text field for user to key in document number', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Docketno'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edited on', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edited by', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Active from Storer', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'FromStorerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Order #', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Type; Pallet / Trays', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'PalletType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Account No', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'PMAccountNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Key', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'PMKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Line #', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'PMLinenumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Qty', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Detail Status', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Active To Storer', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'ToStorerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Trafficcop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management type; DP,WD,TF', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 1', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 2', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 3', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 4', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 5', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 6', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 7', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 8', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 9', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User Define 10', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMTDETAIL', 'COLUMN', N'userdefine10'
GO
