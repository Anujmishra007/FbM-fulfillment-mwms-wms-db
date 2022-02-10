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
[EditDate] [datetime] NULL CONSTRAINT [DF_TMS_Shipment_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMS_Shipment] ADD CONSTRAINT [PKTMS_Shipment] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMS_Shipment] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMS_Shipment] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMS_Shipment] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMS_Shipment] TO [NSQL]
GO
