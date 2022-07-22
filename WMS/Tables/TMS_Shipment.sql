CREATE TABLE [dbo].[TMS_Shipment]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[ShipmentGID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VehicleLPN] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EquipmentID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriveName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipmentPlannedStartDate] [datetime] NOT NULL,
[ShipmentPlannedEndDate] [datetime] NOT NULL,
[Route] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceProviderID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipmentVolume] [numeric] (24, 6) NOT NULL,
[ShipmentWeight] [numeric] (24, 6) NOT NULL,
[ShipmentCartonCount] [int] NOT NULL,
[ShipmentPalletCount] [int] NOT NULL,
[OTMShipmentStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TMS_Shipment_Addwho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_TMS_Shipment_AddDate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TMS_Shipment_Editwho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_TMS_Shipment_EditDate] DEFAULT (getdate()),
Banner nvarchar(100),
SubBanner nvarchar(100),
Wave nvarchar(20),
ShipmentGroupProfile nvarchar(100),
ShipmentGroup nvarchar(100),
AppointmentID nvarchar(20),
Principal nvarchar(90),
BookingNo int
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMS_Shipment] ADD CONSTRAINT [PKTMS_Shipment] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TMS_Shipment_ShipmentGID] ON [dbo].[TMS_Shipment]
(
	[ShipmentGID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMS_Shipment] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMS_Shipment] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMS_Shipment] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMS_Shipment] TO [NSQL]
GO

/* 
--WMS-18951

ALTER TABLE TMS_Shipment
ADD 	Banner nvarchar(100),
	SubBanner nvarchar(100),
	Wave nvarchar(20),
	ShipmentGroupProfile nvarchar(100),
	ShipmentGroup nvarchar(100),
	AppointmentID nvarchar(20),
	Principal nvarchar(90),
	BookingNo int;
GO


*/