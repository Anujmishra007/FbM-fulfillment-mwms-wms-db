IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMS_Shipment]') AND type in (N'U'))
BEGIN

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
	[Banner] [nvarchar](100) NULL,
	[SubBanner] [nvarchar](100) NULL,
	[Wave] [nvarchar](20) NULL,
	[ShipmentGroupProfile] [nvarchar](100) NULL,
	[ShipmentGroup] [nvarchar](100) NULL,
	[AppointmentID] [nvarchar](20) NULL,
	[Principal] [nvarchar](90) NULL,
	[BookingNo] [int] NULL,
	[ArchiveCop] [nvarchar](1) NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[TMS_Shipment] ADD CONSTRAINT [PKTMS_Shipment] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TMS_Shipment]') AND name = N'IX_TMS_Shipment_ShipmentGID')
CREATE NONCLUSTERED INDEX [IX_TMS_Shipment_ShipmentGID] ON [dbo].[TMS_Shipment]
(
	[ShipmentGID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]


GRANT DELETE ON  [dbo].[TMS_Shipment] TO [NSQL]

GRANT INSERT ON  [dbo].[TMS_Shipment] TO [NSQL]

GRANT SELECT ON  [dbo].[TMS_Shipment] TO [NSQL]

GRANT UPDATE ON  [dbo].[TMS_Shipment] TO [NSQL]


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

END

ELSE 
BEGIN 
		 	 IF NOT EXISTS (SELECT 1
	               FROM sys.columns
	               WHERE Name = 'ArchiveCop' AND Object_ID = Object_ID('dbo.TMS_Shipment'))
			BEGIN

				ALTER TABLE dbo.TMS_Shipment ADD ArchiveCop [nvarchar](1) NULL;
				EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'TMS_Shipment', 'COLUMN', N'ArchiveCop'
				
			END

END