IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[DEL_RECEIPT]') and OBJECTPROPERTY(id, N'IsTable') = 1)
DROP TABLE [dbo].[DEL_RECEIPT]
GO
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DEL_RECEIPT](
	[ReceiptKey] [nvarchar](10) NOT NULL,
	[ExternReceiptKey] [nvarchar](50) NULL,
	[ReceiptGroup] [nvarchar](20) NOT NULL,
	[StorerKey] [nvarchar](15) NOT NULL,
	[ReceiptDate] [datetime] NULL,
	[POKey] [nvarchar](18) NULL,
	[CarrierKey] [nvarchar](15) NULL,
	[CarrierName] [nvarchar](45) NULL,
	[CarrierAddress1] [nvarchar](45) NULL,
	[CarrierAddress2] [nvarchar](45) NULL,
	[CarrierCity] [nvarchar](45) NULL,
	[CarrierState] [nvarchar](45) NULL,
	[CarrierZip] [nvarchar](10) NULL,
	[CarrierReference] [nvarchar](18) NULL,
	[WarehouseReference] [nvarchar](18) NULL,
	[OriginCountry] [nvarchar](30) NULL,
	[DestinationCountry] [nvarchar](30) NULL,
	[VehicleNumber] [nvarchar](18) NULL,
	[VehicleDate] [nvarchar](18) NULL,
	[PlaceOfLoading] [nvarchar](18) NULL,
	[PlaceOfDischarge] [nvarchar](18) NULL,
	[PlaceofDelivery] [nvarchar](18) NULL,
	[IncoTerms] [nvarchar](10) NULL,
	[TermsNote] [nvarchar](18) NULL,
	[ContainerKey] [nvarchar](18) NULL,
	[Signatory] [nvarchar](50) NULL,
	[PlaceofIssue] [nvarchar](18) NULL,
	[OpenQty] [int] NULL,
	[Status] [nvarchar](10) NOT NULL,
	[Notes] [nvarchar](4000) NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[AddDate] [datetime] NOT NULL,
	[AddWho] [nvarchar](128) NOT NULL,
	[EditDate] [datetime] NOT NULL,
	[EditWho] [nvarchar](128) NOT NULL,
	[TrafficCop] [nvarchar](1) NULL,
	[ArchiveCop] [nvarchar](1) NULL,
	[ContainerType] [nvarchar](20) NULL,
	[ContainerQty] [int] NULL,
	[BilledContainerQty] [int] NULL,
	[RECType] [nvarchar](10) NULL,
	[ASNStatus] [nvarchar](10) NULL,
	[ASNReason] [nvarchar](10) NULL,
	[Facility] [nvarchar](15) NULL,
	[MBOLKey] [nvarchar](10) NULL,
	[Appointment_No] [nvarchar](10) NULL,
	[LoadKey] [nvarchar](10) NULL,
	[xDockFlag] [nvarchar](1) NULL,
	[UserDefine01] [nvarchar](30) NULL,
	[PROCESSTYPE] [nvarchar](1) NULL,
	[UserDefine02] [nvarchar](30) NULL,
	[UserDefine03] [nvarchar](30) NULL,
	[UserDefine04] [nvarchar](30) NULL,
	[UserDefine05] [nvarchar](30) NULL,
	[UserDefine06] [datetime] NULL,
	[UserDefine07] [datetime] NULL,
	[UserDefine08] [nvarchar](30) NULL,
	[UserDefine09] [nvarchar](30) NULL,
	[UserDefine10] [nvarchar](30) NULL,
	[DOCTYPE] [nvarchar](1) NULL,
	[RoutingTool] [nvarchar](30) NULL,
	[CTNTYPE1] [nvarchar](30) NULL,
	[CTNTYPE2] [nvarchar](30) NULL,
	[CTNTYPE3] [nvarchar](30) NULL,
	[CTNTYPE4] [nvarchar](30) NULL,
	[CTNTYPE5] [nvarchar](30) NULL,
	[CTNTYPE6] [nvarchar](30) NULL,
	[CTNTYPE7] [nvarchar](30) NULL,
	[CTNTYPE8] [nvarchar](30) NULL,
	[CTNTYPE9] [nvarchar](30) NULL,
	[CTNTYPE10] [nvarchar](30) NULL,
	[PACKTYPE1] [nvarchar](30) NULL,
	[PACKTYPE2] [nvarchar](30) NULL,
	[PACKTYPE3] [nvarchar](30) NULL,
	[PACKTYPE4] [nvarchar](30) NULL,
	[PACKTYPE5] [nvarchar](30) NULL,
	[PACKTYPE6] [nvarchar](30) NULL,
	[PACKTYPE7] [nvarchar](30) NULL,
	[PACKTYPE8] [nvarchar](30) NULL,
	[PACKTYPE9] [nvarchar](30) NULL,
	[PACKTYPE10] [nvarchar](30) NULL,
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
	[Weight] [float] NOT NULL,
	[WeightUnit] [nvarchar](20) NULL,
	[Cube] [float] NOT NULL,
	[CubeUnit] [nvarchar](20) NULL,
	[GIS_ControlNo] [nvarchar](20) NULL,
	[Cust_ISA_ControlNo] [nvarchar](20) NULL,
	[Cust_GIS_ControlNo] [nvarchar](20) NULL,
	[GIS_ProcessTime] [datetime] NULL,
	[Cust_EDIAckTime] [datetime] NULL,
	[FinalizeDate] [datetime] NOT NULL,
	[SellerName] [nvarchar](45) NULL,
	[SellerCompany] [nvarchar](45) NULL,
	[SellerAddress1] [nvarchar](45) NULL,
	[SellerAddress2] [nvarchar](45) NULL,
	[SellerAddress3] [nvarchar](45) NULL,
	[SellerAddress4] [nvarchar](45) NULL,
	[SellerCity] [nvarchar](45) NULL,
	[SellerState] [nvarchar](45) NULL,
	[SellerZip] [nvarchar](18) NULL,
	[SellerCountry] [nvarchar](30) NULL,
	[SellerContact1] [nvarchar](30) NULL,
	[SellerContact2] [nvarchar](30) NULL,
	[SellerPhone1] [nvarchar](18) NULL,
	[SellerPhone2] [nvarchar](18) NULL,
	[SellerEmail1] [nvarchar](60) NULL,
	[SellerEmail2] [nvarchar](60) NULL,
	[SellerFax1] [nvarchar](18) NULL,
	[SellerFax2] [nvarchar](18) NULL,
	[HoldChannel] [nvarchar](1) NOT NULL,
	[TrackingNo] [nvarchar](40) NULL,
 CONSTRAINT [PKDEL_RECEIPT] PRIMARY KEY CLUSTERED 
(
	[ReceiptKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_XrecKey]  DEFAULT (' ') FOR [ExternReceiptKey]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_ReceiptGroup]  DEFAULT (' ') FOR [ReceiptGroup]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_StorerKey]  DEFAULT (' ') FOR [StorerKey]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_ReceiptDate]  DEFAULT (getdate()) FOR [ReceiptDate]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_PoKey]  DEFAULT (' ') FOR [POKey]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_OpenQty]  DEFAULT ((0)) FOR [OpenQty]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_Status]  DEFAULT ('0') FOR [Status]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_EffectiveDate]  DEFAULT (getdate()) FOR [EffectiveDate]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_AddDate]  DEFAULT (getdate()) FOR [AddDate]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_AddWho]  DEFAULT (suser_sname()) FOR [AddWho]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_EditDate]  DEFAULT (getdate()) FOR [EditDate]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_EditWho]  DEFAULT (suser_sname()) FOR [EditWho]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_BillContQty]  DEFAULT ((0)) FOR [BilledContainerQty]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF__DEL_RECEIPT__RECType__62A57E71]  DEFAULT ('NORMAL') FOR [RECType]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF__DEL_RECEIPT__ASNStat__6399A2AA]  DEFAULT ('0') FOR [ASNStatus]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF__DEL_RECEIPT__ASNReas__648DC6E3]  DEFAULT (' ') FOR [ASNReason]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF__DEL_RECEIPT__xDockFl__5D5784C6]  DEFAULT ((0)) FOR [xDockFlag]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine01]  DEFAULT (' ') FOR [UserDefine01]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine02]  DEFAULT (' ') FOR [UserDefine02]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine03]  DEFAULT (' ') FOR [UserDefine03]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine04]  DEFAULT (' ') FOR [UserDefine04]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine05]  DEFAULT (' ') FOR [UserDefine05]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine08]  DEFAULT (' ') FOR [UserDefine08]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine09]  DEFAULT (' ') FOR [UserDefine09]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_UserDefine10]  DEFAULT (' ') FOR [UserDefine10]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_Weight]  DEFAULT ((0)) FOR [Weight]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_Cube]  DEFAULT ((0)) FOR [Cube]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_GIS_ControlNo]  DEFAULT ('') FOR [GIS_ControlNo]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_Cust_ISA_ControlNo]  DEFAULT ('') FOR [Cust_ISA_ControlNo]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_Cust_GIS_ControlNo]  DEFAULT ('') FOR [Cust_GIS_ControlNo]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_FinalizeDate]  DEFAULT (getdate()) FOR [FinalizeDate]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerName]  DEFAULT ('') FOR [SellerName]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerCompany]  DEFAULT ('') FOR [SellerCompany]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerAddress1]  DEFAULT ('') FOR [SellerAddress1]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerAddress2]  DEFAULT ('') FOR [SellerAddress2]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerAddress3]  DEFAULT ('') FOR [SellerAddress3]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerAddress4]  DEFAULT ('') FOR [SellerAddress4]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerCity]  DEFAULT ('') FOR [SellerCity]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerState]  DEFAULT ('') FOR [SellerState]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerZip]  DEFAULT ('') FOR [SellerZip]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerCountry]  DEFAULT ('') FOR [SellerCountry]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerContact1]  DEFAULT ('') FOR [SellerContact1]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerContact2]  DEFAULT ('') FOR [SellerContact2]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerPhone1]  DEFAULT ('') FOR [SellerPhone1]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerPhone2]  DEFAULT ('') FOR [SellerPhone2]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerEmail1]  DEFAULT ('') FOR [SellerEmail1]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerEmail2]  DEFAULT ('') FOR [SellerEmail2]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerFax1]  DEFAULT ('') FOR [SellerFax1]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_SellerFax2]  DEFAULT ('') FOR [SellerFax2]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_HoldChannel]  DEFAULT ('0') FOR [HoldChannel]
GO

ALTER TABLE [dbo].[DEL_RECEIPT] ADD  CONSTRAINT [DF_DEL_RECEIPT_TNTrackingNo]  DEFAULT ('') FOR [TrackingNo]
GO

ALTER TABLE [dbo].[DEL_RECEIPT]  WITH NOCHECK ADD  CONSTRAINT [CK_DEL_RECEIPT_Status] CHECK  ((rtrim([Status]) like '[0-9]'))
GO

ALTER TABLE [dbo].[DEL_RECEIPT] CHECK CONSTRAINT [CK_DEL_RECEIPT_Status]
GO


