SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_PAZoneEquipmentExcludeDetail]
AS
SELECT [PutawayZone]
, [EquipmentProfileKey]
, [Descr]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [PAZoneEquipmentExcludeDetail] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PAZoneEquipmentExcludeDetail] TO [NSQL]
GO
