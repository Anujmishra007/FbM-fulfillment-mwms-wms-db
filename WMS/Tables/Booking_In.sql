CREATE TABLE [dbo].[Booking_In]
(
[BookingNo] [int] NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_Facility] DEFAULT (''),
[BookingDate] [datetime] NOT NULL,
[EndTime] [datetime] NOT NULL,
[Duration] [datetime] NOT NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_Type] DEFAULT (''),
[ALTReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_ALTReference] DEFAULT (''),
[SCAC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_SCAC] DEFAULT (''),
[ReferenceNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_ReferenceNo] DEFAULT (''),
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_In_POKey] DEFAULT (' '),
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_In_ReceiptKey] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_Status] DEFAULT ('0'),
[ContainerNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_In_ContainerNo] DEFAULT (' '),
[ArrivedTime] [datetime] NULL,
[SignInTime] [datetime] NULL,
[UnloadTime] [datetime] NULL,
[DepartTime] [datetime] NULL,
[DriverName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Booking_In_UserDefine10] DEFAULT (''),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_Booking_In_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_Booking_In_Qty] DEFAULT ((0)),
[NumberOfSKU] [int] NOT NULL CONSTRAINT [DF_Booking_In_NumberOfSKU] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_In_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_In_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_In_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_In_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remark] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialHandling] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Drop01] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Drop02] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Drop03] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Drop04] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Drop05] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplierCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_In_SupplierCode] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Booking_In] ADD CONSTRAINT [PK_Booking_In] PRIMARY KEY CLUSTERED ([BookingNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Booking_In] ADD CONSTRAINT [FK_Booking_In_LOC] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
GRANT SELECT ON  [dbo].[Booking_In] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[Booking_In] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Booking_In] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Booking_In] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Booking_In] TO [NSQL]
GO
