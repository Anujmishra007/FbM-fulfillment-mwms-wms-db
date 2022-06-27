
CREATE TABLE [dbo].[AppointmentStrategy]
(
 AppointmentStrategyKey [NVARCHAR] (10)  NOT NULL CONSTRAINT [DF_AppointmentStrategy_DoorBookingStrategyKey] DEFAULT (''),
 Description [NVARCHAR] (60)  NOT NULL CONSTRAINT [DF_AppointmentStrategy_Description] DEFAULT (''),
 StorerKey [NVARCHAR] (15)  NOT NULL CONSTRAINT [DF_AppointmentStrategy_StorerKey] DEFAULT (''),
 Facility [NVARCHAR] (5)  NOT NULL CONSTRAINT [DF_AppointmentStrategy_Facility] DEFAULT (''),
 ShipmentGroupProfile [NVARCHAR] (100)  NOT NULL  CONSTRAINT [DF_AppointmentStrategy_ShipmentGroupProfile] DEFAULT (''),
 Active [NVARCHAR] (5)  NOT NULL  CONSTRAINT [DF_AppointmentStrategy_Active] DEFAULT (''),
 SPCode [NVARCHAR] (30)  NOT NULL  CONSTRAINT [DF_AppointmentStrategy_SPCode] DEFAULT (''),
 Priority [NVARCHAR] (5)  NOT NULL  CONSTRAINT [DF_AppointmentStrategy_Priority] DEFAULT (''),
[AddWho] [NVARCHAR] (128)  NULL CONSTRAINT [DF_AppointmentStrategy_AddWho] DEFAULT (SUSER_SNAME()),
[AddDate] [DATETIME] NOT NULL CONSTRAINT [DF_AppointmentStrategy_AddDate] DEFAULT (GETDATE()),
[EditWho] [NVARCHAR] (128)  NULL CONSTRAINT [DF_AppointmentStrategy_EditWho] DEFAULT (suser_sname()),
[EditDate][DATETIME] NOT NULL CONSTRAINT [DF_AppointmentStrategy_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1)  NULL,
[ArchiveCop] [nvarchar] (1)  NULL 
 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppointmentStrategy] ADD CONSTRAINT [PK_AppointmentStrategy] PRIMARY KEY CLUSTERED ( AppointmentStrategyKey ) ON [PRIMARY]
GO
 
GRANT DELETE ON  [dbo].[AppointmentStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AppointmentStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AppointmentStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AppointmentStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Appointment Strategy reference key', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'AppointmentStrategyKey'
GO


EXEC sp_addextendedproperty N'MS_Description', N'Description', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer Reference Key', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility reference key', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Group Profile ', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'ShipmentGroupProfile'
GO
 EXEC sp_addextendedproperty N'MS_Description', N'Active', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'Active'
GO
 EXEC sp_addextendedproperty N'MS_Description', N'SP program Code', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'SPCode'
GO
 EXEC sp_addextendedproperty N'MS_Description', N'Priority Sequence', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategy', 'COLUMN', N'Priority'
GO