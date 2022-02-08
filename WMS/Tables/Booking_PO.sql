CREATE TABLE [dbo].[Booking_PO]
(
[ExternPokey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellersReference] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Booking_PO] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Booking_PO] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Booking_PO] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Booking_PO] TO [NSQL]
GO
