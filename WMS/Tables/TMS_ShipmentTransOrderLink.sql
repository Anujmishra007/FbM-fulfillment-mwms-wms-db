CREATE TABLE [dbo].[TMS_ShipmentTransOrderLink]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[ProvShipmentID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipmentGID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMS_ShipmentTransOrderLink] ADD CONSTRAINT [PKTMS_ShipmentTransOrderLink] PRIMARY KEY CLUSTERED ([Rowref]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[TMS_ShipmentTransOrderLink] TO [NSQL]
GO
