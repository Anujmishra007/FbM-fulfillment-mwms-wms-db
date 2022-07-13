
CREATE TABLE [dbo].[DoorBookingStrategy]
(
 DoorBookingStrategyKey [NVARCHAR] (10)  NOT NULL CONSTRAINT [DF_DoorBookingStrategy_DoorBookingStrategyKey] DEFAULT (''),
 Description [NVARCHAR] (60)  NOT NULL CONSTRAINT [DF_DoorBookingStrategy_Description] DEFAULT (''),
 Storerkey [NVARCHAR] (15)  NOT NULL CONSTRAINT [DF_DoorBookingStrategy_Storerkey] DEFAULT (''),
 Facility [NVARCHAR] (5)  NOT NULL CONSTRAINT [DF_DoorBookingStrategy_Facility] DEFAULT (''),
 ShipmentGroupProfile [NVARCHAR] (100)  NOT NULL  CONSTRAINT [DF_DoorBookingStrategy_ShipmentGroupProfile] DEFAULT (''),
 Active  [NVARCHAR] (5)  NOT NULL CONSTRAINT [DF_DoorBookingStrategy_Active] DEFAULT (''),
 SPCode [NVARCHAR] (30)  NOT NULL CONSTRAINT [DF_DoorBookingStrategy_SPCode] DEFAULT (''),
Priority [NVARCHAR] (5)  NOT NULL CONSTRAINT [DF_DoorBookingStrategy_Priority] DEFAULT (''),
[AddWho] [NVARCHAR] (128)  NULL CONSTRAINT [DF_DoorBookingStrategy_AddWho] DEFAULT (SUSER_SNAME()),
[AddDate] [DATETIME] NOT NULL CONSTRAINT [DF_DoorBookingStrategy_AddDate] DEFAULT (GETDATE()),
[EditWho] [NVARCHAR] (128)  NULL CONSTRAINT [DF_DoorBookingStrategy_EditWho] DEFAULT (suser_sname()),
[EditDate][DATETIME] NOT NULL CONSTRAINT [DF_DoorBookingStrategy_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1)  NULL,
[ArchiveCop] [nvarchar] (1)  NULL 
 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DoorBookingStrategy] ADD CONSTRAINT [PK_DoorBookingStrategy] PRIMARY KEY CLUSTERED ( DoorBookingStrategyKey ) ON [PRIMARY]
GO
 
GRANT DELETE ON  [dbo].[DoorBookingStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DoorBookingStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DoorBookingStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DoorBookingStrategy] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Door Booking Strategy reference key', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'DoorBookingStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer reference key', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility reference Key', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Group Profile ', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'ShipmentGroupProfile'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Active or not', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'Active'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SP Program Code', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'SPCode'
GO
 EXEC sp_addextendedproperty N'MS_Description', N'Priority sequence', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategy', 'COLUMN', N'Priority'
GO
