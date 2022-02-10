SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_PutawayStrategy] 
AS 
SELECT [PutawayStrategyKey]
, [Descr]
, [AddDate]
, [AddWho]
, [EditDate]
, [EditWho]
, [TrafficCop]
, [ArchiveCop]
, [Timestamp]
FROM [PutawayStrategy] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_PutawayStrategy] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_PutawayStrategy] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_PutawayStrategy] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_PutawayStrategy] TO [NSQL]
GO
