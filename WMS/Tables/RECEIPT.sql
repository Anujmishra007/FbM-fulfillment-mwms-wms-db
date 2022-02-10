CREATE TABLE [dbo].[RECEIPT]
(
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternReceiptKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_ExternReceiptKey] DEFAULT (' '),
[ReceiptGroup] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPT_ReceiptGroup] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPT_StorerKey] DEFAULT (' '),
[ReceiptDate] [datetime] NULL CONSTRAINT [DF_RECEIPT_ReceiptDate] DEFAULT (getdate()),
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_PoKey] DEFAULT (' '),
[CarrierKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierZip] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WarehouseReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleNumber] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleDate] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfLoading] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfDischarge] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceofDelivery] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncoTerms] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TermsNote] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Signatory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceofIssue] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenQty] [int] NULL CONSTRAINT [DF_RECEIPT_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPT_Status] DEFAULT ('0'),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPT_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPT_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPT_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPT_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPT_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContainerQty] [int] NULL,
[BilledContainerQty] [int] NULL CONSTRAINT [DF_RECEIPT_BilledContainerQty] DEFAULT ((0)),
[RECType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_RECType] DEFAULT ('NORMAL'),
[ASNStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_ASNStatus] DEFAULT ('0'),
[ASNReason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_ASNReason] DEFAULT (' '),
[Facility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Appointment_No] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xDockFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_xDockFlag] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine01] DEFAULT (' '),
[PROCESSTYPE] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Receipt_UserDefine10] DEFAULT (' '),
[DOCTYPE] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoutingTool] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNCNT1] [int] NULL,
[CTNCNT2] [int] NULL,
[CTNCNT3] [int] NULL,
[CTNCNT4] [int] NULL,
[CTNCNT5] [int] NULL,
[CTNCNT6] [int] NULL,
[CTNCNT7] [int] NULL,
[CTNCNT8] [int] NULL,
[CTNCNT9] [int] NULL,
[CTNCNT10] [int] NULL,
[CTNQTY1] [int] NULL,
[CTNQTY2] [int] NULL,
[CTNQTY3] [int] NULL,
[CTNQTY4] [int] NULL,
[CTNQTY5] [int] NULL,
[CTNQTY6] [int] NULL,
[CTNQTY7] [int] NULL,
[CTNQTY8] [int] NULL,
[CTNQTY9] [int] NULL,
[CTNQTY10] [int] NULL,
[NoOfMasterCtn] [int] NULL,
[NoOfTTLUnit] [int] NULL,
[NoOfPallet] [int] NULL,
[Weight] [float] NOT NULL CONSTRAINT [DF_Receipt_Weight] DEFAULT ((0)),
[WeightUnit] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cube] [float] NOT NULL CONSTRAINT [DF_Receipt_Cube] DEFAULT ((0)),
[CubeUnit] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GIS_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_GIS_ControlNo] DEFAULT (''),
[Cust_ISA_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_Cust_ISA_ControlNo] DEFAULT (''),
[Cust_GIS_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_Cust_GIS_ControlNo] DEFAULT (''),
[GIS_ProcessTime] [datetime] NULL,
[Cust_EDIAckTime] [datetime] NULL,
[FinalizeDate] [datetime] NOT NULL CONSTRAINT [DF_RECEIPT_FinalizeDate] DEFAULT (getdate()),
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerName] DEFAULT (''),
[SellerCompany] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerCompany] DEFAULT (''),
[SellerAddress1] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerAddress1] DEFAULT (''),
[SellerAddress2] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerAddress2] DEFAULT (''),
[SellerAddress3] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerAddress3] DEFAULT (''),
[SellerAddress4] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerAddress4] DEFAULT (''),
[SellerCity] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerCity] DEFAULT (''),
[SellerState] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerState] DEFAULT (''),
[SellerZip] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerZip] DEFAULT (''),
[SellerCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerCountry] DEFAULT (''),
[SellerContact1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerContact1] DEFAULT (''),
[SellerContact2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerContact2] DEFAULT (''),
[SellerPhone1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerPhone1] DEFAULT (''),
[SellerPhone2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerPhone2] DEFAULT (''),
[SellerEmail1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerEmail1] DEFAULT (''),
[SellerEmail2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerEmail2] DEFAULT (''),
[SellerFax1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerFax1] DEFAULT (''),
[SellerFax2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_SellerFax2] DEFAULT (''),
[HoldChannel] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RECEIPT_HoldChannel] DEFAULT ('0'),
[TrackingNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RECEIPT_TrackingNo] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[RECEIPT] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[RECEIPT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RECEIPT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RECEIPT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RECEIPT] TO [NSQL]
GO

ALTER TABLE [dbo].[RECEIPT] WITH NOCHECK ADD CONSTRAINT [CK_RECEIPT_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[RECEIPT] ADD CONSTRAINT [PKRECEIPT] PRIMARY KEY CLUSTERED ([ReceiptKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RECEIPT_ExternReceiptKey] ON [dbo].[RECEIPT] ([StorerKey], [ExternReceiptKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Receipt_TrackingNo] ON [dbo].[RECEIPT] ([TrackingNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RECEIPT_WarehouseReference] ON [dbo].[RECEIPT] ([WarehouseReference], [StorerKey]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The Advance Shipment Notice (ASN) is the receipt document. Information such as carrier and receipt date are tracked on the ASN. It is is also used to record the stock returns.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Appointment number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Appointment_No'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reason code for return', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ASNReason'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External ASN status such as ''Open'', ''Closed'', ''Cancelled'', ''Export'' etc. LISTNAME=''ASNSTATUS''', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ASNStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total number of containers for the ASN (or per receipt)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'BilledContainerQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter address1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter address2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter city', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierCity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter that delivers the goods', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter name', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter reference number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter state', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierState'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter zip code', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CarrierZip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vehicle reference number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total number of containers for the ASN (or per receipt)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ContainerQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Container types that will be used to deliver the goods', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ContainerType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 3', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 4', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 5', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 6', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 7', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 8', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 9', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNCNT9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 3', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 4', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 5', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 6', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 7', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 8', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 9', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNQTY9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 3', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 4', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 5', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 6', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 7', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 8', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 9', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CTNTYPE9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cubic unit', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'CubeUnit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EDI ACK Time', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Cust_EDIAckTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer GIS Control Number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Cust_GIS_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer ISA Control Number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Cust_ISA_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country where the transported goods will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'DestinationCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ASN document type', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'DOCTYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of goods being delivered', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External ASN or receipt key from host system', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ExternReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Warehouse in which the goods will be returned', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Final date', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'FinalizeDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Exceed GIS Control Number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'GIS_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'GIS Process Time', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'GIS_ProcessTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hold Channel', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'HoldChannel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Standard international terms of delivery', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'IncoTerms'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is used for returns - the previous', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of master carton', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'NoOfMasterCtn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of pallet', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'NoOfPallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of total unit', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'NoOfTTLUnit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Notes - or any information for the delivery', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country from which the transported goods will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'OriginCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 1', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 2', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 3', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 4', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 5', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 6', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 7', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 8', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 9', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PACKTYPE9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PlaceofDelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be discharged from the vehicle', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PlaceOfDischarge'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the PO was issued', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PlaceofIssue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be loaded onto the vehicle', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PlaceOfLoading'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Exceed PO number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Receipt Sub-Type', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'PROCESSTYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of which the receipt is done', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ReceiptDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bonded reference number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ReceiptGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique number to identify a specific Receipt/Trade Return/CrossDock record', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'ReceiptKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of receipt from host system', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'RECType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A flag to indicate whether integration to TMS is required. If yes, a file will be generated', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'RoutingTool'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller address 01', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller address 02', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller address 03', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller address 04', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerAddress4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller city', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerCity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller company', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerCompany'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller contact information 01', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerContact1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller contact information 02', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerContact2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller country', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller email address 01', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerEmail1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller email address 02', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerEmail2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller fax number 01', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerFax1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller fax number 02', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerFax2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller name', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller telephone number 01', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerPhone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller telephone number 02', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerPhone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller state
', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerState'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller ZIP code', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'SellerZip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Supplier DO# or other reference number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Signatory'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ASN status e.g. ''Not Fully Received'' and ''Received''. LISTNAME=''RECSTATUS''', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'StorerKey', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery type', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'TermsNote'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Return Ecom Courier Tracking Number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'TrackingNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Supplier invoice number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ASN Header Reason (ASNHDRSN)', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine06', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine07', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Loading date of the goods', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'VehicleDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vehicle or carrier details or reference number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'VehicleNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Buyer''s (customer''s) reference number', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'WarehouseReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight unit', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'WeightUnit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Used to indicated whether the ASN will be of crossdock nature', 'SCHEMA', N'dbo', 'TABLE', N'RECEIPT', 'COLUMN', N'xDockFlag'
GO
