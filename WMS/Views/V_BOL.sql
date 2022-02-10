SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_BOL] 
AS 
SELECT [BolKey]
, [Status]
, [ExternBolKey]
, [OriginCountry]
, [DestinationCountry]
, [VesselQualifier]
, [Vessel]
, [PlaceOfLoadingQualifier]
, [PlaceOfLoading]
, [PlaceOfdischargeQualifier]
, [PlaceOfDischarge]
, [PlaceOfdeliveryQualifier]
, [PlaceOfdelivery]
, [TransMethod]
, [VoyageNumber]
, [DepartureDate]
, [ArrivalDate]
, [ArrivalDateFinalDestination]
, [BookingReference]
, [OtherReference]
, [CarrierKey]
, [CarrierAgent]
, [EffectiveDate]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [Shipper]
, [Consignee]
, [BillTo]
, [PreCarriage]
, [PlaceReceipt]
, [ShipperReference]
, [ForwarderReference]
FROM [BOL] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_BOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_BOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_BOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_BOL] TO [NSQL]
GO
