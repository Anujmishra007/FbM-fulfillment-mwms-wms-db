CREATE TABLE [dbo].[BOL]
(
[BolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_Status] DEFAULT ('0'),
[ExternBolKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_ExternBolKey] DEFAULT (' '),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_OriginCountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_DestinationCountry] DEFAULT (' '),
[VesselQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_VesselQualifier] DEFAULT ('VM'),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_Vessel] DEFAULT (' '),
[PlaceOfLoadingQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_PlaceOfLoadingQualifier] DEFAULT (' '),
[PlaceOfLoading] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_PlaceOfLoading] DEFAULT (' '),
[PlaceOfdischargeQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_PlaceOfdischargeQualifier] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_PlaceOfDischarge] DEFAULT (' '),
[PlaceOfdeliveryQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_PlaceOfdeliveryQualifier] DEFAULT (' '),
[PlaceOfdelivery] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_PlaceOfdelivery] DEFAULT (' '),
[TransMethod] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_TransMethod] DEFAULT (' '),
[VoyageNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_VoyageNumber] DEFAULT (' '),
[DepartureDate] [datetime] NOT NULL CONSTRAINT [DF_BOL_DepartureDate] DEFAULT (getdate()),
[ArrivalDate] [datetime] NOT NULL CONSTRAINT [DF_BOL_ArrivalDate] DEFAULT (getdate()),
[ArrivalDateFinalDestination] [datetime] NOT NULL CONSTRAINT [DF_BOL_ArrivalDateFinalDestination] DEFAULT (getdate()),
[BookingReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_BookingReference] DEFAULT (' '),
[OtherReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_OtherReference] DEFAULT (' '),
[CarrierKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_CarrierKey] DEFAULT (' '),
[CarrierAgent] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_Carrieragent] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_BOL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BOL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BOL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOL_Shipper] DEFAULT (' '),
[Consignee] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOL_Consignee] DEFAULT (' '),
[BillTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOL_BillTo] DEFAULT (' '),
[PreCarriage] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOL_PreCarriage] DEFAULT (' '),
[PlaceReceipt] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOL_PlaceReceipt] DEFAULT (' '),
[ShipperReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOL_ShipperReference] DEFAULT (' '),
[ForwarderReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOL_ForwarderReference] DEFAULT (' ')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BOL] ADD CONSTRAINT [PKBOL] PRIMARY KEY CLUSTERED ([BolKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BOL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Party to be billed for warehousing/storage, if different form Storer.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'BillTo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the bill of lading.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'BolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the carrier.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Party to whom the product is delivered.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'Consignee'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information. ', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the bill of lading used by the storer.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'ExternBolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying voyage.', 'SCHEMA', N'dbo', 'TABLE', N'BOL', 'COLUMN', N'VoyageNumber'
GO
