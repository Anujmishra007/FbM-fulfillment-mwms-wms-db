CREATE TABLE [dbo].[CartonShipmentDetail]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mbolkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Externorderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Buyerpo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UCCLabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonWeight] [float] NULL,
[DestinationZipCode] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassOfService] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingIdType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroundBarcodeString] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoutingCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASTRA_Barcode] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlannedServiceLevel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceTypeDescription] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialHandlingIndicators] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationAirportID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adddate] [datetime] NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Adddate] DEFAULT (getdate()),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Addwho] DEFAULT (suser_sname()),
[2dBarcode] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonCube] [float] NULL,
[FreightCharge] [float] NULL,
[InsCharge] [float] NULL,
[Editdate] [datetime] NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Editdate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Editwho] DEFAULT (suser_sname()),
[PackageID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS_RoutingCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS_URCVersion] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CartonShipmentDetail] ADD CONSTRAINT [PK__CartonShipmentDe__68667AF7] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CartonShipmentDetail_ExtrnOrd] ON [dbo].[CartonShipmentDetail] ([Externorderkey], [Storerkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CartonShipmentDetail_OrdKeyLblNo] ON [dbo].[CartonShipmentDetail] ([Orderkey], [UCCLabelNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Storerkey'
GO
