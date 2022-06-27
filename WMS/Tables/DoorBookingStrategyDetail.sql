
CREATE TABLE [dbo].[DoorBookingStrategyDetail]
(
 DoorBookingStrategyKey [nvarchar] (10)  NOT NULL CONSTRAINT [DF_DoorBookingStrategyDetail_DoorBookingStrategyKey] DEFAULT (''),
 DoorBookingStrategyLineNumber [nvarchar] (5)  NOT NULL CONSTRAINT [DF_DoorBookingStrategyDetail_DoorBookingStrategyLineNumber] DEFAULT (''),
 Description [nvarchar] (60)  NOT NULL CONSTRAINT [DF_DoorBookingStrategyDetail_Description] DEFAULT (''),
 Code [nvarchar] (60)  NOT NULL CONSTRAINT [DF_DoorBookingStrategyDetail_Code] DEFAULT (''),
 [Value] [nvarchar] (4000)  NOT NULL CONSTRAINT [DF_DoorBookingStrategyDetail_Value] DEFAULT (''),
 OptionCodes [nvarchar] (4000)  NOT NULL  CONSTRAINT [DF_DoorBookingStrategyDetail_OptionCodes] DEFAULT (''),
 
[AddWho] [nvarchar] (128)  NULL CONSTRAINT [DF_DoorBookingStrategyDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DoorBookingStrategyDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128)  NULL CONSTRAINT [DF_DoorBookingStrategyDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [DATETIME] NOT NULL CONSTRAINT [DF_DoorBookingStrategyDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1)  NULL,
[ArchiveCop] [nvarchar] (1)  NULL 
 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DoorBookingStrategyDetail] ADD CONSTRAINT [PK_DoorBookingStrategyDetail] PRIMARY KEY CLUSTERED ( DoorBookingStrategyKey , DoorBookingStrategyLineNumber ) ON [PRIMARY]
GO
 
GRANT DELETE ON  [dbo].[DoorBookingStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DoorBookingStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DoorBookingStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DoorBookingStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Door Booking Strategy reference key', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategyDetail', 'COLUMN', N'DoorBookingStrategyKey'
GO

EXEC sp_addextendedproperty N'MS_Description', N'Door Booking Strategy Item Line Number', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategyDetail', 'COLUMN', N'DoorBookingStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategyDetail', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Code', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategyDetail', 'COLUMN', N'Code'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Value', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategyDetail', 'COLUMN', N'Value'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Option Codes ', 'SCHEMA', N'dbo', 'TABLE', N'DoorBookingStrategyDetail', 'COLUMN', N'OptionCodes'
GO
 