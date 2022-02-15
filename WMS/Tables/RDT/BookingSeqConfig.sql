CREATE TABLE [RDT].[BookingSeqConfig]
(
[Booking_Seq] [int] NOT NULL,
[Func] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BookingType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[BookingSeqConfig] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[BookingSeqConfig] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[BookingSeqConfig] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[BookingSeqConfig] TO [NSQL]
GO
