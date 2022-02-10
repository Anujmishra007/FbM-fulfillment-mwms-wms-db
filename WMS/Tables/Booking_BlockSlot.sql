CREATE TABLE [dbo].[Booking_BlockSlot]
(
[Blockslotkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Booking_BlockSlot_Facility] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromDate] [datetime] NULL CONSTRAINT [DF_Booking_BlockSlot_FromDate] DEFAULT (getdate()),
[ToDate] [datetime] NULL,
[FromTime] [datetime] NULL,
[ToTime] [datetime] NULL,
[Day] [int] NULL CONSTRAINT [DF_Booking_BlockSlot_Day] DEFAULT ((0)),
[Descr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Color] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOOKING_BLOCKSLOT_Color] DEFAULT ('X'),
[ColorOnly] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BOOKING_BLOCKSLOT_ColorOnly] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Booking_BlockSlot] ADD CONSTRAINT [PK_Booking_Block] PRIMARY KEY CLUSTERED ([Blockslotkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Booking_BlockSlot] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Booking_BlockSlot] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Booking_BlockSlot] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Booking_BlockSlot] TO [NSQL]
GO
