CREATE TABLE [dbo].[Booking_Audit]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[BookingNo] [int] NULL,
[BookingType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_Facility] DEFAULT (''),
[BookingDate] [datetime] NULL,
[EndTime] [datetime] NULL,
[Duration] [datetime] NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_Type] DEFAULT (''),
[ALTReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_ALTReference] DEFAULT (''),
[SCAC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_SCAC] DEFAULT (''),
[ReferenceNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_ReferenceNo] DEFAULT (''),
[POKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_POKey] DEFAULT (' '),
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_ReceiptKey] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_Status] DEFAULT ('0'),
[ContainerNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_ContainerNo] DEFAULT (' '),
[ArrivedTime] [datetime] NULL,
[SignInTime] [datetime] NULL,
[UnloadTime] [datetime] NULL,
[DepartTime] [datetime] NULL,
[DriverName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_UserDefine10] DEFAULT (''),
[UOMQty] [int] NULL CONSTRAINT [DF_Booking_Audit_UOMQty] DEFAULT ((0)),
[Qty] [int] NULL CONSTRAINT [DF_Booking_Audit_Qty] DEFAULT ((0)),
[NumberOfSKU] [int] NULL CONSTRAINT [DF_Booking_Audit_NumberOfSKU] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_Booking_Audit_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_Booking_Audit_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_EditWho] DEFAULT (suser_sname()),
[Remark] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialHandling] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RouteAuth] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_RouteAuth] DEFAULT (''),
[LicenseNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_LoadKey] DEFAULT (' '),
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_MbolKey] DEFAULT (' '),
[CBOLKey] [int] NULL,
[VehicleContainer] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_Audit_VehicleContainer] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Booking_Audit] ADD CONSTRAINT [PK_Booking_Audit] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Booking_Audit] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Booking_Audit] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Booking_Audit] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Booking_Audit] TO [NSQL]
GO
