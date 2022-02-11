CREATE TABLE [dbo].[MBOL]
(
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Status] DEFAULT ('0'),
[ExternMbolKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_ExternMbolKey] DEFAULT (' '),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_origincountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_DestinationCountry] DEFAULT (' '),
[VesselQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_VesselQualifier] DEFAULT ('VM'),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_Vessel] DEFAULT (' '),
[PlaceOfLoadingQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfLoadingQualifier] DEFAULT (' '),
[PlaceOfLoading] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfLoading] DEFAULT (' '),
[PlaceOfdischargeQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfdischargeQualifier] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfDischarge] DEFAULT (' '),
[PlaceOfdeliveryQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfdeliveryQualifier] DEFAULT (' '),
[PlaceOfdelivery] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfdelivery] DEFAULT (' '),
[TransMethod] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_TransMethod] DEFAULT (' '),
[VoyageNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_VoyageNumber] DEFAULT (' '),
[DepartureDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_DepartureDate] DEFAULT (getdate()),
[ArrivalDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_ArrivalDate] DEFAULT (getdate()),
[ArrivalDateFinalDestination] [datetime] NOT NULL CONSTRAINT [DF_MBOL_ArrivalDateFinalDestination] DEFAULT (getdate()),
[BookingReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_BookingReference] DEFAULT (' '),
[OtherReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_OtherReference] DEFAULT (' '),
[CarrierKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_CarrierKey] DEFAULT (' '),
[Carrieragent] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_CarrierAgent] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DRIVERName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadingDate] [datetime] NULL,
[CustomerReceivedDate] [datetime] NULL,
[Remarks] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_REMARKS] DEFAULT (' '),
[TotalInvoiceValue] [float] NULL CONSTRAINT [DF_MBOL_TotalInvoiceValue] DEFAULT (' '),
[GrossWeight] [float] NULL CONSTRAINT [DF_MBOL_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_MBOL_CAPACITY] DEFAULT ((0)),
[InvoiceAmount] [float] NULL CONSTRAINT [DF_MBOL_INVOICEAMOUNT] DEFAULT ((0)),
[Weight] [float] NULL CONSTRAINT [DF_MBOL_Weight] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_MBOL_Cube] DEFAULT ((0)),
[CustCnt] [int] NULL CONSTRAINT [DF_MBOL_CustCnt] DEFAULT ((0)),
[PalletCnt] [int] NULL CONSTRAINT [DF_MBOL_PalletCnt] DEFAULT ((0)),
[CaseCnt] [int] NULL CONSTRAINT [DF_MBOL_CaseCnt] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Facility] DEFAULT ('F1'),
[COD_Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_COD_Status] DEFAULT ('0'),
[DepotStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_DepotStatus] DEFAULT ('0'),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine10] DEFAULT (' '),
[ShipCounter] [int] NULL CONSTRAINT [DF_MBOL_ShipCounter] DEFAULT ((0)),
[CTNTYPE] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoofContainer] [int] NULL,
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
[NoOfPrepacks] [int] NULL,
[NoofReshippableCarton] [int] NULL,
[NoofCartonPacked] [int] NULL,
[NoofIDSCarton] [int] NULL,
[NoofCustomerCarton] [int] NULL,
[NoofPallets] [int] NULL,
[CartonWeight] [float] NOT NULL CONSTRAINT [DF_MBOL_CartonWeight] DEFAULT ((0)),
[WeightUnit] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonCube] [float] NOT NULL CONSTRAINT [DF_MBOL_CartonCube] DEFAULT ((0)),
[CubeUnit] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeAccountCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ConsigneeAccountCode] DEFAULT (' '),
[ContainerNo] [nvarchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ContainerNo] DEFAULT (' '),
[Equipment] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Equipment] DEFAULT (' '),
[ShipperAccountCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ShipperAccountCode] DEFAULT (' '),
[NotifyAccountCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_NotifyAccountCode] DEFAULT (' '),
[SealNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_SealNo] DEFAULT (' '),
[GIS_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_GIS_ControlNo] DEFAULT (''),
[Cust_ISA_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Cust_ISA_ControlNo] DEFAULT (''),
[Cust_GIS_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Cust_GIS_ControlNo] DEFAULT (''),
[GIS_ProcessTime] [datetime] NULL,
[Cust_EDIAckTime] [datetime] NULL,
[CBOLKey] [bigint] NULL,
[CBOLLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_ShipDate] DEFAULT (getdate()),
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_FinalizeFlag] DEFAULT ('N'),
[ValidatedFlag] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ValidatedFlag] DEFAULT ('N'),
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OTMShipmentID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_OTMShipmentID] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MBOL] ADD CONSTRAINT [CK_MBOL_Status] CHECK (([Status]='0' OR [Status]='5' OR [Status]='7' OR [Status]='9'))
GO
ALTER TABLE [dbo].[MBOL] ADD CONSTRAINT [PKMBOL] PRIMARY KEY CLUSTERED ([MbolKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MBOL_ExternMbolKey] ON [dbo].[MBOL] ([ExternMbolKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MBOL_status] ON [dbo].[MBOL] ([Status], [ShipCounter], [EffectiveDate]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[MBOL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[MBOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MBOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MBOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MBOL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The MBOL is the standard outbound document that is used to record information on the shipments being transported by the same carrier. In WMS, it is via this document that user will initiate the shipment confirmation for orders that have been picked and loaded into the trucks/containers. Based on the storer configuration, shipment confirmation interface files will be generated.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'truck arrival date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ArrivalDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'truck delivery date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ArrivalDateFinalDestination'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Booking reference number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'BookingReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Capacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter agent', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Carrieragent'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter that delivers the goods', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CartonCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CartonWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'total case count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying CBOL', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CBOLLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cash on delivery status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'COD_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'consignee key', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ConsigneeAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Container number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ContainerNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', ' Carton type 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cubic count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton cube', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CubeUnit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EDI ACK Time', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cust_EDIAckTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer GIS Control Number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cust_GIS_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer ISA Control Number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cust_ISA_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total  orders count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CustCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of customer receiving the products.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CustomerReceivedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'truck departure date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DepartureDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'deposited status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DepotStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country where the transported goods will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DestinationCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'driver''s name', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DRIVERName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', '(EQUIPMENT)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Equipment'
GO
EXEC sp_addextendedproperty N'MS_Description', 'external MBOLKey from host system', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ExternMbolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The warehouse or DC in which the location is residing', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Finalize flag', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'FinalizeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Exceed GIS Control Number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'GIS_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'GIS Process Time', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'GIS_ProcessTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Invoice amount', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'InvoiceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the goods are loaded into the truck', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'LoadingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity''s Description', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'MbolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of carton packed', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofCartonPacked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of container', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofContainer'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of customer carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofCustomerCarton'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of IDS carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofIDSCarton'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of master carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoOfMasterCtn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total number of pallets involved in the delivery.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofPallets'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of prepacks', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoOfPrepacks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of re-shippable carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofReshippableCarton'
GO
EXEC sp_addextendedproperty N'MS_Description', 'notifier key', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NotifyAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country from which the transported goods will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'OriginCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other reference number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'OtherReference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTMShipmentID', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'OTMShipmentID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'total pallet count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PalletCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfdelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', 'delivery qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfdeliveryQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be discharged from the vehicle', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfDischarge'
GO
EXEC sp_addextendedproperty N'MS_Description', 'discharge qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfdischargeQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Area of Truck Loading', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfLoading'
GO
EXEC sp_addextendedproperty N'MS_Description', 'loading qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfLoadingQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'any notes / remarks', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seal number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'SealNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment counter', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ShipCounter'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ShipDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'shipper key', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ShipperAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'MBOL Status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TimeStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total invoice value', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TotalInvoiceValue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transport method e.g. land, air, sea etc.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TransMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine06 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine07 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Backend MBOL Validation Status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ValidatedFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'carrier number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Vessel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'carrier qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'VesselQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'To indicate which location the goods are coming from', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'VoyageNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight Unit', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'WeightUnit'
GO
