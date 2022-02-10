CREATE TABLE [dbo].[VehicleDispatch]
(
[VehicleDispatchKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_VehicleDispatchKey] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VehicleDispatch_Facility] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_Status] DEFAULT ('0'),
[DepotStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCH_DepotStatus] DEFAULT ('0'),
[ExpectedDepartureDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_ExpectedDepartureDate] DEFAULT (getdate()),
[ActualDepartureDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_ActualDepartureDate] DEFAULT (getdate()),
[ExpectedDeliveryDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_ExpectedDeliveryDate] DEFAULT (getdate()),
[ActualDeliveryDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_ActualDeliveryDate] DEFAULT (getdate()),
[Bookingno] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCH_Bookingno] DEFAULT ((0)),
[BookingDate] [datetime] NULL,
[Bay] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCH_Bay] DEFAULT (''),
[Lane] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCH_Lane] DEFAULT (''),
[VesselQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_VesselQualifier] DEFAULT ('VM'),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_Vessel] DEFAULT (''),
[VesselType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_VesselType] DEFAULT (''),
[DriverName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCH_DriverName] DEFAULT (''),
[SealNo] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCH_SealNo] DEFAULT (''),
[VoyageNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_VoyageNumber] DEFAULT (''),
[Transmethod] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_Transmethod] DEFAULT (''),
[BookingReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_BookingReference] DEFAULT (''),
[OtherReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_OtherReference] DEFAULT (''),
[Carrierkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_Carrierkey] DEFAULT (''),
[CarrierAgent] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_CarrierAgent] DEFAULT (''),
[PlaceOfLoadingQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_PlaceOfLoadingQualifier] DEFAULT (''),
[PlaceofLoading] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_PlaceofLoading] DEFAULT (''),
[PlaceOfDischargeQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_PlaceOfDischargeQualifier] DEFAULT (''),
[PlaceOfDischarge] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_PlaceOfDischarge] DEFAULT (''),
[PlaceOfDeliveryQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_PlaceOfDeliveryQualifier] DEFAULT (''),
[PlaceOfDelivery] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_PlaceOfDelivery] DEFAULT (''),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_OriginCountry] DEFAULT (''),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_DestinationCountry] DEFAULT (''),
[ContainerNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_ContainerNo] DEFAULT (''),
[NoOfOrders] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCH_NoOfOrders] DEFAULT ((0)),
[NoOfStops] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCH_NoOfStops] DEFAULT ((0)),
[NoOfCustomers] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCH_NoOfCustomers] DEFAULT ((0)),
[TotalCube] [float] NULL CONSTRAINT [DF_VEHICLEDISPATCH_TotalCube] DEFAULT ((0.00)),
[TotalWeight] [float] NULL CONSTRAINT [DF_VEHICLEDISPATCH_TotalWeight] DEFAULT ((0.00)),
[TotalPallets] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCH_TotalPallets] DEFAULT ((0)),
[TotalCartons] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCH_TotalCartons] DEFAULT ((0)),
[TotalDropIDs] [int] NULL CONSTRAINT [DF_VEHICLEDISPATCH_TotalDropIDs] DEFAULT ((0)),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_VEHICLEDISPATCH_Notes] DEFAULT (''),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_AddWho] DEFAULT (suser_name()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_VEHICLEDISPATCH_EditWho] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleDispatch] WITH NOCHECK ADD CONSTRAINT [CK_VehicleDispatch_Status] CHECK (([Status]='0' OR [Status]='9'))
GO
ALTER TABLE [dbo].[VehicleDispatch] ADD CONSTRAINT [PK_VehicleDispatch] PRIMARY KEY CLUSTERED ([VehicleDispatchKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VehicleDispatch_Facility] ON [dbo].[VehicleDispatch] ([Facility]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[VehicleDispatch] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[VehicleDispatch] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[VehicleDispatch] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[VehicleDispatch] TO [NSQL]
GO
