CREATE TABLE [dbo].[PALLETDETAIL]
(
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PalletLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETDETAIL_CaseId] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Sku] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Loc] DEFAULT ('UNKNOWN'),
[Qty] [int] NOT NULL CONSTRAINT [DF_PALLETDETAIL_Qty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PALLETDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PALLETDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PalletDetail_UserDefine05] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PALLETDETAIL] WITH NOCHECK ADD CONSTRAINT [CK_PALLETDETAIL_Status] CHECK (([Status]>='0' AND [Status]<='9'))
GO
ALTER TABLE [dbo].[PALLETDETAIL] ADD CONSTRAINT [PKPalletDetail] PRIMARY KEY CLUSTERED ([PalletKey], [PalletLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PalletDetail01] ON [dbo].[PALLETDETAIL] ([StorerKey], [CaseId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PALLETDETAIL] ADD CONSTRAINT [FK_PALLETDETAIL_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
GRANT SELECT ON  [dbo].[PALLETDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PALLETDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Case.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'CaseId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'PalletKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pallet.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'PalletLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PALLETDETAIL', 'COLUMN', N'TrafficCop'
GO
