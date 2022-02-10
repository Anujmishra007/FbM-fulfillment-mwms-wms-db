CREATE TABLE [dbo].[Booking_InDetail]
(
[BookingNo] [int] NOT NULL,
[BookingLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_InDetail_Key2] DEFAULT (''),
[Key3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_InDetail_Key3] DEFAULT (''),
[Remark] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_InDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_InDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Booking_InDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_InDetail_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Booking_InDetail] ADD CONSTRAINT [PK_Booking_InDetail] PRIMARY KEY CLUSTERED ([BookingNo], [BookingLineNumber]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Booking_InDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Booking_InDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Booking_InDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Booking_InDetail] TO [NSQL]
GO
