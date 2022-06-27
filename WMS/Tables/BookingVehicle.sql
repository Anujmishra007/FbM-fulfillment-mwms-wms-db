

 


CREATE TABLE [dbo].[BookingVehicle]
(
 BookingNo [INT] NOT NULL CONSTRAINT [DF_BookingVehicle_BookingNo] DEFAULT (''),
 VehicleNo [INT] NOT NULL CONSTRAINT [DF_BookingVehicle_VehicleNo] DEFAULT (''),
 BookingType [NVARCHAR] (5)  NOT NULL CONSTRAINT [DF_BookingVehicle_BookingType] DEFAULT (''),
 SCAC [NVARCHAR] (10)  NOT NULL CONSTRAINT [DF_BookingVehicle_SCAC] DEFAULT (''),
 DriverName [NVARCHAR] (30)  NOT NULL  CONSTRAINT [DF_BookingVehicle_DriverName] DEFAULT (''),
 LicenseNo [NVARCHAR] (20)  NOT NULL CONSTRAINT [DF_BookingVehicle_LicenseNo] DEFAULT (''),
 VehicleContainer [nvarchar] (30)  NOT NULL CONSTRAINT [DF_BookingVehicle_VehicleContainer] DEFAULT (''),
 VehicleType [nvarchar] (20)  NOT NULL CONSTRAINT [DF_BookingVehicle_VehicleType] DEFAULT (''),
 CarrierKey [nvarchar] (18)  NOT NULL CONSTRAINT [DF_BookingVehicle_CarrierKey] DEFAULT (''),

[AddWho] [nvarchar] (128)  NULL CONSTRAINT [DF_BookingVehicle_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BookingVehicle_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128)  NULL CONSTRAINT [DF_BookingVehicle_EditWho] DEFAULT (suser_sname()),
[EditDate][DATETIME] NOT NULL CONSTRAINT [DF_BookingVehicle_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1)  NULL,
[ArchiveCop] [nvarchar] (1)  NULL 
 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BookingVehicle] ADD CONSTRAINT [PK_BookingVehicle] PRIMARY KEY CLUSTERED ( BookingNo, VehicleNo ) ON [PRIMARY]
GO
 
GRANT DELETE ON  [dbo].[BookingVehicle] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BookingVehicle] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BookingVehicle] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BookingVehicle] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Booking Number reference', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'BookingNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vehicle Plate Number', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'VehicleNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Booking Type', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'BookingType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SCAC', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'SCAC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Driver Name', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'DriverName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Driver License Number', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'LicenseNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Container reference number for Vehicle', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'VehicleContainer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vehicle Type', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'VehicleType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Carrier reference Key', 'SCHEMA', N'dbo', 'TABLE', N'BookingVehicle', 'COLUMN', N'CarrierKey'
GO
 


