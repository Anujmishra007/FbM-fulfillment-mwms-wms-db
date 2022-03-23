SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_ApptId]
AS
SELECT [ApptId]
, [StartDateTime]
, [EndDateTime]
, [ApptType]
, [Facility]
, [Dock]
, [ShipmentType]
, [BookingDate]
, [DocumentNo]
, [DocumentType]
, [ContainerKey]
, [ContainerType]
, [CarrierKey]
, [VehicleType]
, [VehicleNo]
, [ShippingLine]
, [UserDefined1]
, [UserDefined2]
, [UserDefined3]
, [UserDefined4]
, [UserDefined5]
, [Notes1]
, [Notes2]
, [Status]
, [AddWho]
, [AddDate]
, [EditWho]
, [EditDate]
FROM [ApptId] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ApptId] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ApptId] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ApptId] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ApptId] TO [NSQL]
GO
