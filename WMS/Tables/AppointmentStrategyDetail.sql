
CREATE TABLE [dbo].[AppointmentStrategyDetail]
(
 AppointmentStrategyKey [NVARCHAR] (10)  NOT NULL CONSTRAINT [DF_AppointmentStrategyDetail_DoorBookingStrategyKey] DEFAULT (''),
 AppointmentStrategyLineNumber [NVARCHAR] (5)  NOT NULL CONSTRAINT [DF_AppointmentStrategyDetail_AppointmentStrategyLineNumber] DEFAULT (''),
 Description [NVARCHAR] (60)  NOT NULL CONSTRAINT [DF_AppointmentStrategyDetail_Description] DEFAULT (''),
 FieldName [NVARCHAR] (1000)  NOT NULL CONSTRAINT [DF_AppointmentStrategyDetail_FieldName] DEFAULT (''),
 
[AddWho] [NVARCHAR] (128)  NULL CONSTRAINT [DF_AppointmentStrategyDetail_AddWho] DEFAULT (SUSER_SNAME()),
[AddDate] [DATETIME] NOT NULL CONSTRAINT [DF_AppointmentStrategyDetail_AddDate] DEFAULT (GETDATE()),
[EditWho] [NVARCHAR] (128)  NULL CONSTRAINT [DF_AppointmentStrategyDetail_EditWho] DEFAULT (SUSER_SNAME()),
[EditDate][DATETIME] NOT NULL CONSTRAINT [DF_AppointmentStrategyDetail_EditDate] DEFAULT (GETDATE()),
[TrafficCop] [NVARCHAR] (1)  NULL,
[ArchiveCop] [nvarchar] (1)  NULL 
 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppointmentStrategyDetail] ADD CONSTRAINT [PK_AppointmentStrategyDetail] PRIMARY KEY CLUSTERED ( AppointmentStrategyKey , AppointmentStrategyLineNumber ) ON [PRIMARY]
GO
 
GRANT DELETE ON  [dbo].[AppointmentStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AppointmentStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AppointmentStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AppointmentStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Appointment Strategy reference key', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategyDetail', 'COLUMN', N'AppointmentStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Appointment Strategy Item Line NUmber', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategyDetail', 'COLUMN', N'AppointmentStrategyLineNumber'
GO

EXEC sp_addextendedproperty N'MS_Description', N'Description', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategyDetail', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Field Name', 'SCHEMA', N'dbo', 'TABLE', N'AppointmentStrategyDetail', 'COLUMN', N'FieldName'
GO 

