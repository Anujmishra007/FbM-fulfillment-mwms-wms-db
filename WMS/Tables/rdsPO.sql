CREATE TABLE [dbo].[rdsPO]
(
[rdsPONo] [int] NOT NULL,
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_ExternPOKey] DEFAULT (' '),
[PoGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_PoGroup] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PODate] [datetime] NULL CONSTRAINT [DF_rdsPO_PODate] DEFAULT (getdate()),
[SellersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellersReference] DEFAULT (' '),
[BuyersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyersReference] DEFAULT (' '),
[OtherReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_OtherReference] DEFAULT (' '),
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_POType] DEFAULT (' '),
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerName] DEFAULT (' '),
[SellerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress1] DEFAULT (' '),
[SellerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress2] DEFAULT (' '),
[SellerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress3] DEFAULT (' '),
[SellerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerAddress4] DEFAULT (' '),
[SellerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerCity] DEFAULT (' '),
[SellerState] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerState] DEFAULT (' '),
[SellerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerZip] DEFAULT (' '),
[SellerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerPhone] DEFAULT (' '),
[SellerVat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_SellerVat] DEFAULT (' '),
[BuyerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerName] DEFAULT (' '),
[BuyerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress1] DEFAULT (' '),
[BuyerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress2] DEFAULT (' '),
[BuyerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress3] DEFAULT (' '),
[BuyerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerAddress4] DEFAULT (' '),
[BuyerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerCity] DEFAULT (' '),
[BuyerState] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerState] DEFAULT (' '),
[BuyerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerZip] DEFAULT (' '),
[BuyerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerPhone] DEFAULT (' '),
[BuyerVAT] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_BuyerVAT] DEFAULT (' '),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_OriginCountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_DestinationCountry] DEFAULT (' '),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_Vessel] DEFAULT (' '),
[VesselDate] [datetime] NULL CONSTRAINT [DF_rdsPO_VesselDate] DEFAULT (' '),
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceOfLoading] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceOfDischarge] DEFAULT (' '),
[PlaceofDelivery] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceofDelivery] DEFAULT (' '),
[IncoTerms] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_IncoTerms] DEFAULT (' '),
[Pmtterm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_Pmtterm] DEFAULT (' '),
[TransMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_TransMethod] DEFAULT (' '),
[TermsNote] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_TermsNote] DEFAULT (' '),
[Signatory] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_Signatory] DEFAULT (' '),
[PlaceofIssue] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_PlaceofIssue] DEFAULT (' '),
[OpenQty] [int] NULL CONSTRAINT [DF_rdsPO_OpenQty] DEFAULT ((0)),
[PlannedQty] [int] NULL CONSTRAINT [DF_rdsPO_PlannedQty] DEFAULT ((0)),
[Amount] [float] NULL CONSTRAINT [DF_rdsPO_Amount] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_Status] DEFAULT ('0'),
[Notes] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_rdsPO_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsPO_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdsPO_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsPO_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_ExternStatus] DEFAULT ('0'),
[LoadingDate] [datetime] NULL,
[ReasonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_ReasonCode] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL CONSTRAINT [DF_rdsPO_UserDefine06] DEFAULT (' '),
[UserDefine07] [datetime] NULL CONSTRAINT [DF_rdsPO_UserDefine07] DEFAULT (' '),
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsPO_UserDefine10] DEFAULT (' '),
[xdockpokey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsPO] ADD CONSTRAINT [PK_rdsPO] PRIMARY KEY CLUSTERED ([rdsPONo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsPO] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsPO] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsPO] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsPO] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'BuyerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'SellerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'rdsPO', 'COLUMN', N'TrafficCop'
GO
