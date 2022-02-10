CREATE TABLE [dbo].[PO]
(
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_ExternPOKey] DEFAULT (' '),
[PoGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_PoGroup] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PODate] [datetime] NULL CONSTRAINT [DF_PO_PODate] DEFAULT (getdate()),
[SellersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellersReference] DEFAULT (' '),
[BuyersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyersReference] DEFAULT (' '),
[OtherReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_OtherReference] DEFAULT (' '),
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_POType] DEFAULT (' '),
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerName] DEFAULT (' '),
[SellerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress1] DEFAULT (' '),
[SellerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress2] DEFAULT (' '),
[SellerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress3] DEFAULT (' '),
[SellerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerAddress4] DEFAULT (' '),
[SellerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerCity] DEFAULT (' '),
[SellerState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerState] DEFAULT (' '),
[SellerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerZip] DEFAULT (' '),
[SellerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerPhone] DEFAULT (' '),
[SellerVat] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerVat] DEFAULT (' '),
[BuyerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerName] DEFAULT (' '),
[BuyerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress1] DEFAULT (' '),
[BuyerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress2] DEFAULT (' '),
[BuyerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress3] DEFAULT (' '),
[BuyerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerAddress4] DEFAULT (' '),
[BuyerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerCity] DEFAULT (' '),
[BuyerState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerState] DEFAULT (' '),
[BuyerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerZip] DEFAULT (' '),
[BuyerPhone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerPhone] DEFAULT (' '),
[BuyerVAT] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_BuyerVAT] DEFAULT (' '),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_OriginCountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_DestinationCountry] DEFAULT (' '),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_Vessel] DEFAULT (' '),
[VesselDate] [datetime] NULL CONSTRAINT [DF_PO_VesselDate] DEFAULT (NULL),
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceOfLoading] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceOfDischarge] DEFAULT (' '),
[PlaceofDelivery] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceofDelivery] DEFAULT (' '),
[IncoTerms] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_IncoTerms] DEFAULT (' '),
[Pmtterm] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PmtTerm] DEFAULT (' '),
[TransMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_TransMethod] DEFAULT (' '),
[TermsNote] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_TermsNote] DEFAULT (' '),
[Signatory] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_Signatory] DEFAULT (' '),
[PlaceofIssue] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_PlaceofIssue] DEFAULT (' '),
[OpenQty] [int] NULL CONSTRAINT [DF_PO_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_Status] DEFAULT ('0'),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PO_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PO_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PO_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PO_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_ExternStatus] DEFAULT ('0'),
[LoadingDate] [datetime] NULL,
[ReasonCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_ReasonCode] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_UserDefine10] DEFAULT (' '),
[xdockpokey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerCompany] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerCompany] DEFAULT (''),
[SellerCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerCountry] DEFAULT (''),
[SellerContact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerContact1] DEFAULT (''),
[SellerContact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerContact2] DEFAULT (''),
[SellerPhone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerPhone2] DEFAULT (''),
[SellerEmail1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerEmail1] DEFAULT (''),
[SellerEmail2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerEmail2] DEFAULT (''),
[SellerFax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerFax1] DEFAULT (''),
[SellerFax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PO_SellerFax2] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PO] WITH NOCHECK ADD CONSTRAINT [CK_PO_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[PO] ADD CONSTRAINT [PKPO] PRIMARY KEY CLUSTERED ([POKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternPOKey] ON [dbo].[PO] ([ExternPOKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_StorerKey] ON [dbo].[PO] ([StorerKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_XdockPOKey] ON [dbo].[PO] ([xdockpokey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PO] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PO] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PO] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PO] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PO] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A Purchase Order (PO) is a contract between the buyer of the product and vendor supplying the products. It records the quantity of each commodity ordered, as well as the destination of each shipment. PO can be created manually or transmitted electronically via IDS IML when the storer puts in a PO to the vendor.', 'SCHEMA', N'dbo', 'TABLE', N'PO', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address1 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address2 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address3 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer address4 when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer city when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerCity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer that is buying the goods in the PO. When you select a buyer, the corresponding information on the address and other contacts will be defaulted', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Buyer company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer''s other reference field', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyersReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer state when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerState'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer/consignee''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerVAT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display buyer zip when Buyer/ Storer selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'BuyerZip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country where the transported goods will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'DestinationCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place
', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vendor PO reference key', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'IDS internal PO status', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ExternStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Standard international terms of delivery', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'IncoTerms'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the goods are loaded into the truck', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'LoadingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information you wish to track in the PO', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country from which the transported goods will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'OriginCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other reference number', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'OtherReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not Used', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceofDelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Truck Discharge', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceOfDischarge'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the PO was issued', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceofIssue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Area of Truck Loading', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PlaceOfLoading'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Payment term', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Pmtterm'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Start Date', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PODate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Purchase order group', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'PoGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'It''s used to identify a specific PO record. Automatically generated', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of purchase order. Default: Standard. User defined and configurable at Code Look up', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'POType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reason', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller address1 when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller address2 when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Street address of the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller city when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerCity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller company
', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerCompany'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller contact information 01
', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerContact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller contact information 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerContact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller country', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller email address 01', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerEmail1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller email address 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerEmail2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller fax number 01', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerFax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller fax number 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerFax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vendor that is selling the products. When the Seller is selected, the system fills in the associated VAT# and address fields automatically. The setup will from storer master', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Telephone number for the Seller company.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller telephone number 02', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerPhone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Sellers Reference', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellersReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller state when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerState'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer/consignee''s value added tax ID', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerVat'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Will automatic display seller zip when Seller selected', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'SellerZip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Supplier DO# or other reference number', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Signatory'
GO
EXEC sp_addextendedproperty N'MS_Description', 'System generated PO status.   - Not Fully Received  - Received', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer that is buying the goods in the PO. When you select a buyer, the corresponding information on the address and other contacts will be defaulted', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Payment options and credit terms', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'TermsNote'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transport method e.g. land, air, sea etc.', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'TransMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine1', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine2', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine3', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine4', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine5', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine6', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine7', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine8', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine9', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO Userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carrier transporting the goods from the warehouse to the Consignee. Must be a valid carrier', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'Vessel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date in which the PO was issued and created', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'VesselDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not Used', 'SCHEMA', N'dbo', 'TABLE', N'PO', 'COLUMN', N'xdockpokey'
GO
