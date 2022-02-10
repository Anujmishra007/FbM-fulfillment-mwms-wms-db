SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_AreaDetail] 
AS 
SELECT [AreaKey]
, [PutawayZone]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
FROM [AreaDetail] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_AreaDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_AreaDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_AreaDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_AreaDetail] TO [NSQL]
GO
