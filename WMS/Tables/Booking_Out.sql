CREATE TABLE [dbo].[Booking_Out]
(
[BookingNo] [int] NOT NULL,
[RouteAuth] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_RouteAuth] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_Facility] DEFAULT (''),
[BookingDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_Out_BookingDate] DEFAULT (getdate()),
[EndTime] [datetime] NOT NULL,
[Duration] [datetime] NOT NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_Type] DEFAULT (''),
[SCAC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_SCAC] DEFAULT (''),
[DriverName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LicenseNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_LoadKey] DEFAULT (' '),
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_MbolKey] DEFAULT (' '),
[CBOLKey] [int] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_Status] DEFAULT ('0'),
[ALTReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_ALTReference] DEFAULT (''),
[VehicleContainer] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_VehicleContainer] DEFAULT (''),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Out_UserDefine10] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_Out_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_Out_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivedTime] [datetime] NULL,
[SignInTime] [datetime] NULL,
[UnloadTime] [datetime] NULL,
[DepartTime] [datetime] NULL,
[CallTime] [datetime] NULL,
[Loc2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrierkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_Out_FinalizeFlag] DEFAULT ('N'),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BOOKING_OUT_ToLoc] DEFAULT (''),
Banner nvarchar(100),
SubBanner nvarchar(100),
Wave nvarchar(20),
ShipmentGroupProfile nvarchar(100),
ShipmentGroup nvarchar(100)
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Booking_Out] ADD CONSTRAINT [PK_Booking_Out] PRIMARY KEY CLUSTERED ([BookingNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Booking_Out] ADD CONSTRAINT [FK_Booking_Out_LOC] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
GRANT SELECT ON  [dbo].[Booking_Out] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[Booking_Out] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Booking_Out] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Booking_Out] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Booking_Out] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Loc', 'SCHEMA', N'dbo', 'TABLE', N'Booking_Out', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To Loc', 'SCHEMA', N'dbo', 'TABLE', N'Booking_Out', 'COLUMN', N'ToLoc'
GO


/*

ALTER TABLE Booking_Out
ADD 	Banner nvarchar(100),
	SubBanner nvarchar(100),
	Wave nvarchar(20),
	ShipmentGroupProfile nvarchar(100),
	ShipmentGroup nvarchar(100);
GO

*/