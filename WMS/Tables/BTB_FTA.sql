CREATE TABLE [dbo].[BTB_FTA]
(
[BTB_FTAKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_FormNo] DEFAULT (''),
[FormType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_FormType] DEFAULT (''),
[CustomerCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_CustomerCode] DEFAULT (''),
[HSCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_HSCode] DEFAULT (''),
[COO] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_COO] DEFAULT (''),
[PermitNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_PermitNo] DEFAULT (''),
[IssuedDate] [datetime] NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_Sku] DEFAULT (''),
[SkuDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_SkuDescr] DEFAULT (''),
[UOM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UOM] DEFAULT (''),
[QtyImported] [int] NOT NULL CONSTRAINT [DF_BTB_FTA_QtyImported] DEFAULT ((0)),
[QtyExported] [int] NOT NULL CONSTRAINT [DF_BTB_FTA_QtyExported] DEFAULT ((0)),
[OriginCriterion] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnabledFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_EnabledFlag] DEFAULT ('Y'),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_UserDefine10] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_FTA_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_FTA_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_FTA_IssueCountry] DEFAULT (''),
[IssueAuthority] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_FTA_IssueAuthority] DEFAULT (''),
[BTBShipItem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_BTBShipItem] DEFAULT (''),
[CustomLotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_FTA_CustomLotNo] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BTB_FTA] ADD CONSTRAINT [PK__BTB_FTA__4AEB7F3AE998DB66] PRIMARY KEY CLUSTERED ([BTB_FTAKey]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [BTB_FTA_IDX_BTB_FTA] ON [dbo].[BTB_FTA] ([FormType], [HSCode], [Storerkey], [Sku], [BTBShipItem], [COO], [FormNo], [CustomLotNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_FTA] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_FTA] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_FTA] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_FTA] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Custom Lot #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_FTA', 'COLUMN', N'CustomLotNo'
GO
